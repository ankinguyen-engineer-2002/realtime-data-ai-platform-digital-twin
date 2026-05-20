# benchmarks/

Honest, lab-scale, controlled-scenario results. See [`docs/18-benchmark-strategy.md`](../docs/18-benchmark-strategy.md).

## Layout

```
benchmarks/
  scenarios/
    run_mvp.sh                # B1, B2, B8 — MVP-phase suite
    run_all.sh                # B1..B10 — full suite
    b1_normal_stream.sh
    b2_burst_stream.sh
    b8_vxlan_flap.sh
    ...
  results/
    YYYY-MM-DD-B1.md
    YYYY-MM-DD-B1.png         # grafana snapshot
    ...
  template.md                 # blank result template
```

## Disclaimer

These are **lab numbers** on a DSX Air simulation. Useful for relative comparison
across runs in this lab. **Do not quote as production benchmarks.**

## Result write-up template

See [`template.md`](./template.md).
