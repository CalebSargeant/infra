output "db_system_id" {
  description = "OCID of the MySQL DB System"
  value       = oci_mysql_mysql_db_system.this.id
}

output "db_system_display_name" {
  description = "Display name of the MySQL DB System"
  value       = oci_mysql_mysql_db_system.this.display_name
}

output "db_system_state" {
  description = "Current state of the MySQL DB System"
  value       = oci_mysql_mysql_db_system.this.state
}

output "db_system_endpoints" {
  description = "Endpoints of the MySQL DB System"
  value       = oci_mysql_mysql_db_system.this.endpoints
}

output "db_system_hostname" {
  description = "Hostname of the MySQL DB System"
  value       = oci_mysql_mysql_db_system.this.hostname_label
}

output "db_system_ip_address" {
  description = "IP address of the MySQL DB System"
  value       = oci_mysql_mysql_db_system.this.ip_address
}

output "db_system_port" {
  description = "MySQL port"
  value       = oci_mysql_mysql_db_system.this.port
}

output "db_system_port_x" {
  description = "MySQL X Protocol port"
  value       = oci_mysql_mysql_db_system.this.port_x
}

output "db_system_mysql_version" {
  description = "MySQL version"
  value       = oci_mysql_mysql_db_system.this.mysql_version
}

output "db_system_shape" {
  description = "MySQL DB System shape"
  value       = oci_mysql_mysql_db_system.this.shape_name
}

output "db_system_availability_domain" {
  description = "Availability domain of the MySQL DB System"
  value       = oci_mysql_mysql_db_system.this.availability_domain
}

output "db_system_fault_domain" {
  description = "Fault domain of the MySQL DB System"
  value       = oci_mysql_mysql_db_system.this.fault_domain
}

output "connection_string" {
  description = "MySQL connection string"
  value       = "mysql://${var.admin_username}@${oci_mysql_mysql_db_system.this.ip_address}:${oci_mysql_mysql_db_system.this.port}"
}

output "replication_channel_ids" {
  description = "Map of replication channel OCIDs"
  value = {
    for k, v in oci_mysql_channel.this : k => v.id
  }
}
