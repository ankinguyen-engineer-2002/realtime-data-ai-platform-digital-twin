# KU F01 / 17 — CRC, MD5, SHA hash families

> **Hash families** = 3 thế hệ hash functions, mỗi cái có purpose khác. CRC (integrity), MD5/SHA-1 (legacy, broken cho security), SHA-256/SHA-3/BLAKE3 (modern). Pick đúng = balance speed + security.

**Module:** [F01 — CS Fundamentals](./README.md)
**Prereqs:** [F01/11 Checksums](./11-checksums-integrity.md)
**Related KUs:** [F13 Security](../../semester-2-systems-theory/F13-security-privacy/)
**Đọc trong:** ~12 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn cần "công thức tóm tắt" data → ngắn fixed-size số. 3 loại "công thức":

### Loại 1 — CRC: nhanh, chỉ phát hiện accidental error
- Như **đếm dấu chấm + tổng ký tự** ở cuối hợp đồng.
- Phát hiện thư bị rách, ướt, mất trang.
- KHÔNG bảo vệ chống attacker cố ý sửa thư + tính lại checksum.

### Loại 2 — MD5/SHA-1: ngày xưa được dùng cho security
- Như **đóng dấu mộc** lên thư + dán nhãn "khó copy".
- Năm 1990s: an toàn. Năm 2010s: technique vỡ → attacker tạo 2 thư khác nội dung cùng dấu mộc (collision attack).
- Vẫn dùng cho non-security (file integrity, Git legacy).

### Loại 3 — SHA-256, SHA-3, BLAKE3: modern secure
- Như **chữ ký số** + **mã hoá** kết hợp.
- Practical attacks không khả thi đến 2026.
- Tuy nhiên chậm hơn CRC ~50-100x.

---

## 📖 So sánh families

| Hash | Year | Bits | Speed | Security |
|---|---|---:|---:|---|
| **CRC32** | 1961 | 32 | 6 GB/s (HW) | ❌ Not secure, fast integrity |
| **CRC32C** | 1993 | 32 | 6 GB/s (HW, Intel SSE4.2) | ❌ Same, used in iSCSI |
| **MD5** | 1992 | 128 | 600 MB/s | ❌ BROKEN (collisions found 2004) |
| **SHA-1** | 1993 | 160 | 1 GB/s | ❌ BROKEN (Google SHAttered 2017) |
| **SHA-256** | 2001 | 256 | 500 MB/s | ✅ Secure 2026 |
| **SHA-512** | 2001 | 512 | 700 MB/s (64-bit CPU) | ✅ Secure |
| **SHA-3** (Keccak) | 2015 | 224-512 | 400 MB/s | ✅ Secure, different design |
| **BLAKE2** | 2012 | 256/512 | 1.5 GB/s | ✅ Secure, fast |
| **BLAKE3** | 2020 | 256 | **10+ GB/s** (parallel) | ✅ Secure, modern |
| **xxHash** | 2012 | 32/64 | 30 GB/s | ❌ Not crypto, fast non-crypto |
| **MurmurHash3** | 2011 | 32/128 | 6 GB/s | ❌ Not crypto, hash table use |

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Hash family | Hash family | Generation of similar hash algorithms |
| Collision attack | Collision attack | Find 2 inputs → same hash |
| Pre-image attack | Pre-image attack | Find input given hash |
| Birthday attack | Birthday attack | Use birthday paradox to find collision |
| Merkle-Damgård | Merkle-Damgård construction | Used in MD5/SHA-1/SHA-2 |
| Sponge construction | Sponge construction | Used in SHA-3 |
| Length extension attack | Length extension attack | MD5/SHA-1/SHA-2 vulnerability |
| HMAC | HMAC | Mitigation against length extension |
| BLAKE | BLAKE | Modern hash family (Saarinen 2008) |
| Polynomial hash | Polynomial hash | CRC uses polynomial division |
| Avalanche | Avalanche | 1 bit input → 50% bits output change |
| Strong vs weak hash | Strong vs weak | Cryptographic guarantees |

---

## 💡 Use case map

