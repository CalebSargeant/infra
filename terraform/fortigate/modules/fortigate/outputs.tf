output "lan_gateways" {
  description = "Per-FortiGate LAN gateway IP (DHCP default-gateway handed to clients)."
  value       = { for k, v in var.fortigates : k => v.lan.ip }
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
      lan_mikrotik = fortios_system_interface.lan[k].name
      crosslink    = fortios_system_interface.crosslink[k].name
    }
  }
}
