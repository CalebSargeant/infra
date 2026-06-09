# Split Tunnel configuration for the default device profile.
# By default, WARP excludes private network subnets (RFC1918 ranges) from its tunnel.
# To route RFC1918 subnets through the firefly tunnel, we configure Split Tunneling
# in "exclude" mode and remove the 10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16 subnets
# from this exclusion list. The WARP client's dynamic LAN bypass (lan_allow_subnet_size)
# will automatically handle excluding the active local LAN from the tunnel.
resource "cloudflare_zero_trust_split_tunnel" "default_exclude" {
  account_id = var.account_id
  policy_id  = cloudflare_zero_trust_device_profiles.default.id
  mode       = "exclude"

  tunnels {
    address     = "255.255.255.255/32"
    description = "DHCP Broadcast"
  }

  tunnels {
    address     = "169.254.0.0/16"
    description = "DHCP Unspecified"
  }

  tunnels {
    address     = "100.64.0.0/10"
    description = "Carrier Grade NAT / Cloudflare Services"
  }

  tunnels {
    address     = "192.0.0.0/24"
    description = "IETF Protocol Assignments"
  }

  tunnels {
    address     = "224.0.0.0/24"
    description = "Multicast"
  }

  tunnels {
    address     = "240.0.0.0/4"
    description = "Reserved"
  }

  tunnels {
    address     = "fd00::/8"
    description = "IPv6 Unique Local"
  }

  tunnels {
    address     = "fe80::/10"
    description = "IPv6 Link Local"
  }

  tunnels {
    address     = "ff01::/16"
    description = "IPv6 Multicast"
  }

  tunnels {
    address     = "ff02::/16"
    description = "IPv6 Multicast"
  }

  tunnels {
    address     = "ff03::/16"
    description = "IPv6 Multicast"
  }

  tunnels {
    address     = "ff04::/16"
    description = "IPv6 Multicast"
  }

  tunnels {
    address     = "ff05::/16"
    description = "IPv6 Multicast"
  }
}
