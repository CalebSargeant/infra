# Atlantis Setup Guide

## Overview

This guide covers the setup and configuration of Atlantis for automated Terraform/Terragrunt pull request workflows on the firefly Kubernetes cluster.

## What is Atlantis?

Atlantis is a tool for collaborating on Terraform/Terragrunt through GitHub pull requests. It automatically runs `terraform plan` on pull requests and allows you to apply changes with a simple comment.

## Architecture

### Components

- **Atlantis Server**: Runs as a deployment in the `automation` namespace on the firefly K8s cluster
- **Persistent Storage**: 10Gi volume for Atlantis data
- **Ingress**: Accessible at `https://atlantis.sargeant.co`
- **GitHub Integration**: Webhooks configured to notify Atlantis of PR events

### Supported Environments

Atlantis is configured to support the following cloud providers:

1. **AWS** - Via AWS credentials stored in secrets
2. **Azure** - Via Azure service principal credentials (optional)
3. **GCP** - Via existing GCP service account configuration
4. **OCI** - Via existing OCI configuration
5. **Cloudflare** - Via existing Cloudflare configuration

## Prerequisites

Before deploying Atlantis, you need:

1. **GitHub Personal Access Token** with repo permissions
2. **GitHub Webhook Secret** (random string for webhook validation)
3. **AWS Credentials** (optional, if deploying AWS infrastructure)
   - AWS Access Key ID
   - AWS Secret Access Key
4. **Azure Credentials** (optional, if deploying Azure infrastructure)
   - Client ID
   - Client Secret
   - Tenant ID
   - Subscription ID

## Deployment

### 1. Configure Secrets

The Atlantis deployment requires several secrets to be configured. These are currently set to placeholder values and must be updated:

#### GitHub Credentials

```bash
# Edit the secret file
kubectl create secret generic atlantis \
  --from-literal=github-user='YOUR_GITHUB_USERNAME' \
  --from-literal=github-token='YOUR_GITHUB_TOKEN' \
  --from-literal=webhook-secret='YOUR_WEBHOOK_SECRET' \
  -n automation --dry-run=client -o yaml | kubectl apply -f -
```

Or use SOPS to encrypt the secret:

```bash
# Edit kubernetes/_base/automation/atlantis/secret.yaml
# Replace placeholder values with actual credentials
# Then encrypt with SOPS
sops -e -i kubernetes/_base/automation/atlantis/secret.yaml
```

#### AWS Credentials (Optional)

```bash
kubectl create secret generic atlantis-aws \
  --from-literal=access-key-id='YOUR_AWS_ACCESS_KEY_ID' \
  --from-literal=secret-access-key='YOUR_AWS_SECRET_ACCESS_KEY' \
  -n automation --dry-run=client -o yaml | kubectl apply -f -
```

Or use SOPS:

```bash
# Edit kubernetes/_base/automation/atlantis/secret-aws.yaml
# Replace placeholder values with actual credentials
# Then encrypt with SOPS
sops -e -i kubernetes/_base/automation/atlantis/secret-aws.yaml
```

#### Azure Credentials (Optional)

```bash
kubectl create secret generic atlantis-azure \
  --from-literal=client-id='YOUR_AZURE_CLIENT_ID' \
  --from-literal=client-secret='YOUR_AZURE_CLIENT_SECRET' \
  --from-literal=tenant-id='YOUR_AZURE_TENANT_ID' \
  --from-literal=subscription-id='YOUR_AZURE_SUBSCRIPTION_ID' \
  -n automation --dry-run=client -o yaml | kubectl apply -f -
```

Or use SOPS:

```bash
# Edit kubernetes/_base/automation/atlantis/secret-azure.yaml
# Replace placeholder values with actual credentials
# Then encrypt with SOPS
sops -e -i kubernetes/_base/automation/atlantis/secret-azure.yaml
```

### 2. Deploy Atlantis

Once secrets are configured, deploy Atlantis using kustomize:

```bash
# From the repository root
kubectl apply -k kubernetes/_clusters/firefly/automation/atlantis
```

### 3. Configure GitHub Webhook

After Atlantis is deployed and accessible at `https://atlantis.sargeant.co`, configure a webhook in your GitHub repository:

1. Go to your repository settings: `https://github.com/CalebSargeant/infra/settings/hooks`
2. Click "Add webhook"
3. Configure:
   - **Payload URL**: `https://atlantis.sargeant.co/events`
   - **Content type**: `application/json`
   - **Secret**: Use the same webhook secret configured in the Atlantis secret
   - **Events**: Select "Let me select individual events" and choose:
     - Pull requests
     - Issue comments
     - Pull request reviews
     - Pull request review comments
