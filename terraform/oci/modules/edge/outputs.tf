# When `use_reserved_public_ips = true`, the instance's primary VNIC no
# longer carries an ephemeral IP — `oci_core_instance.this[k].public_ip` is
# empty, and the actual public IP comes from `oci_core_public_ip.reserved[k]`.
# Resolve here so callers don't have to care which mode is in effect.
locals {
  resolved_public_ips = {
    for k, v in oci_core_instance.this : k => (
      var.use_reserved_public_ips
      ? oci_core_public_ip.reserved[k].ip_address
      : v.public_ip
    )
  }
}

output "instances" {
  description = "Map of edge instances"
  value = {
    for k, v in oci_core_instance.this : k => {
      instance_id    = v.id
      public_ip      = local.resolved_public_ips[k]
      private_ip     = v.private_ip
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
  value       = local.resolved_public_ips[keys(oci_core_instance.this)[0]]
}

output "private_ip" {
  description = "Private IP address of the first edge instance (backwards compatibility)"
  value       = values(oci_core_instance.this)[0].private_ip
}

output "instance_state" {
  description = "Current state of the first edge instance (backwards compatibility)"
  value       = values(oci_core_instance.this)[0].state
}
