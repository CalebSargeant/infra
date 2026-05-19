# Cloudflare Access applications + their policies. Imported as-is; every
# field that the CF dashboard set is mirrored here so the first apply is a
# pure state reconciliation.

# --- bookmark: Radarr -------------------------------------------------------
resource "cloudflare_zero_trust_access_application" "radarr" {
  account_id                = var.account_id
  name                      = "Radarr"
  type                      = "bookmark"
  domain                    = "https://radarr.sargeant.co"
  logo_url                  = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/radarr-4k.png"
  tags                      = ["Sargeant"]
  app_launcher_visible      = true
  auto_redirect_to_identity = false
}

# --- bookmark: AWS Access Portal (magmamoose) -------------------------------
resource "cloudflare_zero_trust_access_application" "aws_magmamoose" {
  account_id                = var.account_id
  name                      = "AWS Access Portal"
  type                      = "bookmark"
  domain                    = "https://magmamoose.awsapps.com/start"
  logo_url                  = "https://www.pngplay.com/wp-content/uploads/3/Amazon-Web-Services-AWS-Logo-Transparent-PNG.png"
  tags                      = ["Magma Moose"]
  app_launcher_visible      = true
  auto_redirect_to_identity = false
}

# --- bookmark: AWS Access Portal (platform-1) -------------------------------
resource "cloudflare_zero_trust_access_application" "aws_platform_1" {
  account_id                = var.account_id
  name                      = "AWS Access Portal"
  type                      = "bookmark"
  domain                    = "https://platform-1.awsapps.com/start"
  logo_url                  = "https://www.pngplay.com/wp-content/uploads/3/Amazon-Web-Services-AWS-Logo-Transparent-PNG.png"
  tags                      = ["Platform1"]
  app_launcher_visible      = true
  auto_redirect_to_identity = false
}

# --- self_hosted: Overseerr -------------------------------------------------
resource "cloudflare_zero_trust_access_application" "overseerr" {
  account_id                = var.account_id
  name                      = "Overseerr"
  type                      = "self_hosted"
  domain                    = "overseerr.sargeant.co"
  logo_url                  = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/overseerr.svg"
  tags                      = ["Sargeant"]
  app_launcher_visible      = true
  auto_redirect_to_identity = false
  session_duration          = "24h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.google_workspace.id,
    cloudflare_zero_trust_access_identity_provider.one_time_pin.id,
    cloudflare_zero_trust_access_identity_provider.google.id,
  ]
}

# NOTE: overseerr_friends / overseerr_caleb are *reusable* policies in CF
# (the v4 provider can't update reusable policies through the app-scoped
# endpoint — error 12130). Keeping the include lists inline here matches
# what's already in CF, so the plan stays no-op on these two. The matching
# access_groups (friends, caleb) are still defined for future reuse on
# other apps; once the provider grows reusable-policy support or these
# get recreated as app-scoped, switch include to `group = [...]`.
resource "cloudflare_zero_trust_access_policy" "overseerr_friends" {
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.overseerr.id
  name             = "Friends"
  decision         = "allow"
  precedence       = 1
  session_duration = "24h"

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
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.overseerr.id
  name             = "Caleb"
  decision         = "allow"
  precedence       = 2
  session_duration = "24h"

  include {
    email = ["caleb@magmamoose.com"]
  }

  # NOTE — posture `require` would belong here, but this policy is reusable
  # in CF (error 12130 on app-scoped update). Provider v4 has no resource
  # for reusable-policy updates; add via dashboard or wait for v5 migration.
  # When it can be added, use:
  #   require {
  #     device_posture = [
  #       cloudflare_zero_trust_device_posture_rule.mac_disk_encryption.id,
  #       cloudflare_zero_trust_device_posture_rule.mac_os_version.id,
  #     ]
  #   }
}

# --- warp: Warp Login App ---------------------------------------------------
# WARP login is unusual — CF returns logo_url=null, tags=[], allowed_idps=[],
# app_launcher_visible=null. We mirror that so the import doesn't try to set
# anything new. auto_redirect_to_identity=false matches.
resource "cloudflare_zero_trust_access_application" "warp_login" {
  account_id                = var.account_id
  name                      = "Warp Login App"
  type                      = "warp"
  domain                    = "magmamoose.cloudflareaccess.com/warp"
  tags                      = []
  allowed_idps              = []
  app_launcher_visible      = false # CF returns null for warp apps; pin false to match
  auto_redirect_to_identity = false
  session_duration          = "24h"
}

resource "cloudflare_zero_trust_access_policy" "warp_email_domain" {
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.warp_login.id
  name             = "Email domain policy"
  decision         = "allow"
  precedence       = 1
  session_duration = "24h"

  include {
    email = ["caleb.sargeant@icloud.com"]
  }
}

# Reusable policy in CF — can't refactor include to use household group
# through v4 provider (error 12130). Keeping inline emails.
resource "cloudflare_zero_trust_access_policy" "warp_allow_emails" {
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.warp_login.id
  name             = "Allow emails: 1/19/2026"
  decision         = "allow"
  precedence       = 2
  session_duration = "24h"

  include {
    email = [
      "caleb@magmamoose.com",
      "tracey@magmamoose.com",
    ]
  }
}

# --- app_launcher -----------------------------------------------------------
resource "cloudflare_zero_trust_access_application" "app_launcher" {
  account_id                = var.account_id
  name                      = "App Launcher"
  type                      = "app_launcher"
  domain                    = "magmamoose.cloudflareaccess.com"
  app_launcher_visible      = false # the launcher itself; CF returns null here, pin false to match
  auto_redirect_to_identity = true
  session_duration          = "24h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.google_workspace.id,
  ]
}

# Reusable policy in CF — can't refactor include to use magma_moose_domain
# group through v4 provider (error 12130). Keeping inline email_domain.
resource "cloudflare_zero_trust_access_policy" "app_launcher_magma" {
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.app_launcher.id
  name             = "Magma Moose"
  decision         = "allow"
  precedence       = 1
  session_duration = "24h"

  include {
    email_domain = ["magmamoose.com"]
  }
}
