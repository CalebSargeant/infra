# Custom atlantis image for the firefly cluster.
#
# Bakes `oci` (oci-cli) + `terragrunt` into the upstream atlantis image so
# that:
#   1. Server-side workflow shells (kubernetes/apps/atlantis/base/atlantis/
#      configmap.yaml — "if [ -f terragrunt.hcl ]; then terragrunt plan ...")
#      find terragrunt on PATH.
#   2. Terragrunt parse-time `run_cmd("oci secrets secret-bundle get ...")`
#      calls (e.g. terraform/cloudflare/dns/prod/terragrunt.hcl) find the oci
#      CLI on PATH. Without this the plan failed with
#         bash: line 1: oci: command not found
#      followed by cascading "Unknown variable" errors as terragrunt's parse
#      tried to consume the empty token output.
#
# Replaces the earlier install-terragrunt initContainer pattern (#232).
# That worked for terragrunt alone (~25MB single binary) but couldn't
# reasonably satisfy oci-cli, which needs a full python runtime + ~40 pip
# deps. Baking everything into the image is cleaner long-term and avoids
# per-pod-start downloads.
#
# Bump TERRAGRUNT_VERSION / OCI_CLI_VERSION below, then either:
#   - push to main (path-filtered workflow rebuilds :latest), or
#   - push a tag `atlantis-firefly-v<rev>` (builds :<rev> + :latest).
# When bumping TERRAGRUNT_VERSION update both SHA256 values — pull them
# from the matching release's SHA256SUMS file at
#   https://github.com/gruntwork-io/terragrunt/releases/download/<VERSION>/SHA256SUMS
# The PR-review-time pairing of binary + SHA is the supply-chain guard.

ARG ATLANTIS_VERSION=v0.43.0
FROM ghcr.io/runatlantis/atlantis:${ATLANTIS_VERSION}

# Upstream image runs as the `atlantis` user (uid 100). Drop to root for the
# install steps and switch back at the end so pod startup doesn't need
# runAsUser overrides beyond what the deployment already sets.
USER root

ARG TERRAGRUNT_VERSION=v1.0.5
ARG TERRAGRUNT_SHA256_AMD64=729d59f7655e25e8db4abd73a422d002d80720ef1edbd2f4a03322e79e444101
ARG TERRAGRUNT_SHA256_ARM64=36dd76fe7f211aedf79920f6f1794eed22e7d7142fe969f4cfff5d863f6593f3
# oci-cli is pure python so the same wheel works on amd64 and arm64. Pinned
# here as a supply-chain guard; bump alongside major terragrunt/atlantis
# bumps.
ARG OCI_CLI_VERSION=3.50.0

# python3 + pip for oci-cli; libffi/openssl/ca-certificates are runtime deps
# loaded dynamically by the CLI's crypto modules. bash so the workflow's
# `bash -c` heredoc in terragrunt.hcl works without surprises.
#
# --break-system-packages: Alpine 3.20+ ships pip with PEP 668's
# "externally-managed" marker. Fine here because we own the image and aren't
# co-tenanting pip with apk's python packages. The alternative (a venv)
# would force every shell to source-activate before running oci.
RUN apk add --no-cache \
        bash \
        ca-certificates \
        libffi \
        openssl \
        python3 \
        py3-pip \
        wget \
    && pip install --no-cache-dir --break-system-packages \
        "oci-cli==${OCI_CLI_VERSION}" \
    && oci --version

# TARGETARCH is set automatically by `docker buildx build --platform ...`
# (amd64 | arm64). Pick the matching binary + SHA so the multi-arch manifest
# stays verifiable per-arch.
ARG TARGETARCH
RUN set -eu; \
    case "${TARGETARCH}" in \
      amd64) GOARCH=amd64; SHA="${TERRAGRUNT_SHA256_AMD64}" ;; \
      arm64) GOARCH=arm64; SHA="${TERRAGRUNT_SHA256_ARM64}" ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    wget -qO /usr/local/bin/terragrunt \
      "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_${GOARCH}"; \
    echo "${SHA}  /usr/local/bin/terragrunt" | sha256sum -c -; \
    chmod 0755 /usr/local/bin/terragrunt; \
    terragrunt --version

# Back to the unprivileged atlantis user the upstream image uses for the
# server process.
USER atlantis
