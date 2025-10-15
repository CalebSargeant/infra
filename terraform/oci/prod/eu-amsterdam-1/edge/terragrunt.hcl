include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform/oci/_modules/edge"
}

locals {
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  tenancy_ocid            = get_env("OCI_TENANCY_OCID", "")
  user_ocid               = get_env("OCI_USER_OCID", "")
  fingerprint             = get_env("OCI_FINGERPRINT", "")
  private_key_path        = get_env("OCI_PRIVATE_KEY_PATH", "")
  compartment_ocid        = get_env("OCI_COMPARTMENT_OCID", "")
  region                  = local.region_vars.locals.region
  environment             = local.environment_vars.locals.environment
  shape                   = "VM.Standard.E2.1.Micro"
  subnet_id               = dependency.network.outputs.subnet_id
  network_security_group_id = dependency.network.outputs.network_security_group_id
  ssh_public_key_path     = "${get_repo_root()}/ansible/keys/id_rsa.pub"
  vcn_id                  = dependency.network.outputs.vcn_id
  # Oracle Linux 8 for x86 - will be used as base for MikroTik CHR installation
  image_ocid              = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaaf6i6b6t7eedgqku6a2whieyfeeit3wl4l366meurvkc4btc4tgha"
  
  # Create two MikroTik CHR instances, one per fault domain
  fault_domains = {
    "fd1" = { fault_domain = 0 }  # Fault Domain 1
    "fd2" = { fault_domain = 1 }  # Fault Domain 2
  }
}
