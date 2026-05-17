# AI Agent Guide for Monolithic Infrastructure Repository

This guide provides essential architectural knowledge for AI agents working in this infrastructure-as-code repository.

## Big Picture: Multi-Tier Infrastructure

This monolithic repository manages a **distributed home lab** across multiple cloud providers and a local Kubernetes cluster:

- **Kubernetes Core**: Single-node k3s on Raspberry Pi (primary workload cluster "firefly")
- **Cloud Infrastructure**: Multi-provider Terraform via Terragrunt (GCP, OCI, Cloudflare, AWS/Azure future)
- **Configuration Management**: Ansible for system setup, bootstrapping, and complex provisioning
- **GitOps Pipeline**: FluxCD v2 watches this repo and auto-deploys Kubernetes manifests

### Critical Insight: Everything is Declared as Code

No manual kubectl apply or SSH commands. Changes flow through: Git → Terraform/Ansible → FluxCD → Cluster. Breaking this flow causes drift.

## Architecture Patterns You'll Encounter

### 1. Terragrunt Layering (terraform/)

Terragrunt manages configuration inheritance and state, auto-generating Terraform files:

```
terraform/
  root.hcl           # Version pins, remote state config (GCS)
  terragrunt.hcl     # Default backend configuration
  modules/gcp/       # Reusable GCP modules
  gcp/prod/          # Provider-specific environments (uses root.hcl)
  oci/prod/          # OCI infrastructure
  cloudflare/prod/   # Cloudflare DNS/edge
```

**Key Pattern**: Each provider directory structure mirrors cloud regions/environments. Terragrunt auto-generates `backend.tf` and `provider.tf` - **don't manually edit these files** (they're marked `if_exists = "overwrite"`).

### 2. Kustomize Hierarchical Overlays (kubernetes/)

Multi-layer manifests with cluster-specific patches:

```
kubernetes/
  _base/              # Generic, reusable deployments (1password-connect, external-dns, media apps)
  _components/        # Cross-cutting concerns (node-selectors/pi, resource-profiles)
  _clusters/firefly/  # Active overlay → patches _base resources + applies SOPS decryption
  apps/               # New infra-v2-style layout (apps/<app>/{base,prod}/<app>/), being phased in
  clusters/firefly/   # New cluster-level entry point for the apps/ tree (inert until wired into Flux)
```

