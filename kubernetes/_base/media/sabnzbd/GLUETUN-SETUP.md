# Gluetun VPN Sidecar Setup

This deployment includes a Gluetun sidecar configured with Privado VPN that routes all pod traffic through a VPN tunnel while preserving cluster networking.

## How It Works

1. **Gluetun Sidecar**: Runs alongside sabnzbd and establishes a VPN connection to Privado
2. **Shared Network Namespace**: Both containers share the same network stack
3. **Firewall Rules**: Gluetun's built-in firewall ensures:
   - RFC1918 addresses (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) use the cluster network
   - All internet traffic goes through the Privado VPN tunnel
   - Killswitch blocks traffic if VPN is down
4. **Auto-reconnect**: Gluetun automatically reconnects if the VPN connection drops

## Setup Instructions

### 1. Create Privado VPN Credentials Secret

Create a secret containing your Privado VPN credentials:

```bash
kubectl create secret generic privado-vpn-credentials \
  --from-literal=username=<your-privado-username> \
  --from-literal=password=<your-privado-password> \
  --namespace=media
```

Or create a file `privado-credentials.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: privado-vpn-credentials
  namespace: media
type: Opaque
stringData:
  username: your-privado-username
  password: your-privado-password
```

Then apply it:

```bash
kubectl apply -f privado-credentials.yaml
```

### 2. Deploy

Apply the deployment:

```bash
kubectl apply -k .
```

Or from the cluster-specific path:

```bash
cd kubernetes/_clusters/firefly/media/sabnzbd
kubectl apply -k .
```

## Verification

Check that Gluetun is running and connected:

```bash
# Check pod status
kubectl get pods -n media -l app=sabnzbd

# Check Gluetun logs and connection status
kubectl logs -n media <pod-name> -c gluetun

# Look for successful connection message
kubectl logs -n media <pod-name> -c gluetun | grep -i "ip getter"
```

Test that external traffic goes through VPN:

```bash
# Check external IP (should be VPN IP, not your home IP)
kubectl exec -n media -it <pod-name> -c sabnzbd -- curl -s ifconfig.me

# Internal cluster traffic should still work
kubectl exec -n media -it <pod-name> -c sabnzbd -- curl -s http://overseerr.media.svc.cluster.local:5055
```

## Configuration

The Gluetun sidecar is configured with:

- **VPN Provider**: Privado
- **Server Location**: Netherlands (default)
- **Killswitch**: Enabled (blocks traffic if VPN disconnects)
- **Allowed Subnets**: RFC1918 (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)

### Changing Server Location

To change the VPN server location, edit the base deployment's kustomization to add a patch:

```yaml
patches:
  - target:
      kind: Deployment
      name: sabnzbd
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/1/env/3/value
        value: "United States"
```

Or add more specific filters:

```yaml
patches:
  - target:
      kind: Deployment
      name: sabnzbd
    patch: |-
      - op: add
        path: /spec/template/spec/containers/1/env/-
        value:
          name: SERVER_REGIONS
          value: "New York"
```

## Troubleshooting

### Gluetun not connecting
- Check the secret exists: `kubectl get secret privado-vpn-credentials -n media`
- Check Gluetun logs: `kubectl logs -n media <pod-name> -c gluetun`
- Verify credentials are correct
- Check network connectivity: `kubectl logs -n media <pod-name> -c gluetun | grep -i error`

### VPN connection drops
- Gluetun will automatically reconnect
- Check logs for reconnection attempts: `kubectl logs -n media <pod-name> -c gluetun --tail=50`

### Traffic not going through VPN
- Verify killswitch is active: `kubectl logs -n media <pod-name> -c gluetun | grep -i firewall`
- Check external IP: `kubectl exec -n media <pod-name> -c sabnzbd -- curl ifconfig.me`
- Compare with your actual IP (should be different)

### Cluster networking broken
- Verify FIREWALL_OUTBOUND_SUBNETS includes your cluster's CIDR
- Check pod-to-pod connectivity
- Review Gluetun firewall logs

### Permission issues
The Gluetun container needs:
- `NET_ADMIN` capability for network configuration
- This is automatically added by the gluetun-sidecar component

## Killswitch Details

The Gluetun killswitch:

1. **Blocks all outbound traffic** when VPN is not connected
2. **Only allows**:
   - Traffic through the VPN tunnel when connected
   - Traffic to RFC1918 subnets (cluster networking)
3. **Automatically manages** iptables rules
4. **Prevents DNS leaks** by routing DNS through the VPN

## Advanced: List Available Servers

To see available Privado VPN servers:

```bash
# Run Gluetun with server listing
docker run --rm qmcgaw/gluetun:latest -providers privado

# Or check the Gluetun wiki
# https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers/privado
```
