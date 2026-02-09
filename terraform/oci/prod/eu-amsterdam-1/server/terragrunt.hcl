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

  mock_outputs = {
    app_subnet_id             = "mock-app-subnet-id"
    network_security_group_id = "mock-nsg-id"
    vcn_id                    = "mock-vcn-id"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  tenancy_ocid            = get_env("OCI_TENANCY_OCID", "")
  compartment_ocid        = get_env("OCI_COMPARTMENT_OCID", "")
  region                  = local.region_vars.locals.region
  environment             = local.environment_vars.locals.environment
  shape                   = "VM.Standard.A1.Flex"
  ocpus                   = 2   # 2 OCPUs per server
  memory_in_gbs           = 12  # 12GB memory per server

  # Use app subnet from network module
  subnet_id               = dependency.network.outputs.app_subnet_id
  network_security_group_id = dependency.network.outputs.network_security_group_id
  ssh_public_key_path     = "${get_repo_root()}/ansible/keys/id_rsa.pub"
  vcn_id                  = dependency.network.outputs.vcn_id
  
  # Ubuntu 22.04 for ARM
  image_ocid              = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaahc3kbflujx4g536l4yuzzy7udc6ltwlbt7iqbkt33i6zx62yy7va"

  # Create two servers, one per fault domain
  servers = {
    "fd1" = { fault_domain = 0, private_ip = "192.168.223.71" }  # Fault Domain 1
    "fd2" = { fault_domain = 1, private_ip = "192.168.223.72" }  # Fault Domain 2
  }
}
