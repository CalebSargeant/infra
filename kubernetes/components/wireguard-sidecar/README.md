# WireGuard Sidecar Component

Reusable Kustomize component that adds a WireGuard sidecar to any Deployment or StatefulSet.

## Features

- Adds WireGuard sidecar container
- Configures routing so RFC1918 traffic uses cluster network
- Routes all non-RFC1918 traffic through WireGuard tunnel
- Works with both Deployments and StatefulSets

## Usage

Add this component to any service's `kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

components:
  - ../components/wireguard-sidecar

resources:
  - deployment.yaml
  - service.yaml
```

That's it! The component will automatically inject the WireGuard sidecar.

## Prerequisites

Create the WireGuard secret in the `media` namespace:

```bash
kubectl create secret generic wireguard-config \
  --from-file=wg0.conf \
  --namespace=media
```

## What Gets Added

- **Init container**: Sets up routing rules
- **Sidecar container**: Runs WireGuard
- **Volumes**: Mounts WireGuard config and kernel modules
- **Security contexts**: Adds required capabilities (NET_ADMIN, SYS_MODULE)

## Verification

```bash
# Check WireGuard is running
kubectl exec -n media <pod-name> -c wireguard -- wg show

# Verify routing
kubectl exec -n media <pod-name> -c <app-name> -- ip route

# Test VPN IP
kubectl exec -n media <pod-name> -c <app-name> -- curl ifconfig.me
```
