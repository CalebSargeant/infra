# Cloudflare Zero Trust Gateway policies. Two of these are an allow+block
# pair for the same destination IP (192.168.69.110) — order matters; the
# block-after-allow is what's currently in the dashboard, so we preserve the
# explicit precedence values to match.

resource "cloudflare_zero_trust_gateway_policy" "block_adware" {
  account_id  = var.account_id
  name        = "Block adware"
  description = ""
  action      = "block"
  enabled     = true
  filters     = ["dns"]
  precedence  = 1
  traffic     = "any(dns.domains[*] in {\"doubleclick.net\" \"self.events.data.microsoft.com\" \"metrics.icloud.com\" \"dit.whatsapp.net\" \"mask.icloud.com\" \"app-measurement.com\" \"g.live.com\" \"mask-h2.icloud.com\" \"treatment.grammarly.com\" \"firebaselogging-pa.googleapis.com\" \"partner.googleadservices.com\" \"c.amazon-adsystem.com\" \"pagead2.googlesyndication.com\" \"www.googletagmanager.com\" \"www.google-analytics.com\" \"pdat.matterlytics.com\"})"
}

resource "cloudflare_zero_trust_gateway_policy" "allow_server_l4" {
  account_id  = var.account_id
  name        = "Allow rule for Server"
  description = ""
  action      = "allow"
  enabled     = true
  filters     = ["l4"]
  precedence  = 2
  traffic     = "net.dst.ip == 192.168.69.110"
}

resource "cloudflare_zero_trust_gateway_policy" "block_server_l4" {
  account_id  = var.account_id
  name        = "Block rule for Server"
  description = ""
  action      = "block"
  enabled     = true
  filters     = ["l4"]
  precedence  = 3
  traffic     = "net.dst.ip == 192.168.69.110"
}
