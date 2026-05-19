# Reusable Access Groups so app policies don't need to re-inline the same
# email lists. Membership changes are then a single edit instead of one per
# app that allows that group.

resource "cloudflare_zero_trust_access_group" "friends" {
  account_id = var.account_id
  name       = "Friends"

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

resource "cloudflare_zero_trust_access_group" "caleb" {
  account_id = var.account_id
  name       = "Caleb"

  include {
    email = ["caleb@magmamoose.com"]
  }
}

resource "cloudflare_zero_trust_access_group" "household" {
  account_id = var.account_id
  name       = "Household"

  include {
    email = [
      "caleb@magmamoose.com",
      "tracey@magmamoose.com",
    ]
  }
}

resource "cloudflare_zero_trust_access_group" "magma_moose_domain" {
  account_id = var.account_id
  name       = "Magma Moose"

  include {
    email_domain = ["magmamoose.com"]
  }
}
