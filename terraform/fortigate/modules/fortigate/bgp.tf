# ============================================================================
# BGP. Each FortiGate runs its own ASN and:
#   - eBGP-peers with OCI over BOTH IPsec tunnels (ecmp/active-active to the VCN)
#   - eBGP-peers with the other FortiGate over the interconnect (east-west)
# It advertises its VLAN subnets. (MikroTik keeps static ECMP defaults — the
# chosen BGP scope is "OCI + FGT<->FGT".)
# ============================================================================

locals {
  # OCI tunnel neighbors (one per tunnel, all in OCI's ASN -> ECMP).
  bgp_oci_neighbors = flatten([
    for fk, v in local.vpn_fgts : [
      for t in v.tunnels : {
        fgt       = fk
        ip        = t.bgp_oracle_ip
        remote_as = var.oci_bgp_asn
      }
    ]
  ])

  # Interconnect neighbor: the other FortiGate.
  bgp_icx_neighbors = [
    for fk, f in var.fortigates : {
      fgt       = fk
      ip        = f.interconnect.peer_ip
      remote_as = f.peer_bgp_asn
    }
  ]

  bgp_neighbors = concat(local.bgp_oci_neighbors, local.bgp_icx_neighbors)
}

resource "fortios_router_bgp" "this" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  as             = var.fortigates[each.key].bgp_asn
  router_id      = var.fortigates[each.key].interconnect.ip
  ebgp_multipath = "enable" # ECMP across the two OCI tunnels (active-active)

  dynamic "neighbor" {
    for_each = { for n in local.bgp_neighbors : n.ip => n if n.fgt == each.key }
    content {
      ip                   = neighbor.value.ip
      remote_as            = neighbor.value.remote_as
      activate             = "enable"
      soft_reconfiguration = "enable"
    }
  }

  # Advertise this unit's VLAN subnets (prefix derived from each VLAN's netmask).
  dynamic "network" {
    for_each = { for e in local.vlan_entries : tostring(e.id) => e if e.fgt == each.key }
    content {
      id     = network.value.id
      prefix = "${cidrhost("${network.value.ip}/${network.value.prefix_len}", 0)} ${network.value.netmask}"
    }
  }
}
