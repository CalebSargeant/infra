# WordPress with Elementor Deployment

This directory contains Kubernetes manifests for deploying WordPress with Elementor support in the Firefly cluster.

## Overview

WordPress is configured with:
- **WordPress 6.7** (Apache variant)
- **MariaDB 11.2** database (sidecar container)
- **Elementor** support for visual page building
- **Static site export** capability

## Database Decision

While the cluster has a PostgreSQL StatefulSet, this deployment uses MariaDB because:

1. **WordPress Compatibility**: WordPress is designed for MySQL/MariaDB
2. **Plugin Support**: Elementor and other plugins expect MySQL
3. **Reliability**: Using PG4WP plugin for PostgreSQL adds complexity and potential compatibility issues
4. **Best Practices**: MariaDB sidecar keeps the deployment self-contained

The MariaDB instance runs as a sidecar container in the WordPress pod, with its data persisted to a PVC.

## Components

- `deployment.yaml` - WordPress + MariaDB containers
- `service.yaml` - ClusterIP service for internal access
- `ingress.yaml` - External HTTPS access via Traefik
- `pv.yaml` - Persistent volumes for WordPress files and database
- `pvc.yaml` - Persistent volume claims
- `namespace.yaml` - Dedicated namespace
- `configmap.yaml` - Configuration and usage instructions
- `secret.enc.yaml` - Database credentials (encrypted with SOPS)
- `kustomization.yaml` - Kustomize configuration

## Usage

### Access WordPress

After deployment, access WordPress at: `https://wordpress.sargeant.co`

### Initial Setup

1. Complete WordPress installation wizard
2. Install Elementor plugin from WordPress admin
3. Create pages with Elementor

### Export Static Sites

1. Install "Simply Static" plugin
2. Design your site with Elementor
3. Generate static HTML export
4. Download and host separately

See the ConfigMap README.txt for detailed instructions.

## Customization

To change the domain, edit `ingress.yaml`:
```yaml
spec:
  rules:
    - host: your-domain.com
```

To change resource limits, edit `deployment.yaml` resources sections.

## Security

- Database password stored in encrypted secret
- HTTPS enabled via cert-manager
- Use strong passwords during WordPress setup
- Keep WordPress and plugins updated
