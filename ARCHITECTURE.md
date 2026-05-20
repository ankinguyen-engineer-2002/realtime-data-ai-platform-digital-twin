# Architecture Deep Dive

> Visual + technical walkthrough of every layer, from physical fabric to RAG service.

**Companion files:** [README.md](./README.md) · [ROADMAP.md](./ROADMAP.md) · [docs/](./docs) · [adr/](./adr)

---

## Table of contents

1. [Architectural principles](#1-architectural-principles)
2. [Layered C4-style overview](#2-layered-c4-style-overview)
3. [Physical layer — DSX Air fabric](#3-physical-layer--dsx-air-fabric)
4. [Compute layer — node roles](#4-compute-layer--node-roles)
5. [Storage layer — persistent substrate](#5-storage-layer--persistent-substrate)
6. [Event layer — backbone + CDC](#6-event-layer--backbone--cdc)
7. [Stream processing layer](#7-stream-processing-layer)
8. [Lakehouse layer](#8-lakehouse-layer)
9. [Batch + quality layer](#9-batch--quality-layer)
10. [Serving layer](#10-serving-layer)
11. [AI / RAG layer](#11-ai--rag-layer)
12. [Observability + SLO layer](#12-observability--slo-layer)
13. [Governance + lineage](#13-governance--lineage)
14. [Security boundary](#14-security-boundary)
15. [Chaos engineering surface](#15-chaos-engineering-surface)
16. [Data flow end-to-end](#16-data-flow-end-to-end)
17. [Failure cascade reference](#17-failure-cascade-reference)

---

## 1. Architectural principles

1. **The fabric is part of the lab.** DSX Air's EVPN/VXLAN simulation is treated as a first-class component, not as invisible plumbing.
2. **Streaming for reaction, batch for correctness.** Both exist; neither replaces the other.
3. **Time-multiplexed sessions over kitchen-sink stack.** Run a focused subset, save credits, switch.
4. **Kill your darlings.** Every tool slot has exactly one choice + a documented rejection.
5. **Synthetic data is a feature, not a workaround.** Dirty / late / duplicate / burst are *designed in*.
6. **Document trade-offs as ADRs.** Senior signal = visible thinking, not visible diagrams.
7. **Recovery is the proof.** A platform that hasn't recovered from a documented failure hasn't been verified.

---

## 2. Layered C4-style overview

```mermaid
C4Container
    title Container view — Realtime Data + AI Platform Digital Twin

    Person(user, "User / Analyst / Agent", "BI, dashboards, APIs, RAG")

    System_Boundary(platform, "Data + AI Platform") {

        Container_Boundary(serving, "Serving") {
            Container(api, "FastAPI", "Python", "Edge APIs")
            Container(ch, "ClickHouse", "OLAP", "Realtime aggregates")
            Container(rds, "Redis", "cache", "Online features")
            Container(trino, "Trino", "SQL", "Ad-hoc lakehouse queries")
            Container(graf, "Grafana", "BI", "Dashboards + alerts")
        }

        Container_Boundary(ai, "AI / RAG") {
            Container(qdrant, "Qdrant", "vector DB", "embeddings")
            Container(rag, "RAG service", "FastAPI", "retrieval + LLM")
        }

        Container_Boundary(proc, "Processing") {
            Container(flink, "Flink", "JVM", "stream jobs")
            Container(dagster, "Dagster", "Python", "batch assets")
            Container(ge, "Great Expectations", "Python", "data quality")
        }

        Container_Boundary(lake, "Lakehouse") {
            ContainerDb(minio, "MinIO", "object store", "raw / bronze / silver / gold")
            ContainerDb(iceberg, "Iceberg catalog", "table format", "snapshots + schema evolution")
        }

        Container_Boundary(evt, "Event backbone") {
            Container(rp, "Redpanda", "broker", "topics + DLQ")
            Container(dbz, "Debezium", "connector", "Postgres CDC")
            ContainerDb(sr, "Schema Registry", "Avro/JSON", "contracts")
        }

        Container_Boundary(src, "Sources") {
            ContainerDb(pg, "Postgres OLTP", "RDBMS", "orders, customers, inventory")
            Container(prods, "Producers", "Python", "synthetic events")
        }

        Container_Boundary(obs, "Observability") {
            Container(prom, "Prometheus")
            Container(loki, "Loki")
            Container(otel, "OpenTelemetry collector")
        }

        Container_Boundary(gov, "Governance") {
            Container(marquez, "Marquez", "OpenLineage", "lineage graph")
        }
    }

    Rel(user, api, "queries", "HTTPS")
    Rel(user, graf, "dashboards", "HTTPS")
    Rel(user, rag, "RAG queries", "HTTPS")
    Rel(api, ch, "reads")
    Rel(api, rds, "reads")
    Rel(api, trino, "reads")
    Rel(rag, qdrant, "vector search")
    Rel(rag, trino, "context lookup")
    Rel(flink, rp, "consumes/produces")
    Rel(flink, ch, "sinks")
    Rel(flink, minio, "sinks via Iceberg")
    Rel(dagster, minio, "reads/writes")
    Rel(dagster, ge, "quality checks")
    Rel(dbz, pg, "CDC")
    Rel(dbz, rp, "emits")
    Rel(prods, rp, "produces")
    Rel(trino, iceberg, "queries")
    Rel(iceberg, minio, "metadata + data")
    Rel(marquez, dagster, "lineage events")
    Rel(marquez, flink, "lineage events")
```

---

## 3. Physical layer — DSX Air fabric

A spine-leaf topology with one OOB management plane and one data plane. This is what `topologies/01-data-platform-mvp.json` produces.

```mermaid
flowchart TB
    classDef spine fill:#1e3a5f,stroke:#7fb8ff,color:#fff
    classDef leaf fill:#3a1e5f,stroke:#b87fff,color:#fff
    classDef node fill:#3a3a3a,stroke:#aaa,color:#fff
    classDef oob fill:#5f5f1e,stroke:#ffff7f,color:#000

    subgraph OOB["OOB Management Plane (eth0)"]
        OOBSW["oob-mgmt-switch"]:::oob
        OOBSRV["oob-mgmt-server (bastion)"]:::oob
    end

    subgraph SPINE["Spine layer"]
        SP1["spine1<br/>Cumulus Linux"]:::spine
        SP2["spine2<br/>Cumulus Linux"]:::spine
    end

    subgraph LEAF["Leaf layer"]
        L1["leaf1"]:::leaf
        L2["leaf2"]:::leaf
        L3["leaf3"]:::leaf
    end

    subgraph RACK1["Rack 1 → leaf1"]
        N1["node-event<br/>redpanda + sr"]:::node
        N2["node-cdc<br/>postgres + debezium"]:::node
    end

    subgraph RACK2["Rack 2 → leaf2"]
        N3["node-stream<br/>flink jm + tm"]:::node
        N4["node-lake<br/>minio + iceberg"]:::node
    end

    subgraph RACK3["Rack 3 → leaf3"]
        N5["node-serve<br/>trino + clickhouse + redis + fastapi"]:::node
        N6["node-obs<br/>prom + grafana + loki + marquez"]:::node
    end

    SP1 ---|swp1| L1
    SP1 ---|swp2| L2
    SP1 ---|swp3| L3
    SP2 ---|swp1| L1
    SP2 ---|swp2| L2
    SP2 ---|swp3| L3

    L1 --- N1
    L1 --- N2
    L2 --- N3
    L2 --- N4
    L3 --- N5
    L3 --- N6

    OOBSW -.-> N1
    OOBSW -.-> N2
    OOBSW -.-> N3
    OOBSW -.-> N4
    OOBSW -.-> N5
    OOBSW -.-> N6
    OOBSRV --- OOBSW
```

**Design choices:**

- Two spines for ECMP + spine failure testing.
- Three leaves so we can isolate one rack at a time during chaos.
- All compute on data plane (swpX); OOB only for SSH / package pulls.
- EVPN/VXLAN encapsulates tenant traffic — flap a VTEP and watch Kafka ISR react.

See [`docs/03-network-fabric-design.md`](./docs/03-network-fabric-design.md).

---

## 4. Compute layer — node roles

| Node | Role | vCPU | RAM | Disk | Session |
|---|---|---:|---:|---:|---|
| `oob-mgmt-server` | bastion, runs Ansible | 2 | 2 GB | 10 GB | always |
| `node-event` | redpanda + schema registry | 4 | 8 GB | 80 GB | A, B, C |
| `node-cdc` | postgres + debezium + kafka-connect | 4 | 8 GB | 40 GB | A, B |
| `node-stream` | flink jobmanager + 1 taskmanager | 4 | 12 GB | 30 GB | A |
| `node-lake` | minio + iceberg rest catalog | 4 | 8 GB | 200 GB | A, B, C |
| `node-batch` | dagster + great expectations | 2 | 6 GB | 30 GB | B |
| `node-serve` | trino + clickhouse + redis + fastapi | 4 | 12 GB | 40 GB | B, C |
| `node-obs` | prometheus + grafana + loki + marquez | 4 | 8 GB | 50 GB | A, B, C |
| `node-ai` | qdrant + rag service + embeddings worker | 2 | 6 GB | 20 GB | C |

**Session sizing:**

| Session | Active nodes | vCPU | RAM | Compute hr/h |
|---|---|---:|---:|---:|
| Session A — Backbone + Stream | event, cdc, stream, lake, obs | 20 | 44 GB | 25.5 |
| Session B — Batch + Serve | event, cdc, batch, lake, serve, obs | 22 | 50 GB | 28.25 |
| Session C — AI + Governance | event, lake, serve, obs, ai | 18 | 42 GB | 23.25 |

Stays under the 60 vCPU / 60 GiB concurrent ceiling, with headroom.

See [`docs/04-compute-platform.md`](./docs/04-compute-platform.md) · [`docs/19-cost-budget-guardrails.md`](./docs/19-cost-budget-guardrails.md).

---

## 5. Storage layer — persistent substrate

```mermaid
flowchart LR
    subgraph PG["Postgres (OLTP source + metastore)"]
        PG_OLTP["oltp DB<br/>customers, orders, inventory"]
        PG_META["metastore DB<br/>iceberg REST, marquez, dagster"]
    end

    subgraph MINIO["MinIO buckets"]
        B_RAW["raw/<br/>landed JSON"]
        B_BRONZE["bronze/<br/>iceberg tables"]
        B_SILVER["silver/<br/>cleaned, deduped"]
        B_GOLD["gold/<br/>kpi tables"]
        B_LIN["lineage/<br/>marquez events"]
        B_RAG["rag-docs/<br/>support / policy docs"]
    end

    subgraph LOCAL["Node-local volumes"]
        V_KAFKA["redpanda segments"]
        V_FLINK["flink checkpoints"]
        V_PROM["prom TSDB"]
        V_LOKI["loki chunks"]
    end

    PG -. WAL .-> CDC[Debezium]
    CDC --> RP[Redpanda]
    RP --> Flink
    Flink -. checkpoint .-> V_FLINK
    Flink --> B_BRONZE
    Dagster --> B_SILVER
    Dagster --> B_GOLD
    PG_META -. tables .-> B_BRONZE
    PG_META -. tables .-> B_SILVER
    PG_META -. tables .-> B_GOLD
```

See [`docs/05-storage-layer.md`](./docs/05-storage-layer.md).

---

## 6. Event layer — backbone + CDC

```mermaid
flowchart LR
    classDef src fill:#3a3a3a,stroke:#aaa,color:#fff
    classDef topic fill:#5f1e3a,stroke:#ff7fb8,color:#fff
    classDef dlq fill:#5f1e1e,stroke:#ff7f7f,color:#fff

    PG_OLTP[("Postgres OLTP")]:::src
    PROD_CS["clickstream_producer"]:::src
    PROD_PAY["payment_producer"]:::src
    PROD_FRAUD["fraud_signal_producer"]:::src

    DBZ["Debezium connector"]
    PG_OLTP -- WAL --> DBZ

    DBZ --> T1["cdc.customers.v1"]:::topic
    DBZ --> T2["cdc.orders.v1"]:::topic
    DBZ --> T3["cdc.inventory.v1"]:::topic

    PROD_CS --> T4["ecom.page_view.v1"]:::topic
    PROD_CS --> T5["ecom.add_to_cart.v1"]:::topic
    PROD_CS --> T6["ecom.checkout_started.v1"]:::topic
    PROD_PAY --> T7["payment.authorized.v1"]:::topic
    PROD_PAY --> T8["payment.failed.v1"]:::topic
    PROD_FRAUD --> T9["fraud.risk_signal.v1"]:::topic

    SR["Schema Registry"]
    T1 -.- SR
    T7 -.- SR
    T9 -.- SR

    T1 --> CONSUMER["Flink jobs"]
    T2 --> CONSUMER
    T4 --> CONSUMER
    T7 --> CONSUMER
    T9 --> CONSUMER

    CONSUMER -. invalid .-> DLQ["dlq.invalid_events.v1"]:::dlq
    CONSUMER -. malformed .-> DLQ
```

Topic naming convention: `{domain}.{event_type}.v{schema_version}`. Schema lives in [`schemas/`](./schemas/).

See [`docs/06-event-backbone.md`](./docs/06-event-backbone.md) · [`docs/07-cdc-design.md`](./docs/07-cdc-design.md).

---

## 7. Stream processing layer

Four Flink jobs, each with a clear streaming-concept showcase.

```mermaid
flowchart TB
    classDef job fill:#3a5f1e,stroke:#b8ff7f,color:#fff
    classDef topic fill:#5f1e3a,stroke:#ff7fb8,color:#fff
    classDef sink fill:#5f3a1e,stroke:#ffb87f,color:#fff

    subgraph IN["Input topics"]
        I1["ecom.page_view.v1"]:::topic
        I2["ecom.add_to_cart.v1"]:::topic
        I3["ecom.checkout_started.v1"]:::topic
        I4["cdc.orders.v1"]:::topic
        I5["payment.authorized.v1"]:::topic
        I6["payment.failed.v1"]:::topic
        I7["fraud.risk_signal.v1"]:::topic
        I8["cdc.inventory.v1"]:::topic
        I9["shipment.created.v1"]:::topic
    end

    J1["Job 1 — order funnel<br/>event-time window, sessionization"]:::job
    J2["Job 2 — payment risk<br/>stateful join, online features"]:::job
    J3["Job 3 — inventory availability<br/>CDC + stream join, compacted topic"]:::job
    J4["Job 4 — lakehouse sink<br/>exactly-once Iceberg write"]:::job

    I1 --> J1
    I2 --> J1
    I3 --> J1
    I4 --> J1
    I5 --> J2
    I6 --> J2
    I7 --> J2
    I4 --> J3
    I8 --> J3
    I9 --> J3

    I1 --> J4
    I4 --> J4
    I5 --> J4
    I7 --> J4
    I8 --> J4

    J1 --> S1["clickhouse.realtime_funnel"]:::sink
    J2 --> S2["clickhouse.transaction_risk_score"]:::sink
    J2 --> S3["redis.online_risk:{customer_id}"]:::sink
    J3 --> S4["clickhouse.inventory_availability"]:::sink
    J3 --> S5["redis.stock:{sku}"]:::sink
    J4 --> S6["iceberg.bronze.* + silver.*"]:::sink
```

See [`docs/08-stream-processing.md`](./docs/08-stream-processing.md).

---

## 8. Lakehouse layer

Bronze → Silver → Gold with explicit ownership.

```mermaid
flowchart LR
    classDef bronze fill:#7f4f1e,stroke:#ffb87f,color:#fff
    classDef silver fill:#5f5f5f,stroke:#ccc,color:#fff
    classDef gold fill:#7f6f1e,stroke:#ffd700,color:#000

    subgraph BR["Bronze — raw normalized"]
        B1["bronze.events_clickstream"]:::bronze
        B2["bronze.events_payment"]:::bronze
        B3["bronze.cdc_orders"]:::bronze
        B4["bronze.cdc_inventory"]:::bronze
    end

    subgraph SV["Silver — cleaned, deduped, conformed"]
        S1["silver.fact_clickstream"]:::silver
        S2["silver.fact_payment"]:::silver
        S3["silver.fact_order"]:::silver
        S4["silver.dim_customer_scd2"]:::silver
        S5["silver.dim_product_scd2"]:::silver
    end

    subgraph GD["Gold — KPI / served"]
        G1["gold.daily_revenue"]:::gold
        G2["gold.order_funnel_hourly"]:::gold
        G3["gold.payment_success_rate"]:::gold
        G4["gold.fraud_alert_summary"]:::gold
        G5["gold.inventory_availability"]:::gold
        G6["gold.delivery_sla"]:::gold
    end

    B1 --> S1
    B2 --> S2
    B3 --> S3
    B3 --> S4
    B4 --> S5

    S1 --> G2
    S2 --> G1
    S2 --> G3
    S2 --> G4
    S3 --> G1
    S3 --> G2
    S3 --> G6
    S5 --> G5
```

See [`docs/09-lakehouse-design.md`](./docs/09-lakehouse-design.md).

---

## 9. Batch + quality layer

```mermaid
flowchart LR
    classDef asset fill:#1e5f3a,stroke:#7fffb8,color:#fff
    classDef check fill:#5f3a1e,stroke:#ffb87f,color:#fff

    subgraph DAG["Dagster asset graph"]
        A1["raw_events"]:::asset --> A2["bronze_events"]:::asset
        A2 --> Q1["GE check<br/>schema + null"]:::check
        Q1 --> A3["silver_facts"]:::asset
        A3 --> Q2["GE check<br/>dedup + ranges"]:::check
        Q2 --> A4["dim_customer_scd2"]:::asset
        Q2 --> A5["dim_product_scd2"]:::asset
        A4 --> A6["gold_kpis"]:::asset
        A5 --> A6
        A6 --> Q3["GE check<br/>row counts + freshness"]:::check
        Q3 --> A7["reconcile_payment_settlement"]:::asset
        A7 --> A8["publish_to_clickhouse"]:::asset
    end
```

Why Dagster instead of Airflow: assets > tasks for lakehouse work, lighter RAM, native data contracts. See [ADR-0005](./adr/0005-dagster-over-airflow.md).

---

## 10. Serving layer

```mermaid
sequenceDiagram
    autonumber
    actor U as Client
    participant API as FastAPI
    participant RDS as Redis
    participant CH as ClickHouse
    participant TR as Trino
    participant LH as Iceberg

    U->>API: GET /risk/customer/{id}
    API->>RDS: hot-path lookup
    alt cache hit
        RDS-->>API: risk_score (p95 < 20ms)
        API-->>U: 200 OK
    else cache miss
        API->>CH: query realtime aggregate
        CH-->>API: latest score
        API->>RDS: SETEX (ttl=60s)
        API-->>U: 200 OK
    end

    U->>API: GET /metrics/orders/realtime
    API->>CH: SELECT FROM realtime_funnel
    CH-->>API: rows
    API-->>U: 200 OK

    U->>API: GET /orders/{id}
    API->>TR: SELECT FROM silver.fact_order WHERE order_id=?
    TR->>LH: iceberg scan
    LH-->>TR: snapshot rows
    TR-->>API: rows
    API-->>U: 200 OK
```

See [`docs/11-serving-layer.md`](./docs/11-serving-layer.md).

---

## 11. AI / RAG layer

```mermaid
flowchart LR
    classDef doc fill:#3a3a3a,stroke:#aaa,color:#fff
    classDef proc fill:#1e5f5f,stroke:#7fffff,color:#fff
    classDef store fill:#5f1e5f,stroke:#ff7fff,color:#fff
    classDef api fill:#5f3a1e,stroke:#ffb87f,color:#fff

    DOC["Product / support / policy docs"]:::doc
    GOLD["Gold tables (context)"]:::doc

    EMB["Embedding worker<br/>sentence-transformers"]:::proc
    DOC --> EMB
    EMB --> QD["Qdrant<br/>vector store"]:::store

    USER["User question"] --> RAG["RAG service<br/>FastAPI"]:::api
    RAG -- hybrid search<br/>BM25 + vector --> QD
    RAG -- structured context --> TR2["Trino → gold"]:::store
    RAG -- prompt + context --> LLM["LLM (external API or local)"]:::proc
    LLM --> RAG
    RAG --> USER

    RAG -. trace .-> OTEL[OpenTelemetry]
    RAG -. eval .-> RAGAS["RAGAS / TruLens<br/>retrieval quality"]:::proc
```

Evaluation framework is mandatory — no half-baked RAG. See [`docs/15-ai-rag-layer.md`](./docs/15-ai-rag-layer.md).

---

## 12. Observability + SLO layer

```mermaid
flowchart TB
    classDef met fill:#5f5f1e,stroke:#ffff7f,color:#000
    classDef sig fill:#3a3a3a,stroke:#aaa,color:#fff

    subgraph SIG["Signal sources"]
        APP["Application metrics<br/>(FastAPI, Flink, Dagster)"]:::sig
        NODE["Node exporters<br/>CPU/RAM/disk/net"]:::sig
        KAFKA["Redpanda exporter<br/>lag, throughput"]:::sig
        FLINKM["Flink REST<br/>checkpoint, backpressure"]:::sig
        QUAL["GE checkpoint results"]:::sig
        OTEL["OpenTelemetry traces"]:::sig
        LOG["Service stdout logs"]:::sig
    end

    PROM["Prometheus<br/>TSDB"]:::met
    LOKI["Loki<br/>log store"]:::met
    TEMPO["Tempo (optional)<br/>trace store"]:::met

    APP --> PROM
    NODE --> PROM
    KAFKA --> PROM
    FLINKM --> PROM
    QUAL --> PROM
    LOG --> LOKI
    OTEL --> TEMPO

    GR["Grafana<br/>dashboards + alerts"]:::met
    PROM --> GR
    LOKI --> GR
    TEMPO --> GR

    ALERT["Alertmanager<br/>→ webhook / email"]:::met
    PROM --> ALERT
```

Documented SLOs:
- Pipeline freshness < 60s for realtime metrics
- DAG success > 99% in lab runs
- Data quality pass rate > 98%
- API p95 < 2s
- DLQ rate visible and explained

See [`docs/12-observability-slo.md`](./docs/12-observability-slo.md).

---

## 13. Governance + lineage

```mermaid
flowchart LR
    classDef contract fill:#1e3a5f,stroke:#7fb8ff,color:#fff
    classDef lin fill:#3a1e5f,stroke:#b87fff,color:#fff

    SR["Schema Registry<br/>JSON Schema + Avro"]:::contract
    CONT["data-contracts/<br/>YAML + examples"]:::contract
    OWN["data-ownership.md<br/>domain → team map"]:::contract
    PII["pii-classification.md<br/>field tags"]:::contract

    OL["OpenLineage emitters<br/>Flink + Dagster + Trino"]:::lin
    MQ["Marquez UI<br/>dataset lineage graph"]:::lin

    OL --> MQ
    SR -. validates .-> EVENTS["produced events"]
    CONT -. references .-> SR
    PII -. tags fields in .-> SR
    MQ -. annotates .-> LH["lakehouse tables"]
```

PII path is concrete:
1. `payment.authorized.v1` tags `card_number` as `pii=true, tokenize=true`
2. Flink `lakehouse_sink_job` tokenizes before bronze write
3. Silver / gold never contain raw PAN
4. Marquez tags the dataset as `pii.tokenized=true`

See [`docs/13-governance-lineage.md`](./docs/13-governance-lineage.md).

---

## 14. Security boundary

```mermaid
flowchart TB
    classDef ext fill:#5f1e1e,stroke:#ff7f7f,color:#fff
    classDef edge fill:#5f3a1e,stroke:#ffb87f,color:#fff
    classDef int fill:#1e3a5f,stroke:#7fb8ff,color:#fff
    classDef sec fill:#3a3a3a,stroke:#aaa,color:#fff

    INTERNET["Internet (your laptop)"]:::ext
    BASTION["oob-mgmt-server<br/>SSH gateway"]:::edge

    subgraph EDGE["Edge (exposed)"]
        API_E["FastAPI :8000"]:::edge
        GR_E["Grafana :3000"]:::edge
        MQ_E["Marquez UI :3001"]:::edge
    end

    subgraph INTERNAL["Internal (data plane only)"]
        RP_I["Redpanda 9092 SASL/SCRAM"]:::int
        MIN_I["MinIO 9000 access key"]:::int
        PG_I["Postgres 5432 cert auth"]:::int
        CH_I["ClickHouse 8123 user/pass"]:::int
    end

    subgraph SECS["Secrets"]
        SOPS["SOPS + age<br/>encrypted .env"]:::sec
        VAULT["(optional) HashiCorp Vault"]:::sec
    end

    INTERNET --> BASTION
    BASTION --> EDGE
    EDGE --> INTERNAL
    SOPS -. provides .-> INTERNAL
```

What's enforced:
- Kafka SASL/SCRAM + ACLs per topic per producer
- Trino group-based catalog access
- Dagster RBAC + Fernet key rotation
- Loki audit query log
- PII tokenization documented + tested

See [`docs/14-security-zero-trust.md`](./docs/14-security-zero-trust.md).

---

## 15. Chaos engineering surface

```mermaid
mindmap
  root((Chaos<br/>catalog))
    Service
      docker stop redpanda
      docker stop flink-tm
      docker stop minio
      docker stop postgres
    Data
      bad schema injection
      late events up to 30m
      duplicate event_id
      negative payment amount
      unknown customer_id
    Network ★ DSX Air sweet spot
      VXLAN tunnel flap
      leaf switch down
      ISL link down
      EVPN BGP route flap
      spine outage
      network partition
      asymmetric packet loss
    Resource
      CPU stress
      RAM pressure
      disk full
```

Network-fabric chaos is the differentiator. See [`docs/17-network-failure-storyline.md`](./docs/17-network-failure-storyline.md) and [`chaos/network/`](./chaos/network/).

---

## 16. Data flow end-to-end

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Web
    participant OLTP as Postgres
    participant Producer as Synthetic producer
    participant DBZ as Debezium
    participant RP as Redpanda
    participant Flink
    participant CH as ClickHouse
    participant Redis
    participant Iceberg
    participant Dagster
    participant GE as Great Expectations
    participant API as FastAPI

    User->>Web: browse → add_to_cart
    Web->>Producer: emit ecom.add_to_cart.v1
    Producer->>RP: produce
    User->>Web: checkout
    Web->>OLTP: INSERT order
    OLTP-->>DBZ: WAL
    DBZ->>RP: cdc.orders.v1
    User->>Web: pay
    Web->>Producer: emit payment.authorized.v1
    Producer->>RP: produce

    par streaming path
        RP->>Flink: subscribe
        Flink->>Flink: dedup + window + risk score
        Flink->>CH: realtime aggregate
        Flink->>Redis: online feature
        Flink->>Iceberg: bronze + silver write (exactly-once)
    and quality path
        Flink->>RP: dlq.invalid_events.v1 (rejected)
    end

    Note over Dagster,Iceberg: every hour
    Dagster->>Iceberg: build gold tables
    Dagster->>GE: run checkpoint
    GE-->>Dagster: pass / fail
    Dagster->>CH: publish gold to serving

    User->>API: GET /risk/customer/{id}
    API->>Redis: lookup
    Redis-->>API: score
    API-->>User: 200 OK (p95 < 20ms)
```

---

## 17. Failure cascade reference

What breaks when *X* fails, and what stays alive.

```mermaid
flowchart TB
    classDef fail fill:#5f1e1e,stroke:#ff7f7f,color:#fff
    classDef degraded fill:#5f5f1e,stroke:#ffff7f,color:#000
    classDef alive fill:#1e5f1e,stroke:#7fff7f,color:#fff

    F1["Redpanda down"]:::fail --> D1["Producers buffer + back off"]:::degraded
    F1 --> D2["Flink job restarts, replays from offset"]:::degraded
    F1 --> A1["ClickHouse keeps serving last data"]:::alive
    F1 --> A2["Lakehouse reads still work via Trino"]:::alive

    F2["Flink TM down"]:::fail --> D3["Stream lag spikes"]:::degraded
    F2 --> D4["Checkpoint recovery on restart"]:::degraded
    F2 --> A3["ClickHouse / lake unaffected"]:::alive

    F3["MinIO down"]:::fail --> D5["Bronze/silver writes fail (DLQ)"]:::degraded
    F3 --> D6["Trino queries error"]:::degraded
    F3 --> A4["Realtime metrics in ClickHouse still served"]:::alive
    F3 --> A5["Redpanda buffers until retention"]:::alive

    F4["Leaf switch down (DSX Air)"]:::fail --> D7["Whole rack offline"]:::degraded
    F4 --> D8["Other racks see partition"]:::degraded
    F4 --> A6["Surviving racks: serving, lake — keep running"]:::alive

    F5["VXLAN flap"]:::fail --> D9["Brief packet loss"]:::degraded
    F5 --> D10["Kafka ISR shrink → restore"]:::degraded
    F5 --> D11["Flink checkpoint may slow"]:::degraded
```

This cascade map drives the runbooks. Each failure mode has a runbook entry in [`runbooks/`](./runbooks/).

---

## See also

- [`ROADMAP.md`](./ROADMAP.md) — phase-by-phase execution plan
- [`docs/17-network-failure-storyline.md`](./docs/17-network-failure-storyline.md) — the differentiator
- [`adr/`](./adr/) — every kill-your-darling decision
- [`runbooks/`](./runbooks/) — what to do when the cascade fires
