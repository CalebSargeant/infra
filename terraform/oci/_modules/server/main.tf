# k3s instances on the OCI ARM64 free tier, placed in the app subnet.
#
# Two modes:
#   k3s_url + k3s_token_secret_ocid set  -> install as agent joining the cluster
#   both empty                          -> install as standalone k3s server
#
# The join token is *not* baked into instance metadata. The agent-mode
# cloud-init script uses instance principal auth to fetch the token from
# OCI Vault at boot. Permission to read that specific secret is granted
# by the dynamic group + IAM policy in iam.tf.

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Hash of the inputs that *meaningfully* change cloud-init outcome —
# k3s_url, the secret OCID it should fetch (in agent mode), and the base
# image. Cosmetic script tweaks don't change the hash so don't recreate
# VMs. Bump `version` below to force a one-off replacement when you do
# edit the install script meaningfully (e.g. new cloud-init step).
#
# k3s_token_secret_ocid is folded out in server mode (k3s_url == "")
# because the OCID isn't read — pointing it at a different Vault secret
# shouldn't rebuild standalone-server VMs that ignore it.
resource "terraform_data" "user_data_replace_trigger" {
  for_each = var.servers

  input = sha256(jsonencode({
    k3s_url               = var.k3s_url
    k3s_token_secret_ocid = var.k3s_url == "" ? "" : var.k3s_token_secret_ocid
    image                 = var.image_ocid
    version               = 1
  }))
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
      set -e
      echo "k3s install starting at $(date)"

      if [ -n "${var.k3s_url}" ]; then
        echo "agent mode: will join ${var.k3s_url}"

        # Fetch the node-token from OCI Vault via instance principal.
        # oci-cli's `--auth instance_principal` flag uses the metadata
        # service to acquire a short-lived JWT from OCI's auth service
        # and signs subsequent API calls — no static credentials, no
        # token in instance metadata.
        #
        # pip on Ubuntu 22.04 doesn't recognise `--break-system-packages`
        # (introduced when PEP 668 marked external installs); only 23.04+
        # ships pip new enough. Detect the flag and add it only when
        # supported so the script works across image versions.
        echo "installing oci-cli..."
        apt-get update -qq
        apt-get install -y -qq python3-pip
        PIP_ARGS="--quiet"
        if pip3 install --help 2>&1 | grep -q break-system-packages; then
          PIP_ARGS="$PIP_ARGS --break-system-packages"
        fi
        pip3 install $PIP_ARGS oci-cli

        echo "fetching k3s token from OCI Vault (instance principal)..."
        for attempt in 1 2 3 4 5; do
          K3S_TOKEN_VALUE=$(oci secrets secret-bundle get \
            --secret-id ${var.k3s_token_secret_ocid} \
            --region ${var.region} \
            --auth instance_principal \
            --query 'data."secret-bundle-content".content' \
            --raw-output 2>/var/log/oci-secret-fetch.log | base64 -d || true)
          if [ -n "$K3S_TOKEN_VALUE" ]; then break; fi
          echo "attempt $attempt failed; retrying in 10s..."
          sleep 10
        done

        if [ -z "$K3S_TOKEN_VALUE" ]; then
          echo "ERROR: couldn't fetch k3s token from Vault after 5 tries. See /var/log/oci-secret-fetch.log."
          exit 1
        fi
        echo "token fetched (len=$${#K3S_TOKEN_VALUE})"

        curl -sfL https://get.k3s.io | \
          INSTALL_K3S_EXEC="agent" \
          K3S_URL="${var.k3s_url}" \
          K3S_TOKEN="$K3S_TOKEN_VALUE" \
          sh -

        echo "k3s-agent service installed at $(date); will retry connection until ${var.k3s_url} is reachable"
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

  lifecycle {
    # source_details: don't fight image version drift if the OCI image gets republished.
    # metadata.user_data: cosmetic script tweaks shouldn't replace VMs.
    # Meaningful changes (k3s_url / k3s_token_secret_ocid / image) propagate
    # via replace_triggered_by on the user_data_replace_trigger hash.
    ignore_changes = [
      source_details[0].source_id,
      metadata["user_data"]
    ]

    replace_triggered_by = [
      terraform_data.user_data_replace_trigger[each.key],
    ]

    precondition {
      condition     = (var.k3s_url == "" && var.k3s_token_secret_ocid == "") || (var.k3s_url != "" && var.k3s_token_secret_ocid != "")
      error_message = "k3s_url and k3s_token_secret_ocid must be set together (agent mode) or both empty (standalone server mode). Setting one without the other is silently broken."
    }
  }

  depends_on = [
    # Make sure the dynamic group + IAM policy exist before the VM boots and
    # tries to fetch the secret. IAM eventual consistency means a freshly
    # created instance might still fail the first fetch — that's why the
    # cloud-init has a 5-attempt retry with backoff.
    oci_identity_policy.k3s_servers_vault_read,
  ]
}
