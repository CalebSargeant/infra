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
# hadolint ignore=DL3007
FROM mem0/mem0-api-server:latest
# hadolint ignore=DL3013
RUN pip install --no-cache-dir "psycopg[binary,pool]" "pgvector" "rank-bm25"
USER 65534
