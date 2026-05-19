# Service tokens are non-human identities for hitting Access-protected
# services from automation. Caller sends:
#   CF-Access-Client-Id: <client_id>
#   CF-Access-Client-Secret: <client_secret>
# CF Access validates these against the service token and bypasses the
# normal IdP flow.
#
# Usage pattern:
#   1. Define the service token here.
#   2. Attach it to one or more Access policies via `include { service_token = [...] }`.
#   3. Pull the secret via:
#        terraform output -raw service_token_<name>_secret
#      and stash in OCI Vault. The secret is only available at create-time;
#      rotating means destroy + recreate.
#
# Currently no service tokens defined — leaving this file as the scaffold
# and pattern reference. Add one when there's a real consumer (e.g.
# uptime monitoring hitting overseerr.sargeant.co).

# Example (commented out — un-comment + adapt when you have a real consumer):
#
# resource "cloudflare_zero_trust_access_service_token" "uptime_kuma" {
#   account_id = var.account_id
#   name       = "uptime-kuma"
#   # Default duration is "8760h" (1y). For tighter rotation set e.g. "720h" (30d).
#   duration   = "8760h"
# }
#
# output "service_token_uptime_kuma_client_id" {
#   value     = cloudflare_zero_trust_access_service_token.uptime_kuma.client_id
#   sensitive = true
# }
#
# output "service_token_uptime_kuma_client_secret" {
#   value     = cloudflare_zero_trust_access_service_token.uptime_kuma.client_secret
#   sensitive = true
# }
#
# Then on the app's policy:
#   resource "cloudflare_zero_trust_access_policy" "overseerr_uptime" {
#     account_id     = var.account_id
#     application_id = cloudflare_zero_trust_access_application.overseerr.id
#     name           = "Uptime probes"
#     decision       = "non_identity"
#     precedence     = 100
#     include {
#       service_token = [cloudflare_zero_trust_access_service_token.uptime_kuma.id]
#     }
#   }
