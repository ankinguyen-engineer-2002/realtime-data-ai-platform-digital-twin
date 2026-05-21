# KU F01 / 10 — Compression basics: Snappy, gzip, LZ4, Zstd

> **Compression** giảm bytes → tiết kiệm disk + network bandwidth, **trao đổi** CPU. Pick compression algorithm = pick trade-off (speed vs ratio). Parquet, Iceberg, Kafka, gRPC đều có compression — chọn đúng = giảm cost 30-70%.

**Module:** [F01 — CS Fundamentals](./README.md)
**Prereqs:** [F01/01 Bits, bytes](./01-bits-bytes-encoding.md)
**Related KUs:** [F01/11 Checksums](./11-checksums-integrity.md) · [F01/17 CRC/MD5/SHA](./17-hash-families.md) · [F10 Databases II](../../semester-2-systems-theory/F10-databases-beyond-sql/)
**Đọc trong:** ~12 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn cần đóng gói **100 cuốn sách giống nhau** vào hộp gửi đi:

### Cách 1 — Đóng riêng từng cuốn (no compression)
- 100 hộp lớn, mỗi hộp 1 cuốn.
- **Size:** 100 × 500g = 50kg.

### Cách 2 — Note "100 bản sách X" (Run-length encoding)
- 1 hộp + 1 mảnh giấy "100 bản sách Designing Data-Intensive Applications" + 1 cuốn mẫu.
- **Size:** 1 cuốn + giấy = 502g. **100x nhỏ hơn.**
- **Decompress:** photocopy 100 bản. Tốn thời gian.

### Cách 3 — Dictionary encoding
- Note: "Cuốn A = Designing DDIA, Cuốn B = Streaming Systems".
- Trong order: "100A, 50B, 30A, 80B" thay vì tên dài.
- **Size:** dictionary + indices. Nhỏ hơn nhiều khi có nhiều ký tự lặp lại.

Compression algorithms = **tìm pattern + replace bằng reference ngắn hơn**:

- **LZ77** (gzip family) — sliding window, "this match was 10 chars ago, 30 chars long"
- **Huffman coding** (gzip uses) — frequent chars → shorter code
- **Snappy / LZ4** — LZ77 family, fast + lower ratio
- **Zstd** — Modern, configurable ratio/speed
- **Brotli** — Google, web-optimized
- **bzip2** — Burrows-Wheeler, slow but better ratio

---

## 📖 Định nghĩa chính thức

**Compression** = represent data với fewer bits by exploiting patterns.

**Lossless** = decompress identical to original (text, code, structured data).
**Lossy** = decompress approximate (audio, video, image).

In DE, **lossless only** (data integrity requirement).

3 metric khi pick compression:

1. **Compression ratio** — original_size / compressed_size. Higher = smaller output.
2. **Compression speed** — MB/s when compressing.
3. **Decompression speed** — MB/s when reading.

Trade-off:
- **High ratio** algorithms (Zstd-22, brotli) → slow compress + slow decompress
- **High speed** (Snappy, LZ4) → low ratio
- **Balanced** (gzip-6, Zstd-3) → middle ground

**Nguồn:**
- "Data Compression: The Complete Reference" (Salomon).
- Facebook Zstd paper (2016).
- Snappy paper (Google 2011).

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Nén dữ liệu | Compression | Reduce data size |
| Giải nén | Decompression | Restore original |
| Lossless | Lossless | Exact restoration |
| Lossy | Lossy | Approximate restoration |
| Compression ratio | Compression ratio | Original / compressed size |
| Bit rate | Bit rate | Bits per second |
| Entropy | Entropy | Information density (bits per symbol) |
| Dictionary | Dictionary | Reference table for compression |
| Sliding window | Sliding window | LZ77 lookback buffer |
| Huffman coding | Huffman coding | Variable-length code by frequency |
| Run-length encoding | Run-length encoding (RLE) | "N copies of X" |
| Delta encoding | Delta encoding | Store differences |
| Dictionary encoding | Dictionary encoding | Replace strings with IDs |
| Bit packing | Bit packing | Use fewer bits per value |
| LZ77 / LZW | LZ77 / LZW | Lempel-Ziv family |
| DEFLATE | DEFLATE | LZ77 + Huffman (gzip) |
| Snappy | Snappy | Google fast compression |
| LZ4 | LZ4 | Yann Collet fast compression |
| Zstd | Zstandard | Facebook modern, tunable |
| Brotli | Brotli | Google web compression |
| bzip2 | bzip2 | Burrows-Wheeler transform |

