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
  default     = true
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
    hostname = string                     # management host the provider connects to (mgmt IP / FQDN)
    vdom     = optional(string, "root")
    wan_mode = optional(string, "dhcp")   # static | dhcp | pppoe — each FortiGate has its own ISP

    # Physical port roles on the 40F. The 40F ships its 4 internal GE ports as
    # one hardware switch; break it up (or remap) here. VERIFY the real names
    # on each unit with `get system interface physical` before apply.
    ports = optional(object({
      wan          = optional(string, "wan")       # ISP uplink
      interconnect = optional(string, "internal1") # direct link to the other FortiGate
      lan_mikrotik = optional(string, "internal2") # link to the MikroTik directly behind this unit
      crosslink    = optional(string, "internal3") # cross-link to the OPPOSITE unit's MikroTik
    }), {})

    # LAN segment (clients live behind the MikroTik; this FortiGate is the gw).
    lan = object({
      ip         = string                          # gateway IP, e.g. "10.10.10.1"
      netmask    = optional(string, "255.255.255.0")
      dhcp_start = string
      dhcp_end   = string
    })

    # Point-to-point /30 to the other FortiGate.
    interconnect = object({
      ip      = string                             # this unit's IP, e.g. "10.255.255.1"
      netmask = optional(string, "255.255.255.252")
      peer_ip = string                             # the other unit's interconnect IP (failover/east-west next-hop)
    })

    # Point-to-point /30 to the OPPOSITE unit's MikroTik.
    crosslink = object({
      ip      = string
      netmask = optional(string, "255.255.255.252")
    })

    # The other site's LAN CIDR (e.g. "10.20.20.0/24") — installs an east-west
    # static route to it via the interconnect peer.
    peer_lan_subnet = string
  }))
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

variable "internal_zone_name" {
  description = "Name of the zone grouping the internal-facing (LAN + cross-link) interfaces."
  type        = string
  default     = "internal"
}
