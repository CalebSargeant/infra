### NetFlow-as-a-Service (NaaS) Backend Spec
Production-ready FastAPI multi-tenant NetFlow-as-a-Service for SMBs/MSPs. FlutterFlow frontend (REST API only). No Grafana/BI—the API is the product.

### Architecture
- **Ingest:** GoFlow2 (v5/v9, IPFIX, sFlow) -> Redpanda (JSON) -> ClickHouse Worker (batch write).
- **API:** FastAPI (Auth, Tenant/User/Billing/Exporter Mgmt, Dashboard/Reports/Alerts/Webhooks).
- **Workers:**
  - *Report:* Redpanda job -> ClickHouse query -> WeasyPrint (PDF/CSV) -> MinIO.
  - *Alert:* Scheduled ClickHouse eval -> Redpanda alert.
  - *Notification:* Redpanda alert -> Slack/Teams/Webhooks.
- **Storage:** PostgreSQL (Relational/System of Record), ClickHouse (Flows), MinIO (Reports), Redpanda (Bus).
- **Design:** Multi-tenancy, horizontal scaling, GDPR/EU residency. Tenant-scoped at all layers.

### Project Structure
```
/app
  /api/v1: router.py, /routes (auth, tenants, users, billing, reports, alerts, flows, exporters, webhooks, audit, admin)
  /core: config, security, database, clickhouse, minio, redpanda, logging, middleware, exceptions, deps
  /models: tenant, user, billing, report, alert, exporter, webhook, audit, api_key
  /schemas: tenant, user, billing, report, alert, flows, exporter, webhook, audit, api_key, common
  /workers: clickhouse_consumer, report_worker, alert_worker, notification_worker
  /tasks: scheduled_reports, usage_aggregator, exporter_health
  /templates/reports: base.html, weekly_summary.html, top_talkers.html, bandwidth.html
  /migrations, /tests (unit, integration), main.py, Dockerfile, docker-compose.yml, requirements.txt, .env.example
```

### Config (config.py)
`pydantic-settings` from ENV. No secret defaults.
Groups: App (Name, Env, Secret, Debug, Hosts, Prefix), Postgres (URL, Pool), ClickHouse (Host, Port, User, Pass, DB, Pool), Redpanda (Bootstrap, Groups, Topics: flows.raw, reports, alerts, audit), MinIO (Endpoint, Keys, Bucket, Secure, Expiry), Stripe (Keys, Webhook, PriceIDs), OIDC (Issuer, Audience, JWKS), RateLimits (Ingest, Query), Retention (Hobby: 7d, Starter: 30d, Pro/MSP: 90d).

### Database Models (SQLAlchemy 2.0 Async)
- **Tenant:** id(UUID), name, slug(unique), plan(hobby|starter|pro|msp), status(active|suspended|cancelled), stripe_ids, retention_days, is_msp, parent_tenant_id. Rel: users, exporters, api_keys, alert_rules, report_jobs, notification_channels.
- **User:** id, tenant_id, email, oidc_sub, role(owner|admin|viewer), is_active, last_login.
- **Exporter:** id, tenant_id, name, ip, type(v5|v9|ipfix|sflow), status(active|inactive|never_seen), last_seen, stats.
- **APIKey:** id, tenant_id, name, hash, prefix(8), scopes(ingest|read|admin), last_used, expires, is_active.
- **ReportJob:** id, tenant_id, type(weekly|top_talkers|bandwidth|proto|custom), format(pdf|csv), status(pending|processing|complete|failed), range(from/to), minio_path, error, requested_by, scheduled.
- **AlertRule:** id, tenant_id, name, metric(bandwidth_bps/pps, new_ip, top_talker, proto_anomaly, exporter_down), threshold, window(min), severity(info|warn|crit), is_active, channel_ids, exporter_id.
- **AlertEvent:** id, tenant_id, rule_id, metric, value, threshold, severity, triggered_at, resolved_at, notified(bool).
- **NotificationChannel:** id, tenant_id, name, type(slack|teams|webhook|email), config(JSONB, encrypted), is_active.
- **AuditLog:** id, tenant_id, user_id, action, res_type, res_id, metadata, ip, ua.
- **UsageRecord:** id, tenant_id, period(start/end), bytes/gb_ingested, exporter_count, flows_ingested.

### ClickHouse Schema
- **netflow.flows:** `MergeTree` (tenant_id, exporter_id, timestamp, src/dst_ip, src/dst_port, proto, bytes, packets, asn_src/dst, geo_src/dst, direction). Partition by (tenant, month). Order by (tenant, time, ips). TTL 90d.
- **Materialized Views:** `flows_hourly`, `flows_daily`, `top_talkers_hourly`. `SummingMergeTree`. Group by tenant, exporter, time, proto/ip.

