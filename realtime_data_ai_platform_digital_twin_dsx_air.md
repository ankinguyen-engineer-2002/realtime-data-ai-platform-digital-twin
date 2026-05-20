# Realtime Data + AI Platform Digital Twin on NVIDIA DSX Air

> **Project blueprint / learning roadmap / GitHub packaging guide**  
> Người thực hiện: Data Engineer / Solution Data Architect / Data Platform Engineer muốn nâng cấp sang senior/lead-level Data + AI Platform Architect.  
> Mục tiêu: dùng NVIDIA DSX Air trial để học, mô phỏng, xây dựng và kiểm thử một nền tảng **hybrid batch + streaming + lakehouse + realtime serving + AI/RAG + observability + governance + failure testing** theo phong cách production-inspired.

---

## 0. Executive Summary

Dự án này không phải là một demo “cài vài service bằng Docker Compose”. Mục tiêu là xây dựng một **Data + AI Platform Digital Twin** trên NVIDIA DSX Air, mô phỏng cách một enterprise data platform hiện đại vận hành trong bối cảnh e-commerce / fintech / banking.

NVIDIA DSX Air là cloud-hosted data center simulation platform. Nó cho phép tạo simulation giống môi trường data center thật để validate configuration, feature, automation code, network architecture, topology, và platform behavior trước khi triển khai thật. Với trial hiện tại, tài nguyên gồm **60 concurrent vCPUs, 60 GiB concurrent memory, 10,000 compute hours/credits, duration 1 year**. Đây là tài nguyên rất phù hợp để học/vọc hạ tầng, network fabric, data platform, AI platform engineering và failure testing ở scale lab.

Dự án cuối cùng sẽ chứng minh:

- Bạn hiểu tầng **infra/network** bên dưới cloud: switch, routing, VLAN/VXLAN, EVPN, OOB management, network path, failure domain.
- Bạn build được tầng **platform**: Linux nodes, Docker/Kubernetes nhẹ, storage, database, observability.
- Bạn build được tầng **streaming + batch data platform**: CDC, Kafka/Redpanda, Flink, Airflow/Dagster, MinIO, Iceberg/Paimon, Trino, ClickHouse.
- Bạn build được tầng **data reliability**: data quality, DLQ, schema contracts, lineage, reconciliation, replay/backfill.
- Bạn build được tầng **AI platform**: embedding, vector DB, RAG API, batch scoring, monitoring.
- Bạn biết **đo, phá, phục hồi và viết runbook** như một platform engineer/architect.

Công thức cốt lõi của dự án:

> **Build a production-inspired platform, feed it realistic synthetic data, stress it with controlled scenarios, break it intentionally, measure behavior, document trade-offs and recovery.**

---

## 1. DSX Air là gì trong bối cảnh dự án này?

### 1.1 Không phải cloud thông thường

Nếu trước giờ bạn quen AWS/Azure/GCP:

```text
VPC → Subnet → EC2/EKS → Security Group → S3/RDS → Managed Services
```

thì DSX Air nên được hiểu như:

```text
Data center simulation → Switch/fabric → Server nodes → OOB management → Custom topology → Network + platform lab
```

Nói đơn giản:

- **AWS/Azure/GCP**: thuê hạ tầng thật/managed services để chạy workload.
- **DSX Air**: dựng mô hình data center/fabric/server để học, mô phỏng, validate và automation trước khi production.

Nó giống “sandbox / SimCity cho data center và AI factory infrastructure”.

### 1.2 DSX Air dùng tốt nhất cho gì?

Phù hợp:

- Học data center networking ở mức cần thiết cho Data/Platform Architect.
- Mô phỏng network topology, switch, routing, VLAN/VXLAN/EVPN.
- Tạo custom topology bằng drag-and-drop hoặc JSON/DOT.
- Launch pre-built demos từ Demo Marketplace.
- Tạo lab nhiều node để chạy Docker/Kubernetes nhẹ.
- Build data platform lab: streaming, batch, lakehouse, observability.
- Test automation code, CI/CD, bootstrap nodes.
- Failure testing: node down, service down, network issue, replay/recovery.
- Viết GitHub portfolio project production-inspired.

Không phù hợp:

- Host app cá nhân 24/7.
- Chạy production workload.
- Train model AI lớn.
- Đào coin / chạy bot / free VPS.
- Thay thế cloud provider như AWS/GCP/Azure.

---

## 2. Research chính thống: tài nguyên DSX Air có thực sự làm được không?

### 2.1 Trial resources

Theo NVIDIA DSX Air Account Setup documentation:

- Concurrent vCPUs: **60**
- Concurrent memory: **60 GiB**
- Compute hours / credits: **10,000**
- Duration: **1 year**
- Chỉ NGC organization owner mới start free trial.
- Billing tính theo compute hour và đo theo phút.

Nguồn chính thống:

- NVIDIA DSX Air Account Setup: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Account-Setup/

### 2.2 Compute hour là gì?

Từ NVIDIA docs:

> DSX Air bills usage by compute hour, measured down to the minute.

Cách hiểu thực tế:

```text
Compute hours mỗi giờ thực tế ≈ số vCPU đang chạy + (RAM GB đang chạy / 8)
```

Ví dụ:

```text
Lab nhỏ: 8 vCPU + 30 GB RAM
= 8 + 30/8
= 11.75 compute hours / giờ thực tế

10,000 / 11.75 ≈ 851 giờ chạy lab
```

Ví dụ lab vừa:

```text
12 vCPU + 48 GB RAM
= 12 + 48/8
= 18 compute hours / giờ thực tế

10,000 / 18 ≈ 555 giờ chạy lab
```

Ví dụ lab lớn sát quota:

```text
60 vCPU + 60 GB RAM
= 60 + 60/8
= 67.5 compute hours / giờ thực tế

10,000 / 67.5 ≈ 148 giờ chạy lab
```

Chiến lược sử dụng:

- Build nhỏ.
- Chạy theo session.
- Stop/sleep/checkpoint khi xong.
- Không để lab chạy qua đêm nếu không cần.
- Không bật full stack enterprise cùng lúc.
- Theo dõi Billing Overview thường xuyên.

### 2.3 Simulation lifecycle

DSX Air hỗ trợ start/stop simulation, checkpoint, resume. Khi stop và save checkpoint, bạn có thể lưu trạng thái để lần sau resume lại. Inactive simulation release resources, giúp tiết kiệm credit.

Nguồn chính thống:

- NVIDIA DSX Air Simulation Management: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Simulation-Management/

### 2.4 Demo Marketplace

DSX Air có pre-built demos/labs trong Demo Marketplace. Các demo này có thể clone để học best practices, thử feature, phá và rebuild.

Nguồn chính thống:

