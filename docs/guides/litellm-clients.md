# Pointing dev tools at the LiteLLM gateway

The LiteLLM proxy (`kubernetes/apps/litellm`) is an OpenAI-compatible gateway. Any
tool that speaks the OpenAI API can route through it: one endpoint, one key, unified
usage tracking + the LiteLLM admin UI.

- **In-cluster URL:** `http://litellm.automation.svc.cluster.local:4000`
- **External URL (once the ingress lands):** `https://litellm.sargeant.co`
- **Auth:** every client presents the **LiteLLM key** (the master key, or a virtual
  key minted in the UI). Tools that follow the OpenAI convention send it as
  `Authorization: Bearer <key>` (i.e. as their `OPENAI_API_KEY`).
- **Model names:** clients request a `model_name` from the proxy's `config.yaml`
  (`claude-opus-4-8`, `claude-sonnet-4-6`, `claude-haiku-4-5`, …).

## ⚠️ Billing: subscription vs. per-token

There are two ways the proxy talks upstream:

| Path | Who | Billing | How |
|---|---|---|---|
| **Subscription** | **Claude Code only** (incl. the diatreme dispatcher) | Flat-rate Max plan | Claude Code forwards its **OAuth** token in `Authorization`; LiteLLM forwards it upstream (`forward_client_headers_to_llm_api`). Gateway is authed via the `x-litellm-api-key` header. |
| **Per-token (API key)** | **Codex, OpenCode, OpenAI Agents SDK**, anything OpenAI-protocol | Per-token on a provider account | The client sends the LiteLLM key in `Authorization`; LiteLLM calls the provider with its own configured `api_key`. |

The three tools below put a **key** in `Authorization`, so they **cannot use the
Claude Max subscription** — that's exclusive to Claude Code's OAuth. To use them
through LiteLLM you must add at least one **API-key'd model** to the proxy, e.g.:

```yaml
# kubernetes/apps/litellm/base/litellm/configmap.yaml  (model_list)
  - model_name: gpt-4o
    litellm_params:
      model: openai/gpt-4o
      api_key: os.environ/OPENAI_API_KEY        # per-token on your OpenAI account
  - model_name: gemini-2.0-flash
    litellm_params:
      model: gemini/gemini-2.0-flash
      api_key: os.environ/GEMINI_API_KEY
  - model_name: claude-sonnet-api                # Claude per-token (NOT the Max plan)
    litellm_params:
      model: anthropic/claude-sonnet-4-6
      api_key: os.environ/ANTHROPIC_API_KEY
```

…plus the matching `ExternalSecret` entry + `Deployment` env for each key.

---

## Codex CLI

```bash
export OPENAI_BASE_URL="https://litellm.sargeant.co"   # or the in-cluster URL
export OPENAI_API_KEY="<your-litellm-key>"
codex --model gpt-4o --full-auto
```

Or persist it in `~/.codex/config.toml`:

```toml
model = "gpt-4o"
[model_providers.litellm]
name = "LiteLLM"
base_url = "https://litellm.sargeant.co/v1"
env_key = "OPENAI_API_KEY"      # Codex reads the key from this env var
```

## OpenCode

`~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "litellm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LiteLLM",
      "options": { "baseURL": "https://litellm.sargeant.co/v1" },
      "models": {
        "gpt-4o": { "name": "GPT-4o" },
        "claude-sonnet-api": { "name": "Claude Sonnet (API)" }
      }
    }
  }
}
```

Then in OpenCode run `/connect`, pick provider **LiteLLM**, and paste your LiteLLM
key. Model keys must match the proxy's `model_name` values exactly. If a reasoning
model rejects params, add `additional_drop_params: ["reasoningSummary"]` to the
proxy `litellm_settings`.

## OpenAI Agents SDK (Python)

```python
import os
from agents import Agent, Runner, ModelProvider, Model, OpenAIChatCompletionsModel, RunConfig, set_tracing_disabled
from openai import AsyncOpenAI

client = AsyncOpenAI(
    base_url=os.getenv("LITELLM_BASE_URL", "https://litellm.sargeant.co"),
    api_key=os.environ["LITELLM_API_KEY"],   # your LiteLLM key, not a provider key
)
set_tracing_disabled(True)

class LiteLLMProvider(ModelProvider):
    def get_model(self, model_name: str | None) -> Model:
        return OpenAIChatCompletionsModel(model=model_name or "gpt-4o", openai_client=client)

# Runner.run(agent, "...", run_config=RunConfig(model_provider=LiteLLMProvider(), model="gpt-4o"))
```

Uses the Chat Completions path (not the Responses API), which LiteLLM serves for all
configured models.
