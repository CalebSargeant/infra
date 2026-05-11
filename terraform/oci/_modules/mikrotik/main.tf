# ============================================================================
# Two MikroTik CHR routers in OCI, configured identically as HA replicas of
# the same Cloudflare tunnel. The routeros provider is iterated per router
# (OpenTofu 1.9+ feature) so each resource exists once and is fanned out via
# for_each. Connection details for the provider instances come from the
# generated provider.tf in this directory's terragrunt config.
# ============================================================================

locals {
  # Appended to every comment we set on RouterOS objects so future-you, staring
  # at the CLI, immediately knows not to edit it by hand.
  tf_marker = "(managed by Terraform)"

  # Derive resource for_each keys from var.routers. Wrapping in toset() makes
  # this a syntactically different expression from `var.routers` itself, which
  # OpenTofu requires so provider instances outlive resources during destroy.
  routers = toset(keys(var.routers))

  # Flatten router × address-list-entry for the per-router address lists.
  trusted_entries = flatten([
    for router in local.routers : [
      for comment, address in var.trusted_addresses : {
        router  = router
        comment = comment
        address = address
        key     = "${router}/${comment}"
      }
    ]
  ])
  rfc1918_entries = flatten([
    for router in local.routers : [
      for comment, address in var.rfc1918_addresses : {
        router  = router
        comment = comment
        address = address
        key     = "${router}/${comment}"
      }
    ]
  ])
}

# Note: WAN ether1 + its DHCP client are NOT managed by this module. They're
# prerequisites for the routeros provider itself to reach the router (no
# public IP = no API connectivity), so managing them via Terraform creates a
# chicken-and-egg. They live as default CHR config + whatever you set out of
# band. Same reason the routeros user/password and TLS cert aren't managed.

# --- Interfaces ---

resource "routeros_interface_bridge" "containers" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  name    = var.container_bridge_name
  comment = local.tf_marker
}

resource "routeros_interface_veth" "cloudflared" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  # dhcp defaults to false in RouterOS — setting it explicitly causes the
  # API to reject the call as "unknown parameter" on at least some 7.21.x
  # builds. Same reason mac_address is per-router via lookup: r2's API
  # rejects mac-address at create time, so we let RouterOS auto-generate.
  name        = "veth-cloudflared"
  address     = ["${var.cloudflared_container_ip}/${split("/", var.container_network_cidr)[1]}"]
  gateway     = var.container_gateway_ip
  mac_address = lookup(var.cloudflared_veth_macs, each.key, null)
  comment     = local.tf_marker
}

resource "routeros_interface_bridge_port" "veth_cloudflared" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  bridge    = routeros_interface_bridge.containers[each.key].name
  interface = routeros_interface_veth.cloudflared[each.key].name
  comment   = local.tf_marker
}

# --- IP addressing ---

resource "routeros_ip_address" "container_gateway" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  address   = "${var.container_gateway_ip}/${split("/", var.container_network_cidr)[1]}"
  interface = routeros_interface_bridge.containers[each.key].name
  network   = cidrhost(var.container_network_cidr, 0)
  comment   = local.tf_marker

  lifecycle {
    # r1's RouterOS API rejects `vrf` as an unknown parameter, but the
    # provider reads it back into state as "main" after create. Ignoring it
    # keeps the update payload free of vrf and avoids "unknown parameter".
    ignore_changes = [vrf]
  }
}

# --- Container runtime + cloudflared ---

resource "routeros_container_config" "this" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  registry_url = var.container_registry_url
  tmpdir       = var.container_tmpdir
}

resource "routeros_container_envs" "cloudflared_tunnel_token" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  name  = "CLOUDFLARED"
  key   = "TUNNEL_TOKEN"
  value = var.cloudflared_tunnel_token
}

resource "routeros_container" "cloudflared" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  # `name` is read-only on this provider — RouterOS derives it from the
  # remote_image. Rename manually via /container set if the auto name matters.
  remote_image  = var.cloudflared_image
  interface     = routeros_interface_veth.cloudflared[each.key].name
  envlist       = "CLOUDFLARED"
  cmd           = "tunnel --no-autoupdate --protocol quic run"
  logging       = true
  start_on_boot = true
  workdir       = "/home/nonroot"
  root_dir      = var.container_root_dir
  comment       = local.tf_marker
  # Per-router because r1's RouterOS accepts only "15-SIGTERM" (enum) while
  # r2's accepts only "15" (number). Different firmware/schema versions.
  stop_signal = var.cloudflared_stop_signals[each.key]

  lifecycle {
    # RouterOS may return the value back in a different format than it was
    # set, causing perpetual diff. Don't fight per-firmware display quirks.
    ignore_changes = [stop_signal]
  }

  depends_on = [
    routeros_container_config.this,
    routeros_container_envs.cloudflared_tunnel_token,
    routeros_interface_bridge_port.veth_cloudflared,
    routeros_ip_address.container_gateway,
  ]
}

