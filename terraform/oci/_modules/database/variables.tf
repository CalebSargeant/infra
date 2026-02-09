variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, dev)"
  type        = string
}

variable "subnet_id" {
  description = "OCID of the subnet for the MySQL instance"
  type        = string
}

variable "shape_name" {
  description = "MySQL DB System shape name"
  type        = string
  default     = "MySQL.Free" # Free tier shape
}

variable "data_storage_size_in_gb" {
  description = "Data storage size in GB"
  type        = number
  default     = 50 # Free tier includes 50GB
}

variable "admin_username" {
  description = "MySQL admin username"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "MySQL admin password"
  type        = string
  sensitive   = true
}

variable "mysql_version" {
  description = "MySQL version"
  type        = string
  default     = "8.0.36" # Latest stable version
}

variable "backup_enabled" {
  description = "Enable automatic backups"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "backup_window_start_time" {
  description = "Backup window start time (UTC)"
  type        = string
  default     = "02:00"
}

variable "maintenance_window_start_time" {
  description = "Maintenance window start time (format: day HH:MM)"
  type        = string
  default     = "SUNDAY 03:00"
}

variable "fault_domain" {
  description = "Fault domain index (0, 1, or 2)"
  type        = number
  default     = 0
}

variable "deletion_automatic_backup_retention" {
  description = "Retain automatic backups on deletion"
  type        = string
  default     = "DELETE"
}

variable "deletion_final_backup" {
  description = "Create final backup on deletion"
  type        = string
  default     = "SKIP_FINAL_BACKUP"
}

variable "is_delete_protected" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "crash_recovery" {
  description = "Crash recovery mode: ENABLED or DISABLED"
  type        = string
  default     = "ENABLED"
}

variable "replication_channels" {
  description = "Map of replication channels for MySQL"
  type = map(object({
    is_enabled              = bool
    source_type             = string
    source_hostname         = string
    source_port             = number
    source_username         = string
    source_password         = string
    ssl_mode                = string
    target_applier_username = optional(string)
  }))
  default = {}
}
