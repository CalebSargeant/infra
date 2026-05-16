# Kubernetes restructure plan (firefly cluster)

Status: **DRAFT — not yet executed.** Captures findings from the 2026-05-15 audit and proposes a phased migration to the [`infra-v2`](https://github.com/CalebSargeant/infra-v2) Flux layout.

---

## 1. Current state (after 2026-05-15 audit/cleanup)

- `kubernetes/_base/<category>/<app>/` — 8 namespace-categories of shared bases
- `kubernetes/_clusters/firefly/<category>/<app>/` — per-cluster overlays
- `kubernetes/_components/{resource-profiles,node-selectors,gluetun-sidecar,wireguard-sidecar}/` — reusable patches
- `kubernetes/_clusters/firefly/flux-system/` — Flux bootstrap + 18 `Kustomization` CRs in `kustomizations.yaml` with `dependsOn` chains

**Cleanup already done this session** (see `.old/` for archived content, gitignored):

| Removed | Reason |
| --- | --- |
| `kubernetes/_clusters/franklin/` (tracked, 39 files) | franklinhouse cluster lives in `infra-v2` now |
| `kubernetes/_clusters/firefly/miscellaneous/headlamp1/` (tracked) | Orphan duplicate; canonical files live in `headlamp/` |
| `kubernetes/.kusomization.workings.yaml` (tracked, typo) | Stale working draft for `mini` node |
| `kubernetes/_base/miscellaneous/comfyui/`, `comfyui-api/`, `imagegen/` (untracked) | Never tracked; preserved in `.old/` for possible reactivation under new layout |
| `kubernetes/infrastructure/` (untracked) | Abandoned migration attempt — see §3 for credential preservation |
| `kubernetes/apps/`, `kubernetes/base/`, `kubernetes/overlays/` (untracked) | Dangling early-stage dirs; `apps/automation/n8n/secret.yaml` was plaintext (see §3) |
| `.neon_credentials.txt`, `.DS_Store` | Local junk |

**Items left alone, flagged for follow-up:**

| Item | Why |
| --- | --- |
| `kubernetes/maniforge.yaml` (root) and `kubernetes/_clusters/firefly/maniforge.yaml` | Different content; referenced from `docs/reference/maniforge.md`. Decide if maniforge is still in use. |
| `ansible/keys/chr.pem` (tracked) | OPENSSH private key, committed `2025-04-18` (commit `d5b8915`). Public repo — already leaked. **Rotate + scrub history.** |
| `ansible/vars/franklin.yaml`, `ansible/vars/pi.yaml` (gitignored on-disk) | Contain plaintext `ghp_…` GitHub PAT. Not in git history but on disk. **Rotate the PAT.** |
| `docs/operations/proxmox-gpu-passthrough-recovery.md` (untracked) | Looks intentional — commit when ready |
| `terraform/oci/_modules/mikrotik/`, `terraform/oci/prod/eu-amsterdam-1/mikrotik/`, `terraform/.oci-config.ps1` (untracked) | Out of scope for k8s cleanup; user wants these kept as-is |
| Empty staged `AGENTS.md` | Decide whether to fill it or unstage |
| `kubernetes/_base/observability/SECRETS.md` (tracked) | Audit content — make sure no plaintext is in it |

---

## 2. Target state (`infra-v2` pattern)

```
kubernetes/
├── clusters/
│   └── firefly/
│       ├── flux-system/      # gotk-components, gotk-sync, etc.
│       └── system/           # cluster-level resources + node-placement patches
├── infrastructure/
│   ├── controllers/          # operators (cert-manager, cloudnative-pg, external-secrets, 1password, flux)
│   ├── services/             # platform services (postgres, minio, vpn-gateway, external-dns)
│   └── configs/              # cluster-wide configmaps / namespaces
└── apps/
    └── <app-name>/
        ├── base/<app>/           # canonical resources + kustomization.yaml
        ├── prod/<app>/           # prod overlay + flux-kustomization.yaml
        └── staging/<app>/        # optional staging overlay
```

**Why this layout:**

- **App-first, env-second.** Easier to find one app's full story (base + each env) than hunting through `_base/category/app + _clusters/firefly/category/app`.
- **No leading-underscore folders.** Standard Flux convention; tools and contributors expect `apps/`, `clusters/`, `infrastructure/`.
- **Per-app `flux-kustomization.yaml`** keeps Flux CRs co-located with the manifests they apply, instead of a single 200-line `kustomizations.yaml`.
- **Mirrors `infra-v2`** so context-switching between the two repos is frictionless.

---

## 3. Plaintext credential findings (action required)

Currently no plaintext secrets are tracked **except `ansible/keys/chr.pem`** (committed 2025-04-18 in public repo `CalebSargeant/infra`). The rest sit on disk in `.old/` after this session's cleanup.

### Rotate these credentials

| Credential | Where found | Action |
| --- | --- | --- |
| OPENSSH private key `chr.pem` | `ansible/keys/chr.pem` (tracked, in git history) | **Rotate immediately.** Revoke from MikroTik device. Scrub from git history (`git filter-repo --path ansible/keys/chr.pem --invert-paths` then force-push, **after** key is rotated and any clones notified). |
| GitHub PAT (token redacted; starts `ghp_QV…`) | `ansible/vars/franklin.yaml`, `ansible/vars/pi.yaml` (gitignored, on disk only) | **Rotate the PAT** at https://github.com/settings/tokens. Move actual value to 1Password / age-encrypted secret. |
| AGE secret key (private value redacted; public recipient is the same one in `.sops.yaml`) | `.old/kubernetes/infrastructure/controllers/cert-manager/age.agekey` + duplicate at `.old/kubernetes/overlays/franklin/apps/cert-manager/age.agekey` | This is **the production SOPS key**. Keep secure (1Password). If you suspect exposure, re-encrypt all `.enc.yaml` to a new key. |
| Cloudflare DNS API token (base64-encoded in `data: dns-cloudflare-api-token`) | `.old/kubernetes/infrastructure/controllers/cert-manager/cloudflare-secret.yaml`, `.old/kubernetes/overlays/franklin/apps/cert-manager/cloudflare-secret.yaml` | **Rotate via Cloudflare dashboard.** Replace with SOPS-encrypted secret or ExternalSecret. |
| WireGuard private keys (`jackett`, `nzbhydra2`, `prowlarr`, `qbittorrent`, `sabnzbd`) | `.old/kubernetes/infrastructure/components/wireguard-sidecar/keys/*.key` + `*-wg0.conf` | If the VPN provider supports it, **regenerate** each peer key. Otherwise mark as known-exposure risk. |
| n8n postgres password (15-char alphanumeric; value redacted) | `.old/kubernetes/apps/automation/n8n/secret.yaml` | If still the live password (cross-check against `kubernetes/_base/automation/n8n/secret.enc.yaml`), **rotate**. |

### Hygiene improvements

- `kubernetes/_components/wireguard-sidecar/wg0-configs-README.md` and `kubernetes/_base/media/WIREGUARD-DEPLOYMENT-GUIDE.md` contain `PrivateKey =` lines — confirm they're documentation placeholders, not real keys leaked into docs.
- Move any future WireGuard keys / Cloudflare tokens into the existing `1password-connect` + `external-secrets` flow rather than on-disk files.

---

## 4. Broken Flux state — Phase 0 progress

### `misc` Kustomization — FIX APPLIED (uncommitted)

**Real root cause** (my earlier sync-conflict-file hypothesis was wrong — Flux only sees git-tracked files, the conflict file was untracked): `kubernetes/_clusters/firefly/miscellaneous/headlamp/tunnel-pr-acc-eurofiber-web.enc.yaml` was encrypted with `encrypted_regex: ^(.*)$` — i.e. EVERY field including `apiVersion`, `kind`, `metadata.name`, `metadata.namespace`. Flux's kustomize-controller `v1.7.2` needs the resource header in plaintext to identify what it's about to decrypt; with everything encrypted it can't determine resource identity and emits a misleading "decryption failed" error. The misleading bit: the resource ID in the error log shows `misc/ENC[...]` — `misc` is the namespace (resolved from `kustomization.yaml`'s `namespace: misc` default), `ENC[...]` is the encrypted `metadata.name`. Local `sops -d` works because it walks the tree without trying to identify the resource first.

