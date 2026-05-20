# Incident: Flink job failed / restarting

**Severity:** P2
**Family:** Service
**Chaos script:** `chaos/service/flink_restart.sh`
**Expected recovery:** ≤ 2 min from last checkpoint

## Symptoms

- Job state `RESTARTING` or `FAILED`
- Consumer lag growing on input topics
- Alert: `FlinkCheckpointFailure` or `FlinkJobRestarting`

## Detection

- Flink REST: `GET node-stream:8081/jobs/<id>` → state
- Prometheus: `flink_jobmanager_job_numRestarts > 0`
- Loki: `{service="flink-taskmanager"} |~ "ERROR|Caused by"`

## Immediate action

1. Identify failure reason from Flink UI or logs.
2. Common causes:
   - **OOM** → bump TaskManager memory in compose, restart.
   - **Checkpoint failure** → check MinIO availability and bucket policy.
   - **State backend corruption** → run from last *successful* checkpoint.
3. If failure-rate exceeds policy, job state = FAILED; manual restart via:
   ```bash
   flink run --target remote --jobmanager node-stream:8081 \
     --fromSavepoint s3://flink-checkpoints/<job>/savepoint-xxxx \
     <job-jar>
   ```

## Recovery

- From last checkpoint: automatic.
- From savepoint: manual command above.
- Verify lag drains within 5 min after restart.

## Data correctness check

For exactly-once jobs (`lakehouse_sink_job`):
```sql
-- expect zero duplicate event_id in the window around failure
SELECT event_id, COUNT(*) c
FROM iceberg.bronze.events_payment
WHERE event_time BETWEEN <-1h> AND <+1h>
GROUP BY 1
HAVING COUNT(*) > 1;
-- result: empty
```

## Prevention

- Set `restart-strategy.failure-rate.delay` to avoid hot loops.
- Pre-allocate enough TaskManager memory headroom (20%+).
- Alarm on checkpoint duration > 30s (early indicator).
