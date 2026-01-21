# Grafana Observability Stack

A comprehensive, scalable observability solution for the firefly Kubernetes cluster.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Grafana UI                               │
│                    (Dashboards & Queries)                        │
└────────────┬────────────────────────────────┬───────────────────┘
             │                                │
             ▼                                ▼
    ┌────────────────┐                ┌──────────────┐
    │  Thanos Query  │                │     Loki     │
    │ (Unified View) │                │  (Logs API)  │
    └────────┬───────┘                └──────┬───────┘
             │                                │
      ┌──────┴─────────┐              ┌──────┴─────────┐
      │                │              │                │
      ▼                ▼              ▼                ▼
┌──────────┐    ┌─────────────┐  ┌─────────┐    ┌─────────┐
│Prometheus│    │Thanos Store │  │Loki Read│    │Loki Write│
│(Thanos   │    │  Gateway    │  │Components│   │Components│
│ Sidecar) │    │             │  └─────────┘    └─────────┘
└────┬─────┘    └──────┬──────┘       │              │
     │                 │               │              │
     └─────────────────┼───────────────┴──────────────┘
                       ▼                              │
                 ┌───────────┐                        │
                 │   MinIO   │                        │
                 │(S3 Object │                        │
                 │ Storage)  │                        │
                 └───────────┘                        │
                                                      │
     ┌────────────────────────────────────────────────┘
     │
     ▼
┌────────────┐
│ Fluent Bit │ (Logs from all pods via DaemonSet)
└────────────┘
```

## Components

### Core Stack

1. **MinIO** - S3-compatible object storage
   - Provides backend storage for metrics and logs
   - Buckets: `thanos-metrics`, `loki-chunks`, `loki-ruler`
   - Path: `_base/observability/minio/`

2. **kube-prometheus-stack** - Complete Prometheus stack
   - **Prometheus**: Metrics collection with Thanos sidecar
   - **Grafana**: Visualization and dashboards
   - **AlertManager**: Alert routing and management
   - **Node Exporter**: Host-level metrics
   - **Kube State Metrics**: Kubernetes object metrics
   - Path: `_base/observability/kube-prometheus-stack/`

3. **Thanos** - Long-term metrics storage and global query
   - **Query**: Unified query interface for all metrics
   - **Store Gateway**: Queries historical data from object storage
   - **Compactor**: Downsamples and compacts metrics data
   - **Sidecar**: Uploads Prometheus data to object storage
   - Paths: `_base/observability/thanos-{query,store,compactor}/`

4. **Loki** - Log aggregation
   - Simple scalable deployment mode
   - Stores logs in MinIO (S3-compatible)
   - 30-day retention
   - Path: `_base/observability/loki/`

5. **Fluent Bit** - Log collection
   - DaemonSet on all nodes
   - Reads container logs from `/var/log/containers/`
   - Enriches with Kubernetes metadata
   - Forwards to Loki
   - Path: `_base/observability/fluent-bit/`

## Data Flow

### Metrics
1. Applications/exporters expose metrics
2. Prometheus scrapes metrics (ServiceMonitor auto-discovery)
3. Thanos Sidecar uploads blocks to MinIO
4. Thanos Query provides unified view (recent + historical)
5. Grafana queries Thanos Query for dashboards

### Logs
1. Applications write to stdout/stderr
2. Fluent Bit DaemonSet reads container logs
3. Fluent Bit adds Kubernetes metadata (namespace, pod, container)
4. Fluent Bit forwards to Loki
5. Loki stores logs in MinIO
6. Grafana queries Loki for log exploration

## Deployment

### Prerequisites
- FluxCD running in the cluster
- SOPS configured for secret encryption (optional but recommended)
- Persistent storage provisioner

### Steps

1. **Update secrets** (IMPORTANT!)
   - See [SECRETS.md](./SECRETS.md) for detailed instructions
   - Generate secure passwords for MinIO, Grafana, etc.
   - Update all files containing "change-me"
   - Optionally encrypt with SOPS

2. **Verify configuration**
   ```bash
   # Check if all components are referenced
   cat _clusters/firefly/observability/kustomization.yaml
   
   # Validate Kustomize build
   kubectl kustomize _clusters/firefly/observability/
   ```

3. **Deploy via FluxCD**
   - Commit and push changes to Git
   - FluxCD will automatically deploy the stack
   - Monitor deployment:
   ```bash
   flux get helmreleases -n observability
   kubectl get pods -n observability
   ```

4. **Access Grafana**
   ```bash
   # Port-forward to access Grafana
   kubectl port-forward -n observability svc/prometheus-grafana 3000:80
   ```
   - Open http://localhost:3000
   - Login: `admin` / (password you set)

## Configuration

### Resource Profiles

Components are assigned resource profiles via Kustomize patches:

- **t.small** (250m CPU, 256Mi-1Gi RAM): Fluent Bit, exporters
- **m.medium** (500m CPU, 2Gi-8Gi RAM): Thanos Query
- **m.large** (custom, 4Gi+ RAM): MinIO, kube-prometheus-stack, Thanos Store/Compactor, Loki

### Node Placement

All observability components run on nodes with `type: mini` label.

### Retention Policies

- **Prometheus**: 7 days (local storage)
- **Thanos**: 
  - Raw: 30 days
  - 5m downsampled: 180 days
  - 1h downsampled: 365 days
- **Loki**: 30 days

### Storage Requirements

Estimated storage needs (adjust based on your workload):
- MinIO: 100Gi (can grow)
- Prometheus: 50Gi
- Loki components: ~30Gi total
- Thanos Store/Compactor: 60Gi total
- AlertManager: 5Gi
- Grafana: 10Gi

Total: ~255Gi minimum

## Usage

### Accessing Services

**Grafana** (Main UI):
```bash
kubectl port-forward -n observability svc/prometheus-grafana 3000:80
```

**Prometheus** (Direct access):
```bash
kubectl port-forward -n observability svc/prometheus-operated 9090:9090
```

**Thanos Query** (PromQL API):
```bash
kubectl port-forward -n observability svc/thanos-query 9090:9090
```

**MinIO Console**:
```bash
kubectl port-forward -n observability svc/minio-console 9001:9001
```

### Grafana Datasources

Pre-configured datasources:
- **Thanos**: Default Prometheus datasource (queries both recent and historical metrics)
- **Loki**: Log datasource for log exploration

### Creating Dashboards

1. Log into Grafana
2. Go to Dashboards → New Dashboard
3. Add panels with queries:
   - Use **Thanos** datasource for metrics
   - Use **Loki** datasource for logs

Many default Kubernetes dashboards are included automatically from kube-prometheus-stack.

### Querying Logs

In Grafana Explore:
1. Select **Loki** datasource
2. Use LogQL queries:
   ```
   {namespace="default"}
   {k8s_pod_name=~"my-app.*"}
   {k8s_namespace_name="observability"} |= "error"
   ```

### Alerting

AlertManager is included in kube-prometheus-stack:
- Configure alerts via PrometheusRule CRDs
- Configure notification channels in AlertManager config
- Default Kubernetes alerts are pre-configured

## Monitoring the Stack

The observability stack monitors itself:

- All components expose metrics via ServiceMonitors
- Prometheus scrapes metrics from all components
- Use the included Grafana dashboards to monitor health

Key metrics to watch:
- Prometheus: `prometheus_tsdb_head_samples_appended_total`
- Thanos: `thanos_objstore_bucket_operations_total`
- Loki: `loki_ingester_chunks_created_total`
- Fluent Bit: `fluentbit_input_records_total`

## Troubleshooting

### Component Not Starting

```bash
# Check HelmRelease status
flux get helmreleases -n observability

