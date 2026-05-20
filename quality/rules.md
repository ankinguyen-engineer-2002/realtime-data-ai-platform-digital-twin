# Data quality rules (human-readable catalogue)

## Bronze

| Rule | Applied to | Action on fail |
|---|---|---|
| Schema validates against JSON Schema | every event | DLQ |
| `event_time` between (now-7d, now+5m) | every event | DLQ |
| `event_id` is unique within 1h window | sample | warn |

## Silver

| Rule | Applied to | Action on fail |
|---|---|---|
| No duplicate `event_id` | every fact table | fail asset |
| Amount > 0 | `silver.fact_payment` | quarantine row |
| Currency in allowed enum | `silver.fact_payment` | quarantine row |
| SCD2 has exactly one current row per business key | dims | fail asset |

## Gold

| Rule | Applied to | Action on fail |
|---|---|---|
| Row count > expected_min(day_of_week) | every gold table | page on-call |
| Freshness < 25h | every gold table | page on-call |
| Stream-vs-batch revenue diff < 0.5% | `gold.payment_reconciliation` | page on-call |
