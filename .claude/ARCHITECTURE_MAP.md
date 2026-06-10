# Architecture Map

```
Git → Atlantis (terragrunt plan/apply)    → cloud (GCP/OCI/Cloudflare)
Git → FluxCD (watches main)               → k3s firefly (RPi) → apps + infra tiers
Ansible → bootstraps systems/k3s          → runtime-only after Flux owns the cluster
```

Three sources of truth (in flow order):
1. `terraform/` — Terragrunt wraps TF; GCS backend; 1 leaf = 1 Atlantis project = 1 state file
2. `ansible/` — host config, k3s bootstrap, network devices (idempotent roles)
3. `kubernetes/` — Flux: cluster root → infrastructure (configs→controllers→services) + apps

Secrets order: **OCI Vault → 1Password → SOPS (last resort, `.enc.yaml` only)**.

franklinhouse cluster is NOT here — lives in `calebsargeant/infra-v2`. This repo is firefly-only.
