#!/usr/bin/env bash
# vxlan_flap.sh — flap VXLAN tunnel on a leaf
#
# Usage:
#   chaos/network/vxlan_flap.sh [--leaf leaf1] [--vxlan vxlan100] [--duration 5]
#
# Effect: bring vxlan down → sleep N → bring vxlan up. Observed: producer
# timeouts, Redpanda ISR shrink, Flink checkpoint extension, then full recovery.
set -euo pipefail

LEAF="${LEAF:-leaf1}"
VXLAN="${VXLAN:-vxlan100}"
DURATION="${DURATION:-5}"
OOB_USER="${OOB_MGMT_USER:-cumulus}"
KEY="${CHAOS_SSH_KEY:-${HOME}/.ssh/id_rsa}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --leaf) LEAF="$2"; shift 2 ;;
    --vxlan) VXLAN="$2"; shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

echo "[chaos:N1] flap ${VXLAN} on ${LEAF} for ${DURATION}s"
ssh -i "${KEY}" -o StrictHostKeyChecking=no "${OOB_USER}@${LEAF}" "sudo ip link set ${VXLAN} down"
START_EPOCH=$(date +%s)
echo "[chaos:N1] down at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
sleep "${DURATION}"
ssh -i "${KEY}" -o StrictHostKeyChecking=no "${OOB_USER}@${LEAF}" "sudo ip link set ${VXLAN} up"
END_EPOCH=$(date +%s)
echo "[chaos:N1] up at $(date -u +%Y-%m-%dT%H:%M:%SZ) (outage ${DURATION}s)"

cat <<EOF

Recorded:
  scenario:        N1 — VXLAN flap
  leaf:            ${LEAF}
  vxlan:           ${VXLAN}
  start_epoch:     ${START_EPOCH}
  end_epoch:       ${END_EPOCH}
  outage_seconds:  ${DURATION}

Next:
  1. Capture Grafana snapshot: Flink checkpoint duration, Redpanda ISR
  2. Run runbook validation: runbooks/vxlan-flap.md
  3. Update benchmarks/results/$(date -u +%Y-%m-%d)-N1.md
EOF
