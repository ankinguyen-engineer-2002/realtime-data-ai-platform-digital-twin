#!/usr/bin/env bash
# minio_down.sh — stop minio for 3 minutes
set -euo pipefail
DURATION="${DURATION:-180}"
NODE="${NODE:-node-lake}"
echo "[chaos:S3] stopping MinIO on ${NODE} for ${DURATION}s"
ssh "${NODE}" "docker stop minio"
sleep "${DURATION}"
ssh "${NODE}" "docker start minio"
echo "[chaos:S3] MinIO back; expect lakehouse sink replay from offsets"
