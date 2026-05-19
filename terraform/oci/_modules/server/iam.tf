# Instance principal access for k3s join-token fetch.
#
# Dynamic group: matches every instance in `var.compartment_ocid` (which
# is the target compartment for this module instantiation, not necessarily
# the prod one). Broad on purpose — the compartment is tightly controlled,
# and a narrower defined-tag match would mean creating a defined-tag
# namespace just for this. If new unrelated VMs land in the compartment
# they'd also gain read on the secret; revisit if that becomes a real risk.
#
# IAM policy: grants this dynamic group `read` on the specific node-token
# secret only (scoped via `where target.secret.id = ...`). Dynamic groups
# live at the tenancy root so the policy does too.
#
# Both resources are gated on the *same* agent-mode condition that the
# instance precondition uses (k3s_url AND k3s_token_secret_ocid both set).
# Otherwise terraform would create tenancy-wide IAM resources even in
# standalone-server mode where they're unused, and an "accidentally set
# the OCID but not the URL" apply would leave them behind.

locals {
  agent_mode = var.k3s_url != "" && var.k3s_token_secret_ocid != ""
}

resource "oci_identity_dynamic_group" "k3s_servers" {
  count = local.agent_mode ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "k3s-${var.environment}-servers"
  description    = "All ${var.environment} k3s server instances in compartment ${var.compartment_ocid}; grants Vault read for the k3s node-token"
  matching_rule  = "instance.compartment.id = '${var.compartment_ocid}'"
}

resource "oci_identity_policy" "k3s_servers_vault_read" {
  count = local.agent_mode ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "k3s-${var.environment}-servers-vault-read"
  description    = "Allow ${var.environment} k3s server instances to read the k3s node-token from OCI Vault (instance principal auth)"

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.k3s_servers[0].name} to read secret-bundles in tenancy where target.secret.id = '${var.k3s_token_secret_ocid}'"
  ]
}
