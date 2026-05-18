terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Provider configuration is the caller's responsibility (see
# https://developer.hashicorp.com/terraform/language/modules/develop/providers).
# The calling terragrunt.hcl generates a provider.tf with the api_token.

# Key records by name#type#value so the same name+type can appear twice with
# different values (round-robin), which is how oci.sargeant.co resolves to
# both r1 and r2.
resource "cloudflare_record" "this" {
  for_each = {
    for r in var.records : "${r.name}#${r.type}#${r.value}" => r
  }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.value
  ttl     = each.value.ttl
  proxied = each.value.proxied
  comment = "Managed by Terraform"
}

# Import blocks for records that already exist in the dashboard. Empty
# `imports` list = no imports (the steady state once initial migration is
# done).
import {
  for_each = { for i in var.imports : i.key => i }
  to       = cloudflare_record.this[each.key]
  id       = "${var.zone_id}/${each.value.record_id}"
}
