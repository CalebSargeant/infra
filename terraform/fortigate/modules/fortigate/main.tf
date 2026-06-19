# ============================================================================
# Two standalone FortiGate 40Fs (no HA), each a resilient edge. Every resource
# is declared once and fanned out across both units via `for_each = local.keys`
# with `provider = fortios.by_fortigate[each.key]`.
# ============================================================================

locals {
  marker = "managed by Terraform"

  # Resource for_each keys. toset(keys(...)) is intentionally a DIFFERENT
  # expression from the provider's `for_each = var.fortigates`, which OpenTofu
  # requires so provider instances outlive the resources during destroy.
  keys = toset(keys(var.fortigates))
}

# ---------------------------------------------------------------------------
# Interfaces
# ---------------------------------------------------------------------------

# WAN — each FortiGate has its own ISP. DHCP by default; the ISP supplies the
# default route (a lower-priority backup default via the interconnect is added
# below for ISP failover).
resource "fortios_system_interface" "wan" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  name        = var.fortigates[each.key].ports.wan
  vdom        = var.fortigates[each.key].vdom
  mode        = var.fortigates[each.key].wan_mode
  ip          = "0.0.0.0 0.0.0.0"
  type        = "physical"
  role        = "wan"
  allowaccess = var.wan_allowaccess
  description = local.marker
}

# Direct firewall-to-firewall interconnect (FGT1 <-> FGT2).
resource "fortios_system_interface" "interconnect" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  name        = var.fortigates[each.key].ports.interconnect
  vdom        = var.fortigates[each.key].vdom
  mode        = "static"
  ip          = "${var.fortigates[each.key].interconnect.ip} ${var.fortigates[each.key].interconnect.netmask}"
  type        = "physical"
  role        = "lan"
  allowaccess = "ping"
  description = "${local.marker} — FGT<->FGT interconnect"
}

# LAN — link to the MikroTik directly behind this unit. Clients sit behind the
# MikroTik; this interface is their default gateway (DHCP server below).
resource "fortios_system_interface" "lan" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  name        = var.fortigates[each.key].ports.lan_mikrotik
  vdom        = var.fortigates[each.key].vdom
  mode        = "static"
  ip          = "${var.fortigates[each.key].lan.ip} ${var.fortigates[each.key].lan.netmask}"
  type        = "physical"
  role        = "lan"
  allowaccess = var.lan_allowaccess
  description = "${local.marker} — LAN to local MikroTik"
}

# Cross-link to the OPPOSITE unit's MikroTik (resilient mesh path).
resource "fortios_system_interface" "crosslink" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  name        = var.fortigates[each.key].ports.crosslink
  vdom        = var.fortigates[each.key].vdom
  mode        = "static"
  ip          = "${var.fortigates[each.key].crosslink.ip} ${var.fortigates[each.key].crosslink.netmask}"
  type        = "physical"
  role        = "lan"
  allowaccess = "ping"
  description = "${local.marker} — cross-link to opposite MikroTik"
}

# ---------------------------------------------------------------------------
# Zone: group the internal-facing interfaces (local LAN + cross-link) so
# policies reference one logical "internal". intrazone=allow lets traffic move
# between the two switch-facing legs without an explicit policy.
# ---------------------------------------------------------------------------
resource "fortios_system_zone" "internal" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  name      = var.internal_zone_name
  intrazone = "allow"

  interface {
    interface_name = fortios_system_interface.lan[each.key].name
  }
  interface {
    interface_name = fortios_system_interface.crosslink[each.key].name
  }
}

# ---------------------------------------------------------------------------
# DHCP server on the LAN segment
# ---------------------------------------------------------------------------
resource "fortios_systemdhcp_server" "lan" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  fosid           = 1
  status          = "enable"
  interface       = fortios_system_interface.lan[each.key].name
  default_gateway = var.fortigates[each.key].lan.ip
  netmask         = var.fortigates[each.key].lan.netmask
  dns_service     = "default"
  lease_time      = 86400

  ip_range {
    id       = 1
    start_ip = var.fortigates[each.key].lan.dhcp_start
    end_ip   = var.fortigates[each.key].lan.dhcp_end
  }
}

# ---------------------------------------------------------------------------
# Firewall policies
# ---------------------------------------------------------------------------

# internal -> wan : primary internet egress (source NAT).
resource "fortios_firewall_policy" "internal_to_wan" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  policyid   = 1
  name       = "internal-to-wan"
  srcintf { name = fortios_system_zone.internal[each.key].name }
  dstintf { name = fortios_system_interface.wan[each.key].name }
  srcaddr { name = "all" }
  dstaddr { name = "all" }
  service { name = "ALL" }
  action     = "accept"
  schedule   = "always"
  nat        = "enable"
  logtraffic = "all"
}

# internal -> interconnect : east-west to the other site (routed, no NAT).
resource "fortios_firewall_policy" "internal_to_interconnect" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  policyid   = 2
  name       = "internal-to-interconnect"
  srcintf { name = fortios_system_zone.internal[each.key].name }
  dstintf { name = fortios_system_interface.interconnect[each.key].name }
  srcaddr { name = "all" }
  dstaddr { name = "all" }
  service { name = "ALL" }
  action     = "accept"
  schedule   = "always"
  nat        = "disable"
  logtraffic = "all"
}

# interconnect -> internal : return / other-site traffic into the local LAN.
resource "fortios_firewall_policy" "interconnect_to_internal" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  policyid   = 3
  name       = "interconnect-to-internal"
  srcintf { name = fortios_system_interface.interconnect[each.key].name }
  dstintf { name = fortios_system_zone.internal[each.key].name }
  srcaddr { name = "all" }
  dstaddr { name = "all" }
  service { name = "ALL" }
  action     = "accept"
  schedule   = "always"
  nat        = "disable"
  logtraffic = "all"
}

# NOTE: both ISPs run active-active — each FortiGate only ever NATs out its OWN
# WAN. Cross-site egress is the MikroTik load-balancing (ECMP) onto whichever
# FortiGate, arriving on the cross-link (which sits in the `internal` zone), so
# the internal->wan policy above already covers it. There is deliberately no
# interconnect->wan "failover egress" policy and no backup default route.

# ---------------------------------------------------------------------------
# Routing
# ---------------------------------------------------------------------------

# East-west: reach the other site's LAN via the interconnect peer.
resource "fortios_router_static" "peer_lan" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  dst      = "${cidrhost(var.fortigates[each.key].peer_lan_subnet, 0)} ${cidrnetmask(var.fortigates[each.key].peer_lan_subnet)}"
  gateway  = var.fortigates[each.key].interconnect.peer_ip
  device   = fortios_system_interface.interconnect[each.key].name
  distance = 10
  status   = "enable"
  comment  = "${local.marker} — route to peer site LAN"
}
