output "instances" {
  description = "Map of edge instances"
  value = {
    for k, v in oci_core_instance.this : k => {
      instance_id   = v.id
      public_ip     = v.public_ip
      private_ip    = v.private_ip
      instance_state = v.state
    }
  }
}

# Backwards compatibility outputs for single instance
output "instance_id" {
  description = "ID of the first edge instance (backwards compatibility)"
  value       = values(oci_core_instance.this)[0].id
}

output "public_ip" {
  description = "Public IP address of the first edge instance (backwards compatibility)"
  value       = values(oci_core_instance.this)[0].public_ip
}

output "private_ip" {
  description = "Private IP address of the first edge instance (backwards compatibility)"
  value       = values(oci_core_instance.this)[0].private_ip
}

output "instance_state" {
  description = "Current state of the first edge instance (backwards compatibility)"
  value       = values(oci_core_instance.this)[0].state
}
