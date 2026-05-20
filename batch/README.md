# batch/

Dagster project for batch orchestration, gold-table builds, reconciliation, and quality.

## Why Dagster (and not Airflow)

See [ADR-0005](../adr/0005-dagster-over-airflow.md). The asset-centric model maps cleanly to bronze→silver→gold lakehouse work.

## Layout

```
batch/dagster/
  pyproject.toml
  workspace.yaml
  resources.py            # MinIO, Iceberg, ClickHouse, GE clients
  assets/
    bronze.py             # passthroughs from Flink-written tables
    silver.py             # dedup, conform, SCD2
    gold.py               # KPI tables
    quality.py            # GE checkpoint runs
    reconciliation.py     # stream-vs-batch revenue check
  jobs/
    nightly_maintenance.py
    daily_gold_build.py
  schedules.py            # cron schedules
  sensors.py              # partition + Kafka-offset sensors
```

## Run locally (dev)

```bash
cd batch/dagster
dagster dev
# UI at http://localhost:3000
```

## Run in lab (Session B)

```bash
make session-b-up
# Dagster UI at http://node-batch:3000 (via OOB)
```
