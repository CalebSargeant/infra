# Import blocks for every resource that currently exists in the dashboard,
# so the first `terragrunt apply` is a no-op (state reconciliation only).
# After the first apply finishes cleanly, these can be deleted.
#
# ID format reference:
#   cloudflare_zero_trust_access_identity_provider: <account_id>/<id>
#   cloudflare_zero_trust_access_application:       <account_id>/<id>
#   cloudflare_zero_trust_access_policy:            <account_id>/<app_id>/<id>
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

# Access policies (note the app_id middle segment)
import {
  to = cloudflare_zero_trust_access_policy.overseerr_friends
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/68dd94ac-564d-40a7-9804-2fb8e12b69dc/d57845aa-a79c-454e-839c-518889733351"
}

import {
  to = cloudflare_zero_trust_access_policy.overseerr_caleb
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/68dd94ac-564d-40a7-9804-2fb8e12b69dc/fb6794a4-431b-4973-a8b2-4cf690a5669d"
}

import {
  to = cloudflare_zero_trust_access_policy.warp_email_domain
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/e613a2bf-7391-434c-8b57-ce0a17681ccf/9d145c1e-efec-4178-8419-1eb38c1f4a5c"
}

import {
  to = cloudflare_zero_trust_access_policy.warp_allow_emails
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/e613a2bf-7391-434c-8b57-ce0a17681ccf/4f2ee5b7-787d-481b-8d33-8e411bfd530f"
}

import {
  to = cloudflare_zero_trust_access_policy.app_launcher_magma
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/47ace2ca-6dbf-4ee3-8e6f-d2756b928b49/17d82583-c5be-49dd-ac01-1c3be3534978"
}

# Gateway policies
import {
  to = cloudflare_zero_trust_gateway_policy.block_adware
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/1d4dfdb4-5a37-47c6-ab39-e00e6764e549"
}

import {
  to = cloudflare_zero_trust_gateway_policy.allow_server_l4
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/29a5daaf-2151-4501-acfc-23dd821c9625"
}

import {
  to = cloudflare_zero_trust_gateway_policy.block_server_l4
  id = "6e26afa31c37dee1dc82ad2f214f9b3c/7cf7a3a5-0d68-4fa0-b311-74140a04a201"
}

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
