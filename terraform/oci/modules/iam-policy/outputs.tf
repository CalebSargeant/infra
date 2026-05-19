output "policy_id" {
  description = "OCID of the created policy"
  value       = oci_identity_policy.this.id
}

output "policy_name" {
  description = "Name of the policy"
  value       = oci_identity_policy.this.name
}

output "policy_state" {
  description = "Current state of the policy"
  value       = oci_identity_policy.this.state
}
