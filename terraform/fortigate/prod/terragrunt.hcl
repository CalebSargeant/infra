# Self-contained terragrunt config for the two home-lab FortiGate 40Fs.
# Deliberately does NOT include terraform/root.hcl: root.hcl generates a
# google + oci provider.tf that's irrelevant here and would force a fake
# cloud "region"/"environment" dir layout onto physical edge kit. We keep
# state in the same bucket as everything else and let the module own the
# fortios provider (see modules/fortigate/fortios_provider.tf).
remote_state {
  backend = "gcs"
  config = {
    bucket   = "sargeant-prod-terraform-state"
    prefix   = "fortigate/prod"
    project  = "magmamoose-terraform"
    location = "europe-west4"
  }
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "gcs" {}
}
EOF
}

terraform {
  source = "${get_repo_root()}/terraform/fortigate/modules/fortigate"
}

# ---------------------------------------------------------------------------
# Credentials
#
# The hardware isn't wired/provisioned yet, so there are no API tokens to fetch.
# For now the management hosts + tokens come from env vars (empty by default) so
# `terragrunt validate`/parse succeeds — a `plan`/`apply` will only fail later
# at provider-connect time, once you point it at real, reachable units.
#
# WHEN THE UNITS ARE LIVE — switch to the repo-standard OCI Vault pattern
# (same as oci/mikrotik): create one REST-API admin token per FortiGate
# (`config system api-user`), store each in vault-prod, and replace the
# get_env() defaults below with run_cmd() lookups, e.g.:
#
#   locals {
#     fgt1_token_secret_ocid = "ocid1.vaultsecret.oc1.eu-amsterdam-1.<...>"
#     fgt1_token = run_cmd("--terragrunt-quiet", "bash", "-c",
#       "oci secrets secret-bundle get --secret-id ${local.fgt1_token_secret_ocid} --region eu-amsterdam-1 --query 'data.\"secret-bundle-content\".content' --raw-output | base64 -d")
#   }
#
# NOTE: API tokens are plaintext-equivalent secrets — never inline a real one
# in this PUBLIC repo. OCI Vault first; rotate immediately if leaked.
# ---------------------------------------------------------------------------
locals {
  fgt1_token = get_env("FORTIGATE_FGT1_TOKEN", "")
  fgt2_token = get_env("FORTIGATE_FGT2_TOKEN", "")

  # OCI IPsec PSKs (one per FortiGate, shared with the OCI IPSecConnection).
  # When live: store in OCI Vault and swap to run_cmd, OR read straight from the
  # oci/vpn-fortigate module's psk_secret_ids. Empty default keeps parse working.
  fgt1_oci_psk = get_env("FORTIGATE_FGT1_OCI_PSK", "")
  fgt2_oci_psk = get_env("FORTIGATE_FGT2_OCI_PSK", "")
}

inputs = {
  fortigate_insecure = true # 40Fs ship a self-signed mgmt cert

  fortigate_tokens = {
    fgt1 = local.fgt1_token
    fgt2 = local.fgt2_token
  }

  # Shared with the OCI side (terraform/oci/.../vpn-fortigate).
  fortigate_oci_vpn_psks = {
    fgt1 = local.fgt1_oci_psk
    fgt2 = local.fgt2_oci_psk
  }

  # --- Topology (PLACEHOLDER addressing — edit to your real scheme) ----------
  # Interconnect /30s + cross-link /30s share 10.255.255.0/24:
  #   FGT1<->FGT2 : 10.255.255.0/30  (FGT1 .1, FGT2 .2)
  #   FGT2<->MT1  : 10.255.255.4/30  (FGT2 .5)   [cross-link]
  #   FGT1<->MT2  : 10.255.255.8/30  (FGT1 .9)   [cross-link]
  # Client space per site: 10.<site>.<vlanid>.0/24, summarised as a /16 for
  # east-west routing. Site1 = 10.10.0.0/16, Site2 = 10.20.0.0/16.
  # VLANs: 10 trusted, 20 iot, 30 guest, 99 mgmt.
  fortigates = {
    fgt1 = {
      hostname = get_env("FORTIGATE_FGT1_HOST", "192.168.1.99") # 40F default mgmt IP
      vlans = {
        trusted = { id = 10, ip = "10.10.10.1", dhcp_start = "10.10.10.100", dhcp_end = "10.10.10.200", trusted = true }
        iot     = { id = 20, ip = "10.10.20.1", dhcp_start = "10.10.20.100", dhcp_end = "10.10.20.200" }
        guest   = { id = 30, ip = "10.10.30.1", dhcp_start = "10.10.30.100", dhcp_end = "10.10.30.200" }
        mgmt    = { id = 99, ip = "10.10.99.1", dhcp_start = "10.10.99.100", dhcp_end = "10.10.99.200" }
      }
      interconnect = {
        ip      = "10.255.255.1"
        peer_ip = "10.255.255.2"
      }
      crosslink       = { ip = "10.255.255.9" } # to MikroTik2
      peer_lan_subnet = "10.20.0.0/16"          # Site2 supernet

      # OCI tunnel public IPs come from the oci/vpn-fortigate `tunnel_ips`
      # output (fortigate1). Placeholders (TEST-NET-1) until the OCI side exists.
      oci_vpn = {
        local_subnet = "10.10.0.0/16"
        tunnels = [
          { name = "oci-t1", remote_gw = get_env("FORTIGATE_FGT1_OCI_T1", "192.0.2.1") },
          { name = "oci-t2", remote_gw = get_env("FORTIGATE_FGT1_OCI_T2", "192.0.2.2") },
        ]
      }
    }

    fgt2 = {
      hostname = get_env("FORTIGATE_FGT2_HOST", "192.168.1.98")
      vlans = {
        trusted = { id = 10, ip = "10.20.10.1", dhcp_start = "10.20.10.100", dhcp_end = "10.20.10.200", trusted = true }
        iot     = { id = 20, ip = "10.20.20.1", dhcp_start = "10.20.20.100", dhcp_end = "10.20.20.200" }
        guest   = { id = 30, ip = "10.20.30.1", dhcp_start = "10.20.30.100", dhcp_end = "10.20.30.200" }
        mgmt    = { id = 99, ip = "10.20.99.1", dhcp_start = "10.20.99.100", dhcp_end = "10.20.99.200" }
      }
      interconnect = {
        ip      = "10.255.255.2"
        peer_ip = "10.255.255.1"
      }
      crosslink       = { ip = "10.255.255.5" } # to MikroTik1
      peer_lan_subnet = "10.10.0.0/16"          # Site1 supernet

      oci_vpn = {
        local_subnet = "10.20.0.0/16"
        tunnels = [
          { name = "oci-t1", remote_gw = get_env("FORTIGATE_FGT2_OCI_T1", "192.0.2.3") },
          { name = "oci-t2", remote_gw = get_env("FORTIGATE_FGT2_OCI_T2", "192.0.2.4") },
        ]
      }
    }
  }
}
