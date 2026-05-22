# CHANGELOG

<!-- version list -->

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
