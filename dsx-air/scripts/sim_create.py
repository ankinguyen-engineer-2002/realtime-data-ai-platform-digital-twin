#!/usr/bin/env python3
"""sim_create.py — create a DSX Air simulation from a topology JSON."""
from __future__ import annotations

import argparse
import json
import os
import pathlib
import sys


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--topology", required=True, type=pathlib.Path)
    p.add_argument("--name", required=True)
    p.add_argument("--organization", default=os.environ.get("NV_AIR_ORG_ID"))
    args = p.parse_args()

    if not args.topology.exists():
        print(f"topology not found: {args.topology}", file=sys.stderr)
        return 1

    try:
        from air_sdk import AirApi  # type: ignore
    except ImportError:
        print("nv-air-sdk not installed. pip install nv-air-sdk", file=sys.stderr)
        return 2

    client = AirApi(api_token=os.environ["NV_AIR_TOKEN"],
                    api_url=os.environ.get("NV_AIR_API_URL", "https://air.nvidia.com/api/v2"))

    topology_data = json.loads(args.topology.read_text())
    sim = client.simulations.create(  # type: ignore[attr-defined]
        name=args.name,
        topology_data=topology_data,
        organization=args.organization,
    )
    print(f"created: id={sim.id} name={sim.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
