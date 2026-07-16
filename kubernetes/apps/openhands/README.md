# openhands — DORMANT scaffold (not deployed)

OpenHands is the **dev-lane** engine in the agent architecture (autonomous coding:
implement/fix an issue or PR and open a PR — driven on demand, and later dispatched by
Nievah *as you*).

**This app is intentionally NOT wired into [`../kustomization.yaml`](../kustomization.yaml),
so Flux does not deploy it.** It is a reviewed starting point, parked because OpenHands is
not yet safe to auto-deploy here:

1. **V1 transition.** Upstream is moving to a new `agent-server` + `agent-canvas` stack
   (`ghcr.io/openhands/agent-canvas`, currently a **release candidate**, port 8000). This
   scaffold pins the **stable V0 server** (`docker.all-hands.dev/all-hands-ai/openhands`,
   port 3000) — confirm the right line/tag/arch before enabling.
2. **Runtime sandbox.** It uses `RUNTIME=local` (runs in-container, no privileged DinD, no
   separate amd64-only runtime image). The pod is the sandbox boundary. If you need stronger
   isolation, the Kubernetes runtime (sandbox pods + RBAC) is a follow-up.
3. **Headless + custom LiteLLM** has open upstream bugs (#11608/#11632); the `litellm_proxy/`
   model prefix is the documented workaround and is set here.
4. **It acts as you** (holds your GitHub PAT + writes code). Same trust posture as Nievah's
   write path — enable it deliberately, not via a silent merge.

## Enable (after validating in-cluster)

1. Confirm the image line/tag and that it boots with `RUNTIME=local` (test the pod first).
2. Add `- ./openhands` to [`../kustomization.yaml`](../kustomization.yaml) (it's there now as
   a commented line).
3. (Optional) mint a dedicated `openhands-github-pat` vault entry and point the ExternalSecret
   at it instead of the reused `comment-commander-github-pat`.

Inference is the in-cluster LiteLLM (`…:4000`, `litellm_proxy/claude-opus-4-8`); secrets come
from OCI Vault via the ExternalSecret; LAN-only ingress at `openhands.sargeant.co`.
