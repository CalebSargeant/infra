# fortigate

Manages two **standalone FortiGate 40Fs** (no HA) as resilient dual-ISP edges.
The `fortinetdev/fortios` provider is iterated per unit with **`for_each`**
(OpenTofu 1.9+), so each resource below is declared once and applied to both
boxes at the same time — the same pattern as `oci/modules/mikrotik`.

## Topology modelled

```
        ISP1                                   ISP2
         │                                      │
       (wan)                                  (wan)
      ┌──────┐   interconnect /30   ┌──────┐
      │ FGT1 │◀────────────────────▶│ FGT2 │
      └──────┘                       └──────┘
       │    └────crosslink───┐    ┌───crosslink────┘   │
   (lan_mikrotik)            │    │             (lan_mikrotik)
       │                     ▼    ▼                     │
   ┌─────────┐            ┌─────────┐            ┌─────────┐
   │MikroTik1│◀──────────▶│  ...    │◀──────────▶│MikroTik2│
   └─────────┘  MT<->MT   └─────────┘            └─────────┘
```

- Each FortiGate has its own ISP on `wan` (DHCP by default).
- `interconnect` — direct FGT1↔FGT2 link (/30).
- `lan_mikrotik` — link to the MikroTik directly behind each unit (clients live
  behind the MikroTik; the FortiGate is their gateway + DHCP server).
- `crosslink` — link to the **opposite** unit's MikroTik (FGT1↔MikroTik2,
  FGT2↔MikroTik1) for a redundant fabric path.
- `lan_mikrotik` is an 802.1Q trunk (VLAN subinterfaces); `crosslink` is routed.

MikroTik2 isn't installed yet — its FGT2 `lan_mikrotik` and the cross-links can
be configured ahead of cabling; the interfaces simply sit link-down until wired.
The MikroTik side itself is out of scope here (see `oci/modules/mikrotik` for
the routeros pattern when you add it).

## What it configures, per unit

Physical interfaces (wan / interconnect / lan trunk / crosslink) · **VLAN
subinterfaces** on the LAN trunk (`vlans.tf`) · a DHCP scope per VLAN ·
per-VLAN internet SNAT · trusted-VLAN segmentation policies · cross-link SNAT ·
east-west static route to the peer site.

**VLANs / segmentation** (`vlans.tf`): the LAN port is an 802.1Q trunk to the
MikroTik; each VLAN (default `trusted`/`iot`/`guest`/`mgmt`, subnet
`10.<site>.<vlanid>.0/24`) is an L3 subinterface with its own DHCP. Every VLAN
gets internet egress; the `trusted` VLAN may reach all others + the
interconnect; `iot`/`guest` are isolated by the implicit default-deny.

**Both ISPs run active-active** (no failover): each FortiGate only NATs out its
own WAN. The two ISPs carry traffic simultaneously because the MikroTik
load-balances (ECMP) across both FortiGates — flows sent to the *opposite*
FortiGate arrive on its cross-link, and the `crosslink→wan` SNAT policy egresses
them out that unit's ISP. There is no backup default route and no failover
egress policy.

**OCI site-to-site VPN** (`vpn.tf`): route-based IPsec from each FortiGate to
OCI's managed Site-to-Site VPN (DRG headend). Both of OCI's tunnel public IPs are
configured per unit; routing is **BGP** (`bgp.tf`) and **SD-WAN** (`sdwan.tf`)
steers VCN traffic across both tunnels. `trusted` reaches the OCI VCN
(`192.168.223.0/24`) un-NATed. OCI side: `oci/.../vpn-fortigate` (routing_type
BGP); PSK + tunnel/BGP inside IPs are shared between the two sides via the leaves.

**BGP** (`bgp.tf`): each FortiGate runs its own ASN (FGT1 65010 / FGT2 65020),
eBGP-peers with OCI (AS 31898) over both tunnels with ECMP, and eBGP-peers with
the other FortiGate over the interconnect. It advertises its VLAN /24s. (Scope:
"OCI + FGT↔FGT"; the MikroTik keeps static ECMP defaults.)

**SD-WAN** (`sdwan.tf`): an `oci` SD-WAN zone with both OCI tunnels as members, a
health-check SLA, and a load-balance service rule for VCN-bound traffic. Each
unit has a single physical ISP, so SD-WAN here is the OCI overlay, not a WAN
underlay. The `trusted↔OCI` policies reference the SD-WAN `oci` zone.

**Remote access** (`remote-access.tf`): IPsec **dial-up** (FortiClient) — not
SSL-VPN, which is removed/constrained on 2GB-RAM models (40F) in recent FortiOS.
mode-config assigns a client pool + split route. Users authenticate via **Google
Workspace SAML** (`fortios_user_saml`, IKEv2 EAP). The SAML SP URLs + the
SAML-over-IPsec knobs vary by FortiOS version — validate before apply.

**Identity**: Google Workspace as the SAML IdP (`var.saml_idp`); the imported
`idp_cert_name` must exist on the unit. Used to gate the remote-access policy via
the `vpn-saml` user group.

**Visibility & automation** (`monitoring.tf`): remote syslog + NetFlow export
(self-disable when unset), and a sample automation stitch (reboot → webhook).
Clone the trigger/action/stitch trio for more events.

> **Licensing:** everything here works on the **base license**. FortiGuard-only
> UTM (IPS, AV, web/app/DNS filtering, SSL deep-inspection) is intentionally not
> configured — add those profiles to the `*-to-wan` policies if you subscribe.

## ⚠️ Before you apply

1. **Verify physical port names.** Defaults are `wan` + `internal1..3`. The 40F's
   4 internal ports ship as one hardware switch — confirm the real per-port
   interface names on each unit (`get system interface physical`) and remap via
   each FortiGate's `ports = { ... }` in the leaf if they differ. An interface
   that's a hardware-switch member can't take its own IP until it's split out.
2. **Placeholder addressing.** All IPs in `prod/terragrunt.hcl` are RFC1918
   placeholders — set your real scheme.
3. **Tokens + reachability.** Create a REST-API admin token per unit
   (`config system api-user`), store each in OCI Vault, and wire them in (see
   the leaf's credentials comment). The host running `terragrunt apply` (incl.
   Atlantis on firefly) must be able to reach each FortiGate's mgmt IP/API.

Until 1–3 are done, the Atlantis project for this leaf is left with
`autoplan.enabled: false` (a plan can't reach a device that isn't there yet);
run it manually with `atlantis plan -p fortigate-prod`.
