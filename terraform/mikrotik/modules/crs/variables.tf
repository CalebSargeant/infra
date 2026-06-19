# ---------------------------------------------------------------------------
# Connection (one provider instance per switch; iterated by for_each)
# ---------------------------------------------------------------------------
variable "routeros_username" {
  description = "RouterOS API username (shared by both switches)."
  type        = string
  default     = "admin"
}

variable "routeros_password" {
  description = "RouterOS API password. Sourced from OCI Vault by the leaf — never commit a real password to this public repo."
  type        = string
  sensitive   = true
}

variable "routeros_insecure" {
  description = "Skip TLS verification (binary API on 8728 is unencrypted anyway; relevant only if you switch to the HTTPS REST transport)."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Per-switch topology
#
# Each CRS is an L2 access switch (FortiGate is the gateway + DHCP server) with
# two routed point-to-point uplinks for resilience:
#   - LAN bridge  : local FortiGate uplink + client ports (one subnet)
#   - crosslink   : /30 to the OPPOSITE FortiGate (2nd active default, ECMP)
#   - mt_link     : /30 to the OTHER MikroTik (reach the peer site's LAN)
#
# Both ISPs run active-active: equal-distance default routes via the local and
# opposite FortiGate ECMP-balance client traffic across both ISPs at once.
#
# All IPs are PLACEHOLDERS and are kept consistent with the fortigate module's
# placeholder scheme (10.255.255.0/24 carves the /30s; LANs 10.10.10/24,
# 10.20.20/24). The crosslink + mt_link are routed ether ports, NOT bridged, so
# there's no L2 loop between sites; MSTP still guards the local bridge.
# ---------------------------------------------------------------------------
variable "mikrotiks" {
  description = "Per-CRS connection + interface/topology config, keyed mt1/mt2."
  type = map(object({
    hosturl = string # binary-API URL, e.g. "api://10.10.10.2:8728"

    # Physical port roles. VERIFY against the real CRS model's port names
    # (ether1..N / sfp* / qsfp*) with `/interface print` before apply.
    ports = object({
      fgt_uplink = optional(string, "ether1") # to the local FortiGate (bridged into the LAN)
      crosslink  = optional(string, "ether2") # routed /30 to the opposite FortiGate
      mt_link    = optional(string, "ether3") # routed /30 to the other MikroTik
    })

    client_ports = list(string) # additional ether ports bridged into the LAN

    lan = object({
      bridge_ip = string # mgmt IP on the LAN bridge WITH prefix, e.g. "10.10.10.2/24"
      gateway   = string # local FortiGate LAN IP (one ECMP default route), e.g. "10.10.10.1"
    })

    crosslink = object({
      address     = string # this switch's /30 IP WITH prefix, e.g. "10.255.255.6/30"
      fgt_gateway = string # opposite FortiGate's crosslink IP (2nd ECMP default), e.g. "10.255.255.5"
    })

    mt_link = object({
      address = string # this switch's /30 IP WITH prefix, e.g. "10.255.255.13/30"
    })

    peer = object({
      lan_subnet = string # other site's LAN CIDR, routed via mt_link, e.g. "10.20.20.0/24"
      mt_link_ip = string # other MikroTik's mt_link IP (next hop), e.g. "10.255.255.14"
    })
  }))
}

variable "bridge_name" {
  description = "Name of the LAN bridge created on each switch."
  type        = string
  default     = "bridge-lan"
}

variable "bridge_protocol_mode" {
  description = "Spanning-tree mode for the LAN bridge. MSTP preferred over RSTP."
  type        = string
  default     = "mstp"
}

# region_name + region_revision must be IDENTICAL on both switches for them to
# form a single MST region (otherwise each ends up in its own region and MSTP
# degrades to RSTP between them).
variable "mst_region_name" {
  description = "MSTP region name (must match across both switches). Only used when bridge_protocol_mode = mstp."
  type        = string
  default     = "home-edge"
}

variable "mst_region_revision" {
  description = "MSTP configuration revision number (must match across both switches)."
  type        = number
  default     = 1
}
