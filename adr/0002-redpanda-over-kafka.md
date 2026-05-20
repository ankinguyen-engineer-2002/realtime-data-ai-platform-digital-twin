# ADR-0002: Use Redpanda as the event backbone

## Status

Accepted

## Date

2026-05-20

## Context

We need a durable, replayable event backbone supporting topics, partitions, consumer groups, retention, compacted topics, DLQ, and Kafka-protocol compatibility (so Debezium, Flink, ClickHouse Kafka engine all just work).

DSX Air node sizing constrains us. A 3-broker Kafka cluster with ZooKeeper or KRaft consumes ~12 GB RAM minimum to be stable. We have ~50-60 GiB total ceiling across all services.

## Decision

Use **Redpanda Community Edition** as the event backbone, deployed as a **single broker** for MVP and **3-node cluster** for the burst/failure test profile only.

- Kafka API compatibility means clients are unaware (Debezium / Flink Kafka connector / etc.).
- Single binary, no JVM, no ZooKeeper → ~1.5 GB RAM per broker.
- Schema Registry is the Redpanda built-in (`rpk registry`).

## Alternatives considered

- **Apache Kafka (KRaft mode)** — the industry default.
  - Attractive: highest portability, real production parallel.
  - Rejected: JVM + 3-broker quorum eats RAM we need for Flink/ClickHouse.

- **NATS JetStream** — lightweight, modern.
  - Attractive: very small footprint, native streaming.
  - Rejected: ecosystem (Debezium, Flink connectors, ClickHouse engine) is weaker; portfolio less recognizable.

- **RabbitMQ Streams** — newer streams feature.
  - Rejected: not Kafka-protocol; tooling story is harder.

- **Redis Streams** — for the lab feel.
  - Rejected: not durable enough at the scale we want to demonstrate; consumer group semantics differ.

## Consequences

### Positive
- ~10× less RAM per broker vs JVM Kafka.
- Kafka-compatible: portfolio reads as "Kafka skill" to most reviewers.
- Faster startup → shorter chaos recovery cycles.

### Negative
- Community Edition lacks tiered storage / multi-region. We don't need them at lab scale.
- Some Kafka admin features differ slightly; document any divergence in `docs/06-event-backbone.md`.

### Neutral
- We will run a 3-broker cluster *for one burst benchmark scenario* to show we know how to scale; otherwise single broker.

## References

- [Redpanda vs Kafka — official comparison](https://redpanda.com/compare/redpanda-vs-kafka)
- [Redpanda Schema Registry](https://docs.redpanda.com/current/manage/schema-reg/schema-reg-overview/)
- [`docs/06-event-backbone.md`](../docs/06-event-backbone.md)
