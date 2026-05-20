# Benchmark result: B<N> — <name> — <YYYY-MM-DD>

## Environment

- Topology: `topologies/01-data-platform-mvp.json`
- Session: A / B / C
- Sizing: <vCPU> vCPU / <GB> RAM
- Redpanda version:
- Flink version:
- Iceberg version:
- ClickHouse version:

## Workload

- Rate: <eps>
- Duration: <s>
- Producers active:
- Special flags:

## Result table

| Metric | Pre-chaos baseline | During chaos | Post-recovery |
|---|---|---|---|
| Producer p95 latency (ms) |  |  |  |
| Consumer lag max (records) |  |  |  |
| Flink checkpoint p95 (s) |  |  |  |
| Backpressure ratio max |  |  |  |
| DLQ events |  |  |  |
| ClickHouse insert p95 (ms) |  |  |  |
| Pipeline freshness p95 (s) |  |  |  |
| Alerts fired | n/a |  | n/a |

## Recovery

- Time to first alert:
- Time to recovery signal:
- Time to lag drained:
- Time to baseline:

## Data correctness

- count(produced) =
- count(consumed) =
- count(in bronze) =
- count(in DLQ) =
- duplicates detected =
- gap detected =

Verdict: ✓ no loss / ⚠ partial / ✗ loss

## Observations

- ...
- ...

## Lessons / actions

- ...

## Grafana snapshot

![](./YYYY-MM-DD-B<N>.png)
