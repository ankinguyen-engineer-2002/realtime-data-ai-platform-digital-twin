#!/usr/bin/env bash
# spine_down.sh — bring down one spine (test ECMP fallback to surviving spine)
set -euo pipefail

SPINE="${SPINE:-spine1}"
DURATION="${DURATION:-60}"
SIM_NAME="${DSX_SIM_NAME:-dsx-data-platform}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --spine) SPINE="$2"; shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    --sim) SIM_NAME="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

echo "[chaos:N5] stopping spine ${SPINE}"
python3 dsx-air/scripts/sim_node_stop.py --sim "${SIM_NAME}" --name "${SPINE}"
sleep "${DURATION}"
python3 dsx-air/scripts/sim_node_start.py --sim "${SIM_NAME}" --name "${SPINE}"
echo "[chaos:N5] spine ${SPINE} back"

echo "Capture: throughput drop (% of baseline), any keepalive break."
