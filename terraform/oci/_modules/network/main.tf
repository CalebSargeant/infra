resource "oci_core_virtual_network" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "vcn-${var.environment}"
  cidr_blocks    = var.vcn_cidr_blocks
  dns_label      = "vcn${var.environment}"
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "ig-${var.environment}"
  vcn_id         = oci_core_virtual_network.this.id
  enabled        = true
}

# Dynamic Routing Gateway for VPN connectivity
resource "oci_core_drg" "this" {
  count          = var.enable_vpn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "drg-${var.environment}"
}

resource "oci_core_drg_attachment" "this" {
  count        = var.enable_vpn ? 1 : 0
  drg_id       = oci_core_drg.this[0].id
  display_name = "drg-attachment-${var.environment}"

  network_details {
    id   = oci_core_virtual_network.this.id
    type = "VCN"
  }
}

# Edge Subnet - Public subnet for edge/router instances (e.g., MikroTik CHR)
resource "oci_core_subnet" "edge" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.this.id
  display_name               = "subnet-edge-${var.environment}"
  cidr_block                 = var.subnets.edge.cidr
  route_table_id             = oci_core_route_table.edge.id
  dns_label                  = "edge"
  prohibit_public_ip_on_vnic = false
  security_list_ids          = [oci_core_security_list.edge.id]
}

# App Subnet - Private subnet for application/workload instances
resource "oci_core_subnet" "app" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.this.id
  display_name               = "subnet-app-${var.environment}"
  cidr_block                 = var.subnets.app.cidr
  route_table_id             = oci_core_route_table.app.id
  dns_label                  = "app"
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_security_list.app.id]
}

# Data Subnet - Private subnet for database instances
resource "oci_core_subnet" "data" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.this.id
  display_name               = "subnet-data-${var.environment}"
  cidr_block                 = var.subnets.data.cidr
  route_table_id             = oci_core_route_table.data.id
  dns_label                  = "data"
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_security_list.data.id]
}

# Spare Subnet - Reserved for future use
resource "oci_core_subnet" "spare" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.this.id
  display_name               = "subnet-spare-${var.environment}"
  cidr_block                 = var.subnets.spare.cidr
  route_table_id             = oci_core_route_table.spare.id
  dns_label                  = "spare"
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_security_list.spare.id]
}

# Route Tables
resource "oci_core_route_table" "edge" {
  compartment_id = var.compartment_ocid
  display_name   = "rt-edge-${var.environment}"
  vcn_id         = oci_core_virtual_network.this.id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }

  # VPN routes to remote networks
  dynamic "route_rules" {
    for_each = var.enable_vpn ? var.remote_networks : {}
    content {
      destination       = route_rules.value.cidr
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.this[0].id
      description       = route_rules.value.description
    }
  }
}

resource "oci_core_route_table" "app" {
  compartment_id = var.compartment_ocid
  display_name   = "rt-app-${var.environment}"
  vcn_id         = oci_core_virtual_network.this.id

  # VPN routes to remote networks
  dynamic "route_rules" {
    for_each = var.enable_vpn ? var.remote_networks : {}
    content {
      destination       = route_rules.value.cidr
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.this[0].id
      description       = route_rules.value.description
    }
  }
}

resource "oci_core_route_table" "data" {
  compartment_id = var.compartment_ocid
  display_name   = "rt-data-${var.environment}"
  vcn_id         = oci_core_virtual_network.this.id

  # VPN routes to remote networks
  dynamic "route_rules" {
    for_each = var.enable_vpn ? var.remote_networks : {}
    content {
      destination       = route_rules.value.cidr
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.this[0].id
      description       = route_rules.value.description
    }
  }
}

resource "oci_core_route_table" "spare" {
  compartment_id = var.compartment_ocid
  display_name   = "rt-spare-${var.environment}"
  vcn_id         = oci_core_virtual_network.this.id

  # VPN routes to remote networks
  dynamic "route_rules" {
    for_each = var.enable_vpn ? var.remote_networks : {}
    content {
      destination       = route_rules.value.cidr
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.this[0].id
      description       = route_rules.value.description
    }
  }
}

