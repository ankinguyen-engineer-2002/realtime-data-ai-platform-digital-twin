# Changelog

All notable changes to this project are documented here. Format inspired by
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- Initial repository skeleton, ADRs, layered docs, roadmap, network-failure storyline.

## [v0.1.0] — 2026-05-20 — Blueprint v2

### Added
- README with full architectural Mermaid diagram set
- ARCHITECTURE deep-dive doc
- ROADMAP with MVP-first 6-week plan
- 10 ADRs covering all stack choices
- Per-layer docs (00-99)
- Network failure storyline as the differentiator
- Cost budget guardrails + `budget_guard.py`
- Chaos catalog (service / data / network)
- Skeletons for producers, streaming, batch, serving, AI

### Decided
- DSX Air positioned as network-fabric twin, not generic VM host (ADR-0001)
- Redpanda over Kafka (ADR-0002)
- Flink over Spark Streaming (ADR-0003)
- Iceberg over Delta/Paimon (ADR-0004)
- Dagster over Airflow (ADR-0005)
- Marquez over DataHub (ADR-0006)
- ClickHouse over Druid/Pinot (ADR-0007)
- Time-multiplex sessions (ADR-0008)
- MVP-first then extend (ADR-0009)
- Synthetic data with dirty/late/duplicate built-in (ADR-0010)
