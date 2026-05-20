# Incident: Redpanda broker unavailable

**Severity:** P1
**Family:** Service
**Chaos script:** `chaos/service/redpanda_down.sh`
**Expected recovery:** < 2 min after restart

## Symptoms

- All producers logging `Broker not available` / `BROKER_NOT_AVAILABLE`
- All consumers stuck
- Grafana `redpanda_up` metric → 0
- Alert: `RedpandaBrokerDown`

## Detection

- Prometheus: `up{job="redpanda"} == 0`
- Loki: `{service="redpanda"} |~ "FATAL|panic"`

## Immediate action

1. SSH to `node-event`, check container:
   ```bash
   ssh node-event "docker ps -a | grep redpanda"
   ```
2. If exited, check logs for OOM / disk full:
   ```bash
   ssh node-event "docker logs --tail 200 redpanda"
   df -h
   ```
3. Restart:
   ```bash
   ssh node-event "docker start redpanda"
   ```

## Recovery

- Allow 30-60s for log replay / catch-up.
- Producers with `enable.idempotence=true` (ours do) automatically resume.
- Consumer groups will reconnect; lag will spike then drain.

## Data correctness check

Producer-side `events_sent_total` should equal eventually:
`events_consumed_total + events_in_dlq_total + lag_at_outage_start`.

```promql
sum(increase(events_produced_total[10m]))
== sum(increase(events_consumed_total[10m]))
   + sum(increase(dlq_events_total[10m]))
```

## Prevention

- Set Redpanda disk usage alarm at 75% (current: not set → action item).
- For burst test profile, switch to 3-broker cluster temporarily.
- Document RAM headroom: Redpanda single-broker should stay < 80% of node RAM.
