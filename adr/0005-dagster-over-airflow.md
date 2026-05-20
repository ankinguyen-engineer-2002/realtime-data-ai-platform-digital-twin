# ADR-0005: Use Dagster for batch orchestration

## Status

Accepted

## Date

2026-05-20

## Context

We need a batch orchestrator for: lakehouse table builds (bronze → silver → gold), reconciliation jobs, scheduled data quality checks, embedding refreshes, and gold-table publishing to ClickHouse.

The lakehouse pattern is *asset-centric* (what tables exist, what their freshness is, what depends on what) rather than *task-centric* (run this, then that).

## Decision

Use **Dagster 1.6+** with the `pyiceberg` integration and the `dagster-great-expectations` integration.

- Code organization: `batch/dagster/assets/` (one file per lakehouse domain).
- Sensors: file landing, Kafka offset, time schedule.
- Resources: shared Postgres metastore, MinIO client, Iceberg catalog, ClickHouse.
- IO managers: PyIceberg IO for lakehouse, ClickHouse IO for serving.

## Alternatives considered

- **Apache Airflow** — the default choice.
  - Attractive: most recognizable to recruiters, huge community.
  - Rejected: task-centric model fits lakehouse poorly; the asset model in Dagster matches our gold-tables-as-products framing; Airflow's 2-3 GB RAM scheduler is heavier; we'd need extra glue for data-aware orchestration.

- **Prefect 2.x** — flow-as-code, dynamic.
  - Attractive: very Pythonic, lightweight.
  - Rejected: weaker lineage / asset model; Dagster's data-contract story is stronger.

- **Argo Workflows / Tekton** — Kubernetes-native.
  - Rejected: no K8s in this lab.

- **Mage** — newer, code + UI.
  - Rejected: smaller community; ADR signal is weaker.

## Consequences

### Positive
- Asset graph maps **directly** to bronze/silver/gold model.
- Data-aware scheduling reduces redundant builds.
- Dagster UI shows asset materializations with lineage out of the box.
- OpenLineage emission is native.

### Negative
- Less recognizable on a CV than Airflow. Mitigation: README explicitly explains the choice with this ADR.
- Smaller community of stackoverflow answers.

### Neutral
- Both tools would have worked. The asset model tilts the call.

## References

- [Dagster vs Airflow comparison](https://dagster.io/blog/dagster-airflow)
- [Dagster software-defined assets](https://docs.dagster.io/concepts/assets/software-defined-assets)
- [`docs/10-batch-orchestration.md`](../docs/10-batch-orchestration.md)
