# OCI Database Module
# Creates MySQL HeatWave DB System (HeatWave cluster disabled for free tier)

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# MySQL DB System
resource "oci_mysql_mysql_db_system" "this" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  display_name = "mysql-${var.environment}"
  description  = "MySQL HeatWave DB System for ${var.environment}"

  # Shape configuration
  shape_name = var.shape_name

  # Storage configuration
  data_storage_size_in_gb = var.data_storage_size_in_gb

  # Network configuration
  subnet_id = var.subnet_id

  # Security
  admin_username = var.admin_username
  admin_password = var.admin_password

  # Backup configuration
  backup_policy {
    is_enabled        = var.backup_enabled
    retention_in_days = var.backup_retention_days
    window_start_time = var.backup_window_start_time
  }

  # Maintenance configuration
  maintenance {
    window_start_time = var.maintenance_window_start_time
  }

  # MySQL configuration
  mysql_version = var.mysql_version

  # Note: HeatWave cluster is not attached by default (free tier)
  # is_heat_wave_cluster_attached is a computed attribute

  # Deletion protection
  deletion_policy {
    automatic_backup_retention = var.deletion_automatic_backup_retention
    final_backup               = var.deletion_final_backup
    is_delete_protected        = var.is_delete_protected
  }

  # Fault domain
  fault_domain = "FAULT-DOMAIN-${var.fault_domain + 1}"

  # Hostname
  hostname_label = "mysql${var.environment}"

  # Port
  port   = 3306
  port_x = 33060

  # High availability (disabled for free tier)
  is_highly_available = false

  # Crash recovery
  crash_recovery = var.crash_recovery

  # Freeform tags
  freeform_tags = {
    "Environment" = var.environment
    "Managed-By"  = "terraform"
  }

  lifecycle {
    # Prevent accidental deletion
    prevent_destroy = false # Set to true in production

    # Ignore password changes (managed externally)
    ignore_changes = [
      admin_password
    ]
  }
}

# MySQL channels for replication (optional)
resource "oci_mysql_channel" "this" {
  for_each = var.replication_channels

  compartment_id = var.compartment_ocid
  display_name   = "channel-${each.key}-${var.environment}"
  is_enabled     = each.value.is_enabled

  source {
    source_type = each.value.source_type
    hostname    = each.value.source_hostname
    port        = each.value.source_port
    username    = each.value.source_username
    password    = each.value.source_password
    ssl_mode    = each.value.ssl_mode
  }

  target {
    target_type    = "DBSYSTEM"
    db_system_id   = oci_mysql_mysql_db_system.this.id
    applier_username = each.value.target_applier_username
  }
}