4. Click "Add webhook"

### 4. Verify Deployment

Check that Atlantis is running:

```bash
# Check deployment status
kubectl get deployment atlantis -n automation

# Check pod status
kubectl get pods -n automation -l app=atlantis

# Check logs
kubectl logs -n automation -l app=atlantis -f
```

## Usage

### Basic Workflow

1. Create a pull request with Terraform/Terragrunt changes
2. Atlantis automatically runs `plan` on the changed projects
3. Review the plan output in the PR comments
4. Approve the PR
5. Comment `atlantis apply` to apply the changes
6. Merge the PR

### Atlantis Commands

Comment these on pull requests to interact with Atlantis:

- `atlantis plan` - Run terraform plan
- `atlantis apply` - Run terraform apply (requires PR approval)
- `atlantis plan -p PROJECT_NAME` - Plan a specific project
- `atlantis apply -p PROJECT_NAME` - Apply a specific project
- `atlantis unlock` - Unlock a plan

### Project Configuration

Projects are configured in the `atlantis.yaml` file at the repository root. Current projects:

- `aws-infrastructure` - AWS resources in `terraform/aws`
- `azure-infrastructure` - Azure resources in `terraform/azure`
- `oci-infrastructure` - OCI resources in `terraform/oci`
- `gcp-infrastructure` - GCP resources in `terraform/gcp`
- `cloudflare-infrastructure` - Cloudflare resources in `terraform/cloudflare`

### Terragrunt Support

Atlantis is configured with a custom `terragrunt` workflow that:

1. Detects if `terragrunt.hcl` exists in the project directory
2. Uses `terragrunt` commands if found, otherwise falls back to `terraform`
3. Properly handles Terragrunt's directory structure and dependencies

## Configuration Files

### Repository Configuration

- **`atlantis.yaml`** - Root-level configuration defining projects and workflows
- **`kubernetes/_base/automation/atlantis/configmap.yaml`** - Server-side configuration

### Workflow Definition

The `terragrunt` workflow is defined to handle both Terraform and Terragrunt:

```yaml
workflows:
  terragrunt:
    plan:
      steps:
        - init
        - run: |
            if [ -f "terragrunt.hcl" ]; then
              terragrunt plan -input=false -out=$PLANFILE
            else
              terraform plan -input=false -out=$PLANFILE
            fi
    apply:
      steps:
        - run: |
            if [ -f "terragrunt.hcl" ]; then
              terragrunt apply -input=false $PLANFILE
            else
              terraform apply -input=false $PLANFILE
            fi
```

## Security Considerations

1. **Secrets Management**: All secrets are stored as Kubernetes secrets. Consider using SOPS for encryption at rest
2. **RBAC**: Atlantis uses a ServiceAccount with minimal permissions (read configmaps only)
3. **PR Approval**: Atlantis is configured to require PR approval before applying changes
4. **Webhook Secret**: Validates that webhook events are from GitHub
5. **Repository Allowlist**: Only allows operations on `github.com/CalebSargeant/infra`

## Troubleshooting

### Check Atlantis Logs

```bash
kubectl logs -n automation -l app=atlantis -f
```

### Verify Webhook Delivery

1. Go to GitHub repository settings > Webhooks
2. Click on the Atlantis webhook
3. Check "Recent Deliveries" for any failed deliveries

### Reset Atlantis State

If Atlantis gets stuck:

```bash
# Delete the pod to restart
kubectl delete pod -n automation -l app=atlantis

# Or unlock via comment
# Comment on PR: atlantis unlock
```

### Common Issues

**Issue**: Atlantis doesn't respond to PR comments
- Check webhook is configured correctly
- Verify webhook secret matches
- Check Atlantis logs for errors

**Issue**: Plan fails with authentication errors
- Verify cloud provider credentials are correctly set in secrets
- Check that secrets are mounted in the deployment

**Issue**: Terragrunt commands fail
- Ensure Terragrunt is available in the Atlantis image
- Verify TERRAGRUNT_TFPATH environment variable is set correctly

## References

- [Atlantis Documentation](https://www.runatlantis.io/)
- [Atlantis Server Configuration](https://www.runatlantis.io/docs/server-configuration.html)
- [Atlantis Repo Configuration](https://www.runatlantis.io/docs/repo-level-atlantis-yaml.html)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
