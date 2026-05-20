#!/usr/bin/env bash
# flink_restart.sh — restart flink taskmanager (test checkpoint recovery)
set -euo pipefail
NODE="${NODE:-node-stream}"
echo "[chaos:S2] restarting flink-taskmanager on ${NODE}"
ssh "${NODE}" "docker restart flink-taskmanager"
echo "[chaos:S2] check Flink REST for checkpoint recovery"
