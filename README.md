<div align="center">

# Realtime Data + AI Platform Digital Twin
### on NVIDIA DSX Air — a Network-Fabric-Aware Lab

[![Status](https://img.shields.io/badge/status-blueprint--v2-blue)]()
[![Stack](https://img.shields.io/badge/stack-Redpanda%20%7C%20Flink%20%7C%20Iceberg%20%7C%20Trino%20%7C%20ClickHouse%20%7C%20Dagster-orange)]()
[![Infra](https://img.shields.io/badge/infra-DSX%20Air%20Simulation-76b900)]()
[![License](https://img.shields.io/badge/license-MIT-green)]()
[![ADRs](https://img.shields.io/badge/ADRs-10-purple)]()
[![Runbooks](https://img.shields.io/badge/runbooks-included-success)]()

**A production-inspired data + AI platform lab where the network fabric itself is part of the experiment.**

[Architecture](./ARCHITECTURE.md) · [Roadmap](./ROADMAP.md) · [ADRs](./adr) · [Runbooks](./runbooks) · [Chaos Catalog](./chaos) · [Benchmarks](./benchmarks)

</div>

---

## Why this repo exists

Most "modern data platform" GitHub projects stop at `docker compose up`. That proves you can install tools — not that you understand how a platform **behaves** under realistic stress, dirty data, late events, and **network fabric failure**.

This repo treats the **NVIDIA DSX Air simulation** as a **network-fabric digital twin** and layers a realistic event-driven data + AI platform on top of it. The differentiator: when other labs `docker stop kafka`, we **flap a VXLAN, fail a leaf switch, partition the EVPN underlay** and measure what the data platform actually does.

> **Build the platform → feed it realistic synthetic data → stress it with controlled scenarios → break the fabric beneath it → measure → recover → document.**

---

## What you'll see in this repo

```mermaid
mindmap
  root((Realtime<br/>Data + AI<br/>Platform))
    Infrastructure
      DSX Air simulation
      EVPN/VXLAN fabric
      OOB management plane
      Compute nodes (Ubuntu)
      Budget guard rails
    Event Backbone
      Redpanda topics
      Postgres CDC via Debezium
      Schema Registry
      DLQ + replay
    Stream Processing
      Flink jobs
      Event time + watermarks
      Stateful joins
      Checkpoint recovery
    Lakehouse
      MinIO object store
      Iceberg tables
      Bronze - Silver - Gold
      Time travel
    Batch
      Dagster assets
      Reconciliation jobs
      Backfill workflows
      Data quality gates
    Serving
      ClickHouse OLAP
      Redis online features
      FastAPI endpoints
      Grafana dashboards
    AI / RAG
      Qdrant vector DB
      Embedding pipeline
      RAG service
      Retrieval evaluation
    Observability
      Prometheus
      Grafana
      Loki
      OpenTelemetry
    Governance
      Data contracts
      OpenLineage + Marquez
      PII tokenization
      Ownership map
    Chaos
      Service failure
      Dirty data
      Late events
      Network fabric failure
    Operations
      Runbooks
      ADRs
      Benchmarks
      Cost guard
```

---

## High-level architecture

```mermaid
flowchart TB
    classDef users fill:#1e3a5f,stroke:#7fb8ff,color:#fff
    classDef serving fill:#5f3a1e,stroke:#ffb87f,color:#fff
    classDef processing fill:#3a5f1e,stroke:#b8ff7f,color:#fff
    classDef storage fill:#5f1e5f,stroke:#ff7fff,color:#fff
    classDef event fill:#5f1e3a,stroke:#ff7fb8,color:#fff
    classDef sources fill:#3a3a3a,stroke:#aaa,color:#fff
    classDef ai fill:#1e5f5f,stroke:#7fffff,color:#fff
    classDef obs fill:#5f5f1e,stroke:#ffff7f,color:#000

    U["Users / Apps / BI / AI Agents"]:::users

    subgraph SRV["Serving Layer"]
      direction LR
      API["FastAPI Edge"]:::serving
      CH["ClickHouse<br/>realtime OLAP"]:::serving
      RDS["Redis<br/>online features"]:::serving
      TR["Trino<br/>ad-hoc SQL"]:::serving
      GR["Grafana / Superset"]:::serving
    end

    subgraph AI["AI / RAG Layer"]
      direction LR
      QD["Qdrant<br/>vector store"]:::ai
      RAG["RAG service"]:::ai
      EVAL["Retrieval eval"]:::ai
    end

    subgraph PROC["Processing Layer"]
      direction LR
      FL["Flink<br/>stream processing"]:::processing
      DG["Dagster<br/>batch assets"]:::processing
      DQ["Great Expectations<br/>data quality"]:::processing
    end

    subgraph LH["Lakehouse Layer"]
      direction LR
      MIN["MinIO<br/>object store"]:::storage
      IC["Iceberg<br/>bronze - silver - gold"]:::storage
      PG["Postgres<br/>metastore"]:::storage
    end

    subgraph EVT["Event + Ingestion Layer"]
      direction LR
      RP["Redpanda topics"]:::event
      DBZ["Debezium CDC"]:::event
      SR["Schema Registry"]:::event
      DLQ["DLQ topics"]:::event
    end

    subgraph SRC["Source Systems"]
      direction LR
      OLTP["Postgres OLTP mock"]:::sources
      PROD["Synthetic producers<br/>clickstream / order /<br/>payment / fraud / inventory"]:::sources
    end

    subgraph OBS["Side planes"]
      direction LR
      PROM["Prometheus + Grafana + Loki"]:::obs
      LIN["OpenLineage + Marquez"]:::obs
      RBAC["Authz + Secrets + PII tokenization"]:::obs
    end

    U --> SRV
    U --> AI
    SRV --> LH
    SRV --> CH
    AI --> QD
    AI --> LH
    SRV --> PROC
    PROC --> LH
    PROC --> EVT
    LH --> EVT
    EVT --> SRC
    OBS -. observes .- SRV
    OBS -. observes .- PROC
    OBS -. observes .- EVT
    OBS -. observes .- LH
```

---

## The differentiator: network-fabric chaos

The story most labs miss. DSX Air gives us a **simulated EVPN/VXLAN fabric** between compute nodes. We can fail it deliberately and watch the data platform react.

```mermaid
flowchart LR
    subgraph FABRIC["DSX Air Network Fabric"]
        direction TB
        S1["Spine 1"] --- L1["Leaf 1"]
        S1 --- L2["Leaf 2"]
        S2["Spine 2"] --- L1
        S2 --- L2
    end

    subgraph RACK1["Rack 1 (Leaf 1)"]
        N1["redpanda-1"]
        N2["postgres + debezium"]
        N3["minio-1"]
    end

    subgraph RACK2["Rack 2 (Leaf 2)"]
        N4["flink-jm + tm"]
        N5["trino + clickhouse"]
        N6["dagster + observability"]
    end

    L1 --- N1
    L1 --- N2
    L1 --- N3
    L2 --- N4
    L2 --- N5
    L2 --- N6

    CHAOS["🌩 Chaos events"]
    CHAOS -. "flap VXLAN tunnel" .-> S1
    CHAOS -. "fail leaf switch" .-> L1
    CHAOS -. "partition spine" .-> S2
    CHAOS -. "BGP route flap" .-> L2

    style CHAOS fill:#5f1e1e,stroke:#ff7f7f,color:#fff
```

See [`docs/17-network-failure-storyline.md`](./docs/17-network-failure-storyline.md) and [`chaos/network/`](./chaos/network/).

---

## Build phases (bottom-up)

```mermaid
flowchart BT
    P0["Phase 0 — DSX Air foundation<br/>simulation, OOB, budget guard"]
    P1["Phase 1 — Network fabric<br/>EVPN + VXLAN + leaf/spine"]
    P2["Phase 2 — Compute platform<br/>Ubuntu nodes + Docker + Ansible"]
    P3["Phase 3 — Storage substrate<br/>MinIO + Postgres + persistent vols"]
    P4["Phase 4 — Event backbone<br/>Redpanda + CDC + Schema Registry + DLQ"]
    P5["Phase 5 — Stream processing<br/>Flink: funnel, risk, inventory"]
    P6["Phase 6 — Lakehouse<br/>Iceberg + Trino + bronze/silver/gold"]
    P7["Phase 7 — Batch + quality<br/>Dagster assets + GE + reconciliation"]
    P8["Phase 8 — Serving<br/>ClickHouse + Redis + FastAPI"]
    P9["Phase 9 — Observability + SLO<br/>Prometheus + Grafana + Loki"]
    P10["Phase 10 — Governance + AI<br/>contracts + lineage + Qdrant + RAG eval"]
    P11["Phase 11 — Chaos + benchmark<br/>service + data + network failure"]
    P12["Phase 12 — Packaging<br/>ADRs + runbooks + portfolio polish"]

    P0 --> P1 --> P2 --> P3 --> P4 --> P5 --> P6 --> P7 --> P8 --> P9 --> P10 --> P11 --> P12

    style P0 fill:#1e3a5f,color:#fff
    style P1 fill:#1e3a5f,color:#fff
    style P2 fill:#1e3a5f,color:#fff
    style P3 fill:#5f1e5f,color:#fff
    style P4 fill:#5f1e3a,color:#fff
    style P5 fill:#3a5f1e,color:#fff
    style P6 fill:#5f1e5f,color:#fff
    style P7 fill:#3a5f1e,color:#fff
    style P8 fill:#5f3a1e,color:#fff
    style P9 fill:#5f5f1e,color:#000
    style P10 fill:#1e5f5f,color:#fff
    style P11 fill:#5f1e1e,color:#fff
    style P12 fill:#3a3a3a,color:#fff
```

The first **6 phases** = MVP (shippable portfolio). See [`ROADMAP.md`](./ROADMAP.md).

---

## MVP-first timeline (Gantt)

```mermaid
gantt
    title 6-week MVP, then extension months
    dateFormat YYYY-MM-DD
    axisFormat %b %d

    section MVP (Phase 0-5)
    P0 DSX Air foundation          :p0, 2026-06-01, 5d
    P1 Network fabric              :p1, after p0, 5d
    P2 Compute + Docker            :p2, after p1, 4d
    P3 Storage substrate           :p3, after p2, 3d
    P4 Event backbone + CDC        :p4, after p3, 7d
    P5 First Flink job             :p5, after p4, 7d
    MVP ship                       :milestone, after p5, 0d

    section Extension
    P6 Lakehouse Iceberg           :p6, after p5, 10d
    P7 Batch + quality             :p7, after p6, 7d
    P8 Serving layer               :p8, after p7, 7d

    section Polish
    P9 Observability + SLO         :p9, after p8, 7d
    P10 Governance + AI/RAG        :p10, after p9, 14d
    P11 Chaos + benchmark          :p11, after p10, 10d
    P12 ADRs + runbooks            :p12, after p11, 7d
```

---

## Domain modeled

E-commerce + payment + fraud, with banking-grade correctness expectations.

```mermaid
sequenceDiagram
    autonumber
    actor Customer
    participant Web as Web/App
    participant OLTP as Postgres OLTP
    participant Bus as Redpanda topics
    participant Flink as Flink jobs
    participant LH as Iceberg lakehouse
    participant CH as ClickHouse
    participant API as FastAPI

    Customer->>Web: browse → add_to_cart → checkout
    Web->>OLTP: write order
    OLTP-->>Bus: cdc.orders.v1 (Debezium)
    Web->>Bus: ecom.checkout_started.v1
    Customer->>Web: pay
    Web->>Bus: payment.authorized.v1
    Bus->>Flink: stream
    Flink->>Flink: enrich + risk score + dedup
    Flink->>CH: realtime aggregates
    Flink->>LH: bronze + silver
    LH->>LH: Dagster builds gold tables
    Customer->>API: GET /risk/customer/{id}
    API->>CH: read realtime metric
    API->>LH: read gold features
    API-->>Customer: response p95 < 2s
```

---

## Stack — kill-your-darlings choices

Each row has an ADR explaining what was rejected and why.

| Slot | Choice | Rejected | ADR |
|---|---|---|---|
| Event backbone | **Redpanda** | Kafka, NATS JetStream | [ADR-0002](./adr/0002-redpanda-over-kafka.md) |
| Stream processing | **Flink** | Spark Structured Streaming, Kafka Streams | [ADR-0003](./adr/0003-flink-over-spark-streaming.md) |
| Lakehouse table | **Iceberg** | Delta, Paimon, Hudi | [ADR-0004](./adr/0004-iceberg-over-delta-paimon.md) |
| Batch orchestrator | **Dagster** | Airflow, Prefect | [ADR-0005](./adr/0005-dagster-over-airflow.md) |
| Lineage | **OpenLineage + Marquez** | DataHub, OpenMetadata | [ADR-0006](./adr/0006-marquez-over-datahub.md) |
| Realtime OLAP | **ClickHouse** | Apache Pinot, Druid | [ADR-0007](./adr/0007-clickhouse-for-realtime-serving.md) |
| CDC | **Debezium → Redpanda** | Fivetran, Airbyte | covered in ADR-0002 |
| Vector DB | **Qdrant** | Weaviate, Milvus, pgvector | — |
| Query | **Trino** | Presto, DuckDB | — |
| Online cache | **Redis** | Memcached, DragonflyDB | — |

---

## Repository layout

```text
.
├── README.md                    ← you are here
├── ARCHITECTURE.md              ← deep dive with all diagrams
├── ROADMAP.md                   ← MVP-then-extend timeline
├── docs/                        ← per-layer design docs (20 files)
├── adr/                         ← 10 architecture decision records
├── topologies/                  ← DSX Air topology JSON files
├── dsx-air/                     ← DSX Air SDK scripts + budget guard
├── infra/                       ← Ansible playbooks + bootstrap scripts
├── platform/                    ← docker-compose per session
├── producers/                   ← synthetic event generators
├── schemas/                     ← JSON Schema + event contracts
├── streaming/flink/             ← 4 Flink jobs
├── batch/dagster/               ← Dagster assets + jobs
├── lakehouse/                   ← Iceberg DDL + SQL
├── serving/                     ← FastAPI + ClickHouse DDL + Redis config
├── ai/                          ← Qdrant + RAG + evaluation
├── observability/               ← Prometheus + Grafana dashboards + Loki
├── governance/                  ← data contracts + ownership + PII + lineage
├── quality/                     ← Great Expectations suites
├── chaos/
│   ├── service/                 ← docker stop X
│   ├── data/                    ← dirty / late / duplicate injection
│   └── network/                 ← VXLAN flap, leaf-down, EVPN reroute  ← differentiator
├── runbooks/                    ← incident response playbooks
├── tests/                       ← connectivity / unit / integration
├── benchmarks/                  ← scenarios + results
└── .github/workflows/           ← CI / schema + topology validation
```

Full breakdown: [`docs/02-architecture-layers.md`](./docs/02-architecture-layers.md).

---

## Quickstart

```bash
# 1. clone + env
git clone <this-repo>
cd realtime-data-ai-platform-digital-twin
cp .env.example .env

# 2. provision DSX Air simulation (uses nv-air-sdk)
make sim-create TOPOLOGY=topologies/01-data-platform-mvp.json
make sim-start

# 3. bootstrap nodes (Docker, base packages)
make bootstrap

# 4. launch session A (event backbone + streaming)
make session-a-up

# 5. produce synthetic events
make produce-normal       # 100 eps for 10m
make produce-burst        # 1000 eps for 2m
make produce-dirty        # 5% invalid, 10m
make produce-late         # late events up to 30m

# 6. observe
make grafana              # opens dashboards

# 7. break things
make chaos-redpanda-down
make chaos-vxlan-flap     # network-level chaos
make chaos-leaf-down      # rack isolation

# 8. always tear down to save credits
make sim-stop
make budget-status        # how many compute hours left
```

Full Makefile reference: [`docs/04-compute-platform.md`](./docs/04-compute-platform.md).

---

## Non-goals (honest)

This is a **lab**, not production. It does not claim:

- Production-scale throughput. ClickHouse on a sim node ≠ ClickHouse on bare metal.
- Real benchmark numbers. Network is simulated; absolute latencies are not comparable.
- Hardened security or compliance. PII tokenization is **demonstrated**, not certified.
- Real-world data. All events are synthetic.
- 24/7 uptime. Simulation is stopped between sessions to save credits.

Full statement: [`docs/99-limitations-and-honesty.md`](./docs/99-limitations-and-honesty.md).

---

## Cost guard rails

DSX Air trial = 10,000 compute hours over 1 year. A forgotten weekend can burn 9% of budget. We solve this with:

- [`dsx-air/scripts/budget_guard.py`](./dsx-air/scripts/budget_guard.py) — cron auto-stops sim when daily burn > threshold.
- [`docs/19-cost-budget-guardrails.md`](./docs/19-cost-budget-guardrails.md) — the math + monitoring.

---

## References

NVIDIA DSX Air official:
- [User Guide](https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/)
- [Account Setup + billing](https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Account-Setup/)
- [Custom Topology](https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Custom-Topology/)
- [Simulation Management](https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Simulation-Management/)
- [API / SDK](https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/API-SDK/) · [`nv-air-sdk`](https://pypi.org/project/nv-air-sdk/)

OSS:
[Redpanda](https://redpanda.com) · [Debezium](https://debezium.io) · [Flink](https://flink.apache.org) · [Iceberg](https://iceberg.apache.org) · [Trino](https://trino.io) · [ClickHouse](https://clickhouse.com) · [MinIO](https://min.io) · [Dagster](https://dagster.io) · [Great Expectations](https://greatexpectations.io) · [OpenLineage](https://openlineage.io) · [Marquez](https://marquezproject.ai) · [Qdrant](https://qdrant.tech) · [Prometheus](https://prometheus.io) · [Grafana](https://grafana.com) · [FastAPI](https://fastapi.tiangolo.com)

---

<div align="center">

Built for Senior / Lead **Data + AI Platform Architect** portfolio.<br/>
[License: MIT](./LICENSE) · [Changelog](./CHANGELOG.md) · [Contributing](./CONTRIBUTING.md)

</div>
