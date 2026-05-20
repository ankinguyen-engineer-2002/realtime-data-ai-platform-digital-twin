#!/usr/bin/env bash
# leaf_switch_down.sh — power-off a leaf switch (whole rack isolated)
set -euo pipefail

LEAF="${LEAF:-leaf1}"
DURATION="${DURATION:-60}"
SIM_NAME="${DSX_SIM_NAME:-dsx-data-platform}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --leaf) LEAF="$2"; shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    --sim) SIM_NAME="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

echo "[chaos:N2] STOPPING leaf ${LEAF} via DSX Air SDK"
python3 dsx-air/scripts/sim_node_stop.py --sim "${SIM_NAME}" --name "${LEAF}"

echo "[chaos:N2] sleeping ${DURATION}s (whole rack is isolated)"
sleep "${DURATION}"

echo "[chaos:N2] STARTING leaf ${LEAF}"
python3 dsx-air/scripts/sim_node_start.py --sim "${SIM_NAME}" --name "${LEAF}"

cat <<EOF

Capture:
  - alerts that fired
  - time-to-alert
  - data freshness during outage
  - any data loss on restoration (count(in) == count(in_bronze)?)
EOF
