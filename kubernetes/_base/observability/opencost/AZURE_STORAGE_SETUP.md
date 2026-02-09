# OpenCost Azure Storage Integration

This document describes the Azure cost integration setup for the firefly K3s cluster using Azure Storage Account access keys.

## Overview

OpenCost on the firefly cluster is configured to read Azure cost data from a storage account where Azure Cost Management exports cost data daily. This approach works for any Kubernetes cluster (K3s, EKS, GKE, on-premises) without requiring Azure Workload Identity.

## Configuration

### Cloud Integration Secret

A new `opencost-cloud-integration` secret has been added to `cloud-credentials-secrets.enc.yaml` containing:

- **Storage account**: Azure Storage Account name (REDACTED in encrypted file)
- **Container**: Blob container with cost exports (REDACTED)
- **Path**: Path to cost export files (REDACTED)
- **Subscription ID**: Azure subscription being monitored (REDACTED)
- **Access Key**: Storage account access key (encrypted with SOPS)

The secret uses the OpenCost `cloud-integration.json` format with `AzureAccessKey` authorizer type.

### HelmRelease Changes

The `helmrelease.yaml` has been updated to:

1. Enable cloud cost integration:
   ```yaml
   cloudCost:
     enabled: true
   ```

2. Reference the cloud integration secret:
   ```yaml
   cloudIntegrationSecret: opencost-cloud-integration
   ```

3. Configure the cloud cost config path:
   ```yaml
   exporter:
     extraEnv:
       CLOUD_COST_CONFIG_PATH:
         value: "/var/configs/cloud-integration/cloud-integration.json"
   ```

## How It Works

1. **Cost Exports**: Azure Cost Management exports cost data daily to the configured storage account
2. **OpenCost Reads**: OpenCost periodically downloads CSV files from the storage account
3. **Cost Processing**: Downloaded data is cached locally and processed to provide cost insights
4. **UI Display**: Cost data is visible in the OpenCost UI under the "Cloud Costs" tab

## Security

- All sensitive data (storage account name, access key, subscription ID) is encrypted using SOPS with age encryption
- The age key is stored in `~/.sops.agekey` (not committed to git)
- The encrypted file `cloud-credentials-secrets.enc.yaml` can be safely committed to the public repository

## Deployment

OpenCost is already deployed to the firefly cluster via Flux. The changes will be automatically applied when:

1. The updated files are committed and pushed to git
2. Flux reconciles the observability kustomization
3. The new secret is created in the cluster
4. OpenCost deployment picks up the cloud integration configuration

## Accessing OpenCost

```bash
# Port forward to OpenCost UI
kubectl port-forward -n observability svc/opencost 9090:9090
```

Then open http://localhost:9090 and navigate to the "Cloud Costs" tab.

## Verification

To verify the integration is working:

1. **Check secret exists**:
   ```bash
   kubectl get secret -n observability opencost-cloud-integration
   ```

2. **Check OpenCost logs**:
   ```bash
   kubectl logs -n observability -l app.kubernetes.io/name=opencost | grep -i azure
   ```

3. **Query the API**:
   ```bash
   kubectl port-forward -n observability svc/opencost 9003:9003
   curl http://localhost:9003/cloudCost?window=7d
   ```

## Troubleshooting

### No Cloud Cost Data

1. Verify cost exports exist in the storage account
2. Check OpenCost logs for authentication or download errors
3. Ensure the storage account access key is correct
4. Verify the path to cost exports matches the actual blob structure

### Permission Denied Errors

1. Check that the access key has permission to read from the container
2. Verify the storage account allows access from the cluster's network

## Maintenance

### Rotating Access Keys

When rotating the storage account access key:

1. Generate a new access key in Azure Portal
2. Update the encrypted secret:
   ```bash
   cd ~/repos/calebsargeant/infra
   SOPS_AGE_KEY_FILE=~/.sops.agekey sops kubernetes/_base/observability/opencost/cloud-credentials-secrets.enc.yaml
   # Update the accessKey value in the opencost-cloud-integration secret
   ```
3. Commit and push the change
4. Flux will automatically update the secret in the cluster

## References

- [OpenCost Documentation](https://opencost.io/docs/)
- [OpenCost Azure Configuration](https://opencost.io/docs/configuration/azure/)
- [Azure Cost Management Exports](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-export-acm-data)
