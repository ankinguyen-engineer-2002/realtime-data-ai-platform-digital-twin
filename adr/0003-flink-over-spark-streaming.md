# ADR-0003: Use Flink for stream processing

## Status

Accepted

## Date

2026-05-20

## Context

We need a stream processor that demonstrates:
- True event-time processing with watermarks
- Stateful operations (joins, sessionization)
- Exactly-once semantics with checkpoint/savepoint
- Backpressure visibility
- Late-event handling

…and runs in our DSX Air RAM budget.

## Decision

Use **Apache Flink 1.18+ in session mode** with 1 JobManager + 1-2 TaskManagers.

- Jobs written in **Java/Scala for production-grade jobs** (lakehouse_sink, payment_risk) and **PyFlink for funnel** (to demonstrate both APIs).
- State backend: **RocksDB**, checkpoints to MinIO S3.
- Iceberg writes use the official `flink-iceberg` connector.

## Alternatives considered

- **Spark Structured Streaming** — familiar, batch-streaming continuity.
  - Attractive: same engine as batch; one less tool.
  - Rejected: micro-batch semantics are weaker than Flink's true streaming; event-time + watermark story is less crisp; RAM footprint heavier.

- **Kafka Streams** — JVM library, no separate cluster.
  - Attractive: very lightweight; just an app.
  - Rejected: limited to JVM, weaker windowing UX, no equivalent to Flink CEP, less of a "platform" story.

- **Materialize / RisingWave** — SQL-only streaming.
  - Attractive: declarative, simple.
  - Rejected: less to demonstrate; harder to show watermark/checkpoint internals.

- **ksqlDB** — Kafka-native SQL streaming.
  - Rejected: weaker stateful joins, ecosystem narrower than Flink.

## Consequences

### Positive
- Strongest event-time / watermark / state story in OSS.
- Iceberg streaming sink is first-class.
- Backpressure + checkpoint metrics are observable, perfect for the chaos catalog.

### Negative
- Heaviest single service in the stack (12 GB RAM allocated to `node-stream`).
- JVM tuning is a learning tax.

### Neutral
- PyFlink coverage is uneven for newer features; pick wisely per job.

## References

- [Flink documentation](https://flink.apache.org/)
- [Flink + Iceberg connector](https://iceberg.apache.org/docs/latest/flink/)
- [`docs/08-stream-processing.md`](../docs/08-stream-processing.md)
