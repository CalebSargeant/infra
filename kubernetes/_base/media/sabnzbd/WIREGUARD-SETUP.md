# WireGuard Sidecar Setup

This deployment includes a WireGuard sidecar that routes all non-RFC1918 traffic through a VPN tunnel.

## How It Works

1. **WireGuard Sidecar**: Runs alongside sabnzbd and establishes a VPN connection
2. **Shared Network Namespace**: Both containers share the same network stack
3. **Routing Rules**: An init container sets up routes so:
   - RFC1918 addresses (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) use the cluster network
   - All other traffic (internet) goes through the WireGuard tunnel

## Setup Instructions

### 1. Create WireGuard Configuration

Edit `wg0.conf.example` with your WireGuard settings and save as `wg0.conf`:

```bash
# Copy the example
cp wg0.conf.example wg0.conf

# Edit with your values
vim wg0.conf
```

### 2. Create Kubernetes Secret

Create a secret containing your WireGuard configuration:

```bash
kubectl create secret generic wireguard-config \
  --from-file=wg0.conf \
  --namespace=media \
  --dry-run=client -o yaml > wireguard-secret.yaml

# Apply the secret
kubectl apply -f wireguard-secret.yaml
```

Or using kustomize, add to your `kustomization.yaml`:

```yaml
secretGenerator:
  - name: wireguard-config
    files:
      - wg0.conf
```

### 3. Deploy

Apply the deployment:

```bash
kubectl apply -k .
```

## Verification

Check that the WireGuard tunnel is up:

```bash
# Check pod status
kubectl get pods -n media -l app=sabnzbd

# Check WireGuard interface in the pod
kubectl exec -n media -it <pod-name> -c wireguard -- wg show

# Test routing from sabnzbd container
kubectl exec -n media -it <pod-name> -c sabnzbd -- ip route
```

Test that external traffic goes through VPN:

```bash
# Check external IP (should be VPN IP)
kubectl exec -n media -it <pod-name> -c sabnzbd -- curl ifconfig.me

# Internal cluster traffic should still work
kubectl exec -n media -it <pod-name> -c sabnzbd -- ping <internal-service>
```

## Troubleshooting

### WireGuard not connecting
- Check the secret is created: `kubectl get secret wireguard-config -n media`
- Check WireGuard logs: `kubectl logs -n media <pod-name> -c wireguard`

### Routing issues
- Check routes: `kubectl exec -n media <pod-name> -c sabnzbd -- ip route`
- Check init container logs: `kubectl logs -n media <pod-name> -c route-setup`

### Permission issues
The WireGuard container needs:
- `NET_ADMIN` capability for network configuration
- `SYS_MODULE` capability to load kernel modules
- Access to `/lib/modules` (hostPath mount)
