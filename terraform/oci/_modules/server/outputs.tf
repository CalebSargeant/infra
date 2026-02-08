output "instances" {
  description = "Map of server instances"
  value = {
    for k, v in oci_core_instance.this : k => {
      instance_id    = v.id
      public_ip      = v.public_ip
      private_ip     = v.private_ip
      instance_state = v.state
      fault_domain   = v.fault_domain
    }
  }
}

# Backwards compatibility outputs for single instance
output "instance_id" {
  description = "ID of the first server instance (backwards compatibility)"
  value       = length(oci_core_instance.this) > 0 ? values(oci_core_instance.this)[0].id : null
}

output "public_ip" {
  description = "Public IP address of the first server instance (backwards compatibility)"
  value       = length(oci_core_instance.this) > 0 ? values(oci_core_instance.this)[0].public_ip : null
}

output "private_ip" {
  description = "Private IP address of the first server instance (backwards compatibility)"
  value       = length(oci_core_instance.this) > 0 ? values(oci_core_instance.this)[0].private_ip : null
}

output "instance_state" {
  description = "Current state of the first server instance (backwards compatibility)"
  value       = length(oci_core_instance.this) > 0 ? values(oci_core_instance.this)[0].state : null
}

output "private_ips" {
  description = "List of all server private IPs"
  value       = [for k, v in oci_core_instance.this : v.private_ip]
}
