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
# only thing gating it: Caleb-only, with the same macOS device-posture
# requirement used for Radarr/Overseerr. Tighten/loosen when real auth +
# the paid tier land (see the app repo's ROADMAP.md).
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

  require {
    device_posture = [
      cloudflare_zero_trust_device_posture_rule.mac_disk_encryption.id,
      cloudflare_zero_trust_device_posture_rule.mac_os_version.id,
    ]
  }
}
