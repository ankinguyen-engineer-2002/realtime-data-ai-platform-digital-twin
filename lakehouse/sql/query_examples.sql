-- query_examples.sql — Iceberg features worth demonstrating

-- 1. Time-travel by snapshot
SELECT * FROM iceberg.gold.daily_revenue
FOR VERSION AS OF 1234567890;

-- 2. Time-travel by timestamp
SELECT * FROM iceberg.gold.daily_revenue
FOR TIMESTAMP AS OF DATE '2026-05-15';

-- 3. Snapshot listing
SELECT * FROM iceberg.gold."daily_revenue$snapshots"
ORDER BY committed_at DESC LIMIT 10;

-- 4. Schema evolution example: column added
-- ALTER TABLE iceberg.silver.fact_payment ADD COLUMN risk_band VARCHAR;
SELECT order_id, amount, risk_score, risk_band
FROM iceberg.silver.fact_payment
WHERE event_time > current_timestamp - INTERVAL '1' DAY;

-- 5. Hidden partitioning
SELECT * FROM iceberg.silver.fact_payment
WHERE event_time > DATE '2026-05-19'
  AND event_time < DATE '2026-05-20';
-- partition pruning visible in EXPLAIN

-- 6. Joining lakehouse + serving via federated query
SELECT s.order_id, s.amount, c.realtime_funnel_session_id
FROM iceberg.silver.fact_payment s
JOIN clickhouse.default.realtime_funnel c
  ON s.order_id = c.order_id
WHERE s.event_time > current_timestamp - INTERVAL '1' HOUR;
