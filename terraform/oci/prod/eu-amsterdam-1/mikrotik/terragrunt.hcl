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

# Secrets are fetched from 1Password at parse time via the `op` CLI.
# Requires `op` CLI installed and signed in (`op signin`).
locals {
  op_vault = "Firefly"

  routeros_password        = run_cmd("--terragrunt-quiet", "op", "read", "op://${local.op_vault}/Firefly MikroTik Password/password")
  cloudflared_tunnel_token = run_cmd("--terragrunt-quiet", "op", "read", "op://${local.op_vault}/Firefly Cloudflare Tunnel Token/password")
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
}
