# Two home-lab MikroTik CRS switches (one behind each FortiGate). The routeros
# provider is iterated per switch with for_each (OpenTofu 1.9+) so every
# resource is declared once and applied to both — same pattern as the FortiGate
# module and the oci/mikrotik module.
#
# Uses the binary API (api://host:8728): challenge-response auth keeps the
# password off the wire even though the session itself isn't TLS-wrapped — same
# reasoning as oci/modules/mikrotik.
provider "routeros" {
  alias    = "by_router"
  for_each = var.mikrotiks

  hosturl  = each.value.hosturl
  username = var.routeros_username
  password = var.routeros_password
  insecure = var.routeros_insecure
}
