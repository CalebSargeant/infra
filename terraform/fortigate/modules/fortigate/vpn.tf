# ============================================================================
# Route-based IPsec site-to-site VPN from each FortiGate to OCI's managed
# Site-to-Site VPN (DRG headend). OCI hands out two tunnel public IPs per IPSec
# connection; both are configured here and run active-active (ECMP), matching
# the rest of this design (no failover).
#
# The OCI side (CPE + IPSecConnection per FortiGate) lives in
# terraform/oci/prod/eu-amsterdam-1/vpn-fortigate. The remote_gw IPs and the
# PSKs are produced there (tunnel_ips output + Vault) and fed in via the leaf.
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
        fgt       = fk
        name      = t.name
        key       = "${fk}/${t.name}"
        remote_gw = t.remote_gw
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

# --- Phase 2 (IPsec SA / traffic selectors) per OCI tunnel -----------------
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
  src_subnet     = "${cidrhost(local.vpn_fgts[each.value.fgt].local_subnet, 0)} ${cidrnetmask(local.vpn_fgts[each.value.fgt].local_subnet)}"
  dst_subnet     = "${cidrhost(local.vpn_fgts[each.value.fgt].remote_subnet, 0)} ${cidrnetmask(local.vpn_fgts[each.value.fgt].remote_subnet)}"
}

# --- Route to the OCI VCN over each tunnel (equal distance = ECMP) ----------
resource "fortios_router_static" "oci_vcn" {
  for_each = { for e in local.vpn_tunnel_entries : e.key => e }
  provider = fortios.by_fortigate[each.value.fgt]

  dst      = "${cidrhost(local.vpn_fgts[each.value.fgt].remote_subnet, 0)} ${cidrnetmask(local.vpn_fgts[each.value.fgt].remote_subnet)}"
  device   = fortios_vpnipsec_phase1interface.oci[each.key].name
  distance = 1
  status   = "enable"
  comment  = "${local.marker} — OCI VCN via ${each.value.name}"
}

# --- Zone grouping both OCI tunnels, then policies trusted <-> OCI ----------
resource "fortios_system_zone" "oci_vpn" {
  for_each = local.vpn_fgt_keys
  provider = fortios.by_fortigate[each.key]

  name      = "oci-vpn"
  intrazone = "allow"

  dynamic "interface" {
    for_each = local.vpn_fgts[each.key].tunnels
    content {
      interface_name = fortios_vpnipsec_phase1interface.oci["${each.key}/${interface.value.name}"].name
    }
  }
}

# trusted VLAN -> OCI (no NAT: OCI must see real on-prem source addresses).
resource "fortios_firewall_policy" "trusted_to_oci" {
  for_each = local.vpn_fgt_keys
  provider = fortios.by_fortigate[each.key]

  policyid = 300
  name     = "trusted-to-oci"
  srcintf { name = fortios_system_interface.vlan["${each.key}/${local.trusted_vlan_name[each.key]}"].name }
  dstintf { name = fortios_system_zone.oci_vpn[each.key].name }
  srcaddr { name = "all" }
  dstaddr { name = "all" }
  service { name = "ALL" }
  action     = "accept"
  schedule   = "always"
  nat        = "disable"
  logtraffic = "all"
}

resource "fortios_firewall_policy" "oci_to_trusted" {
  for_each = local.vpn_fgt_keys
  provider = fortios.by_fortigate[each.key]

  policyid = 301
  name     = "oci-to-trusted"
  srcintf { name = fortios_system_zone.oci_vpn[each.key].name }
  dstintf { name = fortios_system_interface.vlan["${each.key}/${local.trusted_vlan_name[each.key]}"].name }
  srcaddr { name = "all" }
  dstaddr { name = "all" }
  service { name = "ALL" }
  action     = "accept"
  schedule   = "always"
  nat        = "disable"
  logtraffic = "all"
}
