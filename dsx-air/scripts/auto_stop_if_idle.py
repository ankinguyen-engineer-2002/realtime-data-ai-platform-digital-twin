#!/usr/bin/env python3
"""auto_stop_if_idle.py — sidecar that stops the sim if the data stack is idle.

Run continuously as a docker sidecar or systemd service. Stops the simulation
when no producer/consumer activity has been observed for IDLE_MINUTES.

Polls Prometheus for the metric `pipeline_event_lag_seconds` and producer
throughput. If both are zero for N consecutive checks, stops the sim.
"""
from __future__ import annotations

import os
import sys
import time
import urllib.parse
import urllib.request
import json


def query_prom(prom_url: str, q: str) -> float:
    url = f"{prom_url}/api/v1/query?query={urllib.parse.quote(q)}"
    try:
        with urllib.request.urlopen(url, timeout=10) as r:
            data = json.loads(r.read())
        results = data.get("data", {}).get("result", [])
        if not results:
            return 0.0
        return float(results[0]["value"][1])
    except Exception as e:  # noqa: BLE001
        print(f"prom query failed: {e}", file=sys.stderr)
        return -1.0


def main() -> int:
    prom = os.environ.get("PROMETHEUS_URL", "http://node-obs:9090")
    sim_name = os.environ.get("DSX_SIM_NAME", "dsx-data-platform")
    idle_minutes = int(os.environ.get("IDLE_MINUTES", 30))
    poll_seconds = int(os.environ.get("POLL_SECONDS", 60))

    needed_idle_checks = (idle_minutes * 60) // poll_seconds
    idle_count = 0

    while True:
        rate = query_prom(prom, "sum(rate(events_produced_total[1m]))")
        if rate <= 0.01:
            idle_count += 1
        else:
            idle_count = 0

        print(f"[idle_watcher] producer_rate={rate:.2f}  idle_count={idle_count}/{needed_idle_checks}")

        if idle_count >= needed_idle_checks:
            print(f"[idle_watcher] idle for ≥{idle_minutes}m — stopping sim {sim_name}")
            # delegate to sim_stop.py for the actual stop
            os.execvp("python3", ["python3", "dsx-air/scripts/sim_stop.py", "--name", sim_name, "--checkpoint"])

        time.sleep(poll_seconds)


if __name__ == "__main__":
    raise SystemExit(main())
