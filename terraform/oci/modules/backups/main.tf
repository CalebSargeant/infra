terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

# Object Storage namespace (tenancy-global, e.g. axn3gwpaabzc)
data "oci_objectstorage_namespace" "this" {
  compartment_id = var.tenancy_ocid
}

locals {
  s3_endpoint = "https://${data.oci_objectstorage_namespace.this.namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
  # OCI policy "where any { ... }" clause scoping access to just the backup buckets
  bucket_match = join(", ", [for b in var.bucket_names : "target.bucket.name='${b}'"])
}

# --- Backup buckets (versioned, private) ---
resource "oci_objectstorage_bucket" "this" {
  for_each = toset(var.bucket_names)

  namespace      = data.oci_objectstorage_namespace.this.namespace
  compartment_id = var.compartment_ocid
  name           = each.value
  access_type    = "NoPublicAccess"
  versioning     = "Enabled"
  storage_tier   = "Standard"

  freeform_tags = {
    purpose     = "backups"
    environment = var.environment
    managed-by  = "terraform"
  }
}

# --- Least-privilege service identity (S3-compat) ---
resource "oci_identity_group" "backup_writers" {
  compartment_id = var.tenancy_ocid # IAM groups are tenancy-level
  name           = "backup-writers"
  description    = "Write access to the backup Object Storage buckets"
}

resource "oci_identity_user" "backup_writer" {
  compartment_id = var.tenancy_ocid # IAM users are tenancy-level
  name           = "backup-writer"
  description    = "Service user for CNPG/Plex backups to OCI Object Storage (S3 compat)"
}

resource "oci_identity_user_group_membership" "backup_writer" {
  group_id = oci_identity_group.backup_writers.id
  user_id  = oci_identity_user.backup_writer.id
}

# Scoped to ONLY the backup buckets, in the backup compartment.
resource "oci_identity_policy" "backup_writers" {
  compartment_id = var.compartment_ocid
  name           = "backup-writers-objectstorage"
  description    = "Allow backup-writers to manage objects in the backup buckets only"
  statements = [
    "Allow group ${oci_identity_group.backup_writers.name} to read buckets in compartment id ${var.compartment_ocid} where any {${local.bucket_match}}",
    "Allow group ${oci_identity_group.backup_writers.name} to manage objects in compartment id ${var.compartment_ocid} where any {${local.bucket_match}}",
  ]
}

# S3-compatible credentials: .id = Access Key ID, .key = Secret (creation-only)
resource "oci_identity_customer_secret_key" "backup_writer" {
  display_name = "backup-writer-s3"
  user_id      = oci_identity_user.backup_writer.id
}

# Store the creds (as JSON) in OCI Vault; consumed in-cluster via ExternalSecret.
resource "oci_vault_secret" "backup_s3" {
  compartment_id = var.tenancy_ocid # same compartment as vault-prod
  vault_id       = var.vault_id
  key_id         = var.key_id
  secret_name    = var.secret_name
  description    = "S3-compat credentials for backup-writer (CNPG + Plex backups)"

  secret_content {
    content_type = "BASE64"
    content = base64encode(jsonencode({
      access_key = oci_identity_customer_secret_key.backup_writer.id
      secret_key = oci_identity_customer_secret_key.backup_writer.key
      endpoint   = local.s3_endpoint
      region     = var.region
      namespace  = data.oci_objectstorage_namespace.this.namespace
    }))
  }

  # customer_secret_key.key is only returned at creation; it persists in state
  # but isn't re-readable. Pin the content so plans don't churn on refresh.
  # Rotating the key = taint oci_identity_customer_secret_key + this secret.
  lifecycle {
    ignore_changes = [secret_content]
  }
}
