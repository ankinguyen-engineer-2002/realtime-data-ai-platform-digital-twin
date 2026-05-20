# Mini-quiz — Module 00 Mental Models

> 10 câu trắc nghiệm. Trả lời rồi xuống cuối xem đáp án.

---

## Câu 1
Tư duy "data product" yêu cầu mỗi dataset phải có những gì?

- (A) Owner, SLA, contract, quality, lineage
- (B) Tên đẹp, schema, dashboard
- (C) Backup, monitor, alert
- (D) Tài liệu, code review, CI

## Câu 2
Trade-off thinking khác "cargo cult" ở chỗ nào?

- (A) Trade-off thinking đúng hơn nói chung
- (B) Cargo cult sao chép chọn lọc theo FAANG; trade-off cân nhắc constraint ngữ cảnh
- (C) Cargo cult chỉ áp cho frontend
- (D) Trade-off thinking chỉ dùng khi viết ADR

## Câu 3
Mức "Hiểu sâu" được kiểm chứng tốt nhất bằng cách nào?

- (A) Đọc 600 trang DDIA
- (B) Hoàn thành tutorial Kafka chính thức
- (C) Giải thích cho người không cùng ngành mà họ gật đầu
- (D) Pass certification

## Câu 4
Đặt vào 3 trục state / change / time, Kafka thuộc trục nào?

- (A) State-focused
- (B) Change-focused (chính), time-secondary (offset)
- (C) Time-focused
- (D) Cả 3 trục đều mạnh

## Câu 5
"Failure as a feature" có nghĩa là gì?

- (A) Cần để hệ thống fail nhiều để học
- (B) Liệt kê failure modes tường minh, có alert + runbook + chaos test
- (C) Cứ build happy path, sửa khi hỏng
- (D) Mua bảo hiểm cho hệ thống

## Câu 6
Operation nào sau đây idempotent?

- (A) `UPDATE balance = balance - 50 WHERE id = X`
- (B) `INSERT INTO orders VALUES (...)`
- (C) `UPDATE status = 'SHIPPED' WHERE order_id = 'ord_123'`
- (D) `DELETE FROM users WHERE id = X` chạy lần thứ 2

## Câu 7
Producer Kafka bật `enable.idempotence=true`. Pipeline đạt exactly-once chưa?

- (A) Đã đạt — đủ rồi
- (B) Chưa — cần consumer + sink cũng idempotent / transactional
- (C) Chưa — cần thêm `acks=0`
- (D) Đã đạt nếu broker là Redpanda

## Câu 8
Khi Flink sink chậm, operator phía trước backpressure cao. Stage nào là bottleneck thực sự?

- (A) Operator có backpressure ratio cao nhất
- (B) Operator có backpressure ratio thấp nhất (= sink chậm thực sự)
- (C) Operator đầu vào nhất
- (D) Không xác định được từ backpressure ratio

## Câu 9
Ngân hàng phải dùng mức consistency nào cho thao tác trừ tiền?

- (A) Eventual consistency
- (B) Read-your-writes
- (C) Linearizable / strong
- (D) Causal

## Câu 10
ClickHouse mat. view trong project này có lag 5-30s so với OLTP. Đây là?

- (A) Bug — phải fix về 0s
- (B) Eventual consistency, chấp nhận được cho dashboard
- (C) Strong consistency
- (D) Strong + caching

---

## Đáp án + giải thích

<details>
<summary>Bấm để mở đáp án</summary>

1. **A** — Data product mindset = 5 thuộc tính: owner, SLA, contract, quality, lineage. Backup/monitor là technical, không định nghĩa "product".
2. **B** — Cargo cult là sao chép giải pháp khi không có cùng problem; trade-off thinking đánh giá theo ngữ cảnh.
3. **C** — Test "Hiểu sâu" = Feynman technique = giải thích cho người không cùng ngành.
4. **B** — Kafka log là append-only change stream. Offset là index theo time nhưng không phải focus chính.
5. **B** — "Failure as a feature" = thiết kế cho lúc hỏng, không phải mong hỏng.
6. **C** — UPDATE status = 'SHIPPED' lặp 100 lần vẫn là SHIPPED → idempotent. (A) trừ 50 mỗi lần → KHÔNG. (B) insert tạo duplicate (trừ khi có ON CONFLICT). (D) lần thứ 2 không xoá gì — kết quả giống = idempotent, nhưng cần check ngữ cảnh.
7. **B** — Idempotent producer chỉ giải quyết duplicate ở mức broker. Consumer / sink cũng phải đảm bảo exactly-once.
8. **B** — Sink chậm có backpressure THẤP (nó là bottleneck nên không bị block bởi downstream). Operator phía trước nó có backpressure CAO vì bị sink block.
9. **C** — Trừ tiền cần atomic + isolated. Strong / linearizable là duy nhất an toàn.
10. **B** — Lag 5-30s là eventual consistency. Đây là design choice, không phải bug. Strong end-to-end là không thực tế.

</details>

---

## Chấm điểm

| Đúng | Mức |
|---:|---|
| 9-10 | Hiểu sâu Module 00 — sẵn sàng đi Module 01 |
| 7-8 | Hiểu — đọc lại các câu sai |
| 5-6 | Biết — đọc lại các KU liên quan |
| 0-4 | Chưa biết — đọc lại toàn module |

Sau khi pass, tick vào [`learning/progress/checklist.md`](../progress/checklist.md) và sang [Module 01](../01-foundations/).
