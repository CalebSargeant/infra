# security-integrations

Glue between **Dependency-Track**, **DefectDojo**, **GitHub**, and **Slack** — the
parts that none of those tools expose as config-as-code (their settings live in
each app's database, not in Helm values).

## What runs

| Piece | Where | Does |
|-------|-------|------|
| `dd-bootstrap` init container | DefectDojo django pod (`apps/defectdojo`, via `helmrelease.yaml` + `configmap-bootstrap.yaml`) | On every (re)deploy: enables DefectDojo **Slack** notifications, routes import/SLA events to Slack, enables **GitHub** + creates the `GITHUB_Conf` (PAT). |
| `dt-defectdojo-sync` CronJob | here (`security` ns), hourly | Exports each Dependency-Track project's findings (FPF) → DefectDojo `reimport-scan` (auto-creates product/engagement). For projects in `github-repo-map`, links the product to a GitHub repo and opens issues for new **Active+Verified** High/Critical findings. |

Both run the `defectdojo/defectdojo-django` image (pinned to chart appVersion
**2.58.4** — bump together with the DefectDojo HelmRelease on upgrades), because
DefectDojo's GitHub config + finding→issue push are Django-ORM-only (no REST API).

## One-time manual prerequisites

1. **OCI Vault secrets** (the ExternalSecrets reference these keys):
   - `dependency-track-api-key` — a Dependency-Track API key for a team with
     `VIEW_PORTFOLIO` + `VIEW_VULNERABILITY` (DTrack → Administration → Teams → API Keys).
   - `github-pat-defectdojo` — a **fine-grained** GitHub PAT scoped to the target
     repo(s): **Issues: read/write**, **Metadata: read**. (DefectDojo has no GitHub
     App support — a PAT is the only option; this is the least-privilege form.)
2. **Slack** — invite the bot behind `slack-bot-token` (the same one Alertmanager/Flux
   use) to the target channel. Default channel is `#engineering-alerts`; change it via
   `SLACK_CHANNEL` on the `dd-bootstrap` init container in
   `apps/defectdojo/base/helmrelease.yaml`.
3. **GitHub repo map** — edit `configmap-github-repo-map.yaml` (`repo-map.json`):
   ```json
   { "<dtrack project name>": "<owner>/<repo>" }
   ```
   Only mapped projects push GitHub issues; everything else is still imported into
   DefectDojo. The mapping can't be inferred, so it's curated by hand.

## Verify

```bash
kubectl -n security get externalsecret defectdojo-integrations security-integrations   # SecretSynced
kubectl -n security logs -l app.kubernetes.io/name=defectdojo -c dd-bootstrap          # init-container log
kubectl -n security create job --from=cronjob/dt-defectdojo-sync sync-test             # run sync now
kubectl -n security logs job/sync-test -f
```

Then in DefectDojo: **System Settings** shows Slack + GitHub enabled; a GitHub
Configuration exists; products (one per DTrack project) carry imported findings.

## Notes / limits

- OSS DefectDojo's GitHub push is lightly maintained — issues are opened by the sync
  job calling `add_external_issue` directly (the importer never does). Findings must be
  **Active + Verified** to push, so mapped projects are reimported with `verified=true`.
- Issue creation is capped per run (`MAX_GITHUB_ISSUES_PER_RUN`, default 50) and floored
  at `GITHUB_MIN_SEVERITY` (default High) to limit noise; remainder carries to next run.
- Multi-version DTrack projects sharing a name merge into one DefectDojo product.
