# OCI IAM Policy Module
# Creates IAM policies for cross-tenancy DRG peering

resource "oci_identity_policy" "this" {
  compartment_id = var.compartment_ocid
  name           = var.policy_name
  description    = var.description
  statements     = var.statements

  freeform_tags = {
    "Environment" = var.environment
    "Managed-By"  = "terraform"
  }
}