---

## 💡 Real-world trade-offs

### Comparison table (per Facebook Zstd benchmark, typical text)

| Algorithm | Ratio | Compress speed | Decompress speed | Use case |
|---|---:|---:|---:|---|
| **Snappy** | 2.0x | 250 MB/s | 500 MB/s | Hot path, in-memory |
| **LZ4** | 2.1x | 750 MB/s ⚡ | 4000 MB/s ⚡ | Real-time streaming |
| **Zstd-1** | 2.9x | 470 MB/s | 1400 MB/s | Balanced default |
| **Zstd-3 (default)** | 3.1x | 270 MB/s | 1100 MB/s | General use |
| **gzip-6** | 3.0x | 90 MB/s | 350 MB/s | Compatible legacy |
| **gzip-9** | 3.1x | 20 MB/s | 350 MB/s | Storage-optimized |
| **Zstd-19** | 4.0x | 5 MB/s | 1000 MB/s | Archive (rare write) |
| **Brotli-11** | 3.8x | 1 MB/s | 250 MB/s | Web static (HTML) |
| **bzip2** | 3.3x | 12 MB/s | 30 MB/s | Old archives |

→ **Decompress speed** thường matter hơn compress (data đọc nhiều lần). LZ4 + Zstd dominate modern.

---

## 🚀 Real-world impact trong DE

### Parquet column compression

```
Sales table 1B rows, 10 columns, 100 bytes/row:
  Raw: 100 GB
  Parquet uncompressed: 50 GB (column dictionary)
  Parquet + Snappy: 15 GB (3x compression on top)
  Parquet + Zstd: 8 GB (6x compression on top)
```

→ Storage cost reduce 12.5x with Parquet+Zstd vs raw CSV.

### Kafka producer compression

```
Producer config: compression.type=snappy
Throughput: 100 MB/s before → 250 MB/s effective (2.5x more events fit same network)
```

→ Compression at producer = save network bandwidth + broker disk + consumer bandwidth.

### HTTP gzip

```
JSON response 100 KB → gzip → 15 KB (6.7x)
Network transfer 100ms → 15ms
```

→ Why all REST APIs use Content-Encoding: gzip default.

### Trong project DSX Air

| Where | Compression | Why |
|---|---|---|
| Kafka topics | LZ4 | Fast, real-time streaming |
| Iceberg Parquet | Zstd (level 3) | Balanced storage + read |
| HTTP API responses | gzip | Universal browser support |
| Prometheus TSDB | Snappy | Fast in-memory |
| MinIO object backups | Zstd-19 | Storage-optimized |
| Loki logs | Snappy | Fast write, fast scan |

---

## 🔧 Cách compression work (high level)

### LZ77 (foundation of gzip, Zstd, LZ4)

Sliding window approach. When find match in recent history, output `(offset, length)`:

```
Input:  "abcabcabc"
Window: ............ (initially empty)

Output:
  'a' → literal 'a'
  'b' → literal 'b'
  'c' → literal 'c'
  'abc' → match at offset 3, length 3 → output (3, 3)
  'abc' → match at offset 3, length 3 → output (3, 3) or (6, 6)
```

→ Replace repeated substring with short reference.

### Huffman coding (frequency-based)

Frequent characters get **shorter bit codes**:

```
Char frequency in English: 'e' = 12%, 'z' = 0.1%
Standard ASCII: 'e' = 8 bits, 'z' = 8 bits
Huffman: 'e' = 3 bits, 'z' = 12 bits → average 4-5 bits/char
```

→ Saves bits proportional to frequency variance.

### gzip = LZ77 + Huffman (DEFLATE)

```
Step 1: LZ77 find matches
Step 2: Huffman code the literals + match references
```

### Zstd improvements

- Larger window (128 KB+)
- Optional pre-trained dictionary (great for many small payloads)
- Multi-thread
- 22 levels of compression (1=fast, 22=max ratio)

### Dictionary compression

Train dictionary on representative samples → reuse cho mỗi message → tiny per-message size.

