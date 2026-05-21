# KU F01 / 12 — Bit manipulation cơ bản

> **Bit manipulation** = operate trên individual bits. Dùng cho flags, masks, bit packing, performance tricks. Hiếm dùng trong app code, nhưng **everywhere** trong DB internals, file formats, networking, compression.

**Module:** [F01 — CS Fundamentals](./README.md)
**Prereqs:** [F01/01 Bits, bytes](./01-bits-bytes-encoding.md)
**Related KUs:** [F01/13 Random](./13-pseudo-random-vs-crypto.md) · [F01/16 Endianness](./16-endianness.md)
**Đọc trong:** ~10 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn có 1 cái **đèn bão 8 bóng**. Mỗi bóng on/off độc lập. Status = chuỗi 8 ký hiệu:

```
🟡⚫⚫🟡⚫🟡⚫🟡  = 10010101
```

8 bit = 1 byte. Mỗi bit = 1 bóng. Bit operations = bật/tắt/đảo bóng:

- **AND (`&`)** — "cả 2 phải on" → kết quả on. Dùng để **kiểm tra bit**.
- **OR (`|`)** — "1 trong 2 on" → kết quả on. Dùng để **bật bit**.
- **XOR (`^`)** — "khác nhau" → on. Dùng để **đảo bit**.
- **NOT (`~`)** — đảo tất cả.
- **Shift left (`<<`)** — đẩy bit sang trái = nhân 2.
- **Shift right (`>>`)** — đẩy bit sang phải = chia 2.

Ví dụ: flags pack 8 boolean trong 1 byte:

```
permissions: [read, write, exec, delete, admin, audit, suspend, expire]
binary:      [   1,    1,    0,      0,     1,     0,       0,      0]
= 0b11001000 = 200

Check "user can read?"
  user_perms & 0b10000000 != 0  → bit 0 (read) on → yes

Add "delete" permission:
  user_perms |= 0b00010000

Remove "admin" permission:
  user_perms &= ~0b00001000  (NOT admin mask, AND)
```

→ 8 boolean trong 1 byte vs 8 bytes (1 bool/byte) = **8x memory savings**.

---

## 🧩 The Crux of the Problem  *(v3 — OSTEP-style framing)*

> **Core question:** Cho 8 boolean flags trong 1 record × 1 tỷ records = 8 GB nếu mỗi bool = 1 byte. Làm sao **pack 8 flags vào 1 byte** + manipulate (set/clear/toggle/check) trong 1 CPU instruction?
>
> **Why hard:** Modern languages abstract bits away. Python `bool` = 28 bytes object overhead. Java `boolean` = 1 byte. C `_Bool` = 1 byte. Để thực sự xài 1 bit = phải dùng bitwise operators (AND, OR, XOR, NOT, shift) — low-level skill.
>
> **What we need:** 6 bitwise primitives — `&`, `|`, `^`, `~`, `<<`, `>>` — đủ để build flag set, bit field, bloom filter, integer encoding/decoding. CPU thực hiện trong 1 cycle.

→ Bit manipulation = vốn cho mọi protocol design (TCP flags, IPv4 header, Parquet bit-packing, Arrow validity bitmap).

---

## 📜 Lịch sử ngắn  *(v3 — etymology + invention)*

