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

`oci network ip-sec-tunnel list` shows tunnel UP from both routers but the
firefly Cloudflare tunnel only has live colo connections from
`193.123.39.172` (r2). r1's `cloudflared` container isn't connecting. The
HA design pays for two MikroTiks but only one is doing work — if r2 dies,
the tunnel goes with it.

Investigation pointers:

- SSH into r1 (now reachable via Winbox; terraform also reaches it on 8728)
- Check `/container/print` for the cloudflared container state
- Compare `/container/print run-time` between r1 and r2

## 3. Extract repeated email lists into Access Groups

The Overseerr "Friends" policy has 10 emails inlined. Same for the WARP
"Allow emails" policy. Same emails will appear again when you add the next
"family-can-use-this" app. An Access Group is the right abstraction:

```hcl
resource "cloudflare_zero_trust_access_group" "friends" {
  account_id = var.account_id
  name       = "Friends"

  include {
    email = ["calebsargeant@gmail.com", "nicholas_smith_@msn.com", ...]
  }
}

resource "cloudflare_zero_trust_access_policy" "overseerr_friends" {
  # …
  include {
    group = [cloudflare_zero_trust_access_group.friends.id]
  }
}
```

Removes drift between policies, makes membership a single edit.

## 4. Wire device posture rules into Access policies

Three macOS posture rules exist (Disk Encryption, Firewall, OS Version >=
13.0.1) — and **none of them are referenced**. They're dead code.

Add a `require` block on the Caleb policy for Overseerr (or anything more
sensitive), e.g.:

```hcl
require {
  device_posture = [
    cloudflare_zero_trust_device_posture_rule.mac_disk_encryption.id,
    cloudflare_zero_trust_device_posture_rule.mac_firewall.id,
  ]
}
```

Otherwise the posture rules might as well not exist.

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

`Allow rule for Server` (precedence 15000) and `Block rule for Server`
(precedence 16000) both target the same IP. The block is strictly less
preferred than the allow, so the block does nothing right now — unless
there's a planned identity/posture condition on the allow that hasn't been
added yet. Either drop one or document the intent in the resource
description.

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
