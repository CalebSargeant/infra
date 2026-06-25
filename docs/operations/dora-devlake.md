# DORA Metrics (Apache DevLake)

`kubernetes/apps/devlake` deploys [Apache DevLake](https://devlake.apache.org/) —
the open-source engineering-metrics platform — to compute and dashboard the four
**DORA** metrics (deployment frequency, lead time for changes, change-failure rate,
failed-deployment recovery time). This closes the golden-stack's stated #1 gap:
*measuring* delivery instead of optimising by feel.

## What's deployed

All on the amd64 `worker` node, in the `devlake` namespace:

- **config-ui** (`devlake-ui:4000`) — set up data connectors here.
- **lake** (`devlake-lake:8080`) — the backend/collector.
- **grafana** (`devlake-grafana`) — the prebuilt DORA dashboards (proxied at
  config-ui's `/grafana`).
- **mysql** — DevLake's own bundled MySQL on a Longhorn PVC.

### Why bundled MySQL (not the shared CNPG)

DevLake is **MySQL-centric**: its Helm chart's PostgreSQL path is a commented
secondary option and DevLake does **not** support MariaDB. Rather than fight the
chart onto CNPG (Postgres) blind, it runs its own bundled MySQL — a deliberate,
documented exception to the shared-CNPG convention. The MySQL is ClusterIP-only and
never exposed. Revisit if you want to consolidate onto external Postgres later.

## Access (and why it's not public yet)

DevLake's config-ui has **no authentication by default**, so it is **not** exposed
through the Cloudflare tunnel in this change — an open admin UI on the internet
would be a real risk. Reach it locally:

```bash
kubectl -n devlake port-forward svc/devlake-ui 4000:4000
# http://localhost:4000  (DORA dashboards at /grafana)
```

**Follow-up to expose it**: add a Cloudflare Access app (Caleb-only) for
`devlake.magmamoose.com` + a tunnel rule → `devlake-ui.devlake:4000`, the same
edge-auth pattern as the other gated dashboards. Do this before any public exposure.

## Setup

1. **OCI Vault prerequisite**: create `devlake-encryption-secret` once (DevLake
   encrypts stored connector creds with it — never rotate it after data exists):
   ```bash
   openssl rand -base64 2000 | tr -dc 'A-Z' | fold -w 128 | head -n 1
   ```
2. Once running, open config-ui and add the **GitHub** connector (a PAT) for your
   orgs, plus a **Deployments** source (GitHub deployments / a webhook) so DevLake
   can compute deployment frequency + recovery time. Connector creds are entered in
   the UI and stored (encrypted) in DevLake's DB — not in Git.
