# Glossary — Từ điển Việt-Anh thuật ngữ

> Tra cứu nhanh khi gặp 1 thuật ngữ và muốn biết nó là cái gì + nó nằm ở KU nào.

## A

- **ACID** — 4 đặc tính giao dịch (Atomicity, Consistency, Isolation, Durability) → KU 02/01
- **ACL (Access Control List)** — danh sách quyền truy cập → KU 10/03
- **Asymmetric routing** — định tuyến bất đối xứng (đi 1 đường, về đường khác) → KU 13/11
- **At-least-once** — ít nhất một lần (có thể trùng) → KU 04/10
- **At-most-once** — nhiều nhất một lần (có thể mất) → KU 04/10

## B

- **Backfill** — nạp dữ liệu lịch sử / nấu bù mâm cũ → KU 02/10
- **Backpressure** — áp lực ngược / tắc đường ngược → KU 00/07, KU 04/08
- **BGP (Border Gateway Protocol)** — giao thức định tuyến giữa các nhà mạng → KU 13/05
- **Bloom filter** — bộ lọc khả năng (probabilistic) → KU 07/...
- **Bronze layer** — lớp dữ liệu thô đã chuẩn hoá nhẹ → KU 02/04
- **Burn rate** — tốc độ tiêu ngân sách lỗi → KU 08/08

## C

- **Cache invalidation** — vô hiệu hoá cache → KU 14/07
- **CAP theorem** — định lý Consistency / Availability / Partition tolerance → KU 01/07
- **Cardinality** — độ phong phú giá trị (số nhãn khác nhau) → KU 08/10
- **CDC (Change Data Capture)** — ghi nhận thay đổi dữ liệu → KU 03/09
- **Checkpoint** — điểm lưu trạng thái → KU 04/06
- **Circuit breaker** — cầu chì ngắt mạch → KU 12/06
- **Compaction** — gộp / nén / dọn → KU 03/06, KU 05/08
- **Consensus** — đồng thuận trong nhóm → KU 01/09
- **Consumer group** — nhóm người tiêu thụ → KU 03/04
- **CRDT** — Conflict-free Replicated Data Type → KU 01/...

## D

- **DAG** — Directed Acyclic Graph, đồ thị có hướng không chu trình → KU 06/01
- **Data contract** — hợp đồng dữ liệu → KU 02/08, KU 09/01
- **Data lake** — hồ dữ liệu (lưu thô, schema khi đọc) → KU 02/03
- **Data lakehouse** — lake + warehouse → KU 02/03
- **Data mesh** — kiến trúc mesh, mỗi domain tự sở hữu → KU 02/07
- **Data warehouse** — kho dữ liệu (schema khi ghi) → KU 02/03
- **Debezium** — connector CDC → KU 03/10
- **DLQ (Dead-Letter Queue)** — hàng đợi thư chết / không xử lý được → KU 03/08
- **DNS** — Domain Name System, danh bạ tên miền → KU 01/02

## E

- **ECMP** — Equal-Cost Multi-Path, định tuyến song song chi phí ngang → KU 13/08
- **Embedding** — vector toạ độ ý nghĩa → KU 11/01
- **EVPN** — Ethernet VPN, mở rộng L2 qua L3 fabric → KU 13/06
- **Event time** — giờ sự kiện thật xảy ra → KU 04/01
- **Eventual consistency** — nhất quán dần dần → KU 00/08
- **Exactly-once** — đúng một lần → KU 04/09

## F

- **Failure domain** — vùng đổ sụp / vùng cô lập lỗi → KU 12/02, KU 14/04
- **File descriptor** — số định danh tệp đang mở → KU 01/11
- **Flink** — engine stream processing → KU 04/...

## G

- **Gold layer** — lớp dữ liệu KPI sẵn dùng → KU 02/04
- **GraphQL** — ngôn ngữ truy vấn API → KU 07/07

## H

- **Hash partitioning** — chia ngăn bằng hash → KU 03/02
- **HNSW** — Hierarchical Navigable Small World, thuật toán tìm vector → KU 11/03
- **Hot path / cold path** — đường nóng (latency thấp) / đường lạnh → KU 07/04

## I

- **Iceberg** — table format cho data lake → KU 05/03
- **Idempotency** — chạy nhiều lần ra cùng kết quả → KU 00/06
- **ISR (In-Sync Replica)** — bản sao đang đồng bộ → KU 03/...

## J

- **JWT (JSON Web Token)** — thẻ ra vào có chữ ký → KU 10/07

## K

- **Kafka** — event streaming platform → KU 03/01
- **kafka Streams** — thư viện stream xử lý cùng Kafka → KU 04/...

