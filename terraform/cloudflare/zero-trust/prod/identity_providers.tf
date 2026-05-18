# Identity providers wired to Cloudflare Access. Imported as-is — IdP secrets
# (Google OAuth client_id/secret etc.) are redacted by the CF API after
# creation, so we ignore_changes on config to avoid spurious diffs/drift.
# Rotating an IdP secret means editing here AND in the IdP console, then
# removing the ignore_changes for that resource temporarily.

resource "cloudflare_zero_trust_access_identity_provider" "one_time_pin" {
  account_id = var.account_id
  name       = "One-time PIN"
  type       = "onetimepin"
}

resource "cloudflare_zero_trust_access_identity_provider" "google" {
  account_id = var.account_id
  name       = "Google"
  type       = "google"

  config {
    client_id     = "IMPORTED_FROM_DASHBOARD"
    client_secret = "IMPORTED_FROM_DASHBOARD"
  }

  lifecycle {
    ignore_changes = [config]
  }
}

resource "cloudflare_zero_trust_access_identity_provider" "google_workspace" {
  account_id = var.account_id
  name       = "Google Workspace"
  type       = "google-apps"

  config {
    apps_domain   = "magmamoose.com"
    client_id     = "IMPORTED_FROM_DASHBOARD"
    client_secret = "IMPORTED_FROM_DASHBOARD"
  }

  lifecycle {
    ignore_changes = [config]
  }
}
