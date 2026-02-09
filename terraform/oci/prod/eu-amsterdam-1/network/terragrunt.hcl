include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform/oci/_modules/network"
}

locals {
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

inputs = {
  tenancy_ocid        = get_env("OCI_TENANCY_OCID", "")
  user_ocid           = get_env("OCI_USER_OCID", "")
  fingerprint         = get_env("OCI_FINGERPRINT", "")
  private_key_path    = get_env("OCI_PRIVATE_KEY_PATH", "")
  region              = local.region_vars.locals.region
  compartment_ocid    = get_env("OCI_COMPARTMENT_OCID", "")
  environment         = local.environment_vars.locals.environment
  ssh_public_key_path = "${get_repo_root()}/ansible/keys/id_rsa.pub"

  # VCN CIDR - using 192.168.223.0/24 split into 4x /26 subnets
  vcn_cidr_blocks = ["192.168.223.0/24"]

  # Subnet configuration
  subnets = {
    edge = {
      cidr = "192.168.223.0/26"    # .1-.62 for edge/routers (public)
    }
    app = {
      cidr = "192.168.223.64/26"   # .65-.126 for app/workload (private)
    }
    data = {
      cidr = "192.168.223.128/26"  # .129-.190 for database (private)
    }
    spare = {
      cidr = "192.168.223.192/26"  # .193-.254 reserved (private)
    }
  }

  # Enable VPN for site-to-site connectivity
  enable_vpn = true

  # Remote networks accessible via VPN
  remote_networks = {
    sargeant_onprem = {
      cidr        = "192.168.19.0/24"
      description = "Sargeant on-prem network (MikroTik)"
    }
    franklinhouse_oci = {
      cidr        = "192.168.72.0/24"
      description = "FranklinHouse OCI Johannesburg (DRG peering)"
    }
    # AWS network - uncomment when AWS VPN is configured
    # aws_af_south_1 = {
    #   cidr        = "10.0.0.0/16"  # Update with actual AWS VPC CIDR
    #   description = "AWS af-south-1 VPC"
    # }
  }
}
