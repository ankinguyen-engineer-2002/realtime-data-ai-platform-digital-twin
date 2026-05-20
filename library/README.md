# Library — Phòng thư viện

> Nơi nạp PDF sách, paper, và viết tóm tắt.

---

## 📂 Cấu trúc

```
library/
├── README.md                ← bạn ở đây
├── MANIFEST.md              ← danh mục tất cả tài liệu
├── books/                   ← PDF (gitignored — file lớn)
│   ├── data-engineering/
│   ├── streaming/
│   ├── networking/
│   ├── distributed-systems/
│   ├── sre-observability/
│   ├── ai-ml/
│   └── system-design/
├── papers/                  ← academic papers (PDF)
├── summaries/               ← bản tóm tắt + take-aways
└── citations/               ← citation tracker
```

---

## 🛠 Cách dùng

### Bước 1 — Drop PDF
```bash
cp ~/Downloads/designing-data-intensive-applications.pdf library/books/distributed-systems/
```

### Bước 2 — Update MANIFEST
Tự thêm vào [`MANIFEST.md`](./MANIFEST.md) bằng tay hoặc chạy script (sẽ có sau).

### Bước 3 — Viết summary
Tạo `summaries/<book-slug>.md` theo template [`summaries/_template.md`](./summaries/_template.md).

### Bước 4 — Liên kết về Learning KU
Trong KU liên quan, thêm dòng:
```markdown
## 📖 Đọc thêm
- 📚 [Kleppmann ch. 11 — Stream processing](../../library/summaries/ddia.md#ch11) — chương đáng đọc cho KU này
```

---

## 📚 Sách shortlist đề xuất

(Tải bản hợp pháp — owned, mua, hoặc free chính thống. Không upload sách lậu lên repo public — `library/books/` đã gitignored.)

| Chủ đề | Sách | Tác giả | Ưu tiên |
|---|---|---|---|
| Distributed systems | Designing Data-Intensive Applications | Martin Kleppmann | ⭐⭐⭐ |
| Distributed systems | Database Internals | Alex Petrov | ⭐⭐ |
| Streaming | Streaming Systems | Akidau & Lax | ⭐⭐⭐ |
| Streaming | Kafka: The Definitive Guide | Narkhede et al. | ⭐⭐ |
| Lakehouse | Apache Iceberg: The Definitive Guide | Tomer Shiran et al. | ⭐⭐ |
| Networking | BGP in the Data Center | Dinesh Dutt | ⭐⭐⭐ |
| Networking | TCP/IP Illustrated Vol 1 | W. Richard Stevens | ⭐⭐ |
| SRE | Site Reliability Engineering | Google (free) | ⭐⭐⭐ |
| SRE | The SRE Workbook | Google (free) | ⭐⭐ |
| Chaos | Chaos Engineering | Casey Rosenthal | ⭐⭐ |
| System design | Designing Distributed Systems | Brendan Burns | ⭐⭐ |
| AI | Building LLM-Powered Applications | Valentina Alto | ⭐⭐ |
| Data engineering | Fundamentals of Data Engineering | Joe Reis | ⭐⭐⭐ |
| Data engineering | The Data Warehouse Toolkit | Ralph Kimball | ⭐⭐ |

---

## 🔓 Bản quyền

`library/books/` được gitignored để **không upload sách bản quyền lên repo public**.

`library/summaries/` thì OK push — tóm tắt + take-aways là sáng tạo của bạn.

`library/papers/` — chỉ commit paper **open access** (arXiv, ACM open, USENIX). Paper trả phí thì gitignored.
