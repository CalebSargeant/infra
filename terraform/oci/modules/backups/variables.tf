variable "tenancy_ocid" {
  description = "Tenancy OCID (IAM users/groups are tenancy-level)."
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment for the buckets and the bucket-scoped policy."
  type        = string
}

variable "region" {
  description = "OCI region (e.g. eu-amsterdam-1)."
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. prod)."
  type        = string
  default     = "prod"
}

variable "bucket_names" {
  description = "Object Storage buckets to create for backups."
  type        = list(string)
  default     = ["postgres-backups", "plex-backups"]
}

variable "vault_id" {
  description = "OCID of the OCI Vault that stores the generated S3 credentials."
  type        = string
}

variable "key_id" {
  description = "OCID of the KMS key used to encrypt the stored secret."
  type        = string
}

variable "secret_name" {
  description = "Name of the Vault secret holding the S3-compat credentials (JSON)."
  type        = string
  default     = "backup-oci-s3-credentials"
}
