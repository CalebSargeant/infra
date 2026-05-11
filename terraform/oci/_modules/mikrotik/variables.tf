# ---------------------------------------------------------------------------
# Routers (one entry per router; iterated by the routeros provider for_each)
# ---------------------------------------------------------------------------
variable "routers" {
  description = "Map of router key (r1, r2, ...) to connection details"
  type = map(object({
    hosturl = string
  }))
}

variable "routeros_username" {
  description = "RouterOS API username (shared by all routers)"
  type        = string
  default     = "admin"
}

variable "routeros_password" {
  description = "RouterOS API password (shared by all routers)"
  type        = string
  sensitive   = true
}

variable "routeros_insecure" {
  description = "Skip TLS verification for the RouterOS REST API (CHR self-signed cert)"
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Container bridge / veth (identical on both routers — each runs its own
# cloudflared replica connected to the same Cloudflare tunnel for HA)
# ---------------------------------------------------------------------------
variable "container_bridge_name" {
  description = "Bridge name that container veths attach to"
  type        = string
  default     = "containers"
}

variable "container_network_cidr" {
  description = "CIDR of the container bridge network"
  type        = string
  default     = "172.17.0.0/24"
}

variable "container_gateway_ip" {
  description = "Gateway IP on the bridge (router side)"
  type        = string
  default     = "172.17.0.1"
}

variable "cloudflared_container_ip" {
  description = "IP assigned inside the cloudflared container"
  type        = string
  default     = "172.17.0.2"
}

variable "cloudflared_stop_signals" {
  description = "Per-router stop signal for the cloudflared container. r1/r2 RouterOS firmwares disagree on the accepted format — r1 wants the enum-style \"15-SIGTERM\", r2 wants the bare number \"15\". Don't combine into one value."
  type        = map(string)
  default = {
    r1 = "15-SIGTERM"
    r2 = "15"
  }
}

variable "cloudflared_veth_macs" {
  description = "Host-side MAC for the veth pair, per router. Omit a router key to let RouterOS auto-generate the MAC — needed for builds whose API rejects mac-address at create-time. The container-side MAC is always auto-generated (v1.99.1 doesn't expose container_mac_address)."
  type        = map(string)
  default = {
    # r1 preserves the MAC from the original .rsc; r2 omitted so RouterOS auto-generates.
    r1 = "34:06:F1:63:E1:7F"
  }
}

# ---------------------------------------------------------------------------
# Cloudflared container
# ---------------------------------------------------------------------------
variable "cloudflared_tunnel_token" {
  description = "Cloudflare tunnel token (JWT) — shared by both routers as HA replicas"
  type        = string
  sensitive   = true
}

variable "cloudflared_image" {
  description = "Cloudflared container image"
  type        = string
  default     = "cloudflare/cloudflared:latest"
}

variable "container_root_dir" {
  description = "Root directory on the router for the cloudflared container layers"
  type        = string
  default     = "/disk1/containers/cloudflared"
}

variable "container_tmpdir" {
  description = "tmpdir for container image pulls"
  type        = string
  default     = "/disk1/pull"
}

variable "container_registry_url" {
  description = "Container registry URL"
  type        = string
  default     = "https://registry-1.docker.io"
}

# ---------------------------------------------------------------------------
# Firewall address lists
# ---------------------------------------------------------------------------
variable "trusted_addresses" {
  description = "Entries for the TRUSTED address-list (comment => address-or-host)"
  type        = map(string)
  default = {
    "Pink Roccade office"           = "212.61.158.12"
    "Sargeant House, Venray, NL"    = "vpn.sargeant.co"
    "Franklin House, Cape Town, ZA" = "vpn.franklinhouse.co.za"
    "Sargeant OCI, Amsterdam, NL"   = "oci.sargeant.co"
  }
}

variable "rfc1918_addresses" {
  description = "Entries for the RFC1918 address-list (comment => CIDR)"
  type        = map(string)
  default = {
    "RFC1918-192" = "192.168.0.0/16"
    "RFC1918-172" = "172.16.0.0/12"
    "RFC1918-10"  = "10.0.0.0/8"
  }
}
