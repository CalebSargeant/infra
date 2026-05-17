# This instance will be a k3s instance using the ARM64 free tier OCI
# Servers are placed in the app subnet from the network module

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

resource "oci_core_instance" "this" {
  for_each = var.servers
  
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.environment}-server-${each.key}"
  shape               = var.shape
  fault_domain        = "FAULT-DOMAIN-${each.value.fault_domain + 1}"

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = false
    nsg_ids          = [var.network_security_group_id]
    hostname_label   = "server-${each.key}"
    private_ip       = each.value.private_ip
  }

  source_details {
    source_type = "image"
    source_id   = var.image_ocid
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data = base64encode(<<-EOF
      #!/bin/bash
      exec > /var/log/k3s-install.log 2>&1
      echo "Starting k3s agent install at $(date)"
      curl -sfL https://get.k3s.io | \
        INSTALL_K3S_EXEC="agent" \
        K3S_URL="${var.k3s_url}" \
        K3S_TOKEN="${var.k3s_token}" \
        sh -
      echo "k3s-agent service installed at $(date); will retry connection to ${var.k3s_url} until reachable"
    EOF
    )
  }

  # Prevent recreation on image changes
  lifecycle {
    ignore_changes = [
      source_details[0].source_id,
      metadata["user_data"]
    ]
  }
}
