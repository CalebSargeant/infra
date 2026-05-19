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

# Note: an L4 allow+block pair on 192.168.69.110 (Franklin Cape Town
# network) lived here until cloudflare-ztna-improvements.md #8 was
# resolved. Both rules were dead code: the allow at precedence 15000
# matched first so the block at 16000 never fired, and Gateway default-
# allows traffic anyway so the allow was a no-op too. Access to .110
# already goes via the on-prem MikroTik VPN + DRG peering, not through
# Cloudflare WARP, so dropping the policies has no data-plane effect.
