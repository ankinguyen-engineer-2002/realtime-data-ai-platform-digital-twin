"""Skeleton for producers. Real implementation lands in Phase 4."""
from __future__ import annotations

import dataclasses
import random
import time
import uuid
from typing import Iterator


@dataclasses.dataclass
class ProducerConfig:
    rate: float = 100.0
    duration_s: float = 600.0
    seed: int = 42
    invalid_rate: float = 0.0
    duplicate_rate: float = 0.0
    late_events: bool = False
    max_late_minutes: int = 0
    dry_run: bool = False


def parse_duration(s: str) -> float:
    """Parse '10m', '30s', '1h', or raw seconds."""
    if s.endswith("h"):
        return float(s[:-1]) * 3600
    if s.endswith("m"):
        return float(s[:-1]) * 60
    if s.endswith("s"):
        return float(s[:-1])
    return float(s)


def rate_limit(target_hz: float) -> Iterator[float]:
    """Yield monotonic times at the requested rate."""
    period = 1.0 / target_hz
    next_t = time.monotonic()
    while True:
        next_t += period
        sleep_for = next_t - time.monotonic()
        if sleep_for > 0:
            time.sleep(sleep_for)
        yield time.monotonic()


def event_id() -> str:
    return f"evt_{uuid.uuid4().hex[:12]}"


def maybe_invalidate(event: dict, mode: str, cfg: ProducerConfig) -> dict:
    """Apply a controlled invalidation if rolling under invalid_rate."""
    if random.random() >= cfg.invalid_rate:
        return event
    out = dict(event)
    out["_synthetic_label"] = mode
    if mode == "negative_amount" and "amount" in out:
        out["amount"] = -abs(out["amount"])
    elif mode == "missing_field":
        out.pop("currency", None)
    elif mode == "future_ts":
        out["event_time"] = "2099-01-01T00:00:00Z"
    elif mode == "wrong_type":
        out["amount"] = "not a number"
    return out
