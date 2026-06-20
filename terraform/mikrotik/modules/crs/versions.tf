# Self-contained leaf (terragrunt.hcl does NOT include root.hcl), so there's no
# Terragrunt-generated provider.tf to collide with — required_providers lives
# here normally (cf. oci/modules/mikrotik, which must use an _override.tf
# because that leaf DOES include root.hcl).
terraform {
  required_version = ">= 1.9.0" # provider for_each (targets both MikroTiks) was added in OpenTofu 1.9

  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.99.1" # matches the version the oci/mikrotik leaf pins
    }
  }
}
