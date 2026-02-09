# Grafana Stack Quick Start

Get your observability stack up and running in 5 steps.

## Prerequisites

- FluxCD installed and configured
- `kubectl` access to the firefly cluster
- Git push access to this repository

## Deployment Steps

### 1. Generate Secrets

Generate strong passwords for all components:

```bash
cd _base/observability

# Generate credentials
MINIO_ROOT_PASSWORD=$(openssl rand -base64 32)
THANOS_SECRET_KEY=$(openssl rand -base64 32)
LOKI_SECRET_KEY=$(openssl rand -base64 32)
GRAFANA_ADMIN_PASSWORD=$(openssl rand -base64 24)

echo "Save these credentials securely!"
echo "================================"
echo "MinIO Root Password: $MINIO_ROOT_PASSWORD"
echo "Thanos Secret Key: $THANOS_SECRET_KEY"
echo "Loki Secret Key: $LOKI_SECRET_KEY"
echo "Grafana Admin Password: $GRAFANA_ADMIN_PASSWORD"
```

### 2. Update Configuration Files

Replace all occurrences of `*-change-me` with your generated secrets:

```bash
# MinIO root password
# File: minio/helmrelease.yaml
# Line: rootPassword: minio-admin-password-change-me

# MinIO Thanos user
# File: minio/helmrelease.yaml
# Line: secretKey: thanos-secret-key-change-me (under users, accessKey: thanos)

# MinIO Loki user  
# File: minio/helmrelease.yaml
# Line: secretKey: loki-secret-key-change-me (under users, accessKey: loki)

# Thanos object storage secret
# File: kube-prometheus-stack/thanos-objstore-secret.yaml
# Line: secret_key: thanos-secret-key-change-me

# Thanos Store config
# File: thanos-store/helmrelease.yaml
# Line: secret_key: thanos-secret-key-change-me

# Thanos Compactor config
# File: thanos-compactor/helmrelease.yaml
# Line: secret_key: thanos-secret-key-change-me

# Loki storage config
# File: loki/helmrelease.yaml
# Line: secretAccessKey: loki-secret-key-change-me

# Grafana admin
# File: kube-prometheus-stack/helmrelease.yaml
# Line: adminPassword: admin-change-me
```

**Pro tip:** Use find and replace in your editor:
```bash
# Example with sed (macOS)
find . -name "*.yaml" -exec sed -i '' 's/minio-admin-password-change-me/YOUR_PASSWORD_HERE/g' {} +
```

### 3. Commit and Push

```bash
cd /Users/caleb/Nextcloud/repos/calebsargeant/infra/kubernetes

git add _base/observability/
git add _clusters/firefly/observability/kustomization.yaml
git add _clusters/firefly/flux-system/helmrepositories.yaml

git commit -m "Add Grafana observability stack

- MinIO for object storage
- kube-prometheus-stack (Prometheus, Grafana, AlertManager)
- Thanos for long-term metrics storage
- Loki for log aggregation
- Fluent Bit for log collection

Co-Authored-By: Warp <agent@warp.dev>"

git push
```

### 4. Monitor Deployment

Watch as FluxCD deploys the stack:

```bash
# Watch HelmReleases
watch flux get helmreleases -n observability

# Watch pods coming up
watch kubectl get pods -n observability

# Check for any issues
kubectl get events -n observability --sort-by='.lastTimestamp'
```

Expected components:
- MinIO (1 pod)
- Prometheus (1 pod)
- Grafana (1 pod)
- AlertManager (1 pod)
- Thanos Query (2 pods)
- Thanos Store Gateway (2 pods)
- Thanos Compactor (1 pod)
- Loki read/write/backend (6 pods total)
- Loki gateway (1 pod)
- Fluent Bit (1 per node, DaemonSet)
- Various exporters

**Total:** ~20-30 pods depending on node count

### 5. Access Grafana

Once all pods are running:

```bash
kubectl port-forward -n observability svc/prometheus-grafana 3000:80
```

Open http://localhost:3000 in your browser:
- Username: `admin`
- Password: (the `GRAFANA_ADMIN_PASSWORD` you set)

## Verify Everything Works

### Check Metrics

1. In Grafana, go to **Explore**
2. Select **Thanos** datasource
3. Run a simple query:
   ```promql
   up
   ```
4. You should see all your Kubernetes services

### Check Logs

1. In Grafana, go to **Explore**
2. Select **Loki** datasource
3. Run a simple query:
   ```logql
   {namespace="observability"}
   ```
4. You should see logs from observability pods

### Check Dashboards

1. Go to **Dashboards**
2. Browse imported dashboards (from kube-prometheus-stack)
3. Try: "Kubernetes / Compute Resources / Cluster"

## Next Steps

- Review [README.md](./README.md) for complete documentation
- Configure AlertManager notification channels
- Create custom dashboards for your applications
- Set up ingress for external access (optional)
- Enable SOPS encryption for secrets (see [SECRETS.md](./SECRETS.md))

## Troubleshooting

### HelmRelease Failed

```bash
# Get details
flux get helmreleases -n observability

# Describe the failed release
kubectl describe helmrelease -n observability <name>
```

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n observability

# Check logs
kubectl logs -n observability <pod-name>

# Check PVC status (storage issues)
kubectl get pvc -n observability
```

### Can't Access Grafana

```bash
# Verify service exists
kubectl get svc -n observability prometheus-grafana

# Check if pod is running
kubectl get pods -n observability -l app.kubernetes.io/name=grafana

# Try different port-forward
kubectl port-forward -n observability deployment/prometheus-grafana 3000:3000
```

### No Logs in Loki

```bash
# Check Fluent Bit is running on all nodes
kubectl get pods -n observability -l app.kubernetes.io/name=fluent-bit -o wide

# Check Fluent Bit logs for errors
kubectl logs -n observability -l app.kubernetes.io/name=fluent-bit --tail=50

# Verify Loki is accepting connections
kubectl port-forward -n observability svc/loki-gateway 3100:80
curl http://localhost:3100/ready
```

## Common Issues

**Issue:** MinIO buckets not created
**Solution:** Check MinIO logs, verify the chart version supports bucket creation, or manually create buckets via console

**Issue:** Thanos can't connect to MinIO
**Solution:** Verify secret keys match between MinIO user config and Thanos objstore config

**Issue:** Prometheus not scraping
**Solution:** Check ServiceMonitor resources exist: `kubectl get servicemonitors -A`

**Issue:** High memory usage
**Solution:** Adjust retention periods or resource limits in component configs

## Support

For detailed information, see:
- [README.md](./README.md) - Full documentation
- [SECRETS.md](./SECRETS.md) - Secrets management guide
- Component documentation linked in README
