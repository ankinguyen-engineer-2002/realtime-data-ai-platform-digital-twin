# 14 — Security boundary

> Lab-grade demo, not certified. The point is to show *patterns*, not pass an audit.

## Layered model

```mermaid
flowchart TB
    classDef ext fill:#5f1e1e,stroke:#ff7f7f,color:#fff
    classDef edge fill:#5f3a1e,stroke:#ffb87f,color:#fff
    classDef int fill:#1e3a5f,stroke:#7fb8ff,color:#fff
    classDef sec fill:#3a3a3a,stroke:#aaa,color:#fff

    NET["Internet (your laptop)"]:::ext
    BAST["oob-mgmt-server"]:::edge
    GR["Grafana :3000<br/>basic auth + reverse proxy"]:::edge
    API["FastAPI :8000<br/>JWT (RS256)"]:::edge
    MQ["Marquez UI :3001<br/>basic auth"]:::edge

    INT_RP["Redpanda :9092<br/>SASL/SCRAM-SHA-256<br/>ACLs per topic"]:::int
    INT_MIN["MinIO :9000<br/>access key per service"]:::int
    INT_PG["Postgres :5432<br/>md5 + role-per-service"]:::int
    INT_CH["ClickHouse :8123<br/>user/pass + RBAC profile"]:::int
    INT_TR["Trino :8080<br/>group-based catalog access"]:::int

    NET --> BAST
    NET --> GR
    NET --> API
    NET --> MQ
    BAST --> INT_RP
    GR --> INT_CH
    API --> INT_RP
    API --> INT_MIN
    API --> INT_CH
    API --> INT_TR

    SOPS["SOPS + age<br/>encrypted .env"]:::sec
    SOPS -. provides creds .-> INT_RP
    SOPS -. provides creds .-> INT_MIN
    SOPS -. provides creds .-> INT_PG
```

## Per-component controls

| Component | Authn | Authz | Secrets |
|---|---|---|---|
| Redpanda | SASL/SCRAM-SHA-256 | ACLs per topic per principal | SOPS |
| MinIO | access key | per-bucket policy JSON | SOPS |
| Postgres | md5 + cert option | role per service | SOPS |
| ClickHouse | user/pass | RBAC profile (`profiles.xml`) | SOPS |
| Trino | password file | group-based catalog rules | SOPS |
| FastAPI | JWT (RS256) | route-level scopes | SOPS |
| Dagster | basic auth + RBAC | role-per-tenant | SOPS |
| Grafana | basic auth + viewer/editor | per-folder | SOPS |

## Secrets management

`.env` is **never** committed in plaintext. Stored as `.env.sops.yaml` (SOPS + age). To decrypt:

```bash
sops -d platform/env/.env.sops.yaml > platform/env/.env
```

Public age recipient lives at `infra/secrets/age.pub`. Private key lives in 1Password / OS keychain.

## PII handling

Concrete tokenization flow documented in [`docs/13-governance-lineage.md`](./13-governance-lineage.md). Raw PAN never lands in any lakehouse table or DLQ.

## Audit trail

- Loki ingests `service=` logs from every container.
- `dagster-audit.log` ships to Loki.
- Marquez UI shows who ran what when (lineage = audit complement).

## What's intentionally *not* in scope

- Real RBAC for a multi-tenant platform.
- Real disaster recovery on credential compromise.
- mTLS between every service (Redpanda mTLS planned for Phase 10 stretch).
- Compliance certification.

See also [`docs/99-limitations-and-honesty.md`](./99-limitations-and-honesty.md).
