# The routeros provider lives in its own file so Terragrunt's generated
# provider.tf (oci + google, from root.hcl) doesn't overwrite it. for_each
# fans the provider out per router (OpenTofu 1.9+).
provider "routeros" {
  alias    = "by_router"
  for_each = var.routers

  hosturl  = each.value.hosturl
  username = var.routeros_username
  password = var.routeros_password
  insecure = var.routeros_insecure
}
