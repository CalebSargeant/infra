output "bridge_mgmt_ips" {
  description = "Per-switch LAN bridge management IP."
  value       = { for k, m in var.mikrotiks : k => m.lan.bridge_ip }
}

output "bridge_members" {
  description = "Per-switch list of ports bridged into the LAN."
  value = {
    for k, m in var.mikrotiks : k => concat([m.ports.fgt_uplink], m.client_ports)
  }
}

output "routed_uplinks" {
  description = "Per-switch routed P2P interfaces (cross-link to opposite FortiGate, inter-switch link)."
  value = {
    for k, m in var.mikrotiks : k => {
      crosslink = m.crosslink.address
      mt_link   = m.mt_link.address
    }
  }
}
