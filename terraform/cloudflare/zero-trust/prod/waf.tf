# WAF custom rule — bot-block exception for the public LiteLLM endpoint.
#
# Why this exists:
#   litellm-warp.sargeant.co is the public OpenAI-compatible endpoint Warp.dev
#   uses for custom inference (tunnel route in tunnels.tf). Warp does NOT call
#   it from the user's machine — the inference requests originate from Warp's
#   own backend servers. Cloudflare classifies those as an AI bot, and the
#   zone has "Block AI bots" / Super Bot Fight Mode enabled, so every Warp
#   request is rejected at the edge with HTTP 403 and never reaches the tunnel.
#
#   Reproduction (2026-06-10): an AI-bot User-Agent (GPTBot, Bytespider) gets
#   403 at this hostname while a normal client (curl/residential, Warp UA from
#   a residential IP) gets 200 — confirming the block is bot-classification,
#   not the key, model name, tunnel, or LiteLLM itself (all verified healthy).
#
# What this does:
#   A single zone custom rule that SKIPS Super Bot Fight Mode (the
#   http_request_sbfm phase) for this one hostname only. The rest of the zone
#   keeps full bot protection. Scoped as tightly as possible: host match only.
#
# IMPORTANT — prerequisites before this will apply cleanly:
#   1. TOKEN SCOPE. The zero-trust Cloudflare API token (OCI Vault secret
#      `cloudflare-api-token-zero-trust`) currently has DNS:Edit + Zero
#      Trust:Edit only. Managing a WAF ruleset needs "Zone WAF: Edit" on the
#      sargeant.co zone. Add that permission to the token in the Cloudflare
#      dashboard and re-stash the token in OCI Vault, or the apply fails with
#      an authz error.
#   2. ENTRYPOINT OWNERSHIP. A zone has exactly ONE http_request_firewall_custom
#      entrypoint ruleset. This resource takes ownership of it. If custom rules
#      already exist in the dashboard for sargeant.co, the Atlantis plan will
#      show them being removed — DO NOT APPLY in that case; import/codify the
#      existing rules into the `rules` block below first. As of writing, no WAF
#      rules are managed in Terraform anywhere in this repo.
#
# If after apply Warp still 403s, the block may be a Bot Management managed
# rule rather than SBFM — add "http_request_firewall_managed" to the skipped
# phases (broader; reduces managed-WAF coverage for the host, so prefer the
# SBFM-only form first).

resource "cloudflare_ruleset" "sargeant_co_custom_firewall" {
  # sargeant.co zone (same zone_id used by terraform/cloudflare/dns/prod).
  zone_id     = "e25f6d9e2d13d9c04988e459587101b5"
  name        = "default"
  description = "Zone custom firewall rules (sargeant.co)"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules {
    ref         = "litellm_warp_skip_sbfm"
    description = "Allow Warp server-side inference to litellm-warp.sargeant.co (skip Super Bot Fight Mode / AI-bot block)"
    expression  = "(http.host eq \"litellm-warp.sargeant.co\")"
    action      = "skip"

    action_parameters {
      phases = ["http_request_sbfm"]
    }

    logging {
      enabled = true
    }
  }
}
