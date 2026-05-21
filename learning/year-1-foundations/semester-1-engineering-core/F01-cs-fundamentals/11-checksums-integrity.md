# KU F01 / 11 — Checksums + hash for integrity

> **Checksum** trả lời "file có bị hỏng không?". Khác với crypto hash (security), checksum optimized cho **speed** detect random corruption. Parquet, Kafka, TCP đều có checksum. Hiểu = debug corruption bugs nhanh.

**Module:** [F01 — CS Fundamentals](./README.md)
**Prereqs:** [F01/01 Bits, bytes](./01-bits-bytes-encoding.md) · [F01/10 Compression](./10-compression-basics.md)
**Related KUs:** [F01/17 CRC/MD5/SHA](./17-hash-families.md)
**Đọc trong:** ~10 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn gửi **bản hợp đồng 100 trang** qua bưu điện cho đối tác. Lo lắng: thư có thể bị **ướt, rách, hoặc thiếu trang** trong quá trình vận chuyển.

### Cách verify: ghi số "checksum"

Ở cuối hợp đồng, bạn ghi:
> "Tổng số ký tự: 245,789. Tổng số dấu chấm: 1,247."

Đối tác nhận → đếm lại ký tự + dấu chấm → so với ghi chú:
- Khớp → có thể ok (high confidence, không guarantee 100%)
- Sai → CHẮC CHẮN bị hỏng → request gửi lại

Checksum trong tech làm y vậy:
- File = data
- Checksum = "công thức tóm tắt" data thành 4-8 bytes
- Sender ghi checksum cùng file
- Receiver compute lại checksum → compare
- Sai → corruption detected, retry/reject

**Quan trọng:** checksum dò **random corruption** (bit flip do hardware, network glitch). KHÔNG bảo vệ chống **intentional tampering** (attacker tính lại checksum). Cho security → dùng cryptographic hash (SHA-256, MAC, signature).

---

## 📖 Định nghĩa chính thức

**Checksum** = small fixed-size value computed từ data, dùng to detect **accidental** corruption.

**Cryptographic hash** = checksum với additional properties:
- **Collision-resistant** — khó tìm 2 input → same hash
- **Pre-image resistant** — khó từ hash reverse về input
- **Avalanche** — đổi 1 bit input → hash thay đổi hoàn toàn

**Trade-off:**
- **Non-crypto** (CRC32, xxHash, Adler-32) — fast, **NOT** secure
- **Crypto** (MD5, SHA-1, SHA-256, BLAKE3) — slower, secure

Modern hash families (2026):
- **xxHash** — fastest non-crypto, 30 GB/s
- **CRC32C** — hardware-accelerated, used in network protocols
- **MD5** — broken for security, OK for integrity
- **SHA-256** — secure, slower
- **BLAKE3** — modern crypto, fast (parallel), 10+ GB/s

**Nguồn:**
- CRC paper (Peterson & Brown 1961).
- SHA-256 FIPS 180-4 standard.
- BLAKE3 spec (2020).

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Tổng kiểm tra | Checksum | Small value detect data corruption |
| Hash | Hash | General term |
| Cryptographic hash | Cryptographic hash | Secure hash |
| Non-cryptographic | Non-cryptographic | Fast, not secure |
| Bit flip | Bit flip | Random bit change (hardware error) |
| Collision | Collision | 2 inputs → same hash |
| Avalanche effect | Avalanche effect | 1 bit input → 50% hash bits change |
| Pre-image resistance | Pre-image resistance | Hard to find input given hash |
| Second pre-image | Second pre-image | Hard to find 2nd input matching given input's hash |
| CRC | Cyclic Redundancy Check | Polynomial-based checksum |
| CRC32C | CRC32C | Hardware-accelerated CRC32 |
| Adler-32 | Adler-32 | Simple checksum (zlib) |
| xxHash | xxHash | Modern fast non-crypto |
| MD5 | MD5 | 128-bit, broken security |
| SHA-1 | SHA-1 | 160-bit, broken security |
| SHA-256 | SHA-256 | 256-bit, currently secure |
| SHA-3 | SHA-3 | NIST 2015, different design |
| BLAKE3 | BLAKE3 | 2020, fast + secure |
| HMAC | HMAC | Hash with secret key |
| MAC | Message Authentication Code | Verify authenticity |
| Salt | Salt | Random data added before hashing |
| Rainbow table | Rainbow table | Precomputed hash lookup attack |

---

## 💡 Real-world impact

### CRC32 trong Parquet, Avro

