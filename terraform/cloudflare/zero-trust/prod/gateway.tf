# Cloudflare Zero Trust Gateway policies. The two L4 rules for 192.168.69.110
# are flagged with extended descriptions so a future reader understands the
# semantics — see comments + descriptions below.

resource "cloudflare_zero_trust_gateway_policy" "block_adware" {
  account_id  = var.account_id
  name        = "Block adware"
  description = "Managed by Terraform — manual domain list; long-term replace with CF managed categories (see docs/reference/cloudflare-ztna-improvements.md #7)"
  action      = "block"
  enabled     = true
  filters     = ["dns"]
  precedence  = 13000
  traffic     = "any(dns.domains[*] in {\"doubleclick.net\" \"self.events.data.microsoft.com\" \"metrics.icloud.com\" \"dit.whatsapp.net\" \"mask.icloud.com\" \"app-measurement.com\" \"g.live.com\" \"mask-h2.icloud.com\" \"treatment.grammarly.com\" \"firebaselogging-pa.googleapis.com\" \"partner.googleadservices.com\" \"c.amazon-adsystem.com\" \"pagead2.googlesyndication.com\" \"www.googletagmanager.com\" \"www.google-analytics.com\" \"pdat.matterlytics.com\"})"
}

# L4 allow + block pair on 192.168.69.110 — UNREACHABLE BLOCK as currently
# written: precedence 15000 (allow) is evaluated before 16000 (block), so
# the allow always wins and the block is dead code. This is either:
#   a) intentional plumbing for a future condition on the allow (e.g.
#      "allow only if identity == foo"; block as catch-all), or
#   b) a leftover that should be deleted.
# Tracked as docs/reference/cloudflare-ztna-improvements.md #8. Until the
# intent is clarified, keep both so we don't silently change behaviour.
resource "cloudflare_zero_trust_gateway_policy" "allow_server_l4" {
  account_id  = var.account_id
  name        = "Allow rule for Server"
  description = "Managed by Terraform — pair with block_server_l4; intentional override pattern, see gateway.tf comment + improvements memo #8"
  action      = "allow"
  enabled     = true
  filters     = ["l4"]
  precedence  = 15000
  traffic     = "net.dst.ip == 192.168.69.110"
}

resource "cloudflare_zero_trust_gateway_policy" "block_server_l4" {
  account_id  = var.account_id
  name        = "Block rule for Server"
  description = "Managed by Terraform — currently UNREACHABLE (allow_server_l4 at lower precedence matches first); see gateway.tf comment + improvements memo #8"
  action      = "block"
  enabled     = true
  filters     = ["l4"]
  precedence  = 16000
  traffic     = "net.dst.ip == 192.168.69.110"
}
