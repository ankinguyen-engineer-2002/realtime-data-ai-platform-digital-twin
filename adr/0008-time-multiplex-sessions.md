# ADR-0008: Time-multiplex three sessions instead of running the full stack

## Status

Accepted

## Date

2026-05-20

## Context

DSX Air trial caps us at 60 vCPU / 60 GiB concurrent. The full data-platform vision (Redpanda + Postgres + Debezium + Flink + MinIO + Iceberg catalog + Trino + ClickHouse + Redis + FastAPI + Dagster + GE + Prometheus + Grafana + Loki + Marquez + Qdrant) needs ~70 vCPU and ~80 GiB if every service runs comfortably.

Squeezing 4 services per node (as a naive "resource-constrained profile" would) breaks failure-isolation: if one service OOMs the node, you lose multiple unrelated components. That **defeats the chaos catalog** because failures cascade in ways the platform wouldn't in production.

## Decision

We split the platform into **three time-multiplexed sessions**, each focused on a coherent subset. Only one session runs at a time. State persists in MinIO between sessions; Redpanda/Postgres are present in all sessions because they're the data substrate.

| Session | Focus | Active services |
|---|---|---|
| **Session A** — Backbone + Stream | Event flow, CDC, Flink jobs, lakehouse writes | Redpanda, Postgres+Debezium, Flink, MinIO+Iceberg catalog, Prometheus+Grafana |
| **Session B** — Batch + Serve | Dagster, GE, gold tables, ClickHouse, Redis, FastAPI | Redpanda, Postgres, MinIO+Iceberg, Dagster+GE, ClickHouse+Redis+FastAPI, Trino, Prometheus+Grafana |
| **Session C** — AI + Governance | RAG, lineage, embeddings, evaluation | Redpanda, MinIO, ClickHouse, FastAPI, Qdrant, Marquez, Prometheus+Grafana |

Switching sessions:
1. Save checkpoint of current sim.
2. Stop sim → release credits.
3. Apply new compose file (per-session `docker-compose.session-X.yml`).
4. Resume sim or create new.

## Alternatives considered

- **Run everything on one big simulation** — naive approach.
  - Rejected: exceeds RAM ceiling; failure-isolation broken; credit burn is 50%+ higher per learning hour.

- **One-service-per-node, all on at once** — the diagram-perfect approach.
  - Rejected: would need 10+ nodes simultaneously; not enough headroom for burst tests.

- **Use Kubernetes to bin-pack** — k3s on each node, schedule pods.
  - Attractive: a single K8s skill demo.
  - Rejected: K8s on simulation nodes adds 2-3 GB overhead per node; pod scheduling masks failure boundaries we want to observe.

## Consequences

### Positive
- Each service gets enough RAM to behave realistically.
- Failure isolation matches a "1 service = 1 host" production pattern.
- Compute hours stretch ~2× further.
- The session model itself is a portfolio talking point ("how I planned a 6-month lab on a 1-year credit budget").

### Negative
- Switching sessions takes ~5 minutes (start/stop sim, re-deploy compose).
- Some integration tests need to be re-run across sessions; document which.
- Demo screencast must show all 3 sessions or be split into 3 short clips.

### Neutral
- A "Session D — Full burst" runs all services briefly during the benchmark phase, intentionally pushing the ceiling for ~30 min to record numbers.

## References

- [`docs/19-cost-budget-guardrails.md`](../docs/19-cost-budget-guardrails.md)
- [`platform/`](../platform/) — per-session compose files
