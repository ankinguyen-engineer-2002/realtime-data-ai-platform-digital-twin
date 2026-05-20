# 06 — Event backbone

> Redpanda topics, partitions, retention, Schema Registry, DLQ.

## Topic catalog

| Topic | Type | Partitions | Retention | Key | Schema | Producer |
|---|---|---:|---|---|---|---|
| `cdc.customers.v1` | compacted | 6 | infinite | customer_id | JSON | Debezium |
| `cdc.products.v1` | compacted | 6 | infinite | sku | JSON | Debezium |
| `cdc.inventory.v1` | compacted | 6 | infinite | sku | JSON | Debezium |
| `cdc.orders.v1` | log | 12 | 30d | order_id | JSON | Debezium |
| `ecom.page_view.v1` | log | 12 | 7d | session_id | JSON | clickstream_producer |
| `ecom.add_to_cart.v1` | log | 6 | 7d | session_id | JSON | clickstream_producer |
| `ecom.checkout_started.v1` | log | 6 | 7d | session_id | JSON | clickstream_producer |
| `payment.authorized.v1` | log | 6 | 30d | order_id | JSON | payment_producer |
| `payment.failed.v1` | log | 6 | 30d | order_id | JSON | payment_producer |
| `fraud.risk_signal.v1` | log | 6 | 7d | customer_id | JSON | fraud_signal_producer |
| `inventory.stock_changed.v1` | log | 6 | 7d | sku | JSON | inventory_producer |
| `shipment.created.v1` | log | 6 | 7d | shipment_id | JSON | inventory_producer |
| `shipment.delivery_updated.v1` | log | 6 | 7d | shipment_id | JSON | inventory_producer |
| `returns.return_requested.v1` | log | 6 | 30d | return_id | JSON | inventory_producer |
| `returns.refund_issued.v1` | log | 6 | 30d | return_id | JSON | payment_producer |
| `dlq.invalid_events.v1` | log | 3 | 7d | source_topic | JSON | Flink (rejection sink) |

## Producer guarantees

- All producers are **idempotent** (`enable.idempotence=true`).
- Compression: `lz4`.
- Acks: `all`.
- Bad events produced when `--invalid` flag set carry a `_synthetic_label` field for downstream assertion.

## DLQ design

Every Flink job has a side output to `dlq.invalid_events.v1` with payload:

```json
{
  "source_topic": "payment.authorized.v1",
  "source_offset": 1234567,
  "source_partition": 3,
  "rejection_reason": "schema_validation_failed",
  "raw_payload_b64": "...",
  "rejected_at": "2026-05-20T10:15:00Z",
  "consumer_group": "flink-payment-risk"
}
```

Replay flow:

```mermaid
flowchart LR
    DLQ["dlq.invalid_events.v1"] --> INSP["chaos/data/inspect_dlq.py"]
    INSP --> FIX["fix schema / patch event"]
    FIX --> REPLAY["chaos/data/replay_dlq.py"]
    REPLAY --> RP["correct topic"]
```

## Schema Registry usage

JSON Schema bound 1:1 with topic. Compatibility mode: **BACKWARD**. Producers fetch schema on startup and validate before send (in clean mode).

Schemas live at [`schemas/`](../schemas/) and are validated by CI (`.github/workflows/validate-schemas.yml`).
