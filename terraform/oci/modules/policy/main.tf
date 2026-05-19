# Create OCI policies to allow instance creation

resource "oci_identity_policy" "instance_policy" {
  name           = "AllowInstanceCreation"
  description    = "Allow instance creation in the tenancy"
  compartment_id = var.tenancy_ocid
  statements     = [
    "Allow service compute to use all-resources in tenancy",
    "Allow group Administrators to manage instance-family in tenancy",
    "Allow group Administrators to manage virtual-network-family in tenancy",
    "Allow group Administrators to manage volume-family in tenancy"
  ]
}
