terraform {
  source = "${get_repo_root()}/terraform/oci/modules/iam-policy"
}

# The peer tenancy OCID is recon-grade (enumerates cross-tenant trust) and
# lives in OCI Vault as `infra-recon-blockers` (vault-prod). Fetched at parse
# time using the operator's ~/.oci/config and decoded as JSON; only the
# franklinhouse_tenancy_ocid sub-key is consumed here.
locals {
  recon_blockers_secret_ocid = "ocid1.vaultsecret.oc1.eu-amsterdam-1.amaaaaaa4ebs56aa7mytuezgibzn4g36jxupsgy57zl4372uq47atgfra2ka"

  # Direct `oci` call + base64decode in HCL (no `bash -c`) so this parses on
  # Windows/PowerShell, which has no bash. Pattern: cloudflare/zero-trust/prod.
  recon_blockers = jsondecode(base64decode(trimspace(run_cmd(
    "--terragrunt-quiet",
    "oci", "secrets", "secret-bundle", "get",
    "--secret-id", local.recon_blockers_secret_ocid,
    "--region", "eu-amsterdam-1",
    "--query", "data.\"secret-bundle-content\".content",
    "--raw-output"
  ))))

  franklinhouse_tenancy_ocid = local.recon_blockers.iam_peers.franklinhouse_tenancy_ocid
}

inputs = {
  tenancy_ocid     = get_env("OCI_TENANCY_OCID", "")
  compartment_ocid = get_env("OCI_TENANCY_OCID", "")  # Root-level policy
  region           = "eu-amsterdam-1"
  environment      = "prod"

  policy_name = "drg-cross-tenancy-peering-franklinhouse"
  description = "Allow FranklinHouse tenancy to peer DRGs with Sargeant"

  statements = [
    "Define tenancy franklinhouse as ${local.franklinhouse_tenancy_ocid}",
    "Endorse group Administrators to manage remote-peering-to in tenancy franklinhouse"
  ]
}

remote_state {
  backend = "gcs"
  config = {
    bucket   = "sargeant-prod-terraform-state"
    prefix   = "oci/iam-policy"
    project  = "magmamoose-terraform"
    location = "europe-west4"
  }
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "gcs" {}
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "google" {
  project         = "magmamoose-terraform"
  region          = "europe-west4"
  impersonate_service_account = "deployer@magmamoose-terraform.iam.gserviceaccount.com"
}

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = "${get_env("OCI_TENANCY_OCID", "")}"
  user_ocid        = "${get_env("OCI_USER_OCID", "")}"
  private_key_path = "${get_env("OCI_PRIVATE_KEY_PATH", "")}"
  fingerprint      = "${get_env("OCI_FINGERPRINT", "")}"
  region           = "eu-amsterdam-1"
}
EOF
}
