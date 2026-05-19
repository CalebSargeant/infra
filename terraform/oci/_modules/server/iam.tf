# Instance principal access for k3s join-token fetch.
#
# Dynamic group: matches every instance in the prod compartment. Broad on
# purpose — the compartment is tightly controlled, and a narrower defined-tag
# match would mean creating a defined-tag namespace just for this. If new
# unrelated VMs land in the compartment they'd also gain read on the secret;
# revisit if that becomes a real risk.
#
# IAM policy: grants this dynamic group `read` on the specific node-token
# secret only (scoped via `where target.secret.id = ...`). Dynamic groups
# live at the tenancy root so the policy does too.

resource "oci_identity_dynamic_group" "k3s_servers" {
  count = var.k3s_token_secret_ocid != "" ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "k3s-${var.environment}-servers"
  description    = "All ${var.environment} k3s server instances; grants Vault read for the k3s node-token"
  matching_rule  = "instance.compartment.id = '${var.compartment_ocid}'"
}

resource "oci_identity_policy" "k3s_servers_vault_read" {
  count = var.k3s_token_secret_ocid != "" ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "k3s-${var.environment}-servers-vault-read"
  description    = "Allow ${var.environment} k3s server instances to read the k3s node-token from OCI Vault (instance principal auth)"

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.k3s_servers[0].name} to read secret-bundles in tenancy where target.secret.id = '${var.k3s_token_secret_ocid}'"
  ]
}
