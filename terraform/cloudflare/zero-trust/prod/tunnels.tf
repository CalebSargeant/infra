# Cloudflared tunnels. The `firefly` tunnel was created in the dashboard and
# its credentials are currently held by the cloudflared container running on
# the OCI MikroTik CHRs (see terraform/oci/_modules/mikrotik/).
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

  # Placeholder; ignored after import. tunnel_secret must be base64 of a 32+
  # byte value but is only consumed at create-time.
  tunnel_secret = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

  lifecycle {
    ignore_changes = [tunnel_secret]
  }
}

# Ingress for the firefly tunnel. Mirrors the dashboard's current config:
# - overseerr.sargeant.co  -> http://overseerr.media.svc.cluster.local:5055
# - <anything else>        -> http_status:404
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "firefly" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.firefly.id

  config {
    ingress_rule {
      hostname = "overseerr.sargeant.co"
      service  = "http://overseerr.media.svc.cluster.local:5055"
    }

    # Cloudflared requires the last rule to be a catch-all with no hostname.
    ingress_rule {
      service = "http_status:404"
    }
  }
}
