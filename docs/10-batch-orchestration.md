# 10 — Batch orchestration (Dagster + GE)

> Why Dagster: see [ADR-0005](../adr/0005-dagster-over-airflow.md).

## Asset graph

```mermaid
flowchart TB
    classDef raw fill:#3a3a3a,stroke:#aaa,color:#fff
    classDef bronze fill:#7f4f1e,stroke:#ffb87f,color:#fff
    classDef silver fill:#5f5f5f,stroke:#ccc,color:#fff
    classDef gold fill:#7f6f1e,stroke:#ffd700,color:#000
    classDef check fill:#5f3a1e,stroke:#ffb87f,color:#fff
    classDef serve fill:#5f3a1e,stroke:#ffd700,color:#fff

    R1["raw.kafka_offsets"]:::raw
    B1["bronze.events_clickstream"]:::bronze
    B2["bronze.events_payment"]:::bronze
    B3["bronze.cdc_orders"]:::bronze

    Q1["GE bronze schema check"]:::check

    S1["silver.fact_clickstream"]:::silver
    S2["silver.fact_payment"]:::silver
    S3["silver.fact_order"]:::silver
    S4["silver.dim_customer_scd2"]:::silver

    Q2["GE silver dedup + range"]:::check

    G1["gold.daily_revenue"]:::gold
    G2["gold.order_funnel_hourly"]:::gold
    G3["gold.payment_success_rate"]:::gold
    G4["gold.fraud_alert_summary"]:::gold

    Q3["GE gold sanity"]:::check
    REC["gold.payment_reconciliation"]:::gold

    CH["ClickHouse publisher"]:::serve

    R1 --> B1
    R1 --> B2
    R1 --> B3
    B1 --> Q1
    B2 --> Q1
    B3 --> Q1
    Q1 --> S1
    Q1 --> S2
    Q1 --> S3
    Q1 --> S4
    S1 --> Q2
    S2 --> Q2
    S3 --> Q2
    S4 --> Q2
    Q2 --> G1
    Q2 --> G2
    Q2 --> G3
    Q2 --> G4
    G1 --> Q3
    G2 --> Q3
    G3 --> Q3
    G4 --> Q3
    Q3 --> REC
    Q3 --> CH
```

## Schedules

| Asset group | Schedule | Trigger |
|---|---|---|
| Bronze (Flink sinks) | continuous | streaming, not Dagster |
| Silver | hourly | sensor on bronze partition arrival |
| Gold | daily 02:00 UTC | cron |
| Reconciliation | daily 03:00 UTC | cron, after gold |
| Maintenance | nightly 04:00 UTC | cron |

## Resources (`batch/dagster/resources.py`)

- `postgres_metastore` — for Dagster's run history
- `minio` — S3 client for MinIO
- `iceberg_catalog` — `pyiceberg.Catalog` instance
- `clickhouse` — for publishers
- `great_expectations` — checkpoint runner

## Great Expectations suites

- `bronze_schema` — column types match contract
- `silver_dedup` — no duplicate `event_id` in window
- `silver_ranges` — amount > 0, currency in {USD, EUR, ...}
- `gold_sanity` — row count > expected_min, freshness < 25h

Suites live at `quality/great_expectations/expectations/`.

## Reconciliation example

```python
# gold.payment_reconciliation
# Compare: stream-derived revenue today vs batch settlement file
discrepancy = abs(stream_revenue - batch_settlement) / batch_settlement
assert discrepancy < 0.005, f"Discrepancy {discrepancy:.4f} exceeds 0.5%"
```

Output table:
```text
event_date | stream_revenue | settlement | discrepancy_pct | status
2026-05-19 | 124318.50      | 124355.00  | 0.029           | OK
```
