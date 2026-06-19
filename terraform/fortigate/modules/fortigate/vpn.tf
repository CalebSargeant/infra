# ============================================================================
# Route-based IPsec site-to-site VPN from each FortiGate to OCI's managed
# Site-to-Site VPN (DRG headend). OCI hands out two tunnel public IPs per IPSec
# connection; both are configured here and run active-active.
#
# Routing over the tunnels is BGP (see bgp.tf), so the phase2 selectors are
# 0.0.0.0/0 and there are no static routes to the VCN here — BGP learns it.
# SD-WAN (sdwan.tf) steers VCN-bound traffic across the two tunnels.
#
# OCI side: terraform/oci/prod/eu-amsterdam-1/vpn-fortigate (routing_type BGP).
# ============================================================================

locals {
  # FortiGates that have OCI VPN configured.
  vpn_fgts = {
    for fk, f in var.fortigates : fk => f.oci_vpn
    if f.oci_vpn != null && try(f.oci_vpn.enabled, true)
  }
  vpn_fgt_keys = toset(keys(local.vpn_fgts))

  # fgt × OCI tunnel -> flat list, keyed "<fgt>/<tunnelname>".
  vpn_tunnel_entries = flatten([
    for fk, v in local.vpn_fgts : [
      for t in v.tunnels : {
        fgt             = fk
        name            = t.name
        key             = "${fk}/${t.name}"
        remote_gw       = t.remote_gw
        bgp_customer_ip = t.bgp_customer_ip
        bgp_oracle_ip   = t.bgp_oracle_ip
        # tunnel-interface ip / remote-ip in "addr mask" form
        cust_addr   = "${split("/", t.bgp_customer_ip)[0]} ${cidrnetmask("0.0.0.0/${split("/", t.bgp_customer_ip)[1]}")}"
        remote_addr = "${t.bgp_oracle_ip} ${cidrnetmask("0.0.0.0/${split("/", t.bgp_customer_ip)[1]}")}"
      }
    ]
  ])
}

# --- Phase 1 (IKE gateway) per OCI tunnel ----------------------------------
resource "fortios_vpnipsec_phase1interface" "oci" {
  for_each = { for e in local.vpn_tunnel_entries : e.key => e }
  provider = fortios.by_fortigate[each.value.fgt]

  name         = each.value.name
  type         = "static"
  interface    = var.fortigates[each.value.fgt].ports.wan
  ike_version  = local.vpn_fgts[each.value.fgt].ike_version
  peertype     = "any"
  net_device   = "enable" # route-based (creates a tunnel interface)
  proposal     = local.vpn_fgts[each.value.fgt].proposal
  dhgrp        = local.vpn_fgts[each.value.fgt].dhgrp
  remote_gw    = each.value.remote_gw
  psksecret    = var.fortigate_oci_vpn_psks[each.value.fgt]
  dpd          = "on-idle"
  nattraversal = "enable"
  comment      = "${local.marker} — to OCI (${each.value.name})"
}

# --- Tunnel-interface inside IPs (BGP transit) -----------------------------
# Sets the /30 inside addresses OCI expects for BGP over each tunnel. NOTE: the
# phase1 above auto-creates this interface (net_device); on a first real apply
# you may need to `terraform import` it (or set ip/remote-ip out-of-band) since
# the provider can't create an interface that already exists.
resource "fortios_system_interface" "oci_tunnel" {
  for_each = { for e in local.vpn_tunnel_entries : e.key => e }
  provider = fortios.by_fortigate[each.value.fgt]

  name        = fortios_vpnipsec_phase1interface.oci[each.key].name
  vdom        = var.fortigates[each.value.fgt].vdom
  type        = "tunnel"
  interface   = var.fortigates[each.value.fgt].ports.wan
  ip          = each.value.cust_addr
  remote_ip   = each.value.remote_addr
  allowaccess = "ping"
  description = "${local.marker} — OCI BGP transit (${each.value.name})"
}

# --- Phase 2 (IPsec SA) per OCI tunnel — 0.0.0.0/0 selectors for BGP --------
resource "fortios_vpnipsec_phase2interface" "oci" {
  for_each = { for e in local.vpn_tunnel_entries : e.key => e }
  provider = fortios.by_fortigate[each.value.fgt]

  name           = "${each.value.name}-p2"
  phase1name     = fortios_vpnipsec_phase1interface.oci[each.key].name
  proposal       = local.vpn_fgts[each.value.fgt].proposal
  pfs            = "enable"
  dhgrp          = local.vpn_fgts[each.value.fgt].dhgrp
  keepalive      = "enable"
  auto_negotiate = "enable"
  src_subnet     = "0.0.0.0 0.0.0.0"
  dst_subnet     = "0.0.0.0 0.0.0.0"
}

# Policies trusted <-> OCI. The two tunnels live in the SD-WAN "oci" zone
# (sdwan.tf), so policies reference that zone by name (depends_on ties ordering;
# an SD-WAN member interface can't also be in a normal zone).
resource "fortios_firewall_policy" "trusted_to_oci" {
  for_each   = local.vpn_fgt_keys
  provider   = fortios.by_fortigate[each.key]
  depends_on = [fortios_system_sdwan.this]

  policyid = 300
  name     = "trusted-to-oci"
  srcintf { name = fortios_system_interface.vlan["${each.key}/${local.trusted_vlan_name[each.key]}"].name }
  dstintf { name = "oci" }
  srcaddr { name = "all" }
  dstaddr { name = "all" }
  service { name = "ALL" }
  action     = "accept"
  schedule   = "always"
  nat        = "disable"
  logtraffic = "all"
}

resource "fortios_firewall_policy" "oci_to_trusted" {
  for_each   = local.vpn_fgt_keys
  provider   = fortios.by_fortigate[each.key]
  depends_on = [fortios_system_sdwan.this]

  policyid = 301
  name     = "oci-to-trusted"
  srcintf { name = "oci" }
  dstintf { name = fortios_system_interface.vlan["${each.key}/${local.trusted_vlan_name[each.key]}"].name }
  srcaddr { name = "all" }
  dstaddr { name = "all" }
  service { name = "ALL" }
  action     = "accept"
  schedule   = "always"
  nat        = "disable"
  logtraffic = "all"
}