The `franklinhouse` cluster lives in a separate public repo, [calebsargeant/infra-v2](https://github.com/CalebSargeant/infra-v2); this repo is firefly-only. See `docs/operations/kubernetes-restructure-plan.md` for the in-progress migration from `_base/_clusters/` to `apps/clusters/`.

**Key Pattern**: A firefly overlay `kustomization.yaml` patches all Kustomizations labeled `app.kubernetes.io/sops=enabled` to add SOPS decryption provider. Resource profiles (like `c.medium`: 500m-2 CPU, 1-4Gi memory) are Kustomize components targeting labels.

### 3. Secret Management (Preferred → Fallback Order)

**Always prefer external secret stores over in-Git encryption.** Use the following priority order:

1. **OCI Vault + ExternalSecrets** (preferred for runtime cluster secrets) — store the secret in OCI Vault, then create an `ExternalSecret` CR pointing to it. Config lives in `kubernetes/_clusters/firefly/core/external-secrets/`.
2. **1Password Connect + ExternalSecrets** (preferred for app credentials & shared team secrets) — store in 1Password, inject via `OnePasswordItem` or `ExternalSecret`. Config lives in `kubernetes/_base/core/1password-connect/`.
3. **SOPS + Age** (last resort — only when a secret must live in Git with no external store available) — Age key created in `flux-system` namespace (Ansible role: `k3s-sops-age-secret`); Kustomization resources labeled `app.kubernetes.io/sops=enabled` are auto-decrypted by Flux. Workflow: `sops -e secret.yaml > secret.enc.yaml` → commit only `.enc.yaml`.

**Never commit plaintext secrets regardless of which method is used.** The SOPS `.sops.yaml` configuration is in the repo root if fallback encryption is needed.

### 4. Atlantis PR Integration

GitHub PRs trigger Terraform planning/applying via Atlantis (deployed in Kubernetes):

```yaml
# atlantis.yaml defines projects
projects:
  - name: gcp-infrastructure
    dir: terraform/gcp
    terraform_version: v1.11.3
    workflow: terragrunt  # Custom workflow auto-detects terragrunt.hcl vs plain TF
```

**Workflow**: Push to feature branch → PR → Atlantis comments with `terragrunt plan` output → `atlantis apply` comment → merge.

## Critical Developer Workflows

### Terraform Changes

```bash
cd terraform/gcp/prod  # or your provider/environment
terragrunt plan        # Auto-loads root.hcl config inheritance
terragrunt apply
```

### Ansible Playbook Validation

```bash
cd ansible
ansible-playbook -i hosts your-playbook.yml --check  # Dry-run
ansible-playbook -i hosts your-playbook.yml          # Execute
```

### Kubernetes Manifest Testing

```bash
# Validate Kustomize builds correctly
kustomize build kubernetes/_clusters/firefly

# Test w/o applying
kubectl apply -k kubernetes/_clusters/firefly --dry-run=client

# Preview changes
kubectl diff -k kubernetes/_clusters/firefly

# Manually trigger Flux reconciliation
flux reconcile source git flux-system -n flux-system
flux reconcile kustomization core -n flux-system    # or: misc, automation, media, etc.
```

### Pre-Commit Hooks

```bash
# Custom hook system at: https://github.com/calebsargeant/pre-commit-hooks
pre-commit run --all-files  # Must pass before committing
```

## Project-Specific Conventions

### Ansible Playbooks Organization

**Prefix pattern** indicates target scope:
- `pi-*.yml` → Raspberry Pi bootstrap/config
- `docker-*.yml` → Docker container deployments (host-specific: `-firefly`, `-server`)
- `kubernetes-*.yml` → k3s cluster setup
- `server-*.yml` → Non-Pi servers
- Network equipment: `cisco-*.yml`, `mikrotik-*.yml`

### Terraform Module Naming

Provider-specific modules use `_modules/` subdirectories (e.g., `terraform/oci/_modules/network`). Not to be confused with `terraform/modules/gcp/` which contains modules referenced across environments.

### Kubernetes Namespaces

Top-level `_base/` directories align with namespaces:
- `core/` → networking, secrets, DNS (1password-connect, cloudflared, external-dns)
- `database/` → postgres, stateful systems
- `media/` → media apps (sonarr, radarr, etc. w/ gluetun sidecars)
- `automation/` → Atlantis, n8n, workflow engines
- `observability/` → monitoring (Prometheus metrics in opencost, fluent-bit)
- `kube-system/` → cluster infrastructure

**Sidecar Component Pattern**: Media apps use Kustomize components to inject gluetun/wireguard sidecars for VPN bypass (e.g., `kubectl apply -k kubernetes/_clusters/firefly/media/radarr`).

### Resource Profiles (Cloud Flavor Equivalents)

AWS-style naming mapped to Raspberry Pi constraints (requests → limits):
- `t.small` → cpu 250m → 1, memory 256Mi → 1Gi  (burstable, 1:1)
- `c.medium` → cpu 500m → 2, memory 1Gi → 4Gi  (compute-optimised, 1:2)
- `m.large` → cpu 1 → 4, memory 4Gi → 16Gi  (memory-optimised, 1:4)

Full table in `kubernetes/_components/resource-profiles/kustomization.yaml` (5 families × 8 sizes: `p.*` 2:1 cpu/mem, `t.*` 1:1, `c.*` 1:2, `m.*` 1:4, `r.*` 1:8 — each from `pico` to `2xlarge`). Patch deployments by labelling them with `resource-profile=<name>` and applying the component.

## Integration Points & Dependencies

### External Service Integrations

| Service | Purpose | Config Location |
|---------|---------|-----------------|
| Google Cloud | Terraform state backend (GCS bucket `${company}-${environment}-terraform-state`, per `terraform/root.hcl`) | `terraform/root.hcl` remote_state |
| OCI (Oracle) | Cloud infrastructure provisioning | `terraform/oci/` + env vars: OCI_TENANCY_OCID, OCI_USER_OCID, etc. |
| Cloudflare | DNS automation, edge (external-dns plugin) | `terraform/cloudflare/` |
| 1Password Connect | Secret injection into Kubernetes | `kubernetes/_base/core/1password-connect/` |
| Flux GitRepository | Git polling for deployments | `kubernetes/_clusters/firefly/flux-system/` defines git URLs |

### Cross-Component Communication

1. **Terraform → Kubernetes**: GCP service account credentials stored as SOPS-encrypted secret, external-secrets fetches from OCI Vault
2. **Ansible → Kubernetes**: `k3s-sops-age-secret` role creates Age encryption key in cluster during bootstrap
3. **FluxCD → Ansible**: Post-bootstrap, Flux owns all Kubernetes state; Ansible is runtime-only

## Database Conventions (CNPG)

All PostgreSQL workloads run through **one shared CloudNativePG (CNPG) cluster** (`postgres` in the `database` namespace). **Do not create additional CNPG `Cluster` objects** unless there is an explicit environment isolation requirement (e.g., a separate dev, staging, or testing environment).

### The Single-Instance Rule

- The shared cluster is defined in `kubernetes/_base/database/postgres/cluster.yaml` (`name: postgres`, `namespace: database`)
- When an app needs a database, create a new **database + user** inside the existing cluster — not a new `Cluster` resource
- Services available to apps:
  - Read-write: `postgres-rw.database.svc.cluster.local:5432`
  - Read-only: `postgres-ro.database.svc.cluster.local:5432`

### When a New CNPG Instance IS Acceptable

Only spin up an additional `Cluster` when:
- Creating a separate environment (dev, staging, testing)
- Running an isolated experiment that must not touch shared production data
- Explicitly requested by the user for environment separation

### Adding a Database to the Shared Cluster

Use a CNPG `Database` and `User` CR targeting the existing cluster, rather than bootstrapping a new one:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Database
metadata:
  name: myapp
  namespace: database
spec:
  cluster:
    name: postgres   # always point to the shared cluster
  name: myapp
  owner: myapp
```

### Migrating Away from SQLite

**If you encounter an app using SQLite, migrate it to CNPG.** SQLite binds data to a single disk and breaks portability, HA, and backups. It is not acceptable for persistent workloads in this cluster.

- Known outstanding migration: Home Assistant (`kubernetes/_base/automation/homeassistant/daemonset.yaml`) — marked `# todo: move from sqlite to postgres`
- When migrating, provision a new database in the shared cluster (see pattern above), update the app's connection env vars to point at `postgres-rw.database.svc.cluster.local`, and remove any SQLite volume mounts
- If the app doesn't natively support PostgreSQL, check for a supported adapter/plugin before assuming SQLite is the only option

## When Making Changes

### Before Editing Terraform

- Understand which provider (check directory path)
- Run `terragrunt validate-all` from repo root
- Test with `terragrunt plan` in isolated env to avoid state mutations
- Atlantis will auto-plan on PR

### Before Editing Kubernetes Manifests

- Changes to `_base/` affect all clusters
- Changes to `_clusters/firefly/` affect only firefly
- Run `kustomize build kubernetes/_clusters/firefly` to validate
- Test labels match resource profiles/node selectors
- Encrypted secrets: remember `.enc.yaml` suffix

### Before Editing Ansible

- Use `--check` flag for safety
- Test against safe hosts first (not production)
- Roles should be idempotent
- Variables go in `ansible/vars/`, not playbooks

## Raspberry Pi Constraints (Critical!)

This is **not** generic Kubernetes:

- **Memory**: ~4-8GB available after OS/k3s overhead
- **CPU**: 8 cores but weak single-threaded performance
- **Storage**: SD card or external SSD (NFS used for shared mount points)
- **Network**: Resource-heavy monitoring/sidecars will throttle others

**Always include resource limits/requests in deployments.** Oversized pods cause node evictions. Use `t.small` profile for most media apps, `c.medium` only for multi-core workloads.

## Files to Know

| File | Purpose |
|------|---------|
| `.pre-commit-config.yaml` | Custom hook system |
| `.sops.yaml` | SOPS encryption key configuration |
| `atlantis.yaml` | Terraform PR automation config |
| `ATLANTIS_SETUP.md` | Deployment and secret setup guide |
| `terraform/root.hcl` | Terragrunt inheritance root + version pins |
| `kubernetes/_clusters/firefly/kustomization.yaml` | Entry point for cluster deployment |
| `ansible/hosts.yaml` | Inventory (IP addresses, groups) |

## Public Repository — Security Rules (Non-Negotiable)

**This is a public GitHub repository.** Every commit and push is visible to the world. Violating these rules leaks credentials publicly and is irreversible even after deletion (Git history, forks, caches).

- **Never commit secrets, tokens, passwords, API keys, or private keys** in plain text — prefer storing them in **OCI Vault** or **1Password** and referencing via ExternalSecrets; only fall back to SOPS (`sops -e secret.yaml > secret.enc.yaml`, commit only `.enc.yaml`) when no external store is available
- **Never commit proprietary code, licensed third-party source, or internal business logic** that isn't meant for public distribution
- **Never commit cloud credentials** (GCP service account JSON, OCI private keys, Cloudflare tokens) — use environment variables or the existing `.service-account.json` gitignore pattern
- **Scan before pushing**: if you've written anything that looks like a secret, stop and verify it is either already encrypted or covered by `.gitignore`
- **Terraform state files** (`*.tfstate`, `*.tfstate.backup`) must never be committed — state is stored remotely in GCS
- **OCI config** (`terraform/.oci-config.ps1`) and **GCP credentials** (`terraform/.service-account.json`) are gitignored — do not reference or recreate them in tracked files

If you accidentally stage a secret, remove it with `git reset HEAD <file>` before committing. If it has already been committed, treat the credential as compromised and rotate it immediately.

## Red Flags & Common Mistakes

1. **Manually editing generated files** (`backend.tf`, `provider.tf`) — they regenerate with `terragrunt apply`
2. **Reaching for SOPS first** — prefer OCI Vault or 1Password ExternalSecrets; SOPS is last resort only
3. **Over-allocating resources** to Kubernetes pods — will evict everything on Raspberry Pi
4. **Not running `--check`** before Ansible execution — can break system
5. **Assuming git == deployed** — FluxCD reconciles on intervals; force with `flux reconcile`
6. **Committing any plaintext secret to a public repo** — rotate immediately if it happens

## Definition of Done

**Work is not complete until documentation is updated.** Before considering any task finished:

1. **Update `AGENTS.md`** — if you introduced a new pattern, convention, architectural decision, or notable gotcha that future agents should know about, add it here.
2. **Update `docs/`** — if the change affects user-facing behaviour, adds a new application, changes a workflow, or modifies infrastructure: update or create the relevant page under `docs/`. These are published to https://calebsargeant.github.io/infra/.

This applies to all work: new Kubernetes apps, Terraform modules, Ansible roles, secret management changes, database additions, etc. Documentation is part of the implementation, not an afterthought.

## Immediate Next Steps for a New Agent

1. Read `README.md` for high-level overview
2. Explore `terraform/root.hcl` to understand version pinning + state management
3. Inspect `kubernetes/_clusters/firefly/kustomization.yaml` and one `_base/` app (e.g., `_base/core/cloudflared/`)
4. Check `.pre-commit-config.yaml` to understand validation before commits
5. Reference `.github/copilot-instructions.md` for detailed style/standards

## GitHub Copilot PR Reviews

When a PR is opened, **GitHub Copilot will automatically review it and may leave inline code comments** on the diff.

### Cleaning Copilot Comments

When you are asked to "clean Copilot comments" on a PR, follow this process precisely:

1. **Fetch all Copilot review comments** on the PR (comments authored by `github-copilot[bot]` or the Copilot review bot).
2. **Evaluate each comment individually**:
   - If the finding is **valid** (real bug, security issue, violation of this repo's conventions, or a meaningful improvement) → fix the code.
   - If the finding is **not valid** (false positive, stylistic preference that contradicts this project's conventions, or irrelevant to infra-as-code context) → skip it; do not modify the code.
3. **For every valid finding that was fixed**:
   - Reply to the Copilot comment in the PR explaining what was changed (e.g., `"Fixed: added resource limits per project resource-profile conventions."`).
   - **Resolve the comment thread** so it no longer appears as an open review item.
4. **For invalid findings**, leave them unresolved and unaddressed — do not reply or dismiss them without the user's explicit instruction.

### What Counts as a Valid Finding in This Repo

Given the infrastructure-as-code nature of this project, treat the following as valid findings:

- Missing `resource` limits/requests on Kubernetes `Deployment` or `StatefulSet` specs
- Unencrypted secrets committed without `.enc.yaml` suffix
- Hardcoded credentials or IP addresses that should use variables/inventory
- Terraform resources missing required outputs or using deprecated syntax
- Ansible tasks lacking `name:` fields or using non-idempotent shell commands without `creates:`/`changed_when:`
- Kustomize `_base/` changes that unintentionally affect all clusters
- Direct edits to auto-generated files (`backend.tf`, `provider.tf`)

### What to Ignore

- Generic style suggestions that conflict with this repo's existing conventions
- Suggestions to add generic error handling to Terraform/HCL (not applicable)
- Comments about test coverage (this repo has no automated test suite by design)
- Warnings about Raspberry Pi-specific configurations that are intentional constraints

---

**Documentation**: Full guides at `docs/` (published to https://calebsargeant.github.io/infra/)


