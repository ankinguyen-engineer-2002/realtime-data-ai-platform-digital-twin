# ADR-0004: Use Iceberg as the lakehouse table format

## Status

Accepted

## Date

2026-05-20

## Context

We need a lakehouse table format on top of MinIO supporting:
- ACID writes with snapshot isolation
- Schema evolution + partition evolution
- Time travel
- Streaming writes (from Flink) + batch writes (from Dagster)
- Multi-engine reads (Trino, Flink, Spark, PyIceberg)

## Decision

Use **Apache Iceberg 1.4+** with **REST catalog** backed by Postgres metastore.

- Storage: MinIO via S3 protocol.
- Catalog: Iceberg REST (lightweight, Python `pyiceberg` + Flink + Trino all support it).
- Writers: Flink (streaming, exactly-once via 2-phase commit), Dagster + PyIceberg (batch).
- Readers: Trino (federation + BI), PyIceberg (Dagster / notebooks).

## Alternatives considered

- **Delta Lake** — Databricks-originated, very popular.
  - Attractive: huge community, simpler protocol.
  - Rejected: deeper Spark coupling outside Databricks; Flink integration is newer; less "open ecosystem" story; we'd carry Spark just for Delta.

- **Apache Paimon** — streaming-first lakehouse.
  - Attractive: native Flink, fast small-file merging.
  - Rejected: smaller ecosystem; Trino + general-purpose tooling weaker. We considered it as a *secondary* but cut for scope (see ADR-0009).

- **Apache Hudi** — write-optimized for upserts.
  - Attractive: strong upsert/merge story.
  - Rejected: complexity (MoR vs CoW table types) outweighs benefits at lab scale.

- **Plain Parquet on MinIO + Hive metastore** — no lakehouse format.
  - Rejected: doesn't demonstrate schema evolution / time travel / streaming writes.

## Consequences

### Positive
- True engine-agnostic story; multiple compute engines on one table.
- Time travel demo lands well in portfolio.
- Streaming + batch on the same table is provable.

### Negative
- REST catalog adds one more service to keep up.
- Iceberg metadata can grow; periodic expire-snapshots + remove-orphans needed.

### Neutral
- We will compact small files via Dagster nightly job; document in `docs/09-lakehouse-design.md`.

## References

- [Apache Iceberg docs](https://iceberg.apache.org/)
- [Iceberg REST Catalog spec](https://iceberg.apache.org/docs/latest/aws/#iceberg-rest)
- [`docs/09-lakehouse-design.md`](../docs/09-lakehouse-design.md)
