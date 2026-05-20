# Architecture Decision Records

> Every significant architecture decision in this project is recorded here. The point isn't to document what we built — the point is to document what we **didn't** build, and why.

## Index

| # | Decision | Status |
|---|---|---|
| [0001](./0001-dsx-air-as-network-fabric-twin.md) | Position DSX Air as a network-fabric twin, not a generic VM host | Accepted |
| [0002](./0002-redpanda-over-kafka.md) | Use Redpanda as event backbone (over Kafka, NATS) | Accepted |
| [0003](./0003-flink-over-spark-streaming.md) | Use Flink for stream processing (over Spark, Kafka Streams) | Accepted |
| [0004](./0004-iceberg-over-delta-paimon.md) | Use Iceberg as lakehouse table format (over Delta, Paimon, Hudi) | Accepted |
| [0005](./0005-dagster-over-airflow.md) | Use Dagster for batch orchestration (over Airflow, Prefect) | Accepted |
| [0006](./0006-marquez-over-datahub.md) | Use OpenLineage + Marquez for lineage (over DataHub, OpenMetadata) | Accepted |
| [0007](./0007-clickhouse-for-realtime-serving.md) | Use ClickHouse for realtime OLAP (over Pinot, Druid) | Accepted |
| [0008](./0008-time-multiplex-sessions.md) | Time-multiplex three sessions instead of running full stack | Accepted |
| [0009](./0009-mvp-first-then-extend.md) | Ship a 6-week MVP before extending to full scope | Accepted |
| [0010](./0010-synthetic-data-strategy.md) | Design synthetic data with dirty/late/duplicate built in | Accepted |

## Template

See [`ADR-template.md`](./ADR-template.md).
