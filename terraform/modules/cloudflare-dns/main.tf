terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

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
}
