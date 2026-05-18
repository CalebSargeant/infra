variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone.DNS edit on the target zone"
  type        = string
  sensitive   = true
}

variable "zone_id" {
  description = "Cloudflare zone ID to manage records in"
  type        = string
}

variable "records" {
  description = "List of DNS records to create. Multiple entries with the same name + type create a multi-value (round-robin) record."
  type = list(object({
    name    = string
    type    = string
    value   = string
    ttl     = optional(number, 1)
    proxied = optional(bool, false)
  }))
  default = []
}
