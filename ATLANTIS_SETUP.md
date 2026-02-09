# Atlantis Setup Summary

## What Was Created

This PR sets up Terraform Atlantis on the firefly Kubernetes cluster for automated Terragrunt deployments with GitHub integration.

### Files Added

#### Kubernetes Manifests (`kubernetes/_base/automation/atlantis/`)
- **deployment.yaml** - Atlantis server deployment with Terragrunt support
- **service.yaml** - ClusterIP service exposing Atlantis on port 80
- **ingress.yaml** - NGINX ingress with TLS at `atlantis.sargeant.co`
- **pv.yaml** / **pvc.yaml** - 10Gi persistent storage for Atlantis data
- **configmap.yaml** - Server-side Atlantis configuration with Terragrunt workflow
- **serviceaccount.yaml** - RBAC with minimal permissions
- **secret*.yaml.template** - Templates for GitHub, AWS, and Azure credentials
- **kustomization.yaml** - Kustomize configuration for base resources
- **README.md** - Quick reference guide

#### Cluster Configuration (`kubernetes/_clusters/firefly/automation/atlantis/`)
- **kustomization.yaml** - Firefly-specific configuration with resource profiles

#### Repository Configuration
- **atlantis.yaml** - Repo-level configuration defining projects and workflows for:
  - AWS infrastructure
  - Azure infrastructure
  - OCI infrastructure
  - GCP infrastructure
  - Cloudflare infrastructure

#### Documentation
- **docs/guides/atlantis-setup.md** - Comprehensive setup and usage guide

### Key Features

✅ **Terragrunt Support**: Custom workflow that auto-detects Terragrunt vs Terraform
✅ **Multi-Cloud**: Supports AWS, Azure, GCP, OCI, and Cloudflare
✅ **Security**: 
  - SOPS encryption for secrets
  - Webhook secret validation
  - Repository allowlist
  - PR approval required for apply
✅ **Resource Management**: Uses c.medium profile (500m-2 CPU, 1-4Gi memory)
✅ **Persistent Storage**: 10Gi volume for Atlantis state
✅ **TLS**: Automatic certificate management via cert-manager

## Next Steps for Deployment

### 1. Configure Secrets

Users need to create and encrypt secrets before deploying:

```bash
cd kubernetes/_base/automation/atlantis

# Create secrets from templates
cp secret.yaml.template secret.yaml
cp secret-aws.yaml.template secret-aws.yaml  # Optional
cp secret-azure.yaml.template secret-azure.yaml  # Optional

# Edit and add actual credentials
vim secret.yaml
vim secret-aws.yaml
vim secret-azure.yaml

# Encrypt with SOPS
sops -e secret.yaml > secret.enc.yaml
sops -e secret-aws.yaml > secret-aws.enc.yaml
sops -e secret-azure.yaml > secret-azure.enc.yaml

# Clean up unencrypted files
rm secret.yaml secret-aws.yaml secret-azure.yaml
```

### 2. Update Kustomization

Edit `kubernetes/_base/automation/atlantis/kustomization.yaml` to include encrypted secrets:

```yaml
resources:
  # ... existing resources ...
  - secret.enc.yaml
  - secret-aws.enc.yaml  # Optional
  - secret-azure.enc.yaml  # Optional
```

### 3. Deploy to Cluster

```bash
kubectl apply -k kubernetes/_clusters/firefly/automation/atlantis
```

### 4. Configure GitHub Webhook

1. Go to repository settings: Settings > Webhooks > Add webhook
2. Configure:
   - Payload URL: `https://atlantis.sargeant.co/events`
   - Content type: `application/json`
   - Secret: Same as webhook-secret in secret.yaml
   - Events: Pull requests, Issue comments, Pull request reviews
3. Save webhook

### 5. Test the Setup

1. Create a test PR with a Terraform/Terragrunt change
2. Atlantis should automatically comment with plan output
3. Review and approve the PR
4. Comment `atlantis apply` to apply changes

## Required GitHub Credentials

- **GitHub Token**: Personal access token with `repo` scope
- **GitHub Username**: Your GitHub username
- **Webhook Secret**: Random string for webhook validation (generate with: `openssl rand -hex 32`)

## Optional Cloud Credentials

### AWS (for AWS infrastructure)
- AWS Access Key ID
- AWS Secret Access Key

### Azure (for Azure infrastructure)
- Azure Client ID
- Azure Client Secret
- Azure Tenant ID
- Azure Subscription ID

## Configuration Overview

### Atlantis Projects

The `atlantis.yaml` defines projects for different cloud providers:
- `aws-infrastructure` → `terraform/aws`
- `azure-infrastructure` → `terraform/azure`
- `oci-infrastructure` → `terraform/oci`
- `gcp-infrastructure` → `terraform/gcp`
- `cloudflare-infrastructure` → `terraform/cloudflare`

### Terragrunt Workflow

Custom workflow that:
1. Checks for `terragrunt.hcl` in the directory
2. Uses `terragrunt` commands if found, otherwise uses `terraform`
3. Requires PR approval before apply
4. Generates plans with `-out=$PLANFILE`

## Security Considerations

✅ Repository allowlist restricts to `github.com/CalebSargeant/infra`
✅ Secrets stored as Kubernetes secrets (encrypted with SOPS)
✅ Webhook secret validates GitHub events
✅ PR approval required before apply
✅ Minimal RBAC permissions (read configmaps only)

## Troubleshooting

### Check Atlantis Logs
```bash
kubectl logs -n automation -l app=atlantis -f
```

### Verify Deployment
```bash
kubectl get all -n automation -l app=atlantis
```

### Test Webhook
Check GitHub webhook delivery status in repository settings

## Future Enhancements

Potential improvements for future iterations:

1. **Add AWS directory structure** if AWS infrastructure is planned
2. **Add Azure directory structure** if Azure infrastructure is planned
3. **Configure notification integrations** (Slack, Discord, etc.)
4. **Add custom Atlantis Docker image** with additional tools
5. **Configure automerge** for specific types of changes
6. **Add project-specific workflows** for different use cases
7. **Implement plan file retention policies**

## Documentation

Full documentation available at:
- [Atlantis Setup Guide](docs/guides/atlantis-setup.md)
- [Atlantis Base README](kubernetes/_base/automation/atlantis/README.md)
- [Atlantis Official Docs](https://www.runatlantis.io/)

## Testing

The Kubernetes manifests have been validated with `kubectl kustomize` and build successfully without errors.
