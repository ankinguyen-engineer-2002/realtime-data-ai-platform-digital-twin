# Runbooks

Every documented failure mode has a runbook here. Linked from the [chaos catalog](../docs/16-failure-chaos-catalog.md) and from the alert rules in [`observability/prometheus/alerts.yml`](../observability/prometheus/alerts.yml).

## Service failure

- [`redpanda-down.md`](./redpanda-down.md)
- [`flink-job-failed.md`](./flink-job-failed.md)
- [`minio-unavailable.md`](./minio-unavailable.md)
- [`postgres-cdc-lag.md`](./postgres-cdc-lag.md)
- [`clickhouse-down.md`](./clickhouse-down.md)
- [`consumer-lag-spike.md`](./consumer-lag-spike.md)

## Data failure

- [`bad-schema-deployed.md`](./bad-schema-deployed.md)
- [`duplicate-events.md`](./duplicate-events.md)
- [`late-events.md`](./late-events.md)
- [`dlq-spike.md`](./dlq-spike.md)

## Network failure ★

- [`vxlan-flap.md`](./vxlan-flap.md)
- [`leaf-switch-down.md`](./leaf-switch-down.md)
- [`isl-link-down.md`](./isl-link-down.md)
- [`evpn-route-flap.md`](./evpn-route-flap.md)
- [`spine-down.md`](./spine-down.md)
- [`async-loss.md`](./async-loss.md)

## Operational

- [`rotate-pii-key.md`](./rotate-pii-key.md)
- [`expand-disk.md`](./expand-disk.md)
- [`backfill-from-checkpoint.md`](./backfill-from-checkpoint.md)

## Template

All runbooks share this structure:

```markdown
# Incident: <name>

**Severity:** Pn
**Family:** Service / Data / Network
**Chaos script:** path
**Expected recovery:** Nm

## Symptoms
## Detection
## Immediate action
## Recovery
## Data correctness check
## Prevention
```
