# ============================================================================
# Remote-access VPN: IPsec dial-up (FortiClient), users authenticated via Google
# Workspace SAML. IPsec dial-up (not SSL-VPN) because SSL-VPN tunnel mode is
# removed/constrained on 2GB-RAM models (the 40F) in recent FortiOS.
#
# mode-config assigns clients an IP from the per-unit pool and pushes split
# routes. The gateway authenticates with a PSK; the USER authenticates via SAML
# (IKEv2 EAP). NOTE: the exact SAML-over-IPsec knobs (eap/authusrgrp + the SP
# URLs) vary by FortiOS version — validate against your build before apply.
# ============================================================================

locals {
  # key (fgt1/fgt2) => its remote_access object. Iterate THIS map of objects (not
  # its keyset) so each.value is the remote_access config (pool_start/end/etc.);
  # each.key is still the FortiGate key for the provider + var.fortigates lookups.
  ra_fgts = {
    for fk, f in var.fortigates : fk => f.remote_access
    if f.remote_access != null && try(f.remote_access.enabled, true)
  }
}

# --- Google Workspace as a SAML IdP ----------------------------------------
resource "fortios_user_saml" "google" {
  for_each = local.ra_fgts
  provider = fortios.by_fortigate[each.key]

  name                   = "google"
  cert                   = var.saml_idp.sp_cert
  idp_entity_id          = var.saml_idp.idp_entity_id
  idp_single_sign_on_url = var.saml_idp.idp_sso_url
  idp_single_logout_url  = var.saml_idp.idp_slo_url
  idp_cert               = var.saml_idp.idp_cert_name
  user_name              = var.saml_idp.user_name_field
  group_name             = var.saml_idp.group_name

  # SP (FortiGate) endpoints — adjust to the real VPN FQDN/cert when live.
  entity_id          = "https://${var.fortigates[each.key].hostname}/remote/saml/metadata"
  single_sign_on_url = "https://${var.fortigates[each.key].hostname}:1024/remote/saml/login"
  single_logout_url  = "https://${var.fortigates[each.key].hostname}:1024/remote/saml/logout"
}

resource "fortios_user_group" "vpn_saml" {
  for_each = local.ra_fgts
  provider = fortios.by_fortigate[each.key]

  name = "vpn-saml"
  member {
    name = fortios_user_saml.google[each.key].name
  }
}

# --- Address objects: the client pool + the split-tunnel subnet -------------
resource "fortios_firewall_address" "ra_pool" {
  for_each = local.ra_fgts
  provider = fortios.by_fortigate[each.key]

  name     = "ra-pool"
  type     = "iprange"
  start_ip = each.value.pool_start
  end_ip   = each.value.pool_end
  comment  = local.marker
}

resource "fortios_firewall_address" "ra_split" {
  for_each = local.ra_fgts
  provider = fortios.by_fortigate[each.key]

  name    = "ra-split"
  type    = "ipmask"
  subnet  = "${cidrhost(each.value.split_include, 0)} ${cidrnetmask(each.value.split_include)}"
  comment = local.marker
}

# --- IPsec dial-up phase 1 (IKEv2 + mode-config + SAML/EAP) -----------------
resource "fortios_vpnipsec_phase1interface" "dialup" {
  for_each = local.ra_fgts
  provider = fortios.by_fortigate[each.key]

  name        = "ra-dialup"
  type        = "dynamic"
  interface   = var.fortigates[each.key].ports.wan
  ike_version = "2"
  peertype    = "any"
  net_device  = "disable"
  proposal    = "aes256-sha256"
  dhgrp       = "14"
  psksecret   = lookup(var.fortigate_remote_access_psks, each.key, "")

  # SAML user auth over IKEv2 EAP.
  eap          = "enable"
  eap_identity = "send-request"
  authusrgrp   = fortios_user_group.vpn_saml[each.key].name

  # mode-config: assign client IP + push DNS and split route.
  mode_cfg           = "enable"
  assign_ip          = "enable"
  ipv4_start_ip      = each.value.pool_start
  ipv4_end_ip        = each.value.pool_end
  ipv4_netmask       = each.value.pool_netmask
  ipv4_dns_server1   = each.value.client_dns
  ipv4_split_include = fortios_firewall_address.ra_split[each.key].name

  comments = "${local.marker} — remote-access dial-up (Google SAML)"

  lifecycle {
    precondition {
      condition     = length(lookup(var.fortigate_remote_access_psks, each.key, "")) >= 16
      error_message = "Remote-access PSK for ${each.key} must be set (>=16 chars); an empty PSK would stand up an open IKE dial-up gateway. Source it from OCI Vault."
    }
  }
}

resource "fortios_vpnipsec_phase2interface" "dialup" {
  for_each = local.ra_fgts
  provider = fortios.by_fortigate[each.key]

  name       = "ra-dialup-p2"
  phase1name = fortios_vpnipsec_phase1interface.dialup[each.key].name
  proposal   = "aes256-sha256"
  src_subnet = "0.0.0.0 0.0.0.0"
  dst_subnet = "0.0.0.0 0.0.0.0"
}

# --- Policy: remote-access clients -> trusted VLAN (SAML group gated) -------
resource "fortios_firewall_policy" "ra_to_trusted" {
  for_each = local.ra_fgts
  provider = fortios.by_fortigate[each.key]

  policyid = 310
  name     = "ra-to-trusted"
  srcintf { name = fortios_vpnipsec_phase1interface.dialup[each.key].name }
  dstintf { name = fortios_system_interface.vlan["${each.key}/${local.trusted_vlan_name[each.key]}"].name }
  srcaddr { name = fortios_firewall_address.ra_pool[each.key].name }
  dstaddr { name = "all" }
  service { name = "ALL" }
  groups { name = fortios_user_group.vpn_saml[each.key].name }
  action     = "accept"
  schedule   = "always"
  nat        = "disable"
  logtraffic = "all"
}
