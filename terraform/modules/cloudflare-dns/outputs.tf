output "record_ids" {
  description = "Map of record key (name#type#value) to Cloudflare record ID"
  value       = { for k, r in cloudflare_record.this : k => r.id }
}

output "record_hostnames" {
  description = "Map of record key to hostname (name)"
  value       = { for k, r in cloudflare_record.this : k => r.hostname }
}
