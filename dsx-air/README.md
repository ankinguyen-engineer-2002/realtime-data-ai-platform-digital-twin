# dsx-air/

> Scripts to manage the DSX Air simulation programmatically + budget guard rails.

All scripts use the official [`nv-air-sdk`](https://pypi.org/project/nv-air-sdk/).
Auth tokens come from `$NV_AIR_TOKEN` in your `.env`.

## Scripts

| Script | Purpose |
|---|---|
| `scripts/sim_list.py` | list simulations on this account |
| `scripts/sim_create.py` | create simulation from a topology JSON |
| `scripts/sim_start.py` | start a stopped simulation |
| `scripts/sim_stop.py` | stop (with optional checkpoint) |
| `scripts/sim_status.py` | status + uptime + estimated cost |
| `scripts/sim_export.py` | export topology + inventory.ini |
| `scripts/validate_topology.py` | static-validate topology JSON |
| `scripts/budget_guard.py` | cron-friendly guard that auto-stops on budget breach |
| `scripts/auto_stop_if_idle.py` | sidecar to stop sim when stack is idle |

## Cron suggestion

Add to crontab to enforce budget guard every 15 minutes:

```
*/15 * * * * cd /path/to/repo && /usr/bin/python3 dsx-air/scripts/budget_guard.py >> /var/log/dsx-budget.log 2>&1
```

## Token

Generate at: DSX Air Web UI → Account → API tokens. Store in `platform/env/.env`
under `NV_AIR_TOKEN`.

## References

- [DSX Air SDK](https://docs.nvidia.com/air/sdk/latest/)
- [API/SDK overview](https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/API-SDK/)