- NVIDIA DSX Air Pre-built Demos: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Pre-Built-Demos/

### 2.5 Custom Topology

DSX Air hỗ trợ custom topology bằng:

- Built-in drag-and-drop topology builder.
- Blank Canvas.
- JSON/DOT topology file.
- ZTP script.
- Export/import topology.

Nguồn chính thống:

- NVIDIA DSX Air Custom Topology: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Custom-Topology/
- NVIDIA DSX Air Quick Start: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Quick-Start/

### 2.6 OOB Management Network

OOB management network rất quan trọng. Mỗi simulation node thường có:

- Management interface, thường là `eth0`.
- Data interfaces, ví dụ `swp1`, `eth1`, dùng cho simulation traffic.

OOB giúp:

- SSH vào node.
- Tải package từ internet.
- Pull config.
- Tách management traffic khỏi production/data traffic.
- Mirror cách data center thật vận hành.

Nguồn chính thống:

- NVIDIA DSX Air OOB Management Network: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/OOB-Management-Network/

### 2.7 API/SDK

DSX Air có API/SDK để quản lý simulation programmatically. NVIDIA cung cấp `nv-air-sdk` Python SDK cho việc tạo, chạy, quản lý simulations.

Nguồn chính thống:

- NVIDIA DSX Air API/SDK: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/API-SDK/
- NVIDIA DSX Air SDK docs: https://docs.nvidia.com/air/sdk/latest/
- PyPI `nv-air-sdk`: https://pypi.org/project/nv-air-sdk/

### 2.8 Kết luận feasibility

Có thể làm:

| Layer | Có làm được trên DSX Air? | Ghi chú |
|---|---:|---|
| Switch/routing/VLAN/VXLAN/EVPN/network path | Có, rất phù hợp | Đây là core use case |
| Linux server/Docker/storage/database | Có | Chạy trên Ubuntu/server nodes |
| Kubernetes nhẹ | Có thể | Dùng k3s/kind, không kỳ vọng cluster lớn |
| Batch data platform | Có | Airflow/Dagster, MinIO, Trino, Spark nhẹ |
| Streaming platform | Có | Redpanda/Kafka, Flink ở scale lab |
| Lakehouse | Có | MinIO + Iceberg/Paimon/Parquet |
| Observability | Có | Prometheus, Grafana, Loki |
| Governance/lineage | Có thể | OpenLineage, Marquez, DataHub/OpenMetadata nếu đủ RAM |
| AI/RAG API | Có | Qdrant, FastAPI, embedding model nhỏ hoặc external API |
| Training model lớn | Không nên | Không phải GPU training platform |
| Production workload | Không | Đây là simulation/lab |

---

## 3. Vì sao kiến trúc ban đầu quá đơn giản?

Kiến trúc đầu tiên:

```text
User/API
  → RAG API / BI API
  → Vector DB / Trino
  → MinIO
  → Airflow/Dagster
  → Mock ingestion
  → Postgres
```

là bản “hello world” để hiểu DSX Air và data platform cơ bản. Nó chưa đại diện cho e-commerce/fintech/banking hiện đại vì thiếu:

- Event streaming backbone.
- CDC.
- Stream processing.
- Schema Registry.
- DLQ.
- Replay/backfill.
- Realtime serving.
- Lakehouse streaming ingest.
- Governance/lineage.
- Data contracts.
- Failure/recovery testing.
- Consumer lag/backpressure/checkpoint monitoring.
- Batch-stream reconciliation.

Với e-commerce, fintech, banking, platform thực tế cần hybrid:

```text
Streaming for reaction
Batch for correctness
Lakehouse for history
Serving store for low latency
Governance for trust
Observability for operations
Failure testing for reliability
```

---

## 4. Dự án chốt: Realtime Data + AI Platform Digital Twin

### 4.1 Tên project đề xuất

```text
realtime-data-ai-platform-digital-twin
```

hoặc:

```text
dsx-air-realtime-data-platform
```

Tagline:

> A production-inspired real-time data and AI platform lab built on NVIDIA DSX Air, covering event streaming, CDC, stream processing, lakehouse, observability, governance, and failure testing.

### 4.2 Domain mô phỏng

Chọn domain lai giữa **e-commerce + fintech/payment**:

```text
Realtime Order, Payment, Fraud, Inventory and Fulfillment Platform
```

Lý do:

- E-commerce cần clickstream, order, inventory, fulfillment.
- Fintech/payment cần transaction, fraud, reconciliation, auditability.
- Banking mindset cần correctness, governance, schema contract, lineage, replay, compliance.

### 4.3 Business flow mô phỏng

```text
Customer browses product
→ product_viewed
→ add_to_cart
→ checkout_started
→ payment_authorized / payment_failed
→ fraud_risk_signal
→ order_created
→ inventory_reserved
→ shipment_created
→ delivery_updated
→ return_requested
→ refund_issued
```

### 4.4 Mục tiêu kỹ thuật

Dự án phải chứng minh 5 năng lực:

```text
1. Build
2. Run
3. Measure
4. Break
5. Recover
```

Cụ thể:

- **Build**: tạo hạ tầng, services, pipelines.
- **Run**: tạo synthetic events, stream processing, batch jobs.
- **Measure**: dashboard/metrics/logs/data quality.
- **Break**: service failure, bad schema, dirty data, late events, duplicate events.
- **Recover**: replay, backfill, checkpoint, runbook.

---

## 5. Kiến trúc tổng thể

### 5.1 High-level architecture

```text
                           ┌──────────────────────┐
                           │ Users / Apps / BI / AI│
                           └──────────┬───────────┘
                                      │
                         ┌────────────▼────────────┐
                         │ API Gateway / Serving   │
                         │ REST / GraphQL / gRPC   │
                         └───────┬─────────┬───────┘
                                 │         │
                    ┌────────────▼─┐     ┌─▼─────────────┐
                    │ Realtime API │     │ BI / Analytics│
                    │ Redis/       │     │ Trino/Superset│
                    │ ClickHouse   │     │ Grafana       │
                    └──────┬───────┘     └──────┬────────┘
                           │                    │
┌──────────────────────────▼────────────────────▼─────────────────────────┐
│                         Serving / Query Layer                            │
│ Redis / ClickHouse / Trino / FastAPI / Grafana / Superset                 │
└──────────────────────────┬────────────────────┬─────────────────────────┘
                           │                    │
              ┌────────────▼───────┐   ┌────────▼─────────┐
              │ Lakehouse Tables   │   │ Feature Store    │
              │ Iceberg/Paimon     │   │ Redis/Custom     │
              └────────────┬───────┘   └────────┬─────────┘
                           │                    │
┌──────────────────────────▼────────────────────▼─────────────────────────┐
│                    Processing Layer                                      │
│ Batch: Airflow/Dagster + Spark/dbt/Python                                │
│ Streaming: Flink / Kafka Streams / Spark Structured Streaming             │
│ Jobs: enrichment, dedup, windowing, fraud/risk scoring, aggregation       │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
┌──────────────────────────▼───────────────────────────────────────────────┐
│                    Event + Ingestion Layer                                │
│ Kafka/Redpanda topics, Debezium CDC, producers, connectors, Schema Registry│
│ DLQ, replay, retention, compaction, partitioning, idempotent producers    │
└──────────────────────────┬───────────────────────────────────────────────┘
                           │
┌──────────────────────────▼───────────────────────────────────────────────┐
│                    Source Systems                                         │
│ OLTP DB, payment events, orders, inventory, web/app events, logs, CRM      │
└──────────────────────────────────────────────────────────────────────────┘

Side planes:
- Observability: Prometheus, Grafana, Loki, OpenTelemetry
- Governance: DataHub/OpenMetadata, OpenLineage/Marquez, Great Expectations/Soda
- Security: RBAC, secrets, audit logs, PII masking, network segmentation
- Infra: DSX Air nodes, switch/fabric, OOB management, failure testing
```

