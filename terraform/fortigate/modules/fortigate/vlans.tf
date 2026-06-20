# ============================================================================
# VLAN segmentation. Each FortiGate routes between its VLANs and applies policy;
# the MikroTik switch behind it carries the VLANs tagged on the trunk
# (ports.lan_mikrotik) and presents them untagged on client access ports.
#
# Segmentation model:
#   - every VLAN gets internet egress (SNAT out its own WAN)
#   - the VLAN flagged `trusted = true` may initiate to every other VLAN
#     (+ the FGT<->FGT interconnect for east-west management)
#   - all other VLANs (iot, guest, ...) are isolated from each other and from
#     trusted by the implicit default-deny — no explicit allow exists
# ============================================================================

locals {
  # fgt × vlan -> flat list, keyed "<fgt>/<vlanname>".
  vlan_entries = flatten([
    for fk, f in var.fortigates : [
      for vname, v in f.vlans : {
        fgt        = fk
        vlan       = vname
        key        = "${fk}/${vname}"
        id         = v.id
        ip         = v.ip
        netmask    = v.netmask
        prefix_len = one([for p in range(0, 33) : p if cidrnetmask("0.0.0.0/${p}") == v.netmask])
        dhcp_start = v.dhcp_start
        dhcp_end   = v.dhcp_end
        trusted    = v.trusted
      }
    ]
  ])

  # The single trusted VLAN name per FortiGate (exactly one expected).
  trusted_vlan_name = {
    for fk, f in var.fortigates : fk => one([for vn, v in f.vlans : vn if v.trusted])
  }

  # trusted -> each NON-trusted VLAN (privileged management reach).
  trusted_to_other = flatten([
    for fk, f in var.fortigates : [
      for vname, v in f.vlans : {
        fgt = fk
        dst = vname
        key = "${fk}/${vname}"
        id  = v.id
      } if !v.trusted
    ]
  ])
}

# --- VLAN subinterfaces (L3 gateway for each segment) ----------------------
resource "fortios_system_interface" "vlan" {
  for_each = { for e in local.vlan_entries : e.key => e }
  provider = fortios.by_fortigate[each.value.fgt]

  name        = each.value.vlan # interface name = VLAN key (trusted/iot/guest/mgmt)
  vdom        = var.fortigates[each.value.fgt].vdom
  type        = "vlan"
  interface   = var.fortigates[each.value.fgt].ports.lan_mikrotik # trunk parent
  vlanid      = each.value.id
  mode        = "static"
  ip          = "${each.value.ip} ${each.value.netmask}"
  role        = "lan"
  allowaccess = var.lan_allowaccess
  description = "${local.marker} — VLAN ${each.value.id} (${each.value.vlan})"
}

# --- Per-VLAN DHCP server --------------------------------------------------
resource "fortios_systemdhcp_server" "vlan" {
  for_each = { for e in local.vlan_entries : e.key => e }
  provider = fortios.by_fortigate[each.value.fgt]

  fosid           = each.value.id
  status          = "enable"
  interface       = fortios_system_interface.vlan[each.key].name
  default_gateway = each.value.ip
  netmask         = each.value.netmask
  dns_service     = "default"
  lease_time      = 86400

  ip_range {
    id       = 1
    start_ip = each.value.dhcp_start
    end_ip   = each.value.dhcp_end
  }
}

# --- Internet egress for every VLAN (SNAT) ---------------------------------
resource "fortios_firewall_policy" "vlan_to_wan" {
  for_each = { for e in local.vlan_entries : e.key => e }
  provider = fortios.by_fortigate[each.value.fgt]

  policyid = 100 + each.value.id
  name     = "${each.value.vlan}-to-wan"
  srcintf { name = fortios_system_interface.vlan[each.key].name }
  dstintf { name = fortios_system_interface.wan[each.value.fgt].name }
  srcaddr { name = "all" }
  dstaddr { name = "all" }
  service { name = "ALL" }
  action     = "accept"
  schedule   = "always"
  nat        = "enable"
  logtraffic = "all"
}

# --- Trusted VLAN -> every other VLAN (privileged) -------------------------
resource "fortios_firewall_policy" "trusted_to_vlan" {
  for_each = { for e in local.trusted_to_other : e.key => e }
  provider = fortios.by_fortigate[each.value.fgt]

  policyid = 200 + each.value.id
  name     = "trusted-to-${each.value.dst}"
  srcintf { name = fortios_system_interface.vlan["${each.value.fgt}/${local.trusted_vlan_name[each.value.fgt]}"].name }
  dstintf { name = fortios_system_interface.vlan[each.key].name }
  srcaddr { name = "all" }
  dstaddr { name = "all" }
  service { name = "ALL" }
  action     = "accept"
  schedule   = "always"
  nat        = "disable"
  logtraffic = "all"
}

# --- Trusted VLAN <-> interconnect (FGT<->FGT east-west management) ---------
resource "fortios_firewall_policy" "trusted_to_interconnect" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  policyid = 20
  name     = "trusted-to-interconnect"
  srcintf { name = fortios_system_interface.vlan["${each.key}/${local.trusted_vlan_name[each.key]}"].name }
  dstintf { name = fortios_system_interface.interconnect[each.key].name }
  srcaddr { name = "all" }
  dstaddr { name = "all" }
  service { name = "ALL" }
  action     = "accept"
  schedule   = "always"
  nat        = "disable"
  logtraffic = "all"
}

resource "fortios_firewall_policy" "interconnect_to_trusted" {
  for_each = local.keys
  provider = fortios.by_fortigate[each.key]

  policyid = 21
  name     = "interconnect-to-trusted"
  srcintf { name = fortios_system_interface.interconnect[each.key].name }
  dstintf { name = fortios_system_interface.vlan["${each.key}/${local.trusted_vlan_name[each.key]}"].name }
  srcaddr { name = "all" }
  dstaddr { name = "all" }
  service { name = "ALL" }
  action     = "accept"
  schedule   = "always"
  nat        = "disable"
  logtraffic = "all"
}
