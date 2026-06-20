# ---------------------------------------------------------------------------
# Connection (one provider instance per FortiGate; iterated by for_each)
# ---------------------------------------------------------------------------
variable "fortigate_tokens" {
  description = "API token per FortiGate (keyed fgt1/fgt2). REST API admin token from 'config system api-user' on each unit. Sourced from OCI Vault by the leaf — never commit a real token to this public repo."
  type        = map(string)
  sensitive   = true
}

variable "fortigate_insecure" {
  description = "Skip TLS verification of the FortiGate management cert (self-signed by default on a 40F). Set false once a trusted cert is installed."
  type        = bool
  default     = true # TODO(when-cert-installed): flip to false once each unit has a trusted mgmt cert
}

# ---------------------------------------------------------------------------
# Per-FortiGate topology
#
# Physical topology being modelled (end-state; not all cabled yet):
#   ISP1 ── wan ─▶ FGT1                 ISP2 ── wan ─▶ FGT2
#   FGT1 ◀── interconnect ──▶ FGT2      (direct firewall-to-firewall link)
#   FGT1 ◀── lan_mikrotik ──▶ MikroTik1 (CRS directly behind FGT1)
#   FGT2 ◀── lan_mikrotik ──▶ MikroTik2 (CRS behind FGT2 — not present yet)
#   FGT1 ◀── crosslink ──▶ MikroTik2    (cross-link to the OPPOSITE switch)
#   FGT2 ◀── crosslink ──▶ MikroTik1    (cross-link to the OPPOSITE switch)
#
# All IPs here are PLACEHOLDERS in RFC1918 space — adjust to your real scheme.
# ---------------------------------------------------------------------------
variable "fortigates" {
  description = "Per-FortiGate connection + interface/topology config, keyed fgt1/fgt2."
  type = map(object({
    hostname = string # management host the provider connects to (mgmt IP / FQDN)
    vdom     = optional(string, "root")
    wan_mode = optional(string, "dhcp") # static | dhcp | pppoe — each FortiGate has its own ISP

    # Physical port roles on the 40F. The 40F ships its 4 internal GE ports as
    # one hardware switch; break it up (or remap) here. VERIFY the real names
    # on each unit with `get system interface physical` before apply.
    ports = optional(object({
      wan          = optional(string, "wan")       # ISP uplink
      interconnect = optional(string, "internal1") # direct link to the other FortiGate
      lan_mikrotik = optional(string, "internal2") # link to the MikroTik directly behind this unit
      crosslink    = optional(string, "internal3") # cross-link to the OPPOSITE unit's MikroTik
    }), {})

    # VLANs trunked over ports.lan_mikrotik. Each becomes an L3 subinterface +
    # DHCP scope + firewall policies. Exactly ONE vlan should set trusted=true.
    # Convention: subnet = 10.<site>.<vlanid>.0/24.
    vlans = map(object({
      id         = number # 802.1Q tag
      ip         = string # gateway IP, e.g. "10.10.10.1"
      netmask    = optional(string, "255.255.255.0")
      dhcp_start = string
      dhcp_end   = string
      trusted    = optional(bool, false) # may initiate to all other VLANs + interconnect
    }))

    # Point-to-point /30 to the other FortiGate.
    interconnect = object({
      ip      = string # this unit's IP, e.g. "10.255.255.1"
      netmask = optional(string, "255.255.255.252")
      peer_ip = string # the other unit's interconnect IP (failover/east-west next-hop)
    })

    # Point-to-point /30 to the OPPOSITE unit's MikroTik.
    crosslink = object({
      ip      = string
      netmask = optional(string, "255.255.255.252")
    })

    # The other site's supernet (e.g. "10.20.0.0/16") — installs an east-west
    # static route to it via the interconnect peer.
    peer_lan_subnet = string

    # BGP (see bgp.tf). Each FortiGate runs its own ASN, peers with OCI over the
    # IPsec tunnels, and eBGP-peers with the other FortiGate over the interconnect.
    bgp_asn      = number # this unit's ASN, e.g. 65010
    peer_bgp_asn = number # the other FortiGate's ASN (interconnect eBGP), e.g. 65020

    # Optional route-based IPsec site-to-site VPN to OCI (vpn.tf) — BGP-routed
    # (bgp.tf) and steered by SD-WAN (sdwan.tf). tunnels = OCI's two tunnel
    # public IPs + BGP inside IPs for this unit's IPSec connection.
    oci_vpn = optional(object({
      enabled       = optional(bool, true)
      remote_subnet = optional(string, "192.168.223.0/24") # OCI VCN (SD-WAN service dst / health-check)
      ike_version   = optional(string, "2")
      proposal      = optional(string, "aes256-sha256")
      dhgrp         = optional(string, "14")
      tunnels = list(object({
        name            = string           # FortiGate IPsec interface name (<= 15 chars), e.g. "oci-t1"
        remote_gw       = string           # OCI tunnel public IP
        bgp_customer_ip = string           # this unit's BGP inside IP on the tunnel WITH prefix, e.g. "169.254.22.2/30"
        bgp_oracle_ip   = string           # OCI's BGP inside IP (neighbor), e.g. "169.254.22.1"
        health_check_ip = optional(string) # SD-WAN probe target reachable over this tunnel (defaults to bgp_oracle_ip)
      }))
    }))

    # Optional IPsec dial-up remote access (remote-access.tf), authenticated via
    # Google SAML. mode-config assigns clients from this pool.
    remote_access = optional(object({
      enabled       = optional(bool, true)
      pool_start    = string # e.g. "10.10.250.1"
      pool_end      = string # e.g. "10.10.250.50"
      pool_netmask  = optional(string, "255.255.255.0")
      client_dns    = string # DNS pushed to clients (the trusted VLAN gw)
      split_include = string # subnet clients route over the tunnel, e.g. "10.10.0.0/16"
    }))
  }))

  validation {
    condition     = alltrue([for k, f in var.fortigates : length([for vn, v in f.vlans : vn if try(v.trusted, false)]) == 1])
    error_message = "Each FortiGate must have exactly one VLAN with trusted = true."
  }
}

