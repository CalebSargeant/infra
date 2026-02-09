output "vcn_id" {
  description = "ID of the Virtual Cloud Network"
  value       = oci_core_virtual_network.this.id
}

output "vcn_cidr_blocks" {
  description = "CIDR blocks of the VCN"
  value       = oci_core_virtual_network.this.cidr_blocks
}

# Subnet IDs
output "edge_subnet_id" {
  description = "ID of the edge subnet"
  value       = oci_core_subnet.edge.id
}

output "app_subnet_id" {
  description = "ID of the app subnet"
  value       = oci_core_subnet.app.id
}

output "data_subnet_id" {
  description = "ID of the data subnet"
  value       = oci_core_subnet.data.id
}

output "spare_subnet_id" {
  description = "ID of the spare subnet"
  value       = oci_core_subnet.spare.id
}

# Subnet CIDRs
output "edge_subnet_cidr" {
  description = "CIDR of the edge subnet"
  value       = oci_core_subnet.edge.cidr_block
}

output "app_subnet_cidr" {
  description = "CIDR of the app subnet"
  value       = oci_core_subnet.app.cidr_block
}

output "data_subnet_cidr" {
  description = "CIDR of the data subnet"
  value       = oci_core_subnet.data.cidr_block
}

output "spare_subnet_cidr" {
  description = "CIDR of the spare subnet"
  value       = oci_core_subnet.spare.cidr_block
}

# Route Table IDs
output "edge_route_table_id" {
  description = "ID of the edge route table"
  value       = oci_core_route_table.edge.id
}

output "app_route_table_id" {
  description = "ID of the app route table"
  value       = oci_core_route_table.app.id
}

output "data_route_table_id" {
  description = "ID of the data route table"
  value       = oci_core_route_table.data.id
}

# Security List IDs
output "edge_security_list_id" {
  description = "ID of the edge security list"
  value       = oci_core_security_list.edge.id
}

output "app_security_list_id" {
  description = "ID of the app security list"
  value       = oci_core_security_list.app.id
}

output "data_security_list_id" {
  description = "ID of the data security list"
  value       = oci_core_security_list.data.id
}

# Network Security Group
output "network_security_group_id" {
  description = "ID of the Network Security Group"
  value       = oci_core_network_security_group.this.id
}

# DRG outputs (for VPN module)
output "drg_id" {
  description = "ID of the Dynamic Routing Gateway (null if VPN disabled)"
  value       = var.enable_vpn ? oci_core_drg.this[0].id : null
}

output "drg_attachment_id" {
  description = "ID of the DRG attachment (null if VPN disabled)"
  value       = var.enable_vpn ? oci_core_drg_attachment.this[0].id : null
}

# Internet Gateway
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = oci_core_internet_gateway.this.id
}

# SSH Key
output "ssh_public_key" {
  description = "SSH public key used for instances"
  value       = file(var.ssh_public_key_path)
}

# Backwards compatibility aliases
output "subnet_id" {
  description = "ID of the edge subnet (backwards compatibility)"
  value       = oci_core_subnet.edge.id
}

output "network_id" {
  description = "ID of the Virtual Cloud Network (alias for vcn_id)"
  value       = oci_core_virtual_network.this.id
}

output "ssh_key" {
  description = "SSH public key used for instances (alias for ssh_public_key)"
  value       = file(var.ssh_public_key_path)
}