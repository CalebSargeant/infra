# Self-contained terragrunt config for the two home-lab FortiGate 40Fs.
# Deliberately does NOT include terraform/root.hcl: root.hcl generates a
# google + oci provider.tf that's irrelevant here and would force a fake
# cloud "region"/"environment" dir layout onto physical edge kit. We keep
# state in the same bucket as everything else and let the module own the
# fortios provider (see modules/fortigate/fortios_provider.tf).
remote_state {
  backend = "gcs"
  config = {
    bucket   = "sargeant-prod-terraform-state"
    prefix   = "fortigate/prod"
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
  source = "${get_repo_root()}/terraform/fortigate/modules/fortigate"
}

# ---------------------------------------------------------------------------
# Credentials
#
# The hardware isn't wired/provisioned yet, so there are no API tokens to fetch.
# For now the management hosts + tokens come from env vars (empty by default) so
# `terragrunt validate`/parse succeeds — a `plan`/`apply` will only fail later
# at provider-connect time, once you point it at real, reachable units.
#
# WHEN THE UNITS ARE LIVE — switch to the repo-standard OCI Vault pattern
# (same as oci/mikrotik): create one REST-API admin token per FortiGate
# (`config system api-user`), store each in vault-prod, and replace the
# get_env() defaults below with run_cmd() lookups, e.g.:
#
#   locals {
#     fgt1_token_secret_ocid = "ocid1.vaultsecret.oc1.eu-amsterdam-1.<...>"
#     fgt1_token = run_cmd("--terragrunt-quiet", "bash", "-c",
#       "oci secrets secret-bundle get --secret-id ${local.fgt1_token_secret_ocid} --region eu-amsterdam-1 --query 'data.\"secret-bundle-content\".content' --raw-output | base64 -d")
#   }
#
# NOTE: API tokens are plaintext-equivalent secrets — never inline a real one
# in this PUBLIC repo. OCI Vault first; rotate immediately if leaked.
# ---------------------------------------------------------------------------
locals {
  fgt1_token = get_env("FORTIGATE_FGT1_TOKEN", "")
  fgt2_token = get_env("FORTIGATE_FGT2_TOKEN", "")
}

inputs = {
  fortigate_insecure = true # 40Fs ship a self-signed mgmt cert

  fortigate_tokens = {
    fgt1 = local.fgt1_token
    fgt2 = local.fgt2_token
  }

  # --- Topology (PLACEHOLDER addressing — edit to your real scheme) ----------
  # Interconnect /30s + cross-link /30s share 10.255.255.0/24:
  #   FGT1<->FGT2 : 10.255.255.0/30  (FGT1 .1, FGT2 .2)
  #   FGT2<->MT1  : 10.255.255.4/30  (FGT2 .5)   [cross-link]
  #   FGT1<->MT2  : 10.255.255.8/30  (FGT1 .9)   [cross-link]
  # LANs: FGT1 10.10.10.0/24, FGT2 10.20.20.0/24
  fortigates = {
    fgt1 = {
      hostname = get_env("FORTIGATE_FGT1_HOST", "192.168.1.99") # 40F default mgmt IP
      lan = {
        ip         = "10.10.10.1"
        dhcp_start = "10.10.10.100"
        dhcp_end   = "10.10.10.200"
      }
      interconnect = {
        ip      = "10.255.255.1"
        peer_ip = "10.255.255.2"
      }
      crosslink       = { ip = "10.255.255.9" } # to MikroTik2
      peer_lan_subnet = "10.20.20.0/24"
    }

    fgt2 = {
      hostname = get_env("FORTIGATE_FGT2_HOST", "192.168.1.98")
      lan = {
        ip         = "10.20.20.1"
        dhcp_start = "10.20.20.100"
        dhcp_end   = "10.20.20.200"
      }
      interconnect = {
        ip      = "10.255.255.2"
        peer_ip = "10.255.255.1"
      }
      crosslink       = { ip = "10.255.255.5" } # to MikroTik1
      peer_lan_subnet = "10.10.10.0/24"
    }
  }
}