# Security Lists
resource "oci_core_security_list" "edge" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.this.id
  display_name   = "sl-edge-${var.environment}"

  # Allow all egress
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # SSH
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # HTTP
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  # HTTPS
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # WireGuard
  ingress_security_rules {
    protocol = "17" # UDP
    source   = "0.0.0.0/0"
    udp_options {
      min = 51820
      max = 51820
    }
  }

  # IPSec IKE
  ingress_security_rules {
    protocol = "17" # UDP
    source   = "0.0.0.0/0"
    udp_options {
      min = 500
      max = 500
    }
  }

  # IPSec NAT-T
  ingress_security_rules {
    protocol = "17" # UDP
    source   = "0.0.0.0/0"
    udp_options {
      min = 4500
      max = 4500
    }
  }

  # MikroTik Winbox
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 8291
      max = 8291
    }
  }

  # ICMP
  ingress_security_rules {
    protocol = 1 # ICMP
    source   = "0.0.0.0/0"
    icmp_options {
      type = 8 # Echo request
    }
  }

  # Allow all from VCN
  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_cidr_blocks[0]
  }

  # Allow all from remote networks (VPN)
  dynamic "ingress_security_rules" {
    for_each = var.remote_networks
    content {
      protocol = "all"
      source   = ingress_security_rules.value.cidr
    }
  }
}

resource "oci_core_security_list" "app" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.this.id
  display_name   = "sl-app-${var.environment}"

  # Allow all egress
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # SSH from edge subnet
  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.subnets.edge.cidr
    tcp_options {
      min = 22
      max = 22
    }
  }

  # K3s API
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  # HTTP/HTTPS from edge
  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.subnets.edge.cidr
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.subnets.edge.cidr
    tcp_options {
      min = 443
      max = 443
    }
  }

  # ICMP from VCN
  ingress_security_rules {
    protocol = 1 # ICMP
    source   = var.vcn_cidr_blocks[0]
    icmp_options {
      type = 8 # Echo request
    }
  }

  # Allow all from VCN
  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_cidr_blocks[0]
  }

  # Allow all from remote networks (VPN)
  dynamic "ingress_security_rules" {
    for_each = var.remote_networks
    content {
      protocol = "all"
      source   = ingress_security_rules.value.cidr
    }
  }
}

resource "oci_core_security_list" "data" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.this.id
  display_name   = "sl-data-${var.environment}"

  # Allow all egress
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # MySQL from app subnet
  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.subnets.app.cidr
    tcp_options {
      min = 3306
      max = 3306
    }
  }

  # MySQL from edge subnet (for management)
  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.subnets.edge.cidr
    tcp_options {
      min = 3306
      max = 3306
    }
  }

  # SSH from edge subnet
  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.subnets.edge.cidr
    tcp_options {
      min = 22
      max = 22
    }
  }

  # ICMP from VCN
  ingress_security_rules {
    protocol = 1 # ICMP
    source   = var.vcn_cidr_blocks[0]
    icmp_options {
      type = 8 # Echo request
    }
  }

  # Allow all from remote networks (VPN) - for database replication/access
  dynamic "ingress_security_rules" {
    for_each = var.remote_networks
    content {
      protocol = "6" # TCP
      source   = ingress_security_rules.value.cidr
      tcp_options {
        min = 3306
        max = 3306
      }
    }
  }
}

resource "oci_core_security_list" "spare" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.this.id
  display_name   = "sl-spare-${var.environment}"

  # Allow all egress
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # SSH from edge subnet
  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.subnets.edge.cidr
    tcp_options {
      min = 22
      max = 22
    }
  }

  # ICMP from VCN
  ingress_security_rules {
    protocol = 1 # ICMP
    source   = var.vcn_cidr_blocks[0]
    icmp_options {
      type = 8 # Echo request
    }
  }
}

# Network Security Group (for instances that need additional controls)
resource "oci_core_network_security_group" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.this.id
  display_name   = "nsg-${var.environment}"
}

# NSG Rules
resource "oci_core_network_security_group_security_rule" "ssh" {
  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "http" {
  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "https" {
  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "k3s_api" {
  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "egress_all" {
  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}
