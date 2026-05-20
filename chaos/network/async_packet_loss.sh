#!/usr/bin/env bash
# async_packet_loss.sh — inject % packet loss via tc netem on one ISL
#
# The sneakiest failure: throughput degrades, often no alert fires.
set -euo pipefail

LEAF="${LEAF:-leaf1}"
INTERFACE="${INTERFACE:-swp1}"
LOSS_PCT="${LOSS_PCT:-5}"
DURATION="${DURATION:-300}"
OOB_USER="${OOB_MGMT_USER:-cumulus}"
KEY="${CHAOS_SSH_KEY:-${HOME}/.ssh/id_rsa}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --leaf) LEAF="$2"; shift 2 ;;
    --interface) INTERFACE="$2"; shift 2 ;;
    --loss) LOSS_PCT="$2"; shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

echo "[chaos:N6] adding ${LOSS_PCT}% loss on ${LEAF}/${INTERFACE} for ${DURATION}s"
ssh -i "${KEY}" -o StrictHostKeyChecking=no "${OOB_USER}@${LEAF}" \
    "sudo tc qdisc add dev ${INTERFACE} root netem loss ${LOSS_PCT}%"

sleep "${DURATION}"

ssh -i "${KEY}" -o StrictHostKeyChecking=no "${OOB_USER}@${LEAF}" \
    "sudo tc qdisc del dev ${INTERFACE} root"
echo "[chaos:N6] loss removed"

cat <<'EOF'

If no alert fired, that is a finding — note an improvement in monitoring.
Suggested new alert: rate(redpanda_kafka_under_replicated_partitions[2m]) > 0
EOF
