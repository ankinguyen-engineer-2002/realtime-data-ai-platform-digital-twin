# Contributing

This is primarily a portfolio / learning project, but contributions are welcome.

## Local development setup

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
pre-commit install
```

## PR checklist

- [ ] `make fmt` clean
- [ ] `make lint` clean
- [ ] `make test` green (or note why skipped)
- [ ] `make validate-schemas` green
- [ ] `make validate-topologies` green
- [ ] If you added a new tool: a new ADR in `adr/`
- [ ] If you changed an architecture diagram: README + ARCHITECTURE both updated
- [ ] If you added a runbook: linked from `runbooks/INDEX.md` + the relevant `chaos/` script
- [ ] If you added a benchmark scenario: result file in `benchmarks/results/`

## ADR process

1. Open a draft ADR using `adr/ADR-template.md`.
2. Status: `Proposed`.
3. Open a PR titled `ADR: <decision>`.
4. Discuss alternatives in the PR review.
5. Merge with status `Accepted` (or close as `Rejected`).

## Diagram conventions

- All diagrams are Mermaid (no PlantUML, no draw.io exports).
- Use the project color palette:
  - infra blue `#1e3a5f`
  - network purple `#3a1e5f`
  - storage magenta `#5f1e5f`
  - event red `#5f1e3a`
  - processing green `#3a5f1e`
  - serving orange `#5f3a1e`
  - AI cyan `#1e5f5f`
  - observability yellow `#5f5f1e`
  - chaos crimson `#5f1e1e`

## Commit style

Prefix:
- `feat:` new functionality
- `fix:` bug fix
- `docs:` docs only
- `chaos:` chaos scenario added/changed
- `adr:` ADR added/changed
- `infra:` Ansible / topology
- `bench:` benchmark result

## Reporting an issue

Use the issue templates in `.github/ISSUE_TEMPLATE/`.
