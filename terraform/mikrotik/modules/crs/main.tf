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

  # router × (local-FGT-uplink + client ports) -> flat list of bridge members.
  bridge_port_entries = flatten([
    for k, m in var.mikrotiks : [
      for port in concat([m.ports.fgt_uplink], m.client_ports) : {
        router = k
        port   = port
        key    = "${k}/${port}"
      }
    ]
  ])
}

# ---------------------------------------------------------------------------
# LAN bridge (RSTP for loop protection on the access ports)
# ---------------------------------------------------------------------------
resource "routeros_interface_bridge" "lan" {
  for_each = local.keys
  provider = routeros.by_router[each.key]

  name          = var.bridge_name
  protocol_mode = "rstp"
  comment       = local.marker
}

# Bridge members: the local FortiGate uplink + all client ports.
resource "routeros_interface_bridge_port" "lan" {
  for_each = { for e in local.bridge_port_entries : e.key => e }
  provider = routeros.by_router[each.value.router]

  bridge    = routeros_interface_bridge.lan[each.value.router].name
  interface = each.value.port
  comment   = local.marker
}

# ---------------------------------------------------------------------------
# IP addressing
# ---------------------------------------------------------------------------

# Management IP on the LAN bridge (FortiGate hands clients their addresses).
resource "routeros_ip_address" "bridge_lan" {
  for_each = local.keys
  provider = routeros.by_router[each.key]

  address   = var.mikrotiks[each.key].lan.bridge_ip
  interface = routeros_interface_bridge.lan[each.key].name
  network   = cidrhost(var.mikrotiks[each.key].lan.bridge_ip, 0)
  comment   = local.marker

  # r1's RouterOS API rejects `vrf` as unknown but the provider reads it back
  # as "main" — ignoring it keeps the update payload clean (see oci/mikrotik).
  lifecycle {
    ignore_changes = [vrf]
  }
}

# Routed /30 to the OPPOSITE FortiGate (backup internet path).
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
# Routing
# ---------------------------------------------------------------------------

# Primary default route via the local FortiGate.
resource "routeros_ip_route" "default_primary" {
  for_each = local.keys
  provider = routeros.by_router[each.key]

  dst_address = "0.0.0.0/0"
  gateway     = var.mikrotiks[each.key].lan.gateway
  distance    = 1
  comment     = "${local.marker} — default via local FortiGate"
}

# Backup default route via the opposite FortiGate over the cross-link. Higher
# distance, so it only takes over when the primary next-hop is unreachable.
resource "routeros_ip_route" "default_backup" {
  for_each = local.keys
  provider = routeros.by_router[each.key]

  dst_address = "0.0.0.0/0"
  gateway     = var.mikrotiks[each.key].crosslink.fgt_gateway
  distance    = 20
  comment     = "${local.marker} — backup default via opposite FortiGate (cross-link)"
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
