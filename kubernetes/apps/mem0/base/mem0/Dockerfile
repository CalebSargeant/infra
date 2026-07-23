# mem0 fleet-memory server image.
#
# The upstream mem0/mem0-api-server image does not include the pgvector client deps,
# so we layer them on. Vector memory only (no Neo4j/graph, unlike the retired
# zoey/k8s-mem0 build). Build + push to the org registry, then pin the tag in
# deployment.yaml:
#   docker build -t ghcr.io/magmamoose/mem0-server:<tag> kubernetes/apps/mem0/base/mem0
#   docker push ghcr.io/magmamoose/mem0-server:<tag>
#
# Longer term this belongs in its own MagmaMoose/mem0-server repo with CI + Flux image
# automation (matching github-contributions/nievah), not built by hand from infra.
#
# Chargate/KICS suppression (accepted risk, reviewed):
#   b03a748a no HEALTHCHECK – Kubernetes ignores Docker HEALTHCHECK entirely; the
#            Deployment already has HTTP readiness + liveness probes on :8000/docs.
#            Adding one would need curl/wget in the image — more attack surface, no effect.
# kics-scan disable=b03a748a-542d-44f4-bb86-9199ab4fd2d5
#
# Base pinned by DIGEST, not `:latest` — upstream publishes only a `latest` tag
# (registry tags list == ["latest"]), so a digest is the only way to get an immutable
# base. Every other base in this repo is pinned (github-runner 2.334.0, wordpress
# 6.7-apache, debian bookworm-slim); this keeps that invariant. Re-resolve with:
#   docker buildx imagetools inspect mem0/mem0-api-server:latest
FROM mem0/mem0-api-server@sha256:2fcf4bb713cfc584d454bf06993cc7e2fe51540695995bd3aa9c7008b7065c75
# hadolint ignore=DL3013
RUN pip install --no-cache-dir "psycopg[binary,pool]" "pgvector" "rank-bm25"
USER 65534
