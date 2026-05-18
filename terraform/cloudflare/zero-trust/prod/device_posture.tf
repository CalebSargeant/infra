# Device posture rules. These get referenced from Access policies' `require`
# block (none currently do — see /improvements memo). Imported as-is so we
# don't lose them; future Access policies can require any of these.

resource "cloudflare_zero_trust_device_posture_rule" "mac_disk_encryption" {
  account_id  = var.account_id
  name        = "MacOS Disk Encryption"
  type        = "disk_encryption"
  description = ""
  schedule    = "5m"

  input {
    require_all = true
    check_disks = []
  }

  match {
    platform = "mac"
  }
}

resource "cloudflare_zero_trust_device_posture_rule" "mac_firewall" {
  account_id  = var.account_id
  name        = "MacOS Firewall"
  type        = "firewall"
  description = ""
  schedule    = "5m"

  input {
    enabled = true
  }

  match {
    platform = "mac"
  }
}

resource "cloudflare_zero_trust_device_posture_rule" "mac_os_version" {
  account_id  = var.account_id
  name        = "MacOS Version"
  type        = "os_version"
  description = ""
  schedule    = "5m"

  input {
    version  = "13.0.1"
    operator = ">="
  }

  match {
    platform = "mac"
  }
}
