terraform {
  source = "${get_repo_root()}/terraform/oci/_modules/iam-policy"
}

inputs = {
  tenancy_ocid     = get_env("OCI_TENANCY_OCID", "")
  compartment_ocid = get_env("OCI_TENANCY_OCID", "")  # Root-level policy
  region           = "eu-amsterdam-1"
  environment      = "prod"

  policy_name = "drg-cross-tenancy-peering-franklinhouse"
  description = "Allow FranklinHouse tenancy to peer DRGs with Sargeant"

  statements = [
    "Define tenancy franklinhouse as ocid1.tenancy.oc1..aaaaaaaaa4edy346b3as4gv6wpf5aaworbp6ls3u36lr3sulhkkjkrzz6tfa",
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
