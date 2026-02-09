# OCI DRG Remote Peering Module
# Creates Remote Peering Connection (RPC) for region-to-region connectivity

# Create Remote Peering Connection (RPC) in this region
resource "oci_core_remote_peering_connection" "this" {
  compartment_id = var.compartment_ocid
  drg_id         = var.drg_id
  display_name   = "rpc-${var.peer_region}-${var.environment}"

  # Freeform tags
  freeform_tags = {
    "Environment" = var.environment
    "PeerRegion"  = var.peer_region
    "Managed-By"  = "terraform"
  }
}
