output "vlan_gateways" {
  description = "Per-FortiGate, per-VLAN gateway IP (DHCP default-gateway handed to clients)."
  value       = { for k, v in var.fortigates : k => { for vn, vl in v.vlans : vn => vl.ip } }
}

output "interconnect_ips" {
  description = "Per-FortiGate interconnect /30 address."
  value       = { for k, v in var.fortigates : k => v.interconnect.ip }
}

output "managed_interfaces" {
  description = "Interface role -> name actually configured on each FortiGate."
  value = {
    for k in keys(var.fortigates) : k => {
      wan          = fortios_system_interface.wan[k].name
      interconnect = fortios_system_interface.interconnect[k].name
      lan_trunk    = fortios_system_interface.lan_trunk[k].name
      crosslink    = fortios_system_interface.crosslink[k].name
    }
  }
}
