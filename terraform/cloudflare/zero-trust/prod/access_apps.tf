# Cloudflare Access applications + their policies. Imported as-is; every
# field that the CF dashboard set is mirrored here so the first apply is a
# pure state reconciliation.

# --- self_hosted: Radarr ----------------------------------------------------
# Was a bookmark before — that meant the launcher icon existed but the app
# itself wasn't gated by Access at all (bookmarks don't authenticate).
# Now properly self_hosted, behind the same Friends + Caleb policies as
# Overseerr. Reachable via the firefly cloudflared tunnel (ingress in
# tunnels.tf) + the radarr CNAME in cloudflare/dns/prod (created in same PR).
#
# NOTE: this is a ForceNew type change (bookmark → self_hosted) — terraform
# destroys the old bookmark app and creates the new self_hosted one. Brief
# launcher-icon flicker during apply; the URL itself stays
# `https://radarr.sargeant.co` (was the bookmark target, now the
# self_hosted domain).
resource "cloudflare_zero_trust_access_application" "radarr" {
  account_id                = var.account_id
  name                      = "Radarr"
  type                      = "self_hosted"
  domain                    = "radarr.sargeant.co"
  logo_url                  = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/radarr-4k.png"
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

resource "cloudflare_zero_trust_access_policy" "radarr_friends" {
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.radarr.id
  name             = "Friends"
  decision         = "allow"
  precedence       = 1
  session_duration = "24h"

  include {
    group = [cloudflare_zero_trust_access_group.friends.id]
  }
}

resource "cloudflare_zero_trust_access_policy" "radarr_caleb" {
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.radarr.id
  name             = "Caleb"
  decision         = "allow"
  precedence       = 2
  session_duration = "24h"

  include {
    group = [cloudflare_zero_trust_access_group.caleb.id]
  }

  # Mirror overseerr_caleb's posture requirements: Caleb's Radarr session
  # only valid from a macOS device with FileVault on + current OS version.
  # Firewall posture intentionally omitted (many dev Macs have system
  # firewall off; revisit when that changes).
  require {
    device_posture = [
      cloudflare_zero_trust_device_posture_rule.mac_disk_encryption.id,
      cloudflare_zero_trust_device_posture_rule.mac_os_version.id,
    ]
  }
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

resource "cloudflare_zero_trust_access_policy" "overseerr_friends" {
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.overseerr.id
  name             = "Friends"
  decision         = "allow"
  precedence       = 1
  session_duration = "24h"

  include {
    group = [cloudflare_zero_trust_access_group.friends.id]
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
    group = [cloudflare_zero_trust_access_group.caleb.id]
  }

  # Caleb's session is only valid from a macOS device with FileVault on
  # and a current OS version. Firewall posture rule is intentionally NOT
  # included (many dev Macs have the system firewall off; flip on
  # cluster-wide and we can add it). Friends policy stays posture-less —
  # mixed-device family/friends shouldn't be locked out by Apple posture.
  require {
    device_posture = [
      cloudflare_zero_trust_device_posture_rule.mac_disk_encryption.id,
      cloudflare_zero_trust_device_posture_rule.mac_os_version.id,
    ]
  }
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

  # Was inline `email = ["caleb.sargeant@icloud.com"]` — now references
  # the caleb_personal group whose membership lives in OCI Vault, so the
  # personal email address isn't published in the public repo.
  include {
    group = [cloudflare_zero_trust_access_group.caleb_personal.id]
  }
}

resource "cloudflare_zero_trust_access_policy" "warp_allow_emails" {
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.warp_login.id
  name             = "Allow emails: 1/19/2026"
  decision         = "allow"
  precedence       = 2
  session_duration = "24h"

  include {
    group = [cloudflare_zero_trust_access_group.household.id]
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

resource "cloudflare_zero_trust_access_policy" "app_launcher_magma" {
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.app_launcher.id
  name             = "Magma Moose"
  decision         = "allow"
  precedence       = 1
  session_duration = "24h"

  include {
    group = [cloudflare_zero_trust_access_group.magma_moose_domain.id]
  }
}

# --- self_hosted: Comment Commander Pro -------------------------------------
# The comment-commander-pro dashboard (firefly cluster, behind the firefly
# cloudflared tunnel — ingress in tunnels.tf, CNAME in dns-magmamoose/prod).
# The dashboard has no in-app auth or paywall yet (MVP), so Access is the
# only thing gating it: Caleb-only. No device-posture `require` — the posture
# rules need a WARP-enrolled device and Caleb has none, so requiring it would
# be a hard lockout. Tighten when real auth + the paid tier land (see the app
# repo's ROADMAP.md).
resource "cloudflare_zero_trust_access_application" "comment_commander_pro" {
  account_id                = var.account_id
  name                      = "Comment Commander Pro"
  type                      = "self_hosted"
  domain                    = "comment-commander-pro.magmamoose.com"
  tags                      = ["Magma Moose"]
  app_launcher_visible      = true
  auto_redirect_to_identity = false
  session_duration          = "24h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.google_workspace.id,
    cloudflare_zero_trust_access_identity_provider.one_time_pin.id,
    cloudflare_zero_trust_access_identity_provider.google.id,
  ]
}

resource "cloudflare_zero_trust_access_policy" "comment_commander_pro_caleb" {
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.comment_commander_pro.id
  name             = "Caleb"
  decision         = "allow"
  precedence       = 1
  session_duration = "24h"

  include {
    group = [cloudflare_zero_trust_access_group.caleb.id]
  }
}

# --- Dün Mir Pro — now gated by Stytch, NOT Cloudflare Access ----------------
# The licensed operator UI (github.com/MagmaMoose/dunmir-pro) now authenticates
# CUSTOMERS itself via Stytch B2B magic links: the app fail-closes to /login and
# the worker validates the forwarded session JWT, scoping each operator to their
# own tenant. The Cloudflare Access application that used to gate it has therefore
# been removed — Access would double-gate and block self-serve customer sign-up
# (only emails in the Caleb access group could get in). Removing it makes the
# Pages URLs reachable, but the app is gated by Stytch at the edge of every route.
#
# NOTE: applying this DESTROYS the Access app + its policy — dunmir.magmamoose.com
# and *.mikrotik-minder-pro.pages.dev become Stytch-gated only. Confirm Stytch
# sign-in works before merging.

# --- self_hosted: Zoey ------------------------------------------------------
# Zoey — the project-intelligence dashboard (firefly cluster, behind the
# firefly cloudflared tunnel — ingress in tunnels.tf). The app has no in-app
# auth, so Access is the only thing gating the UI: Caleb-only. No
# device-posture `require` — same reasoning as comment-commander-pro (the
# posture rules need a WARP-enrolled device Caleb doesn't have), and Zoey is
# a companion dashboard Caleb will want from his phone too.
#
# Zoey's Slack webhooks (everything under /api/v1/slack/) are carved out by
# the separate bypass app below — Slack's POSTs can't carry an Access cookie.
resource "cloudflare_zero_trust_access_application" "zoey" {
  account_id                = var.account_id
  name                      = "Zoey"
  type                      = "self_hosted"
  domain                    = "zoey.sargeant.co"
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

resource "cloudflare_zero_trust_access_policy" "zoey_caleb" {
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.zoey.id
  name             = "Caleb"
  decision         = "allow"
  precedence       = 1
  session_duration = "24h"

  include {
    group = [cloudflare_zero_trust_access_group.caleb.id]
  }
}

# Bypass app for Zoey's Slack webhooks. Cloudflare Access matches the
# most-specific path first, so POSTs under /api/v1/slack/ — the interaction
# webhook and the app_mention events listener — hit this bypass app instead
# of the Caleb gate above. Slack can't authenticate through Access; every
# /api/v1/slack/* endpoint verifies the Slack v0 HMAC signature itself
# (SLACK_SIGNING_SECRET), so unauthenticated reachability is safe here.
resource "cloudflare_zero_trust_access_application" "zoey_slack" {
  account_id                = var.account_id
  name                      = "Zoey — Slack webhook"
  type                      = "self_hosted"
  domain                    = "zoey.sargeant.co/api/v1/slack/"
  tags                      = ["Sargeant"]
  app_launcher_visible      = false
  auto_redirect_to_identity = false
}

resource "cloudflare_zero_trust_access_policy" "zoey_slack_bypass" {
  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.zoey_slack.id
  name           = "Slack webhook bypass"
  decision       = "bypass"
  precedence     = 1

  include {
    everyone = true
  }
}

# --- self_hosted: Diatreme Pro ----------------------------------------------
# The Diatreme Pro dashboard (firefly cluster, behind the firefly cloudflared
# tunnel — ingress in tunnels.tf), served at the apex diatreme.magmamoose.com.
# Supersedes Comment Commander Pro as comment-commander folds into Diatreme —
# keep the cc-pro app until diatreme-pro is verified live, then prune both. The
# dashboard has no in-app auth/paywall yet (MVP), so Access is the only thing
# gating it: Caleb-only. No device-posture `require` — same reasoning as
# comment-commander-pro / Zoey (the posture rules need a WARP-enrolled device
# Caleb doesn't have, so requiring it is a hard lockout; he'll want it on mobile
# too).
#
# Only the dashboard apex is gated. The Diatreme *worker* lives at
# api.diatreme.magmamoose.com and is intentionally NOT behind Access — it's the
# OSS engine API (token broker, /process, /dispatch, /sign, the GitHub webhook,
# OAuth callback) and authenticates callers itself (bearer / HMAC / OIDC).
resource "cloudflare_zero_trust_access_application" "diatreme_pro" {
  account_id                = var.account_id
  name                      = "Diatreme Pro"
  type                      = "self_hosted"
  domain                    = "diatreme.magmamoose.com"
  tags                      = ["Magma Moose"]
  app_launcher_visible      = true
  auto_redirect_to_identity = false
  session_duration          = "24h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.google_workspace.id,
    cloudflare_zero_trust_access_identity_provider.one_time_pin.id,
    cloudflare_zero_trust_access_identity_provider.google.id,
  ]
}

resource "cloudflare_zero_trust_access_policy" "diatreme_pro_caleb" {
  account_id       = var.account_id
  application_id   = cloudflare_zero_trust_access_application.diatreme_pro.id
  name             = "Caleb"
  decision         = "allow"
  precedence       = 1
  session_duration = "24h"

  include {
    group = [cloudflare_zero_trust_access_group.caleb.id]
  }
}

# --- self_hosted: Diatreme Dispatch API (bypass — bearer-gated) -------------
# diatreme.magmamoose.com/api/dispatch is POSTed to by the Diatreme worker
# (api.diatreme.magmamoose.com) when triage decides a Copilot comment is a
# "fix" — it hands off to the diatreme-pro agent dispatcher. Most-specific path
# first, so /api/dispatch hits this bypass app instead of the Caleb gate on the
# apex dashboard above. The dispatcher authenticates the worker itself (Bearer
# DISPATCH_AGENT_TOKEN) and 503s until configured, so unauthenticated
# reachability is safe here — same reasoning as the Zoey Slack webhook bypass.
# Browser users only ever load the dashboard apex, which stays Caleb-only.
resource "cloudflare_zero_trust_access_application" "diatreme_dispatch" {
  account_id                = var.account_id
  name                      = "Diatreme Dispatch API"
  type                      = "self_hosted"
  domain                    = "diatreme.magmamoose.com/api/dispatch"
  tags                      = ["Magma Moose"]
  app_launcher_visible      = false
  auto_redirect_to_identity = false
}

resource "cloudflare_zero_trust_access_policy" "diatreme_dispatch_bypass" {
  account_id     = var.account_id
  application_id = cloudflare_zero_trust_access_application.diatreme_dispatch.id
  name           = "Worker bypass (bearer-gated)"
  decision       = "bypass"
  precedence     = 1

  include {
    everyone = true
  }
}
