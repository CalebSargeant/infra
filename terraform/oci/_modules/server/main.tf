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
      echo "k3s install starting at $(date)"

      # Three modes:
      #   k3s_url + k3s_token  -> install as agent joining the cluster
      #   k3s_url empty        -> install as a standalone k3s server
      #   k3s_url set, token empty -> blocked by the resource precondition
      if [ -n "${var.k3s_url}" ]; then
        echo "agent mode: joining ${var.k3s_url}"
        curl -sfL https://get.k3s.io | \
          INSTALL_K3S_EXEC="agent" \
          K3S_URL="${var.k3s_url}" \
          K3S_TOKEN="${var.k3s_token}" \
          sh -
        echo "k3s-agent service installed at $(date); will retry connection to ${var.k3s_url} until reachable"
      else
        echo "server mode: standalone k3s control plane"
        curl -sfL https://get.k3s.io | sh -
        mkdir -p /home/ubuntu/.kube
        cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
        chown -R ubuntu:ubuntu /home/ubuntu/.kube
        chmod 600 /home/ubuntu/.kube/config
        echo "k3s server installed at $(date)"
      fi
    EOF
    )
  }

  freeform_tags = {
    "Environment" = var.environment
    "Role"        = "k3s-${var.k3s_url == "" ? "server" : "agent"}"
    "ManagedBy"   = "Terraform"
  }

  # Prevent recreation on image changes
  lifecycle {
    ignore_changes = [
      source_details[0].source_id,
      metadata["user_data"]
    ]

    precondition {
      condition     = var.k3s_url == "" || length(var.k3s_token) > 0
      error_message = "k3s_token must be set when k3s_url is configured, otherwise cloud-init will install k3s-agent with an empty token and silently fail to join. Run: export K3S_TOKEN=$(ssh firefly \"sudo cat /var/lib/rancher/k3s/server/node-token\")"
    }
  }
}
