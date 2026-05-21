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

## 🧩 The Crux of the Problem  *(v3 — OSTEP-style framing)*

> **Core question:** Có 3 thế hệ hash functions — non-crypto (xxHash, MurmurHash), broken crypto (MD5, SHA-1), modern crypto (SHA-256, SHA-3, BLAKE3). Cho mỗi use case (hash table, integrity, password, signature, prompt cache key) pick **đúng cái**?
>
> **Why hard:** Mỗi family có speed vs security trade-off cực khác. Pick chậm cho hot path = throughput sập. Pick non-crypto cho security = HashDoS / collision attack. Pick MD5 cho password 2026 = security incident.
>
> **What we need:** Biết **threat model** (có attacker không? collision attack possible?), **speed budget** (hot path vs cold storage), **legacy compatibility** (Git stuck SHA-1, S3 ETag stuck MD5).

→ Khi memorize "use SHA-256 for security, xxHash for hash table" = đủ 90% case. Special case (length-extension attack, password hashing) còn lại = phải hiểu mechanism.

---

## 📜 Lịch sử ngắn  *(v3 — etymology + invention)*

- **CRC (1961)** — Peterson, polynomial-based error detection.
- **MD5 (1992)** — **Ron Rivest** (MIT) — Message Digest 5. Pre-internet era. Broken 2004 (Wang collision attack, Crypto conference).
- **SHA-0 (1993) → SHA-1 (1995)** — NSA designed, NIST standard. SHA-0 had flaw, replaced với SHA-1 within 2 years. SHA-1 collision found 2005 theoretical, 2017 practical (Google **SHAttered** với $110K compute).
- **SHA-2 family (2001)** — NSA / NIST. SHA-224, SHA-256, SHA-384, SHA-512. Still secure 2026.
- **SHA-3 / Keccak (2015)** — NIST competition winner (2007-2012). Different design (sponge construction) → backup nếu SHA-2 broken. Adopted slower than expected.
- **BLAKE (2008)** → **BLAKE2 (2012)** → **BLAKE3 (2020)** — non-NIST hash family. BLAKE3 = tree hashing, parallel, 10 GB/s, modern darling.
- **MurmurHash (2008)** — **Austin Appleby** — non-crypto, fast for hash table. Used in Cassandra Bloom filter, Hadoop.
- **xxHash (2012)** — **Yann Collet** (Facebook) — 30 GB/s, non-crypto. Used in LZ4, Zstd dictionary, ClickHouse.
- **Today (2026):** xxHash/MurmurHash cho hash table; SHA-256 cho security; BLAKE3 cho high-throughput integrity; bcrypt/argon2 cho password.

---

## 🧮 Pseudocode — HMAC + Bloom filter hash  *(v3 — Erickson UIUC style)*

### HMAC (mitigate length-extension attack)

```
HMAC(key K, message M):
    if length(K) > BLOCK_SIZE then K ← HASH(K)
    if length(K) < BLOCK_SIZE then K ← K + ZERO_PAD
    ipad ← K XOR (0x36 repeated)
    opad ← K XOR (0x5C repeated)
    return HASH(opad || HASH(ipad || M))   《|| = concatenation》
```

→ Why double hash? Vì MD5/SHA-1/SHA-2 Merkle-Damgård construction có length-extension attack — attacker biết `hash(secret || M)` có thể compute `hash(secret || M || M')`. HMAC giải quyết.

### Bloom filter dùng k hash functions

```
BLOOM_INSERT(bits, x, k):
    for i ← 1 to k
        h ← HASH_i(x) mod length(bits)
        bits[h] ← 1

BLOOM_LOOKUP(bits, x, k):
    for i ← 1 to k
        h ← HASH_i(x) mod length(bits)
        if bits[h] = 0 then return ABSENT       《definitely not in set》
    return MAYBE_PRESENT                         《1% false positive》
```

