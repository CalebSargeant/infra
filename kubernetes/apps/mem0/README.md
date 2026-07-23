# mem0 — fleet-shared agent memory

The single durable-memory service for the agent fleet (Nievah/Claude Code, Hermes,
OpenHands, HolmesGPT). It is the `mem0` OSS REST server backed by **pgvector on the
shared CNPG `postgres` cluster** (NOT a new database — a `Database` CR on the existing
cluster, per COMMON_MISTAKES #3), with LLM + embeddings routed through the in-cluster
**LiteLLM** gateway. Lifted out of the retired `zoey` app (`zoey/k8s-mem0/`) and
promoted to a Flux-managed fleet service. Graph memory (Neo4j) is intentionally
dropped — vector memory only.

See ADR `.claude/decisions/2026-07-23-fleet-shared-memory-mem0.md`.

## Layout
- `base/mem0/database.yaml`      — CNPG `Database` CR (`agent_memory`, owner `neondb_owner`), ns `database`
- `base/mem0/extension-job.yaml` — one-shot Job that `CREATE EXTENSION vector` (needs superuser), ns `database`
- `base/mem0/externalsecret.yaml`— DATABASE_URL + POSTGRES_PASSWORD + LiteLLM key (OCI Vault), ns `automation`
- `base/mem0/{deployment,service,ingress}.yaml` — the mem0 REST server, ns `automation`
- `base/mem0/Dockerfile`         — the image (mem0 server + pgvector deps)

## PREREQUISITES / VALIDATE-ON-FIRST-DEPLOY (read before merging)

1. **Container image must be built + pushed.** The upstream `mem0/mem0-api-server`
   image does not ship the pgvector client deps (see `Dockerfile`). Build and push
   `ghcr.io/magmamoose/mem0-server` (ideally from its own repo + CI, matching the
   github-contributions/nievah convention) before this reconciles, or the Deployment
   ImagePullBackOffs. Pin a real tag over `:latest`.
2. **LiteLLM rollout required.** The LiteLLM ConfigMap in this change adds
   `text-embedding-3-small` and `gpt-4o-mini`. LiteLLM reads its YAML config at startup
   only — after this PR merges and Flux reconciles the ConfigMap, trigger a rollout so
   the new model entries load:
   ```
   kubectl rollout restart deployment/litellm -n automation
   ```
   Without this step, mem0's first embedding/completion calls will fail with "model not
   found". Confirm the env vars (`OPENAI_BASE_URL`, `OPENAI_API_KEY`) match the
   provisioned ExternalSecret. Adjust models to `claude-*`/`deepseek-*` if you prefer
   non-OpenAI extraction.
3. **pgvector extension.** This CNPG version's `Database` CR has no `spec.extensions`,
   and `neondb_owner` is not a superuser, so `extension-job.yaml` creates the extension
   using the existing `admin` superuser (secret `nextcloud-db-admin` in ns `database`).
   Reviewed choice — there is no dedicated postgres-superuser secret on this cluster.
4. **AUTH_DISABLED=true** for v1 (LAN-only ingress + in-cluster callers). Add an admin
   key before exposing beyond the LAN.

## MCP exposure (the fleet interface — fast follow)

mem0's storage layer is here; the shared **MCP-over-SSE** endpoint every agent points at
is the next step. mem0's own self-hosted MCP packaging is in flux (OpenMemory deprecated),
so it is deliberately NOT baked in yet. Wiring:
- **Claude Code** — `~/.claude.json` mcpServers → `@tensakulabs/mem0-mcp` (npx) against
  `MEM0_BASE_URL=http://mem0.sargeant.co`, `MEM0_USER_ID=caleb`, `MEM0_AGENT_ID=claude-code`
  (proven in `zoey/k8s-mem0/claude-mcp-config.json`).
- **Hermes / OpenHands / HolmesGPT** — need a remote SSE MCP shim in-cluster; pick a
  maintained wrapper, add it as a second container/Deployment, expose SSE. Holmes is
  SSE-only. Namespace memories by `agent_id` (`claude-code`/`hermes`/`holmes`/`openhands`)
  with a shared `user_id=caleb` for cross-agent facts.
