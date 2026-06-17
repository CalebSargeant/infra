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
   - `github-pat-defectdojo` — a **fine-grained github.com PAT** scoped to the
     target repo(s): **Issues: read/write**, **Metadata: read**. (DefectDojo has
     no GitHub App support — a PAT is the only option; this is the least-privilege
     form.) **github.com only** — see the GitHub Enterprise note below.
     This is optional: skip it entirely and findings still import + Slack still
     fires; only GitHub issue creation is disabled.
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

## GitHub Enterprise (*.ghe.com)

DefectDojo OSS can push issues **only to github.com**. The `GITHUB_Conf` model has
just `configuration_name` + `api_key` (no base-URL field), and the push code calls
PyGithub `Github(auth=...)` with no `base_url`, so it always hits `api.github.com`.
Consequences:

- A `tenant.ghe.com` PAT here will **not** work — DefectDojo would send it to
  github.com. PATs are per-server, so github.com and a GHE tenant always need
  separate tokens *and* separate endpoints, and DefectDojo only knows the github.com one.
- Multiple `GITHUB_Conf` entries are allowed (e.g. different github.com orgs/PATs,
  linked per-product via `GITHUB_PKey.git_conf`) but they **all** target github.com.
- For GHE-hosted repos you have three options: (a) import findings into DefectDojo
  but don't auto-open GHE issues; (b) extend `sync.py` to open GHE issues directly
  via PyGithub `base_url=https://<tenant>.ghe.com/api/v3` with a GHE PAT (bypasses
  DefectDojo's github.com-only push); (c) patch the DefectDojo image (not advised).
  Ask if you want (b) wired in.

## Notes / limits

- Integration secrets are **optional** — the init-container `SLACK_TOKEN`/`GITHUB_PAT`
  and the CronJob `DTRACK_API_KEY` are `optional: true`, so missing OCI Vault keys
  never wedge the DefectDojo rollout or spawn `CreateContainerConfigError` cron pods.
  Slack + GitHub PATs live in separate ExternalSecrets so a missing GitHub key
  doesn't block Slack.
- OSS DefectDojo's GitHub push is lightly maintained — issues are opened by the sync
  job calling `add_external_issue` directly (the importer never does). Findings must be
  **Active + Verified** to push, so mapped projects are reimported with `verified=true`.
- Issue creation is capped per run (`MAX_GITHUB_ISSUES_PER_RUN`, default 50) and floored
  at `GITHUB_MIN_SEVERITY` (default High) to limit noise; remainder carries to next run.
- Multi-version DTrack projects sharing a name merge into one DefectDojo product.
