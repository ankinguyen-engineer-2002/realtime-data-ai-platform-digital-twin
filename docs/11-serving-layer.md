# 11 — Serving layer

## Composition

| Service | Role |
|---|---|
| ClickHouse | realtime OLAP — funnel, risk, inventory |
| Redis | online features, hot path lookup |
| FastAPI | edge HTTP API, OpenAPI docs |
| Trino | ad-hoc / federated SQL |
| Grafana / Superset | dashboards |

## Latency targets (lab)

| Endpoint | p95 |
|---|---:|
| `GET /risk/customer/{id}` (Redis hit) | < 20 ms |
| `GET /risk/customer/{id}` (cache miss → ClickHouse) | < 300 ms |
| `GET /metrics/orders/realtime` | < 500 ms |
| `GET /orders/{id}` (lakehouse) | < 2 s |

## FastAPI structure

```text
serving/fastapi/
  main.py
  deps/
    clickhouse.py        # client pool
    redis.py             # client pool
    trino.py             # client pool
    auth.py              # JWT stub
  routes/
    health.py
    metrics_orders.py
    metrics_payments.py
    metrics_inventory.py
    risk.py
    orders.py
    rag.py               # delegated to ai/ in Phase 10
  schemas/               # pydantic response models
  middleware/
    otel.py              # opentelemetry tracing
    log.py               # structured logging
```

## ClickHouse tables

```sql
CREATE TABLE realtime_funnel (
    event_time      DateTime,
    session_id      String,
    page_views      UInt32,
    add_to_carts    UInt32,
    checkouts       UInt32,
    orders          UInt32
)
ENGINE = ReplacingMergeTree(event_time)
PARTITION BY toDate(event_time)
ORDER BY (toStartOfHour(event_time), session_id);

CREATE TABLE realtime_funnel_kafka (...) ENGINE = Kafka(...);
CREATE MATERIALIZED VIEW mv_funnel TO realtime_funnel
AS SELECT ... FROM realtime_funnel_kafka;
```

Full DDL in [`serving/clickhouse/ddl.sql`](../serving/clickhouse/ddl.sql).

## Redis schema

```text
risk:{customer_id}            -> JSON score (TTL 60s)
stock:{sku}                   -> quantity (TTL 30s)
session:{session_id}          -> session aggregates (TTL 30m)
```

## Grafana dashboards (Phase 9)

- Order Funnel
- Payment Success / Failure
- Fraud Risk Alerts
- Inventory Stockout
- Delivery SLA
- Consumer Lag (per topic)
- Pipeline Freshness
- Data Quality scoreboard
- DLQ live tail

Dashboards saved as JSON in `observability/grafana/dashboards/`.
