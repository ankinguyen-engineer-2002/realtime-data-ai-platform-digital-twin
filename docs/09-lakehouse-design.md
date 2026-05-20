# 09 — Lakehouse design

Iceberg tables on MinIO, three zones (bronze / silver / gold), Trino query layer.

## Zone responsibilities

| Zone | What's in it | Who writes | Who reads |
|---|---|---|---|
| `raw/` | Landed JSON files (rare; mostly bypassed) | producers / batch fallback | none normally |
| `bronze.*` | One row per event, schema-validated, minimal cleaning | Flink `lakehouse_sink_job` | Dagster, ad-hoc |
| `silver.*` | Cleaned, deduped, conformed, SCD2 dims | Dagster | Dagster, Trino |
| `gold.*` | KPI / served | Dagster | ClickHouse publisher, Trino, BI |

## Tables (Phase 6 target)

```sql
-- bronze
CREATE TABLE bronze.events_clickstream (...) PARTITIONED BY (day(event_time));
CREATE TABLE bronze.events_payment (...) PARTITIONED BY (day(event_time));
CREATE TABLE bronze.cdc_orders (...) PARTITIONED BY (day(event_time));
CREATE TABLE bronze.cdc_inventory (...) PARTITIONED BY (day(event_time));

-- silver
CREATE TABLE silver.fact_clickstream (...) PARTITIONED BY (day(event_time));
CREATE TABLE silver.fact_payment (...) PARTITIONED BY (day(event_time));
CREATE TABLE silver.fact_order (...);
CREATE TABLE silver.dim_customer_scd2 (...);
CREATE TABLE silver.dim_product_scd2 (...);

-- gold
CREATE TABLE gold.daily_revenue (...) PARTITIONED BY (event_date);
CREATE TABLE gold.order_funnel_hourly (...) PARTITIONED BY (event_date);
CREATE TABLE gold.payment_success_rate (...);
CREATE TABLE gold.fraud_alert_summary (...);
CREATE TABLE gold.inventory_availability (...);
CREATE TABLE gold.delivery_sla (...);
```

## Catalog

Iceberg REST catalog on `node-lake:8181`, Postgres-backed:

```text
catalog name: iceberg
warehouse: s3://lakehouse/warehouse/
endpoint: http://node-lake:9000
```

Used by Trino, Flink, PyIceberg / Dagster.

## Maintenance jobs (Dagster, nightly)

| Job | Purpose |
|---|---|
| `expire_snapshots` | retain last 7 days of snapshots |
| `remove_orphan_files` | clean S3 orphans from failed writes |
| `rewrite_data_files` | compact small files (target 128 MB) |
| `rewrite_manifests` | merge manifest lists |

## Time travel demo

```sql
SELECT * FROM iceberg.gold.daily_revenue FOR VERSION AS OF 1234567890;
SELECT * FROM iceberg.gold.daily_revenue FOR TIMESTAMP AS OF DATE '2026-05-15';
```

Recorded in [`lakehouse/sql/query_examples.sql`](../lakehouse/sql/).
