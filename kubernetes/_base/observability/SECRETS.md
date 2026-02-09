# Observability Stack Secrets

This document describes the secrets that need to be configured for the observability stack.

## Overview

The observability stack requires several secrets for:
1. MinIO access credentials
2. Grafana admin password
3. Thanos object storage configuration
4. Loki object storage configuration

## Required Secret Updates

### 1. MinIO Credentials

Update the following files to replace the placeholder passwords:

**File:** `_base/observability/minio/helmrelease.yaml`
- `rootPassword`: MinIO admin password
- `users[].secretKey`: Secret keys for `thanos` and `loki` users

```yaml
rootPassword: minio-admin-password-change-me  # Change this
users:
  - accessKey: thanos
    secretKey: thanos-secret-key-change-me  # Change this
  - accessKey: loki
    secretKey: loki-secret-key-change-me  # Change this
```

### 2. Thanos Object Storage Secret

**File:** `_base/observability/kube-prometheus-stack/thanos-objstore-secret.yaml`

Update the `secret_key` to match the MinIO `thanos` user secret key:

```yaml
stringData:
  objstore.yml: |
    type: s3
    config:
      bucket: thanos-metrics
      endpoint: minio.core.svc.cluster.local:9000
      access_key: thanos
      secret_key: thanos-secret-key-change-me  # Match MinIO thanos user secret
      insecure: true
```

### 3. Thanos Store and Compactor Secrets

**Files:**
- `_base/observability/thanos-store/helmrelease.yaml`
- `_base/observability/thanos-compactor/helmrelease.yaml`

Update the `secret_key` in the `config` section:

```yaml
config: |-
  type: s3
  config:
    bucket: thanos-metrics
    endpoint: minio.core.svc.cluster.local:9000
    access_key: thanos
    secret_key: thanos-secret-key-change-me  # Match MinIO thanos user secret
    insecure: true
```

### 4. Loki Object Storage Configuration

**File:** `_base/observability/loki/helmrelease.yaml`

Update the `secretAccessKey` to match the MinIO `loki` user secret key:

```yaml
storage:
  type: s3
  bucketNames:
    chunks: loki-chunks
    ruler: loki-ruler
  s3:
    endpoint: minio.core.svc.cluster.local:9000
    region: us-east-1
    secretAccessKey: loki-secret-key-change-me  # Match MinIO loki user secret
    accessKeyId: loki
    s3ForcePathStyle: true
    insecure: true
```

### 5. Grafana Admin Password

**File:** `_base/observability/kube-prometheus-stack/helmrelease.yaml`

Update the Grafana admin password:

```yaml
grafana:
  enabled: true
  adminPassword: admin-change-me  # Change this
```

## Using SOPS for Encryption (Recommended)

Your firefly cluster has SOPS enabled (`.sops.yaml` exists). To encrypt sensitive values:

### Option 1: Create Encrypted Secrets (Recommended)

Create cluster-specific encrypted secrets in `_clusters/firefly/observability/`:

1. Create a secret file:
```bash
cd _clusters/firefly/observability
cat > secrets.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: minio-credentials
  namespace: observability
type: Opaque
stringData:
  rootPassword: "your-secure-password-here"
  thanos-secret-key: "your-secure-thanos-key-here"
  loki-secret-key: "your-secure-loki-key-here"
EOF
```

2. Encrypt the file:
```bash
sops --encrypt --in-place secrets.yaml
```

3. Update kustomization to reference the encrypted secret

4. Update HelmRelease values to use `valueFrom` to reference the secret

### Option 2: Direct Replacement (Simple but less secure)

Simply replace all placeholder values directly in the YAML files with your actual credentials. This is simpler but credentials will be in plain text in Git.

## Secret Generation

Generate secure random passwords:

```bash
# Generate strong passwords (32 characters)
openssl rand -base64 32

# Or use this for each credential
MINIO_ROOT_PASSWORD=$(openssl rand -base64 32)
THANOS_SECRET_KEY=$(openssl rand -base64 32)
LOKI_SECRET_KEY=$(openssl rand -base64 32)
GRAFANA_ADMIN_PASSWORD=$(openssl rand -base64 24)

echo "MinIO Root: $MINIO_ROOT_PASSWORD"
echo "Thanos Key: $THANOS_SECRET_KEY"
echo "Loki Key: $LOKI_SECRET_KEY"
echo "Grafana Admin: $GRAFANA_ADMIN_PASSWORD"
```

## Verification Checklist

After updating secrets, verify:

- [ ] MinIO root password changed
- [ ] Thanos user secret key generated and consistent across all Thanos components
- [ ] Loki user secret key generated and consistent in Loki config
- [ ] Grafana admin password changed
- [ ] All placeholders containing "change-me" have been replaced
- [ ] If using SOPS, all sensitive files are encrypted

## Important Notes

1. **Consistency is critical**: The same credentials must be used wherever they appear:
   - MinIO thanos user secret key = Thanos objstore secret = Thanos store/compactor config
   - MinIO loki user secret key = Loki storage config

2. **Security**: Never commit unencrypted secrets to Git. Use SOPS encryption or external secret management.

3. **Access**: Keep credentials secure and rotate them periodically.

4. **Object Storage Endpoint**: The endpoint uses Kubernetes service DNS:
   - `minio.core.svc.cluster.local:9000`
   - This resolves within the cluster automatically
