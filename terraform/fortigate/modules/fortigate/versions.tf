# This leaf is self-contained (its terragrunt.hcl does NOT include root.hcl),
# so — unlike the oci/mikrotik module — there is no Terragrunt-generated
# provider.tf to collide with. That means required_providers can live here in
# the module normally (one required_providers block per module) instead of
# being split into an `_override.tf` file.
terraform {
  required_version = ">= 1.9.0" # provider for_each (targets both FortiGates) was added in OpenTofu 1.9

  required_providers {
    fortios = {
      source  = "fortinetdev/fortios"
      version = "1.24.1" # latest as of 2026-01-27; covers FortiOS 6.0–7.6
    }
  }
}
