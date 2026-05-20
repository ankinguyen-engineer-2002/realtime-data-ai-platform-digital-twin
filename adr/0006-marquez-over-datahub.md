# ADR-0006: Use OpenLineage + Marquez for lineage

## Status

Accepted

## Date

2026-05-20

## Context

We need dataset-level lineage spanning Flink streaming jobs, Dagster batch assets, Trino queries, and lakehouse tables. The lineage should be:
- Visible (UI) so reviewers can see end-to-end flow
- Automatic (emitters), not hand-curated
- Cheap on RAM

## Decision

Use **OpenLineage** as the wire protocol and **Marquez** as the storage + UI.

- Emitters: `openlineage-flink`, `openlineage-dagster`, `openlineage-trino`.
- Marquez backend: Postgres metastore + UI on `node-obs:3001`.
- Lineage events also archived to MinIO `lineage/` for offline analysis.

## Alternatives considered

- **DataHub** — feature-complete metadata catalog.
  - Attractive: search, glossary, tags, RBAC, full catalog.
  - Rejected: 6+ GB RAM stack (frontend + GMS + Elasticsearch + Kafka + MySQL). Too heavy for the lab; lineage-only need doesn't justify it.

- **OpenMetadata** — similar scope to DataHub.
  - Rejected: same RAM problem; pick one heavy catalog or none.

- **Apache Atlas** — original lineage tool.
  - Rejected: Hadoop heritage, heavy, dated UX.

- **Manual lineage in markdown** — write `docs/lineage.md`.
  - Attractive: zero cost.
  - Rejected: doesn't auto-detect drift; doesn't show real platform behavior.

## Consequences

### Positive
- Standards-based (OpenLineage) → portable; emitters available for all our tools.
- Marquez runs in ~500 MB RAM.
- Lineage events emitted automatically — no manual curation drift.

### Negative
- Marquez UI lacks search/glossary/RBAC. We're trading features for footprint.
- If the portfolio later wants a full catalog story, we'd add DataHub on top.

### Neutral
- Future-friendly: OpenLineage events could be piped into DataHub later without changing emitters.

## References

- [OpenLineage spec](https://openlineage.io/)
- [Marquez project](https://marquezproject.ai/)
- [Why we picked OpenLineage — community write-ups](https://openlineage.io/community/)
- [`docs/13-governance-lineage.md`](../docs/13-governance-lineage.md)
