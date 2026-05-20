#!/usr/bin/env python3
"""validate_topology.py — static validation of DSX Air topology JSON files."""
from __future__ import annotations

import argparse
import json
import pathlib
import sys


REQUIRED_TOP_LEVEL = {"name", "nodes", "links"}
REQUIRED_NODE_FIELDS = {"name", "os", "cpu", "memory"}


def validate_file(path: pathlib.Path) -> list[str]:
    errors: list[str] = []
    try:
        data = json.loads(path.read_text())
    except Exception as e:  # noqa: BLE001
        return [f"{path}: cannot parse JSON: {e}"]

    missing = REQUIRED_TOP_LEVEL - data.keys()
    if missing:
        errors.append(f"{path}: missing top-level keys {missing}")

    seen_names: set[str] = set()
    for i, node in enumerate(data.get("nodes", [])):
        mn = REQUIRED_NODE_FIELDS - node.keys()
        if mn:
            errors.append(f"{path}: node[{i}] missing {mn}")
        nm = node.get("name")
        if nm in seen_names:
            errors.append(f"{path}: duplicate node name {nm!r}")
        seen_names.add(nm)
        if node.get("memory", 0) > 60_000:
            errors.append(f"{path}: node {nm} memory > trial ceiling 60 GiB")

    return errors


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("files", nargs="+", type=pathlib.Path)
    args = p.parse_args()

    all_errors: list[str] = []
    for f in args.files:
        all_errors += validate_file(f)

    if all_errors:
        print("topology validation FAILED")
        for e in all_errors:
            print(f"  - {e}")
        return 1
    print(f"✓ {len(args.files)} topology file(s) valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