- **Boolean algebra (1854)** — **George Boole** — *"An Investigation of the Laws of Thought"*. AND/OR/NOT operations định nghĩa formal trên `{0, 1}`. Foundation cho mọi digital logic.
- **Claude Shannon (1937)** — MIT MSc thesis — apply Boolean algebra vào electrical circuits. Foundation cho computer design.
- **Bitwise operators** xuất hiện trong **B language (1969)** → **C (1972)** — Dennis Ritchie. C giữ nguyên semantics đến nay.
- **Bit twiddling hacks** — **Sean Eron Anderson** (Stanford) maintain famous page [graphics.stanford.edu/~seander/bithacks.html](https://graphics.stanford.edu/~seander/bithacks.html) — tricks classic như: detect power of 2, count bits set (popcount), reverse bits, swap without temp.
- **Hardware bit operations** — modern CPU SIMD instructions (POPCNT, PDEP, PEXT in BMI2) accelerate population count + bit extraction.
- **Today (2026):** Bit manipulation backbone của Parquet bit-packing (RLE), Arrow validity bitmap, Bloom filter, IP routing (BGP route summarization), color encoding (RGB565 mobile games).

---

## ❌ Bad example / anti-pattern  *(v3 — "Martin's algorithm" style)*

### Anti-pattern 1 — Overuse bit manipulation cho readability

```c
// ❌ "Clever" code
int abs_val = (x ^ (x >> 31)) - (x >> 31);   // abs() for int32

// vs:
int abs_val = (x < 0) ? -x : x;              // 10× rõ ràng hơn
```

**Tại sao bad:** Premature bit twiddling kills readability. Modern compilers tự optimize `abs()` thành bit hack. Pick clarity unless profile shows bottleneck.

### Anti-pattern 2 — Confuse signed shift vs unsigned shift

```c
int8_t x = -128;       // 1000 0000
int8_t y = x >> 1;     // signed: 1100 0000 = -64 (arithmetic shift, fill sign bit)
uint8_t z = (uint8_t)x >> 1;  // unsigned: 0100 0000 = 64 (logical shift, fill 0)
```

**Tại sao bad:** Behavior khác nhau theo signedness. Java `>>` arithmetic, `>>>` logical. Python `>>` always arithmetic. C undefined cho signed negative.

### Anti-pattern 3 — Set flag bằng OR-EQUAL mỗi lần

```python
# ❌ "Toggle" flag bằng OR (luôn set, không thực sự toggle)
flags |= ADMIN_MASK   # always set, never clear
```

**Tại sao bad:** `|=` chỉ set. Toggle thật cần XOR: `flags ^= ADMIN_MASK`.

### Anti-pattern 4 — Quên parenthesize bitwise vs comparison

```c
// ❌ Precedence trap
if (flags & 0x01 == 0)   // = flags & (0x01 == 0) = flags & 0
                          // không phải (flags & 0x01) == 0

// ✅ Always parenthesize
if ((flags & 0x01) == 0)
```

**Tại sao bad:** `==` bind tighter than `&` trong C/Java. Common bug. Always parenthesize bitwise ops.

---

## 📖 Định nghĩa chính thức

**Bit manipulation** = operate trên bits trực tiếp bằng bitwise operators:

| Operator | Symbol | Logic |
|---|---|---|
| AND | `&` | 1 if both 1 |
| OR | `\|` | 1 if either 1 |
| XOR | `^` | 1 if different |
| NOT | `~` | flip all |
| Left shift | `<<` | shift bits left, fill 0 |
| Right shift | `>>` | shift bits right |

Common patterns:
- **Set bit k:** `n \|= (1 << k)`
- **Clear bit k:** `n &= ~(1 << k)`
- **Toggle bit k:** `n ^= (1 << k)`
- **Check bit k:** `(n >> k) & 1` or `n & (1 << k) != 0`
- **Count set bits:** `bin(n).count('1')` or `popcount`
- **Lowest set bit:** `n & -n`
- **Check power of 2:** `n & (n-1) == 0`

**Nguồn:**
- "Hacker's Delight" (Henry Warren) — bit manipulation classic.
- CLRS Appendix C.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Thao tác bit | Bit manipulation | Operate on individual bits |
| Bitwise AND | Bitwise AND | Apply AND per bit |
| Bit mask | Bit mask | Pattern of bits used to extract/set |
| Bit field | Bit field | Group of bits with meaning |
| Bit packing | Bit packing | Pack multiple values in fewer bits |
| Bit-set | Bitset | Array of bits |
| Bitmap | Bitmap | Similar to bitset |
| popcount | Population count | Count of 1-bits |
| Leading zeros | Leading zeros | Count of leading 0-bits |
| Trailing zeros | Trailing zeros | Count of trailing 0-bits |
| Endianness | Endianness | Byte order |
| Two's complement | Two's complement | Encoding for signed integer |
| Sign extension | Sign extension | Preserve sign on widening |
| Arithmetic shift | Arithmetic shift | Right shift preserving sign |
| Logical shift | Logical shift | Right shift filling 0 |

---

## 💡 Real-world uses

### 1. Flags in 1 byte (file permissions)

Unix file mode: `rwxrwxrwx` = 9 bits in 1 byte (with type bits 12 bits total).

```c
mode_t mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
// owner: read+write, group: read, other: read
// = 0644 octal
```

### 2. Bit packing in Parquet

Column with integers 0-100 needs only 7 bits each. Pack 8 values into 7 bytes.

```
Values: 50, 75, 30, 100, 25, 80, 60, 95 (each 7 bits)
Packed: 56 bits = 7 bytes (vs 32 bytes if each int32)
→ 4.5x memory reduction
```

### 3. Bloom filter

```python
class BloomFilter:
    def __init__(self, size, num_hashes):
        self.bits = 0  # one giant int as bitset
        self.size = size
        self.num_hashes = num_hashes

    def add(self, item):
        for i in range(self.num_hashes):
            idx = hash((item, i)) % self.size
            self.bits |= (1 << idx)

    def contains(self, item):
        for i in range(self.num_hashes):
            idx = hash((item, i)) % self.size
            if not (self.bits >> idx) & 1:
                return False
        return True
```

### 4. Roaring bitmaps (ClickHouse, Druid)

Efficient set operations on large sparse integer sets via bit manipulation. Used cho query filtering.

### 5. CPU instructions

`popcnt`, `lzcnt`, `tzcnt`, `bsr`, `bsf` — hardware bit operations. Used in compression, hash, vectorized scan.

### 6. Network IP masks

IPv4 subnet `192.168.1.0/24` = first 24 bits network, last 8 bits host.

```python
ip = 0xC0A80105  # 192.168.1.5
mask = 0xFFFFFF00  # /24
network = ip & mask  # 192.168.1.0
```

---

## ⚠️ Common pitfalls

### Pitfall 1 — Operator precedence

❌ `a & 1 == 0` → due to precedence, evaluated `a & (1 == 0)` = `a & 0` = 0.

✅ `(a & 1) == 0` → explicit parens.

### Pitfall 2 — Sign bit unexpected

❌ Right shift signed int in Java: `(-1) >> 1` keeps sign (= -1).

✅ Unsigned shift `(-1) >>> 1` → fills 0.

### Pitfall 3 — XOR with self = 0

Trick: swap variables without temp:
```c
a ^= b; b ^= a; a ^= b;
```
But: if `a` and `b` reference same location → result 0. Edge case.

### Pitfall 4 — Bit count manually

❌ Naive `count = 0; while n: count += n & 1; n >>= 1` → O(bits).

✅ Use `popcount` builtin (hardware-accelerated) or `bin(n).count('1')`.

---

## 🌱 Advanced topics

### A1. SWAR (SIMD Within A Register)

Treat 64-bit register as 8 × 8-bit values. Apply ops in parallel using bit tricks.

→ Used in ClickHouse, DuckDB for vectorized scan.

### A2. Hamming distance

XOR + popcount → count of differing bits.

Used in error detection, near-duplicate detection (SimHash).

### A3. Z-order curve / Morton encoding

Interleave bits of multi-dim coords → 1D ordering preserving locality.

→ Used in spatial indexes (RocksDB, Iceberg).

### A4. Apply cho AI 2026

- **Quantized weights** in INT8 → bit-packed for memory + SIMD
- **Sparse attention masks** = bitmaps
- **Sign bit + magnitude** for low-precision arithmetic

---

## 🧠 Self-test

1. Set bit 5 of n? Clear bit 3? Check bit 7?
2. Why `n & (n-1) == 0` checks power of 2?
3. Pack 4 values (each 4 bits) in 16 bits — code?
4. Compute popcount manually for `0b10110101`.
5. IPv4 `/24` subnet: how many bits network? How many hosts?
6. Why `a & 1 == 0` operator precedence gotcha?

---

## 🔗 Liên kết

- **[F01/01 Bits, bytes](./01-bits-bytes-encoding.md)** — foundation
- **[F01/16 Endianness](./16-endianness.md)** — byte order
- **[F10 Databases II](../../semester-2-systems-theory/F10-databases-beyond-sql/)** — bit packing Parquet

---

## 🌐 Đọc thêm — refs cụ thể vào library  *(v3 — pointers chính xác)*

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **CSAPP samples (CMU)** → bits + boolean algebra chapter sample.
- **Beej C Programming** → `Beej_C_Programming.pdf` — bitwise operators reference với examples.

📄 **Reference + spec:**
- **Sean Anderson, *"Bit Twiddling Hacks"*** — [graphics.stanford.edu/~seander/bithacks.html](https://graphics.stanford.edu/~seander/bithacks.html) — collection of 200+ tricks.
- **Hank Warren Jr., *"Hacker's Delight" 2nd ed (2012)*** — bible of bit-level algorithms.
- **Intel BMI / BMI2 reference** — hardware bit manipulation instructions.
- **Boole (1854)**, *"An Investigation of the Laws of Thought"* — Boolean algebra foundation, Archive.org.
- **Shannon (1937)** MSc thesis, MIT.

---

**Đã đọc xong?**
✅ Tick → [F01/13 Pseudo-random vs crypto-random](./13-pseudo-random-vs-crypto.md).
