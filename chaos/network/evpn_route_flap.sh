#!/usr/bin/env bash
# evpn_route_flap.sh — BGP soft-clear on a leaf
set -euo pipefail

LEAF="${LEAF:-leaf2}"
OOB_USER="${OOB_MGMT_USER:-cumulus}"
KEY="${CHAOS_SSH_KEY:-${HOME}/.ssh/id_rsa}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --leaf) LEAF="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

echo "[chaos:N4] BGP soft-clear on ${LEAF}"
ssh -i "${KEY}" -o StrictHostKeyChecking=no "${OOB_USER}@${LEAF}" "sudo vtysh -c 'clear bgp * soft'"
sleep 2
ssh -i "${KEY}" -o StrictHostKeyChecking=no "${OOB_USER}@${LEAF}" "sudo vtysh -c 'clear bgp * soft out'"
echo "[chaos:N4] soft-clear complete"

echo
echo "Capture: BGP convergence time, brief packet loss window."