## L

- **Lakehouse** — kết hợp lake + warehouse → KU 02/03
- **Latency** — độ trễ → KU 01/08
- **Leaf-spine** — kiến trúc 2 tầng lá-cột sống → KU 13/07
- **Lineage** — dòng chảy dữ liệu (ai sinh ra ai) → KU 09/03
- **Loki** — log aggregation → KU 08/...

## M

- **MAC learning** — học địa chỉ MAC qua bridge → KU 13/09
- **MTU (Maximum Transmission Unit)** — kích thước gói tối đa → KU 13/10
- **Materialized view** — bảng kết quả lưu sẵn → KU 07/03
- **Mental model** — mô hình tư duy → toàn bộ M00

## O

- **OLAP** — Online Analytical Processing → KU 02/01
- **OLTP** — Online Transaction Processing → KU 02/01
- **OpenLineage** — chuẩn lineage event → KU 09/04
- **OpenTelemetry (OTEL)** — chuẩn metric/log/trace → KU 08/...

## P

- **Partition** — phân vùng / chia ngăn → KU 03/02
- **Parquet** — file columnar → KU 05/02
- **PII (Personally Identifiable Information)** — thông tin định danh cá nhân → KU 09/06
- **Postmortem** — mổ xẻ sau sự cố → KU 12/09

## Q

- **Qdrant** — vector database → KU 11/02
- **Quorum** — số tối thiểu để đồng thuận → KU 01/09

## R

- **RAG (Retrieval-Augmented Generation)** — sinh có trích cứu → KU 11/05
- **RAGAS** — eval framework cho RAG → KU 11/10
- **RBAC** — Role-Based Access Control → KU 10/03
- **Reconciliation** — đối chiếu / kiểm chứng → KU 06/06
- **Redpanda** — Kafka-compatible broker → KU 03/01
- **Replay** — phát lại từ offset → KU 03/12
- **REST** — Representational State Transfer → KU 07/07
- **Retry + backoff** — thử lại có giãn cách → KU 12/07
- **RPO (Recovery Point Objective)** — mất tối đa bao nhiêu dữ liệu → KU 12/03
- **RTO (Recovery Time Objective)** — phục hồi trong bao lâu → KU 12/03

## S

- **SCD2 (Slowly Changing Dimension type 2)** — chiều thay đổi chậm, giữ lịch sử → KU 02/06
- **Schema-on-read / write** — schema khi đọc / khi ghi → KU 02/02
- **Schema Registry** — đăng ký lược đồ → KU 03/11
- **SLO (Service Level Objective)** — mục tiêu mức dịch vụ → KU 08/06
- **SLI (Service Level Indicator)** — chỉ số đo dịch vụ → KU 08/06
- **SLA (Service Level Agreement)** — cam kết dịch vụ → KU 08/06
- **Sliding window** — cửa sổ trượt → KU 04/04
- **Snapshot** — ảnh chụp trạng thái → KU 05/04
- **SOPS** — Secrets OPerationS, mã hoá secret → KU 10/05
- **Spine-leaf** — leaf-spine (xem trên) → KU 13/07
- **SRE** — Site Reliability Engineering → KU 08/...

## T

- **Time travel** — du hành quá khứ (lakehouse) → KU 05/05
- **TLS / mTLS** — Transport Layer Security / mutual TLS → KU 10/06
- **Tombstone** — bia mộ, marker xoá → KU 03/06
- **Throughput** — thông lượng → KU 01/08
- **Tokenization** — token hoá (đổi giá trị nhạy cảm thành token) → KU 09/07
- **Tumbling window** — cửa sổ rời rạc → KU 04/04
- **Trino** — distributed SQL engine → KU 05/...

## U

- **Underlay / overlay** — mạng nền / mạng phủ → KU 13/04

## V

- **Vector database** — DB lưu vector → KU 11/02
- **VLAN** — Virtual LAN → KU 13/02
- **VTEP (VXLAN Tunnel Endpoint)** — đầu hầm VXLAN → KU 13/03
- **VXLAN** — Virtual Extensible LAN → KU 13/03

## W

- **Watermark** — mép nước thuỷ triều (event-time marker) → KU 04/02
- **WAL (Write-Ahead Log)** — log ghi trước → KU 03/...

## Z

- **Zero-trust** — không tin ai mặc định → KU 10/01

---

## Quy ước

- `KU XX/YY` = Module XX, KU thứ YY.
- Khi 1 thuật ngữ xuất hiện ở nhiều KU, link tới KU **đầu tiên** giải thích nó.
- Glossary này được cập nhật mỗi khi viết KU mới.
