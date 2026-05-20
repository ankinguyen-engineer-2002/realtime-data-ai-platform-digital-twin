# observability/

> 12 alerts mapped to 8 runbooks. See [`docs/12-observability-slo.md`](../docs/12-observability-slo.md).

## Layout

```
observability/
  prometheus/
    prometheus.yml              # scrape config (job per service)
    alerts.yml                  # alert rules
    recording_rules.yml         # SLI recording rules
  grafana/
    provisioning/
      datasources/              # Prom, Loki, Tempo
      dashboards/               # YAML provisioning
    dashboards/                 # *.json dashboards
      infra-overview.json
      redpanda.json
      flink.json
      data-quality.json
      pipeline-freshness.json
      api.json
      serving.json
      rag.json
      chaos-runs.json           # snapshot of recent chaos events
  loki/
    loki-config.yaml
    promtail-config.yaml
  otel/
    collector.yaml
```

## Provisioning

All Grafana dashboards + alert rules are committed as JSON. `docker compose -f platform/docker-compose.observability.yml up -d` mounts them so the obs stack is reproducible.
