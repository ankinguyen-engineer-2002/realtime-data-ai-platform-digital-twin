#!/usr/bin/env bash
# postgres_down.sh — stop OLTP postgres (test Debezium reconnect)
set -euo pipefail
DURATION="${DURATION:-60}"
NODE="${NODE:-node-cdc}"
echo "[chaos:S4] stopping postgres on ${NODE} for ${DURATION}s"
ssh "${NODE}" "docker stop postgres-oltp"
sleep "${DURATION}"
ssh "${NODE}" "docker start postgres-oltp"
echo "[chaos:S4] postgres back; Debezium will reconnect and resume from LSN"
