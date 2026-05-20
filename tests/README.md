# tests/

Three layers of tests. CI runs all of them on every PR.

## Layers

| Layer | Folder | Runs when | Needs |
|---|---|---|---|
| Unit | `unit/` | always | pure Python; no infra |
| Integration | `integration/` | when stack is up | Docker compose running |
| Connectivity | `connectivity/` | post-bootstrap | sim running |

## Examples

```bash
pytest tests/unit                                 # always-fast
pytest tests/integration -m "not chaos"           # excludes destructive
pytest tests/connectivity --hosts inventory.ini   # against live sim
```

## What's tested

- **Unit:** producer event shape, schema validation, dedup logic, watermark math, PII tokenization round-trip.
- **Integration:** end-to-end produce → consume → assert in bronze; DLQ routing; Dagster asset run.
- **Connectivity:** every host reachable via OOB; every service health endpoint 200.