# Check pod logs
kubectl logs -n observability <pod-name>

# Check events
kubectl get events -n observability --sort-by='.lastTimestamp'
```

### Prometheus Not Scraping

```bash
# Check ServiceMonitor resources
kubectl get servicemonitors -n observability

# Check Prometheus targets
kubectl port-forward -n observability svc/prometheus-operated 9090:9090
# Visit http://localhost:9090/targets
```

### Loki Not Receiving Logs

```bash
# Check Fluent Bit pods
kubectl get pods -n observability -l app.kubernetes.io/name=fluent-bit

# Check Fluent Bit logs
kubectl logs -n observability -l app.kubernetes.io/name=fluent-bit

# Test Loki ingestion
kubectl port-forward -n observability svc/loki-gateway 3100:80
curl http://localhost:3100/ready
```

### MinIO Connection Issues

```bash
# Verify MinIO is running
kubectl get pods -n observability -l app.kubernetes.io/name=minio

# Check if buckets exist (port-forward MinIO console)
kubectl port-forward -n observability svc/minio-console 9001:9001
# Login and verify buckets: thanos-metrics, loki-chunks, loki-ruler
```

## Scaling

### Horizontal Scaling

Increase replicas in component HelmReleases:
- Thanos Query: `values.query.replicaCount`
- Thanos Store: `values.storegateway.replicaCount`
- Loki components: `values.{read,write,backend}.replicas`

### Vertical Scaling

Adjust resource requests/limits or change resource profile assignments in:
`_clusters/firefly/observability/kustomization.yaml`

### Storage Scaling

Increase PVC sizes in component HelmReleases before deployment. For existing deployments, you may need to:
1. Scale down the component
2. Resize the PVC (if storage class supports it)
3. Scale up the component

## Backup and Recovery

### MinIO Data
- MinIO stores all persistent metrics and logs
- Backup the MinIO PVC or use MinIO's built-in replication

### Grafana Dashboards
- Export dashboards as JSON
- Store in Git alongside infrastructure

### Prometheus Configuration
- All config is in Git (GitOps)
- No manual backup needed

## Maintenance

### Updating Components

1. Update chart versions in HelmRelease files
2. Commit and push
3. FluxCD will automatically upgrade

### Rotating Secrets

1. Generate new credentials
2. Update secrets in all relevant files
3. See [SECRETS.md](./SECRETS.md) for locations
4. Commit and push (encrypted with SOPS if used)
5. Restart affected components

## Additional Resources

- [Prometheus Operator Documentation](https://prometheus-operator.dev/)
- [Thanos Documentation](https://thanos.io/tip/thanos/getting-started.md/)
- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [Fluent Bit Documentation](https://docs.fluentbit.io/manual/)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
