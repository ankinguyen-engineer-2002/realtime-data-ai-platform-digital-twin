#!/usr/bin/env python3
"""order_producer.py — synthetic order events.

Real Kafka produce lands in Phase 4. This is the CLI surface that gets wired up.
"""
from __future__ import annotations

import argparse

from producers.common.base import ProducerConfig, parse_duration


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--rate", type=float, default=100.0)
    p.add_argument("--duration", type=str, default="10m")
    p.add_argument("--seed", type=int, default=42)
    p.add_argument("--invalid-rate", type=float, default=0.0)
    p.add_argument("--invalid-mode", type=str, default="missing_field")
    p.add_argument("--duplicate-rate", type=float, default=0.0)
    p.add_argument("--late-events", type=str, default="false")
    p.add_argument("--max-late-minutes", type=int, default=0)
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()

    cfg = ProducerConfig(
        rate=args.rate,
        duration_s=parse_duration(args.duration),
        seed=args.seed,
        invalid_rate=args.invalid_rate,
        duplicate_rate=args.duplicate_rate,
        late_events=args.late_events.lower() == "true",
        max_late_minutes=args.max_late_minutes,
        dry_run=args.dry_run,
    )
    print(f"[order_producer] config={cfg}")
    print("[order_producer] (skeleton) wire confluent-kafka in Phase 4.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