variable "fortigate_oci_vpn_psks" {
  description = "Pre-shared key per FortiGate for the OCI IPsec tunnels (shared with the OCI IPSecConnection). Sourced from OCI Vault by the leaf — never commit a real PSK."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "fortigate_remote_access_psks" {
  description = "Gateway pre-shared key per FortiGate for the IPsec dial-up remote-access VPN (users still auth via Google SAML). Sourced from OCI Vault by the leaf."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "lan_allowaccess" {
  description = "Management protocols permitted on LAN-facing interfaces."
  type        = string
  default     = "ping https ssh"
}

variable "wan_allowaccess" {
  description = "Management protocols permitted on WAN interfaces. Keep minimal on an internet-facing link (ideally empty / ping only)."
  type        = string
  default     = "ping"
}

variable "oci_bgp_asn" {
  description = "OCI's BGP ASN for the Site-to-Site VPN (commercial realm default 31898). The FortiGates eBGP-peer with this over the tunnels."
  type        = number
  default     = 31898
}

# ---------------------------------------------------------------------------
# Identity — Google Workspace as a SAML IdP (remote-access.tf)
# ---------------------------------------------------------------------------
variable "saml_idp" {
  description = "Google Workspace SAML IdP details for the remote-access VPN. Values come from the Google Admin SAML app; idp_cert must already be imported on the FortiGate."
  type = object({
    idp_entity_id   = string # e.g. "https://accounts.google.com/o/saml2?idpid=XXXX"
    idp_sso_url     = string # Google SSO URL
    idp_slo_url     = optional(string, "")
    idp_cert_name   = string                               # name of the imported Google signing cert on the FortiGate
    sp_cert         = optional(string, "Fortinet_Factory") # SP signing cert
    user_name_field = optional(string, "username")
    group_name      = optional(string, "group")
  })
  default = {
    idp_entity_id = ""
    idp_sso_url   = ""
    idp_cert_name = "google-idp-cert"
  }
}

# ---------------------------------------------------------------------------
# Visibility (monitoring.tf)
# ---------------------------------------------------------------------------
variable "syslog" {
  description = "Remote syslog collector. Disabled if server is empty."
  type = object({
    server    = optional(string, "")
    port      = optional(number, 514)
    mode      = optional(string, "udp")
    facility  = optional(string, "local7")
    source_ip = optional(string, "")
  })
  default = {}
}

variable "netflow" {
  description = "NetFlow collector. Disabled if collector_ip is empty."
  type = object({
    collector_ip   = optional(string, "")
    collector_port = optional(number, 2055)
    source_ip      = optional(string, "")
  })
  default = {}
}

variable "automation_webhook_url" {
  description = "Webhook URL for automation-stitch notifications (e.g. a chat/incident endpoint). Disabled if empty."
  type        = string
  default     = ""
}

