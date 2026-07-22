# Custom GitHub Actions self-hosted runner image for the firefly cluster.
#
# Bakes `envsubst` (from gettext) into the upstream runner image. Diatreme's
# `image-sign` step installs cosign via a script that calls `envsubst`; the
# stock runner image doesn't ship it, so `mode: release` fails with
# "envsubst: command not found" (exit 127) right after the version tag is
# created - a tag is made but no GitHub Release. See MagmaMoose/dastgate.
#
# Deployed by ansible/roles/k3s-github-runner (image = runner_image).
#
# BASE_IMAGE must match the runner the cluster actually runs (env-var contract:
# myoung34/github-runner). Pin it to the tag in use if it differs from the
# default below.
ARG BASE_IMAGE=myoung34/github-runner:latest
FROM ${BASE_IMAGE}

USER root

# envsubst ships in `gettext` on Alpine and `gettext-base` on Debian/Ubuntu;
# install whichever this base uses, then assert it's on PATH so a wrong base
# fails the build instead of the release.
RUN if command -v apk >/dev/null 2>&1; then \
        apk add --no-cache gettext; \
    else \
        apt-get update \
        && apt-get install -y --no-install-recommends gettext-base \
        && rm -rf /var/lib/apt/lists/*; \
    fi \
    && command -v envsubst

# Drop back to the runner uid the k3s Deployment runs as
# (securityContext.runAsUser: 1000), so the image isn't left running as root.
USER 1000
