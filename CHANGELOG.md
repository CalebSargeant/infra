# CHANGELOG

<!-- version list -->

## v1.38.0 (2026-06-10)

### Features

- **atlantis**: Migrate to Longhorn storage on the worker node (Phase 2)
  ([#360](https://github.com/CalebSargeant/infra/pull/360),
  [`98db5b5`](https://github.com/CalebSargeant/infra/commit/98db5b5f3b922ea3e56148e7b8db66c615b1ba00))


## v1.37.1 (2026-06-10)

### Bug Fixes

- Address copilot review feedback on PROJECT_INDEX.json and CLAUDE.md
  ([#271](https://github.com/CalebSargeant/infra/pull/271),
  [`0f20b5c`](https://github.com/CalebSargeant/infra/commit/0f20b5cd5849998e06ad8450cf288692546c87a1))

### Chores

- **claude**: Add context optimization scaffold
  ([#271](https://github.com/CalebSargeant/infra/pull/271),
  [`0f20b5c`](https://github.com/CalebSargeant/infra/commit/0f20b5cd5849998e06ad8450cf288692546c87a1))


## v1.37.0 (2026-06-10)

### Chores

- **headlamp**: Remove dead OpenCost plugin build step
  ([#359](https://github.com/CalebSargeant/infra/pull/359),
  [`78ef89a`](https://github.com/CalebSargeant/infra/commit/78ef89a1c3a6ec2c265b48ecec74d27fdca4c1bc))

### Features

- **cluster**: System/worker node roles + relieve ff-pi1 memory pressure (Phase 1)
  ([#358](https://github.com/CalebSargeant/infra/pull/358),
  [`e306574`](https://github.com/CalebSargeant/infra/commit/e3065743ab7576b8155eaa0ae16e343073b90711))


## v1.36.0 (2026-06-10)

### Bug Fixes

- For pull request finding ([#344](https://github.com/CalebSargeant/infra/pull/344),
  [`dff2964`](https://github.com/CalebSargeant/infra/commit/dff2964e966abb01183ec929142a4910bc5646d0))

- Pin minio/mc to stable release tag in backup cronjob
  ([#355](https://github.com/CalebSargeant/infra/pull/355),
  [`24ee9c4`](https://github.com/CalebSargeant/infra/commit/24ee9c476e71b6def8f6839deb3de9b903d2480c))

- Pin qwen3:4b quantized tag to q4_K_M for deterministic VRAM/behavio
  ([#356](https://github.com/CalebSargeant/infra/pull/356),
  [`c73c1c0`](https://github.com/CalebSargeant/infra/commit/c73c1c021f926ec0a22091b3dae54ca5e798c1c8))

- Remove commented lines and unused components
  ([#332](https://github.com/CalebSargeant/infra/pull/332),
  [`4a13269`](https://github.com/CalebSargeant/infra/commit/4a13269e2290198c80f07e5a45caf17f32eb36e3))

- **alerting**: Add slack externalsecret.yaml (gitignore dropped prior filename)
  ([#306](https://github.com/CalebSargeant/infra/pull/306),
  [`31ede53`](https://github.com/CalebSargeant/infra/commit/31ede53f101fa161885e710e26c7c4d8d0a70ecd))

- **alloy**: Correct QoS class comment from BestEffort to Burstable
  ([#355](https://github.com/CalebSargeant/infra/pull/355),
  [`24ee9c4`](https://github.com/CalebSargeant/infra/commit/24ee9c476e71b6def8f6839deb3de9b903d2480c))

- **blackbox-exporter**: Add http scheme to prober URL
  ([#351](https://github.com/CalebSargeant/infra/pull/351),
  [`4b16f53`](https://github.com/CalebSargeant/infra/commit/4b16f531eb7da0ca88aa5ff66c12dc88e83b36d1))

- **cloudflare**: Correct note from past-tense to imperative in access_apps.tf
  ([#329](https://github.com/CalebSargeant/infra/pull/329),
  [`42b904a`](https://github.com/CalebSargeant/infra/commit/42b904af24218ba4f09043a02d4ff19e89e3595e))

- **cloudflare**: Update WAF rule description to accurately reflect 'skip
  ([#353](https://github.com/CalebSargeant/infra/pull/353),
  [`3d4856c`](https://github.com/CalebSargeant/infra/commit/3d4856c145e94b9589a0f4d3b724f58414675b8f))

- **dns-magmamoose**: Drop comment-commander* (zero-trust-managed) and dunmir (Pages-flow)
  ([#291](https://github.com/CalebSargeant/infra/pull/291),
  [`d1d0679`](https://github.com/CalebSargeant/infra/commit/d1d0679674b9433f22ecf8fce637adb292ebb394))

- **docs**: Use compatible-release constraint for mkdocs-material
  ([#355](https://github.com/CalebSargeant/infra/pull/355),
  [`24ee9c4`](https://github.com/CalebSargeant/infra/commit/24ee9c476e71b6def8f6839deb3de9b903d2480c))

- **fluent-bit**: Use correct node label for Pi exclusion affinity
  ([#352](https://github.com/CalebSargeant/infra/pull/352),
  [`5188667`](https://github.com/CalebSargeant/infra/commit/51886676c13f4ffb5be51be42b84d1fd0d4e7544))

- **kube-prometheus-stack**: Use `type: pi` node affinity label for Grafa
  ([#351](https://github.com/CalebSargeant/infra/pull/351),
  [`4b16f53`](https://github.com/CalebSargeant/infra/commit/4b16f531eb7da0ca88aa5ff66c12dc88e83b36d1))

- **kyverno**: HA admission controller + loosen :9443 probes to stop crashloop
  ([#354](https://github.com/CalebSargeant/infra/pull/354),
  [`08d7cd0`](https://github.com/CalebSargeant/infra/commit/08d7cd01b815a4e41f75c276c7973c3a634ea788))

- **litellm**: Add ollama lan endpoints ([#346](https://github.com/CalebSargeant/infra/pull/346),
  [`085b325`](https://github.com/CalebSargeant/infra/commit/085b325a1e8e6a959fd049bc3bb3b978a7970093))

- **litellm**: Allow rollout off pi node ([#342](https://github.com/CalebSargeant/infra/pull/342),
  [`468f958`](https://github.com/CalebSargeant/infra/commit/468f95880de3eb0d4830f39fac52590ec9b65228))

- **litellm**: Correct qwen tool metadata ([#348](https://github.com/CalebSargeant/infra/pull/348),
  [`0f19d60`](https://github.com/CalebSargeant/infra/commit/0f19d6035bbd8db63e48812c8fb75f17cd0dc6f0))

- **litellm**: Correct qwen3 ollama tag to qwen3:4b
  ([#357](https://github.com/CalebSargeant/infra/pull/357),
  [`4126cd6`](https://github.com/CalebSargeant/infra/commit/4126cd68621e197de84cc37637ea69982c667914))

- **litellm**: Fix comment backtick formatting in nginx auth-proxy config
  ([#344](https://github.com/CalebSargeant/infra/pull/344),
  [`dff2964`](https://github.com/CalebSargeant/infra/commit/dff2964e966abb01183ec929142a4910bc5646d0))

- **litellm**: Increase proxy memory profile
  ([#343](https://github.com/CalebSargeant/infra/pull/343),
  [`c3f0c14`](https://github.com/CalebSargeant/infra/commit/c3f0c1418047d06f4944da19b6857446876bc352))

- **litellm**: Nginx auth-proxy overwrites x-litellm-api-key when UI uses custom header
  ([#344](https://github.com/CalebSargeant/infra/pull/344),
  [`dff2964`](https://github.com/CalebSargeant/infra/commit/dff2964e966abb01183ec929142a4910bc5646d0))

- **litellm**: Preserve client x-litellm-api-key in nginx auth-proxy map
  ([#344](https://github.com/CalebSargeant/infra/pull/344),
  [`dff2964`](https://github.com/CalebSargeant/infra/commit/dff2964e966abb01183ec929142a4910bc5646d0))

- **litellm**: Rely on ollama endpoints source
  ([#347](https://github.com/CalebSargeant/infra/pull/347),
  [`c8888e0`](https://github.com/CalebSargeant/infra/commit/c8888e02e9b4bafb5a2d22954279e07fa559c13c))

- **litellm**: Roll pods on config changes
  ([`4f03577`](https://github.com/CalebSargeant/infra/commit/4f03577116e4a572bafa536537b7b680220df158))

- **litellm**: Set imagePullPolicy to Always for mutable tag
  ([#331](https://github.com/CalebSargeant/infra/pull/331),
  [`8ab1773`](https://github.com/CalebSargeant/infra/commit/8ab1773ab0aa7c2a46a0549d1243212b26b2d0e3))

- **litellm**: Use router-scoped Traefik annotations instead of deprecate
  ([#340](https://github.com/CalebSargeant/infra/pull/340),
  [`32242af`](https://github.com/CalebSargeant/infra/commit/32242afd9cd9be455dfb6a25a96beac6164cc2dc))

- **mikrotik-minder**: Point agent at api.dunmir.magmamoose.com (old workers.dev URL is dead)
  ([#286](https://github.com/CalebSargeant/infra/pull/286),
  [`78fd420`](https://github.com/CalebSargeant/infra/commit/78fd420acbc71b7d7c3c7dda4700de005aec85a7))

- **minio**: Replace root credentials in backup CronJob with a dedicated
  ([#355](https://github.com/CalebSargeant/infra/pull/355),
  [`24ee9c4`](https://github.com/CalebSargeant/infra/commit/24ee9c476e71b6def8f6839deb3de9b903d2480c))

- **observability**: Post-merge corrections — Thanos objstore schema, Loki tuning, Pi fluent-bit,
  blackbox probe ([#352](https://github.com/CalebSargeant/infra/pull/352),
  [`5188667`](https://github.com/CalebSargeant/infra/commit/51886676c13f4ffb5be51be42b84d1fd0d4e7544))

- **oci/backups**: Drop duplicate required_providers (fixes Atlantis plan)
  ([#302](https://github.com/CalebSargeant/infra/pull/302),
  [`3bdb6e8`](https://github.com/CalebSargeant/infra/commit/3bdb6e8f0241a08ff6066ee7c8bc7147223fec9c))

- **oci/backups**: Drop module required_providers block
  ([#305](https://github.com/CalebSargeant/infra/pull/305),
  [`b1256b4`](https://github.com/CalebSargeant/infra/commit/b1256b498454986ef68e611e666951e590b7f122))

- **oci/backups**: Drop module required_providers block
  ([#304](https://github.com/CalebSargeant/infra/pull/304),
  [`5b4a54f`](https://github.com/CalebSargeant/infra/commit/5b4a54f0b83f31543a3045bdb2512a3fb34b7277))

- **oci/backups**: Drop module required_providers block
  ([#303](https://github.com/CalebSargeant/infra/pull/303),
  [`1ac6d1d`](https://github.com/CalebSargeant/infra/commit/1ac6d1db9d963d35b89ba5e26d4b1c6db870bcd6))

- **oci/backups**: Drop module required_providers block
  ([#302](https://github.com/CalebSargeant/infra/pull/302),
  [`3bdb6e8`](https://github.com/CalebSargeant/infra/commit/3bdb6e8f0241a08ff6066ee7c8bc7147223fec9c))

- **oci/backups**: Set email on backup-writer user (required by Identity Domains)
  ([#305](https://github.com/CalebSargeant/infra/pull/305),
  [`b1256b4`](https://github.com/CalebSargeant/infra/commit/b1256b498454986ef68e611e666951e590b7f122))

- **oci/backups**: Set email on backup-writer user (required by Identity Domains)
  ([#304](https://github.com/CalebSargeant/infra/pull/304),
  [`5b4a54f`](https://github.com/CalebSargeant/infra/commit/5b4a54f0b83f31543a3045bdb2512a3fb34b7277))

- **oci/backups**: Set email on backup-writer user (required by Identity Domains)
  ([#303](https://github.com/CalebSargeant/infra/pull/303),
  [`1ac6d1d`](https://github.com/CalebSargeant/infra/commit/1ac6d1db9d963d35b89ba5e26d4b1c6db870bcd6))

- **oci/backups**: Set service email on backup-writer (IDCS requires it)
  ([#303](https://github.com/CalebSargeant/infra/pull/303),
  [`1ac6d1d`](https://github.com/CalebSargeant/infra/commit/1ac6d1db9d963d35b89ba5e26d4b1c6db870bcd6))

- **rbac**: Grant Kyverno background-controller RoleBinding perms
  ([#320](https://github.com/CalebSargeant/infra/pull/320),
  [`442a392`](https://github.com/CalebSargeant/infra/commit/442a392b4479596d0659a4419df6cbc2a3d22bc6))

- **rbac**: Grant Kyverno bind+escalate on admin ClusterRole
  ([#321](https://github.com/CalebSargeant/infra/pull/321),
  [`6f4bf7b`](https://github.com/CalebSargeant/infra/commit/6f4bf7ba2784bd304507fb657dc952dc72d0e2b4))

- **recyclarr**: Pin to v7 + add Radarr 4K (SQP-1 2160p)
  ([#297](https://github.com/CalebSargeant/infra/pull/297),
  [`1d9a4ac`](https://github.com/CalebSargeant/infra/commit/1d9a4ac961d8b416a6f0904a2a3b1d4b8c300056))

- **sonarr**: Cap 1080p episodes at ~3GB via API quality definitions
  ([#322](https://github.com/CalebSargeant/infra/pull/322),
  [`891991d`](https://github.com/CalebSargeant/infra/commit/891991da0259d63e0eefd9772fd75145f9dadbcc))

- **storage**: Move downloads PV off node root disk to K8s-native NFS
  ([#308](https://github.com/CalebSargeant/infra/pull/308),
  [`5c499c9`](https://github.com/CalebSargeant/infra/commit/5c499c9a545274ae652cd569aab0a3ca6c571e17))

- **streaming-sync**: Netflix-only provider (Prime NL flatrate too broad)
  ([#324](https://github.com/CalebSargeant/infra/pull/324),
  [`aac6a1a`](https://github.com/CalebSargeant/infra/commit/aac6a1a4fb42df7283937edac9f97e5a773c028a))

- **tunnel**: Drop v5-only firefly_oci tunnel-token data source + output
  ([#285](https://github.com/CalebSargeant/infra/pull/285),
  [`251aa6b`](https://github.com/CalebSargeant/infra/commit/251aa6b1cbec421b45443317593cf34b3243e837))

### Chores

- Onboard Chargate security + lint scanning
  ([#337](https://github.com/CalebSargeant/infra/pull/337),
  [`48bb1e0`](https://github.com/CalebSargeant/infra/commit/48bb1e0656cfa7e5a84f8dd7542397a3af9d17a4))

- **deps**: Bump docker/setup-qemu-action from 4.0.0 to 4.1.0
  ([#277](https://github.com/CalebSargeant/infra/pull/277),
  [`3f6f550`](https://github.com/CalebSargeant/infra/commit/3f6f5509458bc17e0b14dd9ab470c70f3608b8ee))

- **deps**: Bump magmamoose/release-runner from 1.14.1 to 1.26.0
  ([#281](https://github.com/CalebSargeant/infra/pull/281),
  [`b9c55ce`](https://github.com/CalebSargeant/infra/commit/b9c55ce20e38e536ea768231223a41dfdb87045e))

- **deps**: Bump magmamoose/release-runner from 1.26.0 to 1.30.0
  ([#339](https://github.com/CalebSargeant/infra/pull/339),
  [`32b8e31`](https://github.com/CalebSargeant/infra/commit/32b8e31566797cabc532a74b88bca150e7ebe23d))

- **flux**: Retire comment-commander + comment-commander-pro
  ([#335](https://github.com/CalebSargeant/infra/pull/335),
  [`86107b9`](https://github.com/CalebSargeant/infra/commit/86107b93b26747e9d66b1e05717c968543d2d8eb))

- **media**: Bump image tags
  ([`363a106`](https://github.com/CalebSargeant/infra/commit/363a1066c4206e36f2449c6cdb7c4dca9dfc5da8))

- **media**: Bump image tags
  ([`bd4c2c3`](https://github.com/CalebSargeant/infra/commit/bd4c2c3702e4bbd6fa415c84ca803277f05d04a5))

- **media**: Bump image tags
  ([`6df1c1d`](https://github.com/CalebSargeant/infra/commit/6df1c1dffe3b57c736fed9a845c6b7b5443a86c0))

- **media**: Bump image tags
  ([`5865788`](https://github.com/CalebSargeant/infra/commit/586578838369d2affc89ffe6731e366c68f7b7d1))

- **media**: Bump image tags
  ([`80e4012`](https://github.com/CalebSargeant/infra/commit/80e4012261e6f655573dfb52a7fb2b96b14811ae))

- **media**: Bump image tags
  ([`b5c2bb5`](https://github.com/CalebSargeant/infra/commit/b5c2bb57d4a63fe1270252ad6c45dc4053b4babd))

- **media**: Bump image tags
  ([`2db02e8`](https://github.com/CalebSargeant/infra/commit/2db02e8a3419799166c5faa9086fc3e4912f559e))

- **media**: Bump image tags
  ([`f223126`](https://github.com/CalebSargeant/infra/commit/f223126d3bd45268a80cd0bdb4dac254163b394c))

- **media**: Bump image tags
  ([`d4c9d6e`](https://github.com/CalebSargeant/infra/commit/d4c9d6e7e3947956566572162237f3e0de7e8ab5))

- **media**: Bump image tags
  ([`6f761ab`](https://github.com/CalebSargeant/infra/commit/6f761ab6ef316e6252bc040d34191844c778eb66))

- **media**: Bump image tags
  ([`a3af305`](https://github.com/CalebSargeant/infra/commit/a3af305de62fd1fa426dc64e83a2d42e77d33516))

- **media**: Bump image tags
  ([`48079da`](https://github.com/CalebSargeant/infra/commit/48079daa0c3b5507cc4f6687e7d4cf9c07aac1de))

- **media**: Bump image tags
  ([`8233984`](https://github.com/CalebSargeant/infra/commit/82339846d8a7b0313b283e33e850d0028302e74f))

- **media**: Bump image tags
  ([`f9f2b60`](https://github.com/CalebSargeant/infra/commit/f9f2b6084574579bce1d6aaf5bed31b3bc81ee53))

- **media**: Bump image tags
  ([`faa145f`](https://github.com/CalebSargeant/infra/commit/faa145f508f4e970d6b7c7dc415d75dcc6c0ba0a))

- **media**: Bump image tags
  ([`6bfd5f1`](https://github.com/CalebSargeant/infra/commit/6bfd5f1c48284c02ad1f791131960fb0932114f1))

- **media**: Bump image tags
  ([`2b4a225`](https://github.com/CalebSargeant/infra/commit/2b4a225b57914c926edc3624a5e063aaf0c3c22e))

- **media**: Bump image tags
  ([`d507247`](https://github.com/CalebSargeant/infra/commit/d507247a904ecc36011d27dfc110706521a1b270))

- **media**: Bump image tags
  ([`39db900`](https://github.com/CalebSargeant/infra/commit/39db900ace771c337029b709185bc8bf43a03ca6))

- **media**: Bump image tags
  ([`0ca75b2`](https://github.com/CalebSargeant/infra/commit/0ca75b2d05a863992da8a579a4c942c56a8f0dc0))

- **media**: Bump image tags
  ([`9571bb0`](https://github.com/CalebSargeant/infra/commit/9571bb02272d4a1523a306a55b3d5a5b066dae2f))

- **media**: Bump image tags
  ([`c633c5e`](https://github.com/CalebSargeant/infra/commit/c633c5ef029038a8ef0f8294baaf61fda71bc86b))

- **media**: Bump image tags
  ([`3e726dd`](https://github.com/CalebSargeant/infra/commit/3e726dd0c764971c78362127e5f0799cc3d8839a))

- **media**: Bump image tags
  ([`4b9db6e`](https://github.com/CalebSargeant/infra/commit/4b9db6e6f110c144f3fcb2c29732394f8564edeb))

- **media**: Bump image tags
  ([`dc2c556`](https://github.com/CalebSargeant/infra/commit/dc2c556ef98ee1162872786209cff160b4330d75))

- **media**: Bump image tags
  ([`7a0832e`](https://github.com/CalebSargeant/infra/commit/7a0832e223b2b684d743b43b748dd1a9778e22b8))

- **media**: Bump image tags
  ([`824bde7`](https://github.com/CalebSargeant/infra/commit/824bde7697ded071c556f756a0c2e57330656342))

- **media**: Bump image tags
  ([`131e91b`](https://github.com/CalebSargeant/infra/commit/131e91bc07194c43e44bd50bf1e9447359f3fe3a))

- **media**: Bump image tags
  ([`8d4159f`](https://github.com/CalebSargeant/infra/commit/8d4159f4c4fb3d6433fce2192c72215e8b5b91b6))

- **mikrotik-minder**: Pin agent image to 1.5.2 (SSH/host-key/false-alert hardening)
  ([#283](https://github.com/CalebSargeant/infra/pull/283),
  [`d3ec46b`](https://github.com/CalebSargeant/infra/commit/d3ec46b6a572d102fab3593650cf647ae6a9e61b))

### Documentation

- Fix Alloy label schema and QoS classification
  ([#355](https://github.com/CalebSargeant/infra/pull/355),
  [`24ee9c4`](https://github.com/CalebSargeant/infra/commit/24ee9c476e71b6def8f6839deb3de9b903d2480c))

- **kyverno**: Qualify chart default comments with version (3.8+)
  ([#354](https://github.com/CalebSargeant/infra/pull/354),
  [`08d7cd0`](https://github.com/CalebSargeant/infra/commit/08d7cd01b815a4e41f75c276c7973c3a634ea788))

- **observability**: Rewrite to current-state; scaffold mkdocs + pass strict build
  ([#355](https://github.com/CalebSargeant/infra/pull/355),
  [`24ee9c4`](https://github.com/CalebSargeant/infra/commit/24ee9c476e71b6def8f6839deb3de9b903d2480c))

- **operations**: Fix stale cloudflared DaemonSet link to current path
  ([#355](https://github.com/CalebSargeant/infra/pull/355),
  [`24ee9c4`](https://github.com/CalebSargeant/infra/commit/24ee9c476e71b6def8f6839deb3de9b903d2480c))

### Features

- **access**: Bypass app for diatreme.magmamoose.com/api/dispatch
  ([#336](https://github.com/CalebSargeant/infra/pull/336),
  [`c4656e3`](https://github.com/CalebSargeant/infra/commit/c4656e39c9be0b85fb0174f32b87ca8f30255f68))

- **alerting**: Critical + CNPG backup alerts to Slack
  ([#305](https://github.com/CalebSargeant/infra/pull/305),
  [`b1256b4`](https://github.com/CalebSargeant/infra/commit/b1256b498454986ef68e611e666951e590b7f122))

- **alerting**: Route critical + CNPG backup alerts to Slack
  ([#305](https://github.com/CalebSargeant/infra/pull/305),
  [`b1256b4`](https://github.com/CalebSargeant/infra/commit/b1256b498454986ef68e611e666951e590b7f122))

- **apps**: Add ghcr pull-secret RBAC for diatreme-pro
  ([#295](https://github.com/CalebSargeant/infra/pull/295),
  [`611ef81`](https://github.com/CalebSargeant/infra/commit/611ef81f534a2125822afa35f0ded4f75d041b15))

- **apps**: Fold diatreme-pro into apps/ (publishes diatreme.magmamoose.com DNS)
  ([#292](https://github.com/CalebSargeant/infra/pull/292),
  [`7296f68`](https://github.com/CalebSargeant/infra/commit/7296f680df3f52902747cadcd01d6b1d6ec20953))

- **apps**: Register ghcr-reader-rbac in diatreme-pro base
  ([#295](https://github.com/CalebSargeant/infra/pull/295),
  [`611ef81`](https://github.com/CalebSargeant/infra/commit/611ef81f534a2125822afa35f0ded4f75d041b15))

- **bazarr**: Move /config to Longhorn (replicated storage)
  ([#311](https://github.com/CalebSargeant/infra/pull/311),
  [`669dc99`](https://github.com/CalebSargeant/infra/commit/669dc99e9963605765fa71e5015cc659e48c4acf))

- **bazarr**: Use CNPG Postgres backend ([#300](https://github.com/CalebSargeant/infra/pull/300),
  [`bd7e0bc`](https://github.com/CalebSargeant/infra/commit/bd7e0bc4da463ea469e81c5fc10a303416320ba5))

- **cloudflare**: Diatreme Pro dashboard Access + docs DNS
  ([#284](https://github.com/CalebSargeant/infra/pull/284),
  [`4283315`](https://github.com/CalebSargeant/infra/commit/4283315456f6c3f0b519e29aa7928a66bdb220ee))

- **cloudflare**: DNS for dunmir.magmamoose.com (Pro UI Pages custom domain)
  ([#287](https://github.com/CalebSargeant/infra/pull/287),
  [`66dd2f1`](https://github.com/CalebSargeant/infra/commit/66dd2f1f99a67ec2b6676cd6e198ec0571f06688))

- **cloudflare**: Gate Diatreme Pro dashboard at diatreme.magmamoose.com
  ([#284](https://github.com/CalebSargeant/infra/pull/284),
  [`4283315`](https://github.com/CalebSargeant/infra/commit/4283315456f6c3f0b519e29aa7928a66bdb220ee))

- **cloudflare**: Skip Super Bot Fight Mode for litellm-warp hostname
  ([#353](https://github.com/CalebSargeant/infra/pull/353),
  [`3d4856c`](https://github.com/CalebSargeant/infra/commit/3d4856c145e94b9589a0f4d3b724f58414675b8f))

- **cnpg**: Back up to OCI Object Storage (offsite)
  ([#304](https://github.com/CalebSargeant/infra/pull/304),
  [`5b4a54f`](https://github.com/CalebSargeant/infra/commit/5b4a54f0b83f31543a3045bdb2512a3fb34b7277))

- **cnpg**: Back up to OCI Object Storage instead of in-cluster MinIO
  ([#305](https://github.com/CalebSargeant/infra/pull/305),
  [`b1256b4`](https://github.com/CalebSargeant/infra/commit/b1256b498454986ef68e611e666951e590b7f122))

- **cnpg**: Back up to OCI Object Storage instead of in-cluster MinIO
  ([#304](https://github.com/CalebSargeant/infra/pull/304),
  [`5b4a54f`](https://github.com/CalebSargeant/infra/commit/5b4a54f0b83f31543a3045bdb2512a3fb34b7277))

- **dns**: Docs.diatreme.magmamoose.com → GitHub Pages (diatreme docs)
  ([#284](https://github.com/CalebSargeant/infra/pull/284),
  [`4283315`](https://github.com/CalebSargeant/infra/commit/4283315456f6c3f0b519e29aa7928a66bdb220ee))

- **dunmir**: Remove Cloudflare Access — Stytch gates the Pro UI
  ([#329](https://github.com/CalebSargeant/infra/pull/329),
  [`42b904a`](https://github.com/CalebSargeant/infra/commit/42b904af24218ba4f09043a02d4ff19e89e3595e))

- **dunmir**: Remove Cloudflare Access — Stytch now gates the Pro UI
  ([#329](https://github.com/CalebSargeant/infra/pull/329),
  [`42b904a`](https://github.com/CalebSargeant/infra/commit/42b904af24218ba4f09043a02d4ff19e89e3595e))

- **litellm**: Add auth proxy and visible oauth metadata
  ([#341](https://github.com/CalebSargeant/infra/pull/341),
  [`04a986e`](https://github.com/CalebSargeant/infra/commit/04a986e06e466f1438b285aabd14bd080753d42f))

- **litellm**: Add ollama lan provider ([#345](https://github.com/CalebSargeant/infra/pull/345),
  [`f1af6e8`](https://github.com/CalebSargeant/infra/commit/f1af6e845e05314435252dbe566e9f0c716bfb70))

- **litellm**: Add qwen3-4b agent model with tool-calling
  ([#356](https://github.com/CalebSargeant/infra/pull/356),
  [`c73c1c0`](https://github.com/CalebSargeant/infra/commit/c73c1c021f926ec0a22091b3dae54ca5e798c1c8))

- **litellm**: Add qwen3-4b agent model with tool-calling enabled
  ([#356](https://github.com/CalebSargeant/infra/pull/356),
  [`c73c1c0`](https://github.com/CalebSargeant/infra/commit/c73c1c021f926ec0a22091b3dae54ca5e798c1c8))

- **litellm**: Admin UI via Cloudflare Access + Postgres
  ([#334](https://github.com/CalebSargeant/infra/pull/334),
  [`544d81c`](https://github.com/CalebSargeant/infra/commit/544d81c37e60898bbf61cecfac356a631c432a63))

- **litellm**: Deploy LiteLLM proxy on Firefly (automation ns)
  ([#331](https://github.com/CalebSargeant/infra/pull/331),
  [`8ab1773`](https://github.com/CalebSargeant/infra/commit/8ab1773ab0aa7c2a46a0549d1243212b26b2d0e3))

- **litellm**: Expose Warp inference endpoint
  ([`7b8d1a4`](https://github.com/CalebSargeant/infra/commit/7b8d1a4eb773d8b72c63ad97ae41acbbedf112c6))

- **litellm**: LAN Traefik ingress + drop unapplied public Access path
  ([#340](https://github.com/CalebSargeant/infra/pull/340),
  [`32242af`](https://github.com/CalebSargeant/infra/commit/32242afd9cd9be455dfb6a25a96beac6164cc2dc))

- **litellm**: LAN Traefik ingress; drop unapplied public Access path
  ([#340](https://github.com/CalebSargeant/infra/pull/340),
  [`32242af`](https://github.com/CalebSargeant/infra/commit/32242afd9cd9be455dfb6a25a96beac6164cc2dc))

- **longhorn**: Deploy Longhorn for replicated/resilient block storage
  ([#310](https://github.com/CalebSargeant/infra/pull/310),
  [`87d6eee`](https://github.com/CalebSargeant/infra/commit/87d6eeeb3ead45fac84c4c1d0fb06610c67ccccf))

- **media**: All 5 apps via pod-gateway (one Privado tunnel)
  ([#318](https://github.com/CalebSargeant/infra/pull/318),
  [`51f0987`](https://github.com/CalebSargeant/infra/commit/51f09874a9172116386bff25439cd6d842e67025))

- **media**: Auto-update image tags via Flux ImageUpdateAutomation
  ([#289](https://github.com/CalebSargeant/infra/pull/289),
  [`a594672`](https://github.com/CalebSargeant/infra/commit/a594672992c2422912f261f0dbae7991493e77db))

- **media**: Jackett via pod-gateway (test client)
  ([#317](https://github.com/CalebSargeant/infra/pull/317),
  [`419d90e`](https://github.com/CalebSargeant/infra/commit/419d90e969142ddad854e48f0c8de2baecf46fc4))

- **media**: Kill-switched gluetun VPN for jackett/nzbhydra2/prowlarr/sabnzbd
  ([#314](https://github.com/CalebSargeant/infra/pull/314),
  [`4442366`](https://github.com/CalebSargeant/infra/commit/444236609363485d47faf574d7efd387f6c6667a))

- **media**: Route jackett through pod-gateway (VPN client test)
  ([#318](https://github.com/CalebSargeant/infra/pull/318),
  [`51f0987`](https://github.com/CalebSargeant/infra/commit/51f09874a9172116386bff25439cd6d842e67025))

- **media**: Route jackett through pod-gateway (VPN client test)
  ([#317](https://github.com/CalebSargeant/infra/pull/317),
  [`419d90e`](https://github.com/CalebSargeant/infra/commit/419d90e969142ddad854e48f0c8de2baecf46fc4))

- **media**: Route jackett/nzbhydra2/prowlarr/sabnzbd through kill-switched gluetun (Privado)
  ([#314](https://github.com/CalebSargeant/infra/pull/314),
  [`4442366`](https://github.com/CalebSargeant/infra/commit/444236609363485d47faf574d7efd387f6c6667a))

- **media**: Route qbittorrent/prowlarr/nzbhydra2/sabnzbd through pod-gateway
  ([#318](https://github.com/CalebSargeant/infra/pull/318),
  [`51f0987`](https://github.com/CalebSargeant/infra/commit/51f09874a9172116386bff25439cd6d842e67025))

- **media**: Streaming-sync — auto-prune titles already on Netflix/Prime NL
  ([#323](https://github.com/CalebSargeant/infra/pull/323),
  [`5deb8c3`](https://github.com/CalebSargeant/infra/commit/5deb8c3e63d90227192a1f5ac02ef18a2ddee120))

- **mikrotik-minder**: Auto-bump agent image via Flux ImageUpdateAutomation
  ([#309](https://github.com/CalebSargeant/infra/pull/309),
  [`f80d512`](https://github.com/CalebSargeant/infra/commit/f80d5126e09e6793ff055fcdf485f2315a1ff012))

- **mikrotik-minder**: Roll agent to 1.6.0 (inventory + packet-loss probes)
  ([#307](https://github.com/CalebSargeant/infra/pull/307),
  [`e1a3b45`](https://github.com/CalebSargeant/infra/commit/e1a3b45b1ce9dca3c9ea25c7602766039c6f686f))

- **mikrotik-minder**: Set agent_key_path to enable the Pro vault
  ([#327](https://github.com/CalebSargeant/infra/pull/327),
  [`9ba2e57`](https://github.com/CalebSargeant/infra/commit/9ba2e57dee12941e339d5d18570979125858aef7))

- **monitoring**: Alert on CNPG backup failure/staleness
  ([#299](https://github.com/CalebSargeant/infra/pull/299),
  [`aee80d9`](https://github.com/CalebSargeant/infra/commit/aee80d9a3fe2ac2066ac7c824ca9dc18589ffc76))

- **observability**: Ff-pi1 logs (Alloy), Grafana ingress, MinIO->OCI backup
  ([#355](https://github.com/CalebSargeant/infra/pull/355),
  [`24ee9c4`](https://github.com/CalebSargeant/infra/commit/24ee9c476e71b6def8f6839deb3de9b903d2480c))

- **observability**: Get firefly stack green — OCI ExternalSecrets, KRR sizing, Thanos/Loki/Grafana
  fixes ([#351](https://github.com/CalebSargeant/infra/pull/351),
  [`4b16f53`](https://github.com/CalebSargeant/infra/commit/4b16f531eb7da0ca88aa5ff66c12dc88e83b36d1))

- **qbittorrent**: VPN via kill-switched gluetun (Privado OpenVPN) instead of wireguard
  ([#314](https://github.com/CalebSargeant/infra/pull/314),
  [`4442366`](https://github.com/CalebSargeant/infra/commit/444236609363485d47faf574d7efd387f6c6667a))

- **qbittorrent**: VPN via kill-switched gluetun (Privado OpenVPN) instead of wireguard
  ([#313](https://github.com/CalebSargeant/infra/pull/313),
  [`baf61c2`](https://github.com/CalebSargeant/infra/commit/baf61c2560ae12c4ed134023492c619fb63c13bd))

- **rbac**: Scope daily kubectl access via humans group + Kyverno
  ([#319](https://github.com/CalebSargeant/infra/pull/319),
  [`c61116b`](https://github.com/CalebSargeant/infra/commit/c61116b88cd38b453ade2e47412ee67b18d00b3a))

- **recyclarr**: Config-as-code 1080p quality for Sonarr via TRaSH
  ([#296](https://github.com/CalebSargeant/infra/pull/296),
  [`5023ecc`](https://github.com/CalebSargeant/infra/commit/5023ecc33d68ab7d5de9d4c501e7bdf09aa9907c))

- **streaming-sync**: Add Amazon Prime Video to providers
  ([#326](https://github.com/CalebSargeant/infra/pull/326),
  [`e6f2bf0`](https://github.com/CalebSargeant/infra/commit/e6f2bf0d94707a4d254afda59406256d11fa47ba))

- **streaming-sync**: Arm Netflix-NL pruning (DRY_RUN=false, cap 400)
  ([#325](https://github.com/CalebSargeant/infra/pull/325),
  [`1aa23f5`](https://github.com/CalebSargeant/infra/commit/1aa23f5bb2fd0a817889e0f2e16345845b4ef22b))

- **vpn**: Deploy pod-gateway — shared Privado VPN gateway for media apps
  ([#318](https://github.com/CalebSargeant/infra/pull/318),
  [`51f0987`](https://github.com/CalebSargeant/infra/commit/51f09874a9172116386bff25439cd6d842e67025))

- **vpn**: Deploy pod-gateway — shared Privado VPN gateway for media apps
  ([#317](https://github.com/CalebSargeant/infra/pull/317),
  [`419d90e`](https://github.com/CalebSargeant/infra/commit/419d90e969142ddad854e48f0c8de2baecf46fc4))

- **vpn**: Deploy pod-gateway — shared Privado VPN gateway for media apps
  ([#316](https://github.com/CalebSargeant/infra/pull/316),
  [`95026c6`](https://github.com/CalebSargeant/infra/commit/95026c6f55851e19a24ccf0ca3e11959b0c8a631))

### Refactoring

- **flux**: Fold external-repo apps from flux-system into apps/<app>/
  ([#290](https://github.com/CalebSargeant/infra/pull/290),
  [`f805ebb`](https://github.com/CalebSargeant/infra/commit/f805ebb6c94a2f9f6ab5e2408097657c70c7b4d3))

- **flux**: Strip flux-system to bootstrap-only; relocate shared config
  ([#293](https://github.com/CalebSargeant/infra/pull/293),
  [`724a409`](https://github.com/CalebSargeant/infra/commit/724a4099b34d4be0a3aef3d99bcbdde8fe937fa9))

- **litellm**: Claude Max-subscription pass-through (follow-up to #331)
  ([#333](https://github.com/CalebSargeant/infra/pull/333),
  [`b50eaa8`](https://github.com/CalebSargeant/infra/commit/b50eaa89ba79705d4b3895110d0501f032c7f7a7))

- **media**: Colocate image automation in each app's prod/ folder
  ([#289](https://github.com/CalebSargeant/infra/pull/289),
  [`a594672`](https://github.com/CalebSargeant/infra/commit/a594672992c2422912f261f0dbae7991493e77db))

- **media**: Consolidate image automation into infrastructure/flux
  ([#294](https://github.com/CalebSargeant/infra/pull/294),
  [`047ffae`](https://github.com/CalebSargeant/infra/commit/047ffaeb91424fd1ea6cb5c20f5ea330b29fd09b))


## v1.35.0 (2026-05-30)

### Features

- **cloudflare**: Gate dunmir.magmamoose.com in the Mikrotik Minder Pro Access app
  ([#280](https://github.com/CalebSargeant/infra/pull/280),
  [`ac2a9d3`](https://github.com/CalebSargeant/infra/commit/ac2a9d3d68f881f753042dedaa2793e4115cf827))


## v1.34.4 (2026-05-30)

### Bug Fixes

- **mikrotik-minder**: Pin github.com host keys so the export push works under RO rootfs
  ([#282](https://github.com/CalebSargeant/infra/pull/282),
  [`4ddc238`](https://github.com/CalebSargeant/infra/commit/4ddc238ff6203b759a75cce42e8641aca0988103))

### Chores

- **mikrotik-minder**: Pin agent image to 1.5.1 (git-concurrency fix)
  ([#279](https://github.com/CalebSargeant/infra/pull/279),
  [`eb98a60`](https://github.com/CalebSargeant/infra/commit/eb98a607f8f3b32e5d6af369843669f851851e25))


## v1.34.3 (2026-05-27)

### Bug Fixes

- **flux**: Point zoey ImageRepositories at ghcr.io/magmamoose/*
  ([#275](https://github.com/CalebSargeant/infra/pull/275),
  [`6d640f3`](https://github.com/CalebSargeant/infra/commit/6d640f31bf140f3fccd3152e6adf3ef676ebef20))


## v1.34.2 (2026-05-27)

### Bug Fixes

- **flux**: Point transferred repos at github-app-magmamoose
  ([#273](https://github.com/CalebSargeant/infra/pull/273),
  [`5c9041e`](https://github.com/CalebSargeant/infra/commit/5c9041e51160e4c3c73eb1984e3b4aad85ef72b2))

- **flux**: Rotate buxfer-sync-github-app installationID after App reinstall
  ([#273](https://github.com/CalebSargeant/infra/pull/273),
  [`5c9041e`](https://github.com/CalebSargeant/infra/commit/5c9041e51160e4c3c73eb1984e3b4aad85ef72b2))


## v1.34.1 (2026-05-24)

### Bug Fixes

- **tunnel,dns**: Persist sargeant.co cc/cc-pro swap in terraform
  ([#270](https://github.com/CalebSargeant/infra/pull/270),
  [`28b4c86`](https://github.com/CalebSargeant/infra/commit/28b4c86dba2295db45936aa7a933edca68e6cf4a))


## v1.34.0 (2026-05-24)

### Features

- **tunnel**: Split OCI MikroTik onto firefly-oci tunnel (off firefly)
  ([#269](https://github.com/CalebSargeant/infra/pull/269),
  [`2d61671`](https://github.com/CalebSargeant/infra/commit/2d61671ba003779932486333868f9ebbff64990b))


## v1.33.6 (2026-05-23)

### Bug Fixes

- **cloudflared**: Correct livenessProbe detection time in comment
  ([#268](https://github.com/CalebSargeant/infra/pull/268),
  [`3e8d28e`](https://github.com/CalebSargeant/infra/commit/3e8d28e994aedaf1fc3921c31db8a3e460f71a8e))

- **cloudflared**: Make UDP buffer init container best-effort
  ([#268](https://github.com/CalebSargeant/infra/pull/268),
  [`3e8d28e`](https://github.com/CalebSargeant/infra/commit/3e8d28e994aedaf1fc3921c31db8a3e460f71a8e))

- **cloudflared**: Make UDP buffer init container best-effort (Pi unblock)
  ([#268](https://github.com/CalebSargeant/infra/pull/268),
  [`3e8d28e`](https://github.com/CalebSargeant/infra/commit/3e8d28e994aedaf1fc3921c31db8a3e460f71a8e))

- **cloudflared**: Re-add set -e to init container script
  ([#268](https://github.com/CalebSargeant/infra/pull/268),
  [`3e8d28e`](https://github.com/CalebSargeant/infra/commit/3e8d28e994aedaf1fc3921c31db8a3e460f71a8e))

- **cloudflared**: Use HTTP liveness probe on /ready instead of TCP socket
  ([#268](https://github.com/CalebSargeant/infra/pull/268),
  [`3e8d28e`](https://github.com/CalebSargeant/infra/commit/3e8d28e994aedaf1fc3921c31db8a3e460f71a8e))


## v1.33.5 (2026-05-23)

### Bug Fixes

- **cloudflared**: Fail initContainer on partial sysctl write failure
  ([#267](https://github.com/CalebSargeant/infra/pull/267),
  [`7fed215`](https://github.com/CalebSargeant/infra/commit/7fed215677259f49f700e16ad464baaf727029e9))

- **cloudflared**: Harden initContainer securityContext
  ([#267](https://github.com/CalebSargeant/infra/pull/267),
  [`7fed215`](https://github.com/CalebSargeant/infra/commit/7fed215677259f49f700e16ad464baaf727029e9))

- **cloudflared**: Liveness probe + UDP buffer tuning to prevent silent hangs
  ([#267](https://github.com/CalebSargeant/infra/pull/267),
  [`7fed215`](https://github.com/CalebSargeant/infra/commit/7fed215677259f49f700e16ad464baaf727029e9))

- **cloudflared**: Use tcpSocket liveness probe to avoid restart loops on network outage
  ([#267](https://github.com/CalebSargeant/infra/pull/267),
  [`7fed215`](https://github.com/CalebSargeant/infra/commit/7fed215677259f49f700e16ad464baaf727029e9))

### Chores

- **mikrotik-minder-agent**: Bump image to 1.4.0
  ([#266](https://github.com/CalebSargeant/infra/pull/266),
  [`abfc6db`](https://github.com/CalebSargeant/infra/commit/abfc6db4e2b2bf607de21dbc94df6c4784fd9f88))


## v1.33.4 (2026-05-23)

### Bug Fixes

- **resources**: Right-size atlantis + mariadb to free ff-pi1 capacity
  ([#265](https://github.com/CalebSargeant/infra/pull/265),
  [`26f2b9d`](https://github.com/CalebSargeant/infra/commit/26f2b9d65cfaf55f4eae91187ce4682d3797c12e))


## v1.33.3 (2026-05-23)

### Bug Fixes

- **atlantis**: Update stale comment path for ClusterSecretStore reference
  ([#264](https://github.com/CalebSargeant/infra/pull/264),
  [`25571d4`](https://github.com/CalebSargeant/infra/commit/25571d43d6474a1928e1af58528de2d16576d6aa))

- **atlantis**: Update stale path in comment to current external-secrets stack
  ([#264](https://github.com/CalebSargeant/infra/pull/264),
  [`25571d4`](https://github.com/CalebSargeant/infra/commit/25571d43d6474a1928e1af58528de2d16576d6aa))

- **stack**: Correct legacy path in comment
  ([#264](https://github.com/CalebSargeant/infra/pull/264),
  [`25571d4`](https://github.com/CalebSargeant/infra/commit/25571d43d6474a1928e1af58528de2d16576d6aa))

### Chores

- **structure**: Migrate timemachine + headlamp to apps/ (Phase D)
  ([#263](https://github.com/CalebSargeant/infra/pull/263),
  [`dcc564b`](https://github.com/CalebSargeant/infra/commit/dcc564b16efead65be27465b4e4cab034ff8403b))

- **structure**: Phase E — relocate flux-system, delete legacy trees
  ([#264](https://github.com/CalebSargeant/infra/pull/264),
  [`25571d4`](https://github.com/CalebSargeant/infra/commit/25571d43d6474a1928e1af58528de2d16576d6aa))

### Documentation

- **external-secrets**: Fix cluster configuration path in SUMMARY.md
  ([#264](https://github.com/CalebSargeant/infra/pull/264),
  [`25571d4`](https://github.com/CalebSargeant/infra/commit/25571d43d6474a1928e1af58528de2d16576d6aa))

- **external-secrets**: Fix path to firefly kustomization.yaml
  ([#264](https://github.com/CalebSargeant/infra/pull/264),
  [`25571d4`](https://github.com/CalebSargeant/infra/commit/25571d43d6474a1928e1af58528de2d16576d6aa))

- **external-secrets**: Update OCI Vault setup guide paths to current layout
  ([#264](https://github.com/CalebSargeant/infra/pull/264),
  [`25571d4`](https://github.com/CalebSargeant/infra/commit/25571d43d6474a1928e1af58528de2d16576d6aa))

- **external-secrets**: Update SUMMARY.md paths to current layout
  ([#264](https://github.com/CalebSargeant/infra/pull/264),
  [`25571d4`](https://github.com/CalebSargeant/infra/commit/25571d43d6474a1928e1af58528de2d16576d6aa))

- **helm-charts**: Update example structure to match current layout
  ([#264](https://github.com/CalebSargeant/infra/pull/264),
  [`25571d4`](https://github.com/CalebSargeant/infra/commit/25571d43d6474a1928e1af58528de2d16576d6aa))

- **warp**: Update directory structure and commands to current paths
  ([#264](https://github.com/CalebSargeant/infra/pull/264),
  [`25571d4`](https://github.com/CalebSargeant/infra/commit/25571d43d6474a1928e1af58528de2d16576d6aa))


## v1.33.2 (2026-05-22)

### Bug Fixes

- **kustomization**: Correct comment about vpn-gateway removal
  ([#261](https://github.com/CalebSargeant/infra/pull/261),
  [`a2025bb`](https://github.com/CalebSargeant/infra/commit/a2025bb5e4a9fce6fd3b2ad60d3f73d1dcfabd72))

- **structure**: Drop vpn-gateway from infrastructure-services
  ([#261](https://github.com/CalebSargeant/infra/pull/261),
  [`a2025bb`](https://github.com/CalebSargeant/infra/commit/a2025bb5e4a9fce6fd3b2ad60d3f73d1dcfabd72))

### Chores

- **deps**: Bump docker/setup-buildx-action from 4.0.0 to 4.1.0
  ([#262](https://github.com/CalebSargeant/infra/pull/262),
  [`e212392`](https://github.com/CalebSargeant/infra/commit/e212392911c4276adc6472f7fe38c8edc107fd3d))

- **structure**: Delete dead legacy dirs for the 30 migrated apps
  ([#259](https://github.com/CalebSargeant/infra/pull/259),
  [`3710753`](https://github.com/CalebSargeant/infra/commit/3710753af0fb5e44f202c75a7b1534225be926ea))

- **structure**: Delete dead legacy dirs for the 30 migrated apps
  ([#258](https://github.com/CalebSargeant/infra/pull/258),
  [`58c04e4`](https://github.com/CalebSargeant/infra/commit/58c04e4cfae4e2e9ecda4a87399b7dab4ff940ac))

- **structure**: Migrate core+database to infrastructure/ tier (Phase C)
  ([#260](https://github.com/CalebSargeant/infra/pull/260),
  [`7b41adc`](https://github.com/CalebSargeant/infra/commit/7b41adc7fb6f286ab3e4abf8cab6dda871a728af))

- **structure**: Phase B — relocate shared deps, archive orphans
  ([#259](https://github.com/CalebSargeant/infra/pull/259),
  [`3710753`](https://github.com/CalebSargeant/infra/commit/3710753af0fb5e44f202c75a7b1534225be926ea))

- **structure**: Relocate shared deps, archive orphan bases
  ([#259](https://github.com/CalebSargeant/infra/pull/259),
  [`3710753`](https://github.com/CalebSargeant/infra/commit/3710753af0fb5e44f202c75a7b1534225be926ea))


## v1.33.1 (2026-05-22)

### Bug Fixes

- **firefly**: Point comment-commander Flux auth at the MagmaMoose App installation
  ([#257](https://github.com/CalebSargeant/infra/pull/257),
  [`a9a6693`](https://github.com/CalebSargeant/infra/commit/a9a6693a2c32ac0cd7a2eeab10bcdf9257843ca9))


## v1.33.0 (2026-05-22)

### Features

- **mikrotik-minder**: Push agent /export history to a private git remote
  ([#256](https://github.com/CalebSargeant/infra/pull/256),
  [`fbe5699`](https://github.com/CalebSargeant/infra/commit/fbe5699e44c2f2e5573d3c7b77a542428530b597))


## v1.32.0 (2026-05-22)

### Bug Fixes

- **cloudflare**: Add trailing slash to Zoey Slack bypass domain
  ([#255](https://github.com/CalebSargeant/infra/pull/255),
  [`b4b8122`](https://github.com/CalebSargeant/infra/commit/b4b8122275a60c71c8d30035398cb6641d1eff85))

- **ztna**: Gate Mikrotik Minder Pro's Pages deployment URLs
  ([#254](https://github.com/CalebSargeant/infra/pull/254),
  [`ee309ff`](https://github.com/CalebSargeant/infra/commit/ee309ff27d7669bee13daaf183674d9897ef27d6))

### Features

- **ztna**: Broaden Zoey's Slack Access bypass to /api/v1/slack
  ([#255](https://github.com/CalebSargeant/infra/pull/255),
  [`b4b8122`](https://github.com/CalebSargeant/infra/commit/b4b8122275a60c71c8d30035398cb6641d1eff85))


## v1.31.1 (2026-05-22)

### Bug Fixes

- **atlantis**: Repoint Terraform GCP auth at dedicated atlantis@ SA
  ([#253](https://github.com/CalebSargeant/infra/pull/253),
  [`be04d30`](https://github.com/CalebSargeant/infra/commit/be04d3008be6e370019871a29db7ced0e6544196))

### Documentation

- **atlantis**: Clarify GCP SA key scope and legacy state bucket
  ([#253](https://github.com/CalebSargeant/infra/pull/253),
  [`be04d30`](https://github.com/CalebSargeant/infra/commit/be04d3008be6e370019871a29db7ced0e6544196))


## v1.31.0 (2026-05-22)

### Features

- Register OpenViking with Flux on firefly ([#252](https://github.com/CalebSargeant/infra/pull/252),
  [`f623940`](https://github.com/CalebSargeant/infra/commit/f623940b688313364068c83f099a555440a736a9))


## v1.30.1 (2026-05-22)

### Bug Fixes

- **ztna**: Drop device-posture require from Mikrotik Minder Pro Access policy
  ([#251](https://github.com/CalebSargeant/infra/pull/251),
  [`50cf0f4`](https://github.com/CalebSargeant/infra/commit/50cf0f45feaffb992625edc3f0459ca39fdde25d))


## v1.30.0 (2026-05-22)

### Bug Fixes

- **cloudflare**: Scope Slack webhook bypass to /interaction path
  ([#250](https://github.com/CalebSargeant/infra/pull/250),
  [`8b7abf5`](https://github.com/CalebSargeant/infra/commit/8b7abf510c91f9cef32812f18a36ca1797a34fe9))

- **cloudflare**: Tighten zoey ingress path regex to avoid false matches
  ([#250](https://github.com/CalebSargeant/infra/pull/250),
  [`8b7abf5`](https://github.com/CalebSargeant/infra/commit/8b7abf510c91f9cef32812f18a36ca1797a34fe9))

### Features

- **ztna**: Expose Zoey via firefly tunnel + gate the UI with Access
  ([#250](https://github.com/CalebSargeant/infra/pull/250),
  [`8b7abf5`](https://github.com/CalebSargeant/infra/commit/8b7abf510c91f9cef32812f18a36ca1797a34fe9))

- **ztna**: Expose Zoey via firefly tunnel + gate UI with Access
  ([#250](https://github.com/CalebSargeant/infra/pull/250),
  [`8b7abf5`](https://github.com/CalebSargeant/infra/commit/8b7abf510c91f9cef32812f18a36ca1797a34fe9))


## v1.29.1 (2026-05-22)

### Bug Fixes

- **ztna**: Drop device-posture require from comment-commander-pro Access policy
  ([#249](https://github.com/CalebSargeant/infra/pull/249),
  [`e99fb0f`](https://github.com/CalebSargeant/infra/commit/e99fb0fcd09b1e8571ee8b15c7947013112eda21))


## v1.29.0 (2026-05-22)

### Features

- **ztna**: Gate Mikrotik Minder Pro behind Access
  ([#248](https://github.com/CalebSargeant/infra/pull/248),
  [`ea21e22`](https://github.com/CalebSargeant/infra/commit/ea21e222e0c0f444f14d0ef5eca92cb01a81a627))


## v1.28.0 (2026-05-22)

### Features

- **firefly**: Make comment-commander-pro reachable + resume source
  ([#247](https://github.com/CalebSargeant/infra/pull/247),
  [`31c8703`](https://github.com/CalebSargeant/infra/commit/31c8703105608eb13282c1379d9ca04f62eca771))


## v1.27.0 (2026-05-22)

### Bug Fixes

- **flux**: Suspend comment-commander-pro GitRepository until GitHub App access is granted
  ([#246](https://github.com/CalebSargeant/infra/pull/246),
  [`10ece15`](https://github.com/CalebSargeant/infra/commit/10ece1579761be38b61d99a09953b4c279c0b0aa))

### Features

- **firefly**: Deploy comment-commander-pro
  ([#246](https://github.com/CalebSargeant/infra/pull/246),
  [`10ece15`](https://github.com/CalebSargeant/infra/commit/10ece1579761be38b61d99a09953b4c279c0b0aa))


## v1.26.2 (2026-05-21)

### Bug Fixes

- **mikrotik-minder**: Align comment with actual tag format
  ([#245](https://github.com/CalebSargeant/infra/pull/245),
  [`8105471`](https://github.com/CalebSargeant/infra/commit/81054710cb92fe2b5a30fbbda12479e92e18c7e9))

- **mikrotik-minder**: Pin image.tag to release-runner's actual version
  ([#245](https://github.com/CalebSargeant/infra/pull/245),
  [`8105471`](https://github.com/CalebSargeant/infra/commit/81054710cb92fe2b5a30fbbda12479e92e18c7e9))


## v1.26.1 (2026-05-21)

### Bug Fixes

- **mikrotik-minder**: Narrow Helm chart version constraint to <0.2.0
  ([#244](https://github.com/CalebSargeant/infra/pull/244),
  [`efdd40b`](https://github.com/CalebSargeant/infra/commit/efdd40b9e031d6cd5f8ab2579a6331722efd1848))

- **mikrotik-minder**: Pin chart to >=0.1.1 <1.0.0
  ([#244](https://github.com/CalebSargeant/infra/pull/244),
  [`efdd40b`](https://github.com/CalebSargeant/infra/commit/efdd40b9e031d6cd5f8ab2579a6331722efd1848))


## v1.26.0 (2026-05-21)

### Features

- Add mikrotik-minder agent to firefly cluster
  ([#242](https://github.com/CalebSargeant/infra/pull/242),
  [`cb5b790`](https://github.com/CalebSargeant/infra/commit/cb5b7901141ede64c121ce64115fac47c8558731))

- Deploy mikrotik-minder agent on firefly ([#242](https://github.com/CalebSargeant/infra/pull/242),
  [`cb5b790`](https://github.com/CalebSargeant/infra/commit/cb5b7901141ede64c121ce64115fac47c8558731))

- Register zoey with Flux on firefly ([#242](https://github.com/CalebSargeant/infra/pull/242),
  [`cb5b790`](https://github.com/CalebSargeant/infra/commit/cb5b7901141ede64c121ce64115fac47c8558731))


## v1.25.2 (2026-05-21)

### Bug Fixes

- **1password-connect**: Repair Connect bootstrap + grant Tech vault access
  ([#241](https://github.com/CalebSargeant/infra/pull/241),
  [`4b2bfb7`](https://github.com/CalebSargeant/infra/commit/4b2bfb7163562713ea315523b053fa9c1ee5db75))


## v1.25.1 (2026-05-21)

### Bug Fixes

- **external-dns-cloudflare**: Drop self-conflicting annotation filter, add magmamoose.com
  ([#243](https://github.com/CalebSargeant/infra/pull/243),
  [`2f1276e`](https://github.com/CalebSargeant/infra/commit/2f1276eab47ce67300671fe53a8c2805dcf1eac4))


## v1.25.0 (2026-05-21)

### Bug Fixes

- **cloudflare**: Manage comment-commander.magmamoose.com CNAME explicitly
  ([#240](https://github.com/CalebSargeant/infra/pull/240),
  [`62d1d0e`](https://github.com/CalebSargeant/infra/commit/62d1d0eda8f55d9f8d72c1539185b22318fe0b50))

### Documentation

- **oci-vrrp**: Pivot to route-table-update after smoke test
  ([#233](https://github.com/CalebSargeant/infra/pull/233),
  [`32ab3a7`](https://github.com/CalebSargeant/infra/commit/32ab3a7d57cb31f85d1363a3b0b3fada46c66004))

### Features

- Register zoey with Flux on firefly ([#239](https://github.com/CalebSargeant/infra/pull/239),
  [`346b3e1`](https://github.com/CalebSargeant/infra/commit/346b3e17da2e5194ed0513a55896d72179396762))

- **cloudflare**: Route comment-commander.magmamoose.com via firefly tunnel
  ([#240](https://github.com/CalebSargeant/infra/pull/240),
  [`62d1d0e`](https://github.com/CalebSargeant/infra/commit/62d1d0eda8f55d9f8d72c1539185b22318fe0b50))


## v1.24.0 (2026-05-20)

### Features

- Add comment-commander GitRepository and Kustomization configurations
  ([#238](https://github.com/CalebSargeant/infra/pull/238),
  [`76f688c`](https://github.com/CalebSargeant/infra/commit/76f688ca1c229f27a9b6a47856bd12a5875ad9ad))


## v1.23.4 (2026-05-20)

### Bug Fixes

- **atlantis**: Mount GCP SA key so terragrunt can read GCS state
  ([#237](https://github.com/CalebSargeant/infra/pull/237),
  [`413409d`](https://github.com/CalebSargeant/infra/commit/413409d997d3eb4e9257a69dbc0e71784711ae17))

### Documentation

- **atlantis**: Reuse existing terraform SA, drop new-SA runbook
  ([#237](https://github.com/CalebSargeant/infra/pull/237),
  [`413409d`](https://github.com/CalebSargeant/infra/commit/413409d997d3eb4e9257a69dbc0e71784711ae17))

- **atlantis**: Strip base64 wrap for portability (#237 review)
  ([#237](https://github.com/CalebSargeant/infra/pull/237),
  [`413409d`](https://github.com/CalebSargeant/infra/commit/413409d997d3eb4e9257a69dbc0e71784711ae17))


## v1.23.3 (2026-05-20)

### Bug Fixes

- **atlantis**: Mount OCI CLI config + key so terragrunt run_cmd auths
  ([#236](https://github.com/CalebSargeant/infra/pull/236),
  [`d434054`](https://github.com/CalebSargeant/infra/commit/d434054d25151938b7e7580722a1a893d042ddfa))


## v1.23.2 (2026-05-20)

### Bug Fixes

- **atlantis**: Bake oci-cli + terragrunt into custom image
  ([#235](https://github.com/CalebSargeant/infra/pull/235),
  [`567659a`](https://github.com/CalebSargeant/infra/commit/567659ac0d54b270a08d5212a86dd620fa21a82b))


## v1.23.1 (2026-05-20)

### Bug Fixes

- **atlantis**: Install terragrunt at pod start + restore Recreate strategy
  ([#232](https://github.com/CalebSargeant/infra/pull/232),
  [`553d9f8`](https://github.com/CalebSargeant/infra/commit/553d9f89c0a41c0f4d5a8ae605f236d9e858c7ca))

- **atlantis**: Verify terragrunt SHA256 before exec (Copilot #232)
  ([#232](https://github.com/CalebSargeant/infra/pull/232),
  [`553d9f8`](https://github.com/CalebSargeant/infra/commit/553d9f89c0a41c0f4d5a8ae605f236d9e858c7ca))


## v1.23.0 (2026-05-19)

### Bug Fixes

- Add `--formatter=json` flag to KRR cronjob configuration
  ([`a84e597`](https://github.com/CalebSargeant/infra/commit/a84e59767a4044ed92f22132d21d0d266a0a7983))

- Add missing headlamp TLS certificate ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Add missing headlamp TLS certificate ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Add missing headlamp TLS certificate ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Add missing headlamp TLS certificate ([#178](https://github.com/CalebSargeant/infra/pull/178),
  [`5164a87`](https://github.com/CalebSargeant/infra/commit/5164a87bd905ac62e3aab605abace521844df496))

- Add missing headlamp TLS certificate ([#177](https://github.com/CalebSargeant/infra/pull/177),
  [`1267122`](https://github.com/CalebSargeant/infra/commit/1267122ad32d9803197987806c33d1ece96eae0d))

- Add missing headlamp TLS certificate ([#176](https://github.com/CalebSargeant/infra/pull/176),
  [`0d3b841`](https://github.com/CalebSargeant/infra/commit/0d3b841adec408ef863f1352f12a03273bf89928))

- Add missing headlamp TLS certificate ([#175](https://github.com/CalebSargeant/infra/pull/175),
  [`5400b47`](https://github.com/CalebSargeant/infra/commit/5400b4792244f25c9a6d52f0a8a326141b05344a))

- Add missing headlamp TLS certificate ([#174](https://github.com/CalebSargeant/infra/pull/174),
  [`3caba76`](https://github.com/CalebSargeant/infra/commit/3caba7622bf98a342d5ef072744c0820b7863a8c))

- Add missing headlamp TLS certificate ([#173](https://github.com/CalebSargeant/infra/pull/173),
  [`5af28aa`](https://github.com/CalebSargeant/infra/commit/5af28aa0714aa96f2ce2fe193b7705426641ddb6))

- Add missing headlamp TLS certificate ([#172](https://github.com/CalebSargeant/infra/pull/172),
  [`acf9a05`](https://github.com/CalebSargeant/infra/commit/acf9a05a36c7001f6948057ccac128148f56e95f))

- Add missing headlamp TLS certificate ([#171](https://github.com/CalebSargeant/infra/pull/171),
  [`fef411a`](https://github.com/CalebSargeant/infra/commit/fef411a9db785d112a1790718a0d7eee81c37818))

- Add missing headlamp TLS certificate ([#170](https://github.com/CalebSargeant/infra/pull/170),
  [`e6e815a`](https://github.com/CalebSargeant/infra/commit/e6e815a5005e365cf49455f24aa8087993b63ee8))

- Add missing headlamp TLS certificate ([#169](https://github.com/CalebSargeant/infra/pull/169),
  [`b80e075`](https://github.com/CalebSargeant/infra/commit/b80e07513c4782c7baa94836d3e5d872cd5b7e7b))

- Address Copilot comments on #202 ([#202](https://github.com/CalebSargeant/infra/pull/202),
  [`686ff27`](https://github.com/CalebSargeant/infra/commit/686ff2742b7115fe6bc57ca7535cd0b82a907e3f))

- Build plugins from source for Headlamp in Firefly cluster
  ([`31f5f61`](https://github.com/CalebSargeant/infra/commit/31f5f61bea730998e3e3f74f304fe8e0bc6b2214))

- Consolidate Slack token and channel options into single `--slackoutput` flag in KRR cronjob
  configuration
  ([`2af959b`](https://github.com/CalebSargeant/infra/commit/2af959b18c5a77bb9e51202ec5dfd1671cf6dc96))

- Copilot review round 2 + mark terraform-managed resources
  ([#199](https://github.com/CalebSargeant/infra/pull/199),
  [`d893df8`](https://github.com/CalebSargeant/infra/commit/d893df8441931608b9365d77d8a1650edb93d225))

- Copilot review round 3 — provider anti-pattern, codify 8728 drift, doc follow-ups
  ([#199](https://github.com/CalebSargeant/infra/pull/199),
  [`d893df8`](https://github.com/CalebSargeant/infra/commit/d893df8441931608b9365d77d8a1650edb93d225))

- Increase sync intervals from 1m to 10m for GitRepos, HelmReleases, and Kustomizations
  ([`1652252`](https://github.com/CalebSargeant/infra/commit/1652252584820b47b703bc549b1886d0b1b772b8))

- Regenerate encrypted secrets for Cloudflare API with updated SOPS version
  ([`e58324d`](https://github.com/CalebSargeant/infra/commit/e58324dc4f6bff030773e2bbe49db8a60e961871))

- Remove unused `--formatter=table` flag from KRR cronjob configuration
  ([`65dde41`](https://github.com/CalebSargeant/infra/commit/65dde41335c85093e1650db0ce7bb7c6d9731b34))

- Same conditional-hash + AMI fixes on #210
  ([#210](https://github.com/CalebSargeant/infra/pull/210),
  [`ff0895c`](https://github.com/CalebSargeant/infra/commit/ff0895c08f0a1a9edf033dbc15ee9772584dfd9a))

- Update Eurofiber web tunnel configuration with new paths and metadata
  ([`8b46d17`](https://github.com/CalebSargeant/infra/commit/8b46d1740ce77ed03086045edc4c9d14e2a2ca8f))

- Update KRR cronjob to use `--formatter=pprint` instead of `--formatter=json`
  ([`ec65792`](https://github.com/CalebSargeant/infra/commit/ec657925c968539b8aaa0a9f9d9f6041fe68f7ef))

- Update lastmodified timestamps and mac values in Eurofiber web tunnel configuration
  ([`9c8eff4`](https://github.com/CalebSargeant/infra/commit/9c8eff404904c47887a6fed367e1aecc436abeaf))

- Update plex container image to use latest version
  ([`e233f3a`](https://github.com/CalebSargeant/infra/commit/e233f3ac22753addf585c71ded37b75a95e5daaa))

- Update plex container image to use lscr.io repository
  ([`ced3793`](https://github.com/CalebSargeant/infra/commit/ced3793cf4666a92472e46c48f7f0659789d7589))

- Update storage flags and switch KRR output to CSV format
  ([`3a38304`](https://github.com/CalebSargeant/infra/commit/3a383045c1fc998426255694134bbd79c092783b))

- **atlantis**: Add ATLANTIS_WRITE_GIT_CREDS for GitHub App cloning
  ([#212](https://github.com/CalebSargeant/infra/pull/212),
  [`33241aa`](https://github.com/CalebSargeant/infra/commit/33241aa4755b46c48751936ccc9b9c97b5f472ae))

- **atlantis**: Address Copilot review on #201
  ([#212](https://github.com/CalebSargeant/infra/pull/212),
  [`33241aa`](https://github.com/CalebSargeant/infra/commit/33241aa4755b46c48751936ccc9b9c97b5f472ae))

- **atlantis**: Address Copilot review on #201
  ([#211](https://github.com/CalebSargeant/infra/pull/211),
  [`d7b2e3f`](https://github.com/CalebSargeant/infra/commit/d7b2e3fd1ec6206893c4ef23c574a207c18c51fb))

- **atlantis**: Address Copilot review on #201
  ([#201](https://github.com/CalebSargeant/infra/pull/201),
  [`02f89a7`](https://github.com/CalebSargeant/infra/commit/02f89a77c72b837204e889d853af12796e0bcd9f))

- **atlantis**: Address Copilot review on #211 — idempotent init + accurate guide
  ([#212](https://github.com/CalebSargeant/infra/pull/212),
  [`33241aa`](https://github.com/CalebSargeant/infra/commit/33241aa4755b46c48751936ccc9b9c97b5f472ae))

- **atlantis**: Address Copilot review on #211 — idempotent init + accurate guide
  ([#211](https://github.com/CalebSargeant/infra/pull/211),
  [`d7b2e3f`](https://github.com/CalebSargeant/infra/commit/d7b2e3fd1ec6206893c4ef23c574a207c18c51fb))

- **atlantis**: Allow apply_requirements override in repo atlantis.yaml
  ([#225](https://github.com/CalebSargeant/infra/pull/225),
  [`a679cd1`](https://github.com/CalebSargeant/infra/commit/a679cd186d5adccd3d204b168fab0af45a290caa))

- **atlantis**: Bump image v0.31.0 → v0.43.0 (PGP key expired in old version)
  ([#228](https://github.com/CalebSargeant/infra/pull/228),
  [`f683478`](https://github.com/CalebSargeant/infra/commit/f6834782c0a3fa33aa64efb1371c4f99fa7c3e43))

- **atlantis**: Change Ingress class from nginx to traefik
  ([#216](https://github.com/CalebSargeant/infra/pull/216),
  [`090f4dc`](https://github.com/CalebSargeant/infra/commit/090f4dc9f4baadaf51b2f0e50608ba0202188d75))

- **atlantis**: Change Ingress class from nginx to traefik
  ([#215](https://github.com/CalebSargeant/infra/pull/215),
  [`2ec3585`](https://github.com/CalebSargeant/infra/commit/2ec358561ccb43fccaffc92d925b5f6cbe9cd7d1))

- **atlantis**: Chown existing PVC to atlantis user via init container
  ([#212](https://github.com/CalebSargeant/infra/pull/212),
  [`33241aa`](https://github.com/CalebSargeant/infra/commit/33241aa4755b46c48751936ccc9b9c97b5f472ae))

- **atlantis**: Chown existing PVC to atlantis user via init container
  ([#211](https://github.com/CalebSargeant/infra/pull/211),
  [`d7b2e3f`](https://github.com/CalebSargeant/infra/commit/d7b2e3fd1ec6206893c4ef23c574a207c18c51fb))

- **atlantis**: Make autoplan when_modified patterns recursive
  ([#226](https://github.com/CalebSargeant/infra/pull/226),
  [`b73e97b`](https://github.com/CalebSargeant/infra/commit/b73e97b6dc09e1c0fd7c7cdb196f229ca8f5e460))

- **atlantis**: One project per leaf terragrunt module
  ([#231](https://github.com/CalebSargeant/infra/pull/231),
  [`4892c0e`](https://github.com/CalebSargeant/infra/commit/4892c0e2aa2c6be04926c8d0c7233fd45935062a))

- **atlantis**: One project per leaf terragrunt module (was: provider-level dirs with no TF config)
  ([#231](https://github.com/CalebSargeant/infra/pull/231),
  [`4892c0e`](https://github.com/CalebSargeant/infra/commit/4892c0e2aa2c6be04926c8d0c7233fd45935062a))

- **cloudflared**: Migrate tunnel token from SOPS to OCI Vault ExternalSecret
  ([#212](https://github.com/CalebSargeant/infra/pull/212),
  [`33241aa`](https://github.com/CalebSargeant/infra/commit/33241aa4755b46c48751936ccc9b9c97b5f472ae))

- **cloudflared**: Migrate tunnel token from SOPS to OCI Vault ExternalSecret
  ([#211](https://github.com/CalebSargeant/infra/pull/211),
  [`d7b2e3f`](https://github.com/CalebSargeant/infra/commit/d7b2e3fd1ec6206893c4ef23c574a207c18c51fb))

- **cloudflared**: Migrate tunnel token from SOPS to OCI Vault ExternalSecret
  ([#201](https://github.com/CalebSargeant/infra/pull/201),
  [`02f89a7`](https://github.com/CalebSargeant/infra/commit/02f89a77c72b837204e889d853af12796e0bcd9f))

- **cloudflared**: Migrate tunnel token from SOPS to OCI Vault ExternalSecret
  ([#200](https://github.com/CalebSargeant/infra/pull/200),
  [`8e2489e`](https://github.com/CalebSargeant/infra/commit/8e2489ef55df1f257135055c4cc7ebada16db1e2))

- **docs**: Address Copilot review on #192 ([#192](https://github.com/CalebSargeant/infra/pull/192),
  [`4276b2e`](https://github.com/CalebSargeant/infra/commit/4276b2e33759f5f8dae4db2d3426fea6aa21cd01))

- **docs**: Address second Copilot pass on #192
  ([#192](https://github.com/CalebSargeant/infra/pull/192),
  [`4276b2e`](https://github.com/CalebSargeant/infra/commit/4276b2e33759f5f8dae4db2d3426fea6aa21cd01))

- **docs**: Address third Copilot pass on #192
  ([#192](https://github.com/CalebSargeant/infra/pull/192),
  [`4276b2e`](https://github.com/CalebSargeant/infra/commit/4276b2e33759f5f8dae4db2d3426fea6aa21cd01))

- **docs**: Update AGENTS.md kubernetes layout example
  ([#192](https://github.com/CalebSargeant/infra/pull/192),
  [`4276b2e`](https://github.com/CalebSargeant/infra/commit/4276b2e33759f5f8dae4db2d3426fea6aa21cd01))

- **mikrotik**: Restore cloudflared HA on r1 + suppress perpetual `running` drift
  ([#202](https://github.com/CalebSargeant/infra/pull/202),
  [`686ff27`](https://github.com/CalebSargeant/infra/commit/686ff2742b7115fe6bc57ca7535cd0b82a907e3f))

- **mikrotik**: Restore cloudflared HA on r1 + suppress perpetual running drift
  ([#202](https://github.com/CalebSargeant/infra/pull/202),
  [`686ff27`](https://github.com/CalebSargeant/infra/commit/686ff2742b7115fe6bc57ca7535cd0b82a907e3f))

- **observability**: Unstick loki + kube-prometheus-stack
  ([#198](https://github.com/CalebSargeant/infra/pull/198),
  [`3c448cd`](https://github.com/CalebSargeant/infra/commit/3c448cd5a3870964e06c40de03029d3865753a20))

- **oci**: Address Copilot review comments on PR #199
  ([#199](https://github.com/CalebSargeant/infra/pull/199),
  [`d893df8`](https://github.com/CalebSargeant/infra/commit/d893df8441931608b9365d77d8a1650edb93d225))

- **oci**: Cloud-init pip flag handling works on Ubuntu 22.04 too
  ([#210](https://github.com/CalebSargeant/infra/pull/210),
  [`ff0895c`](https://github.com/CalebSargeant/infra/commit/ff0895c08f0a1a9edf033dbc15ee9772584dfd9a))

- **oci**: Tighten k3s vault-fetch module per #210 review
  ([#210](https://github.com/CalebSargeant/infra/pull/210),
  [`ff0895c`](https://github.com/CalebSargeant/infra/commit/ff0895c08f0a1a9edf033dbc15ee9772584dfd9a))

- **oci-db**: Correct MySQL password guidance + match repo's get_env pattern
  ([#217](https://github.com/CalebSargeant/infra/pull/217),
  [`d75ff2c`](https://github.com/CalebSargeant/infra/commit/d75ff2ce582c4d60e49cb861b76f0e5911ab3412))

- **oci-edge**: Filter on is_primary instead of index ordering (Copilot #227)
  ([#227](https://github.com/CalebSargeant/infra/pull/227),
  [`b6fd0f1`](https://github.com/CalebSargeant/infra/commit/b6fd0f1f5680769cc44e308413b32e88c310ad6a))

- **structure**: Drop ./base from apps/excalidraw/kustomization.yaml
  ([#193](https://github.com/CalebSargeant/infra/pull/193),
  [`9796256`](https://github.com/CalebSargeant/infra/commit/9796256edd1c94eccefdbc5a56ec02b52fe87634))

- **structure**: Post-migration fixes for PR #196 (krr, kubescape, gitignore)
  ([#197](https://github.com/CalebSargeant/infra/pull/197),
  [`40a8035`](https://github.com/CalebSargeant/infra/commit/40a8035e8d75ce143fc4b12a4b82597753c7d1c8))

- **ztna**: Family/friends email lists into OCI Vault + imports.tf state-recovery doc + memo snippet
  ([#214](https://github.com/CalebSargeant/infra/pull/214),
  [`6c89022`](https://github.com/CalebSargeant/infra/commit/6c89022503ae24637e6122ee64f0b444e8bef443))

- **ztna**: Radarr policies use access groups + add posture require on caleb
  ([#209](https://github.com/CalebSargeant/infra/pull/209),
  [`ebdcdd0`](https://github.com/CalebSargeant/infra/commit/ebdcdd0c461fc238e6ff4dc0f11c85e24fb4c191))

- **ztna**: Update gateway.tf header comment after L4 rule deletion (Copilot #229)
  ([#229](https://github.com/CalebSargeant/infra/pull/229),
  [`189f11d`](https://github.com/CalebSargeant/infra/commit/189f11dd1ac74a4c1895c65400e1a786e44985ae))

- **ztna,oci**: Yandex DNS fix + service-token docs + server-hash refinement
  ([#213](https://github.com/CalebSargeant/infra/pull/213),
  [`34c7897`](https://github.com/CalebSargeant/infra/commit/34c7897a1d1e06886405af152481a4ed95bacb72))

### Chores

- Add Kustomization for deskbird-booking ([#190](https://github.com/CalebSargeant/infra/pull/190),
  [`5c145ff`](https://github.com/CalebSargeant/infra/commit/5c145fff2b43a92d7f0bbbc122177beee4843734))

- Disable deskbird-booking resources in kustomization files
  ([`b978fa1`](https://github.com/CalebSargeant/infra/commit/b978fa14ed85defc92b4ffd1d1c984fecda168a5))

- Reorganise terraform modules into per-provider trees
  ([#220](https://github.com/CalebSargeant/infra/pull/220),
  [`ad4edf4`](https://github.com/CalebSargeant/infra/commit/ad4edf4748bc8dbdf4e91381f28b59781b6f7b6f))

- Tidy repo, fix misc Kustomization, document restructure plan
  ([#192](https://github.com/CalebSargeant/infra/pull/192),
  [`4276b2e`](https://github.com/CalebSargeant/infra/commit/4276b2e33759f5f8dae4db2d3426fea6aa21cd01))

- Uncomment deskbird-booking.yaml in kustomization.yaml
  ([#189](https://github.com/CalebSargeant/infra/pull/189),
  [`d99e1d7`](https://github.com/CalebSargeant/infra/commit/d99e1d7545c98bdff88e1d2ab39c18214291de56))

- Update encrypted configuration in headlamp-kubeconfigs.enc.yaml
  ([`a603dd4`](https://github.com/CalebSargeant/infra/commit/a603dd4e0eaea54e3bc8df546be165bac14d8a37))

- **cloudflare/zero-trust**: Align resources with current dashboard state
  ([#199](https://github.com/CalebSargeant/infra/pull/199),
  [`d893df8`](https://github.com/CalebSargeant/infra/commit/d893df8441931608b9365d77d8a1650edb93d225))

- **deps**: Bump actions/checkout from 4 to 6
  ([#222](https://github.com/CalebSargeant/infra/pull/222),
  [`ed95c37`](https://github.com/CalebSargeant/infra/commit/ed95c37d47d9a1dd48f49b0ddf8207608a488d37))

- **deps**: Bump actions/checkout from 5 to 6
  ([#154](https://github.com/CalebSargeant/infra/pull/154),
  [`cc5e2c5`](https://github.com/CalebSargeant/infra/commit/cc5e2c5421d2c63fca4a46314e1ae3e3a28b3162))

- **deps**: Bump actions/deploy-pages from 4 to 5
  ([#188](https://github.com/CalebSargeant/infra/pull/188),
  [`62f93ed`](https://github.com/CalebSargeant/infra/commit/62f93ed7d424665f73b75588491976e21f6273f2))

- **deps**: Bump actions/upload-pages-artifact from 4 to 5
  ([#223](https://github.com/CalebSargeant/infra/pull/223),
  [`103f8ab`](https://github.com/CalebSargeant/infra/commit/103f8abb2111881e02324452c4dbf9181fac0574))

- **deps**: Bump CalebSargeant/reusable-workflows/.github/workflows/semantic-release.yaml
  ([#224](https://github.com/CalebSargeant/infra/pull/224),
  [`71384cb`](https://github.com/CalebSargeant/infra/commit/71384cb510527a39dbe5cb10d8a53a5f51fe0866))

- **deps**: Bump CalebSargeant/reusable-workflows/.github/workflows/semantic-release.yaml
  ([#183](https://github.com/CalebSargeant/infra/pull/183),
  [`0824e48`](https://github.com/CalebSargeant/infra/commit/0824e488a23faf2d89e9fdf6e10e974a93b293fe))

- **deps**: Bump CalebSargeant/reusable-workflows/.github/workflows/semantic-release.yaml
  ([#164](https://github.com/CalebSargeant/infra/pull/164),
  [`0655e0e`](https://github.com/CalebSargeant/infra/commit/0655e0e240baa09e02f7074efce4fa993f2c6001))

- **deps**: Bump CalebSargeant/reusable-workflows/.github/workflows/semantic-release.yaml
  ([#155](https://github.com/CalebSargeant/infra/pull/155),
  [`dca0b6b`](https://github.com/CalebSargeant/infra/commit/dca0b6b8202c597999f8c3fcd5ce246b6b5ee98b))

- **deps**: Bump docker/setup-buildx-action from 3.11.1 to 3.12.0
  ([#153](https://github.com/CalebSargeant/infra/pull/153),
  [`399d788`](https://github.com/CalebSargeant/infra/commit/399d788215fbe7e467b3abcd67338bd56f4ac5a1))

- **deps**: Bump docker/setup-buildx-action from 3.12.0 to 4.0.0
  ([#185](https://github.com/CalebSargeant/infra/pull/185),
  [`585ba94`](https://github.com/CalebSargeant/infra/commit/585ba9418a27984c7fdb91ee90a009e113fb426b))

- **deps**: Bump docker/setup-qemu-action from 3.6.0 to 3.7.0
  ([#152](https://github.com/CalebSargeant/infra/pull/152),
  [`6a393bf`](https://github.com/CalebSargeant/infra/commit/6a393bfbf85b7709de9b6487d597fd60261877ac))

- **deps**: Bump docker/setup-qemu-action from 3.7.0 to 4.0.0
  ([#184](https://github.com/CalebSargeant/infra/pull/184),
  [`43591eb`](https://github.com/CalebSargeant/infra/commit/43591ebcb94c7d494d265e099614cab6057a9805))

- **deps**: Bump dorny/paths-filter from 3.0.2 to 4.0.1
  ([#187](https://github.com/CalebSargeant/infra/pull/187),
  [`41c02e1`](https://github.com/CalebSargeant/infra/commit/41c02e13784bab32b79a0a5028135db0ddc9077e))

- **security**: Move operator WAN CIDR out of the public repo
  ([#209](https://github.com/CalebSargeant/infra/pull/209),
  [`ebdcdd0`](https://github.com/CalebSargeant/infra/commit/ebdcdd0c461fc238e6ff4dc0f11c85e24fb4c191))

- **security**: Move operator WAN CIDR out of the public repo
  ([#205](https://github.com/CalebSargeant/infra/pull/205),
  [`44ebd7a`](https://github.com/CalebSargeant/infra/commit/44ebd7a2f7c5f211348e70d86cddfb7c87d4efc8))

- **security**: Vault recon-grade IPs/OCIDs + fail-closed MySQL password
  ([#217](https://github.com/CalebSargeant/infra/pull/217),
  [`d75ff2c`](https://github.com/CalebSargeant/infra/commit/d75ff2ce582c4d60e49cb861b76f0e5911ab3412))

### Continuous Integration

- Add Terrateam workflow ([#199](https://github.com/CalebSargeant/infra/pull/199),
  [`d893df8`](https://github.com/CalebSargeant/infra/commit/d893df8441931608b9365d77d8a1650edb93d225))

- Add Terrateam workflow ([#191](https://github.com/CalebSargeant/infra/pull/191),
  [`f48340d`](https://github.com/CalebSargeant/infra/commit/f48340d185ba09c8976eeec98dba1db840b8c979))

- Switch releases to release runner ([#234](https://github.com/CalebSargeant/infra/pull/234),
  [`ffca145`](https://github.com/CalebSargeant/infra/commit/ffca1458d45055ab0d469425d8e5ec8094ae4e03))

### Documentation

- **atlantis**: Address Copilot review on #211 — correct paths & recovery
  ([#212](https://github.com/CalebSargeant/infra/pull/212),
  [`33241aa`](https://github.com/CalebSargeant/infra/commit/33241aa4755b46c48751936ccc9b9c97b5f472ae))

- **atlantis**: Address Copilot review on #211 — correct paths & recovery
  ([#211](https://github.com/CalebSargeant/infra/pull/211),
  [`d7b2e3f`](https://github.com/CalebSargeant/infra/commit/d7b2e3fd1ec6206893c4ef23c574a207c18c51fb))

- **atlantis**: Address Copilot review on #212 — webhook + App name consistency
  ([#212](https://github.com/CalebSargeant/infra/pull/212),
  [`33241aa`](https://github.com/CalebSargeant/infra/commit/33241aa4755b46c48751936ccc9b9c97b5f472ae))

- **atlantis**: Address second Copilot pass on #212 — consistency tightening
  ([#212](https://github.com/CalebSargeant/infra/pull/212),
  [`33241aa`](https://github.com/CalebSargeant/infra/commit/33241aa4755b46c48751936ccc9b9c97b5f472ae))

- **atlantis**: Clarify Traefik annotations are HTTPS-only (Copilot #215)
  ([#216](https://github.com/CalebSargeant/infra/pull/216),
  [`090f4dc`](https://github.com/CalebSargeant/infra/commit/090f4dc9f4baadaf51b2f0e50608ba0202188d75))

- **atlantis**: Clarify Traefik annotations are HTTPS-only (Copilot #215)
  ([#215](https://github.com/CalebSargeant/infra/pull/215),
  [`2ec3585`](https://github.com/CalebSargeant/infra/commit/2ec358561ccb43fccaffc92d925b5f6cbe9cd7d1))

- **atlantis**: Correct README example paths (Copilot review #201)
  ([#212](https://github.com/CalebSargeant/infra/pull/212),
  [`33241aa`](https://github.com/CalebSargeant/infra/commit/33241aa4755b46c48751936ccc9b9c97b5f472ae))

- **atlantis**: Correct README example paths (Copilot review #201)
  ([#211](https://github.com/CalebSargeant/infra/pull/211),
  [`d7b2e3f`](https://github.com/CalebSargeant/infra/commit/d7b2e3fd1ec6206893c4ef23c574a207c18c51fb))

- **atlantis**: Correct README example paths (Copilot review #201)
  ([#201](https://github.com/CalebSargeant/infra/pull/201),
  [`02f89a7`](https://github.com/CalebSargeant/infra/commit/02f89a77c72b837204e889d853af12796e0bcd9f))

- **atlantis**: Rewrite setup guide for GitHub App + OCI Vault flow
  ([#212](https://github.com/CalebSargeant/infra/pull/212),
  [`33241aa`](https://github.com/CalebSargeant/infra/commit/33241aa4755b46c48751936ccc9b9c97b5f472ae))

- **atlantis**: Rewrite setup guide for GitHub App + OCI Vault flow
  ([#211](https://github.com/CalebSargeant/infra/pull/211),
  [`d7b2e3f`](https://github.com/CalebSargeant/infra/commit/d7b2e3fd1ec6206893c4ef23c574a207c18c51fb))

- **cloudflare**: Capture ZTNA improvement backlog
  ([#199](https://github.com/CalebSargeant/infra/pull/199),
  [`d893df8`](https://github.com/CalebSargeant/infra/commit/d893df8441931608b9365d77d8a1650edb93d225))

- **cloudflared**: README architecture matches manifest
  ([#208](https://github.com/CalebSargeant/infra/pull/208),
  [`83e63f6`](https://github.com/CalebSargeant/infra/commit/83e63f650f7ceb0f12225b8fed9c2ff15e5bf19e))

- **cloudflared**: Update README for OCI Vault ExternalSecret flow
  ([#208](https://github.com/CalebSargeant/infra/pull/208),
  [`83e63f6`](https://github.com/CalebSargeant/infra/commit/83e63f650f7ceb0f12225b8fed9c2ff15e5bf19e))

- **oci**: VRRP HA design for OCI VCN egress failover
  ([#230](https://github.com/CalebSargeant/infra/pull/230),
  [`33bd44e`](https://github.com/CalebSargeant/infra/commit/33bd44e83dbf9e084697d0ccf7017c12672dce7f))

- **oci-vrrp**: Address Copilot review + concretise failover trigger options
  ([#230](https://github.com/CalebSargeant/infra/pull/230),
  [`33bd44e`](https://github.com/CalebSargeant/infra/commit/33bd44e83dbf9e084697d0ccf7017c12672dce7f))

### Features

- Add annotation filters for external DNS management
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Add annotation filters for external DNS management
  ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Add annotation filters for external DNS management
  ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Add External-DNS configuration for secondary MikroTik router
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Add External-DNS configuration for secondary MikroTik router
  ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Add External-DNS configuration for secondary MikroTik router
  ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Add External-DNS configuration for secondary MikroTik router
  ([#178](https://github.com/CalebSargeant/infra/pull/178),
  [`5164a87`](https://github.com/CalebSargeant/infra/commit/5164a87bd905ac62e3aab605abace521844df496))

- Add External-DNS configuration for secondary MikroTik router
  ([#177](https://github.com/CalebSargeant/infra/pull/177),
  [`1267122`](https://github.com/CalebSargeant/infra/commit/1267122ad32d9803197987806c33d1ece96eae0d))

- Add External-DNS configuration for secondary MikroTik router
  ([#176](https://github.com/CalebSargeant/infra/pull/176),
  [`0d3b841`](https://github.com/CalebSargeant/infra/commit/0d3b841adec408ef863f1352f12a03273bf89928))

- Add External-DNS configuration for secondary MikroTik router
  ([#175](https://github.com/CalebSargeant/infra/pull/175),
  [`5400b47`](https://github.com/CalebSargeant/infra/commit/5400b4792244f25c9a6d52f0a8a326141b05344a))

- Add External-DNS configuration for secondary MikroTik router
  ([#174](https://github.com/CalebSargeant/infra/pull/174),
  [`3caba76`](https://github.com/CalebSargeant/infra/commit/3caba7622bf98a342d5ef072744c0820b7863a8c))

- Add External-DNS configuration for secondary MikroTik router
  ([#173](https://github.com/CalebSargeant/infra/pull/173),
  [`5af28aa`](https://github.com/CalebSargeant/infra/commit/5af28aa0714aa96f2ce2fe193b7705426641ddb6))

- Add External-DNS configuration for secondary MikroTik router
  ([#172](https://github.com/CalebSargeant/infra/pull/172),
  [`acf9a05`](https://github.com/CalebSargeant/infra/commit/acf9a05a36c7001f6948057ccac128148f56e95f))

- Add External-DNS configuration for secondary MikroTik router
  ([#171](https://github.com/CalebSargeant/infra/pull/171),
  [`fef411a`](https://github.com/CalebSargeant/infra/commit/fef411a9db785d112a1790718a0d7eee81c37818))

- Add External-DNS configuration for secondary MikroTik router
  ([#170](https://github.com/CalebSargeant/infra/pull/170),
  [`e6e815a`](https://github.com/CalebSargeant/infra/commit/e6e815a5005e365cf49455f24aa8087993b63ee8))

- Add ExternalSecret for Cloudflare credentials and update helmrelease configuration
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Add ExternalSecret for Cloudflare credentials and update helmrelease configuration
  ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Add ExternalSecret for Cloudflare credentials and update helmrelease configuration
  ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Add ExternalSecret for Cloudflare credentials and update helmrelease configuration
  ([#178](https://github.com/CalebSargeant/infra/pull/178),
  [`5164a87`](https://github.com/CalebSargeant/infra/commit/5164a87bd905ac62e3aab605abace521844df496))

- Add ExternalSecret for Cloudflare credentials and update helmrelease configuration
  ([#177](https://github.com/CalebSargeant/infra/pull/177),
  [`1267122`](https://github.com/CalebSargeant/infra/commit/1267122ad32d9803197987806c33d1ece96eae0d))

- Add ExternalSecret for Cloudflare credentials and update helmrelease configuration
  ([#176](https://github.com/CalebSargeant/infra/pull/176),
  [`0d3b841`](https://github.com/CalebSargeant/infra/commit/0d3b841adec408ef863f1352f12a03273bf89928))

- Add ExternalSecret for Cloudflare credentials and update helmrelease configuration
  ([#175](https://github.com/CalebSargeant/infra/pull/175),
  [`5400b47`](https://github.com/CalebSargeant/infra/commit/5400b4792244f25c9a6d52f0a8a326141b05344a))

- Add ExternalSecret for Cloudflare credentials and update helmrelease configuration
  ([#174](https://github.com/CalebSargeant/infra/pull/174),
  [`3caba76`](https://github.com/CalebSargeant/infra/commit/3caba7622bf98a342d5ef072744c0820b7863a8c))

- Add ExternalSecret for Cloudflare credentials and update helmrelease configuration
  ([#173](https://github.com/CalebSargeant/infra/pull/173),
  [`5af28aa`](https://github.com/CalebSargeant/infra/commit/5af28aa0714aa96f2ce2fe193b7705426641ddb6))

- Add ExternalSecret for Cloudflare credentials and update helmrelease configuration
  ([#172](https://github.com/CalebSargeant/infra/pull/172),
  [`acf9a05`](https://github.com/CalebSargeant/infra/commit/acf9a05a36c7001f6948057ccac128148f56e95f))

- Add ExternalSecret for Cloudflare credentials and update helmrelease configuration
  ([#171](https://github.com/CalebSargeant/infra/pull/171),
  [`fef411a`](https://github.com/CalebSargeant/infra/commit/fef411a9db785d112a1790718a0d7eee81c37818))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#178](https://github.com/CalebSargeant/infra/pull/178),
  [`5164a87`](https://github.com/CalebSargeant/infra/commit/5164a87bd905ac62e3aab605abace521844df496))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#177](https://github.com/CalebSargeant/infra/pull/177),
  [`1267122`](https://github.com/CalebSargeant/infra/commit/1267122ad32d9803197987806c33d1ece96eae0d))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#176](https://github.com/CalebSargeant/infra/pull/176),
  [`0d3b841`](https://github.com/CalebSargeant/infra/commit/0d3b841adec408ef863f1352f12a03273bf89928))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#175](https://github.com/CalebSargeant/infra/pull/175),
  [`5400b47`](https://github.com/CalebSargeant/infra/commit/5400b4792244f25c9a6d52f0a8a326141b05344a))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#174](https://github.com/CalebSargeant/infra/pull/174),
  [`3caba76`](https://github.com/CalebSargeant/infra/commit/3caba7622bf98a342d5ef072744c0820b7863a8c))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#173](https://github.com/CalebSargeant/infra/pull/173),
  [`5af28aa`](https://github.com/CalebSargeant/infra/commit/5af28aa0714aa96f2ce2fe193b7705426641ddb6))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#172](https://github.com/CalebSargeant/infra/pull/172),
  [`acf9a05`](https://github.com/CalebSargeant/infra/commit/acf9a05a36c7001f6948057ccac128148f56e95f))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#171](https://github.com/CalebSargeant/infra/pull/171),
  [`fef411a`](https://github.com/CalebSargeant/infra/commit/fef411a9db785d112a1790718a0d7eee81c37818))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#170](https://github.com/CalebSargeant/infra/pull/170),
  [`e6e815a`](https://github.com/CalebSargeant/infra/commit/e6e815a5005e365cf49455f24aa8087993b63ee8))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#169](https://github.com/CalebSargeant/infra/pull/169),
  [`b80e075`](https://github.com/CalebSargeant/infra/commit/b80e07513c4782c7baa94836d3e5d872cd5b7e7b))

- Add ExternalSecret for WireGuard configuration and update kustomization files
  ([#168](https://github.com/CalebSargeant/infra/pull/168),
  [`45fdfd1`](https://github.com/CalebSargeant/infra/commit/45fdfd1dc4c95217a546d05a99fb0d3f8c21d5af))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#178](https://github.com/CalebSargeant/infra/pull/178),
  [`5164a87`](https://github.com/CalebSargeant/infra/commit/5164a87bd905ac62e3aab605abace521844df496))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#177](https://github.com/CalebSargeant/infra/pull/177),
  [`1267122`](https://github.com/CalebSargeant/infra/commit/1267122ad32d9803197987806c33d1ece96eae0d))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#176](https://github.com/CalebSargeant/infra/pull/176),
  [`0d3b841`](https://github.com/CalebSargeant/infra/commit/0d3b841adec408ef863f1352f12a03273bf89928))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#175](https://github.com/CalebSargeant/infra/pull/175),
  [`5400b47`](https://github.com/CalebSargeant/infra/commit/5400b4792244f25c9a6d52f0a8a326141b05344a))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#174](https://github.com/CalebSargeant/infra/pull/174),
  [`3caba76`](https://github.com/CalebSargeant/infra/commit/3caba7622bf98a342d5ef072744c0820b7863a8c))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#173](https://github.com/CalebSargeant/infra/pull/173),
  [`5af28aa`](https://github.com/CalebSargeant/infra/commit/5af28aa0714aa96f2ce2fe193b7705426641ddb6))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#172](https://github.com/CalebSargeant/infra/pull/172),
  [`acf9a05`](https://github.com/CalebSargeant/infra/commit/acf9a05a36c7001f6948057ccac128148f56e95f))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#171](https://github.com/CalebSargeant/infra/pull/171),
  [`fef411a`](https://github.com/CalebSargeant/infra/commit/fef411a9db785d112a1790718a0d7eee81c37818))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#170](https://github.com/CalebSargeant/infra/pull/170),
  [`e6e815a`](https://github.com/CalebSargeant/infra/commit/e6e815a5005e365cf49455f24aa8087993b63ee8))

- Add ExternalSecrets for MikroTik and Privado VPN credentials
  ([#169](https://github.com/CalebSargeant/infra/pull/169),
  [`b80e075`](https://github.com/CalebSargeant/infra/commit/b80e07513c4782c7baa94836d3e5d872cd5b7e7b))

- Add firefly tunnel hostname for igateway
  ([`5a6b544`](https://github.com/CalebSargeant/infra/commit/5a6b544a8ac367ce8c04cf03699ffe752a879b85))

- Add Franklinhouse middleware and update Headlamp ingress configuration
  ([`14c6b10`](https://github.com/CalebSargeant/infra/commit/14c6b1043d94751abcbf21b723830f1875826ddb))

- Add health check port to webhook deployment configuration
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Add health check port to webhook deployment configuration
  ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Add health check port to webhook deployment configuration
  ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Add health check port to webhook deployment configuration
  ([#178](https://github.com/CalebSargeant/infra/pull/178),
  [`5164a87`](https://github.com/CalebSargeant/infra/commit/5164a87bd905ac62e3aab605abace521844df496))

- Add health check port to webhook deployment configuration
  ([#177](https://github.com/CalebSargeant/infra/pull/177),
  [`1267122`](https://github.com/CalebSargeant/infra/commit/1267122ad32d9803197987806c33d1ece96eae0d))

- Add HelmReleases for Gatekeeper and Kubescape in Firefly cluster
  ([`beb4224`](https://github.com/CalebSargeant/infra/commit/beb422436fdc2bfb35e8fb082a0bb45cddf1786c))

- Add iadminpink host aliases to eurofiber web tunnel
  ([`7b0ca91`](https://github.com/CalebSargeant/infra/commit/7b0ca91d9b1578fb51f8f956bc6d502b962550ff))

- Add jantjepiet igateway host alias to eurofiber web tunnel
  ([`39f9613`](https://github.com/CalebSargeant/infra/commit/39f9613303a9990c3136656ce093151ff9779ba4))

- Add MikroTik router configuration for Cloudflare tunnel with HA setup
  ([#199](https://github.com/CalebSargeant/infra/pull/199),
  [`d893df8`](https://github.com/CalebSargeant/infra/commit/d893df8441931608b9365d77d8a1650edb93d225))

- Add new middleware and tunnel configurations for Eurofiber
  ([`624a6cd`](https://github.com/CalebSargeant/infra/commit/624a6cd715cf2170475efcf198d11e80d54718fc))

- Add remediation retries and update probes for webhook deployment
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Add routing rules for Eurofiber in ingressroute.yaml
  ([`26823bf`](https://github.com/CalebSargeant/infra/commit/26823bf163487a8d699565799304e79989bb9768))

- Add security namespace to kustomization ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Add security namespace to kustomization ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Add security namespace to kustomization ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Add security namespace to kustomization ([#178](https://github.com/CalebSargeant/infra/pull/178),
  [`5164a87`](https://github.com/CalebSargeant/infra/commit/5164a87bd905ac62e3aab605abace521844df496))

- Add security namespace to kustomization ([#177](https://github.com/CalebSargeant/infra/pull/177),
  [`1267122`](https://github.com/CalebSargeant/infra/commit/1267122ad32d9803197987806c33d1ece96eae0d))

- Add security namespace to kustomization ([#176](https://github.com/CalebSargeant/infra/pull/176),
  [`0d3b841`](https://github.com/CalebSargeant/infra/commit/0d3b841adec408ef863f1352f12a03273bf89928))

- Add security namespace to kustomization ([#175](https://github.com/CalebSargeant/infra/pull/175),
  [`5400b47`](https://github.com/CalebSargeant/infra/commit/5400b4792244f25c9a6d52f0a8a326141b05344a))

- Add security namespace to kustomization ([#174](https://github.com/CalebSargeant/infra/pull/174),
  [`3caba76`](https://github.com/CalebSargeant/infra/commit/3caba7622bf98a342d5ef072744c0820b7863a8c))

- Add ServiceAccount and init container for webhook readiness check
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Add ServiceAccount and init container for webhook readiness check
  ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Add ServiceAccount and init container for webhook readiness check
  ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Add ServiceAccount and init container for webhook readiness check
  ([#178](https://github.com/CalebSargeant/infra/pull/178),
  [`5164a87`](https://github.com/CalebSargeant/infra/commit/5164a87bd905ac62e3aab605abace521844df496))

- Add Slack integration to KRR for observability
  ([`2f50126`](https://github.com/CalebSargeant/infra/commit/2f50126ddf49c4f43bb59355557d9f1c93c35a40))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#178](https://github.com/CalebSargeant/infra/pull/178),
  [`5164a87`](https://github.com/CalebSargeant/infra/commit/5164a87bd905ac62e3aab605abace521844df496))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#177](https://github.com/CalebSargeant/infra/pull/177),
  [`1267122`](https://github.com/CalebSargeant/infra/commit/1267122ad32d9803197987806c33d1ece96eae0d))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#176](https://github.com/CalebSargeant/infra/pull/176),
  [`0d3b841`](https://github.com/CalebSargeant/infra/commit/0d3b841adec408ef863f1352f12a03273bf89928))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#175](https://github.com/CalebSargeant/infra/pull/175),
  [`5400b47`](https://github.com/CalebSargeant/infra/commit/5400b4792244f25c9a6d52f0a8a326141b05344a))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#174](https://github.com/CalebSargeant/infra/pull/174),
  [`3caba76`](https://github.com/CalebSargeant/infra/commit/3caba7622bf98a342d5ef072744c0820b7863a8c))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#173](https://github.com/CalebSargeant/infra/pull/173),
  [`5af28aa`](https://github.com/CalebSargeant/infra/commit/5af28aa0714aa96f2ce2fe193b7705426641ddb6))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#172](https://github.com/CalebSargeant/infra/pull/172),
  [`acf9a05`](https://github.com/CalebSargeant/infra/commit/acf9a05a36c7001f6948057ccac128148f56e95f))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#171](https://github.com/CalebSargeant/infra/pull/171),
  [`fef411a`](https://github.com/CalebSargeant/infra/commit/fef411a9db785d112a1790718a0d7eee81c37818))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#170](https://github.com/CalebSargeant/infra/pull/170),
  [`e6e815a`](https://github.com/CalebSargeant/infra/commit/e6e815a5005e365cf49455f24aa8087993b63ee8))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#169](https://github.com/CalebSargeant/infra/pull/169),
  [`b80e075`](https://github.com/CalebSargeant/infra/commit/b80e07513c4782c7baa94836d3e5d872cd5b7e7b))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#168](https://github.com/CalebSargeant/infra/pull/168),
  [`45fdfd1`](https://github.com/CalebSargeant/infra/commit/45fdfd1dc4c95217a546d05a99fb0d3f8c21d5af))

- Implement VPN gateway with Gluetun for centralized proxy routing
  ([#167](https://github.com/CalebSargeant/infra/pull/167),
  [`34da508`](https://github.com/CalebSargeant/infra/commit/34da508cddfd1451ed81caa0e7f7aedf7cd6ee71))

- OCI k3s + MikroTik egress, Cloudflare DNS/ZT import, secret consolidation
  ([#199](https://github.com/CalebSargeant/infra/pull/199),
  [`d893df8`](https://github.com/CalebSargeant/infra/commit/d893df8441931608b9365d77d8a1650edb93d225))

- Quick-win OCI + ZTNA improvements (groups, posture-staged, replace_triggered_by, L4 docs)
  ([#209](https://github.com/CalebSargeant/infra/pull/209),
  [`ebdcdd0`](https://github.com/CalebSargeant/infra/commit/ebdcdd0c461fc238e6ff4dc0f11c85e24fb4c191))

- Remove init container for webhook readiness check
  ([#199](https://github.com/CalebSargeant/infra/pull/199),
  [`d893df8`](https://github.com/CalebSargeant/infra/commit/d893df8441931608b9365d77d8a1650edb93d225))

- Remove init container for webhook readiness check
  ([#191](https://github.com/CalebSargeant/infra/pull/191),
  [`f48340d`](https://github.com/CalebSargeant/infra/commit/f48340d185ba09c8976eeec98dba1db840b8c979))

- Remove init container for webhook readiness check
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Remove init container for webhook readiness check
  ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Serve iadminpink via eurofiber web tunnel over https
  ([`5fc9b89`](https://github.com/CalebSargeant/infra/commit/5fc9b89d36353f2e26b1bf9d3e7338102eac7459))

- Update encrypted configs and switch databases to cloudnative postgres
  ([`8fc0ead`](https://github.com/CalebSargeant/infra/commit/8fc0eadb62dda235e7c7659d49286e537e4ed5af))

- Update External-DNS image for improved ARM64 support
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Update External-DNS image for improved ARM64 support
  ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Update External-DNS image for improved ARM64 support
  ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Update External-DNS image for improved ARM64 support
  ([#178](https://github.com/CalebSargeant/infra/pull/178),
  [`5164a87`](https://github.com/CalebSargeant/infra/commit/5164a87bd905ac62e3aab605abace521844df496))

- Update External-DNS image for improved ARM64 support
  ([#177](https://github.com/CalebSargeant/infra/pull/177),
  [`1267122`](https://github.com/CalebSargeant/infra/commit/1267122ad32d9803197987806c33d1ece96eae0d))

- Update External-DNS image for improved ARM64 support
  ([#176](https://github.com/CalebSargeant/infra/pull/176),
  [`0d3b841`](https://github.com/CalebSargeant/infra/commit/0d3b841adec408ef863f1352f12a03273bf89928))

- Update External-DNS image for improved ARM64 support
  ([#175](https://github.com/CalebSargeant/infra/pull/175),
  [`5400b47`](https://github.com/CalebSargeant/infra/commit/5400b4792244f25c9a6d52f0a8a326141b05344a))

- Update External-DNS image for improved ARM64 support
  ([#174](https://github.com/CalebSargeant/infra/pull/174),
  [`3caba76`](https://github.com/CalebSargeant/infra/commit/3caba7622bf98a342d5ef072744c0820b7863a8c))

- Update External-DNS image for improved ARM64 support
  ([#173](https://github.com/CalebSargeant/infra/pull/173),
  [`5af28aa`](https://github.com/CalebSargeant/infra/commit/5af28aa0714aa96f2ce2fe193b7705426641ddb6))

- Update External-DNS image for improved ARM64 support
  ([#172](https://github.com/CalebSargeant/infra/pull/172),
  [`acf9a05`](https://github.com/CalebSargeant/infra/commit/acf9a05a36c7001f6948057ccac128148f56e95f))

- Update Headlamp configmap with custom plugins directory and volume mounts
  ([`b3b36b4`](https://github.com/CalebSargeant/infra/commit/b3b36b48622b54e1e14e91c25dadcda283b9f6dc))

- Update Headlamp configmap with custom plugins directory and volume mounts
  ([`e6d7b20`](https://github.com/CalebSargeant/infra/commit/e6d7b20b5b73f89385e77bf3c890a96bfba343d8))

- Update webhook deployment probes for improved health checks
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Update webhook deployment probes for improved health checks
  ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Update webhook deployment probes for improved health checks
  ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Update webhook deployment probes for improved health checks
  ([#178](https://github.com/CalebSargeant/infra/pull/178),
  [`5164a87`](https://github.com/CalebSargeant/infra/commit/5164a87bd905ac62e3aab605abace521844df496))

- Update webhook deployment probes for improved health checks
  ([#177](https://github.com/CalebSargeant/infra/pull/177),
  [`1267122`](https://github.com/CalebSargeant/infra/commit/1267122ad32d9803197987806c33d1ece96eae0d))

- Update webhook deployment probes for improved health checks
  ([#176](https://github.com/CalebSargeant/infra/pull/176),
  [`0d3b841`](https://github.com/CalebSargeant/infra/commit/0d3b841adec408ef863f1352f12a03273bf89928))

- Update webhook provider configuration and add RBAC for external DNS
  ([#181](https://github.com/CalebSargeant/infra/pull/181),
  [`ca90e04`](https://github.com/CalebSargeant/infra/commit/ca90e0407e4d63c9716889c04aa2ff38a3f7a1ba))

- Update webhook provider configuration and add RBAC for external DNS
  ([#180](https://github.com/CalebSargeant/infra/pull/180),
  [`feb82eb`](https://github.com/CalebSargeant/infra/commit/feb82eb81bbebe2b0f8a3425c4b671afb1b8fedc))

- Update webhook provider configuration and add RBAC for external DNS
  ([#179](https://github.com/CalebSargeant/infra/pull/179),
  [`23223eb`](https://github.com/CalebSargeant/infra/commit/23223eb50f942c6b798435356066e407e80dcaea))

- Update webhook provider configuration and add RBAC for external DNS
  ([#178](https://github.com/CalebSargeant/infra/pull/178),
  [`5164a87`](https://github.com/CalebSargeant/infra/commit/5164a87bd905ac62e3aab605abace521844df496))

- Update webhook provider configuration and add RBAC for external DNS
  ([#177](https://github.com/CalebSargeant/infra/pull/177),
  [`1267122`](https://github.com/CalebSargeant/infra/commit/1267122ad32d9803197987806c33d1ece96eae0d))

- Update webhook provider configuration and add RBAC for external DNS
  ([#176](https://github.com/CalebSargeant/infra/pull/176),
  [`0d3b841`](https://github.com/CalebSargeant/infra/commit/0d3b841adec408ef863f1352f12a03273bf89928))

- Update webhook provider configuration and add RBAC for external DNS
  ([#175](https://github.com/CalebSargeant/infra/pull/175),
  [`5400b47`](https://github.com/CalebSargeant/infra/commit/5400b4792244f25c9a6d52f0a8a326141b05344a))

- **atlantis**: Switch from PAT to GitHub App auth (OCI Vault-sourced)
  ([#201](https://github.com/CalebSargeant/infra/pull/201),
  [`02f89a7`](https://github.com/CalebSargeant/infra/commit/02f89a77c72b837204e889d853af12796e0bcd9f))

- **atlantis**: Switch from PAT to GitHub App auth, sourced from OCI Vault
  ([#212](https://github.com/CalebSargeant/infra/pull/212),
  [`33241aa`](https://github.com/CalebSargeant/infra/commit/33241aa4755b46c48751936ccc9b9c97b5f472ae))

- **atlantis**: Switch from PAT to GitHub App auth, sourced from OCI Vault
  ([#211](https://github.com/CalebSargeant/infra/pull/211),
  [`d7b2e3f`](https://github.com/CalebSargeant/infra/commit/d7b2e3fd1ec6206893c4ef23c574a207c18c51fb))

- **atlantis**: Switch from PAT to GitHub App auth, sourced from OCI Vault
  ([#201](https://github.com/CalebSargeant/infra/pull/201),
  [`02f89a7`](https://github.com/CalebSargeant/infra/commit/02f89a77c72b837204e889d853af12796e0bcd9f))

- **cf-dns**: Add atlantis.sargeant.co CNAME to the firefly tunnel
  ([#219](https://github.com/CalebSargeant/infra/pull/219),
  [`4f4f901`](https://github.com/CalebSargeant/infra/commit/4f4f901053268662f2e64012328736f3d67d1986))

- **cf-tunnel**: Route atlantis.sargeant.co to in-cluster Atlantis
  ([#216](https://github.com/CalebSargeant/infra/pull/216),
  [`090f4dc`](https://github.com/CalebSargeant/infra/commit/090f4dc9f4baadaf51b2f0e50608ba0202188d75))

- **cloudflare**: Add DNS records module + ZT scaffolding with imports
  ([#199](https://github.com/CalebSargeant/infra/pull/199),
  [`d893df8`](https://github.com/CalebSargeant/infra/commit/d893df8441931608b9365d77d8a1650edb93d225))

- **cloudflare,mikrotik**: Dynamic record imports + move mikrotik secrets to OCI Vault
  ([#199](https://github.com/CalebSargeant/infra/pull/199),
  [`d893df8`](https://github.com/CalebSargeant/infra/commit/d893df8441931608b9365d77d8a1650edb93d225))

- **dns**: Source OCI MikroTik public IPs from edge module state
  ([#218](https://github.com/CalebSargeant/infra/pull/218),
  [`c24020e`](https://github.com/CalebSargeant/infra/commit/c24020e3b82b7ee1c68cddc7b731ac052813ce06))

- **oci**: K3s agent join + app/data subnet internet egress via MikroTik
  ([#199](https://github.com/CalebSargeant/infra/pull/199),
  [`d893df8`](https://github.com/CalebSargeant/infra/commit/d893df8441931608b9365d77d8a1650edb93d225))

- **oci**: K3s join token fetched from OCI Vault at boot (closes #1)
  ([#210](https://github.com/CalebSargeant/infra/pull/210),
  [`ff0895c`](https://github.com/CalebSargeant/infra/commit/ff0895c08f0a1a9edf033dbc15ee9772584dfd9a))

- **oci-edge**: Opt-in reserved public IPs (var.use_reserved_public_ips)
  ([#227](https://github.com/CalebSargeant/infra/pull/227),
  [`b6fd0f1`](https://github.com/CalebSargeant/infra/commit/b6fd0f1f5680769cc44e308413b32e88c310ad6a))

- **structure**: Add apps/excalidraw scaffold + clusters/firefly stub (Phase 2 first slice)
  ([#193](https://github.com/CalebSargeant/infra/pull/193),
  [`9796256`](https://github.com/CalebSargeant/infra/commit/9796256edd1c94eccefdbc5a56ec02b52fe87634))

- **structure**: Add apps/excalidraw/ and clusters/firefly/ scaffolds (Phase 2)
  ([#193](https://github.com/CalebSargeant/infra/pull/193),
  [`9796256`](https://github.com/CalebSargeant/infra/commit/9796256edd1c94eccefdbc5a56ec02b52fe87634))

- **structure**: Cut excalidraw over to the new apps/ tree (Phase 2 step 3)
  ([#195](https://github.com/CalebSargeant/infra/pull/195),
  [`f9d0848`](https://github.com/CalebSargeant/infra/commit/f9d08489d9ee440b2567d675eb92ec8d4337a002))

- **structure**: Migrate 28 apps to the new apps/<app>/ layout (Phase 2 atomic batch)
  ([#196](https://github.com/CalebSargeant/infra/pull/196),
  [`e18a58a`](https://github.com/CalebSargeant/infra/commit/e18a58a1a72779de169ca90a51629a56f606dc6c))

- **structure**: Wire kubernetes/clusters/firefly into Flux (Phase 2 step 2)
  ([#194](https://github.com/CalebSargeant/infra/pull/194),
  [`872823a`](https://github.com/CalebSargeant/infra/commit/872823a2b9f45a000eb3bc98f9487c1f23a277a9))

- **ztna**: Drop dead-code L4 allow+block on 192.168.69.110
  ([#229](https://github.com/CalebSargeant/infra/pull/229),
  [`189f11d`](https://github.com/CalebSargeant/infra/commit/189f11dd1ac74a4c1895c65400e1a786e44985ae))

- **ztna**: Expand free-tier adware blocklist (closes #7 workaround)
  ([#209](https://github.com/CalebSargeant/infra/pull/209),
  [`ebdcdd0`](https://github.com/CalebSargeant/infra/commit/ebdcdd0c461fc238e6ff4dc0f11c85e24fb4c191))

- **ztna**: Promote Radarr from bookmark to self_hosted
  ([#209](https://github.com/CalebSargeant/infra/pull/209),
  [`ebdcdd0`](https://github.com/CalebSargeant/infra/commit/ebdcdd0c461fc238e6ff4dc0f11c85e24fb4c191))

- **ztna**: Promote Radarr from bookmark to self_hosted (#1)
  ([#209](https://github.com/CalebSargeant/infra/pull/209),
  [`ebdcdd0`](https://github.com/CalebSargeant/infra/commit/ebdcdd0c461fc238e6ff4dc0f11c85e24fb4c191))

- **ztna**: Recreate reusable policies as app-scoped + wire posture (closes #3, #4)
  ([#209](https://github.com/CalebSargeant/infra/pull/209),
  [`ebdcdd0`](https://github.com/CalebSargeant/infra/commit/ebdcdd0c461fc238e6ff4dc0f11c85e24fb4c191))

- **ztna**: Service tokens scaffold + improvements memo updates
  ([#209](https://github.com/CalebSargeant/infra/pull/209),
  [`ebdcdd0`](https://github.com/CalebSargeant/infra/commit/ebdcdd0c461fc238e6ff4dc0f11c85e24fb4c191))

### Refactoring

- **oci**: Make user_data rebuild trigger opt-in (Copilot #213)
  ([#213](https://github.com/CalebSargeant/infra/pull/213),
  [`34c7897`](https://github.com/CalebSargeant/infra/commit/34c7897a1d1e06886405af152481a4ed95bacb72))


## v1.22.0 (2026-02-09)

### Chores

- **deps**: Bump actions/checkout from 4 to 5
  ([#135](https://github.com/CalebSargeant/infra/pull/135),
  [`54a9cfd`](https://github.com/CalebSargeant/infra/commit/54a9cfdb58557ca261449904f256bf78d474e22d))

- **deps**: Bump actions/setup-python from 5 to 6
  ([#137](https://github.com/CalebSargeant/infra/pull/137),
  [`168e2f8`](https://github.com/CalebSargeant/infra/commit/168e2f840222b09072a6e95e8df0f9f25987deaa))

- **deps**: Bump actions/upload-pages-artifact from 3 to 4
  ([#138](https://github.com/CalebSargeant/infra/pull/138),
  [`bfc96ae`](https://github.com/CalebSargeant/infra/commit/bfc96aedee8edbb5e11ad0ec804d2d1fd8ca59f6))

- **deps**: Bump CalebSargeant/reusable-workflows from 1.0.3 to 1.0.10
  ([#136](https://github.com/CalebSargeant/infra/pull/136),
  [`c321553`](https://github.com/CalebSargeant/infra/commit/c321553d7f2785e7d44779c3403e24f37990bc0c))

- **deps**: Bump CalebSargeant/reusable-workflows/.github/workflows/semantic-release.yaml
  ([#139](https://github.com/CalebSargeant/infra/pull/139),
  [`603c1f5`](https://github.com/CalebSargeant/infra/commit/603c1f56a8de8b27200c45ba0072c8769807ef42))


## v1.21.1 (2026-02-08)


## v1.21.0 (2026-02-08)

### Bug Fixes

- Remove unused namespace.yaml from Excalidraw kustomization
  ([`ed5545a`](https://github.com/CalebSargeant/infra/commit/ed5545a2f6ab82e3effc1b8ca0100a0fa8b367d3))


## v1.20.0 (2026-02-08)


## v1.19.3 (2026-02-08)


## v1.19.2 (2026-02-08)


## v1.19.1 (2026-02-08)


## v1.19.0 (2026-02-08)


## v1.18.2 (2026-02-08)


## v1.18.1 (2026-02-08)


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
