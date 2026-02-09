output "rpc_id" {
  description = "OCID of the Remote Peering Connection"
  value       = oci_core_remote_peering_connection.this.id
}

output "rpc_display_name" {
  description = "Display name of the Remote Peering Connection"
  value       = oci_core_remote_peering_connection.this.display_name
}

output "rpc_state" {
  description = "Current state of the Remote Peering Connection"
  value       = oci_core_remote_peering_connection.this.state
}

output "peering_status" {
  description = "Peering status of the Remote Peering Connection"
  value       = oci_core_remote_peering_connection.this.peering_status
}
