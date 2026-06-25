# ============================================================================
# Two home-lab MikroTik CRS switches (mt1 behind FGT1, mt2 behind FGT2 — mt2
# not installed yet). Each is an L2 access switch with two routed P2P uplinks
# (local FortiGate + cross-link to the opposite FortiGate) and an inter-switch
# link to the other site. Every resource is fanned out per switch via for_each.
# ============================================================================

locals {
  marker = "managed by Terraform"

  # Different expression from the provider's `for_each = var.mikrotiks` so
  # provider instances outlive resources during destroy (OpenTofu requirement).
  keys = toset(keys(var.mikrotiks))

  # Per switch: client port -> VLAN name (defaults to default_access_vlan).
  port_vlan = {
    for k, m in var.mikrotiks : k => {
      for port in m.client_ports : port => lookup(m.access_port_vlans, port, m.default_access_vlan)
    }
  }

  # router × bridge member ports. fgt_uplink is the tagged 802.1Q trunk to the
  # FortiGate (pvid 1, native); client ports are untagged access ports whose
  # pvid is their assigned VLAN id.
  bridge_port_entries = flatten([
    for k, m in var.mikrotiks : concat(
      [{
        router = k
        port   = m.ports.fgt_uplink
        key    = "${k}/${m.ports.fgt_uplink}"
        pvid   = 1
      }],
      [for port in m.client_ports : {
        router = k
        port   = port
        key    = "${k}/${port}"
        pvid   = var.vlans[local.port_vlan[k][port]].id
      }]
    )
  ])

  # router × vlan -> bridge VLAN table entry. The bridge + the FortiGate trunk
  # are tagged members of every VLAN; client access ports appear untagged in
  # the VLAN their pvid points at.
  bridge_vlan_entries = flatten([
    for k, m in var.mikrotiks : [
      for vname, v in var.vlans : {
        router   = k
        vlan     = vname
        id       = v.id
        key      = "${k}/${vname}"
        untagged = [for port in m.client_ports : port if local.port_vlan[k][port] == vname]
      }
    ]
  ])
}

# ---------------------------------------------------------------------------
# LAN bridge (MSTP for loop protection on the access ports). Both switches
# share one MST region (region_name + region_revision) so they interoperate as
# a single MSTP domain rather than degrading to RSTP between them.
# ---------------------------------------------------------------------------
resource "routeros_interface_bridge" "lan" {
  for_each = local.keys
  provider = routeros.by_router[each.key]

  name            = var.bridge_name
  protocol_mode   = var.bridge_protocol_mode
  region_name     = var.mst_region_name
  region_revision = var.mst_region_revision
  vlan_filtering  = true
  comment         = local.marker
}

# Bridge members: the local FortiGate trunk + all client (access) ports. pvid
# tags ingress untagged frames into the port's VLAN.
resource "routeros_interface_bridge_port" "lan" {
  for_each = { for e in local.bridge_port_entries : e.key => e }
  provider = routeros.by_router[each.value.router]

  bridge    = routeros_interface_bridge.lan[each.value.router].name
  interface = each.value.port
  pvid      = each.value.pvid
  comment   = local.marker
}

# Bridge VLAN table: tag every VLAN on the bridge + FortiGate trunk, and present
# access ports untagged in their VLAN.
resource "routeros_interface_bridge_vlan" "v" {
  for_each = { for e in local.bridge_vlan_entries : e.key => e }
  provider = routeros.by_router[each.value.router]

  bridge   = routeros_interface_bridge.lan[each.value.router].name
  vlan_ids = [tostring(each.value.id)]
  tagged   = [routeros_interface_bridge.lan[each.value.router].name, var.mikrotiks[each.value.router].ports.fgt_uplink]
  untagged = each.value.untagged
}

