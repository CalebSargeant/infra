terraform {
  required_version = ">= 1.5.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.40"
    }
    # Used by tunnels.tf to generate the firefly_oci tunnel_secret so it's
    # not hand-written. State holds the value; the connector token (derived
    # by the CF API) is exported via the firefly_oci_tunnel_token output.
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
