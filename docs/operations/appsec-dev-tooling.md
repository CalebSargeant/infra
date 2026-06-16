# AppSec and Dev Tooling Hostnames

The public AppSec/dev-tooling endpoints hosted on firefly use `magmamoose.com`
hostnames. Public traffic enters through the Cloudflare `firefly` tunnel and is
routed to in-cluster services.

| Tool | Public URL | In-cluster target |
|---|---|---|
| Pull request dashboard | `https://pullrequests.magmamoose.com` | `oauth2-proxy.automation.svc.cluster.local:4180` |
| DefectDojo | `https://defectdojo.magmamoose.com` | `oauth2-proxy.security.svc.cluster.local:4180` |
| Dependency-Track frontend | `https://dependencytrack.magmamoose.com` | `dependency-track-frontend.security.svc.cluster.local:8080` |
| Dependency-Track API | `https://dependencytrack-api.magmamoose.com` | `dependency-track-api-server.security.svc.cluster.local:8080` |
| safe-settings | `https://safesettings.magmamoose.com` | `safe-settings.security.svc.cluster.local:3000` |

Keep these three layers aligned when changing a hostname:

- Cloudflare DNS CNAMEs in `terraform/cloudflare/dns-magmamoose/prod/terragrunt.hcl`.
- Cloudflare Tunnel ingress rules in `terraform/cloudflare/zero-trust/prod/tunnels.tf`.
- App-level URLs and allowed hosts in the Kubernetes manifests.

Dependency-Track needs both frontend and API public hostnames because the SPA
calls the API host directly from the browser. safe-settings must remain public
without a Cloudflare Access gate for `/api/github/webhooks`; GitHub authenticates
payloads with the webhook secret instead.
