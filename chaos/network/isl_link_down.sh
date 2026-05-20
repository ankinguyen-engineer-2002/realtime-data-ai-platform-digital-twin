#!/usr/bin/env bash
# isl_link_down.sh — drop one inter-switch link (ECMP rehash test)
set -euo pipefail

SPINE="${SPINE:-spine1}"
INTERFACE="${INTERFACE:-swp1}"   # link toward leaf1
DURATION="${DURATION:-60}"
OOB_USER="${OOB_MGMT_USER:-cumulus}"
KEY="${CHAOS_SSH_KEY:-${HOME}/.ssh/id_rsa}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --spine) SPINE="$2"; shift 2 ;;
    --interface) INTERFACE="$2"; shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

echo "[chaos:N3] bringing down ${SPINE}/${INTERFACE}"
ssh -i "${KEY}" -o StrictHostKeyChecking=no "${OOB_USER}@${SPINE}" "sudo ip link set ${INTERFACE} down"
sleep "${DURATION}"
ssh -i "${KEY}" -o StrictHostKeyChecking=no "${OOB_USER}@${SPINE}" "sudo ip link set ${INTERFACE} up"
echo "[chaos:N3] restored ${SPINE}/${INTERFACE}"

cat <<EOF

Expected: ECMP rehash via surviving spine. Some long-lived TCP may rebuild.
Capture: reconvergence time, TCP retransmits, any Flink restart events.
EOF
