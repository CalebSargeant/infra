# OCI side of the site-to-site VPN to the two on-prem FortiGate 40Fs. Reuses the
# existing oci/modules/vpn (managed OCI Site-to-Site VPN: CPE + IPSecConnection
# + two tunnels per connection on the shared DRG).
#
# Kept as a SEPARATE leaf from ../vpn (which terminates the MikroTik CHR tunnel)
# so it can carry autoplan=false while the FortiGates aren't reachable, without
# destabilising the live MikroTik tunnel's plans.
#
# ── Heads-up when going live ───────────────────────────────────────────────
#  - peer_ip = each FortiGate's WAN public IP, and the PSKs, are unknown until
#    the units are online. They're env-var placeholders here; switch to OCI
#    Vault (run_cmd) like ../vpn does, and use the SAME PSK value as the
#    FortiGate side (terraform/fortigate/prod: fortigate_oci_vpn_psks).
#  - The OCI tunnel public IPs this creates (output `tunnel_ips`) feed back into
#    the FortiGate side as remote_gw.
#  - oci/modules/vpn provisions its OWN KMS vault for PSK storage, so applying
#    this leaf creates a second vault. If you'd rather reuse ../vpn's vault,
#    fold these two connections into ../vpn/terragrunt.hcl instead when live.
#  - Add 10.10.0.0/16 and 10.20.0.0/16 to `remote_networks` in ../network so the
#    VCN route tables send return traffic for the FortiGate sites to the DRG.
include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform/oci/modules/vpn"
}

locals {
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  # FortiGate WAN public IPs (placeholders — TEST-NET-1). Override via env until
  # they live in OCI Vault.
  fgt1_wan_ip = get_env("FORTIGATE_FGT1_WAN_IP", "192.0.2.10")
  fgt2_wan_ip = get_env("FORTIGATE_FGT2_WAN_IP", "192.0.2.11")

  # PSK per FortiGate — MUST match terraform/fortigate/prod fortigate_oci_vpn_psks.
  fgt1_psk = get_env("FORTIGATE_FGT1_OCI_PSK", "")
  fgt2_psk = get_env("FORTIGATE_FGT2_OCI_PSK", "")
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    drg_id = "mock-drg-id"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  tenancy_ocid     = get_env("OCI_TENANCY_OCID", "")
  compartment_ocid = get_env("OCI_COMPARTMENT_OCID", "")
  region           = local.region_vars.locals.region
  environment      = local.environment_vars.locals.environment

  drg_id = dependency.network.outputs.drg_id

  # OCI VCN advertised to the FortiGates.
  local_networks = ["192.168.223.0/24"]

  # One IPSec connection per FortiGate. STATIC routing: each advertises its own
  # site /16 (which summarises that site's VLAN subnets 10.<site>.<vlan>.0/24).
  vpn_connections = {
    fortigate1 = {
      peer_ip               = local.fgt1_wan_ip
      cpe_device_shape_id   = null
      type                  = "other"
      static_routes         = ["10.10.0.0/16"]
      routing_type          = "STATIC"
      ike_version           = "V2"
      shared_secret_tunnel1 = local.fgt1_psk != "" ? local.fgt1_psk : null
      shared_secret_tunnel2 = local.fgt1_psk != "" ? local.fgt1_psk : null
    }

    fortigate2 = {
      peer_ip               = local.fgt2_wan_ip
      cpe_device_shape_id   = null
      type                  = "other"
      static_routes         = ["10.20.0.0/16"]
      routing_type          = "STATIC"
      ike_version           = "V2"
      shared_secret_tunnel1 = local.fgt2_psk != "" ? local.fgt2_psk : null
      shared_secret_tunnel2 = local.fgt2_psk != "" ? local.fgt2_psk : null
    }
  }
}
