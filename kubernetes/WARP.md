# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is the Kubernetes configuration subdirectory of the monolithic infrastructure repository. It manages a single-node K3s cluster ("firefly") using a Kustomize-based GitOps architecture with Flux v2 for continuous deployment.

## Directory Structure

```
kubernetes/
├── _base/              # Reusable base configurations organized by function
│   ├── automation/     # Home automation apps (Home Assistant, Homebridge, n8n)
│   ├── backup/         # Backup solutions (Timemachine)
│   ├── core/          # Core cluster services (cert-manager, etc.)
│   ├── database/      # Database workloads (PostgreSQL)
│   ├── media/         # Media stack (Plex, Radarr, Sonarr, etc.)
│   ├── miscellaneous/ # Other applications
│   └── observability/ # Monitoring and logging
├── _clusters/         # Cluster-specific overlays
│   ├── firefly/       # Main single-node K3s cluster (Raspberry Pi 5)
│   └── franklin/      # Secondary cluster configuration
├── _components/       # Kustomize components for cross-cutting concerns
│   ├── node-selectors/
│   └── resource-profiles/  # AWS-style resource allocation profiles
└── .kusomization.workings.yaml  # Development/debugging file
```

## Architecture

### GitOps with Flux v2

The cluster uses Flux v2 for declarative GitOps-based deployments. Configurations are applied through a hierarchy:

1. **Base configurations** (`_base/`): Generic, reusable workload definitions
2. **Cluster overlays** (`_clusters/firefly/`): Cluster-specific customizations via Kustomize
3. **Flux sync**: Flux monitors this repository and applies changes automatically

### Kustomize Layering

- Each base namespace/application has its own kustomization
- Cluster overlays reference base resources and apply patches/customizations
- Components provide reusable transformations (resource profiles, node selectors)

### Resource Profiles

Standardized resource allocation profiles following AWS naming conventions:
- **P-type**: Processing intensive (2:1 CPU:Memory) - video transcoding, ML inference
- **T-type**: Burstable/Transactional (1:1) - web servers, APIs
- **C-type**: Compute optimized (1:2 CPU:Memory) - high-traffic services
- **M-type**: Memory optimized (1:4 CPU:Memory) - moderate memory apps
- **R-type**: Memory intensive (1:8 CPU:Memory) - in-memory databases, caches

See `_components/resource-profiles/README.md` for complete reference.

## Common Commands

### Validate and Build

```bash
# Validate Kustomize structure for a cluster
kustomize build _clusters/firefly > /tmp/firefly-manifest.yaml

# Validate specific namespace/component
kustomize build _clusters/firefly/media > /tmp/media-manifest.yaml

# Dry-run apply to verify what would be deployed
kubectl apply -k _clusters/firefly --dry-run=client --output yaml
```

### Deploy

```bash
# Apply cluster configuration (if Flux is not auto-syncing)
kubectl apply -k _clusters/firefly

# Force Flux reconciliation
flux reconcile kustomization firefly-root --with-source
```

### Debugging

```bash
# Check Flux sync status
flux get kustomization

# View Flux logs for specific kustomization
flux logs --kustomization=firefly-media --all-namespaces

# Inspect rendered manifests for a specific kustomization
kustomize build _clusters/firefly/media
```

### Working with Bases and Overlays

```bash
# Add new application base
mkdir -p _base/myapp/{app,config}
# Create kustomization.yaml with resources

# Reference in cluster overlay
# _clusters/firefly/kustomization.yaml
resources:
  - ../../_base/myapp
```

## Key Development Notes

### Sops + GPG Integration

The repository uses SOPS (Secrets Operations) with GPG for encrypting sensitive values. See parent repo's `k3s-sops-gpg-secret` Ansible role for setup.

### Cluster Bootstrap

The main cluster is bootstrapped via Ansible. Refer to `/ansible/pi-k3s-bootstrap.yml` in the parent repository for the full bootstrap procedure, which installs:
- K3s
- Flux v2
- GitHub Private Runner
- SOPS/GPG secrets support

### NFS Storage

Firefly provides NFS storage at `/mnt/raid` for shared access across workloads. See parent repo README for NFS client mount instructions.

### Naming Conventions

- Bases organized by workload type/function (not namespace)
- Cluster overlays mirror base structure for easy correlation
- Kustomization files always named `kustomization.yaml`
- Kubernetes manifests use `.yaml` extension
