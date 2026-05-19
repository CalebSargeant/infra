# Cloudflare ZTNA Improvement Backlog

Captured during the initial dashboard→terraform import (see
`terraform/cloudflare/zero-trust/prod/`). None of these are required for the
import to land; each is a discrete follow-up PR.

Ranked roughly by impact × effort, highest first.

## 1. Promote Radarr from `bookmark` to `self_hosted` (security gap)

Today the Radarr Access "app" is `type = "bookmark"`. Bookmarks are **not
authenticated** — they're just an icon in the App Launcher; the actual
service at `radarr.sargeant.co` is reachable by anyone with the URL.
Overseerr is correctly `self_hosted`. Either:

- Promote Radarr to `self_hosted` with a `Friends` policy (same emails as
  Overseerr) and a Caleb override; or
- Remove the bookmark if Radarr is intentionally public.

Either way, the current state is the worst of both worlds: Access shows it
in the launcher but doesn't actually protect it.

## 2. Fix r1's cloudflared HA (availability gap)

**Resolved 2026-05-19.** r1's container had been stopped since 2026-05-11
(stale ingress config caused cloudflared to crash; `auto-restart-interval`
defaulted to `none`, so RouterOS never restarted it). Started manually via
the API; `auto-restart-interval` set to `30s` on r1 so it self-heals next
time. r2 took the load all that time.

Both routers now active: 8 colo connections to the `firefly` tunnel (4
each, full HA). Cloudflare reports `status: healthy`.

**Residual gap — r2 firmware** doesn't accept the `auto-restart-interval`
parameter (older RouterOS schema; `unknown parameter` error from the API).
If r2's cloudflared crashes, it won't auto-restart. Two options:

- Upgrade r2's RouterOS firmware to match r1, then set the same 30s
  interval. Cleanest.
- Add a RouterOS `/system/scheduler` job on r2 that runs every minute and
  starts the cloudflared container if it's stopped. Works on older
  firmware. Copy-paste-safe script (matches the container by `name` — the
  container name is `cloudflared:latest`, derived from `remote_image`):

  ```routeros
  /system/scheduler/add \
    name=cloudflared-watchdog \
    interval=1m \
    on-event=":local cid [/container find where name=\"cloudflared:latest\"]; :if ([:len \$cid] = 1 && [/container get \$cid stopped] = true) do={ /container start \$cid; :log info \"cloudflared-watchdog: started stopped container\" }"
  ```

  Codify this in the mikrotik terraform module via a `routeros_system_scheduler`
  resource, gated by an input that defaults off but is enabled for r2.

## 3. Extract repeated email lists into Access Groups

**Partially landed.** Four reusable Access Groups defined in
`access_groups.tf`: `friends`, `caleb`, `household`, `magma_moose_domain`.
Membership of each lives in exactly one place now.

**Blocker — v4 provider limitation:** the existing policies in CF
(`overseerr_friends`, `overseerr_caleb`, `warp_allow_emails`,
`app_launcher_magma`) are all *reusable* policies, not app-scoped. The
cloudflare/cloudflare v4 provider can only update policies through the
app-scoped endpoint and returns API error 12130 — "can not update reusable
policies through this endpoint" — when you try. So the
`include = { group = [...] }` refactor can't be applied via terraform
without one of:

- Migrate to provider v5 once the relevant resource exists for reusable
  policies, then switch include blocks to `group = [...]`.
- Recreate each policy as app-scoped (delete + create — brief access
  disruption while CF cuts over).
- Update the include via the CF dashboard (lose the terraform-as-source
  property; not recommended).

Until then the access_groups are scaffolding for *new* app-scoped policies
created via terraform; existing ones stay inline.

## 4. Wire device posture rules into Access policies

**Blocked by the same v4-provider reusable-policy limit (#3).** The
intent was to add a `require { device_posture = [...] }` block on
`overseerr_caleb` (FileVault + macOS version, not firewall — many dev
Macs have the system firewall off). The HCL is staged as a comment in
`access_apps.tf` for when the limit is unblocked.

Three macOS posture rules (Disk Encryption, Firewall, OS Version >=
13.0.1) exist but **none are referenced**. They're dead code until #3 is
resolved.

## 5. Move tunnel credentials into OCI Vault

Today the cloudflared tunnel token lives in 1Password (`Firefly Cloudflare
Tunnel Token`) and gets injected into the MikroTik container env at
terragrunt parse time via `op read`. The new pattern (matching the
cloudflare API token) is to keep all secrets in OCI Vault and read via the
oci CLI.

After this migration:
- One source of truth for secrets (OCI Vault)
- 1Password dependency drops out of the mikrotik terragrunt
- Rotation is `oci vault secret update-base64`, no app re-deploy needed
  (when paired with a small `cloudflared`-watching reload mechanism)

## 6. Service tokens for automation paths

No service tokens are defined. As soon as you want CI to hit an
Access-protected endpoint, or a script to call an internal API, a
short-lived service token is the right answer (instead of an authenticated
user session). At minimum, model the pattern in terraform so adding one is
a single resource + policy update.

## 7. Replace the manual adware list with CF managed categories

The "Block adware" gateway DNS rule has ~16 manually-curated domains. CF
ships managed categories (Ads & Tracking, Malware, etc.) that cover the
same use case with continuous updates. Replace `traffic = "any(dns.domains[*]
in {…})"` with `traffic = "any(dns.content_category[*] in {…})"` using the
appropriate category IDs.

## 8. Document or consolidate the L4 allow + block rules on `192.168.69.110`

**Partially landed.** Both resources now carry descriptions making the
override pattern explicit (allow at precedence 15000 wins; block at
16000 is currently unreachable). Inline comment in `gateway.tf` calls out
the two interpretations (intentional plumbing for a future identity
condition on the allow, or leftover dead code).

**Outstanding decision:** confirm whether the block is meant to be the
catch-all for a not-yet-added identity-conditional allow. If yes, add the
identity condition. If no, delete the block resource.

## 9. Rename the "firefly" tunnel to something OCI-specific

The cloudflared tunnel is named `firefly` but runs on the OCI MikroTik CHRs
— not on the firefly cluster. Confusing when reading the dashboard. Rename
to `magmamoose-oci` (or similar). Tunnel name is immutable on the v4
provider, so this means create-new + cutover, not in-place rename.

## 10. Browser isolation for risky apps

For apps that handle externally-sourced content (Overseerr requests,
anything Plex/Jellyfin-adjacent), enable CF's browser isolation so the
session runs in CF's sandbox. Adds a real defence layer at minor latency
cost.

## 11. WARP profile / device enrollment policy in terraform

The WARP Login App exists but the actual WARP profile (split-tunnel
routes, gateway settings, posture requirements) isn't modelled. If you use
WARP regularly, codify the profile so it survives a dashboard wipe.

## 12. Logpush for Access + Gateway events

CF retains Access/Gateway logs for ~30 days in the UI. Logpush them to GCS
(same bucket as terraform state, or a new audit bucket) for long-term
forensic capability. Cheap to set up, costs almost nothing in storage at
your volume.
