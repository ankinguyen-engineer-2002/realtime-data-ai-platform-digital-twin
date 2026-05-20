#!/usr/bin/env python3
"""sim_start.py — start a DSX Air simulation by name."""
from __future__ import annotations

import argparse
import os
import sys


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--name", required=True)
    args = p.parse_args()

    try:
        from air_sdk import AirApi  # type: ignore
    except ImportError:
        print("nv-air-sdk not installed", file=sys.stderr)
        return 2

    client = AirApi(api_token=os.environ["NV_AIR_TOKEN"],
                    api_url=os.environ.get("NV_AIR_API_URL", "https://air.nvidia.com/api/v2"))

    sim = next((s for s in client.simulations.list() if s.name == args.name), None)  # type: ignore[attr-defined]
    if not sim:
        print(f"no sim named {args.name!r}", file=sys.stderr)
        return 1

    sim.start()
    print(f"starting {sim.id} ({sim.name}). poll status with sim_status.py")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
