# mikrotik/crs

Manages the two **home-lab MikroTik CRS switches** (the "CRS behind each
FortiGate") with the `terraform-routeros/routeros` provider iterated per unit
via **`for_each`** (OpenTofu 1.9+). The MikroTik half of the resilient edge
whose FortiGate half lives in `terraform/fortigate`.

> Not to be confused with `terraform/oci/.../mikrotik` — those are MikroTik CHR
> **cloud VMs** in OCI. These are the **physical** edge switches.

## Role in the topology

```
   ISP1 ─▶ FGT1 ◀──interconnect──▶ FGT2 ◀─ ISP2
            │  └──crosslink─┐  ┌──crosslink──┘ │
        (uplink)           ▼    ▼          (uplink)
        ┌─────────┐    mt_link (/30)     ┌─────────┐
        │   MT1   │◀────────────────────▶│   MT2   │
        └─────────┘                       └─────────┘
       client ports                      client ports
```

Each CRS is an **L2 access switch** — the FortiGate behind it is the gateway and
DHCP server. Each switch also has two **routed** point-to-point uplinks:

- **LAN bridge** (`bridge-lan`, **MSTP**) — the local FortiGate uplink + client
  ports, all in one subnet (MT1 `10.10.10.0/24`, MT2 `10.20.10.0/24`). Both
  switches share one MST region (`region_name`/`region_revision`).
- **crosslink** — `/30` to the *opposite* FortiGate.
- **mt_link** — `/30` to the *other* MikroTik; reaches the peer site's LAN.

The crosslink + mt_link are routed ether ports (not bridged), so there's no L2
loop between sites; MSTP guards the local access bridge.

**Both ISPs run active-active (NOT failover).** Two equal-distance (distance 1)
default routes — via the local FortiGate and via the opposite FortiGate over the
cross-link — give RouterOS **ECMP**, so client flows load-balance across both
FortiGates / ISPs at the same time. Each flow is pinned to one path and the
egress FortiGate SNATs it out its own ISP, keeping return traffic symmetric. The
cross-link terminates in the opposite FortiGate's `internal` zone, so its
`internal→wan` SNAT policy covers the egress.

## What it configures, per switch

LAN bridge (MSTP, **vlan_filtering**) · bridge member ports (tagged FortiGate
trunk + untagged client access ports with PVIDs) · bridge VLAN table · mgmt-VLAN
interface + switch mgmt IP · cross-link `/30` · inter-switch `/30` · two
equal-distance (ECMP) default routes · a route to the peer site supernet.

**VLANs:** `vlan_filtering` is on. The FortiGate uplink is a tagged trunk
carrying every VLAN; client ports are untagged access ports (default VLAN
`trusted`, override per port via `access_port_vlans`). The FortiGate does the
inter-VLAN routing — the switch is pure L2 here. VLAN ids must match the
FortiGate module (`trusted` 10 / `iot` 20 / `guest` 30 / `mgmt` 99).

## ⚠️ Before you apply

1. **Verify port names** for your actual CRS model (`/interface print`) and set
   them in each switch's `ports` / `client_ports`. `ether1..8` are placeholders.
2. **Placeholder addressing** — kept consistent with `terraform/fortigate`; edit
   both together if you change the scheme.
3. **Password + reachability** — store the admin password in OCI Vault and wire
   it in (see the leaf's credentials comment). The host running `terragrunt`
   (incl. Atlantis on firefly) must reach each switch's API.
4. **MT2 isn't installed yet** — it's defined ahead of cabling; a plan/apply
   targets both, so expect the mt2 provider instance to fail to connect until
   the hardware exists.

The Atlantis project keeps `autoplan.enabled: false` until the switches are
reachable; run manually with `atlantis plan -p mikrotik-prod`.
