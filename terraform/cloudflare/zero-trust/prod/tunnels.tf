# Cloudflared tunnels. The `firefly` tunnel was created in the dashboard and
# its credentials are currently held by the cloudflared container running on
# the OCI MikroTik CHRs (see terraform/oci/modules/mikrotik/).
#
# tunnel_secret is required by the resource but is only used at *creation*;
# importing an existing tunnel doesn't let us read the original secret back
# from the CF API. We supply a placeholder and ignore_changes so the import
# doesn't try to rotate. A genuine rotation (planned follow-up) would unset
# ignore_changes, set a real secret, and push the new credentials to wherever
# cloudflared reads them.

resource "cloudflare_zero_trust_tunnel_cloudflared" "firefly" {
  account_id = var.account_id
  name       = "firefly"

  # Placeholder; ignored after import. `secret` must be base64 of a 32+ byte
  # value but is only consumed at create-time. (Provider v4 renamed this from
  # tunnel_secret → secret somewhere along the line.)
  secret = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

  lifecycle {
    ignore_changes = [secret]
  }
}

# Ingress for the firefly tunnel. Mirrors the dashboard's current config:
# - overseerr.sargeant.co  -> http://overseerr.media.svc.cluster.local:5055
# - <anything else>        -> http_status:404
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "firefly" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.firefly.id

  config {
    warp_routing {
      enabled = true
    }

    ingress_rule {
      hostname = "overseerr.sargeant.co"
      service  = "http://overseerr.media.svc.cluster.local:5055"
      origin_request {}
    }

    ingress_rule {
      hostname = "radarr.sargeant.co"
      service  = "http://radarr.media.svc.cluster.local:7878"
      origin_request {}
    }

    # GitHub webhooks → Atlantis (firefly cluster). This + the cloudflare
    # tunnel auto-creates the public CNAME atlantis.sargeant.co →
    # <tunnel-id>.cfargotunnel.com so the App's webhook URL resolves.
    ingress_rule {
      hostname = "atlantis.sargeant.co"
      service  = "http://atlantis.automation.svc.cluster.local:80"
      origin_request {}
    }

    # GitHub PR-review webhooks → comment-commander (firefly cluster).
    # Pairs with the explicit proxied CNAME in
    # terraform/cloudflare/dns-magmamoose/prod/terragrunt.hcl
    # (comment-commander.magmamoose.com → <tunnel-id>.cfargotunnel.com).
    # Same pattern as atlantis.sargeant.co / radarr.sargeant.co.
    ingress_rule {
      hostname = "comment-commander.magmamoose.com"
      service  = "http://comment-commander.comment-commander.svc.cluster.local:8000"
      origin_request {}
    }

    # Cloudflared requires the last rule to be a catch-all with no hostname.
    ingress_rule {
      service = "http_status:404"
    }
  }
}
