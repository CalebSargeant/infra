include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform/oci/_modules/vpn"
}

locals {
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
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
    # Sargeant on-prem MikroTik
    sargeant_onprem = {
      peer_ip             = "77.169.18.35"
      cpe_device_shape_id = null  # Generic/Other
      type                = "mikrotik"
      static_routes       = ["192.168.19.0/24"]
      routing_type        = "STATIC"
      ike_version         = "V2"
      # PSKs will be auto-generated and stored in OCI Vault
      shared_secret_tunnel1 = null
      shared_secret_tunnel2 = null
    }

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
