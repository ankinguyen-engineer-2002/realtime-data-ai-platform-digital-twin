# chaos/

> Three failure families. Run before bedtime, document next morning.

| Family | Where | Differentiator |
|---|---|---|
| Service | [`service/`](./service/) | docker-level kill, common to all labs |
| Data | [`data/`](./data/) | dirty / late / duplicate / replay |
| Network ★ | [`network/`](./network/) | VXLAN / EVPN / leaf-spine — DSX Air sweet spot |

See [`docs/16-failure-chaos-catalog.md`](../docs/16-failure-chaos-catalog.md) for the matrix.

## Before any chaos run

1. Set a synthetic workload going (`make produce-normal &`).
2. Open Grafana, pin the relevant dashboard.
3. Open Loki tail for the affected service.
4. Note start time.

## After any chaos run

1. Note recovery time.
2. Run data-correctness query from the runbook.
3. Save Grafana snapshot to `benchmarks/results/<date>-<scenario>.png`.
4. Append findings to `benchmarks/results/<date>-<scenario>.md`.

## Safety

- Network chaos scripts include `--auto-revert TIMEOUT` flag. **Always use it** unless you're physically next to the keyboard.
- Service chaos scripts include a `sleep && docker start` block as the default for the same reason.
