# Self-contained terragrunt config for the prod Cloudflare DNS records.
# Doesn't include ../../terragrunt.hcl because that parent hardcodes the state
# prefix to "terraform/gcp_project" and uses a different bucket — colocating
# everything under sargeant-prod-terraform-state keeps state in one place.

remote_state {
  backend = "gcs"
  config = {
    bucket   = "sargeant-prod-terraform-state"
    prefix   = "cloudflare/prod"
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

terraform {
  source = "${get_repo_root()}/terraform/modules/cloudflare-dns"
}

# Cloudflare API token lives in OCI Vault (vault-prod / cloudflare-api-token).
# Fetched at parse time via the oci CLI, which uses ~/.oci/config — no
# additional env vars needed beyond what terragrunt already wants for OCI.
locals {
  cf_token_secret_ocid = "ocid1.vaultsecret.oc1.eu-amsterdam-1.amaaaaaa4ebs56aawodbynrquyvlohrzze2uipxvxawsaqqe3sykv5owulfa"

  cloudflare_api_token = run_cmd(
    "--terragrunt-quiet",
    "bash", "-c",
    "oci secrets secret-bundle get --secret-id ${local.cf_token_secret_ocid} --region eu-amsterdam-1 --query 'data.\"secret-bundle-content\".content' --raw-output | base64 -d"
  )
}

inputs = {
  cloudflare_api_token = local.cloudflare_api_token
  # sargeant.co zone (the previous value here was actually the *account* ID).
  zone_id              = "e25f6d9e2d13d9c04988e459587101b5"

  records = [
    # Individual records for each OCI MikroTik so you can target one
    {
      name  = "oci1.sargeant.co"
      type  = "A"
      value = "134.98.139.9"
    },
    {
      name  = "oci2.sargeant.co"
      type  = "A"
      value = "193.123.39.172"
    },

    # Two A records under the same name produce DNS round-robin between r1+r2
    {
      name  = "oci.sargeant.co"
      type  = "A"
      value = "134.98.139.9"
    },
    {
      name  = "oci.sargeant.co"
      type  = "A"
      value = "193.123.39.172"
    },
  ]
}
