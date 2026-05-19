# Cloudflare Zero Trust Gateway policies. The two L4 rules for 192.168.69.110
# are flagged with extended descriptions so a future reader understands the
# semantics — see comments + descriptions below.

# Curated ad / tracker / telemetry blocklist for the free Zero Trust tier
# (CF's "Ads" managed category is paid-tier only — see improvements memo
# #7). Organised in `local.adware_domains` for ease of editing; rule body
# is templated from the list.
locals {
  adware_domains = [
    # Google ads & analytics
    "doubleclick.net",
    "www.google-analytics.com",
    "www.googletagmanager.com",
    "pagead2.googlesyndication.com",
    "partner.googleadservices.com",
    "stats.g.doubleclick.net",
    "ad.doubleclick.net",
    "firebaselogging-pa.googleapis.com",
    "googleadservices.com",
    "google-analytics.com",
    "ssl.google-analytics.com",
    "adservice.google.com",
    "app-measurement.com",
    # Facebook / Meta trackers
    "connect.facebook.net",
    "pixel.facebook.com",
    "graph.facebook.com",
    "an.facebook.com",
    # Amazon advertising
    "c.amazon-adsystem.com",
    "aax-eu.amazon-adsystem.com",
    "fls-eu.amazon.com",
    "fls-na.amazon.com",
    # Microsoft telemetry
    "self.events.data.microsoft.com",
    "v10.events.data.microsoft.com",
    "settings-win.data.microsoft.com",
    "watson.microsoft.com",
    "vortex.data.microsoft.com",
    "vortex-win.data.microsoft.com",
    "telemetry.microsoft.com",
    # Apple analytics / iCloud metrics
    "metrics.icloud.com",
    "mask.icloud.com",
    "mask-h2.icloud.com",
    "stocks-analytics-events.apple.com",
    "weather-analytics-events.apple.com",
    # Other common trackers
    "treatment.grammarly.com",
    "pdat.matterlytics.com",
    "g.live.com",
    "dit.whatsapp.net",
    "ct.pinterest.com",
    "analytics.tiktok.com",
    "log.pinterest.com",
    "events.split.io",
    "track.hubspot.com",
    "events.youtube.com",
    # Yandex / Russian trackers (often hit even on western sites)
    "mc.yandex.ru",
    "mc.yandex.com",
    "yandex.ru",
  ]
}

resource "cloudflare_zero_trust_gateway_policy" "block_adware" {
  account_id  = var.account_id
  name        = "Block adware"
  description = "Managed by Terraform — curated free-tier blocklist (no CF Ads category on free plan; see improvements memo #7)"
  action      = "block"
  enabled     = true
  filters     = ["dns"]
  precedence  = 13000
  # `any(dns.domains[*] in {"a" "b" ...})` matches when the queried name
  # is any of the listed domains. We compose the brace-list from the local
  # so the source-of-truth stays human-readable.
  traffic = "any(dns.domains[*] in {${join(" ", [for d in local.adware_domains : "\"${d}\""])}})"
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
