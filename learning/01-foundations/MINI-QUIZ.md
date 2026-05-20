# Mini-quiz — Module 01 Foundations

> 10 câu trắc nghiệm.

## Câu 1
TCP three-way handshake có 3 bước. Mục đích chính là gì?

- (A) Mã hoá traffic
- (B) Đảm bảo cả 2 phía đồng bộ sequence number + sẵn sàng
- (C) Negotiate compression
- (D) Authentication

## Câu 2
DNS TTL = 3600 có nghĩa là gì?

- (A) Record có thể cache 3600 giây trước khi resolve lại
- (B) Server DNS sẽ down sau 3600 giây
- (C) Connection hết hạn sau 3600 giây
- (D) Đăng ký domain hết hạn sau 3600 ngày

## Câu 3
Cùng IP `10.1.10.11` có thể chạy bao nhiêu service đồng thời?

- (A) 1
- (B) Tối đa 65535 — mỗi service 1 port
- (C) Không giới hạn
- (D) 256

## Câu 4
Process exit code 137 nghĩa là?

- (A) Process tự exit bình thường
- (B) Process bị SIGKILL bởi OOM-killer (vượt RAM limit)
- (C) Compile error
- (D) Permission denied

## Câu 5
Container so với VM khác chỗ chính nào?

- (A) Container chạy nhanh hơn vì code C
- (B) Container share kernel host; VM có guest OS riêng
- (C) VM bảo mật kém hơn
- (D) Container không thể chạy trên Windows

## Câu 6
"8 fallacies of distributed computing" — phát biểu nào ĐÚNG?

- (A) Network is reliable
- (B) Latency is zero
- (C) Cả A và B đều SAI — đó chính là điểm của fallacies
- (D) Tất cả 8 phát biểu là sự thật

## Câu 7
Kafka với `acks=all` + `min.insync.replicas=2` thiên về CAP nào khi partition xảy ra?

- (A) AP — vẫn nhận write
- (B) CP — từ chối write nếu không đủ replica
- (C) CA — không bao giờ partition
- (D) Không liên quan CAP

## Câu 8
p50 latency = 10ms, p99 = 2000ms. Đánh giá hệ thống?

- (A) Hệ thống nhanh, p50 tốt
- (B) Hệ thống có tail latency tệ — 1% user gặp > 2 giây
- (C) p99 không quan trọng bằng p50
- (D) Cần đo lại bằng average

## Câu 9
Cluster Raft 5 node. Mất tối đa bao nhiêu node mà cluster vẫn hoạt động?

- (A) 1
- (B) 2
- (C) 3
- (D) 4

## Câu 10
Wall clock vs Monotonic clock — đo "API mất bao lâu" nên dùng cái nào?

- (A) Wall clock — chính xác hơn
- (B) Monotonic clock — không bị tua khi NTP chỉnh
- (C) Không khác biệt
- (D) Dùng cả 2 và lấy trung bình

---

## Đáp án

<details>
<summary>Bấm để mở đáp án</summary>

1. **B** — Synchronize sequence number + xác nhận sẵn sàng cả 2 phía.
2. **A** — TTL = cache duration. Sau TTL phải resolve lại.
3. **B** — Mỗi service 1 port. 1-65535 (port 0 không dùng), thực tế 1024+.
4. **B** — Exit 137 = 128 + 9 (SIGKILL). Phổ biến nhất là OOM-killer.
5. **B** — Container share kernel; VM có guest OS riêng. Đây là khác biệt cốt lõi.
6. **C** — Cả 8 phát biểu trong "fallacies" đều **SAI** — đó là tên gọi "fallacies".
7. **B** — `min.insync.replicas=2` ép cluster reject write khi không đủ replica → CP.
8. **B** — p99 tệ = tail latency vấn đề. Senior nhìn p99, không nhìn p50.
9. **B** — Cần majority (N/2+1 = 3). Mất 2 → còn 3 = majority OK.
10. **B** — Monotonic clock không bị NTP tua. Wall clock có thể "tua ngược" → duration ra số âm.

</details>

---

## Chấm điểm

| Đúng | Mức |
|---:|---|
| 9-10 | Sẵn sàng đi Module 02 |
| 7-8 | Đọc lại các câu sai |
| <7 | Đọc lại các KU liên quan trong M01 |
