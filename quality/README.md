# quality/

Data quality suites. Wired into the Dagster asset graph as checkpoints.

## Layout

```
quality/
  great_expectations/
    great_expectations.yml
    expectations/
      bronze_schema.json
      silver_dedup.json
      silver_ranges.json
      gold_sanity.json
    checkpoints/
      hourly_silver.yml
      daily_gold.yml
  soda/                                # alternative; pick one
    soda-conf.yml
    checks/
      bronze.yml
      silver.yml
  rules.md                             # human-readable rule catalogue
```

## Decision: GE vs Soda

Default = Great Expectations (broader Dagster integration, more mature).
Soda evaluated as alternative in [`rules.md`](./rules.md).

## CI

GE expectation suites validate via `pytest tests/quality/test_suites.py`.
