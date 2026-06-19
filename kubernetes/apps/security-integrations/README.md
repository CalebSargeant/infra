# security-integrations

Glue between **Dependency-Track**, **DefectDojo**, **GitHub**, and **Slack** — the
parts none of those tools expose as config-as-code (their settings live in each
app's database, not in Helm values). Designed to be **zero-touch / reproducible**:
no per-repo config lives in this (public) repo.

## What runs

| Piece | Where | Does |
|-------|-------|------|
| `dd-bootstrap` init container | DefectDojo django pod (`apps/defectdojo`, via `helmrelease.yaml` + `configmap-bootstrap.yaml`) | On every (re)deploy: enables DefectDojo **Slack** notifications (reusing `slack-bot-token`), routes import/SLA events to Slack, flips `enable_github` so the UI links issues. |
| `dt-defectdojo-sync` CronJob | here (`security` ns), hourly | Exports each DTrack project's findings (FPF) → DefectDojo `reimport-scan` (auto-creates product/engagement). Then **auto-resolves a GitHub repo by name** and opens issues for new Active High/Critical findings (dedup via `GITHUB_Issue`). |

Both run the `defectdojo/defectdojo-django` image (pinned to chart appVersion
**2.58.4** — bump together with the DefectDojo HelmRelease on upgrades): the
bootstrap needs the ORM, and the sync needs the ORM (token + dedup records) plus
`requests`/PyGithub.

## Zero-touch GitHub issue auto-discovery

There is **no repo list in git**. You declare GitHub *accounts* once in the OCI
Vault key **`github-issue-targets`**, and the sync maps a DTrack project to a repo
of the **same name** under those accounts' owners. This handles **github.com
(first-class) and GitHub Enterprise (`*.ghe.com`)** in one path by talking to each
server's API with its own token — DefectDojo's own integration is github.com-only,
so the sync drives GitHub directly instead.

`github-issue-targets` = a JSON array, **github.com first** (first match wins):

```json
[
  { "api_url": "https://api.github.com",        "owners": ["<user-or-org>"], "token": "<github.com PAT>" },
  { "api_url": "https://<host>.ghe.com/api/v3", "owners": ["<org>"],         "token": "<GHE PAT>" }
]
```

- Tokens: **fine-grained PATs**, **Issues: read/write** + **Metadata: read**. Scope
  to *all repositories* for true zero-touch (new repos auto-covered), or list
  specific ones. PATs are per-server, so github.com and a GHE tenant each need their own.
- Servers, owners, and tokens **all** live in this one vault key — no repo names or
  enterprise hostnames touch git, and the whole system reproduces by restoring it.
- Omit the key entirely and GitHub issue push is simply disabled (findings still
  import into DefectDojo, Slack still fires).

## One-time manual prerequisites

1. **OCI Vault**:
   - `dependency-track-api-key` — a DTrack API key for a team with `VIEW_PORTFOLIO`
     + `VIEW_VULNERABILITY` (DTrack → Administration → Teams → API Keys).
   - `github-issue-targets` — the JSON above (optional; only for GitHub issues).
2. **Slack** — invite the bot behind `slack-bot-token` to the target channel
   (default `#engineering-alerts`; change via `SLACK_CHANNEL` on the init container
   in `apps/defectdojo/base/helmrelease.yaml`).

All integration secrets are `optional: true` on their consumers, so a missing key
never wedges the DefectDojo rollout or spawns `CreateContainerConfigError` pods.

## Verify

```bash
kubectl -n security get externalsecret defectdojo-integrations dependency-track... github-issue-targets   # SecretSynced
kubectl -n security logs -l app.kubernetes.io/name=defectdojo -c dd-bootstrap                              # init-container log
kubectl -n security create job --from=cronjob/dt-defectdojo-sync sync-test                                 # run sync now
kubectl -n security logs job/sync-test -f
```

In DefectDojo: System Settings shows Slack enabled; products (one per DTrack
project) carry imported findings; mapped projects get GitHub issues with a
`defectdojo` label, linked back from the finding.

## Notes / limits

- Auto-discovery matches **project name == repo name**. Projects whose name doesn't
  match a repo under any configured owner are imported but don't open issues (logged).
- Issue creation is capped per run (`MAX_GITHUB_ISSUES_PER_RUN`, default 50) and
  floored at `GITHUB_MIN_SEVERITY` (default High) to limit noise; the rest carries
  to the next run. Dedup is via DefectDojo's `GITHUB_Issue` (one per finding).
- Multi-version DTrack projects sharing a name merge into one DefectDojo product.
