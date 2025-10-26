# Maniforge Configuration for Firefly Cluster

## Overview

The `maniforge.yaml` file is a consolidated manifest configuration that serves as a single source of truth for the entire Firefly Kubernetes cluster. It consolidates all kustomization configurations from various subdirectories into one centralized, easy-to-read format.

## Purpose

Instead of having resource profiles and node selectors scattered across dozens of kustomization files in different directories, maniforge provides:

- **Centralized Configuration**: All application deployments, resource allocations, and node assignments in one place
- **Clear Visibility**: Easy overview of the entire cluster architecture
- **Node Specifications**: Documents the actual hardware (4cpu/8Gi Pi5, 8cpu/16Gi x86 VM)
- **Resource Profiles**: Defines all resource request/limit profiles used across the cluster

## Structure

### Cluster Nodes

The Firefly cluster consists of two nodes:

1. **pi** (Raspberry Pi 5)
   - Type: raspberry-pi-5
   - CPU: 4 cores
   - Memory: 8Gi
   - Label: `type: pi`

2. **mini** (x86 VM)
   - Type: x86-vm
   - CPU: 8 cores
   - Memory: 16Gi
   - Label: `type: mini`

### Applications

Applications are organized by category (automation, backup, core, database, media, miscellaneous, observability), with each application specifying:

- **name**: Application name
- **basePath**: Path to the base kustomization
- **resourceProfile**: Which resource profile to use (c.pico, t.small, m.large, etc.)
- **nodeSelector**: Which node type to deploy on (pi or mini)

### Resource Profiles

Resource profiles define CPU and memory requests/limits for different application tiers:

#### Compute Optimized (c.*)
- **c.pico**: 100m CPU / 256Mi RAM → 250m / 512Mi (smallest workloads)
- **c.nano**: 150m CPU / 384Mi RAM → 500m / 1Gi
- **c.micro**: 200m CPU / 512Mi RAM → 750m / 1536Mi
- **c.small**: 250m CPU / 512Mi RAM → 1 CPU / 2Gi

#### Tiny/Minimal (t.*)
- **t.nano**: 50m CPU / 64Mi RAM → 200m / 256Mi (very minimal services)
- **t.small**: 250m CPU / 256Mi RAM → 1 CPU / 1Gi
- **t.medium**: 500m CPU / 512Mi RAM → 2 CPU / 2Gi

#### Memory Optimized (m.*)
- **m.small**: 250m CPU / 1Gi RAM → 1 CPU / 4Gi
- **m.medium**: 500m CPU / 2Gi RAM → 2 CPU / 8Gi
- **m.large**: 1 CPU / 4Gi RAM → 4 CPU / 16Gi (large storage/processing apps)

## Relationship to Kustomizations

This maniforge.yaml file **represents** the combined configuration of all kustomization files in the firefly cluster. The actual kustomization files in subdirectories still control the deployment, but maniforge provides:

1. **Documentation**: Clear view of what's deployed where
2. **Planning**: Easy capacity planning and resource allocation
3. **Reference**: Quick lookup for application configurations
4. **Consistency**: Ensures all apps follow the documented patterns

## Application Distribution

### Deployed on Pi5 (4 CPU / 8Gi RAM)
- Automation: homeassistant, homebridge, n8n
- Core: cert-manager
- Database: postgres
- Media: plex (transcoding workload)
- Miscellaneous: kured, cloudflared, adguard-home

### Deployed on x86 VM (8 CPU / 16Gi RAM)
- Backup: timemachine
- Media: All media downloaders and managers (bazarr, sonarr, radarr, etc.)
- Observability: Complete observability stack (Grafana LGTM + exporters)

## Usage

This file serves as:
1. **Architecture Documentation**: Understand the cluster at a glance
2. **Capacity Planning**: Plan resource allocations and node upgrades
3. **Configuration Reference**: Quickly find which profile/node an app uses
4. **Audit Trail**: Track what's deployed and where

## Future Enhancements

Potential future uses for maniforge.yaml:
- Generate kustomization files automatically from maniforge spec
- Validate actual deployments match the maniforge configuration
- CLI tool to manage and query cluster configuration
- Integration with GitOps workflows
- Automated capacity planning and scaling recommendations

## Schema

The maniforge.yaml follows a custom schema:
```yaml
apiVersion: maniforge.calebsargeant.com/v1alpha1
kind: ClusterManifest
metadata:
  name: <cluster-name>
  description: <description>
spec:
  cluster:
    name: <cluster-name>
    nodes: [...]
  applications:
    <category>:
      namespace: <namespace>
      apps: [...]
  resourceProfiles:
    <profile-name>:
      requests: {...}
      limits: {...}
```

## Notes

- All resource profiles are derived from the actual component definitions in `kubernetes/_components/resource-profiles/`
- Node selectors correspond to the components in `kubernetes/_components/node-selectors/`
- The basePath for each app points to the corresponding base kustomization in `kubernetes/_base/`
