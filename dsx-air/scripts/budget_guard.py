#!/usr/bin/env python3
"""budget_guard.py — keep DSX Air compute usage within budget.

Run via cron every 15 minutes. Behaviour:

  daily_burn > BUDGET_DAILY_BURN_LIMIT_CH   → soft-stop running sims + alert
  total_used > BUDGET_TOTAL_HARD_LIMIT_CH   → hard-stop + freeze (require manual re-arm)
  --report-only                             → only print state, never stop

Reads config from environment (loaded from platform/env/.env or shell).
Telemetry written to ./.local/budget_guard.log (rotated weekly).

Author: Aric Nguyen, 2026
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import logging
import os
import pathlib
import sys
from dataclasses import dataclass
from typing import Any

LOG_DIR = pathlib.Path(".local")
LOG_DIR.mkdir(parents=True, exist_ok=True)
LOG_FILE = LOG_DIR / "budget_guard.log"
STATE_FILE = LOG_DIR / "budget_guard_state.json"
FREEZE_FILE = LOG_DIR / "budget_guard_frozen.flag"

log = logging.getLogger("budget_guard")
log.setLevel(logging.INFO)
fh = logging.FileHandler(LOG_FILE)
fh.setFormatter(logging.Formatter("%(asctime)s %(levelname)s %(message)s"))
log.addHandler(fh)
log.addHandler(logging.StreamHandler(sys.stdout))


# ---------- config ------------------------------------------------------------

@dataclass(frozen=True)
class Config:
    daily_burn_limit: float
    total_hard_limit: float
    total_soft_limit: float
    alert_email: str | None
    alert_slack_webhook: str | None
    nv_air_token: str | None
    nv_air_org_id: str | None
    api_url: str

    @classmethod
    def from_env(cls) -> "Config":
        return cls(
            daily_burn_limit=float(os.environ.get("BUDGET_DAILY_BURN_LIMIT_CH", 250)),
            total_hard_limit=float(os.environ.get("BUDGET_TOTAL_HARD_LIMIT_CH", 8500)),
            total_soft_limit=float(os.environ.get("BUDGET_TOTAL_SOFT_LIMIT_CH", 7000)),
            alert_email=os.environ.get("BUDGET_ALERT_EMAIL") or None,
            alert_slack_webhook=os.environ.get("BUDGET_ALERT_SLACK_WEBHOOK") or None,
            nv_air_token=os.environ.get("NV_AIR_TOKEN") or None,
            nv_air_org_id=os.environ.get("NV_AIR_ORG_ID") or None,
            api_url=os.environ.get("NV_AIR_API_URL", "https://air.nvidia.com/api/v2"),
        )


# ---------- DSX Air client (thin wrapper) -------------------------------------

def get_client(cfg: Config):
    """Lazy import nv-air-sdk so the module can be inspected without it installed."""
    try:
        from air_sdk import AirApi  # type: ignore
    except ImportError:
        log.error("nv-air-sdk not installed. pip install nv-air-sdk")
        sys.exit(2)
    if not cfg.nv_air_token:
        log.error("NV_AIR_TOKEN missing in environment")
        sys.exit(2)
    return AirApi(api_url=cfg.api_url, api_token=cfg.nv_air_token)


def fetch_usage(client) -> dict[str, Any]:
    """Return {'total_used_ch', 'today_used_ch', 'running_sims': [...]}."""
    # NB: API surface evolves; adapt field names as needed per nv-air-sdk version.
    org_usage = client.usage.get()  # type: ignore[attr-defined]
    today = dt.date.today()
    today_total = sum(
        e.compute_hours for e in org_usage.entries if e.date == today
    ) if hasattr(org_usage, "entries") else 0.0

    running = [s for s in client.simulations.list() if getattr(s, "state", "") == "RUNNING"]  # type: ignore[attr-defined]
    return {
        "total_used_ch": float(getattr(org_usage, "total_compute_hours", 0.0)),
        "today_used_ch": float(today_total),
        "running_sims": [{"id": s.id, "name": s.name} for s in running],
    }


def stop_sim(client, sim_id: str, checkpoint: bool = True) -> None:
    sim = client.simulations.get(sim_id)  # type: ignore[attr-defined]
    if checkpoint:
        sim.checkpoint()
    sim.stop()


# ---------- alerts ------------------------------------------------------------

def alert(cfg: Config, level: str, message: str) -> None:
    msg = f"[budget_guard:{level}] {message}"
    log.warning(msg)
    if cfg.alert_slack_webhook:
        try:
            import urllib.request as ur
            req = ur.Request(
                cfg.alert_slack_webhook,
                data=json.dumps({"text": msg}).encode(),
                headers={"Content-Type": "application/json"},
            )
            ur.urlopen(req, timeout=10)
        except Exception as e:  # noqa: BLE001
            log.error("slack alert failed: %s", e)
    # Email left as exercise — typically a small SES / SMTP helper.


# ---------- main --------------------------------------------------------------

def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--report-only", action="store_true",
                   help="never stop sims; only print and log")
    p.add_argument("--force-unfreeze", action="store_true",
                   help="remove freeze flag (manual re-arm after hard limit)")
    args = p.parse_args(argv)

    cfg = Config.from_env()

    if args.force_unfreeze:
        if FREEZE_FILE.exists():
            FREEZE_FILE.unlink()
            log.info("freeze removed manually")
        else:
            log.info("not frozen; nothing to do")
        return 0

    if FREEZE_FILE.exists() and not args.report_only:
        log.warning("budget is FROZEN (%s). pass --force-unfreeze to clear.",
                    FREEZE_FILE.read_text().strip())
        return 1

    client = get_client(cfg)
    usage = fetch_usage(client)

    log.info(
        "usage: total=%.1f ch (soft=%.0f, hard=%.0f) | today=%.1f ch (limit=%.0f) | running_sims=%d",
        usage["total_used_ch"],
        cfg.total_soft_limit,
        cfg.total_hard_limit,
        usage["today_used_ch"],
        cfg.daily_burn_limit,
        len(usage["running_sims"]),
    )

    STATE_FILE.write_text(json.dumps({**usage, "checked_at": dt.datetime.utcnow().isoformat()}, indent=2))

    if args.report_only:
        return 0

    # --- hard limit
    if usage["total_used_ch"] >= cfg.total_hard_limit:
        alert(cfg, "CRITICAL",
              f"TOTAL USAGE {usage['total_used_ch']:.1f} ≥ hard limit {cfg.total_hard_limit}. "
              f"Stopping {len(usage['running_sims'])} sims and freezing.")
        for s in usage["running_sims"]:
            stop_sim(client, s["id"])
        FREEZE_FILE.write_text(dt.datetime.utcnow().isoformat() + "\n")
        return 2

    # --- soft limit
    if usage["total_used_ch"] >= cfg.total_soft_limit:
        alert(cfg, "WARN",
              f"TOTAL USAGE {usage['total_used_ch']:.1f} ≥ soft limit {cfg.total_soft_limit}. "
              f"Sims still running; review needed.")

    # --- daily burn
    if usage["today_used_ch"] >= cfg.daily_burn_limit:
        alert(cfg, "WARN",
              f"TODAY BURN {usage['today_used_ch']:.1f} ≥ daily limit {cfg.daily_burn_limit}. "
              f"Soft-stopping {len(usage['running_sims'])} sims.")
        for s in usage["running_sims"]:
            stop_sim(client, s["id"])
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
