#!/bin/bash
set -e

echo "Creating basic auth credentials for Headlamp"
echo

read -p "Enter username: " USERNAME
read -sp "Enter password: " PASSWORD
echo

# Generate htpasswd entry
HTPASSWD=$(htpasswd -nb "$USERNAME" "$PASSWORD")

# Create unencrypted secret
cat > basic-auth.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: headlamp-basic-auth
  namespace: misc
type: Opaque
stringData:
  auth: |
    ${HTPASSWD}
EOF

# Encrypt with SOPS
sops --encrypt basic-auth.yaml > basic-auth.enc.yaml
rm basic-auth.yaml

echo
echo "✅ Created basic-auth.enc.yaml"
echo
echo "Add this to kustomization.yaml resources:"
echo "  - basic-auth.enc.yaml"
echo
echo "Then commit and push."