### 5.2 Infra side

```text
DSX Air Simulation
  ├── OOB Management Network
  ├── Data Plane Network
  ├── Optional EVPN/VXLAN Fabric
  ├── Bastion/Admin Node
  ├── Streaming Node(s)
  ├── Processing Node(s)
  ├── Storage Node(s)
  ├── Query/Serving Node(s)
  ├── Observability Node
  └── AI/API Node
```

### 5.3 Data side

```text
Sources
  ├── Postgres OLTP mock
  ├── Python synthetic producers
  ├── CDC via Debezium
  ├── Clickstream events
  ├── Payment events
  ├── Fraud/risk signals
  ├── Inventory events
  └── Shipment/return events

Event Backbone
  ├── Kafka/Redpanda
  ├── Topic partitions
  ├── Consumer groups
  ├── Offset management
  ├── Retention policy
  ├── Compaction topics
  ├── DLQ topics
  └── Replay strategy

Processing
  ├── Flink stream jobs
  ├── Airflow/Dagster batch jobs
  ├── Data quality checks
  ├── Batch reconciliation
  └── Backfill/replay jobs

Storage
  ├── MinIO raw zone
  ├── Bronze tables
  ├── Silver tables
  ├── Gold tables
  ├── Iceberg/Paimon metadata
  └── Postgres metadata DB

Serving
  ├── Trino ad-hoc analytics
  ├── ClickHouse realtime OLAP
  ├── Redis online features/cache
  ├── FastAPI serving APIs
  └── Grafana/Superset dashboards
```

---

## 6. Tooling stack

### 6.1 Core stack

| Need | Tool |
|---|---|
| Event backbone | Redpanda first, Kafka later |
| CDC | Debezium |
| Schema governance | Schema Registry / Redpanda schema registry-compatible feature |
| Stream processing | Flink |
| Object storage | MinIO |
| Lakehouse table format | Iceberg first, Paimon optional |
| Batch orchestration | Airflow first, Dagster optional |
| Query engine | Trino |
| Realtime OLAP | ClickHouse |
| Online serving/cache | Redis |
| Metadata DB | Postgres |
| Data quality | Great Expectations or Soda |
| Lineage | OpenLineage + Marquez |
| Catalog | DataHub/OpenMetadata optional |
| Observability | Prometheus + Grafana + Loki |
| API | FastAPI |
| Vector DB | Qdrant |
| AI/RAG | sentence-transformers small model or external embedding API |

### 6.2 Why these tools?

#### Redpanda/Kafka

Used as durable event backbone:

- Topics.
- Partitions.
- Consumer groups.
- Replay.
- Retention.
- Event-driven integration.
- Real-time streams.

Start with Redpanda because it is easier and lighter in lab. Later rebuild with Kafka 3 brokers if you want closer enterprise realism.

#### Flink

Used for stateful stream processing:

- Event-time processing.
- Watermarks.
- Window aggregation.
- Late event handling.
- Stateful joins.
- Checkpoint/recovery.
- Backpressure monitoring.
- Fraud/risk streaming rules.

Airflow is not a stream processor. Flink is for streaming.

#### Airflow/Dagster

Used for:

- Batch orchestration.
- Backfill.
- Reconciliation.
- Gold table build.
- Quality checks.
- Daily reports.
- Compaction jobs.
- Batch scoring.

#### MinIO

Used as S3-compatible object storage for the lake.

#### Iceberg/Paimon

Used to turn object storage into lakehouse tables:

- Schema evolution.
- Partitioning.
- Snapshots.
- Time travel.
- Streaming/batch interoperability.

Iceberg first for general lakehouse. Paimon optional for streaming lakehouse experiments.

#### Trino

Used for ad-hoc SQL and BI over lakehouse tables.

#### ClickHouse

Used for low-latency realtime analytics:

- Funnel metrics.
- Fraud dashboard.
- Payment success rate.
- Inventory stockout alerts.
- Operational dashboard.

#### Redis

Used for:

- Online features.
- Low-latency cache.
- Simple serving store.
- Risk score lookup.

#### Great Expectations/Soda

Used to validate data quality:

- Null checks.
- Range checks.
- Duplicate checks.
- Freshness checks.
- Schema checks.

#### OpenLineage/Marquez/DataHub/OpenMetadata

Used to show governance and lineage mindset. Optional if resource constrained.

#### Prometheus/Grafana/Loki/OpenTelemetry

Used to prove platform observability:

- Consumer lag.
- Flink checkpoint duration.
- Flink backpressure.
- Airflow DAG status.
- Data freshness.
- DLQ count.
- API latency.
- Node CPU/RAM/disk.
- Service uptime.

---

## 7. Node sizing and deployment strategy on DSX Air

### 7.1 Daily learning profile

Use this most days:

```text
Node 1: redpanda + redpanda-console
Node 2: postgres + debezium/connect
Node 3: flink jobmanager + taskmanager
Node 4: minio + iceberg catalog
Node 5: trino + clickhouse
Node 6: airflow + great expectations
Node 7: prometheus + grafana + loki
Node 8: fastapi + qdrant + redis
```

Estimated:

```text
12–18 vCPU
32–48 GB RAM
```

### 7.2 Resource-constrained profile

If you hit RAM limit:

```text
Node 1: redpanda + postgres + debezium
Node 2: flink
Node 3: minio + trino
Node 4: airflow + quality
Node 5: clickhouse + redis + fastapi
Node 6: observability
```

### 7.3 Larger test profile

Only run for short benchmark/failure tests:

