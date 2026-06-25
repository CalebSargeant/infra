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

  # FG1 (Sargeant House, Venray) WAN public IP is recon-grade — it reveals the
  # operator's residential ISP/location, so (like ../vpn) it's sourced from OCI
  # Vault `infra-recon-blockers` (vault-prod) and never inlined in this PUBLIC
  # repo. Fetched at parse time via the operator's ~/.oci/config.
  recon_blockers_secret_ocid = "ocid1.vaultsecret.oc1.eu-amsterdam-1.amaaaaaa4ebs56aa7mytuezgibzn4g36jxupsgy57zl4372uq47atgfra2ka"
  # Direct `oci` call + base64decode in HCL (no `bash -c`) so this parses on
  # Windows/PowerShell, which has no bash. Pattern: cloudflare/zero-trust/prod.
  recon_blockers = jsondecode(base64decode(trimspace(run_cmd(
    "--terragrunt-quiet",
    "oci", "secrets", "secret-bundle", "get",
    "--secret-id", local.recon_blockers_secret_ocid,
    "--region", "eu-amsterdam-1",
    "--query", "data.\"secret-bundle-content\".content",
    "--raw-output"
  ))))
  fgt1_wan_ip = local.recon_blockers.vpn_peers.home_wan_peer_ip

  # FG2 is behind Starlink CGNAT — its public IPv4 is DYNAMIC. OCI requires an
  # IPv4 CPE, so we pin FG2's current egress IP here (sourced from the recon
  # vault, never inlined). FRAGILE: when Starlink reassigns FG2's public
  # IP, update `vpn_peers.fg2_starlink_public_ip` in the recon vault and re-apply
  # (the CPE ip_address is immutable, so the apply recreates the CPE + connection).
  fgt2_wan_ip = local.recon_blockers.vpn_peers.fg2_starlink_public_ip

  # PSK per FortiGate — null lets OCI auto-generate and store in the module vault;
  # read back to configure the FortiGate side. (No PSK inlined in this PUBLIC repo.)
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

  # One IPSec connection per FortiGate, BGP-routed. The BGP inside IPs (/30 per
  # tunnel) MUST match the FortiGate side (terraform/fortigate/prod oci_vpn
  # tunnels: bgp_customer_ip / bgp_oracle_ip). Customer ASN = the FortiGate ASN.
  #   FGT1 (AS 65010): 169.254.22.0/24   FGT2 (AS 65020): 169.254.23.0/24
  vpn_connections = {
    fortigate1 = {
      peer_ip             = local.fgt1_wan_ip
      cpe_device_shape_id = null
      type                = "other"
      # OCI requires >=1 static route even for BGP tunnels (it's ignored while the
      # tunnels run routing=BGP). Listed = the on-prem nets reachable behind FG1/FG2.
      static_routes           = ["192.168.19.0/24", "192.168.99.0/24", "192.168.220.0/23"]
      routing_type            = "BGP"
      ike_version             = "V2"
      bgp_asn                 = 65010
      bgp_oracle_ip_tunnel1   = "169.254.22.1/30"
      bgp_customer_ip_tunnel1 = "169.254.22.2/30"
      bgp_oracle_ip_tunnel2   = "169.254.22.5/30"
      bgp_customer_ip_tunnel2 = "169.254.22.6/30"
      shared_secret_tunnel1   = local.fgt1_psk != "" ? local.fgt1_psk : null
      shared_secret_tunnel2   = local.fgt1_psk != "" ? local.fgt1_psk : null
    }

    # FG2 (Starlink) — CGNAT IPv4 CPE; FG2 is the sole initiator (OCI can't reach a
    # CGNAT'd peer, so oracle-initiation is forced RESPONDER_ONLY out-of-band).
    fortigate2 = {
      peer_ip                 = local.fgt2_wan_ip
      cpe_device_shape_id     = null
      type                    = "other"
      static_routes           = ["192.168.99.0/24", "192.168.19.0/24", "192.168.220.0/23"]
      routing_type            = "BGP"
      ike_version             = "V2"
      bgp_asn                 = 65020
      bgp_oracle_ip_tunnel1   = "169.254.23.1/30"
      bgp_customer_ip_tunnel1 = "169.254.23.2/30"
      bgp_oracle_ip_tunnel2   = "169.254.23.5/30"
      bgp_customer_ip_tunnel2 = "169.254.23.6/30"
      shared_secret_tunnel1   = local.fgt2_psk != "" ? local.fgt2_psk : null
      shared_secret_tunnel2   = local.fgt2_psk != "" ? local.fgt2_psk : null
    }
  }
}
