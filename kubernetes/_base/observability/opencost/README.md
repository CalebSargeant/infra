# OpenCost - Cloud Cost Monitoring

OpenCost provides real-time cost monitoring for Kubernetes clusters and cloud resources. It integrates with Prometheus to collect metrics and can connect to cloud provider APIs for accurate cost data.

## Prerequisites

- Prometheus deployed and accessible (already configured via kube-prometheus-stack)
- Cloud provider credentials with billing/cost access permissions
- SOPS encryption configured for secrets

## Quick Start

1. Deploy OpenCost (basic deployment without cloud costs):
   ```bash
   # OpenCost will deploy with Prometheus integration
   # Add to cluster's observability kustomization.yaml
   ```

2. Configure cloud provider credentials (see sections below)

3. Access OpenCost UI:
   ```bash
   kubectl port-forward -n observability svc/opencost 9090:9090
   ```
   Then open: http://localhost:9090

## Cloud Provider Configuration

### AWS

#### Prerequisites
- AWS account with Cost and Usage Report (CUR) enabled
- IAM user or role with billing permissions

#### Required IAM Permissions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ce:GetCostAndUsage",
        "ce:GetCostForecast",
        "pricing:GetProducts"
      ],
      "Resource": "*"
    }
  ]
}
```

#### Setup Steps
1. Create IAM user or configure IAM role with the above permissions
2. Generate access key for the IAM user (if using IAM user)
3. Update `cloud-credentials-secrets.enc.yaml` with AWS credentials:
   ```yaml
   aws_access_key_id: YOUR_ACCESS_KEY_ID
   aws_secret_access_key: YOUR_SECRET_ACCESS_KEY
   ```
4. Encrypt the secret with SOPS:
   ```bash
   sops -e -i cloud-credentials-secrets.enc.yaml
   ```
5. Update `helmrelease.yaml` to enable AWS:
   ```yaml
   cloudCost:
     aws:
       enabled: true
   ```

#### Optional: Using IAM Role (Recommended)
Instead of access keys, you can use IAM roles with IRSA (IAM Roles for Service Accounts):
1. Create an IAM role with the above permissions
2. Attach the role to the OpenCost service account
3. Set `aws_role_arn` in the secret

---

### GCP

#### Prerequisites
- GCP project with Billing Export to BigQuery enabled
- Service account with billing viewer permissions

#### Required Permissions
- `roles/billing.viewer`
- `roles/bigquery.dataViewer` on the billing export dataset
- `roles/bigquery.user` on the project

#### Setup Steps
1. Enable Billing Export to BigQuery:
   - Go to Cloud Console → Billing → Billing Export
   - Enable "Standard usage cost data"
   - Select or create a BigQuery dataset

2. Create a service account:
   ```bash
   gcloud iam service-accounts create opencost-sa \
     --display-name="OpenCost Service Account"
   ```

3. Grant necessary permissions:
   ```bash
   # Billing viewer role
   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member="serviceAccount:opencost-sa@PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/billing.viewer"
   
   # BigQuery permissions
   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member="serviceAccount:opencost-sa@PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/bigquery.user"
   ```

4. Generate and download the service account key:
   ```bash
   gcloud iam service-accounts keys create opencost-key.json \
     --iam-account=opencost-sa@PROJECT_ID.iam.gserviceaccount.com
   ```

5. Update `cloud-credentials-secrets.enc.yaml` with the JSON key content

6. Encrypt the secret with SOPS:
   ```bash
   sops -e -i cloud-credentials-secrets.enc.yaml
   ```

7. Update `helmrelease.yaml` to enable GCP:
   ```yaml
   cloudCost:
     gcp:
       enabled: true
   ```

---

### Azure

#### Prerequisites
- Azure subscription
- Service principal with Cost Management Reader permissions

#### Setup Steps
1. Create a service principal:
   ```bash
   az ad sp create-for-rbac --name opencost-sp --role "Cost Management Reader" \
     --scopes /subscriptions/YOUR_SUBSCRIPTION_ID
   ```
   
   This will output:
   - `appId` (client_id)
   - `password` (client_secret)
   - `tenant` (tenant_id)

2. Update `cloud-credentials-secrets.enc.yaml` with Azure credentials:
   ```yaml
   azure_subscription_id: YOUR_SUBSCRIPTION_ID
   azure_tenant_id: YOUR_TENANT_ID
   azure_client_id: YOUR_CLIENT_ID
   azure_client_secret: YOUR_CLIENT_SECRET
   ```

3. Encrypt the secret with SOPS:
   ```bash
   sops -e -i cloud-credentials-secrets.enc.yaml
   ```

4. Update `helmrelease.yaml` to enable Azure:
   ```yaml
   cloudCost:
     azure:
       enabled: true
   ```

---

### OCI (Oracle Cloud Infrastructure)

#### Prerequisites
- OCI tenancy with Cost Analysis enabled
- OCI user with read access to cost data

#### Setup Steps
1. Create or use an existing OCI user

2. Generate API signing key:
   ```bash
   mkdir -p ~/.oci
   openssl genrsa -out ~/.oci/oci_api_key.pem 2048
   openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
   ```

3. Add the public key to your OCI user:
   - Go to OCI Console → Identity → Users → Your User
   - Click "API Keys" → "Add API Key"
   - Paste the content of `oci_api_key_public.pem`
   - Note the fingerprint

4. Get your user OCID and tenancy OCID:
   - User OCID: Identity → Users → Your User
   - Tenancy OCID: Tenancy Details in the console

5. Update `cloud-credentials-secrets.enc.yaml` with OCI credentials:
   ```yaml
   oci_config: |
     [DEFAULT]
     user=ocid1.user.oc1..YOUR_USER_OCID
     fingerprint=YOUR_FINGERPRINT
     tenancy=ocid1.tenancy.oc1..YOUR_TENANCY_OCID
     region=YOUR_REGION
     key_file=/root/.oci/oci_api_key.pem
   oci_api_key.pem: |
     -----BEGIN RSA PRIVATE KEY-----
     [Your private key content]
     -----END RSA PRIVATE KEY-----
   ```

6. Encrypt the secret with SOPS:
   ```bash
   sops -e -i cloud-credentials-secrets.enc.yaml
   ```

7. Update `helmrelease.yaml` to enable OCI:
   ```yaml
   cloudCost:
     oci:
       enabled: true
   ```

---

## Enabling Cloud Providers

After configuring credentials for your cloud providers:

1. Uncomment the secrets resource in `kustomization.yaml`:
   ```yaml
   resources:
     - helmrelease.yaml
     - cloud-credentials-secrets.enc.yaml  # Uncomment this line
   ```

2. Update `helmrelease.yaml` to enable specific cloud providers:
   ```yaml
   cloudCost:
     enabled: true
     aws:
       enabled: true  # Set to true for AWS
     gcp:
       enabled: true  # Set to true for GCP
     azure:
       enabled: true  # Set to true for Azure
     oci:
       enabled: true  # Set to true for OCI
   ```

3. Commit and push changes to trigger Flux reconciliation

## Accessing OpenCost

### Port Forward
```bash
kubectl port-forward -n observability svc/opencost 9090:9090
```

### Grafana Integration
OpenCost metrics are automatically scraped by Prometheus and available in Grafana. You can create dashboards or import community dashboards:
- OpenCost Dashboard ID: 15642

### API Access
OpenCost provides a REST API for programmatic access:
```bash
# Get allocation data
kubectl port-forward -n observability svc/opencost 9003:9003
curl http://localhost:9003/allocation/compute?window=7d
```

## Troubleshooting

### Check OpenCost logs
```bash
kubectl logs -n observability -l app.kubernetes.io/name=opencost -f
```

### Verify Prometheus connection
```bash
kubectl exec -n observability -it deployment/opencost -- curl http://prometheus-operated:9090/-/healthy
```

### Check cloud credentials
```bash
# Verify secret exists
kubectl get secret -n observability opencost-aws-credentials
kubectl get secret -n observability opencost-gcp-credentials
kubectl get secret -n observability opencost-azure-credentials
kubectl get secret -n observability opencost-oci-credentials
```

## Additional Resources

- [OpenCost Documentation](https://www.opencost.io/docs/)
- [OpenCost GitHub](https://github.com/opencost/opencost)
- [Cloud Integration Guide](https://www.opencost.io/docs/configuration/cloud-costs)
