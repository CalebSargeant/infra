# These LiteLLM Access resources were removed from configuration when
# litellm.sargeant.co became LAN/VPN-only, but they remained in Terraform state.
# Forget them without destroying the live Cloudflare objects so unrelated Zero
# Trust applies do not delete a stale Access app/policy.
removed {
  from = cloudflare_zero_trust_access_application.litellm

  lifecycle {
    destroy = false
  }
}

removed {
  from = cloudflare_zero_trust_access_policy.litellm_caleb

  lifecycle {
    destroy = false
  }
}
