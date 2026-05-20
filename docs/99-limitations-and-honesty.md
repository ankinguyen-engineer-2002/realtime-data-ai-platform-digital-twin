# 99 — Limitations and honesty statement

> What this project is, and what it is not. Read this before quoting anything to a recruiter.

## What this project IS

- A **production-inspired learning lab** demonstrating modern data + AI platform patterns.
- A **portfolio piece** showing architecture thinking, kill-your-darlings decision making, and end-to-end ownership.
- A **functional, runnable** stack of OSS tools that processes realistic synthetic events end-to-end.
- A **chaos catalog** documenting how the platform responds to service, data, and network failures.

## What this project IS NOT

- ❌ Not production-grade throughput. Benchmark numbers are lab numbers on simulated network. They are not comparable to real bare-metal or hyperscaler numbers.
- ❌ Not real data. Every event is synthetic. No customer, PII, or business data exists.
- ❌ Not multi-tenant. There's one "tenant" assumed everywhere.
- ❌ Not certified compliant. PII tokenization is demonstrated as a pattern, not audited as a control.
- ❌ Not 24/7. The simulation is stopped between sessions to save credits.
- ❌ Not hyperscale-tested. Burst tests cap at 1000 eps; production systems do millions.
- ❌ Not a replacement for a real platform team. This is one person's lab.

## Specific numerical caveats

- **All latency numbers** include DSX Air simulated network overhead. They are useful as **relative** comparisons across runs in this lab, not as **absolute** numbers.
- **Throughput** is capped by node sizing inside the sim. Don't extrapolate to "Redpanda can do X."
- **Recovery times** are measured **in this topology with this sizing**. A real spine-leaf in production might recover faster *or* slower.

## Things that look real but aren't (yet)

| Looks like | Actually is |
|---|---|
| Hardened authentication | Demo SASL/SCRAM + JWT stub |
| Production-grade secrets | SOPS-encrypted .env (good for learning, not production) |
| Multi-region replication | Single-region single-broker (MVP) |
| Disaster recovery | Documented in runbooks; not regularly exercised |
| Real RAG quality | RAGAS scores from synthetic docs |

## What changes between sessions

| Session | Storage state | Why |
|---|---|---|
| A → B | MinIO preserved, Postgres preserved, Redpanda topics preserved | needed for batch jobs |
| B → C | MinIO preserved, ClickHouse exported to MinIO | C doesn't run batch |
| Any → stopped | local Docker volumes lost on node teardown | use MinIO for anything you need to survive |

So if you see "data missing" between sessions and the data wasn't in MinIO or Postgres, that's expected.

## Things planned but cut for scope (so far)

- DataHub / OpenMetadata full catalog (kept lineage-only via Marquez — see [ADR-0006](../adr/0006-marquez-over-datahub.md))
- Multi-broker Redpanda cluster as default (single broker; 3-broker only for burst test — see [ADR-0002](../adr/0002-redpanda-over-kafka.md))
- Apache Paimon as a second lakehouse format (Iceberg only — see [ADR-0004](../adr/0004-iceberg-over-delta-paimon.md))
- Spark batch jobs (Dagster + PyIceberg instead — see [ADR-0005](../adr/0005-dagster-over-airflow.md))
- Full GPU simulation workload (DSX Air supports it; this lab doesn't use it)

## What I'm asking you (reader / reviewer) to evaluate

Not:
- "Does this scale to a million events/sec?" (No, and not designed to.)
- "Would this pass a SOC2 audit?" (No, and not designed to.)

Yes:
- "Does this architecture make sense for the problem stated?"
- "Are the trade-offs in the ADRs honest?"
- "Do the chaos runbooks reflect real operational thinking?"
- "Would this person know what to do on day one as a senior platform engineer?"

## License

MIT — see [`LICENSE`](../LICENSE). Use freely; attribution welcome but not required.
