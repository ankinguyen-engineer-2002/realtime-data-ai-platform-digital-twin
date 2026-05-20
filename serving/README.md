# serving/

The user-facing edge: ClickHouse + Redis + FastAPI, all behind Grafana.

## Components

```
serving/
  fastapi/
    main.py
    deps/                    # client pools for CH, Redis, Trino
    routes/                  # endpoints
    middleware/              # OTEL, structured logging
  clickhouse/
    ddl.sql                  # tables + Kafka engine + materialized views
    profiles.xml             # RBAC profiles
    config.xml               # cluster + storage config
  redis/
    redis.conf               # eviction, maxmemory
```

## Endpoints (Phase 8)

```
GET /health
GET /metrics/orders/realtime
GET /metrics/payments/realtime
GET /metrics/inventory/realtime
GET /risk/customer/{customer_id}
GET /orders/{order_id}
GET /rag/query?q=...          # delegated to ai/ in Phase 10
```

## OpenAPI

FastAPI exposes `/docs` (Swagger) and `/openapi.json`. Documented in [`docs/11-serving-layer.md`](../docs/11-serving-layer.md).

## Latency budget

| Endpoint | p95 target | actual (lab) |
|---|---:|---:|
| `/risk/customer` (Redis hit) | 20 ms | tbd |
| `/risk/customer` (CH miss path) | 300 ms | tbd |
| `/metrics/*/realtime` | 500 ms | tbd |
| `/orders/{id}` | 2 s | tbd |
