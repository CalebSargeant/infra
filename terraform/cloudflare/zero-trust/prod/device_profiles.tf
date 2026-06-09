# Default device settings profile for the Zero Trust organization.
# This resource manages the global default settings applied to enrolled WARP devices.
resource "cloudflare_zero_trust_device_profiles" "default" {
  account_id  = var.account_id
  name        = "Default"
  description = "Default device settings profile managed by Terraform"
  default     = true
}