# Switch management lives on a VLAN interface (the mgmt VLAN) over the bridge,
# since vlan_filtering is on — untagged bridge frames would otherwise land in
# the native VLAN 1.
resource "routeros_interface_vlan" "mgmt" {
  for_each = local.keys
  provider = routeros.by_router[each.key]

  name      = "vlan-${var.mikrotiks[each.key].mgmt_vlan}"
  interface = routeros_interface_bridge.lan[each.key].name
  vlan_id   = var.vlans[var.mikrotiks[each.key].mgmt_vlan].id
}

# ---------------------------------------------------------------------------
# IP addressing
# ---------------------------------------------------------------------------

# Switch management IP on the mgmt-VLAN interface (FortiGate is the gateway and
# serves client DHCP per VLAN).
resource "routeros_ip_address" "bridge_lan" {
  for_each = local.keys
  provider = routeros.by_router[each.key]

  address   = var.mikrotiks[each.key].lan.bridge_ip
  interface = routeros_interface_vlan.mgmt[each.key].name
  network   = cidrhost(var.mikrotiks[each.key].lan.bridge_ip, 0)
  comment   = local.marker

  # r1's RouterOS API rejects `vrf` as unknown but the provider reads it back
  # as "main" — ignoring it keeps the update payload clean (see oci/mikrotik).
  lifecycle {
    ignore_changes = [vrf]
  }
}

# Routed /30 to the OPPOSITE FortiGate (second active internet path, ECMP).
resource "routeros_ip_address" "crosslink" {
  for_each = local.keys
  provider = routeros.by_router[each.key]

  address   = var.mikrotiks[each.key].crosslink.address
  interface = var.mikrotiks[each.key].ports.crosslink
  network   = cidrhost(var.mikrotiks[each.key].crosslink.address, 0)
  comment   = "${local.marker} — cross-link to opposite FortiGate"

  lifecycle {
    ignore_changes = [vrf]
  }
}

# Routed /30 to the OTHER MikroTik.
resource "routeros_ip_address" "mt_link" {
  for_each = local.keys
  provider = routeros.by_router[each.key]

  address   = var.mikrotiks[each.key].mt_link.address
  interface = var.mikrotiks[each.key].ports.mt_link
  network   = cidrhost(var.mikrotiks[each.key].mt_link.address, 0)
  comment   = "${local.marker} — inter-switch link"

  lifecycle {
    ignore_changes = [vrf]
  }
}

# ---------------------------------------------------------------------------
# Routing — both ISPs active-active (NOT failover).
#
# Two equal-distance (distance 1) default routes: one via the local FortiGate,
# one via the opposite FortiGate over the cross-link. RouterOS treats two routes
# with the same dst and same distance as ECMP, so client flows are load-balanced
# (per src+dst hash) across BOTH FortiGates / ISPs simultaneously. Each flow is
# pinned to one path, and the egress FortiGate SNATs it out its own ISP, so
# return traffic stays symmetric.
# ---------------------------------------------------------------------------

# Default route via the local FortiGate (ECMP member 1).
resource "routeros_ip_route" "default_local" {
  for_each = local.keys
  provider = routeros.by_router[each.key]

  dst_address = "0.0.0.0/0"
  gateway     = var.mikrotiks[each.key].lan.gateway
  distance    = 1
  comment     = "${local.marker} — default via local FortiGate (ECMP)"
}

# Default route via the opposite FortiGate over the cross-link (ECMP member 2).
resource "routeros_ip_route" "default_crosslink" {
  for_each = local.keys
  provider = routeros.by_router[each.key]

  dst_address = "0.0.0.0/0"
  gateway     = var.mikrotiks[each.key].crosslink.fgt_gateway
  distance    = 1
  comment     = "${local.marker} — default via opposite FortiGate / cross-link (ECMP)"
}

# Reach the other site's LAN directly over the inter-switch link.
resource "routeros_ip_route" "peer_lan" {
  for_each = local.keys
  provider = routeros.by_router[each.key]

  dst_address = var.mikrotiks[each.key].peer.lan_subnet
  gateway     = var.mikrotiks[each.key].peer.mt_link_ip
  distance    = 10
  comment     = "${local.marker} — route to peer site LAN via inter-switch link"
}
