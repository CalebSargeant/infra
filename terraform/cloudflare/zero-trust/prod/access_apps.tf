# Cloudflare Access applications + their policies. All applications imported
# as-is. Three of the bookmarks have no policies (intentional — bookmarks
# don't gate access, they're just App Launcher icons). The self_hosted and
# warp apps have proper allow policies.
#
# A natural follow-up here is to extract repeated email lists into
# cloudflare_zero_trust_access_group resources and reference those from each
# app's policies, instead of inlining the same lists into every app.

# --- bookmark: Radarr -------------------------------------------------------
resource "cloudflare_zero_trust_access_application" "radarr" {
  account_id = var.account_id
  name       = "Radarr"
  type       = "bookmark"
  domain     = "https://radarr.sargeant.co"
}

# --- bookmark: AWS Access Portal (magmamoose) -------------------------------
resource "cloudflare_zero_trust_access_application" "aws_magmamoose" {
  account_id = var.account_id
  name       = "AWS Access Portal"
  type       = "bookmark"
  domain     = "https://magmamoose.awsapps.com/start"
}

# --- bookmark: AWS Access Portal (platform-1) -------------------------------
resource "cloudflare_zero_trust_access_application" "aws_platform_1" {
  account_id = var.account_id
  name       = "AWS Access Portal"
  type       = "bookmark"
  domain     = "https://platform-1.awsapps.com/start"
}

# --- self_hosted: Overseerr -------------------------------------------------
resource "cloudflare_zero_trust_access_application" "overseerr" {
  account_id       = var.account_id
  name             = "Overseerr"
  type             = "self_hosted"
  domain           = "overseerr.sargeant.co"
  session_duration = "24h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.google_workspace.id,
    cloudflare_zero_trust_access_identity_provider.one_time_pin.id,
    cloudflare_zero_trust_access_identity_provider.google.id,
  ]
}

resource "cloudflare_zero_trust_access_policy" "overseerr_friends" {
  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.overseerr.id
  name           = "Friends"
  decision       = "allow"
  precedence     = 1

  include {
    email = [
      "calebsargeant@gmail.com",
      "nicholas_smith_@msn.com",
      "dvs.sargeant@gmail.com",
      "dirkie.jvrensburg@gmail.com",
      "sabinekersten@hotmail.com",
      "srgnat001@gmail.com",
      "traceyleigh.sargeant@gmail.com",
      "ogenrwotaron@gmail.com",
      "llew.adamson@icloud.com",
      "tracey@magmamoose.com",
    ]
  }
}

resource "cloudflare_zero_trust_access_policy" "overseerr_caleb" {
  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.overseerr.id
  name           = "Caleb"
  decision       = "allow"
  precedence     = 2

  include {
    email = ["caleb@magmamoose.com"]
  }
}

# --- warp: Warp Login App ---------------------------------------------------
resource "cloudflare_zero_trust_access_application" "warp_login" {
  account_id       = var.account_id
  name             = "Warp Login App"
  type             = "warp"
  domain           = "magmamoose.cloudflareaccess.com/warp"
  session_duration = "24h"
}

resource "cloudflare_zero_trust_access_policy" "warp_email_domain" {
  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.warp_login.id
  name           = "Email domain policy"
  decision       = "allow"
  precedence     = 1

  include {
    email = ["caleb.sargeant@icloud.com"]
  }
}

resource "cloudflare_zero_trust_access_policy" "warp_allow_emails" {
  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.warp_login.id
  name           = "Allow emails: 1/19/2026"
  decision       = "allow"
  precedence     = 2

  include {
    email = [
      "caleb@magmamoose.com",
      "tracey@magmamoose.com",
    ]
  }
}

# --- app_launcher -----------------------------------------------------------
resource "cloudflare_zero_trust_access_application" "app_launcher" {
  account_id       = var.account_id
  name             = "App Launcher"
  type             = "app_launcher"
  domain           = "magmamoose.cloudflareaccess.com"
  session_duration = "24h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.google_workspace.id,
  ]
}

resource "cloudflare_zero_trust_access_policy" "app_launcher_magma" {
  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.app_launcher.id
  name           = "Magma Moose"
  decision       = "allow"
  precedence     = 1

  include {
    email_domain = ["magmamoose.com"]
  }
}
