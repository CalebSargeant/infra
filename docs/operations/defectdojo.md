# DefectDojo

DefectDojo runs in the `security` namespace from `kubernetes/apps/defectdojo`
and is exposed at `https://defectdojo.magmamoose.com`.
Flux installs the upstream DefectDojo Helm chart, but the app uses shared firefly
infrastructure instead of bundled subcharts:

- PostgreSQL is the shared CloudNativePG cluster at `postgres-rw.database.svc.cluster.local`.
- Valkey is the shared authless broker at `valkey.database.svc.cluster.local`.
- App secrets are sourced from OCI Vault through `ExternalSecret/defectdojo`.
- Public access enters through the Cloudflare Tunnel and `oauth2-proxy`.

## Required OCI Vault Secrets

The `defectdojo` Kubernetes Secret is managed by External Secrets Operator. These
OCI Vault secret names must exist:

| OCI Vault secret | Kubernetes key |
|---|---|
| `defectdojo-secret-key` | `DD_SECRET_KEY` |
| `defectdojo-credential-aes-256-key` | `DD_CREDENTIAL_AES_256_KEY` |
| `defectdojo-admin-password` | `DD_ADMIN_PASSWORD` |
| `defectdojo-metrics-http-auth-password` | `METRICS_HTTP_AUTH_PASSWORD` |

`METRICS_HTTP_AUTH_PASSWORD` is still required by the chart-rendered nginx
container even when metrics are disabled.

## Valkey Chart Quirk

The chart always injects `DD_CELERY_BROKER_PASSWORD` from
`defectdojo-valkey-specific:valkey-password`. Because firefly's shared Valkey is
authless, this repository provides `valkey-password-empty.yaml`, a Kubernetes
Secret whose value is intentionally empty. Do not set `createValkeySecret: true`
for this deployment: the chart generates a random password for empty values,
which makes DefectDojo try to authenticate to an authless broker.

## Resource Notes

Celery beat needs more than 128Mi during startup while Django imports models and
checks the database/broker. Keep the beat limit at 256Mi or higher unless a live
KRR report proves it is safe to reduce.

## Recovery Checks

```bash
export KUBECONFIG=~/.kube/firefly.yaml

kubectl get externalsecret -n security defectdojo defectdojo-postgresql-specific oauth2-proxy
kubectl get secret -n security defectdojo-valkey-specific
kubectl get pods -n security -l app.kubernetes.io/instance=defectdojo
flux reconcile kustomization prod-defectdojo -n flux-system
flux reconcile helmrelease defectdojo -n security
```
