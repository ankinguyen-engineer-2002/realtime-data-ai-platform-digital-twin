# ADR-0009: Ship a 6-week MVP, then extend

## Status

Accepted

## Date

2026-05-20

## Context

The original blueprint promised "12 weeks → full platform." Realistic part-time effort is 8-12 hours/week. At that pace, the full stack takes 5-6 months, not 3. The classic failure mode is *half-done modules and a half-written README*.

A portfolio with one *demonstrably working* end-to-end flow beats six half-done modules every time. We need an MVP cut that is **shippable** and *honest about being a stage*.

## Decision

We organize execution into three milestones with **gating commits**:

1. **MVP (6 weeks, Phases 0-5)** — minimum to demonstrate end-to-end value:
   - DSX Air sim with leaf-spine fabric
   - Redpanda + Debezium CDC
   - One Flink job (order funnel) with late-event handling
   - Prometheus + Grafana consumer-lag dashboard
   - One network-chaos test (VXLAN flap) + runbook
   - README, ARCHITECTURE, 3 ADRs minimum

   **Gate:** if the MVP is not green by end of week 6, scope freezes — no extension until MVP is green.

2. **Extension (Phases 6-8)** — lakehouse + batch + serving.
3. **Polish (Phases 9-12)** — observability, governance, AI/RAG, chaos catalog complete, benchmark.

Each phase ends with a tagged commit (`vMVP`, `vExt-P6`, ...) so the repo history *is* the portfolio narrative.

## Alternatives considered

- **All-at-once big bang (the original 12-week plan)** — try to ship everything.
  - Rejected: high probability of half-done state at month 3.

- **Per-tool deep dives** — spend 2 weeks each on Kafka, then Flink, then Iceberg in isolation.
  - Rejected: never produces an end-to-end demo; portfolio reads as "tutorial completer."

- **Hire-it-out / clone existing demos** — no novelty.
  - Rejected: defeats the learning goal and the differentiator.

## Consequences

### Positive
- Always have something to show.
- Forces real prioritization of the network-chaos differentiator (it's in the MVP).
- Repo tags become a built-in portfolio narrative.

### Negative
- MVP scope cuts some features that look good in diagrams (Iceberg, ClickHouse, RAG) — README must explicitly say "Phase X delivers Y."

### Neutral
- We mark each ARCHITECTURE diagram section with a `Phase X` badge so readers know what's currently real vs planned.

## References

- [`ROADMAP.md`](../ROADMAP.md)
