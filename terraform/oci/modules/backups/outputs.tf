output "namespace" {
  description = "Object Storage namespace."
  value       = data.oci_objectstorage_namespace.this.namespace
}

output "bucket_names" {
  description = "Created backup bucket names."
  value       = [for b in oci_objectstorage_bucket.this : b.name]
}

output "s3_endpoint" {
  description = "S3-compatible endpoint for the backup buckets."
  value       = local.s3_endpoint
}

output "backup_user_ocid" {
  description = "OCID of the backup-writer service user."
  value       = oci_identity_user.backup_writer.id
}

output "vault_secret_ocid" {
  description = "OCID of the Vault secret holding the S3 credentials (consume via ExternalSecret)."
  value       = oci_vault_secret.backup_s3.id
}
