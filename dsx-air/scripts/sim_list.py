#!/usr/bin/env python3
"""sim_list.py — list DSX Air simulations on this account."""
from __future__ import annotations

import os
import sys


def main() -> int:
    try:
        from air_sdk import AirApi  # type: ignore
    except ImportError:
        print("nv-air-sdk not installed. pip install nv-air-sdk", file=sys.stderr)
        return 2

    token = os.environ.get("NV_AIR_TOKEN")
    if not token:
        print("NV_AIR_TOKEN missing", file=sys.stderr)
        return 2

    client = AirApi(api_token=token, api_url=os.environ.get("NV_AIR_API_URL", "https://air.nvidia.com/api/v2"))
    sims = client.simulations.list()  # type: ignore[attr-defined]

    print(f"{'ID':36s}  {'NAME':40s}  {'STATE':10s}  {'CREATED'}")
    for s in sims:
        print(f"{s.id:36s}  {s.name:40s}  {getattr(s, 'state', '?'):10s}  {getattr(s, 'created', '?')}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
