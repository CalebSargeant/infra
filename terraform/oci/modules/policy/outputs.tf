output "policy_id" {
  description = "ID of the created policy"
  value       = oci_identity_policy.instance_policy.id
}

output "policy_name" {
  description = "Name of the created policy"
  value       = oci_identity_policy.instance_policy.name
}

output "policy_statements" {
  description = "Statements in the created policy"
  value       = oci_identity_policy.instance_policy.statements
}