```text
Kafka/Redpanda 3 nodes
Flink JobManager + 2 TaskManagers
MinIO
Postgres
Trino coordinator + worker
Airflow
ClickHouse
Prometheus/Grafana/Loki
```

Estimated:

```text
25–40 vCPU
50–60 GB RAM
```

### 7.4 Avoid all-in-one enterprise profile

Do not keep this running all the time:

```text
Kafka 3 brokers
Schema Registry
Kafka Connect
Debezium
Flink cluster
Spark
MinIO
Iceberg catalog
Trino cluster
ClickHouse/Pinot
Airflow
DataHub
OpenLineage
Prometheus
Grafana
Loki
Qdrant
FastAPI
```

This may exceed RAM or burn credits too fast. Instead:

- Build modularly.
- Turn on/off modules.
- Use smaller profiles.
- Stop/checkpoint often.

---

## 8. Synthetic data design

### 8.1 Why synthetic data is required

A GitHub project does not need production data or real users. But it absolutely needs:

```text
synthetic data
synthetic event stream
synthetic load
synthetic failures
synthetic business use case
measurable metrics
```

Without workload/data, repo only proves you can install tools. With realistic synthetic workload, repo proves you can design, operate, measure, and test a data platform.

### 8.2 Entities

```text
customers
products
inventory
orders
payments
shipments
returns
clickstream_events
fraud_signals
support_tickets
```

### 8.3 Event types

```text
customer_created
product_viewed
add_to_cart
checkout_started
payment_authorized
payment_failed
fraud_risk_signal
order_created
inventory_reserved
shipment_created
delivery_updated
return_requested
refund_issued
support_ticket_created
```

### 8.4 Topic naming

```text
cdc.customers.v1
cdc.products.v1
cdc.inventory.v1
cdc.orders.v1

ecom.page_view.v1
ecom.add_to_cart.v1
ecom.checkout_started.v1
ecom.order_created.v1

payment.authorized.v1
payment.failed.v1

fraud.risk_signal.v1

inventory.stock_changed.v1

shipment.created.v1
shipment.delivery_updated.v1

returns.return_requested.v1
returns.refund_issued.v1

dlq.invalid_events.v1
```

### 8.5 Example event schema

```json
{
  "event_id": "evt_123",
  "event_type": "payment_authorized",
  "event_time": "2026-05-20T10:15:00Z",
  "producer_time": "2026-05-20T10:15:01Z",
  "customer_id": "cus_001",
  "order_id": "ord_789",
  "amount": 249.99,
  "currency": "USD",
  "payment_method": "card",
  "risk_score": 0.72,
  "schema_version": "1.0"
}
```

### 8.6 Dirty data scenarios

Generate bad data intentionally:

```text
missing order_id
negative payment amount
duplicate event_id
late event by 30 minutes
unknown customer_id
invalid schema version
malformed JSON
future timestamp
missing currency
wrong data type
```

Expected behavior:

```text
valid events → processed
invalid events → DLQ
duplicates → deduplicated
late events → handled by watermark/window policy
schema errors → rejected or routed to DLQ
quality report → pass/fail clearly
```

---

## 9. Streaming design

### 9.1 Streaming jobs

#### Job 1 — Order funnel realtime

Input:

```text
page_view
add_to_cart
checkout_started
order_created
```

Output:

```text
realtime_funnel_metrics
```

Metrics:

```text
page_views
add_to_cart_count
checkout_started_count
orders_created_count
cart_abandonment_rate
checkout_conversion_rate
```

Concepts learned:

```text
event-time window
sessionization
late events
windowed aggregation
```

#### Job 2 — Payment/fraud risk

Input:

```text
payment_authorized
payment_failed
fraud_risk_signal
customer profile
device/IP signal
```

Output:

```text
transaction_risk_score
high_risk_alerts
```

Rules:

```text
more than 5 failed payments by same customer in 10 minutes
transaction amount > customer historical average * 5
multiple cards used by same customer in short window
high-risk device/IP
```

Concepts learned:

```text
stateful stream processing
window join
low-latency decisioning
online features
```

#### Job 3 — Inventory availability

Input:

```text
order_created
inventory_snapshot
inventory_stock_changed
shipment events
returns
```

Output:

```text
inventory_availability_realtime
stockout_alerts
```

Concepts learned:

```text
CDC + stream joins
eventual consistency
compacted topics
reconciliation
```

#### Job 4 — Streaming lakehouse sink

Input:

```text
validated event streams
```

Output:

```text
bronze/silver Iceberg or Paimon tables on MinIO
```

Concepts learned:

```text
streaming ingest to lakehouse
schema evolution
partitioning
compaction
```

#### Job 5 — Stream anomaly metrics

Input:

```text
payments
orders
inventory
shipments
```

Output:

```text
anomaly_alerts
```

Metrics:

```text
payment failure spike
order volume anomaly
delivery SLA drop
inventory stockout spike
```

### 9.2 Streaming concepts to explicitly document

```text
topic
partition
offset
consumer group
retention
compaction
event time
processing time
watermark
late event
state
checkpoint
savepoint
backpressure
exactly-once semantics
at-least-once semantics
idempotent sink
DLQ
replay
```

---

## 10. Batch design

### 10.1 Batch is not a replacement for streaming

Streaming handles reaction. Batch handles correctness, reconciliation, backfill, reporting.

Batch jobs:

```text
daily revenue reconciliation
payment settlement reconciliation
inventory snapshot reconciliation
late-arriving correction
gold KPI rebuild
ML batch scoring
data quality report
compaction job
```

### 10.2 Batch reconciliation example

```text
Stream-derived revenue today = 100,000
Payment settlement file = 99,850
Difference = 150
Generate discrepancy report
```

### 10.3 Airflow/Dagster DAG

```text
generate_mock_data
    >> upload_to_minio
    >> validate_raw
    >> transform_bronze
    >> transform_silver
    >> build_gold
    >> run_quality_checks
    >> reconcile_payments
    >> publish_reports
```

### 10.4 Batch outputs

```text
gold_daily_revenue
gold_order_fulfillment
gold_payment_reconciliation
gold_inventory_availability
gold_delivery_sla
gold_fraud_summary
```

---

## 11. Lakehouse design

### 11.1 Data zones

```text
raw/
  orders/date=YYYY-MM-DD/
  payments/date=YYYY-MM-DD/
  inventory/date=YYYY-MM-DD/
  clickstream/date=YYYY-MM-DD/

bronze/
  raw normalized event tables

silver/
  cleaned_orders
  cleaned_payments
  cleaned_inventory
  cleaned_clickstream
  shipment_events

gold/
  daily_revenue
  order_fulfillment_metrics
  payment_success_rate
  inventory_availability
  delivery_sla
  return_rate
  fraud_alert_summary
```

### 11.2 Iceberg/Paimon concepts

