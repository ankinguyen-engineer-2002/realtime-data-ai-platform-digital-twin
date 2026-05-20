#!/usr/bin/env bash
# redpanda_down.sh — stop redpanda container for N seconds
set -euo pipefail
DURATION="${DURATION:-60}"
NODE="${NODE:-node-event}"
echo "[chaos:S1] stopping redpanda on ${NODE} for ${DURATION}s"
ssh "${NODE}" "docker stop redpanda"
sleep "${DURATION}"
ssh "${NODE}" "docker start redpanda"
echo "[chaos:S1] redpanda back; observe ISR recovery"