→ Kafka, Parquet leverage cho repeated schema.

---

## ⏰ Khi nào dùng cái nào?

| Scenario | Best |
|---|---|
| Real-time streaming (Kafka, Flink) | **LZ4** or **Snappy** |
| Lakehouse storage (Parquet, Iceberg) | **Zstd** (level 3) |
| HTTP API | **gzip** (universal) or **Brotli** (web modern) |
| Backup/Archive (cold) | **Zstd-19** or **bzip2** |
| Database column storage (ClickHouse) | **LZ4** or **Zstd** |
| Logs | **Snappy** or **LZ4** |
| Many small messages with shared structure | **Zstd with dictionary** |

---

## ⚠️ Common pitfalls

### Pitfall 1 — Compress already-compressed data

❌ gzip an MP4 video → no benefit, waste CPU.

✅ MP4, JPEG, PNG, Parquet+Snappy đã compressed. Don't double.

### Pitfall 2 — gzip level 9 trên hot path

❌ Production API gzip-9 → 20 MB/s compress speed → bottleneck.

✅ gzip-6 or Zstd-3 for hot path.

### Pitfall 3 — Snappy ratio không đủ

❌ Storage cost-sensitive → Snappy 2x → not enough.

✅ Zstd-3 → 3x with similar decompress speed.

### Pitfall 4 — Compress small messages without dictionary

❌ 100-byte JSON messages individually compressed → overhead > savings.

✅ Use Zstd dictionary trained on samples. Or batch messages.

---

## 🌱 Advanced topics

### A1. Entropy lower bound

Shannon entropy = theoretical minimum bits per symbol given probability distribution. No lossless algorithm can beat.

Random bytes → entropy 8 bits/byte → no compression possible.
English text → entropy ~4 bits/byte → 2x compression possible.
Structured JSON → entropy 2-3 bits/byte → 3-4x compression.

### A2. Bit packing in columnar

Parquet stores integers in min bits needed:
- Column has values 0-100 → 7 bits per value (not 32 bits int)
- Bit-pack 8 values per 7 bytes

→ Sometimes 10x reduction without dictionary.

### A3. Delta encoding

Time-series with similar consecutive values:
- Store [1000, 1001, 1002, 1003] as [1000, +1, +1, +1]
- Combined with bit packing → huge reduction

→ Used in Prometheus TSDB, InfluxDB.

### A4. Apply cho LLM 2026

- **Model quantization** (INT8, FP8) = lossy compression of weights — 4x smaller, 2-4x faster inference
- **KV cache quantization** — compress per-token state
- **Embedding quantization** (PQ, OPQ) — vector DB storage 10x reduction

---

## 🔗 Liên kết

- **[F01/01 Bits, bytes](./01-bits-bytes-encoding.md)** — units being compressed
- **[F01/11 Checksums](./11-checksums-integrity.md)** — verify integrity after decompress
- **[F10 Databases II](../../semester-2-systems-theory/F10-databases-beyond-sql/)** — Parquet compression deep
- **[D19 Lakehouse](../../../year-2-specialization/semester-3-data-engineering-deep/D19-lakehouse-deep/)** — Iceberg compression tuning

---

## 🧠 Self-test

1. Lossless vs lossy: difference + 1 example each.
2. Snappy vs LZ4 vs Zstd: ratio + speed tradeoffs.
3. Why decompress speed matter more than compress in DE?
4. gzip-1 vs gzip-9: trade-off?
5. Compress JPEG with gzip: result?
6. Why Zstd with dictionary beats Zstd without for many small messages?

---

## 📌 Trong repo

- **Kafka topic compression**: [`docs/06-event-backbone.md`](../../../../docs/06-event-backbone.md)
- **Parquet+Zstd** in Iceberg: [`docs/09-lakehouse-design.md`](../../../../docs/09-lakehouse-design.md)
- **HTTP gzip** in API: [`docs/11-serving-layer.md`](../../../../docs/11-serving-layer.md)

---

## 🌐 Đọc thêm
- Facebook Zstd paper (2016).
- "The Data Compression Book" (Mark Nelson).

**Đã đọc xong?**
✅ Tick → [F01/11 Checksums + integrity hash](./11-checksums-integrity.md).
