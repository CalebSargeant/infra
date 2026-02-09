include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/terraform/oci/_modules/database"
}

locals {
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    data_subnet_id = "mock-data-subnet-id"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  tenancy_ocid     = get_env("OCI_TENANCY_OCID", "")
  compartment_ocid = get_env("OCI_COMPARTMENT_OCID", "")
  region           = local.region_vars.locals.region
  environment      = local.environment_vars.locals.environment

  # Use data subnet from network module
  subnet_id = dependency.network.outputs.data_subnet_id

  # MySQL configuration
  shape_name              = "MySQL.Free"  # Free tier shape
  data_storage_size_in_gb = 50            # Free tier includes 50GB
  mysql_version           = "9.6.0"

  # Admin credentials - use environment variable or SOPS
  admin_username = "admin"
  admin_password = get_env("OCI_MYSQL_ADMIN_PASSWORD", "ChangeMe123!")

  # Backup configuration
  backup_enabled           = false
  backup_retention_days    = 7
  backup_window_start_time = "02:00"

  # Maintenance window (Sunday 3 AM UTC)
  maintenance_window_start_time = "SUNDAY 03:00"

  # Fault domain
  fault_domain = 0  # FD-1

  # Deletion protection (set to true in production)
  is_delete_protected = false

  # Crash recovery
  crash_recovery = "ENABLED"
}
