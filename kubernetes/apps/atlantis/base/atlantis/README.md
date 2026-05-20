# Atlantis for Terragrunt/Terraform Pull Request Automation

This directory contains the Kubernetes manifests for deploying Atlantis on the firefly cluster. Auth uses a **GitHub App** with credentials sourced from **OCI Vault** via `ExternalSecret`.

## What's included

| File | Purpose |
| --- | --- |
| `deployment.yaml` | Atlantis server, mounts the App PEM at `/etc/atlantis/github-app/private-key.pem` |
| `service.yaml` | ClusterIP service |
| `ingress.yaml` | Public ingress at `atlantis.sargeant.co` |
| `pv.yaml` + `pvc.yaml` | Persistent storage for `/atlantis-data` |
| `configmap.yaml` | Server-side Atlantis config (Terragrunt workflow, repo allow-list) |
| `serviceaccount.yaml` | RBAC |
| `externalsecret.yaml` | Pulls App ID + PEM + webhook secret from OCI Vault into `Secret/atlantis` |
| `secret-aws.yaml.template`, `secret-azure.yaml.template` | Optional SOPS-encrypted cloud-provider creds (AWS access keys / Azure SP) — orthogonal to GitHub auth |

## Initial setup (one-time)

### 1. Create the GitHub App

