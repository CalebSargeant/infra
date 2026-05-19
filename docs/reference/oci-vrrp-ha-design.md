# OCI MikroTik HA via VRRP + Floating Private IP — design doc

Status: **Design — not implemented.** This doc captures the approach for
resolving `oci-infra-improvements.md` #3. Implementation lands in a
follow-up PR after this design is agreed.

## Problem

[`terraform/oci/prod/eu-amsterdam-1/network/terragrunt.hcl`](../../terraform/oci/prod/eu-amsterdam-1/network/terragrunt.hcl)
hard-codes:

```hcl
internet_gateway_ip = "192.168.223.11"
```

which becomes the next-hop OCID for the `0.0.0.0/0` default route on
both the **app** and **data** subnets of the prod VCN. That IP belongs
to **r1** (mikrotik-fd1) specifically. If r1 dies — VM stops, NIC fails,
container deadlocks, RouterOS panics — **both subnets lose internet
egress immediately** even though r2 is healthy in the same subnet
running identical config, because nothing repoints the OCI route.

Single point of failure on a deliberately-redundant pair.

## Goal

When r1 fails, internet egress for the app + data subnets should
automatically fail over to r2 without operator intervention. Recovery
to the original master on r1's return is fine (pre-emption is OK in
this topology — no asymmetric WAN cost).

Target failover detection + reconvergence: **under 30 seconds**.

## Why OCI makes this non-trivial

OCI's VCN networking is SDN — there's no shared L2 between VNICs. A
classic VRRP setup where master broadcasts a gratuitous ARP for the
virtual IP and clients learn the new MAC doesn't work; OCI ignores the
ARP and keeps routing by VNIC ownership.

Three options worth considering, in increasing order of fit:

### Option A — ECMP across two equal default routes

Add two `0.0.0.0/0` routes pointing at r1's and r2's private IPs.
OCI's intent: split traffic 50/50.

**Not viable.** OCI route tables enforce **destination uniqueness**:
you can't have two route rules with the same destination. The terraform
apply errors at validation. ECMP isn't a thing on OCI route tables.

### Option B — BGP between MikroTiks and DRG

Each MikroTik peers BGP with the DRG and announces a default route.
DRG picks the active announcer; if r1's session drops, r2 wins.

**Possible but heavy.** Requires the DRG to be in BGP mode rather than
the current static-routing mode (and our existing VPN tunnels to AWS
peer ASNs would need rethinking). Operationally adds another moving
part. Skip for now — revisit only if VRRP + VNIC-failover proves
inadequate.

### Option C — VRRP for state + OCI API VNIC failover (recommended)

Pattern used by Oracle's reference HA architecture for L4 appliances:

1. Allocate a **floating secondary private IP** on the edge subnet —
   e.g. `192.168.223.10`. Initially attached to r1's primary VNIC as
   a secondary IP.
2. Repoint the OCI app + data route tables at `.10` (the floating IP).
3. Run **VRRPv3** between r1 and r2 over the OCI edge subnet. They
   negotiate state via VRRP hellos; r1 is master, r2 is backup.
4. On VRRP state change, the new master executes a **failover script**
   that calls the OCI API to:
   - unassign `.10` from the old master's VNIC
   - assign `.10` to the new master's VNIC
5. OCI's SDN routes traffic destined for `.10` to whichever VNIC
   currently owns it (control-plane latency ~5–15 s).

VRRP-on-OCI doesn't actually move L2 — it just drives the state
machine that triggers the SDN-level reassignment. Detection is
sub-second (VRRP hello = 1 s by default), reassignment is
OCI-control-plane-bound.

## Concrete implementation

### Terraform changes (this part is mechanical; lives in one PR)

#### `terraform/oci/modules/edge/`

Allocate the floating secondary private IP as a managed resource on
r1's VNIC initially. The VNIC reassignment at runtime happens out-of-
band (via the failover script) so terraform shouldn't try to enforce
which VNIC owns it — use `ignore_changes` on `vnic_id`:

