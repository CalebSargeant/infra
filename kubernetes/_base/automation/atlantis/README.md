# Atlantis for Terragrunt/Terraform Pull Request Automation

This directory contains the Kubernetes manifests for deploying Atlantis on the firefly cluster.

## Quick Start

1. **Configure secrets** - Update the secret files with your actual credentials:
   - `secret.yaml` - GitHub token and webhook secret
   - `secret-aws.yaml` - AWS credentials (optional)
   - `secret-azure.yaml` - Azure credentials (optional)

2. **Deploy**:
   ```bash
   kubectl apply -k kubernetes/_clusters/firefly/automation/atlantis
   ```

3. **Configure GitHub webhook** at `https://atlantis.sargeant.co/events`

## What's Included

- **deployment.yaml** - Atlantis server deployment
- **service.yaml** - ClusterIP service for Atlantis
- **ingress.yaml** - Ingress for external access at atlantis.sargeant.co
- **pv.yaml** & **pvc.yaml** - Persistent storage for Atlantis data
- **configmap.yaml** - Atlantis configuration including Terragrunt workflow
- **serviceaccount.yaml** - RBAC configuration
- **secret.yaml** - GitHub credentials (needs to be configured)
- **secret-aws.yaml** - AWS credentials (optional)
- **secret-azure.yaml** - Azure credentials (optional)

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
- Replace placeholder secrets with actual credentials
- Consider using SOPS to encrypt secrets
- Ensure webhook secret is set in both Atlantis and GitHub
- Verify repository allowlist includes only your repository
