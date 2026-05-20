# topologies/

DSX Air topology JSON files. Each is committed and re-deployable via:

```bash
make sim-create TOPOLOGY=topologies/01-data-platform-mvp.json
```

## Files

| File | Purpose | Nodes | vCPU | RAM | Compute hr/h |
|---|---|---:|---:|---:|---:|
| `00-foundation-evpn.dot` | DOT/GraphViz of the conceptual fabric | n/a | n/a | n/a | n/a |
| `01-data-platform-mvp.json` | MVP topology (Phase 0-5) | 6 + fabric | 22 | 46 GB | 27.75 |
| `02-data-platform-full.json` | Full extension topology | 9 + fabric | 30 | 56 GB | 37 |
| `03-burst-test.json` | Temporary burst (Phase 11) | 11 + fabric | 40 | 60 GB | 47.5 |

Run only **one** at a time. Switch by stopping the current sim and creating a new one (state persists in MinIO if exported beforehand).

## Validation

`make validate-topologies` enforces:
- required top-level keys (`name`, `nodes`, `links`)
- unique node names
- no node exceeds 60 GiB RAM (trial ceiling)
- explicit `storage` field for any data-bearing node

## Format reference

[NVIDIA DSX Air Custom Topology docs](https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Custom-Topology/)
