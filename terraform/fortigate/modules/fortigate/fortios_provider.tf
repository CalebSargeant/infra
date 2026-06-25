# Two standalone FortiGate 40Fs (NO HA — each is an independent edge with its
# own ISP). The fortios provider is iterated per unit with for_each (OpenTofu
# 1.9+), so every resource is declared once and fanned out across both boxes —
# this is the "target both FortiGates at the same time" behaviour. Mirrors the
# oci/mikrotik module's `provider "routeros" { for_each = var.routers }`.
#
# API-token auth is Fortinet's supported method for the provider (not
# user/password). Each unit's token + management host come from var.fortigates
# / var.fortigate_tokens, populated by the leaf terragrunt.hcl.
provider "fortios" {
  alias    = "by_fortigate"
  for_each = var.fortigates

  hostname = each.value.hostname
  token    = var.fortigate_tokens[each.key]
  vdom     = each.value.vdom
  insecure = var.fortigate_insecure
}
