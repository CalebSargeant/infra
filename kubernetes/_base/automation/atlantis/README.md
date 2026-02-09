# Atlantis for Terragrunt/Terraform Pull Request Automation

This directory contains the Kubernetes manifests for deploying Atlantis on the firefly cluster.

## Quick Start

1. **Configure secrets** - Create and encrypt secret files:
   ```bash
   # Copy template files
   cd kubernetes/_base/automation/atlantis
   cp secret.yaml.template secret.yaml
   cp secret-aws.yaml.template secret-aws.yaml  # Optional for AWS
   cp secret-azure.yaml.template secret-azure.yaml  # Optional for Azure
   
   # Edit files and replace placeholder values with actual credentials
   # Then encrypt with SOPS
   sops -e secret.yaml > secret.enc.yaml
   sops -e secret-aws.yaml > secret-aws.enc.yaml  # Optional
   sops -e secret-azure.yaml > secret-azure.enc.yaml  # Optional
   
   # Delete unencrypted files
   rm secret.yaml secret-aws.yaml secret-azure.yaml
   
   # Update kustomization.yaml to include the encrypted secrets
   ```

2. **Update kustomization.yaml** to include your encrypted secrets in the resources list

3. **Deploy**:
   ```bash
   kubectl apply -k kubernetes/_clusters/firefly/automation/atlantis
   ```

4. **Configure GitHub webhook** at `https://atlantis.sargeant.co/events`

## What's Included

- **deployment.yaml** - Atlantis server deployment
- **service.yaml** - ClusterIP service for Atlantis
- **ingress.yaml** - Ingress for external access at atlantis.sargeant.co
- **pv.yaml** & **pvc.yaml** - Persistent storage for Atlantis data
- **configmap.yaml** - Atlantis configuration including Terragrunt workflow
- **serviceaccount.yaml** - RBAC configuration
- **secret.yaml.template** - Template for GitHub credentials
- **secret-aws.yaml.template** - Template for AWS credentials (optional)
- **secret-azure.yaml.template** - Template for Azure credentials (optional)

## Supported Environments

- ✅ AWS (via AWS credentials)
- ✅ Azure (via Azure service principal)
- ✅ GCP (via existing service account)
- ✅ OCI (via existing configuration)
- ✅ Cloudflare (via existing configuration)

## Usage

Once deployed, Atlantis will automatically:

1. Run `terraform plan` when you create/update a PR with infrastructure changes
2. Post the plan output as a PR comment
3. Allow you to apply changes with `atlantis apply` comment (after PR approval)

See the [full documentation](../../../../docs/guides/atlantis-setup.md) for detailed setup and usage instructions.

## Configuration

The Atlantis configuration supports both Terraform and Terragrunt:

- Repository-level config: `/atlantis.yaml`
- Server-side config: `configmap.yaml`
- Custom workflow: `terragrunt` (auto-detects Terragrunt vs Terraform)

## Security Notes

⚠️ **Before deploying**:
- Create secrets from templates and encrypt with SOPS
- Replace placeholder secrets with actual credentials
- Ensure webhook secret is set in both Atlantis and GitHub
- Verify repository allowlist includes only your repository
- Never commit unencrypted secret files to version control
