# Goldilocks - Resource Recommendation Tool

Goldilocks helps you right-size resource requests and limits for your Kubernetes workloads by leveraging the Vertical Pod Autoscaler (VPA).

## How it Works

1. **VPA** analyzes pod resource usage and generates recommendations
2. **Goldilocks Controller** automatically creates VPA objects for enabled namespaces
3. **Goldilocks Dashboard** provides a web UI to view all recommendations

## Enabling Goldilocks for a Namespace

By default, Goldilocks is configured with `on-by-default: false`, meaning it only monitors namespaces that are explicitly labeled.

To enable Goldilocks for a namespace, add the label:

```bash
kubectl label namespace <namespace-name> goldilocks.fairwinds.com/enabled=true
```

Example:
```bash
kubectl label namespace automation goldilocks.fairwinds.com/enabled=true
kubectl label namespace media goldilocks.fairwinds.com/enabled=true
kubectl label namespace database goldilocks.fairwinds.com/enabled=true
```

## Accessing the Dashboard

Once deployed, you can access the Goldilocks dashboard:

```bash
kubectl port-forward -n observability svc/goldilocks-dashboard 8080:80
```

Then open your browser to: http://localhost:8080

## Reading Recommendations

The dashboard shows three recommendation types for each workload:

- **Guaranteed QoS**: Sets requests = limits (best for critical workloads)
- **Burstable QoS**: Sets lower requests than limits (allows burst capacity)
- **Uncapped**: No limits set (allows unlimited burst)

Each recommendation shows:
- Current values
- Recommended values
- Resource usage percentiles (P50, P95, P99)

## Applying Recommendations

Goldilocks provides recommendations but **does not automatically apply them**. You must manually update your deployments with the recommended values.

### Manual Application

1. View recommendations in the dashboard
2. Copy the recommended values
3. Update your Helm values or manifests
4. Apply the changes

### Considerations

- Start with burstable QoS for most workloads
- Use guaranteed QoS for critical services
- Monitor after changes to ensure stability
- VPA needs time to gather data (typically 24-48 hours)

## Disabling Goldilocks for a Namespace

```bash
kubectl label namespace <namespace-name> goldilocks.fairwinds.com/enabled-
```

## Configuration

The Goldilocks configuration is in `helmrelease.yaml`:

- VPA updater is **disabled** by default (no automatic pod restarts)
- Controller only watches labeled namespaces
- Dashboard runs as a single replica

To enable automatic updates, set `updater.enabled: true` in the HelmRelease values.

## Dependencies

- VPA (Vertical Pod Autoscaler) must be installed first
- Both are deployed together in this configuration

## Troubleshooting

Check VPA is running:
```bash
kubectl get pods -n observability -l app.kubernetes.io/name=vpa
```

Check Goldilocks is running:
```bash
kubectl get pods -n observability -l app.kubernetes.io/name=goldilocks
```

View VPA recommendations directly:
```bash
kubectl get vpa -n <namespace>
kubectl describe vpa <vpa-name> -n <namespace>
```