→ **Trick:** k hash functions có thể derive từ 2 hashes: `h_i(x) = h1(x) + i · h2(x)` (Kirsch-Mitzenmacher 2006).

---

## ❌ Bad example / anti-pattern  *(v3 — "Martin's algorithm" style)*

### Anti-pattern 1 — MD5 cho password

```python
# ❌ Hash password with MD5
import hashlib
def hash_password(pw):
    return hashlib.md5(pw.encode()).hexdigest()
# Rainbow table có sẵn cho mọi password phổ biến → crack trong giây
# MD5 designed cho integrity, không phải password
```

**Tại sao bad:** Password hash cần (a) slow (work factor), (b) salt, (c) memory-hard. Pick `bcrypt` / `argon2` / `scrypt`.

### Anti-pattern 2 — `hash(secret || message)` cho HMAC

```python
# ❌ Naive MAC
def my_mac(secret, message):
    return hashlib.sha256(secret + message).hexdigest()
# Length-extension attack: attacker có (message, mac) → compute mac(secret + message + suffix)
# Famous: Flickr API 2009 vulnerable
```

**Tại sao bad:** Merkle-Damgård vulnerability. Pick `hmac.new(secret, message, hashlib.sha256).hexdigest()`.

### Anti-pattern 3 — Compare hash với `==`

```python
# ❌ String equality cho hash compare
if user_provided_token == expected_token:
    grant_access()
# Timing attack: `==` short-circuit reveal match position
# 100ms easily distinguish first-char-correct vs all-wrong
```

**Tại sao bad:** Constant-time compare needed cho security. Pick `hmac.compare_digest(a, b)`.

### Anti-pattern 4 — Truncate SHA-256 to 64 bits

```python
# ❌ "Save memory" by taking first 8 bytes of SHA-256
hash_short = hashlib.sha256(data).hexdigest()[:16]   # 64 bits = 16 hex chars
# Birthday collision at 2^32 ≈ 4 billion — feasible for attacker
```

**Tại sao bad:** Security strength = half of hash length (birthday bound). 64-bit hash → 32-bit collision resistance. Keep full 256 bits for security uniqueness.

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

## 🌐 Đọc thêm — refs cụ thể vào library  *(v3 — pointers chính xác)*

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **Sedgewick Princeton slides** → `Sedgewick_Princeton_HashTables.pdf` — hash functions trong context hash table (universal hashing).
- **MIT Math for CS** → `Lehman_MIT_MathForCS.pdf` — number theory + modular arithmetic foundation cho cryptographic hash.

📄 **Paper gốc + spec:**
- Rivest (1992), [*RFC 1321: MD5*](https://datatracker.ietf.org/doc/html/rfc1321).
- NIST FIPS 180-4 (2015), *"Secure Hash Standard (SHS)"* — SHA-2 family standard.
- NIST FIPS 202 (2015), *"SHA-3 Standard"* — Keccak.
- Wang & Yu (2005), *"How to Break MD5 and Other Hash Functions"*, EUROCRYPT.
- Stevens et al. (2017), *["The First Collision for Full SHA-1"](https://shattered.io/)* — Google SHAttered.
- O'Connor et al. (2020), [BLAKE3 spec](https://github.com/BLAKE3-team/BLAKE3-specs).
- Kirsch & Mitzenmacher (2006), *"Less hashing, same performance: building a better bloom filter"*.
- Appleby (2008) — [MurmurHash3](https://github.com/aappleby/smhasher).
- Collet (2012) — [xxHash spec](https://xxhash.com/).
- Provos & Mazières (1999), *"A future-adaptable password scheme"* — bcrypt.
- Biryukov et al. (2016), *"Argon2: New generation of memory-hard password hashing"* — Password Hashing Competition winner.

---

**Đã đọc xong?**
✅ Tick → [F01/18 Algorithmic complexity classes (P, NP)](./18-complexity-classes.md).
