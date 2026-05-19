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

variable "imports" {
  description = "Pre-existing Cloudflare records to bring under terraform management. Each entry needs the same `name#type#value` key used in `records` plus the record's Cloudflare ID. Used for initial dashboard→terraform migration; can be empty after the first apply lands."
  type = list(object({
    key       = string
    record_id = string
  }))
  default = []
}
