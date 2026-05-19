# This instance will be a Mikrotik CHR using OCI free tier x86 machine
# The instance will directly flash the CHR image to disk during provisioning

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# `assign_public_ip = true` allocates an ephemeral public IP (re-allocated on
# instance recreate; new value). `assign_public_ip = false` + a separate
# `oci_core_public_ip` with `lifetime = "RESERVED"` keeps the IP stable
# across recreates — see var.use_reserved_public_ips. Flipping the variable
# is a one-off cutover: the ephemeral is released and a new reserved IP is
# allocated, so the public IP value WILL change at that apply (DNS catches
# up via cloudflare/dns/prod's dependency on this module's outputs).
resource "oci_core_instance" "this" {
  for_each = var.fault_domains

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.environment}-mikrotik-chr-${each.key}"
  shape               = var.shape
  fault_domain        = "FAULT-DOMAIN-${each.value.fault_domain + 1}"

  create_vnic_details {
    subnet_id              = var.subnet_id
    assign_public_ip       = !var.use_reserved_public_ips
    nsg_ids                = [var.network_security_group_id]
    skip_source_dest_check = true
    private_ip             = each.value.private_ip
  }

  source_details {
    source_type = "image"
    source_id   = var.image_ocid
  }
}

# Reserved public IP resources, one per instance, only when the operator
# opts in. Looked up via the instance's primary VNIC → primary private IP
# (OCI requires a private-IP OCID, not the IP string, for the attachment).
# The two data sources are also gated on the variable so the default
# `false` path doesn't run unnecessary API queries.
data "oci_core_vnic_attachments" "primary" {
  for_each = var.use_reserved_public_ips ? oci_core_instance.this : {}

  compartment_id = var.compartment_ocid
  instance_id    = each.value.id
}

data "oci_core_private_ips" "primary" {
  for_each = var.use_reserved_public_ips ? oci_core_instance.this : {}

  vnic_id = data.oci_core_vnic_attachments.primary[each.key].vnic_attachments[0].vnic_id
}

resource "oci_core_public_ip" "reserved" {
  for_each = var.use_reserved_public_ips ? oci_core_instance.this : {}

  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "${var.environment}-edge-${each.key}-reserved-ip"
  private_ip_id  = data.oci_core_private_ips.primary[each.key].private_ips[0].id

  freeform_tags = {
    "Environment" = var.environment
    "Role"        = "edge-mikrotik-chr"
    "ManagedBy"   = "Terraform"
  }
}