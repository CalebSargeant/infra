#!/bin/bash
CLUSTER_NAME=$1
NS=${2:-misc}

if [ -z "$CLUSTER_NAME" ]; then
  echo "Usage: $0 <cluster-name> [namespace]"
  echo "Example: $0 my-prod-cluster"
  exit 1
fi

echo "Extracting kubeconfig for cluster: $CLUSTER_NAME"
echo "Namespace: $NS"
echo

TOKEN=$(kubectl get secret headlamp-admin-token -n "$NS" -o jsonpath='{.data.token}' | base64 -d)
CA=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
SERVER=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')

echo "Copy the following into headlamp-kubeconfigs.enc.yaml:"
echo "sops headlamp-kubeconfigs.enc.yaml"
echo
cat <<EOF
  ${CLUSTER_NAME}: |
    apiVersion: v1
    kind: Config
    clusters:
    - name: ${CLUSTER_NAME}
      cluster:
        server: ${SERVER}
        certificate-authority-data: ${CA}
    contexts:
    - name: ${CLUSTER_NAME}
      context:
        cluster: ${CLUSTER_NAME}
        user: headlamp-admin
    current-context: ${CLUSTER_NAME}
    users:
    - name: headlamp-admin
      user:
        token: "${TOKEN}"
EOF
