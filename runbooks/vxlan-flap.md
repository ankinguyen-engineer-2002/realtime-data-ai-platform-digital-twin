# Incident: VXLAN tunnel flap on a leaf

**Severity:** P2
**Family:** Network ★
**Chaos script:** `chaos/network/vxlan_flap.sh`
**Expected recovery:** < 30s after restoration

## Symptoms

- Producer transient errors: `BROKER_NOT_AVAILABLE`, `NOT_LEADER_FOR_PARTITION`
- Redpanda `under_replicated_partitions` gauge spikes
- Flink `lastCheckpointDuration` doubles or triples briefly
- Grafana panel **Pipeline Freshness** shows a step
- Alert: `RedpandaConsumerLagHigh` may fire if burst long enough

## Detection

- Prometheus: `redpanda_kafka_under_replicated_partitions > 0`
- Loki: `{service="redpanda"} |~ "ISR"`
- Flink REST: `/jobs/<id>/checkpoints` → durations field
- Grafana: panel **Redpanda — ISR shrink events**

## Immediate action

1. Confirm: which leaf? Which VXLAN?
   ```bash
   ssh leaf1 "ip -d link show vxlan100"
   ```
2. If `state DOWN`, bring up:
   ```bash
   ssh leaf1 "sudo ip link set vxlan100 up"
   ```
3. If `state UP` but flapping, check BGP EVPN MAC learning:
   ```bash
   ssh leaf1 "sudo vtysh -c 'show bgp l2vpn evpn'"
   ```

## Recovery

- ISR re-syncs within ~10-30s of tunnel restoration.
- Flink checkpoints resume normal duration once produce/consume rate normalizes.
- No manual data action needed if producers are idempotent (they are — see ADR-0010).

## Data correctness check

```sql
-- in Trino
SELECT
  date_trunc('minute', event_time) AS minute,
  COUNT(*) AS events_received
FROM iceberg.bronze.events_payment
WHERE event_time BETWEEN TIMESTAMP '2026-mm-dd HH:MM:00' - INTERVAL '5' MINUTE
                    AND TIMESTAMP '2026-mm-dd HH:MM:00' + INTERVAL '5' MINUTE
GROUP BY 1 ORDER BY 1;

-- compare with producer-side log of events sent in that window
```

Expected: count(produced) == count(in bronze) + count(in DLQ).

## Prevention

- Monitor MTU consistency along underlay path: `tracepath -n -m 5 -p 4789 <peer>`
- Pre-deploy alert: any flap longer than 10s pages on call.
- Document the firmware-update procedure that **isn't** supposed to flap the tunnel.

## Related

- Chaos catalog: N1 in [`docs/16-failure-chaos-catalog.md`](../docs/16-failure-chaos-catalog.md)
- Network storyline: [`docs/17-network-failure-storyline.md`](../docs/17-network-failure-storyline.md)