Document:

```text
schema evolution
partition evolution
snapshot
time travel
metadata files
small file problem
compaction
catalog
streaming writes
batch reads
```

### 11.3 Suggested first approach

Start with:

```text
MinIO + Parquet + Trino
```

Then upgrade to:

```text
MinIO + Iceberg + Trino
```

Then optional:

```text
MinIO + Paimon + Flink
```

---

## 12. Serving layer

### 12.1 Realtime serving

Use:

```text
ClickHouse for low-latency analytical queries
Redis for online features/cache
FastAPI for internal APIs
Grafana/Superset for dashboards
```

### 12.2 Serving APIs

Potential endpoints:

```text
GET /health
GET /metrics/orders/realtime
GET /metrics/payments/realtime
GET /metrics/inventory/realtime
GET /risk/customer/{customer_id}
GET /orders/{order_id}
GET /rag/query?q=...
```

### 12.3 Realtime dashboards

Dashboards:

```text
Order Funnel
Payment Success/Failure
Fraud Risk Alerts
Inventory Stockout
Delivery SLA
Consumer Lag
Pipeline Freshness
Data Quality
```

---

## 13. AI/RAG layer

### 13.1 Keep AI layer optional but meaningful

AI should not distract from the data platform. Use it as an upper layer that consumes curated data.

### 13.2 Use cases

```text
1. Ask business questions over gold metrics
2. Search product/support/order policy docs
3. Explain anomaly/fraud/inventory risk
4. Batch score inventory risk
```

### 13.3 Architecture

```text
Gold data / product docs / support docs
        ↓
Embedding job
        ↓
Qdrant vector DB
        ↓
FastAPI RAG service
        ↓
User/API
        ↓
Prometheus metrics + logs
```

### 13.4 Stack

```text
FastAPI
Qdrant
sentence-transformers small model or external embedding API
Postgres metadata
MinIO document store
Prometheus/Grafana
```

---

## 14. Observability and SLO

### 14.1 Metrics to collect

Infrastructure:

```text
node CPU
node RAM
node disk
container uptime
network reachability
```

Event streaming:

```text
producer rate
consumer lag
topic throughput
DLQ count
invalid event rate
duplicate event rate
```

Flink:

```text
checkpoint duration
checkpoint failure count
backpressure
records in/out
job restarts
watermark lag
state size
```

Batch:

```text
Airflow DAG success/failure
DAG runtime
task retries
backfill status
```

Data:

```text
data freshness
quality pass rate
row count anomalies
null count
duplicate count
schema validation failures
```

Serving:

```text
API latency
API error rate
ClickHouse query latency
Trino query latency
Redis hit rate
RAG latency
```

### 14.2 SLO examples

```text
Pipeline freshness: < 60 seconds for realtime metrics
DAG success rate: > 99% in lab runs
Data quality pass rate: > 98%
DLQ rate: visible and explained
API p95 latency: < 2 seconds in lab
Recovery after service restart: documented
Consumer lag clears after burst: documented
```

### 14.3 Alert examples

```text
RedpandaConsumerLagHigh
FlinkCheckpointFailure
FlinkBackpressureHigh
MinIODown
PostgresDown
ClickHouseDown
AirflowSchedulerDown
PipelineFreshnessTooHigh
DataQualityFailed
DLQSpike
DiskAlmostFull
```

---

## 15. Governance, data contracts, lineage

### 15.1 Schema contracts

Each event type should have:

```text
schema version
required fields
allowed types
compatibility policy
owner
examples
bad examples
```

### 15.2 Data ownership

Example:

```text
orders events → commerce domain
payments events → payment domain
fraud signals → risk domain
inventory events → supply chain domain
gold metrics → analytics platform
```

### 15.3 Lineage

Use OpenLineage/Marquez or document manually if resource constrained.

Lineage example:

```text
ecom.order_created.v1
  → flink_order_enrichment
  → bronze_orders
  → silver_orders
  → gold_order_fulfillment
  → dashboard_order_funnel
```

### 15.4 Governance docs

Create:

```text
docs/governance/data-contracts.md
docs/governance/data-ownership.md
docs/governance/pii-classification.md
docs/governance/lineage.md
```

---

## 16. Security boundary

### 16.1 Network planes

Document:

```text
management plane
data plane
service plane
observability plane
```

### 16.2 Access rules

Example:

```text
Only bastion can SSH to nodes.
Only Airflow can trigger batch jobs.
Only Flink writes realtime aggregates.
Only Trino reads lakehouse.
Only Grafana/FastAPI are exposed externally.
MinIO/Postgres/Redpanda are internal only.
```

### 16.3 Secrets

Do:

```text
Use .env templates
Do not commit passwords
Use local secret files
Document rotation process
```

Do not:

```text
Commit .env with real credentials
Expose unnecessary ports
Use production data
Use company confidential data
```

---

## 17. Failure testing and chaos scenarios

### 17.1 Why failure testing matters

A platform is not good because it runs on happy path. It is good if:

```text
failures are detected
impact is understood
recovery is documented
data is not silently corrupted
replay/backfill works
operators know what to do
```

### 17.2 Required failure tests

#### Test 1 — Redpanda/Kafka down

Action:

```bash
docker stop redpanda
```

Observe:

```text
producer errors
consumer lag
Flink behavior
alert fired
recovery after restart
replay behavior
```

#### Test 2 — Flink TaskManager down

Action:

```bash
docker stop flink-taskmanager
```

Observe:

```text
job failure/restart
checkpoint recovery
state recovery
output correctness
```

#### Test 3 — MinIO down

Action:

```bash
docker stop minio
```

Observe:

```text
lakehouse sink failures
Trino query failure
alerts
data recovery after replay
```

#### Test 4 — Postgres/CDC source down

Action:

```bash
docker stop postgres
```

Observe:

```text
CDC lag
Debezium connector behavior
downstream impact
recovery
```

#### Test 5 — Dirty event injection

Action:

```bash
make produce-dirty
```

Observe:

```text
invalid events go to DLQ
quality reports update
valid events still processed
```

#### Test 6 — Late event injection

Action:

```bash
make produce-late-events
```

Observe:

```text
watermark handling
late event policy
window correction behavior
```

#### Test 7 — Duplicate event injection

Action:

```bash
make produce-duplicates
```

Observe:

```text
dedup by event_id
no double-counted revenue
```

#### Test 8 — Network issue

Action:

```bash
sudo iptables -A INPUT -p tcp --dport 9000 -j DROP
```

Observe:

```text
timeout behavior
alerts
runbook
recovery after rule removal
```

### 17.3 Runbook template