**Why this file was encrypted whole**: it's a proprietary work-related tunnel — a Deployment that runs nginx + `kubectl port-forward` against the `pr-acc-eurofiber` work cluster, exposing Eurofiber / Samenleving / csam3 internal hostnames. The user wanted everything hidden from the public repo. The `^(.*)$` regex was the workaround, which broke Flux.

**Action taken** (per user's direction: "Move all pr-acc-eurofiber + p1 + nonprod-aks files to a PRIVATE repo"):

13 work-cluster files moved from `kubernetes/_clusters/firefly/miscellaneous/headlamp/` to `.old/work-private/kubernetes/_clusters/firefly/miscellaneous/headlamp/` (gitignored). `kustomization.yaml` updated to drop the references. Local `kustomize build kubernetes/_clusters/firefly/miscellaneous --load-restrictor=LoadRestrictionsNone --enable-helm` now exits 0 (1336 lines of output). All remaining `.enc.yaml` files in `headlamp/` decrypt cleanly with the cluster's AGE key.

Files moved (now in `.old/work-private/`):
- `certificate-p1.yaml`
- `ingressroute-p1.yaml`
- `middleware-oauth2-p1.yaml`
- `middleware-p1-prod-eks.enc.yaml`
- `middleware-p1-staging-eks.enc.yaml`
- `middleware-pr-acc-eurofiber.enc.yaml`
- `middleware-pr-nonprod-aks.enc.yaml`
- `oauth2-proxy-emails-p1.enc.yaml`
- `oauth2-proxy-p1.yaml`
- `oauth2-proxy-secret-p1.enc.yaml`
- `tunnel-pr-acc-eurofiber-secret.enc.yaml`
- `tunnel-pr-acc-eurofiber-web.enc.yaml` ← the one that was breaking Flux
- `tunnel-pr-acc-eurofiber.yaml`

**Follow-up (still in public repo, partial-cleanup):**

1. `kubernetes/_clusters/firefly/miscellaneous/headlamp/ingressroute.yaml` still has Traefik route definitions for `/c/p1-prod-eks`, `/c/p1-staging-eks`, `/c/pr-nonprod-aks`, `/c/pr-acc-eurofiber` paths. These routes will fail at runtime now (their `headlamp-inject-token-*` middlewares are gone), but path/cluster names are still visible. Decide whether to (a) leave (cluster names alone aren't proprietary), or (b) parameterize/move.
2. `kubernetes/_clusters/firefly/miscellaneous/headlamp/headlamp-kubeconfigs.enc.yaml` is a single Secret containing kubeconfigs for ALL clusters mixed (current-context: `p1-staging-eks`, contexts: `p1-prod-eks`, `p1-staging-eks`, `pr-nonprod-aks`, `franklinhouse`, `pr-acc-eurofiber`). Needs splitting into home-only + work-only Secrets, then re-encrypting the home half here.
3. **Syncthing**: there was also an orphan sync-conflict copy of this file (untracked, harmless to Flux but cluttery). Add `*sync-conflict*` to `.stignore` for `~/repos/calebsargeant/infra/kubernetes/_clusters/firefly/miscellaneous/headlamp/` so it doesn't happen again.
4. **Live cluster impact**: once you push, Flux's next reconcile of `misc` will SUCCEED and prune the existing `pr-acc-eurofiber-web-tunnel` Deployment/Service/Ingress from the cluster (since they're no longer in the kustomization output). Plan for re-deploying them from your private repo or 1Password before relying on work-cluster access via `headlamp.sargeant.co`.

### `core` Kustomization — NOT FIXED (needs live cluster access)

**Symptom:** `timeout waiting for: [DaemonSet/core/cloudflared] status: 'InProgress'`. Pods show 543 / 1872 restarts over ~101 days.

**Manifest review:** [kubernetes/_base/core/cloudflared/daemonset.yaml](../../kubernetes/_base/core/cloudflared/daemonset.yaml) is clean. Secret pattern is `TUNNEL_TOKEN` from `cloudflared-token`. Two concerns visible in manifest, neither confirmed as the cause:

1. **`image: cloudflare/cloudflared:latest`** — `:latest` is bad practice but unlikely to be the trigger of a 101-day chronic crashloop (image is cached on nodes).
2. **`limits.memory: 100Mi`** with no CPU limit — cloudflared with QUIC under any real load can spike well past 100Mi → OOMKill loop. Plausible cause for ~1872 restarts.

**Most likely cause (cannot confirm without logs):** the tunnel token has been invalid since around 2026-02 (101 days ago suggests Cloudflare token rotation, deletion, or quota/permission change).

**Next steps for you (need live access):**

```bash
# From a host with cluster reach (LAN or VPN):
kubectl logs ds/cloudflared -n core --previous --tail=200
kubectl describe pod -n core -l app=cloudflared | grep -A 5 "Last State\|Reason"
kubectl get events -n core --sort-by=.lastTimestamp | tail -30
```

If logs show "Unauthorized" / "tunnel not found" → rotate the token (Cloudflare Zero Trust dashboard → existing tunnel → token), re-encrypt, redeploy.
If logs show `OOMKilled` → bump `limits.memory` to `256Mi` in the daemonset.

I did NOT change the cloudflared manifest in this session — I'd rather you confirm the cause with logs first than guess.

### Cascading state

- `automation`, `backup`, `media` → Waiting on `core` / `database`. Self-clears once those are Ready.
- `database`, `fortivpn-gateway` → Reconciling (in progress).
- Plex sits in `media` (depends on `database`, not on `misc` or `core`). My sync-conflict removal only touches the `misc` Kustomization graph — pushing this PR will not bounce Plex.
- **Heads-up unrelated to this session:** the two recent commits `e233f3a` and `ced3793` change Plex's image to `lscr.io/...:latest`. These are already merged but haven't reconciled yet (media is Waiting). Whenever `database` becomes Ready and `media` reconciles, Plex will restart to pick up the new image. That's a pending change in main, not a side effect of my work.

---

## 5. Phased migration

Each phase ends with a verifiable green Flux state. **Plex is the canary** — verify it stays Ready at every phase boundary.

### Phase 0 — Stabilise (1–2 sessions, no structural moves)

1. Fix cloudflared crashloop: decode SOPS secret, inspect tunnel credentials, restart DaemonSet.
2. Fix `misc` SOPS error: identify the bad file, re-encrypt with current AGE recipient.
3. Verify cascading `Waiting` Kustomizations recover.
4. Confirm Plex pod Ready, ingress reachable.
5. **Acceptance:** `flux get ks -A` shows all Ready (or only intentionally-Suspended).

### Phase 1 — Parallel scaffold (1 session)

Set up the new layout **alongside** the old, no Flux changes:

```
kubernetes/
├── apps-new/         # build out under this name first
├── clusters-new/
├── infrastructure-new/
└── _base/ _clusters/ _components/   # untouched
```

This lets us verify kustomize-build of each new app in isolation (`kustomize build kubernetes/apps-new/<app>/prod/<app>`) without Flux touching anything live.

### Phase 2 — Migrate apps one at a time (multi-session)

**Order — safest to riskiest:**

1. Stateless test apps (excalidraw, syncthing, your-spotify) — fail-soft if broken.
2. Automation tier (atlantis, n8n, homeassistant, homebridge) — secrets need migration.
3. Observability tier (prometheus, grafana, loki, thanos) — large but mostly HelmReleases.
4. Database tier (cloudnative-pg, mariadb, postgres) — **wait: true required**.
5. Core tier (cert-manager, external-secrets, 1password, cloudflared) — gates everything.
6. **Plex last.** Migrate base + ingress + PV mapping in one PR with a kill-switch ready.

**For each app:**

a. Copy `kubernetes/_base/<cat>/<app>/` → `kubernetes/apps-new/<app>/base/<app>/`.
b. Copy `kubernetes/_clusters/firefly/<cat>/<app>/` (overlay) → `kubernetes/apps-new/<app>/prod/<app>/`.
c. Write per-app `flux-kustomization.yaml` mirroring the entry in `kubernetes/_clusters/firefly/flux-system/kustomizations.yaml`.
d. `kustomize build` test.
e. Add the new Flux `Kustomization` CR pointing at the new path; **leave the old one in place** with `suspend: true` for one reconcile to confirm new one took over.
f. Delete old paths + old Flux CR in a follow-up PR.

### Phase 3 — Rename + delete old (1 session)

- `mv kubernetes/apps-new kubernetes/apps` etc.
- Delete `_base/`, `_clusters/firefly/`, `_components/` (or move to `.old/`).
- Update CLAUDE.md / AGENTS.md to reflect new layout.

### Phase 4 — `infra-v2` enhancements (optional)

- Per-app `imagepolicy.yaml` + `imageupdateautomation.yaml` for auto-tag bumps.
- Move from age-only to age + KMS for SOPS (cloud-portable recovery).
- Add `kubernetes/clusters/firefly/system/` for cluster-scoped patches (currently spread across `_components/`).

---

## 6. Risks & mitigations

- **Plex outage during cutover.** Mitigation: migrate Plex last, in its own PR, with the old path kept Suspended (not deleted) for 24h. Watch `kubectl logs plex` + ingress.
- **PV/PVC re-binding.** Some apps use `nfs-shared` and named PVs. If a manifest copy changes the PVC spec, k8s may create a new PVC and break the data link. Mitigation: diff old vs new manifests, especially `volumeName` and `storageClassName`.
- **SOPS key handling.** The AGE key is also in `.old/`. Don't accidentally commit that path. `.old/` is gitignored — but never `git add -f` it.
- **External-Secrets / 1Password Connect dependency loop.** Several apps pull credentials via ExternalSecret. If core breaks, dependents fail to render secrets. Migrate `core` early or keep both old and new Flux CRs active in parallel until external-secrets is healthy on the new path.

---

## 7. Open questions for you

1. **Maniforge.** Is the maniforge custom CR still active, or abandoned? Both root and `_clusters/firefly/maniforge.yaml` exist — keep, consolidate, or delete?
2. **`headlamp1.sargeant.co` ingress.** `_clusters/firefly/miscellaneous/headlamp/ingressroute-p1.yaml` routes to p1 EKS / AKS clusters. Is this still wanted? (The orphan folder was deleted but the routing file remains.)
3. **AGENTS.md staged empty.** Intentional first commit? Or unstage?
4. **`.sops.yaml` at repo root is gitignored but tracked nowhere.** New contributors cloning the repo won't get the AGE recipient. Move into the repo (tracked) since the recipient is public-key material, not a secret?
5. **External clusters in headlamp.** `headlamp/middleware-franklinhouse.enc.yaml`, `kubeconfig-franklinhouse.enc.yaml` exist. Are those still valid after the franklinhouse cluster moved to `infra-v2`?
