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

#### `terraform/oci/modules/server/iam.tf` (pattern reuse)

Add a second IAM policy + reuse the existing dynamic group (or extend
the matching rule to include both server and edge instances) that
grants the edge instance principals permission to manage their own
VNICs' secondary private IPs:

```hcl
resource "oci_identity_policy" "edge_vnic_failover" {
  count = local.vrrp_enabled ? 1 : 0

  compartment_id = var.tenancy_ocid
  name           = "edge-${var.environment}-vnic-failover"
  description    = "Allow edge MikroTik instances to reassign the floating secondary private IP for VRRP HA"

  statements = [
    # Need: use vnic, manage private-ips, use instance
    # Scoped to the edge instances' VNICs only (via the floating private IP's parent VNIC)
    "Allow dynamic-group edge-${var.environment} to manage private-ips in compartment ${var.compartment_ocid} where target.private-ip.id = '${var.floating_private_ip_ocid}'",
    "Allow dynamic-group edge-${var.environment} to use vnics in compartment ${var.compartment_ocid}",
    "Allow dynamic-group edge-${var.environment} to read instances in compartment ${var.compartment_ocid}",
  ]
}
```

(The exact statement scoping needs an OCI-policy-quirks pass — `manage
private-ips` may need `where any {target.vnic.id = ..., target.vnic.id = ...}`
for both VNICs. Verify with a least-privilege test before applying.)

### MikroTik changes (RouterOS — the trickier part)

#### VRRP interface

Each router gets a `/interface vrrp` on the edge subnet interface
(`ether1` on the OCI CHR), with the virtual address set to `.10`:

```routeros
/interface/vrrp/add \
  name=vrrp-edge \
  interface=ether1 \
  vrid=10 \
  priority=200 \
  v3-protocol=ipv4 \
  on-backup=":log info \"vrrp-edge: backup state\""
```

Priority `200` on r1 (master) and `100` on r2 (backup). VRID `10`
arbitrary but consistent across routers.

#### Failover script

Triggered via `on-backup` / `on-master` hooks on the VRRP interface.
RouterOS scripts can invoke `/tool/fetch` for HTTPS calls, which we
chain into a tiny one-shot to flip the floating IP via OCI API. Two
realistic paths:

1. **Container-based failover helper**: small Python script in a
   container running on the MikroTik (same pattern as cloudflared) that
   exposes a localhost HTTP endpoint. The VRRP hook does `/tool/fetch
   url=http://172.17.0.3/promote` to trigger it. The container uses
   `oci-cli --auth instance_principal` to do the reassignment.
2. **External webhook**: a small Lambda/Cloud Function the routers POST
   to; it does the OCI API call. Centralises auth + logging but adds an
   external dependency in the failover path (counterproductive — if the
   webhook is in the same region and that region's control plane is
   degraded, failover doesn't work).

**Recommendation: option 1.** Co-locates the failover logic with the
router, no cross-cloud dependency in the failover path, reuses the
container runtime that's already on each router.

The container would be a custom-built image (~20 MB Python + oci-cli)
pushed to a registry. The terraform `routeros_container` resource
already exists in this module — adding one more container per router
is the same pattern as cloudflared.

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
   router and confirm it reassigns the floating IP correctly via
   `oci network vnic get` against both VNICs.
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
4. **Container-based failover helper image distribution**: does this
   live in the same OCI Container Registry that already hosts the
   MikroTik CHR image? Or in Docker Hub like cloudflared? Decision
   needed before implementation PR.

## Out of scope (intentionally)

- DRG / VPN routing changes — VPN tunnels stay pointed at the existing
  endpoints. This design only touches the **internet egress** routing.
- WAN-side HA. The MikroTiks share the same OCI region's internet
  gateway; if OCI eu-amsterdam-1's IGW has a region-wide problem,
  neither router can route. Geographic redundancy is its own project.
- `auto-restart-interval` for cloudflared on r2 — tracked separately
  in `cloudflare-ztna-improvements.md` #2 residual gap.
