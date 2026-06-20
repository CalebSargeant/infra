# ============================================================================
# SD-WAN overlay across the two OCI IPsec tunnels. Each FortiGate has a single
# physical ISP, so SD-WAN here is the OCI overlay: an "oci" zone with both
# tunnels as members, a health-check SLA, and a load-balance service rule for
# VCN-bound traffic — both tunnels active.
#
# Interplay with BGP (bgp.tf): BGP provides reachability to the VCN over both
# tunnels; the SD-WAN service rule + SLA decide which member each session takes.
# Validate the SLA thresholds / route-priority against your FortiOS build.
# ============================================================================

locals {
  # fgt × OCI tunnel -> SD-WAN member (seq_num is 1-based per unit).
  sdwan_members = flatten([
    for fk, v in local.vpn_fgts : [
      for i, t in v.tunnels : {
        fgt     = fk
        seq     = i + 1
        tunnel  = t.name
        gateway = t.bgp_oracle_ip
        probe   = coalesce(try(t.health_check_ip, null), t.bgp_oracle_ip)
      }
    ]
  ])
}

# OCI VCN as a firewall address (SD-WAN service destination).
resource "fortios_firewall_address" "oci_vcn" {
  for_each = local.vpn_fgt_keys
  provider = fortios.by_fortigate[each.key]

  name    = "oci-vcn"
  type    = "ipmask"
  subnet  = "${cidrhost(local.vpn_fgts[each.key].remote_subnet, 0)} ${cidrnetmask(local.vpn_fgts[each.key].remote_subnet)}"
  comment = local.marker
}

resource "fortios_system_sdwan" "this" {
  for_each = local.vpn_fgt_keys
  provider = fortios.by_fortigate[each.key]

  status = "enable"

  zone {
    name = "oci"
  }

  dynamic "members" {
    for_each = { for m in local.sdwan_members : tostring(m.seq) => m if m.fgt == each.key }
    content {
      seq_num   = members.value.seq
      interface = fortios_vpnipsec_phase1interface.oci["${each.key}/${members.value.tunnel}"].name
      zone      = "oci"
      gateway   = members.value.gateway
    }
  }

  health_check {
    name   = "oci-hc"
    server = [for m in local.sdwan_members : m.probe if m.fgt == each.key][0]

    dynamic "members" {
      for_each = { for m in local.sdwan_members : tostring(m.seq) => m if m.fgt == each.key }
      content {
        seq_num = members.value.seq
      }
    }

    sla {
      id                   = 1
      latency_threshold    = 200
      packetloss_threshold = 5
    }
  }

  service {
    id   = 1
    name = "to-oci"
    mode = "load-balance"
    dst {
      name = fortios_firewall_address.oci_vcn[each.key].name
    }
    src {
      name = "all"
    }

    dynamic "priority_members" {
      for_each = { for m in local.sdwan_members : tostring(m.seq) => m if m.fgt == each.key }
      content {
        seq_num = priority_members.value.seq
      }
    }
  }
}
