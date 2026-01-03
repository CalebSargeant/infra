# Headlamp Multi-Cluster Setup

Kubernetes dashboard with path-based authentication for multiple clusters.

## Current Clusters

- **firefly** (`/c/main`) - Local cluster
- **p1-staging-eks** (`/c/p1-staging-eks`) - Remote EKS cluster

## How to Add a New Cluster

### 1. Switch to the target cluster

```bash
kubectl config use-context <cluster-context>
```

### 2. Create ServiceAccount

```bash
kubectl apply -f - <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: headlamp
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: headlamp-admin
  namespace: headlamp
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: headlamp-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: headlamp-admin
    namespace: headlamp
---
apiVersion: v1
kind: Secret
metadata:
  name: headlamp-admin-token
  namespace: headlamp
  annotations:
    kubernetes.io/service-account.name: headlamp-admin
type: kubernetes.io/service-account-token
YAML
```

### 3. Extract the token

```bash
sleep 5  # Wait for token generation
kubectl get secret headlamp-admin-token -n headlamp -o jsonpath='{.data.token}' | base64 -d
```

Copy the token output.

### 4. Create a middleware for the cluster

Create `middleware-<cluster-name>.enc.yaml`:

```yaml
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: headlamp-inject-token-<cluster-name>
  namespace: misc
spec:
  headers:
    customRequestHeaders:
      Authorization: Bearer <PASTE_TOKEN_HERE>
```

Encrypt it:

```bash
sops --encrypt middleware-<cluster-name>.enc.yaml > middleware-<cluster-name>.enc.yaml.tmp && mv middleware-<cluster-name>.enc.yaml.tmp middleware-<cluster-name>.enc.yaml
```

### 5. Update IngressRoute

Add a route for the new cluster in `ingressroute.yaml`:

```yaml
- match: Host(\`headlamp.sargeant.co\`) && (PathPrefix(\`/c/<cluster-name>\`) || PathPrefix(\`/clusters/<cluster-name>\`))
  kind: Rule
  priority: 100
  services:
    - name: headlamp
      port: 80
  middlewares:
    - name: headlamp-inject-token-<cluster-name>
      namespace: misc
```

Place it **before** the catch-all route.

### 6. Update kustomization.yaml

Add the new middleware:

```yaml
resources:
  # ...
  - middleware-<cluster-name>.enc.yaml
```

### 7. Commit and push

```bash
git add middleware-<cluster-name>.enc.yaml ingressroute.yaml kustomization.yaml
git commit -m "Add <cluster-name> to Headlamp"
git push
```

### 8. Access the cluster

Navigate to `https://headlamp.sargeant.co/c/<cluster-name>`

## Architecture

- **Path-based routing**: Each cluster has its own URL path
- **Traefik IngressRoute**: Routes requests to appropriate middleware
- **Middleware per cluster**: Injects the correct bearer token for each cluster
- **No OIDC prompts**: Tokens are handled automatically via middlewares

## Notes

- Cluster name in the URL must match the middleware name
- More specific routes (with PathPrefix) have priority 100
- Catch-all route has priority 10
- Tokens are encrypted with SOPS before committing