| Use case | Hash |
|---|---|
| File download integrity (non-security) | SHA-256 or MD5 |
| TCP packet checksum | CRC32 (16-bit actually) |
| iSCSI/Btrfs block integrity | CRC32C |
| Git object ID | SHA-1 (legacy), migrating SHA-256 |
| Password hashing | **bcrypt/argon2** (not raw SHA) |
| Session token | random (not hash, just `secrets.token_*`) |
| HTTPS / TLS | SHA-256 / SHA-384 |
| Blockchain (Bitcoin) | SHA-256 (double) |
| Hash table | xxHash, MurmurHash |
| Cassandra Bloom filter | MurmurHash |
| Content-addressable storage (IPFS) | SHA-256 |
| Anthropic prompt cache | (internal, similar concept) |
| Image perceptual hash | pHash (not crypto) |

---

## 🚀 Real-world impact

### MD5/SHA-1 collision attacks

**MD5 (2004)**: Wang et al. found collisions in minutes.
- 2 different MS Word documents, same MD5.
- 2 different SSL certificates, same MD5.

**SHA-1 (2017)**: Google "SHAttered" attack, $110k of CPU time.
- 2 PDF documents, same SHA-1.

→ Don't use MD5/SHA-1 cho security. OK for integrity-only.

### Git's SHA-1 → SHA-256 migration

Git 2.29+ supports SHA-256 backend. Existing repos still SHA-1.

→ Sau khi SHA-1 broken, Git plans migration but slow.

### Bitcoin uses SHA-256

Bitcoin proof-of-work: find hash starting with N zeros.

→ Computational cost = security.

### Trong project DSX Air

| Where | Hash |
|---|---|
| Kafka batch CRC | CRC32C |
| Iceberg data file checksum | CRC32 |
| MinIO object ETag | MD5 (legacy, OK for integrity) |
| Git commit IDs | SHA-1 (auto, ok) |
| TLS handshake | SHA-256 |
| Postgres connection password | SCRAM-SHA-256 |

---

## 🔧 SHA-256 mechanics

Merkle-Damgård construction:
1. Pad input to multiple of 512 bits.
2. Initialize state (8 × 32-bit values).
3. For each 512-bit block:
   - Run 64 rounds of compression function.
   - Update state.
4. Output state = 256-bit hash.

→ Sequential. Cannot parallelize directly.

BLAKE3 difference: tree hashing → process chunks in parallel → 10× faster.

---

## ⚠️ Common pitfalls

### Pitfall 1 — Use MD5 for password

❌ `md5(password)` → rainbow tables → cracked instantly.

✅ `bcrypt` or `argon2` with salt + work factor.

### Pitfall 2 — Length extension attack

❌ `hash(secret + message)` for signature → attacker can append data.

✅ Use HMAC: `HMAC(secret, message)`.

### Pitfall 3 — Compare hashes with `==`

❌ Timing attack: `==` short-circuit reveals match position.

✅ `hmac.compare_digest()` constant-time.

### Pitfall 4 — Truncate hash

❌ Take first 8 chars of SHA-256 for uniqueness → birthday collision at 2^32.

✅ Keep full 256 bits for security uniqueness.

---

## 🌱 Advanced topics

### A1. Sponge construction (SHA-3)

Different from Merkle-Damgård. Absorbs input + squeezes output.

→ Resistant to length extension attack natively.

### A2. BLAKE3 tree hashing

Chunks 1KB → hash each → combine pairs → tree → root hash.

→ Embarrassingly parallel. Modern multi-core wins.

### A3. Apply cho LLM 2026

- **Anthropic prompt caching** key derivation via hash
- **Model artifact integrity** via SHA-256
- **Content-addressable RAG** docs identified by hash

---

## 🧠 Self-test

1. MD5: broken? Why still used non-security?
2. SHA-256 vs BLAKE3: speed difference + why?
3. Length extension attack: how? HMAC mitigation?
4. Bitcoin uses what hash + how many rounds?
5. CRC32 vs SHA-256: use cases?
6. Why truncate SHA-256 to 64 bits = security risk?

---

## 🔗 Liên kết

- **[F01/11 Checksums](./11-checksums-integrity.md)** — non-crypto basics
- **[F13 Security](../../semester-2-systems-theory/F13-security-privacy/)** — full security context

---

**Đã đọc xong?**
✅ Tick → [F01/18 Algorithmic complexity classes (P, NP)](./18-complexity-classes.md).
