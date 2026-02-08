# 1Password Connect and Operator

This directory contains the configuration for deploying 1Password Connect server and the 1Password Kubernetes Operator on the firefly k8s cluster.

## Overview

- **1Password Connect**: A server that provides a REST API for accessing 1Password items
- **1Password Operator**: A Kubernetes operator that syncs 1Password items to Kubernetes Secrets

## Prerequisites

Before deploying, you need to:

1. **Create a 1Password Connect Server in your 1Password account**:
   - Go to your 1Password account settings
   - Navigate to Developer > Directory
   - Create a new Secrets Automation workflow (Connect server)
   - Download the `1password-credentials.json` file
   - Generate and save an access token

2. **Encrypt the credentials**:
   ```bash
   # Encrypt the credentials file
   sops --encrypt --age <your-age-key> \
     --encrypted-regex '^(data|stringData)$' \
     1password-credentials-secret.yaml > 1password-credentials-secret.enc.yaml

   # Encrypt the token file
   sops --encrypt --age <your-age-key> \
     --encrypted-regex '^(data|stringData)$' \
     1password-token-secret.yaml > 1password-token-secret.enc.yaml
   ```

3. **Update the encrypted secret files** in this directory with your actual encrypted values.

## Components Deployed

- **1Password Connect Server**: Two pods (connect-api and connect-sync)
- **1Password Operator**: Watches for OnePasswordItem CRDs and creates Kubernetes Secrets

## Usage

After deployment, you can create Kubernetes Secrets from 1Password items:

```yaml
apiVersion: onepassword.com/v1
kind: OnePasswordItem
metadata:
  name: my-secret
spec:
  itemPath: "vaults/<vault_id_or_title>/items/<item_id_or_title>"
```

Apply this resource:
```bash
kubectl apply -f onepassworditem.yaml
```

The Operator will create a corresponding Kubernetes Secret:
```bash
kubectl get secret my-secret
```

## Resources

- [1Password Connect Documentation](https://developer.1password.com/docs/connect/)
- [1Password Operator Documentation](https://developer.1password.com/docs/k8s/operator/)
- [Helm Chart Repository](https://github.com/1Password/connect-helm-charts)
