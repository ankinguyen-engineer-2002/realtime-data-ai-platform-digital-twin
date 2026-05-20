# 18 — Benchmark strategy

> Honest numbers. Sized to lab. Useful for relative comparison, not for vendor decisions.

## Disclaimer (also in `docs/99`)

These numbers are **lab numbers** from DSX Air-simulated nodes and a simulated network. They are useful to compare *across runs in this lab*. They are **not** comparable to bare-metal Redpanda / Flink benchmarks. Do not quote them as production numbers.

## Scenarios

| ID | Scenario | Rate | Duration | Goal |
|---|---|---:|---:|---|
| B1 | Normal stream | 100 eps | 10 min | no lag, no loss |
| B2 | Burst stream | 1000 eps | 2 min | temp lag, clears < 5 min |
| B3 | Dirty events | 5% invalid | 10 min | all routed to DLQ |
| B4 | Duplicate events | 2% dup | 10 min | no double-count in gold |
| B5 | Late events | up to 30m late | 10 min | watermark + late side |
| B6 | MinIO outage | 3 min | n/a | alert + replay on recovery |
| B7 | Flink restart | n/a | n/a | checkpoint recovery |
| B8 ★ | VXLAN flap (network) | 5 s | n/a | producer retry, no data loss |
| B9 ★ | Leaf-down (network) | 60 s | n/a | rack-isolated services degrade gracefully |
| B10 ★ | ISL-down with ECMP (network) | until restored | n/a | survives via second spine |

★ = network family, the differentiator.

## Metrics recorded (per scenario)

```text
- events produced
- events consumed (sum across consumer groups)
- events in DLQ (by reason)
- producer p95/p99 latency
- consumer lag max, mean, recovery time
- Flink processing latency p95
- ClickHouse insert latency p95
- pipeline freshness p95
- alerts fired (and which)
- recovery time to baseline
- data correctness: count(in) vs count(in bronze) vs count(in DLQ) — should sum
- CPU / RAM usage per node during scenario
- compute hours burned during scenario
```

## Result file format

```markdown
# benchmarks/results/<date>-<scenario>.md

## Scenario B2 — Burst stream — 2026-06-15

**Environment**
- topology: 01-data-platform-mvp
- sizing: session-a (20 vCPU / 44 GB)
- redpanda version: 24.x
- flink version: 1.18.x

**Workload**
- rate: 1000 eps
- duration: 2 min

**Result**
- producer p95: 18 ms
- consumer lag max: 47 sec
- lag drain time: 3m 24s
- DLQ events: 0
- correctness: 120042 in, 120042 in bronze ✓

**Observations**
- Flink backpressure ratio peaked at 0.31 on `payment_risk_job`
- Checkpoint duration spiked from 4s to 19s during burst, normal afterwards
- No alert thresholds breached
```

## Visualization

Each result generates a small Grafana snapshot exported to `benchmarks/results/<date>-<scenario>.png`. README features the best 2-3 as hero images.

## Honesty check

Every benchmark write-up includes:
- "What this proves"
- "What this does NOT prove"
- "How it would differ in production"
