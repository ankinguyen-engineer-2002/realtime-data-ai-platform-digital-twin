# Documentation Index

> Per-layer design docs. Read top-down for first encounter; jump in by topic for deep dives.

## Foundations

- [00 — Executive summary](./00-executive-summary.md)
- [01 — DSX Air foundations](./01-dsx-air-foundations.md)
- [02 — Architecture layers (bottom-up)](./02-architecture-layers.md)

## Infrastructure

- [03 — Network fabric design (EVPN/VXLAN)](./03-network-fabric-design.md)
- [04 — Compute platform (nodes + Docker + Ansible)](./04-compute-platform.md)
- [05 — Storage substrate](./05-storage-layer.md)

## Data plane

- [06 — Event backbone (Redpanda + Schema Registry + DLQ)](./06-event-backbone.md)
- [07 — CDC design (Postgres + Debezium)](./07-cdc-design.md)
- [08 — Stream processing (Flink jobs)](./08-stream-processing.md)
- [09 — Lakehouse design (Iceberg + Trino)](./09-lakehouse-design.md)
- [10 — Batch orchestration (Dagster + GE)](./10-batch-orchestration.md)
- [11 — Serving layer (ClickHouse + Redis + FastAPI)](./11-serving-layer.md)

## Cross-cutting

- [12 — Observability + SLO](./12-observability-slo.md)
- [13 — Governance + lineage (OpenLineage + Marquez)](./13-governance-lineage.md)
- [14 — Security boundary (Zero-trust patterns)](./14-security-zero-trust.md)
- [15 — AI / RAG layer (Qdrant + evaluation)](./15-ai-rag-layer.md)

## Operations

- [16 — Failure & chaos catalog](./16-failure-chaos-catalog.md)
- [17 — Network failure storyline ★ the differentiator](./17-network-failure-storyline.md)
- [18 — Benchmark strategy](./18-benchmark-strategy.md)
- [19 — Cost & budget guard rails](./19-cost-budget-guardrails.md)
- [20 — Exit & portability plan](./20-exit-portability-plan.md)

## Honesty

- [99 — Limitations and honesty statement](./99-limitations-and-honesty.md)
