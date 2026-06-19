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
DHCP server. For resilience each switch also has two **routed** point-to-point
uplinks:

- **LAN bridge** (`bridge-lan`, RSTP) — the local FortiGate uplink + client
  ports, all in one subnet (MT1 `10.10.10.0/24`, MT2 `10.20.20.0/24`).
- **crosslink** — `/30` to the *opposite* FortiGate; backup default route so the
  switch still reaches the internet if its local FortiGate / ISP is down.
- **mt_link** — `/30` to the *other* MikroTik; reaches the peer site's LAN.

The crosslink + mt_link are routed ether ports (not bridged), so there's no L2
loop between sites; RSTP just guards the local access bridge. Failover is
distance-based static routing (primary via local FGT = distance 1, backup via
the cross-link = distance 20). The cross-link terminates in the opposite
FortiGate's `internal` zone, so its `internal→wan` SNAT policy already covers
this failover egress.

## What it configures, per switch

LAN bridge (RSTP) · bridge member ports (uplink + clients) · bridge mgmt IP ·
cross-link `/30` · inter-switch `/30` · primary + backup default routes · a
route to the peer site's LAN.

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
