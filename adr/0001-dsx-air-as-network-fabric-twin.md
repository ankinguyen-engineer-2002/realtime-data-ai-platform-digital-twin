# ADR-0001: Position DSX Air as a network-fabric twin, not a generic VM host

## Status

Accepted

## Date

2026-05-20

## Context

DSX Air is marketed as a cloud-hosted data center simulation platform for **AI factory infrastructure**, with a focus on Spectrum-X Ethernet, NVLink, Cumulus Linux switches, and SONiC. The trial offers 60 vCPU / 60 GiB / 10,000 compute hours over 1 year.

The naive interpretation is "DSX Air = AWS but cheap, let's run our data platform on it." That misuses the tool: nodes are simulation VMs with simulated network paths, not bare-metal compute. Benchmark numbers are not portable to production. Pulling images repeatedly costs bandwidth and credits.

But DSX Air has one unique capability **no other free environment offers**: a programmable EVPN/VXLAN fabric we can flap, fail, and route around — while a real data platform runs on top of it.

## Decision

We position DSX Air as a **network-fabric digital twin**. The data platform sits **on top of** the simulated fabric. The differentiating storyline is: *"data platform reaction to fabric failure."*

Concretely:
- All compute nodes run Ubuntu + Docker (general-purpose data services).
- Network topology is **explicitly designed** (3 leaf, 2 spine, EVPN/VXLAN) and version-controlled in `topologies/`.
- Chaos catalog **prioritizes network failure** (`chaos/network/`) alongside service failure (`chaos/service/`).
- README, ARCHITECTURE, and screencast lead with the fabric story.

## Alternatives considered

- **Treat DSX Air as cheap AWS** — Run docker-compose on one big node.
  - Attractive: simple, fast to ship.
  - Rejected: wastes the unique capability; same as any laptop demo.

- **Use DSX Air only for networking learning (week 1-3), move data platform to laptop** — Hybrid.
  - Attractive: cleaner separation, no credit pressure on data layer.
  - Rejected: loses the unified-story differentiator; two repos to maintain.

- **Run on a single cloud VM (Hetzner / Oracle Cloud free tier)** — Skip DSX Air.
  - Attractive: cheaper long-term, persistent.
  - Rejected: no network-fabric story; portfolio loses its hook.

## Consequences

### Positive
- Unique portfolio angle: "data platform meets network failure" is rare.
- Forces clear thinking about which failures are service-level vs fabric-level.
- Justifies the DSX Air choice (otherwise readers ask "why not just use $X?").

### Negative
- Benchmark numbers are not directly comparable to production. We must say so loudly.
- Some readers will not immediately see why network-level chaos matters.
- Requires real network design discipline (EVPN, VXLAN) — adds learning time.

### Neutral
- Network-failure tests do require Cumulus CLI familiarity. See [`docs/03-network-fabric-design.md`](../docs/03-network-fabric-design.md).

## References

- [NVIDIA DSX Air User Guide](https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/)
- [Design, Simulate, and Scale AI Factory Infrastructure with NVIDIA DSX Air](https://developer.nvidia.com/blog/design-simulate-and-scale-ai-factory-infrastructure-with-nvidia-dsx-air/)
- [`docs/17-network-failure-storyline.md`](../docs/17-network-failure-storyline.md)
