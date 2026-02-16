# External-DNS MikroTik Provider (Secondary Router)

This directory contains the configuration for the External-DNS MikroTik webhook provider for the **second MikroTik router**, enabling automatic DNS record management.

## Overview

This is a duplicate of the primary `external-dns-mikrotik` configuration, pointing to a secondary MikroTik router. Both instances watch the same Kubernetes Ingress/Service resources and create identical DNS records on their respective routers.

## OCI Vault Secret

Create a secret named `mikrotik-2-credentials` in OCI Vault with the following JSON content:

```json
{"baseurl":"https://YOUR_SECOND_MIKROTIK_IP","username":"YOUR_USER","password":"YOUR_PASSWORD"}
```

## Components

- **external-dns-mikrotik-2**: HelmRelease for external-dns
- **external-dns-mikrotik-2-webhook**: Webhook deployment connecting to the second MikroTik
- **mikrotik-2-credentials**: ExternalSecret pulling from OCI Vault

## See Also

Refer to the primary `external-dns-mikrotik/README.md` for detailed setup instructions.
