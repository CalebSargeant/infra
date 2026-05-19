output "vault_id" {
  description = "OCID of the VPN secrets vault"
  value       = oci_kms_vault.this.id
}

output "vault_management_endpoint" {
  description = "Management endpoint of the vault"
  value       = oci_kms_vault.this.management_endpoint
}

output "key_id" {
  description = "OCID of the master encryption key"
  value       = oci_kms_key.this.id
}

output "cpe_ids" {
  description = "Map of CPE OCIDs"
  value = {
    for k, v in oci_core_cpe.this : k => v.id
  }
}

output "ipsec_connection_ids" {
  description = "Map of IPSec connection OCIDs"
  value = {
    for k, v in oci_core_ipsec.this : k => v.id
  }
}

output "tunnel_details" {
  description = "Details of IPSec tunnels for each connection"
  value = {
    for k, v in var.vpn_connections : k => {
      tunnel1 = {
        id         = data.oci_core_ipsec_connection_tunnels.this[k].ip_sec_connection_tunnels[0].id
        vpn_ip     = data.oci_core_ipsec_connection_tunnels.this[k].ip_sec_connection_tunnels[0].vpn_ip
        status     = data.oci_core_ipsec_connection_tunnels.this[k].ip_sec_connection_tunnels[0].status
        psk_secret = oci_vault_secret.tunnel1_psk[k].id
      }
      tunnel2 = {
        id         = data.oci_core_ipsec_connection_tunnels.this[k].ip_sec_connection_tunnels[1].id
        vpn_ip     = data.oci_core_ipsec_connection_tunnels.this[k].ip_sec_connection_tunnels[1].vpn_ip
        status     = data.oci_core_ipsec_connection_tunnels.this[k].ip_sec_connection_tunnels[1].status
        psk_secret = oci_vault_secret.tunnel2_psk[k].id
      }
    }
  }
}

output "tunnel_ips" {
  description = "OCI tunnel public IPs for each connection (for configuring remote peers)"
  value = {
    for k, v in var.vpn_connections : k => {
      tunnel1_ip = data.oci_core_ipsec_connection_tunnels.this[k].ip_sec_connection_tunnels[0].vpn_ip
      tunnel2_ip = data.oci_core_ipsec_connection_tunnels.this[k].ip_sec_connection_tunnels[1].vpn_ip
    }
  }
}

output "psk_secret_ids" {
  description = "Vault secret OCIDs for PSKs (retrieve with OCI CLI or Vault API)"
  value = {
    for k, v in var.vpn_connections : k => {
      tunnel1_psk_secret_id = oci_vault_secret.tunnel1_psk[k].id
      tunnel2_psk_secret_id = oci_vault_secret.tunnel2_psk[k].id
    }
  }
  sensitive = true
}