Mỗi data block trong Parquet có CRC32 → detect disk corruption when read.

```
Parquet file structure:
  [data block 1] [CRC32]
  [data block 2] [CRC32]
  [data block 3] [CRC32]
  ...
  [footer with overall checksum]
```

→ Spark/Trino verify CRC during read → silent corruption caught.

### TCP/IP checksum

Every TCP packet has 16-bit checksum. Network corruption (cable bit flip) → packet discarded → retransmit.

→ Why "the network is reliable" fallacy partly works: checksums catch most random errors.

### Git uses SHA-1 (legacy) → SHA-256

Git object IDs = SHA-1 hash of content. Same content → same hash (deduplication). Different content → different hash (detect tampering).

Git migrating to SHA-256 (post-2017 SHA-1 collision attack).

### Cassandra Merkle tree (anti-entropy)

Each replica computes Merkle tree of data ranges → compare trees → only sync mismatched ranges.

→ Efficient eventual consistency.

### Trong project DSX Air

| Where | Checksum |
|---|---|
| Kafka producer | CRC32C per record batch |
| Iceberg data files | Parquet CRC32 per page |
| MinIO objects | MD5 ETag for integrity |
| TCP transport | 16-bit checksum |
| Postgres WAL | 32-bit checksum per record |
| HTTPS | TLS MAC for transport |

---

## 🔧 Cách hash work (high level)

### CRC32 — polynomial arithmetic

Treat data as polynomial. Divide by generator polynomial. Remainder = CRC.

```
Data: 0b110101
Generator: 0b10011
Polynomial division → remainder = 0b1011 → CRC = 0b1011
```

→ Math behind: catches all 1-bit, most 2-bit errors. Hardware-friendly.

### MD5 / SHA-256 — Merkle-Damgård construction

Process input in blocks. Each block updates internal state. Final state = hash.

```
input → chunks → process each → update state → output state
```

→ Each block O(n) → total O(n).

### BLAKE3 — tree hashing

Process input in chunks **in parallel** → combine via tree → output.

→ Multi-threaded → 10+ GB/s on modern CPU.

---

## ⚠️ Common pitfalls

### Pitfall 1 — Use MD5 for security

❌ MD5 collision attacks since 2004. Don't use for password hashing or signature verification.

✅ Use bcrypt/argon2 for passwords, SHA-256+/HMAC for signatures.

### Pitfall 2 — Plain hash for password storage

❌ `sha256(password)` stored → rainbow table attack.

✅ bcrypt/argon2 with salt + work factor. Designed slow.

### Pitfall 3 — Use crypto hash where speed matters

❌ SHA-256 for data dedup at 1 GB/s ingestion → bottleneck.

✅ xxHash 30 GB/s. Crypto only when security matters.

### Pitfall 4 — Compare with == instead of constant-time

❌ Compare HMAC with `==` → timing attack possible.

✅ `hmac.compare_digest()` constant-time.

---

## 🌱 Advanced topics

### A1. Hash collisions in practice

Birthday paradox: 50% chance collision với √(2^n) inputs.
- MD5 (128 bit): 2^64 ≈ 18 quintillion. Practical attacks shown.
- SHA-256 (256 bit): 2^128 ≈ infeasible.

### A2. HMAC — keyed hash

`HMAC(key, message) = hash(key + hash(key + message))`. Verifies both integrity + authenticity.

### A3. Merkle tree

Hash of hashes in tree structure. Used in Bitcoin, Git, IPFS, Cassandra anti-entropy.

→ Efficient verify subset of data + detect which subset changed.

### A4. Apply cho LLM 2026

- **Anthropic prompt cache key** = hash of prompt prefix
- **Vector DB content-addressable** — hash for dedup
- **Model artifact integrity** — SHA-256 of model weights for safety

---

## 🧠 Self-test

1. Checksum vs crypto hash: difference?
2. CRC32 catches what type of errors?
3. Why MD5 still useful for non-security purposes?
4. xxHash vs SHA-256 speed difference?
5. Why hmac.compare_digest constant-time matter?
6. Merkle tree: how does it help anti-entropy in Cassandra?

---

## 🔗 Liên kết

- **[F01/10 Compression](./10-compression-basics.md)** — checksums of compressed blocks
- **[F01/17 CRC/MD5/SHA](./17-hash-families.md)** — deep dive families
- **[F13 Security](../../semester-2-systems-theory/F13-security-privacy/)** — crypto hash use

---

**Đã đọc xong?**
✅ Tick → [F01/12 Bit manipulation](./12-bit-manipulation.md).
