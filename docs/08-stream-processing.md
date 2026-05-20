# 08 — Stream processing (Flink)

Four jobs. Each owns one concept worth demonstrating.

## Cluster shape

- 1 JobManager + 1-2 TaskManagers on `node-stream`.
- State backend: RocksDB.
- Checkpoint store: MinIO `flink-checkpoints/` bucket.
- Checkpoint interval: 60s, minPauseBetween: 30s, maxConcurrent: 1.
- Restart strategy: `failure-rate`, 3 failures in 10 min → fail.

## Jobs

### Job 1 — `order_funnel_job`

**Concept:** event-time windows + sessionization + late-event handling.

```mermaid
flowchart LR
    PV["ecom.page_view.v1"] --> S
    AC["ecom.add_to_cart.v1"] --> S
    CO["ecom.checkout_started.v1"] --> S
    OC["cdc.orders.v1<br/>(op=c)"] --> S

    S["KeyBy(session_id)<br/>Session window 30m gap<br/>allowedLateness 30m"]

    S --> AGG["Aggregator:<br/>views, carts, checkouts, orders"]
    AGG --> CH["clickhouse.realtime_funnel"]
    AGG -. late side .-> LATE["clickhouse.realtime_funnel_late"]
```

### Job 2 — `payment_risk_job`

**Concept:** stateful streaming join + online features + low-latency decision.

```mermaid
flowchart LR
    PA["payment.authorized.v1"] --> J
    PF["payment.failed.v1"] --> J
    FR["fraud.risk_signal.v1"] --> J
    CU["cdc.customers.v1<br/>(broadcast state)"] --> J

    J["KeyBy(customer_id)<br/>state: rolling counters,<br/>velocity, deviation"]

    J --> RS["clickhouse.transaction_risk_score"]
    J --> RD["redis.online_risk:{customer_id} (TTL 60s)"]
    J --> AL["alerts.high_risk_transaction"]
```

### Job 3 — `inventory_availability_job`

**Concept:** CDC + stream join, compacted topic semantics.

```mermaid
flowchart LR
    INV["cdc.inventory.v1<br/>(compacted state)"] --> J
    ORD["cdc.orders.v1"] --> J
    SH["shipment.created.v1"] --> J
    RR["returns.return_requested.v1"] --> J

    J["KeyBy(sku)<br/>delta apply on inventory"]
    J --> CH["clickhouse.inventory_availability"]
    J --> RDS["redis.stock:{sku}"]
```

### Job 4 — `lakehouse_sink_job`

**Concept:** exactly-once write to Iceberg (2PC), schema evolution.

```mermaid
flowchart LR
    T1["all *.v1 topics"] --> S["sink select"]
    S --> ENRICH["enrich + tokenize PII"]
    ENRICH --> ICE["IcebergSink<br/>bronze.events_*"]
    ENRICH -. invalid .-> DLQ["dlq.invalid_events.v1"]
```

## Watermark policy

- Event time = `event_time` field from payload.
- Bounded out-of-orderness: 5 minutes.
- Allowed lateness: 30 minutes (then to side output).

## Metrics exported

- `flink_jobmanager_job_uptime`
- `flink_taskmanager_job_task_operator_records_in`
- `flink_jobmanager_job_lastCheckpointDuration`
- `flink_jobmanager_job_numRestarts`
- `flink_taskmanager_job_task_operator_backpressure_ratio`

All scraped by Prometheus on `node-obs`. Grafana panels live in `observability/grafana/dashboards/flink.json`.
