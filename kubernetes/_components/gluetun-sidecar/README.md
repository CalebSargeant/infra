# Gluetun Sidecar Component

Reusable Kustomize component that adds a Gluetun VPN sidecar to any Deployment or StatefulSet.

## Features

- Adds Gluetun VPN sidecar container configured for Privado VPN
- Routes all pod traffic through the VPN tunnel
- Allows RFC1918 (private) traffic to use cluster network via `FIREWALL_OUTBOUND_SUBNETS`
- Built-in killswitch via Gluetun's firewall
- Automatic VPN reconnection and health checks

## Usage

Add this component to any service's `kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

components:
  - ../../../_components/gluetun-sidecar

resources:
  - deployment.yaml
  - service.yaml
```

That's it! The component will automatically inject the Gluetun sidecar.

## Prerequisites

Create the Privado VPN credentials secret in the `media` namespace:

```bash
kubectl create secret generic privado-vpn-credentials \
  --from-literal=username=<your-privado-username> \
  --from-literal=password=<your-privado-password> \
  --namespace=media
```

Or create a `privado-credentials.yaml` file:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: privado-vpn-credentials
  namespace: media
type: Opaque
stringData:
  username: your-username
  password: your-password
```

Then apply it:

```bash
kubectl apply -f privado-credentials.yaml
```

## Configuration

The Gluetun sidecar is pre-configured with:

- **VPN Provider**: Privado
- **Default Server**: Netherlands
- **Firewall**: Allows RFC1918 subnets (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) for cluster networking
- **Killswitch**: Enabled by default (blocks traffic if VPN is down)

### Customizing Server Location

To change the VPN server location, you can patch the environment variables in your deployment's kustomization:

```yaml
patches:
  - target:
      kind: Deployment
      name: your-app
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/1/env/3/value
        value: "United States"
```

Or use multiple filters:

```yaml
patches:
  - target:
      kind: Deployment
      name: your-app
    patch: |-
      - op: add
        path: /spec/template/spec/containers/1/env/-
        value:
          name: SERVER_REGIONS
          value: "New York"
```

## What Gets Added

- **Sidecar container**: Runs Gluetun VPN client
- **Environment variables**: Configures Privado VPN connection
- **Security contexts**: Adds required capabilities (NET_ADMIN)
- **Volumes**: Temporary storage for Gluetun

## Killswitch

The Gluetun container has a built-in killswitch that:

1. Blocks all traffic when VPN is down
2. Only allows traffic through the VPN tunnel when connected
3. Allows local RFC1918 traffic for cluster networking
4. Automatically manages iptables rules

## Verification

Check that Gluetun is running and connected:

```bash
# Check pod status
kubectl get pods -n media -l app=sabnzbd

# Check Gluetun logs
kubectl logs -n media <pod-name> -c gluetun

# Verify VPN connection
kubectl logs -n media <pod-name> -c gluetun | grep "ip getter"

# Test external IP from main container (should be VPN IP)
kubectl exec -n media <pod-name> -c sabnzbd -- curl -s ifconfig.me

# Verify cluster networking still works
kubectl exec -n media <pod-name> -c sabnzbd -- curl -s http://overseerr.media.svc.cluster.local:5055
```

## Troubleshooting

### VPN not connecting

- Check the secret exists: `kubectl get secret privado-vpn-credentials -n media`
- Check Gluetun logs: `kubectl logs -n media <pod-name> -c gluetun`
- Verify credentials are correct

### DNS issues

- Gluetun uses its own DNS by default (prevents DNS leaks)
- Cluster DNS should still work for internal services

### Connection drops

- Gluetun will automatically reconnect
- Check logs for errors: `kubectl logs -n media <pod-name> -c gluetun --tail=100`

### Permission issues

The Gluetun container needs:
- `NET_ADMIN` capability for network configuration
- This is automatically added by the component

## Network Topology

```
Pod: sabnzbd
├── Container: sabnzbd (shares network namespace with gluetun)
└── Container: gluetun (creates VPN tunnel)
    ├── VPN Tunnel (wg0 or tun0)
    │   └── All internet traffic → Privado VPN
    └── Local Routes
        └── RFC1918 traffic → Cluster network
```

## References

- [Gluetun Documentation](https://github.com/qdm12/gluetun)
- [Privado VPN](https://privadovpn.com/)