```markdown
# Incident: <service/scenario>

## Symptoms
What the operator sees.

## Impact
What business/platform capability is affected.

## Detection
Which alert/dashboard/log identifies it.

## Immediate action
First response steps.

## Recovery
Step-by-step recovery.

## Data correctness check
How to verify no data loss/corruption.

## Prevention
What to improve.
```

---

## 18. Benchmark and validation strategy

### 18.1 Not production benchmark

This project should explicitly say:

> This lab is not designed to benchmark production-scale throughput. It is designed to validate architecture behavior under controlled synthetic workload: normal traffic, burst traffic, dirty events, late events, duplicate events, service failure, replay and recovery.

### 18.2 Required benchmark scenarios

| Scenario | Rate | Duration | Expected result |
|---|---:|---:|---|
| Normal stream | 100 eps | 10m | no lag / no data loss |
| Burst stream | 1,000 eps | 2m | temporary lag, clears after burst |
| Dirty events | 5% invalid | 10m | invalid routed to DLQ |
| Duplicate events | 2% duplicate | 10m | no double count |
| Late events | up to 30m late | 10m | handled by watermark policy |
| MinIO outage | 3m | n/a | alert + replay recovery |
| Flink restart | n/a | n/a | checkpoint recovery |

### 18.3 Metrics to record

```text
events produced
events consumed
events in DLQ
Flink processing latency
consumer lag max
consumer lag recovery time
ClickHouse insert latency
data freshness
pipeline success rate
CPU/RAM usage
service downtime
recovery time
```

### 18.4 Benchmark results file

Create:

```text
docs/benchmark-results.md
```

Template:

```markdown
# Benchmark Results

## Environment
- DSX Air simulation name:
- Node sizing:
- Stack version:
- Date:

## Scenario A: Normal stream
- Rate:
- Duration:
- Result:
- Observations:

## Scenario B: Burst stream
...

## Lessons learned
...
```

---

## 19. GitHub repo structure

Recommended structure:

```text
realtime-data-ai-platform-digital-twin/
  README.md
  Makefile
  docker-compose.yml
  .env.example
  LICENSE

  docs/
    00-project-overview.md
    01-dsx-air-setup.md
    02-architecture.md
    03-network-foundation.md
    04-oob-vs-data-plane.md
    05-custom-topology.md
    06-event-streaming.md
    07-cdc.md
    08-flink-stream-processing.md
    09-lakehouse.md
    10-batch-orchestration.md
    11-serving-layer.md
    12-ai-rag-layer.md
    13-observability-slo.md
    14-governance-lineage.md
    15-security-boundary.md
    16-failure-testing.md
    17-benchmark-results.md
    18-runbooks-index.md
    19-limitations.md

  topologies/
    dsx-air-foundation-evpn.json
    data-platform-v1.json
    data-platform-v2-streaming.json

  inventory/
    hosts.ini

  infra/
    ansible/
      bootstrap.yml
      install-docker.yml
      deploy-platform.yml
    scripts/
      bootstrap-node.sh
      install-docker.sh
      expose-services.md

  dsx-air/
    scripts/
      dsx_list_sims.py
      dsx_create_sim.py
      dsx_start_sim.py
      dsx_stop_sim.py
      dsx_export_topology.py
    README.md

  producers/
    clickstream_producer.py
    order_producer.py
    payment_producer.py
    inventory_producer.py
    fraud_signal_producer.py
    dirty_event_producer.py
    burst_producer.py

  schemas/
    ecom.order_created.v1.json
    payment.authorized.v1.json
    inventory.stock_changed.v1.json
    fraud.risk_signal.v1.json

  streaming/
    flink/
      order_funnel_job/
      payment_risk_job/
      inventory_availability_job/
      lakehouse_sink_job/

  batch/
    airflow/
      dags/
        retail_data_pipeline.py
        payment_reconciliation.py
        gold_metrics_build.py
    jobs/
      transform_bronze.py
      transform_silver.py
      build_gold.py
      reconcile_payments.py

  lakehouse/
    catalogs/
    sql/
      create_tables.sql
      gold_order_fulfillment.sql
      query_examples.sql

  serving/
    fastapi/
      main.py
      routes/
    clickhouse/
      ddl.sql
      materialized_views.sql
    redis/
      README.md

  ai/
    embed_documents.py
    rag_api.py
    batch_score_inventory_risk.py
    evaluate_retrieval.py

  observability/
    prometheus.yml
    alerts.yml
    grafana-dashboards/
    loki-config.yml

  governance/
    data-contracts.md
    data-ownership.md
    pii-classification.md
    lineage.md

  quality/
    great_expectations/
    soda/
    quality_rules.md

  tests/
    test_connectivity.py
    test_redpanda.py
    test_flink_jobs.py
    test_minio.py
    test_trino.py
    test_clickhouse.py
    test_quality.py
    test_api.py

  chaos/
    minio_down.sh
    redpanda_down.sh
    flink_restart.sh
    inject_bad_schema.sh
    network_block_minio.sh
    replay_dlq.sh

  runbooks/
    redpanda-down.md
    flink-job-failed.md
    minio-unavailable.md
    postgres-cdc-lag.md
    bad-schema-deployed.md
    consumer-lag-spike.md

  adr/
    0001-use-redpanda-for-local-event-streaming.md
    0002-use-flink-for-stream-processing.md
    0003-use-minio-and-iceberg-for-lakehouse.md
    0004-use-clickhouse-for-realtime-serving.md
    0005-use-airflow-for-batch-reconciliation.md
    0006-use-prometheus-grafana-for-observability.md
```

---

## 20. Makefile commands

The repo should feel reproducible.

```makefile
up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

produce-normal:
	python producers/order_producer.py --rate 100 --duration 10m

produce-burst:
	python producers/burst_producer.py --rate 1000 --duration 2m

produce-dirty:
	python producers/dirty_event_producer.py --invalid-rate 0.05 --duration 10m

produce-late:
	python producers/order_producer.py --late-events true --max-late-minutes 30

run-batch:
	airflow dags trigger retail_data_pipeline

test:
	pytest tests/

test-quality:
	python batch/jobs/run_quality_checks.py

chaos-minio-down:
	bash chaos/minio_down.sh

chaos-redpanda-down:
	bash chaos/redpanda_down.sh

chaos-flink-restart:
	bash chaos/flink_restart.sh

replay-dlq:
	bash chaos/replay_dlq.sh

benchmark-small:
	bash scripts/benchmark_small.sh

sim-list:
	python dsx-air/scripts/dsx_list_sims.py

sim-start:
	python dsx-air/scripts/dsx_start_sim.py

sim-stop:
	python dsx-air/scripts/dsx_stop_sim.py
```

---

## 21. Learning roadmap: 12 weeks

### Week 1 — DSX Air foundation

Learn:

```text
DSX Air UI
Demo Marketplace
Simulation lifecycle
OOB management
Node console
SSH
Topology
Checkpoint
```

Do:

```text
Launch CL5.16.1 - EVPN Symmetric Routing Best Practices
SSH into nodes
Run ip addr, ip route, ping, traceroute
Stop/checkpoint/start simulation
```

Output:

```text
docs/01-dsx-air-setup.md
docs/03-network-foundation.md
screenshots/topology.png
inventory/node-list.md
```

### Week 2 — Custom topology v1

Learn:

```text
Blank Canvas
Images
Node roles
Management plane vs data plane
Basic network path
```

Do:

```text
Create 5–8 server nodes
Enable OOB
Set hostnames
Test DNS/SSH/ping
```

Output:

```text
topologies/data-platform-v1.json
inventory/hosts.ini
docs/05-custom-topology.md
```

### Week 3 — Linux + Docker platform

Learn:

```text
Linux networking
systemd basics
Docker
Docker Compose
Ports
Volumes
Logs
```

Do:

```text
Install Docker
Deploy hello web app
Expose HTTP service using DSX Air services
```

Output:

```text
infra/scripts/bootstrap-node.sh
infra/ansible/install-docker.yml
```

### Week 4 — Event backbone + producers

Learn:

```text
Kafka/Redpanda
topics
partitions
consumer groups
offsets
retention
replay
DLQ
```

Do:

```text
Deploy Redpanda
Write producers
Create topics
Produce normal/burst/dirty events
```

Output:

```text
producers/
schemas/
docs/06-event-streaming.md
```

### Week 5 — CDC

Learn:

```text
Debezium
CDC snapshot
insert/update/delete events
tombstones
compacted topics
schema changes
```

Do:

```text
Deploy Postgres
Deploy Debezium/Kafka Connect
Capture CDC for orders/inventory/customers
```

Output:

```text
docs/07-cdc.md
cdc topics live
```

### Week 6 — Flink stream processing

Learn:

```text
event time
watermarks
state
checkpoint
window aggregation
late events
backpressure
```

Do:

```text
Build order funnel job
Build payment risk job
Build inventory availability job
```

Output:

```text
streaming/flink/
docs/08-flink-stream-processing.md
```

### Week 7 — Lakehouse

Learn:

```text
MinIO
Parquet
Iceberg/Paimon
partitioning
schema evolution
snapshot
compaction
```

Do:

```text
Write validated streams to bronze/silver
Query with Trino
Create gold tables
```

Output:

```text
lakehouse/
docs/09-lakehouse.md
```

### Week 8 — Batch orchestration + reconciliation

Learn:

```text
Airflow/Dagster
DAGs
backfill
idempotency
financial reconciliation
```

Do:

```text
Build daily reconciliation DAG
Build gold metrics batch job
Run quality checks
```

Output:

```text
batch/airflow/dags/
docs/10-batch-orchestration.md
```

### Week 9 — Realtime serving

Learn:

```text
ClickHouse
Redis
FastAPI
low latency APIs
materialized views
```

Do:

```text
Serve funnel metrics
Serve payment risk metrics
Serve inventory stockout alerts
```

Output:

```text
serving/
docs/11-serving-layer.md
```

### Week 10 — Observability + SLO

Learn:

```text
Prometheus
Grafana
Loki
consumer lag
Flink checkpoints
freshness
DLQ metrics
```

Do:

```text
Build dashboards
Create alert rules
Document SLOs
```

Output:

```text
observability/
docs/13-observability-slo.md
```

### Week 11 — Governance + AI/RAG

Learn:

```text
data contracts
lineage
ownership
PII
embedding
vector DB
RAG API
batch scoring
```

Do:

```text
Write data contracts
Add OpenLineage/Marquez optional
Build Qdrant + FastAPI RAG
Build inventory risk batch scoring
```

Output:

```text
governance/
ai/
docs/12-ai-rag-layer.md
docs/14-governance-lineage.md
```

### Week 12 — Failure testing + final packaging

Learn:

```text
chaos testing
runbooks
RTO/RPO
replay
recovery
ADR
GitHub portfolio packaging
```

Do:

```text
Run failure scenarios
Record benchmark results
Write runbooks
Write ADRs
Finalize README
```

Output:

```text
chaos/
runbooks/
adr/
docs/16-failure-testing.md
docs/17-benchmark-results.md
README.md
```

---

## 22. Architecture Decision Records

Create ADRs because they show architect-level thinking.

### ADR template

```markdown
# ADR-000X: <Decision title>

## Status
Accepted / Proposed / Superseded

## Context
What problem are we solving?

## Decision
What did we choose?

## Alternatives considered
- Option A
- Option B
- Option C

## Consequences
Positive and negative outcomes.

## Notes
Additional details.
```

### Suggested ADRs

```text
0001-use-redpanda-for-local-event-streaming.md
0002-use-flink-for-stream-processing.md
0003-use-minio-and-iceberg-for-lakehouse.md
0004-use-clickhouse-for-realtime-serving.md
0005-use-airflow-for-batch-reconciliation.md
0006-use-prometheus-grafana-loki-for-observability.md
0007-use-qdrant-for-rag-vector-store.md
0008-use-synthetic-data-instead-of-real-data.md
0009-build-on-dsx-air-as-digital-twin-lab.md
```

---

## 23. README outline

Your GitHub README should not be a random note. It should read like a mini design doc.

```markdown
# Realtime Data + AI Platform Digital Twin on NVIDIA DSX Air

## Overview
What this project is.

## Why this project exists
The learning/architecture motivation.

## Scope
What it demonstrates.

## Non-goals
What it does not claim.

## Architecture
Diagram + explanation.

## Stack
Tool table.

## DSX Air setup
Simulation, nodes, OOB, resources.

## Data model
Entities, events, schemas.

## Event streaming
Topics, producers, consumers, DLQ.

## CDC
Postgres + Debezium.

## Stream processing
Flink jobs.

## Lakehouse
MinIO + Iceberg/Paimon + Trino.

## Batch
Airflow/Dagster reconciliation.

## Serving
ClickHouse/Redis/FastAPI.

## AI layer
Qdrant + RAG + batch scoring.

## Observability
Metrics, dashboards, SLOs.

## Governance
Contracts, lineage, ownership.

## Failure testing
Scenarios and results.

## Benchmark results
Controlled synthetic workload results.

## How to run
Make commands.

## Limitations
Important honesty.

## Lessons learned
What this project taught.

## References
Official NVIDIA docs and OSS docs.
```

---

## 24. Scope and limitations statement

Add this to README:

```markdown
## Scope and limitations

This project is a production-inspired lab, not a production-ready platform.

It is designed to demonstrate architecture, integration patterns, failure handling,
observability, data contracts, stream/batch processing semantics, and recovery
under controlled synthetic workloads.

It does not claim production-scale throughput, hardened enterprise security,
managed operations, regulatory compliance, or real production reliability.

The goal is to show how a modern data/AI platform behaves under normal traffic,
dirty data, burst traffic, late events, duplicate events, and service failures.
```

---

## 25. What makes this project impressive on GitHub?

This project scores because it shows:

```text
1. You understand cloud-hidden infrastructure.
2. You can build streaming + batch, not only batch.
3. You understand data correctness, not only data movement.
4. You know how to test dirty data, late events, duplicates.
5. You know observability, not only pipelines.
6. You document trade-offs like an architect.
7. You can explain failures and recovery.
8. You know AI platform is built on top of data/platform reliability.
```

Weak version:

```text
Docker Compose with Airflow + MinIO + Trino
```

Strong version:

```text
Postgres CDC + Redpanda/Kafka + Flink + MinIO/Iceberg + Trino + ClickHouse + Airflow + Quality + Observability + Failure Testing + Runbooks + ADRs
```

---

## 26. CV / LinkedIn positioning

### CV bullet 1

```text
Built a production-inspired real-time data and AI platform lab on NVIDIA DSX Air, integrating Redpanda/Kafka, CDC, Flink, MinIO, Iceberg, Trino, ClickHouse, Airflow, Great Expectations, Prometheus/Grafana, and FastAPI.
```

### CV bullet 2

```text
Designed and implemented hybrid batch/streaming pipelines for mock e-commerce/payment events, including event-time processing, DLQ handling, schema validation, lakehouse ingestion, real-time serving, batch reconciliation, and failure runbooks.
```

### CV bullet 3

```text
Documented platform architecture, network topology, data contracts, observability SLOs, failure scenarios, benchmark results, and architecture decision records to simulate production-grade Data Platform operations.
```

### LinkedIn post angle

```text
I used NVIDIA DSX Air as a data center simulation lab to build a production-inspired realtime data platform: CDC, event streaming, Flink, lakehouse, batch reconciliation, observability, data quality, and failure testing.
```

---

## 27. First actions to start now

### Step 1 — Launch foundation demo

From DSX Air Demo Marketplace, launch:

```text
CL5.16.1 - EVPN Symmetric Routing Best Practices
```

Name:

```text
dsx-e2e-lab-00-evpn-foundation
```

### Step 2 — Inspect topology

Record:

```text
Node name
Node type
Image
vCPU/RAM
Management IP
Data interfaces
Which node is switch
Which node is server
```

Commands:

```bash
hostname
ip addr
ip route
ping <server-ip>
traceroute <server-ip>
```

### Step 3 — Stop/checkpoint

After exploration:

```text
Stop simulation
Save checkpoint
Check Billing Overview
```

### Step 4 — Create GitHub repo skeleton

Create:

```bash
mkdir realtime-data-ai-platform-digital-twin
cd realtime-data-ai-platform-digital-twin

mkdir -p docs topologies inventory infra/scripts infra/ansible dsx-air/scripts \
  producers schemas streaming/flink batch/airflow/dags batch/jobs lakehouse/sql \
  serving/fastapi serving/clickhouse ai observability governance quality tests chaos \
  runbooks adr
```

### Step 5 — Write README first

Before writing code, write:

```text
README.md
docs/00-project-overview.md
docs/02-architecture.md
docs/19-limitations.md
```

This keeps the project intentional.

---

## 28. Official references

### NVIDIA DSX Air

- NVIDIA DSX Air User Guide: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/
- Account Setup / Trial resources / Billing: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Account-Setup/
- Quick Start: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Quick-Start/
- Pre-built Demos: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Pre-Built-Demos/
- Custom Topology: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Custom-Topology/
- OOB Management Network: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/OOB-Management-Network/
- Simulation Management: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/Simulation-Management/
- API/SDK: https://docs.nvidia.com/networking-ethernet-software/nvidia-air-v2/API-SDK/
- DSX Air SDK: https://docs.nvidia.com/air/sdk/latest/
- `nv-air-sdk` on PyPI: https://pypi.org/project/nv-air-sdk/

### OSS references to add later

- Apache Kafka: https://kafka.apache.org/
- Apache Flink: https://flink.apache.org/
- Apache Iceberg: https://iceberg.apache.org/
- Apache Paimon: https://paimon.apache.org/
- Redpanda: https://redpanda.com/
- Debezium: https://debezium.io/
- Trino: https://trino.io/
- ClickHouse: https://clickhouse.com/
- MinIO: https://min.io/
- Apache Airflow: https://airflow.apache.org/
- Dagster: https://dagster.io/
- Great Expectations: https://greatexpectations.io/
- Soda: https://www.soda.io/
- OpenLineage: https://openlineage.io/
- Marquez: https://marquezproject.ai/
- DataHub: https://datahubproject.io/
- OpenMetadata: https://open-metadata.org/
- Prometheus: https://prometheus.io/
- Grafana: https://grafana.com/
- Qdrant: https://qdrant.tech/
- FastAPI: https://fastapi.tiangolo.com/

---

## 29. Final mental model

Đừng nghĩ dự án này là:

```text
Build một pipeline demo
```

Hãy nghĩ nó là:

```text
Build một production-inspired data/AI platform lab
Feed it realistic synthetic data
Run stream + batch workloads
Measure behavior
Inject dirty data
Break services intentionally
Recover with replay/backfill/checkpoints
Document architecture, trade-offs, SLOs, runbooks and limitations
```

Đây là cách biến DSX Air trial thành một dự án GitHub có trọng lượng cho:

```text
Senior Data Engineer
Data Platform Engineer
Streaming Data Engineer
Solution Data Architect
AI Platform Engineer
Data Infrastructure Engineer
```

---

## 30. Definition of Done

Dự án được xem là hoàn chỉnh khi có đủ:

```text
[ ] DSX Air topology documented
[ ] OOB vs data plane documented
[ ] Synthetic ecom/payment data producers
[ ] Redpanda/Kafka event backbone
[ ] Postgres CDC via Debezium
[ ] Flink streaming jobs
[ ] MinIO lake storage
[ ] Iceberg/Paimon or Parquet lakehouse layer
[ ] Trino query layer
[ ] ClickHouse realtime serving
[ ] Airflow/Dagster batch reconciliation
[ ] Great Expectations/Soda data quality checks
[ ] DLQ handling
[ ] Late event handling
[ ] Duplicate event handling
[ ] Batch-stream reconciliation report
[ ] Prometheus/Grafana dashboards
[ ] Failure tests
[ ] Runbooks
[ ] Benchmark results
[ ] ADRs
[ ] README with scope/limitations
[ ] GitHub repo clean enough for portfolio
```

---

**End of document.**