# --- Firewall address lists ---

resource "routeros_ip_firewall_addr_list" "trusted" {
  for_each = { for e in local.trusted_entries : e.key => e }
  provider = routeros.by_router[each.value.router]

  list    = "TRUSTED"
  address = each.value.address
  comment = "${each.value.comment} ${local.tf_marker}"
}

resource "routeros_ip_firewall_addr_list" "rfc1918" {
  for_each = { for e in local.rfc1918_entries : e.key => e }
  provider = routeros.by_router[each.value.router]

  list    = "RFC1918"
  address = each.value.address
  comment = "${each.value.comment} ${local.tf_marker}"
}

# --- Firewall filter rules ---
# RouterOS appends API-created rules to the end of each chain, so the
# depends_on chain below preserves rsc order. depends_on references the
# whole prior resource (all router instances), which serialises the two
# routers' filter applies — acceptable for ~10 rules.

resource "routeros_ip_firewall_filter" "fwd_accept_established" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  action           = "accept"
  chain            = "forward"
  comment          = "accept forward established & related ${local.tf_marker}"
  connection_state = "established,related"
}

resource "routeros_ip_firewall_filter" "in_accept_established" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  action           = "accept"
  chain            = "input"
  comment          = "accept input established & related ${local.tf_marker}"
  connection_state = "established,related"

  depends_on = [routeros_ip_firewall_filter.fwd_accept_established]
}

resource "routeros_ip_firewall_filter" "fwd_drop_invalid" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  action           = "drop"
  chain            = "forward"
  comment          = "drop forward invalid ${local.tf_marker}"
  connection_state = "invalid"

  depends_on = [routeros_ip_firewall_filter.in_accept_established]
}

resource "routeros_ip_firewall_filter" "in_drop_invalid" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  action           = "drop"
  chain            = "input"
  comment          = "drop input invalid ${local.tf_marker}"
  connection_state = "invalid"

  depends_on = [routeros_ip_firewall_filter.fwd_drop_invalid]
}

resource "routeros_ip_firewall_filter" "in_accept_trusted" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  action           = "accept"
  chain            = "input"
  comment          = "accept input TRUSTED ${local.tf_marker}"
  src_address_list = "TRUSTED"

  depends_on = [
    routeros_ip_firewall_filter.in_drop_invalid,
    routeros_ip_firewall_addr_list.trusted,
  ]
}

resource "routeros_ip_firewall_filter" "fwd_accept_rfc1918" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  action           = "accept"
  chain            = "forward"
  comment          = "accept forward RFC1918 ${local.tf_marker}"
  src_address_list = "RFC1918"

  depends_on = [
    routeros_ip_firewall_filter.in_accept_trusted,
    routeros_ip_firewall_addr_list.rfc1918,
  ]
}

resource "routeros_ip_firewall_filter" "fwd_accept_trusted" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  action           = "accept"
  chain            = "forward"
  comment          = "accept forward TRUSTED ${local.tf_marker}"
  src_address_list = "TRUSTED"

  depends_on = [
    routeros_ip_firewall_filter.fwd_accept_rfc1918,
    routeros_ip_firewall_addr_list.trusted,
  ]
}

resource "routeros_ip_firewall_filter" "fwd_accept_rfc1918_2" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  action           = "accept"
  chain            = "forward"
  comment          = "accept input RFC1918 ${local.tf_marker}"
  src_address_list = "RFC1918"

  depends_on = [
    routeros_ip_firewall_filter.fwd_accept_trusted,
    routeros_ip_firewall_addr_list.rfc1918,
  ]
}

resource "routeros_ip_firewall_filter" "fwd_drop_all" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  action  = "drop"
  chain   = "forward"
  comment = "implicit deny forward ${local.tf_marker}"

  depends_on = [routeros_ip_firewall_filter.fwd_accept_rfc1918_2]
}

resource "routeros_ip_firewall_filter" "in_drop_all" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  action  = "drop"
  chain   = "input"
  comment = "implicit deny input ${local.tf_marker}"

  depends_on = [routeros_ip_firewall_filter.fwd_drop_all]
}

# --- NAT ---

resource "routeros_ip_firewall_nat" "container_masquerade" {
  for_each = local.routers
  provider = routeros.by_router[each.key]

  action      = "masquerade"
  chain       = "srcnat"
  src_address = var.container_network_cidr
  comment     = local.tf_marker
}