### API Routes
- **/auth:** POST `/token` (OIDC swap), `/refresh`, `/api-keys` (CRUD, owner/admin).
- **/tenants:** GET `/me` (detail), PATCH `/me`, GET `/me/usage`, GET/POST `/me/sub-tenants` (MSP only, `X-Tenant-Context` header support).
- **/users:** GET `/` (list), POST `/invite`, PATCH `/{id}`, DELETE `/{id}` (owner only).
- **/exporters:** GET/POST (CRUD), PATCH/DELETE `/{id}`, GET `/{id}` (detail + stats).
- **/flows:** (JWT/API-Key, tenant-scoped, params: from, to, exporter_id).
  - GET `/summary`, `/top-talkers`, `/conversations`, `/bandwidth`, `/protocols`, `/ports`, `/geo`, `/asn`, `/raw` (Starter+ plan, aggressive rate limit).
- **/reports:** POST (create job), GET (list), GET `/{id}` (status), GET `/{id}/download` (MinIO presigned), DELETE.
- **/alerts:** GET/POST `/rules` (CRUD), PATCH/DELETE `/rules/{id}`, GET `/events` (paginated), GET `/events/{id}`.
- **/webhooks:** GET/POST/PATCH/DELETE (CRUD), POST `/{id}/test`.
- **/billing:** GET `/subscription`, `/usage`, POST `/portal` (Stripe), POST `/webhook` (Stripe lifecycle: updated, deleted, payment_failed/succeeded).
- **/audit:** GET `/` (Starter+ plan).

### Workers
- **ClickHouse Consumer:** Redpanda `netflow.raw` -> Validate/Enrich (Geo/ASN/Proto) -> Batch Insert (1k rows/5s) -> Update PG stats. At-least-once.
- **Report Worker:** Redpanda `netflow.reports` -> Update PG "processing" -> ClickHouse query -> Render Jinja2 -> WeasyPrint (PDF/CSV) -> MinIO -> Update PG "complete".
- **Alert Worker:** k8s CronJob (1m) -> Eval Rules vs ClickHouse (sum bytes/pkts, etc.) -> Trigger: Insert PG AlertEvent + Publish `netflow.alerts`. Rate limited by window.
- **Notification Worker:** Redpanda `netflow.alerts` -> Load Rule/Channels -> Send (Slack, Teams, Webhook w/ HMAC, Email) -> Update PG `notification_sent`. 3 retries.

### Middleware / Core
1. **RequestID:** Generate UUID, X-Request-ID header, logs.
2. **StructuredLogging:** Method, path, status, duration, IDs via `structlog`.
3. **Auth:** JWT (OIDC JWKS) or X-API-Key (bcrypt hash). Attach tenant/user/scopes.
4. **TenantContext:** Resolve tenant. MSP sub-tenant override via `X-Tenant-Context`.
5. **RateLimit:** `slowapi` per-tenant (Query/Ingest limits).
6. **SuspendedTenant:** 402 if tenant.status == "suspended".
7. **Security:** Roles (owner, admin, viewer). Scopes (ingest, read, admin). Fernet encryption for secrets.

### Wrappers
- **ClickHouse:** Enforce `tenant_id` scoping at wrapper level. Parameterized queries. Helpers for summary, talkers, bandwidth (auto-MV selection), alerts.
- **Common:** `APIResponse[T]` {data, meta}, `ErrorResponse` {error, meta}. Meta includes request_id, tenant_id, timing, pagination.

### Deployment
- **Health:** `/healthz` (liveness), `/readyz` (readiness: check PG, ClickHouse).
- **Docker:** Multi-stage builds for API and Workers. 
- **Compose:** API, Workers (clickhouse-consumer, report, alert, notification), PG 16, ClickHouse, Redpanda, MinIO.
- **Requirements:** FastAPI, Uvicorn, SQLAlchemy, asyncpg, alembic, aiokafka, clickhouse-connect, minio, stripe, jose, pydantic-settings, weasyprint, jinja2, slowapi, bcrypt, structlog, geoip2, pyasn.

### Quality / Testing
Async throughout. Pydantic v2. Alembic migrations (no raw DDL). Structlog JSON. OpenAPI `/docs` (non-prod only). DI via `Depends`. Graceful SIGTERM. Pytest fixtures (isolated DB, mocks for CH/MinIO/Redpanda). Coverage: auth, billing, params, alerts.
FlutterFlow can use `/openapi.json` for client gen.