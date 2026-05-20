# ADR-0010: Design synthetic data with dirty / late / duplicate built in

## Status

Accepted

## Date

2026-05-20

## Context

A platform that only processes clean, on-time, unique events isn't a platform — it's a hello-world. Real e-commerce/payment streams have:
- ~3-5% schema violations (clients with bugs, version drift)
- ~0.5-2% duplicates (retries, network blips)
- Long-tail late arrivals (mobile clients going offline)
- Occasional malformed JSON, wrong types, negative amounts

We need synthetic data that **explicitly contains all of these** so DLQ, dedup, watermark, and quality-check code paths are exercised.

## Decision

The synthetic-data layer has **8 producers**, each toggleable via CLI flags. Defaults emit clean data; flags inject controlled badness.

```bash
# clean
python producers/order_producer.py --rate 100 --duration 10m

# 5% bad schema, 2% duplicates, up to 30min late
python producers/order_producer.py \
  --rate 100 --duration 10m \
  --invalid-rate 0.05 \
  --duplicate-rate 0.02 \
  --late-events true --max-late-minutes 30
```

Bad data types are **labeled in the event payload** (`_synthetic_label`: `"missing_order_id"`, `"negative_amount"`, etc.) so downstream tests can assert correct DLQ routing.

The producer ships with a deterministic mode (`--seed=42`) so test runs are reproducible across CI.

## Alternatives considered

- **Use a real public dataset** — Kaggle e-commerce, Stripe sample.
  - Attractive: realism, no design effort.
  - Rejected: static; doesn't support late/duplicate injection; bad-event control impossible.

- **Use a single producer with a "chaos mode"** — global toggle.
  - Rejected: less granular; can't test "what happens when only payment events go bad."

- **Generate everything in Flink** — `DataGen` source.
  - Rejected: ties bad-data generation to Flink runtime; want producers to work even when Flink is down (for backbone tests).

## Consequences

### Positive
- Every DLQ, dedup, watermark feature is provably exercised.
- Reproducible runs (seed) enable CI assertion.
- Bad-event labels make the test/assert pattern clean.

### Negative
- 8 producers is more code than the "1 producer with toggles" approach.
- Coordinated bursts across producers need a small orchestrator (`make produce-realistic-day`).

### Neutral
- All schemas in `schemas/` are JSON Schema; producers validate before send when not in `--invalid` mode.

## References

- [`producers/README.md`](../producers/README.md)
- [`schemas/`](../schemas/)
- [`docs/16-failure-chaos-catalog.md`](../docs/16-failure-chaos-catalog.md)
