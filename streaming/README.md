# streaming/

Flink jobs. See [`docs/08-stream-processing.md`](../docs/08-stream-processing.md) for the design.

## Jobs

| Folder | Language | Concept showcase |
|---|---|---|
| `flink/order_funnel_job/` | PyFlink | event-time windows, sessionization, late events |
| `flink/payment_risk_job/` | Java | stateful join, broadcast state, online features |
| `flink/inventory_availability_job/` | Java | CDC + stream join, compacted-topic semantics |
| `flink/lakehouse_sink_job/` | Java | exactly-once Iceberg sink (2PC) |

## Common config

All jobs:
- Checkpoint to `s3://flink-checkpoints/` (MinIO).
- State backend: RocksDB.
- Restart strategy: `failure-rate`, 3 in 10 min.
- OpenLineage emitter enabled.
- Prometheus metrics exporter on `:9249`.

## Building

```bash
cd streaming/flink/payment_risk_job
mvn package
# job jar lands in target/payment_risk_job-1.0.jar
```

For PyFlink jobs:
```bash
cd streaming/flink/order_funnel_job
pip install -r requirements.txt
```

## Deploying to the Flink session cluster

```bash
flink run \
  --target remote \
  --jobmanager node-stream:8081 \
  target/payment_risk_job-1.0.jar
```
