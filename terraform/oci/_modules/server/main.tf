# This instance will be a k3s instance using the ARM64 free tier OCI

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Look up the private IP OCID for each edge instance
data "oci_core_private_ips" "edge_private_ip" {
  for_each = { for k, v in var.servers : k => v if var.edge_instances[v.edge_instance_key].private_ip != "" }
  
  ip_address = var.edge_instances[each.value.edge_instance_key].private_ip
  subnet_id  = var.subnet_id
}

### Create the server subnet for each server with edge routing
resource "oci_core_route_table" "edge_router" {
  for_each = var.servers
  
  compartment_id = var.compartment_ocid
  display_name   = "rt-server-${var.environment}-${each.key}"
  vcn_id         = var.vcn_id

  # Route all traffic through the corresponding edge CHR
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.edge_private_ip[each.key].private_ips[0].id
  }
}

resource "oci_core_subnet" "this" {
  for_each = var.servers
  
  compartment_id    = var.compartment_ocid
  vcn_id            = var.vcn_id
  display_name      = "subnet-server-${var.environment}-${each.key}"
  cidr_block        = each.value.subnet_cidr
  route_table_id    = oci_core_route_table.edge_router[each.key].id
  dns_label         = "server${each.key}"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_instance" "this" {
  for_each = var.servers
  
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.environment}-prod-server-${each.key}"
  shape               = var.shape
  fault_domain        = "FAULT-DOMAIN-${each.value.fault_domain + 1}"

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.this[each.key].id
    assign_public_ip = false
    nsg_ids          = [var.network_security_group_id]
  }

  source_details {
    source_type = "image"
    source_id   = var.image_ocid
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data = base64encode(<<-EOF
      #!/bin/bash
      # Install k3s
      curl -sfL https://get.k3s.io | sh -
      # Allow current user to access k3s config
      mkdir -p /home/ubuntu/.kube
      cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
      chown -R ubuntu:ubuntu /home/ubuntu/.kube
      # Set correct permissions
      chmod 600 /home/ubuntu/.kube/config
    EOF
    )
  }
}
