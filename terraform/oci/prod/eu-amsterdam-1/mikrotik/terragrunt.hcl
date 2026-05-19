include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform/oci/_modules/mikrotik"
}

# No `generate "provider"` override: terragrunt v0.63.6 errors on duplicate
# generate block names rather than letting children override parents. We rely
# on root.hcl's generated provider.tf (google + oci) and just don't use the
# oci provider in this module — declaring it in required_providers is enough
# to satisfy OpenTofu; the unused provider block stays inert.

# routeros provider declaration. Lives in an `_override.tf` file so OpenTofu
# merges it into the parent-generated provider.tf's required_providers map
# (one-required_providers-per-module rule). Sidesteps the same-name-generate
# conflict with the root.hcl `generate "provider"` block.
generate "routeros_required" {
  path      = "routeros_override.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    terraform {
      required_providers {
        routeros = {
          source  = "terraform-routeros/routeros"
          version = "1.99.1"
        }
      }
    }
  EOF
}

# Secrets live in OCI Vault (vault-prod) and are fetched at parse time via
# the `oci` CLI, which uses ~/.oci/config — no extra env vars needed.
#
# Previously sourced from 1Password (`op read`), but everything else in this
# repo's secret access pattern is OCI-Vault-first, and the op flow added a
# desktop-integration dependency to every terragrunt run on the mikrotik
# module. The `mikrotik-credentials` secret stores admin creds as JSON
# `{baseurl,username,password}`; we extract the password with jq.
locals {
  routeros_password_secret_ocid     = "ocid1.vaultsecret.oc1.eu-amsterdam-1.amaaaaaa4ebs56aaaizjuctq6do5iou2xo5yibpuiirdwwdjurwllubxlima" # vault-prod / mikrotik-credentials (JSON)
  cloudflared_tunnel_token_secret_ocid = "ocid1.vaultsecret.oc1.eu-amsterdam-1.amaaaaaa4ebs56aa2awevyczjklffua7eugrlxbsz4xziug5x5jgpewsbwfa" # vault-prod / cloudflared-tunnel-token-firefly

  routeros_password = run_cmd(
    "--terragrunt-quiet",
    "bash", "-c",
    "oci secrets secret-bundle get --secret-id ${local.routeros_password_secret_ocid} --region eu-amsterdam-1 --query 'data.\"secret-bundle-content\".content' --raw-output | base64 -d | jq -r .password"
  )

  cloudflared_tunnel_token = run_cmd(
    "--terragrunt-quiet",
    "bash", "-c",
    "oci secrets secret-bundle get --secret-id ${local.cloudflared_tunnel_token_secret_ocid} --region eu-amsterdam-1 --query 'data.\"secret-bundle-content\".content' --raw-output | base64 -d"
  )
}

inputs = {
  # Using the binary API on port 8728 because:
  #   - www-ssl (HTTPS REST) currently won't complete TLS handshakes despite
  #     a signed local-cert bound to the service (root cause unresolved)
  #   - www (plain HTTP REST) returns 403 — RouterOS policy locks REST to
  #     HTTPS regardless of user permissions
  # The binary API uses a challenge-response auth so the password isn't on
  # the wire in cleartext, even though the session itself is unencrypted.
  # TODO: migrate to apis://...:8729 (TLS-wrapped binary API) once cert is
  # working, or back to https:// REST.
  routers = {
    r1 = { hosturl = "api://134.98.139.9:8728" }
    r2 = { hosturl = "api://193.123.39.172:8728" }
  }

  routeros_username        = "admin"
  routeros_password        = local.routeros_password
  cloudflared_tunnel_token = local.cloudflared_tunnel_token

  # Masquerade outbound traffic from app + data subnets so they can use this
  # MikroTik as their internet gateway (paired with the 0.0.0.0/0 route in the
  # network module). edge subnet is excluded — it has its own IGW route.
  vcn_masquerade_sources = [
    "192.168.223.64/26",  # app subnet
    "192.168.223.128/26", # data subnet
  ]
}
