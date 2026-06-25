include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform/oci/modules/vpn"
}

locals {
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  # The on-prem peer WAN IP is recon-grade (reveals the operator's residential
  # ISP and home location) and lives in OCI Vault as `infra-recon-blockers`
  # (vault-prod). Fetched at parse time using the operator's ~/.oci/config.
  recon_blockers_secret_ocid = "ocid1.vaultsecret.oc1.eu-amsterdam-1.amaaaaaa4ebs56aa7mytuezgibzn4g36jxupsgy57zl4372uq47atgfra2ka"

  recon_blockers = jsondecode(run_cmd(
    "--terragrunt-quiet",
    "bash", "-c",
    "oci secrets secret-bundle get --secret-id ${local.recon_blockers_secret_ocid} --region eu-amsterdam-1 --query 'data.\"secret-bundle-content\".content' --raw-output | base64 -d"
  ))

  home_wan_peer_ip = local.recon_blockers.vpn_peers.home_wan_peer_ip
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

  # DRG from network module
  drg_id = dependency.network.outputs.drg_id

  # Local networks to advertise over VPN
  local_networks = ["192.168.223.0/24"]

  # VPN connections
  vpn_connections = {
    # sargeant_onprem (MikroTik CHR @ home) DECOMMISSIONED 2026-06: the home edge
    # is now the FortiGate, which terminates OCI directly via the per-FortiGate
    # design in ../vpn-fortigate (fortigate1, same home WAN peer IP). The old
    # connection only collided on that shared CPE IP, so it was removed.
    # sargeant_onprem = {
    #   peer_ip             = local.home_wan_peer_ip
    #   cpe_device_shape_id = null  # Generic/Other
    #   type                = "mikrotik"
    #   static_routes       = ["192.168.19.0/24"]
    #   routing_type        = "BGP"
    #   ike_version         = "V2"
    #   bgp_asn                  = 65001
    #   bgp_customer_ip_tunnel1  = "169.254.21.2/30"
    #   bgp_oracle_ip_tunnel1    = "169.254.21.1/30"
    #   bgp_customer_ip_tunnel2  = "169.254.21.6/30"
    #   bgp_oracle_ip_tunnel2    = "169.254.21.5/30"
    #   shared_secret_tunnel1 = null
    #   shared_secret_tunnel2 = null
    # }

    # AWS af-south-1 - uncomment when AWS VPN Gateway is deployed
    # aws_af_south_1 = {
    #   peer_ip             = "x.x.x.x"  # AWS VPN Gateway public IP
    #   cpe_device_shape_id = null       # Will use AWS-specific shape
    #   type                = "aws"
    #   static_routes       = ["10.0.0.0/16"]  # AWS VPC CIDR
    #   routing_type        = "STATIC"         # Or "BGP" if using BGP
    #   ike_version         = "V2"
    #   bgp_asn             = 64512            # AWS default ASN (if BGP)
    #   shared_secret_tunnel1 = null
    #   shared_secret_tunnel2 = null
    # }
  }
}
