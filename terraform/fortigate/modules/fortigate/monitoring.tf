# ============================================================================
# Visibility + automation (all base-license).
#   - remote syslog + NetFlow export to a collector
#   - an automation stitch (reboot -> webhook notification) as a template
# Each block self-disables when its target var is empty.
# ============================================================================

locals {
  syslog_keys     = var.syslog.server != "" ? local.keys : toset([])
  netflow_keys    = var.netflow.collector_ip != "" ? local.keys : toset([])
  automation_keys = var.automation_webhook_url != "" ? local.keys : toset([])
}

# --- Remote syslog ---------------------------------------------------------
resource "fortios_logsyslogd_setting" "this" {
  for_each = local.syslog_keys
  provider = fortios.by_fortigate[each.key]

  status    = "enable"
  server    = var.syslog.server
  port      = var.syslog.port
  mode      = var.syslog.mode
  facility  = var.syslog.facility
  source_ip = var.syslog.source_ip
}

# --- NetFlow export --------------------------------------------------------
resource "fortios_system_netflow" "this" {
  for_each = local.netflow_keys
  provider = fortios.by_fortigate[each.key]

  collector_ip   = var.netflow.collector_ip
  collector_port = var.netflow.collector_port
  source_ip      = var.netflow.source_ip
}

# --- Automation: reboot -> webhook (template; clone for more events) --------
resource "fortios_system_automationaction" "webhook_notify" {
  for_each = local.automation_keys
  provider = fortios.by_fortigate[each.key]

  name        = "webhook-notify"
  action_type = "webhook"
  protocol    = "https"
  method      = "post"
  uri         = var.automation_webhook_url
  port        = 443
}

resource "fortios_system_automationtrigger" "reboot" {
  for_each = local.automation_keys
  provider = fortios.by_fortigate[each.key]

  name         = "reboot-trigger"
  trigger_type = "event-based"
  event_type   = "reboot"
}

resource "fortios_system_automationstitch" "reboot_notify" {
  for_each = local.automation_keys
  provider = fortios.by_fortigate[each.key]

  name    = "reboot-notify"
  status  = "enable"
  trigger = fortios_system_automationtrigger.reboot[each.key].name

  actions {
    id       = 1
    action   = fortios_system_automationaction.webhook_notify[each.key].name
    required = "enable"
  }
}
