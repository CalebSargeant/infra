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

variable "cf_access_groups_membership" {
  description = "Email member lists for each Access group, sourced from OCI Vault by the terragrunt parse-time run_cmd (see terragrunt.hcl). Kept out of git so the public repo doesn't list family/friends' personal addresses (PII)."
  type = object({
    friends        = list(string)
    caleb          = list(string)
    household      = list(string)
    caleb_personal = list(string)
  })
  sensitive = true
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