Browser-only (gh CLI doesn't support App creation). Go to https://github.com/settings/apps/new and fill in:

| Field | Value |
| --- | --- |
| GitHub App name | `atlantis-architect` (this repo's actual App; any unique name works if you're forking) |
| Homepage URL | `https://atlantis.sargeant.co` |
| Webhook URL | `https://atlantis.sargeant.co/events` |
| Webhook secret | Generate with `openssl rand -hex 32` — save this |
| Repository permissions | Administration: Read · Checks: R/W · Contents: R/W · Issues: R/W · Pull requests: R/W · Commit statuses: R/W (Metadata: auto-checked Read) |
| Subscribe to events | Issue comment, Pull request, Pull request review, Pull request review comment, Push |
| Where can this GitHub App be installed | Only on this account |

Click **Create GitHub App**.

### 2. Install the App on your repo(s)

App settings → **Install App** → next to your account → **Only select repositories** → pick `CalebSargeant/infra` (and any other Terraform-managed repos) → **Install**.

### 3. Generate the App's private key

App settings → note the **App ID** (a number) → **Private keys** → **Generate a private key** → downloads `atlantis-architect.YYYY-MM-DD.private-key.pem` (or whatever you named the App).

### 4. Store the 3 values in OCI Vault

| OCI Vault secret name | Value |
| --- | --- |
| `atlantis-github-app-id` | App ID number (as a string) |
| `atlantis-github-app-private-key` | Full content of the `.pem` file (multi-line, including `-----BEGIN/END RSA PRIVATE KEY-----` lines) |
| `atlantis-github-webhook-secret` | The webhook secret you generated in step 1 |

The same vault/`ClusterSecretStore` is already wired (see `kubernetes/_base/core/external-dns-cloudflare/externalsecret.yaml`, `kubernetes/_base/core/cloudflared/externalsecret.yaml` for examples).

### 5. Deploy

`externalsecret.yaml` is already part of the Kustomization. After Flux reconciles, `Secret/atlantis` is materialized in `automation` namespace with keys `app-id`, `app-key-pem`, `webhook-secret`. The Deployment mounts the PEM and starts the server with App auth.

## GCP service account (required for any terragrunt project with GCS state)

All terragrunt projects in this repo use a GCS backend (`sargeant-prod-terraform-state`) and the google provider impersonates `deployer@magmamoose-terraform.iam.gserviceaccount.com`. Atlantis needs a service-account key to (a) read/write the state bucket and (b) mint impersonation tokens for the deployer SA. Without this, terragrunt fails at dependency resolution with `Backend initialization required` → cascading `Unknown variable: dependency` errors.

For v0 we **reuse the same SA key that local terragrunt uses** — the JSON file `terraform/.service-account.json` falls under the `credentials = ...` lookup in `terraform/terragrunt.hcl`. That SA already has the right state-bucket + impersonation bindings (since local plans work), so no new IAM is needed.

One-time upload (run once):

```bash
VAULT=ocid1.vault.oc1.eu-amsterdam-1.fruyd6i7aagf4.abqw2ljrzcituk5pndpbgsvhtkgenvf2ae7xnlbctmskmcfj2gw6xsjhbgfq
COMPARTMENT=ocid1.tenancy.oc1..aaaaaaaaq7zpfzcaj4amfz7xwv33rlsopwd4m2ydhgjdidoan67vry5ejlsq
# Same KMS key used by atlantis-github-app-id et al; look up via:
#   oci vault secret list --compartment-id $COMPARTMENT --region eu-amsterdam-1 \
#     --query 'data[?"secret-name"==`atlantis-github-app-id`]."key-id"' --raw-output
KEY=ocid1.key.oc1.eu-amsterdam-1.fruyd6i7aagf4.abqw2ljr2tquiix4j3greeqmtg3hxutkve2u5vrhk5umbz2w4drizdoqy3ca

oci vault secret create-base64 \
  --compartment-id $COMPARTMENT \
  --vault-id $VAULT \
  --key-id $KEY \
  --secret-name atlantis-gcp-sa-key \
  --secret-content-content "$(base64 -i terraform/.service-account.json)" \
  --region eu-amsterdam-1
```

After Flux reconciles, `externalsecret-gcp.yaml` materializes `Secret/atlantis-gcp` with key `key.json`, the deployment mounts it at `/etc/atlantis/gcp/key.json`, and `GOOGLE_APPLICATION_CREDENTIALS` points the GCS backend + google provider at it.

Rotation: generate a new key on the SA, re-run the `oci vault secret create-base64` command (OCI versions secret content automatically; ESO picks up the new version on its next refresh — `kubectl -n automation annotate externalsecret atlantis-gcp force-sync=$(date +%s)` to force).

**Future hardening (tracked, not v0)**: cut a dedicated `atlantis@magmamoose-terraform.iam.gserviceaccount.com` SA with least-privilege bindings (`storage.objectUser` on the state bucket + `serviceAccountTokenCreator` on `deployer@`), so atlantis isn't running as the same identity as your local terragrunt.

## Optional cloud-provider credentials

For Atlantis to actually drive Terraform that needs AWS / Azure / etc., create the optional secrets:

```bash
cp secret-aws.yaml.template secret-aws.yaml
# Edit secret-aws.yaml — fill in your credentials
sops -e secret-aws.yaml > secret-aws.enc.yaml
rm secret-aws.yaml

# Then add `- secret-aws.enc.yaml` to kustomization.yaml's resources
```

These map to env vars `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `ARM_CLIENT_ID`, etc. — they're independent of the GitHub App auth above.

## Supported environments

- AWS (via AWS credentials)
- Azure (via Azure service principal)
- GCP (via existing service account)
- OCI (via existing configuration)
- Cloudflare (via existing configuration)

## Usage

Once deployed, Atlantis will:

1. Run `terraform plan` (or `terragrunt plan`) when a PR with infrastructure changes is opened/updated
2. Post the plan output as a PR comment
3. Apply with `atlantis apply` (after PR approval, depending on workflow)

See [`docs/guides/atlantis-setup.md`](../../../../../docs/guides/atlantis-setup.md) for detailed setup and usage instructions.

## Why GitHub App over PAT

- Per-installation, short-lived tokens (auto-rotated by Atlantis using the PEM to mint a fresh JWT) vs static PAT
- Granular per-repo permissions (no need for a broad `repo` scope on a user account)
- Not tied to any user — survives team-member changes
- Better audit trail in GitHub
