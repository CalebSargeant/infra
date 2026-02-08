# OCI VPN Module
# Creates IPSec VPN connections to remote sites (AWS, on-prem MikroTik)
# Auto-generates PSKs and stores them in OCI Vault

# Vault for storing VPN secrets
resource "oci_kms_vault" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "vault-vpn-${var.environment}"
  vault_type     = "DEFAULT"
}

# Master encryption key for secrets
resource "oci_kms_key" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "key-vpn-${var.environment}"
  key_shape {
    algorithm = "AES"
    length    = 32
  }
  management_endpoint = oci_kms_vault.this.management_endpoint
}

# Customer Premises Equipment (CPE) for each VPN connection
resource "oci_core_cpe" "this" {
  for_each = var.vpn_connections

  compartment_id      = var.compartment_ocid
  ip_address          = each.value.peer_ip
  display_name        = "cpe-${each.key}-${var.environment}"
  cpe_device_shape_id = each.value.cpe_device_shape_id

  # Freeform tags for identification
  freeform_tags = {
    "Name"        = each.key
    "Environment" = var.environment
    "Type"        = each.value.type
  }
}

# IPSec Connection for each CPE
resource "oci_core_ipsec" "this" {
  for_each = var.vpn_connections

  compartment_id = var.compartment_ocid
  cpe_id         = oci_core_cpe.this[each.key].id
  drg_id         = var.drg_id
  display_name   = "ipsec-${each.key}-${var.environment}"

  static_routes = each.value.static_routes

  # Freeform tags
  freeform_tags = {
    "Name"        = each.key
    "Environment" = var.environment
    "Type"        = each.value.type
  }
}

# Get the IPSec tunnel details (OCI creates 2 tunnels per connection for redundancy)
data "oci_core_ipsec_connection_tunnels" "this" {
  for_each = var.vpn_connections

  ipsec_id = oci_core_ipsec.this[each.key].id
}

# Configure IPSec tunnel settings
resource "oci_core_ipsec_connection_tunnel_management" "tunnel1" {
  for_each = var.vpn_connections

  ipsec_id  = oci_core_ipsec.this[each.key].id
  tunnel_id = data.oci_core_ipsec_connection_tunnels.this[each.key].ip_sec_connection_tunnels[0].id

  display_name = "tunnel1-${each.key}-${var.environment}"
  routing      = each.value.routing_type

  # BGP configuration (if using BGP)
  dynamic "bgp_session_info" {
    for_each = each.value.routing_type == "BGP" ? [1] : []
    content {
      customer_bgp_asn = each.value.bgp_asn
      # Only set IPs if provided, otherwise let OCI auto-assign
      customer_interface_ip = each.value.bgp_customer_ip_tunnel1 != null ? each.value.bgp_customer_ip_tunnel1 : null
      oracle_interface_ip   = each.value.bgp_oracle_ip_tunnel1 != null ? each.value.bgp_oracle_ip_tunnel1 : null
    }
  }

  # IKE configuration
  ike_version = each.value.ike_version

  # Encryption settings
  encryption_domain_config {
    cpe_traffic_selector    = each.value.static_routes
    oracle_traffic_selector = var.local_networks
  }

  # Let OCI auto-generate shared secret
  shared_secret = each.value.shared_secret_tunnel1
}

resource "oci_core_ipsec_connection_tunnel_management" "tunnel2" {
  for_each = var.vpn_connections

  ipsec_id  = oci_core_ipsec.this[each.key].id
  tunnel_id = data.oci_core_ipsec_connection_tunnels.this[each.key].ip_sec_connection_tunnels[1].id

  display_name = "tunnel2-${each.key}-${var.environment}"
  routing      = each.value.routing_type

  # BGP configuration (if using BGP)
  dynamic "bgp_session_info" {
    for_each = each.value.routing_type == "BGP" ? [1] : []
    content {
      customer_bgp_asn = each.value.bgp_asn
      # Only set IPs if provided, otherwise let OCI auto-assign
      customer_interface_ip = each.value.bgp_customer_ip_tunnel2 != null ? each.value.bgp_customer_ip_tunnel2 : null
      oracle_interface_ip   = each.value.bgp_oracle_ip_tunnel2 != null ? each.value.bgp_oracle_ip_tunnel2 : null
    }
  }

  # IKE configuration
  ike_version = each.value.ike_version

  # Encryption settings
  encryption_domain_config {
    cpe_traffic_selector    = each.value.static_routes
    oracle_traffic_selector = var.local_networks
  }

  # Let OCI auto-generate shared secret
  shared_secret = each.value.shared_secret_tunnel2
}

# Store PSKs in OCI Vault
resource "oci_vault_secret" "tunnel1_psk" {
  for_each = var.vpn_connections

  compartment_id = var.compartment_ocid
  vault_id       = oci_kms_vault.this.id
  key_id         = oci_kms_key.this.id
  secret_name    = "vpn-${each.key}-tunnel1-psk-${var.environment}"

  secret_content {
    content_type = "BASE64"
    content      = base64encode(oci_core_ipsec_connection_tunnel_management.tunnel1[each.key].shared_secret)
  }

  description = "IPSec PSK for ${each.key} tunnel 1"

  freeform_tags = {
    "VPN"         = each.key
    "Tunnel"      = "1"
    "Environment" = var.environment
  }
}

resource "oci_vault_secret" "tunnel2_psk" {
  for_each = var.vpn_connections

  compartment_id = var.compartment_ocid
  vault_id       = oci_kms_vault.this.id
  key_id         = oci_kms_key.this.id
  secret_name    = "vpn-${each.key}-tunnel2-psk-${var.environment}"

  secret_content {
    content_type = "BASE64"
    content      = base64encode(oci_core_ipsec_connection_tunnel_management.tunnel2[each.key].shared_secret)
  }

  description = "IPSec PSK for ${each.key} tunnel 2"

  freeform_tags = {
    "VPN"         = each.key
    "Tunnel"      = "2"
    "Environment" = var.environment
  }
}
