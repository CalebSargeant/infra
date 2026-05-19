# Import blocks for every resource that currently exists in the dashboard,
# so the first `terragrunt apply` is a no-op (state reconciliation only).
# After the first apply finishes cleanly, these can be deleted.
#
# ID format reference (note the literal "account/" prefix for policies):
#   cloudflare_zero_trust_access_identity_provider: <account_id>/<id>
#   cloudflare_zero_trust_access_application:       <account_id>/<id>
#   cloudflare_zero_trust_access_policy:            account/<account_id>/<app_id>/<id>
#   cloudflare_zero_trust_tunnel_cloudflared:       <account_id>/<id>
#   cloudflare_zero_trust_tunnel_cloudflared_config: <account_id>/<tunnel_id>
#   cloudflare_zero_trust_gateway_policy:           <account_id>/<id>
#   cloudflare_zero_trust_device_posture_rule:      <account_id>/<id>

# Identity providers
import {
  to = cloudflare_zero_trust_access_identity_provider.one_time_pin
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/5f71853a-df4e-48d3-bc3b-5dfe8cc65a0a"
}

import {
  to = cloudflare_zero_trust_access_identity_provider.google
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/783e8bcf-c0d7-41e7-8566-d435d05bad5b"
}

import {
  to = cloudflare_zero_trust_access_identity_provider.google_workspace
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/c8438c8f-c884-489a-8616-05f851f7908a"
}

# Tunnels
import {
  to = cloudflare_zero_trust_tunnel_cloudflared.firefly
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/7694eb38-c35e-4905-bd2b-16ab7053080a"
}

import {
  to = cloudflare_zero_trust_tunnel_cloudflared_config.firefly
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/7694eb38-c35e-4905-bd2b-16ab7053080a"
}

# Access applications
import {
  to = cloudflare_zero_trust_access_application.radarr
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/e8c39959-64ac-4004-9d62-3d730aa2e601"
}

import {
  to = cloudflare_zero_trust_access_application.aws_magmamoose
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/f1c8b775-b7cc-44e7-a7a5-8ee4e4dbf419"
}

import {
  to = cloudflare_zero_trust_access_application.aws_platform_1
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/e16ecad8-7bad-45cf-aabd-b68b52a684a1"
}

import {
  to = cloudflare_zero_trust_access_application.overseerr
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/68dd94ac-564d-40a7-9804-2fb8e12b69dc"
}

import {
  to = cloudflare_zero_trust_access_application.warp_login
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/e613a2bf-7391-434c-8b57-ce0a17681ccf"
}

import {
  to = cloudflare_zero_trust_access_application.app_launcher
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/47ace2ca-6dbf-4ee3-8e6f-d2756b928b49"
}

# Access policy imports for the *original* (reusable, dashboard-created)
# policies were removed: the v4 provider couldn't update them, so they
# were deleted via API and recreated app-scoped with group-based
# includes + posture require. The new policies are already in state.
#
# State-recovery caveat: if you ever blow away the terraform state for
# this module (lost GCS object, accidental `terragrunt state rm`, etc.)
# the recreated policies still exist in Cloudflare but terraform won't
# know about them and the next apply will try to create duplicates.
# Recovery procedure is:
#   1. List the live policies via CF API:
#        curl -s -H "Authorization: Bearer $CF_TOKEN" \
#          "https://api.cloudflare.com/client/v4/accounts/<acct>/access/apps/<app_id>/policies"
#   2. For each terraform resource, run
#        terragrunt import 'cloudflare_zero_trust_access_policy.<name>' \
#          'account/<acct>/<app_id>/<policy_id>'
#      (the literal "account/" prefix is required — see ID format
#      reference at the top of this file).
# Add per-policy `import { }` blocks here when that recovery is ever
# actually needed; leaving them out for the steady state keeps the file
# small.

# Gateway policies
import {
  to = cloudflare_zero_trust_gateway_policy.block_adware
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/1d4dfdb4-5a37-47c6-ab39-e00e6764e549"
}

# (Removed: import blocks for allow_server_l4 / block_server_l4 — those
# resources were deleted in the same PR that resolved cloudflare-ztna-
# improvements.md #8. See git blame on gateway.tf for the rationale.)

# Device posture rules
import {
  to = cloudflare_zero_trust_device_posture_rule.mac_disk_encryption
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/84879737-be7a-4b87-9252-56beb9de60bf"
}

import {
  to = cloudflare_zero_trust_device_posture_rule.mac_firewall
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/460a00b2-cafa-4161-b899-e766717990fc"
}

import {
  to = cloudflare_zero_trust_device_posture_rule.mac_os_version
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/2b86e1cd-a85e-4ffc-ad6b-04ebe22944dd"
}
