# 00 — Executive summary

A one-page version of the project for anyone in a hurry.

## Pitch

A production-inspired real-time data + AI platform lab, built on NVIDIA DSX Air, where the **network fabric itself** is part of the chaos experiments. End-to-end: synthetic e-commerce + payment events flow through Postgres CDC → Redpanda → Flink → Iceberg lakehouse → ClickHouse + Redis + FastAPI, with Dagster batch reconciliation, OpenLineage governance, Qdrant + RAG service, and full observability.

## What's different

| Most data-platform demos | This project |
|---|---|
| Run on Docker Desktop | Run on a simulated EVPN/VXLAN fabric |
| `docker stop kafka` is the chaos | VXLAN flap, leaf-down, EVPN reroute are the chaos |
| Half-baked AI bolt-on | RAG with hybrid search + RAGAS evaluation |
| Single big diagram | 10 ADRs documenting what we chose not to build |
| 12 weeks → all-or-nothing | 6-week MVP, then extend |

## Stack at a glance

| Slot | Choice |
|---|---|
| Event backbone | Redpanda |
| CDC | Debezium → Redpanda |
| Stream processing | Flink |
| Lakehouse | Iceberg on MinIO + Trino |
| Batch | Dagster + PyIceberg + Great Expectations |
| Realtime OLAP | ClickHouse |
| Online cache | Redis |
| API | FastAPI |
| Vector DB | Qdrant |
| Lineage | OpenLineage + Marquez |
| Observability | Prometheus + Grafana + Loki + OTEL |

## Read next

- [`README.md`](../README.md) — hero diagrams
- [`ARCHITECTURE.md`](../ARCHITECTURE.md) — deep dive
- [`ROADMAP.md`](../ROADMAP.md) — execution plan
- [`docs/17-network-failure-storyline.md`](./17-network-failure-storyline.md) — the differentiator