```hcl
data "oci_core_vnic_attachments" "primary_r1" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.this["fd1"].id
}

resource "oci_core_private_ip" "floating" {
  vnic_id        = data.oci_core_vnic_attachments.primary_r1.vnic_attachments[0].vnic_id
  ip_address     = "192.168.223.10"
  display_name   = "${var.environment}-edge-floating"
  hostname_label = "edge-floating"

  lifecycle {
    # Failover script reassigns this at runtime; don't fight it.
    ignore_changes = [vnic_id]
  }
}

output "floating_private_ip" {
  value = oci_core_private_ip.floating.id  # OCID, not address — for route_table consumption
}
```

#### `terraform/oci/modules/network/`

Change `internet_gateway_ip` from `"192.168.223.11"` to `"192.168.223.10"`.
The existing `oci_core_private_ips` data-source lookup resolves it
correctly via the IP-address-to-OCID mapping. App + data route tables
auto-update.

#### `terraform/oci/modules/edge/iam.tf` (new file — edge-only dynamic group + policy)

Pattern mirrors `terraform/oci/modules/server/iam.tf` (added in #210)
but with **a separate, edge-only dynamic group**. Reusing the server
module's group would broaden the k3s nodes' privileges to include VNIC
failover, and broaden the edge routers' privileges to include the k3s
Vault-read — both directions are unnecessary privilege expansion.
Keeping them disjoint preserves least privilege.

Matching rule scopes to just the edge instances by display name (or by
freeform tag, if we add one):

```hcl
locals {
  vrrp_enabled = var.use_reserved_public_ips && var.enable_vrrp_failover
}

resource "oci_identity_dynamic_group" "edge_failover" {
  count = local.vrrp_enabled ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "edge-${var.environment}-failover"
  description    = "Edge MikroTik instances in ${var.compartment_ocid}; grants VNIC failover for the floating private IP"
  # Match by display name pattern — the edge module names instances
  # ${environment}-mikrotik-chr-${fd}. Tighter than "every instance in
  # compartment" (which is what the server module's group does) so a
  # future non-edge instance landing here doesn't gain VNIC-manage.
  matching_rule = "all {instance.compartment.id = '${var.compartment_ocid}', any {instance.id = '${oci_core_instance.this["fd1"].id}', instance.id = '${oci_core_instance.this["fd2"].id}'}}"
}

resource "oci_identity_policy" "edge_vnic_failover" {
  count = local.vrrp_enabled ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "edge-${var.environment}-vnic-failover"
  description    = "Allow edge MikroTik instances to reassign the floating secondary private IP for VRRP HA"

  statements = [
    # Scoped to the specific floating private IP — not any private IP.
    "Allow dynamic-group ${oci_identity_dynamic_group.edge_failover[0].name} to manage private-ips in compartment ${var.compartment_ocid} where target.private-ip.id = '${oci_core_private_ip.floating.id}'",
    # Need read on the target VNICs (both r1's and r2's) to discover the
    # current owner before swapping. The provider needs `use vnics` rather
    # than just read for the attach/detach call.
    "Allow dynamic-group ${oci_identity_dynamic_group.edge_failover[0].name} to use vnics in compartment ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.edge_failover[0].name} to read instances in compartment ${var.compartment_ocid}",
  ]
}
```

(The exact statement scoping needs an OCI-policy-quirks pass — `use
vnics` might need narrowing further via `where any {target.vnic.id =
..., ...}` listing both r1's and r2's VNIC OCIDs. Verify with a
least-privilege test before applying.)

### MikroTik changes (RouterOS — the trickier part)

#### VRRP interface

Each router needs three RouterOS objects, all on the OCI edge subnet
interface (`ether1` on the CHR):

1. The VRRP virtual interface (state machine):

   ```routeros
   /interface/vrrp/add \
     name=vrrp-edge \
     interface=ether1 \
     vrid=10 \
     priority=200 \
     v3-protocol=ipv4 \
     on-master=":log info \"vrrp-edge: master state — triggering failover\"; /tool/fetch url=http://172.17.0.3/promote keep-result=no" \
     on-backup=":log info \"vrrp-edge: backup state — letting master own .10\""
   ```

   Priority `200` on r1 (master) and `100` on r2 (backup). VRID `10`
   arbitrary but consistent across routers.

2. The virtual IP address on the VRRP interface:

   ```routeros
   /ip/address/add \
     address=192.168.223.10/26 \
     interface=vrrp-edge \
     comment="VRRP virtual IP — owned by the master at any time"
   ```

3. The failover-helper container (next section). The `on-master` hook
   above POSTs to it via the container bridge (cloudflared lives at
   `.2`; the helper takes `.3`).

Both routers get all three objects via the existing `routeros_*`
terraform resources iterating with `for_each = local.routers`. The
priority value is per-router; everything else identical.

#### Failover trigger

When VRRP transitions r1 or r2 to master, *something* needs to make the
OCI API call that reassigns the floating private IP `.10` to the new
master's VNIC. RouterOS itself can't run `oci-cli` (no general Linux
shell), so the trigger has to delegate. Three realistic homes for that
code:

**Option A — Custom container per MikroTik (recommended for self-containment)**

Same pattern as the existing cloudflared container on each router. New
image built in-repo at `dockerfiles/oci-vrrp-failover/Dockerfile`,
published to `ghcr.io/calebsargeant/oci-vrrp-failover:<semver>` by the
existing semantic-release docker pipeline, then deployed via a new
`routeros_container.failover_helper` resource alongside the cloudflared
one. Image stack: `python:3.13-slim` + `pip install oci-cli` + a tiny
FastAPI/aiohttp server (~20 MB total). On hitting `POST /promote` from
the VRRP `on-master` hook, it shells `oci network private-ip update
--private-ip-id <floating> --vnic-id <local>` with `--auth
instance_principal` (auth principal is the MikroTik host VM, which the
new IAM policy in this design grants).

Pros: failover logic lives on the routers themselves; no cross-network
dependency in the failover path — if the home internet is down, the
routers still flip; matches the existing cloudflared container
pattern, so the operator already knows how to debug.

Cons: builds an additional in-house image; instance-principal auth
from inside a container on a MikroTik CHR requires confirming the
container can reach `169.254.169.254` (the OCI metadata service) — if
it can't, fall back to mounting a long-lived API key file.

**Option B — Controller pod on the firefly k3s cluster (recommended if
you want fewer custom images to maintain)**

A small Deployment on firefly running the same script logic, but
triggered by polling rather than VRRP webhooks. Pings r1 + r2 every
5–10 s; if r1's health-check fails for N successive intervals, calls
the OCI API to fail the floating IP over to r2.

Pros: no new docker image (just a tiny custom container or even a
`bitnami/oci-cli` image with a shell script); easier to monitor and
log via the existing observability stack; firefly is geographically
diverse from the OCI region (firefly's egress is via the on-prem
MikroTik, not via OCI), so OCI-side failures don't break the controller.

Cons: failover detection latency tied to poll interval (5–30 s
typical); if firefly k3s is unavailable, no failover happens; adds
operational coupling between the on-prem cluster and OCI's network
plane.

**Option C — External webhook (Lambda / Cloud Function)**

Considered and rejected. Adds an external dependency in the failover
path, which is exactly the part you don't want fragile.

**Decision needed:** Option A is what the rest of this doc assumes,
but Option B is simpler operationally. Pick one before the
implementation PR (see Open Questions).

#### Edge VNIC config

`skip_source_dest_check = true` is **already** set on both edge VNICs
in `terraform/oci/modules/edge/main.tf` line 21 — so the floating IP
will not be rejected by the VNIC's MAC-vs-IP check. No change needed
on the edge module's VNIC config.

## Test plan

1. **Pre-implementation smoke test**: in a non-production scratch
   compartment, manually create a floating private IP + reassign it
   between two VNICs via `oci-cli` and confirm OCI's reassignment
   latency is in the expected range (<30 s). If reassignment takes
   minutes, the whole approach is invalid.
2. **VRRP-only test (no API)**: enable VRRP on both routers without
   the failover script. Confirm state convergence (`/interface/vrrp/print`
   shows master/backup as expected, no flapping).
3. **Failover script standalone**: invoke the script manually on each
   router and confirm it reassigns the floating IP correctly. `oci
   network vnic get` only reports the VNIC's *primary* private IP — to
   check secondary-IP ownership, list the private IPs attached to each
   VNIC and confirm the floating one moves:

   ```bash
   # Look up the floating private-IP OCID once
   FLOAT_OCID=$(oci network private-ip get --private-ip-id <floating-ocid> --query 'data."vnic-id"' --raw-output)
   echo "floating IP currently attached to VNIC: $FLOAT_OCID"

   # Or list all private IPs per VNIC and grep for the floating address
   oci network private-ip list --vnic-id <r1-vnic> --query 'data[].{ip:"ip-address",primary:"is-primary"}'
   oci network private-ip list --vnic-id <r2-vnic> --query 'data[].{ip:"ip-address",primary:"is-primary"}'
   ```
4. **End-to-end failover**: stop r1's RouterOS VM. Time how long until
   `traceroute 1.1.1.1` from an app subnet VM starts succeeding again.
   Target: under 30 s.
5. **Failback**: start r1's VM. Confirm pre-emption returns master to
   r1 and floating IP follows.
6. **Split-brain probe**: simulate a network partition between r1 and
   r2 (firewall the VRRP hellos for 30 s). VRRP should declare both
   master — but the OCI API enforces single-VNIC ownership of the
   private IP, so reassignment from one side races; whichever wins is
   the active. Confirm no infinite reassignment loop.

## Rollback

Each step is independently reversible:

- **Floating IP**: `terraform destroy` of `oci_core_private_ip.floating`
  releases it. App/data subnets need their route tables repointed back
  to `.11` (revert the `internet_gateway_ip` change) **first** or
  outbound traffic dies.
- **VRRP**: `/interface/vrrp/remove vrrp-edge` on each router. Routing
  state on OCI is unchanged.
- **Failover script container**: `routeros_container` destroy. Routers
  stop responding to VRRP state changes; floating IP stays wherever it
  was last assigned (probably r1).
- **IAM policy**: terraform destroy of the policy + dynamic group
  matching rule (gated on `var.vrrp_enabled`, default false, same
  pattern as #210).

Each landing should be a separate apply with the route-table change
applied **last** so a misconfigured VRRP/script doesn't strand the
floating IP somewhere inactive.

## Open questions before implementation

1. **OCI Always Free quota for secondary private IPs**: confirm no
   surprise cost. (Spec says "up to 32 secondary IPs per VNIC at no
   cost" — should be fine, but worth verifying.)
2. **OCI control-plane latency for `assign-private-ip`**: needs the
   pre-implementation smoke test (#1 above). If it's minutes rather
   than seconds, the whole approach is no better than manual failover.
3. **VRRP hello transit across OCI**: OCI's SDN passes VRRP multicast
   between VNICs in the same subnet (per Oracle docs), but worth
   confirming on the actual edge subnet before betting the design
   on it.
4. **Failover trigger choice — Option A vs B** (see "Failover trigger"
   section). Defaults differ on operational philosophy:
   - **Option A (container on each MikroTik)**: new image at
     `ghcr.io/calebsargeant/oci-vrrp-failover:<semver>`, built via
     `dockerfiles/oci-vrrp-failover/Dockerfile` and the existing
     semantic-release docker pipeline. Self-contained per-router
     failover with no cross-network dependency. Need to verify that
     a RouterOS container can reach OCI's `169.254.169.254` metadata
     service for instance-principal auth — fallback is an API key
     file mounted in.
   - **Option B (controller on firefly k3s)**: tiny Deployment using
     an off-the-shelf image like `bitnami/oci-cli` + a short Python
     watchdog. Polls r1/r2 health; if r1 down for N intervals,
     fails over via OCI API. No custom image to maintain, easier
     observability, but failover detection latency is poll-bounded
     and depends on firefly being up.

## Out of scope (intentionally)

- DRG / VPN routing changes — VPN tunnels stay pointed at the existing
  endpoints. This design only touches the **internet egress** routing.
- WAN-side HA. The MikroTiks share the same OCI region's internet
  gateway; if OCI eu-amsterdam-1's IGW has a region-wide problem,
  neither router can route. Geographic redundancy is its own project.
- `auto-restart-interval` for cloudflared on r2 — tracked separately
  in `cloudflare-ztna-improvements.md` #2 residual gap.
