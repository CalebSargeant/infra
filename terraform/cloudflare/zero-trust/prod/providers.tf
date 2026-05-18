variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zero Trust + DNS:Edit"
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "Cloudflare account ID (Zero Trust org)"
  type        = string
}

variable "sargeant_co_zone_id" {
  description = "Cloudflare zone ID for sargeant.co"
  type        = string
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
