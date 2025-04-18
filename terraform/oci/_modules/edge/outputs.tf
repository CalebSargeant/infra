output "instance_id" {
  description = "ID of the edge instance"
  value       = oci_core_instance.this.id
}

output "public_ip" {
  description = "Public IP address of the edge instance"
  value       = oci_core_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP address of the edge instance"
  value       = oci_core_instance.this.private_ip
}

output "instance_state" {
  description = "Current state of the edge instance"
  value       = oci_core_instance.this.state
}