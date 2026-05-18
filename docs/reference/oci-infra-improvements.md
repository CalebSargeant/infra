# OCI Infrastructure Improvement Backlog

Companion to [cloudflare-ztna-improvements.md](./cloudflare-ztna-improvements.md).
Captured during PR #199 (k3s agent join + OCI VCN internet egress via
MikroTik). None blocking; ranked roughly by impact × effort.

## 1. Move k3s join token out of OCI instance metadata

[terraform/oci/_modules/server/main.tf](../../terraform/oci/_modules/server/main.tf)
interpolates `var.k3s_token` directly into the cloud-init user_data heredoc.
That value ends up base64-encoded in OCI instance metadata for the life of
the instance — anyone with `instance:read` on the compartment can decode
it, and rotating the cluster token won't propagate to existing nodes (the
lifecycle ignores `metadata["user_data"]`).

Better pattern:

1. Grant the OCI dynamic group containing these instances `read` on the
   `node-token` secret in `vault-prod`.
2. Replace the inline token in user_data with a small script that fetches
   from OCI Vault using the instance principal:
   ```bash
   TOKEN=$(curl -s -H "Authorization: Bearer $(curl -s http://169.254.169.254/opc/v2/instance/) " \
     "https://secrets.vaults.<region>.oci.oraclecloud.com/.../bundle" | jq -r ...)
   curl -sfL https://get.k3s.io | K3S_URL=... K3S_TOKEN="$TOKEN" sh -
   ```
3. Token rotation then becomes: update the vault secret, the next k3s-agent
   restart picks it up (with a tiny systemd ExecStartPre hook).

## 2. Make k3s install script changes propagate to existing instances

[terraform/oci/_modules/server/main.tf](../../terraform/oci/_modules/server/main.tf)'s
`lifecycle.ignore_changes = [metadata["user_data"]]` is currently load-bearing
— without it, every cosmetic tweak to the install script would force-replace
both VMs. But it also means any *meaningful* install-script fix (extra
cloud-init steps to recover stalled joins, a new sysctl, etc.) silently
no-ops on existing nodes; the operator has to remember to destroy+apply
manually.

Two reasonable approaches, pick one:

- Drop `metadata["user_data"]` from `ignore_changes` and live with the
  recreation-on-cosmetic-change blast radius. Acceptable for stateless k3s
  agents that re-register automatically.
- Add a `replace_triggered_by = [terraform_data.user_data_meaningful_hash]`
  where the hash covers only the inputs you genuinely want to force
  replacement on (k3s_url, k3s_token, INSTALL_K3S_EXEC). Cosmetic shell
  tweaks then no-op, but real config changes recreate.

## 3. HA: route OCI VCN egress via both MikroTiks, not just r1

[terraform/oci/prod/eu-amsterdam-1/network/terragrunt.hcl](../../terraform/oci/prod/eu-amsterdam-1/network/terragrunt.hcl)'s
`internet_gateway_ip = "192.168.223.11"` hard-codes mikrotik-fd1 as the
single next-hop for app+data subnets. If r1 fails, both subnets lose
internet egress even though r2 exists, is configured identically for
masquerade, and is in the same subnet. OCI route tables can only hold one
default route per RT, so true HA needs VRRP (or similar) on the MikroTiks
to present a shared virtual IP, then point the OCI route at that VIP.

Concretely:
- Configure VRRP between r1+r2 with a virtual address in `192.168.223.0/26`.
- Change `internet_gateway_ip` to that virtual IP.
- Confirm `skip-source-dest-check = true` on the VRRP IP's owning VNIC at
  any given time.

## 4. Migrate `api://...:8728` to `apis://...:8729` (TLS-wrapped binary API)

The routeros provider currently talks plaintext binary API on 8728. The
existing TODO in
[mikrotik/terragrunt.hcl](../../terraform/oci/prod/eu-amsterdam-1/mikrotik/terragrunt.hcl)
captures this. Once cert is sorted, switch to 8729 + TLS, then drop the
`routeros_api_management_cidrs` ingress rule on the edge security list
(currently the only thing preventing 8728 from being closed to the
internet).
