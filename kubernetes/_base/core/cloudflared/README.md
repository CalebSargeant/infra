# Cloudflared DaemonSet

This configuration deploys Cloudflare Tunnel (cloudflared) as a DaemonSet on the firefly cluster, running on all node types (pi and mini).

## Prerequisites

You need a Cloudflare Tunnel token from the Cloudflare Zero Trust dashboard.

## Configuration

### 1. Add your tunnel token

Edit the secret file and replace the placeholder with your actual tunnel token:

```bash
nano kubernetes/_base/core/cloudflared/secret.enc.yaml
```

Replace `REPLACE_WITH_YOUR_CLOUDFLARE_TUNNEL_TOKEN` with your actual token.

### 2. Encrypt the secret with SOPS

```bash
cd kubernetes/_base/core/cloudflared
sops --encrypt --age age1yj3wdeleng98w9rv46yh40ettc78r9k4r4wgnx7ja5zxmyt8qe7snjg0a0 --encrypted-regex '^(data|stringData)$' secret.enc.yaml > secret.enc.yaml.tmp
mv secret.enc.yaml.tmp secret.enc.yaml
```

### 3. Commit and push

```bash
git add .
git commit -m "Add encrypted cloudflared tunnel token"
git push
```

Flux will automatically deploy the DaemonSet to all nodes in the firefly cluster.

## Verification

Check that the DaemonSet is running:

```bash
kubectl get daemonset -n core cloudflared
kubectl get pods -n core -l app=cloudflared
```

You should see one pod per node in the cluster.

## Architecture

- **Image**: `cloudflare/cloudflared:latest`
- **Namespace**: `core`
- **Node Selector**: `type: all` (runs on both pi and mini nodes)
- **Resources**: t.nano profile (50m CPU request, 200m limit, 64Mi RAM request, 256Mi limit)
- **Command**: `tunnel --no-autoupdate run --token $(TUNNEL_TOKEN)`
