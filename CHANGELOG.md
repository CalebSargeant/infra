# CHANGELOG

<!-- version list -->

## v1.18.0 (2026-02-08)

### Bug Fixes

- Conditionally assign BGP IPs and update OCI-supported IP ranges
  ([`b5d4611`](https://github.com/CalebSargeant/infra/commit/b5d4611db5e0e6a92a7ec2b56ade33ac3b10b30a))

- Remove postgres reference from database kustomization
  ([`eaa2d2b`](https://github.com/CalebSargeant/infra/commit/eaa2d2bc5c094b9402a3ab2b2349ec882e6402a3))

### Features

- **loki**: Re-enable retention and set compactor.delete_request_store=s3 (MinIO)
  ([`a7bb5dd`](https://github.com/CalebSargeant/infra/commit/a7bb5dd18096025ace81fed87af1b0b04de27459))


## v1.17.2 (2026-02-08)

### Bug Fixes

- Disable backups for MySQL instance and simplify autoRestart config for 1Password Connect
  ([`bf05f0e`](https://github.com/CalebSargeant/infra/commit/bf05f0e14403aaff0db26efb774c302b424118b2))


## v1.17.1 (2026-02-08)

### Bug Fixes

- **loki**: Disable retention to satisfy v3 compactor requirements for now
  ([`e8188b5`](https://github.com/CalebSargeant/infra/commit/e8188b5e91d8edf7e1a7b8b4bc4960f6ee5c4214))


## v1.17.0 (2026-02-08)

### Features

- Add Azure Cost integration and OCI DRG peering modules
  ([`0e73fd4`](https://github.com/CalebSargeant/infra/commit/0e73fd4222b8e28b1c7c4b233a44a4bcc6c2eb15))


## v1.16.6 (2026-02-08)


## v1.16.5 (2026-02-08)

### Bug Fixes

- **observability**: Drop m.large label from loki and thanos to restore base resources
  ([`b65a725`](https://github.com/CalebSargeant/infra/commit/b65a725a93065b255d52ad3039e560672e57906a))


## v1.16.4 (2026-02-08)

### Bug Fixes

- **observability**: Scope m.large profile to kube-prometheus-stack only
  ([`35311d8`](https://github.com/CalebSargeant/infra/commit/35311d8b53a58cacc3d52da3ff76306536d700a5))


## v1.16.3 (2026-02-08)

### Bug Fixes

- **fluent-bit**: Correct loki label_keys to use record accessor syntax
  ([`4013c30`](https://github.com/CalebSargeant/infra/commit/4013c305b0a608c6562a2f0de56bf99df47ca99c))


## v1.16.2 (2026-02-08)

### Bug Fixes

- Use correct format for 1password-connect Helm values
  ([`f8b5ef5`](https://github.com/CalebSargeant/infra/commit/f8b5ef54ad551400e52ea2b8bf4e5f5e3262819e))


## v1.16.1 (2026-02-08)

### Bug Fixes

- Reference existing secret for 1Password Connect credentials
  ([`5af4f66`](https://github.com/CalebSargeant/infra/commit/5af4f66741c5c13e1e2d231246546bebf892451f))


## v1.16.0 (2026-02-08)

### Bug Fixes

- **observability**: Reduce fluent-bit resource requests for mini nodes
  ([`91459dc`](https://github.com/CalebSargeant/infra/commit/91459dc458ef3329b0c355c7766715aa5147937a))


## v1.15.2 (2026-02-08)

### Bug Fixes

- **observability**: Fix fluent-bit image registry and kube-prometheus-stack timeout
  ([`69c8afd`](https://github.com/CalebSargeant/infra/commit/69c8afd6c3a5cba24afdec1e2998df2ed5b56c9f))


## v1.15.1 (2026-02-08)

### Bug Fixes

- Update encrypted secrets for 1Password Connect with SOPS version upgrade
  ([`f81594d`](https://github.com/CalebSargeant/infra/commit/f81594d241170172da7e7fdb8aa0d2c9164f8dda))


## v1.15.0 (2026-01-21)

### Features

- Add Kubernetes manifests for Excalidraw deployment with backend and ingress
  ([`758aa8b`](https://github.com/CalebSargeant/infra/commit/758aa8bd0e7889e75aa44c34bdef530eee6be042))


## v1.14.0 (2026-01-21)


## v1.13.1 (2026-01-21)


## v1.13.0 (2026-01-21)


## v1.12.0 (2026-01-21)


## v1.11.0 (2026-01-21)


## v1.10.2 (2026-01-21)


## v1.10.1 (2026-01-21)

### Bug Fixes

- Update encrypted email data and last modified timestamp in oauth2-proxy-emails-p1.enc.yaml
  ([`5375451`](https://github.com/CalebSargeant/infra/commit/53754515c625290fe1814f43970b9dd3d16c051b))


## v1.10.0 (2026-01-20)

### Features

- Add init container for Headlamp plugins and configure volume mounts
  ([`8b80db9`](https://github.com/CalebSargeant/infra/commit/8b80db91ebc0961b8e0ebd02923f2761ec09f481))


## v1.9.0 (2026-01-20)

### Features

- Update encrypted email data and last modified timestamp in configuration
  ([`eddd0fa`](https://github.com/CalebSargeant/infra/commit/eddd0fafaf8b9870b9a493491b60ddb34c417f9c))


## v1.8.0 (2026-01-20)


## v1.7.0 (2026-01-20)

### Features

- Add OAuth2 middleware for error handling and authentication
  ([`3d4b778`](https://github.com/CalebSargeant/infra/commit/3d4b77894a4962e45c5db484d9683bedcebc7e54))


## v1.6.0 (2026-01-20)


## v1.5.0 (2026-01-20)


## v1.4.0 (2026-01-20)


## v1.3.0 (2026-01-20)


## v1.2.0 (2026-01-20)


## v1.1.25 (2026-01-19)


## v1.1.24 (2026-01-19)


## v1.1.23 (2026-01-19)


## v1.1.22 (2026-01-19)


## v1.1.21 (2026-01-19)


## v1.1.20 (2026-01-19)

### Bug Fixes

- Add Slack notifications to Firefly cluster
  ([`966df5e`](https://github.com/CalebSargeant/infra/commit/966df5e48ee17e70e8734263705bf5f197349dfc))


## v1.1.19 (2026-01-18)


## v1.1.18 (2026-01-18)


## v1.1.17 (2026-01-18)


## v1.1.16 (2026-01-18)

### Bug Fixes

- Move MariaDB resources to dedicated database namespace
  ([`1c063fe`](https://github.com/CalebSargeant/infra/commit/1c063fe41a7bcda66ea84d8db49a3f00381072ed))


## v1.1.15 (2026-01-16)

### Bug Fixes

- Add SOPS decryption to buxfer-sync Kustomization
  ([`a16710b`](https://github.com/CalebSargeant/infra/commit/a16710b70ab188c8da3857657d76dfec50c04bbf))

- Add SOPS decryption to deskbird-booking Kustomization
  ([`41f0969`](https://github.com/CalebSargeant/infra/commit/41f09690944adfb657295b909d4dcb6cc1ca2f11))


## v1.1.14 (2026-01-16)


## v1.1.13 (2026-01-16)


## v1.1.12 (2026-01-16)


## v1.1.11 (2026-01-16)


## v1.1.10 (2026-01-16)


## v1.1.9 (2026-01-16)


## v1.1.8 (2026-01-16)


## v1.1.7 (2026-01-16)


## v1.1.6 (2026-01-16)


## v1.1.5 (2026-01-16)


## v1.1.4 (2026-01-16)


## v1.1.3 (2026-01-16)


## v1.1.2 (2026-01-16)


## v1.1.1 (2026-01-16)

### Bug Fixes

- Update GitRepository URLs for `buxfer-sync` and `deskbird-booking` in Firefly cluster
  ([`7631042`](https://github.com/CalebSargeant/infra/commit/7631042863aadc97ae4d7ab9c9374f5ef7fd486c))

### Refactoring

- Replace GitRepository configs for `buxfer-sync` and `deskbird-booking` with shared `gitrepos.yaml`
  ([`c38dab1`](https://github.com/CalebSargeant/infra/commit/c38dab147f09e10a0dec5540c647284d0ad590e7))


## v1.1.0 (2026-01-16)

### Features

- Update Flux configuration to v2.7.3 in Firefly cluster
  ([`a37c5c7`](https://github.com/CalebSargeant/infra/commit/a37c5c790f779824236c01894b16776f2e08c65e))

### Refactoring

- Consolidate `buxfer-sync` and `deskbird-booking` Kustomization configs in `kustomizations.yaml`
  ([`386c388`](https://github.com/CalebSargeant/infra/commit/386c3882fc2cc7d39d20dcc0a525da5f3dacd63d))


## v1.0.4 (2026-01-15)


## v1.0.3 (2026-01-15)


## v1.0.2 (2026-01-15)


## v1.0.1 (2026-01-01)

### Bug Fixes

- Nextcloud
  ([`f56da95`](https://github.com/CalebSargeant/infra/commit/f56da954a8e8d17b0033803e903d14b9bb528937))

### Chores

- **deps**: Bump CalebSargeant/reusable-workflows from 1.0.2 to 1.0.3
  ([#132](https://github.com/CalebSargeant/infra/pull/132),
  [`423281e`](https://github.com/CalebSargeant/infra/commit/423281e3afef19f9dd64a5f72f7707264a7eb7e6))

### Documentation

- Migrate to MkDocs + GitHub Pages ([#134](https://github.com/CalebSargeant/infra/pull/134),
  [`b5b853a`](https://github.com/CalebSargeant/infra/commit/b5b853aef042fe8f093964ec7ca49273f1290525))


## v1.0.0 (2025-10-22)

- Initial Release
