# platform/

Per-session docker-compose files. Only ONE session runs at a time. See [ADR-0008](../adr/0008-time-multiplex-sessions.md).

## Sessions

| File | Phase | Services |
|---|---|---|
| `docker-compose.session-a.yml` | P4-P5 | redpanda, schema-registry, postgres-oltp, debezium, flink-jm, flink-tm, minio, iceberg-rest, prometheus, grafana |
| `docker-compose.session-b.yml` | P6-P9 | session-a + dagster-webserver, dagster-daemon, ge-runner, clickhouse, redis, fastapi, trino |
| `docker-compose.session-c.yml` | P10 | + qdrant, embedder, rag-service, marquez |
| `docker-compose.observability.yml` | always | prometheus, grafana, loki, promtail, otel-collector |
| `docker-compose.burst-test.yml` | P11 only | 3-broker Redpanda + extra flink TM |

## Switching sessions

```bash
make session-down                          # stop current
make session-X-up SESSION=a                # bring up next
```

State persists in MinIO (lakehouse) and Postgres OLTP (CDC source).

## Environment

`docker compose --env-file platform/env/.env -f <session>.yml up -d`

`.env` is gitignored; use `.env.sops.yaml` decrypted via `sops -d`.
