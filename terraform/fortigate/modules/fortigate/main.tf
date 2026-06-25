# ============================================================================
# Two standalone FortiGate 40Fs (no HA), each a resilient edge. Every resource
# is declared once and fanned out across both units via `for_each = local.keys`
# with `provider = fortios.by_fortigate[each.key]`.
#
# Client segmentation lives in vlans.tf — the LAN port (ports.lan_mikrotik) is a
# tagged 802.1Q trunk to the MikroTik; each VLAN is an L3 subinterface here.
# ============================================================================

locals {
  marker = "managed by Terraform"

  # Resource for_each keys. toset(keys(...)) is intentionally a DIFFERENT
  # expression from the provider's `for_each = var.fortigates`, which OpenTofu
  # requires so provider instances outlive the resources during destroy.
  keys = toset(keys(var.fortigates))
}

# ---------------------------------------------------------------------------
# Physical interfaces
# ---------------------------------------------------------------------------

# WAN — each FortiGate has its own ISP (active-active; see vlans.tf for egress).
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

# LAN trunk to the local MikroTik. No L3 of its own — it's the 802.1Q parent for
# the VLAN subinterfaces in vlans.tf. The MikroTik tags these VLANs on this link.
resource "fortios_system_interface" "lan_trunk" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  name        = var.fortigates[each.key].ports.lan_mikrotik
  vdom        = var.fortigates[each.key].vdom
  mode        = "static"
  ip          = "0.0.0.0 0.0.0.0"
  type        = "physical"
  role        = "lan"
  allowaccess = "ping"
  description = "${local.marker} — 802.1Q trunk to local MikroTik"
}

# Cross-link to the OPPOSITE unit's MikroTik (resilient mesh path; carries the
# other site's ECMP internet egress — see crosslink_to_wan below).
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
# Cross-link egress — active-active second ISP path.
#
# The opposite site's MikroTik ECMP-balances some flows onto this FortiGate via
# the cross-link; SNAT them out this unit's own WAN. (No backup default route /
# no failover: both ISPs are always live.)
# ---------------------------------------------------------------------------
resource "fortios_firewall_policy" "crosslink_to_wan" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  policyid = 10
  name     = "crosslink-to-wan"
  srcintf { name = fortios_system_interface.crosslink[each.key].name }
  dstintf { name = fortios_system_interface.wan[each.key].name }
  srcaddr { name = "all" }
  dstaddr { name = "all" }
  service { name = "ALL" }
  action     = "accept"
  schedule   = "always"
  nat        = "enable"
  logtraffic = "all"
}

# ---------------------------------------------------------------------------
# Routing
# ---------------------------------------------------------------------------

# East-west: reach the other site's networks via the interconnect peer.
resource "fortios_router_static" "peer_lan" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  dst      = "${cidrhost(var.fortigates[each.key].peer_lan_subnet, 0)} ${cidrnetmask(var.fortigates[each.key].peer_lan_subnet)}"
  gateway  = var.fortigates[each.key].interconnect.peer_ip
  device   = fortios_system_interface.interconnect[each.key].name
  distance = 10
  status   = "enable"
  comment  = "${local.marker} — route to peer site networks"
}
