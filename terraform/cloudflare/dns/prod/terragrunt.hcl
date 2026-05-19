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

# Cloudflare API token lives in OCI Vault (vault-prod / cloudflare-api-token).
# Fetched at parse time via the oci CLI, then exported as CLOUDFLARE_API_TOKEN
# so the cloudflare provider picks it up via its built-in env-var fallback —
# avoids writing the secret into a generated .tf file in the cache.
locals {
  cf_token_secret_ocid = "ocid1.vaultsecret.oc1.eu-amsterdam-1.amaaaaaa4ebs56aawodbynrquyvlohrzze2uipxvxawsaqqe3sykv5owulfa"

  cloudflare_api_token = run_cmd(
    "--terragrunt-quiet",
    "bash", "-c",
    "oci secrets secret-bundle get --secret-id ${local.cf_token_secret_ocid} --region eu-amsterdam-1 --query 'data.\"secret-bundle-content\".content' --raw-output | base64 -d"
  )
}

terraform {
  source = "${get_repo_root()}/terraform/cloudflare/modules/cloudflare-dns"

  extra_arguments "cloudflare_token" {
    commands = ["plan", "apply", "destroy", "import", "refresh", "validate"]
    env_vars = {
      CLOUDFLARE_API_TOKEN = local.cloudflare_api_token
    }
  }
}

# Provider config belongs in the caller, not the cloudflare-dns module
# (terraform module-development guidance). Generated into the working dir at
# parse time; api_token is read from CLOUDFLARE_API_TOKEN env (above).
generate "cloudflare_provider" {
  path      = "cloudflare_provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "cloudflare" {}
  EOF
}

inputs = {
  # sargeant.co zone (the previous value here was actually the *account* ID).
  zone_id = "e25f6d9e2d13d9c04988e459587101b5"

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

    # Routes through the `firefly` cloudflared tunnel to the in-cluster
    # radarr service (k8s service: radarr.media.svc.cluster.local:7878,
    # see kubernetes/_base/media/radarr/service.yaml). Pairs with the
    # tunnel ingress rule in terraform/cloudflare/zero-trust/prod/tunnels.tf
    # and the cloudflare_zero_trust_access_application.radarr
    # self_hosted entry (no longer a bookmark). Must be proxied so CF
    # recognises the cfargotunnel.com target and routes via the tunnel.
    {
      name    = "radarr.sargeant.co"
      type    = "CNAME"
      value   = "7694eb38-c35e-4905-bd2b-16ab7053080a.cfargotunnel.com"
      proxied = true
    },
  ]

  # These four records already exist in the dashboard (someone re-created
  # them outside terraform after the initial zone_id bug). Importing instead
  # of re-creating. Safe to delete this block after the first clean apply
  # lands in state.
  imports = [
    { key = "oci1.sargeant.co#A#134.98.139.9", record_id = "06e99fd7050e4fdda75047ae12e45bdf" },
    { key = "oci2.sargeant.co#A#193.123.39.172", record_id = "df6b1879c47625d404c68a4d31948898" },
    { key = "oci.sargeant.co#A#134.98.139.9", record_id = "f0cfcdff5ce214beae99477f3c87d839" },
    { key = "oci.sargeant.co#A#193.123.39.172", record_id = "b76a4a6f0be53e5908552f2072a87b5b" },
  ]
}
