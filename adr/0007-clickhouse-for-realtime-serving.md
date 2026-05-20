# ADR-0007: Use ClickHouse for realtime OLAP serving

## Status

Accepted

## Date

2026-05-20

## Context

The serving layer needs to answer dashboard + API queries with sub-second p95 latency over realtime aggregates (last 24h funnel, last 1h fraud, current inventory). Cardinality is moderate (~10M rows/day), updates are append-mostly via Flink, plus materialized views over Iceberg via S3 engine.

## Decision

Use **ClickHouse 24.x** with:
- **Kafka engine table** consuming directly from Redpanda topics for realtime ingestion.
- **MergeTree tables** as the storage layer.
- **Materialized views** for pre-aggregation.
- **S3 engine** (read-only) to query Iceberg-managed Parquet files in MinIO for historical lookups.

## Alternatives considered

- **Apache Druid** — classic realtime OLAP.
  - Attractive: time-series first-class, segment-based architecture.
  - Rejected: 3+ services minimum (broker, coordinator, historical, indexer, middleManager); RAM-heavy; deployment friction.

- **Apache Pinot** — modern segment-store OLAP.
  - Attractive: low-latency, Kafka-native ingest.
  - Rejected: also 3-4 services; smaller community than ClickHouse; lab demo less impressive than 1-binary ClickHouse.

- **DuckDB** — embedded analytical engine.
  - Attractive: zero ops, fast.
  - Rejected: no multi-user, no streaming ingest, not a serving DB.

- **Postgres + materialized views** — keep it simple.
  - Rejected: cardinality + latency goals exceed Postgres comfort zone.

- **Trino alone** — query Iceberg directly.
  - Rejected: not low-latency enough for dashboard refresh-every-5-sec usage; Trino's role stays as ad-hoc / federated.

## Consequences

### Positive
- Single-binary deploy (or `clickhouse-server` + `clickhouse-keeper`).
- Sub-second queries over 10M-row Kafka stream are realistic.
- Direct Kafka ingestion = one less Flink sink to maintain (for simple aggregates).
- S3 engine reads Iceberg-managed files for "view all history" queries.

### Negative
- Schema design discipline matters (sort keys, partition keys, TTL).
- Kafka engine ingestion is at-least-once; we de-duplicate via `ReplacingMergeTree` or upstream Flink dedup.

### Neutral
- We deliberately *do not* put gold KPI tables in ClickHouse — those live in Iceberg, and a Dagster job publishes daily snapshots to ClickHouse for serving.

## References

- [ClickHouse Kafka engine](https://clickhouse.com/docs/en/engines/table-engines/integrations/kafka)
- [ClickHouse S3 table engine](https://clickhouse.com/docs/en/engines/table-engines/integrations/s3)
- [`docs/11-serving-layer.md`](../docs/11-serving-layer.md)
