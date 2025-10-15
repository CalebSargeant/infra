include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform/oci/_modules/server"
}

locals {
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

dependency "network" {
  config_path = "../network"
}

dependency "edge" {
  config_path = "../edge"
}

inputs = {
  tenancy_ocid            = get_env("OCI_TENANCY_OCID", "")
  compartment_ocid        = get_env("OCI_COMPARTMENT_OCID", "")
  region                  = local.region_vars.locals.region
  environment             = local.environment_vars.locals.environment
  shape                   = "VM.Standard.A1.Flex"
  ocpus                   = 2   # 2 OCPUs as requested
  memory_in_gbs           = 12  # 12GB memory as requested
  subnet_id               = dependency.network.outputs.subnet_id
  network_security_group_id = dependency.network.outputs.network_security_group_id
  ssh_public_key_path     = "${get_repo_root()}/ansible/keys/id_rsa.pub"
  # Oracle Linux 8 for ARM
  image_ocid              = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaahc3kbflujx4g536l4yuzzy7udc6ltwlbt7iqbkt33i6zx62yy7va"
  vcn_id                  = dependency.network.outputs.vcn_id
  
  # Pass edge instances from dependency
  edge_instances          = dependency.edge.outputs.instances
  
  # Create two production servers, one per fault domain, each routing through its corresponding edge
  servers = {
    "fd1" = {
      fault_domain     = 0                  # Fault Domain 1
      subnet_cidr      = "172.17.1.0/24"    # FD1 subnet
      edge_instance_key = "fd1"             # Route through edge-fd1
    }
    "fd2" = {
      fault_domain     = 1                  # Fault Domain 2
      subnet_cidr      = "172.17.2.0/24"    # FD2 subnet
      edge_instance_key = "fd2"             # Route through edge-fd2
    }
  }
}
