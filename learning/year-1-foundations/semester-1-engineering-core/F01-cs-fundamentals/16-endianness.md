# KU F01 / 16 — Endianness: big vs little endian

> **Endianness** = thứ tự byte trong word. x86/ARM = **little-endian** (byte thấp trước). Network protocol = **big-endian**. Quên convert = bug đọc binary file sai số. Phổ biến trong data plumbing.

**Module:** [F01 — CS Fundamentals](./README.md)
**Prereqs:** [F01/01 Bits, bytes](./01-bits-bytes-encoding.md)
**Related KUs:** [F06 Networks](../../semester-2-systems-theory/F06-computer-networks/)
**Đọc trong:** ~8 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn viết số **1,234** xuống giấy. 2 cách:

### Big-endian: "to (most significant) trước"
- Viết "1234" — bình thường như đọc số trong tiếng Việt.
- Đọc trái sang phải.

### Little-endian: "nhỏ trước"
- Viết "4321" — đảo ngược.
- Đọc từ phải sang để hiểu đúng.

Cả 2 cùng lưu số **1,234** nhưng **byte order khác**. Trong CPU:

```
32-bit integer 0x12345678 (decimal 305,419,896):

Big-endian (network, mainframe, Java internal):
  Address 0: 0x12
  Address 1: 0x34
  Address 2: 0x56
  Address 3: 0x78

Little-endian (x86, ARM, modern PCs):
  Address 0: 0x78
  Address 1: 0x56
  Address 2: 0x34
  Address 3: 0x12
```

→ Cùng giá trị, **byte sequence khác** trong memory. Khi đọc/ghi binary file across systems → phải biết.

---

## 🧩 The Crux of the Problem  *(v3 — OSTEP-style framing)*

> **Core question:** 32-bit integer `0x12345678` lưu trong memory dưới 4 bytes. Theo thứ tự nào? Network protocols dùng order A, x86 CPU dùng order B → khi truyền data qua network phải convert.
>
> **Why hard:** Không có "right" answer — historical accident. Different vendors picked different orders. Cross-platform binary file = bug nếu quên convert. Big-endian network byte order = TCP/IP standard từ 1981.
>
> **What we need:** Biết platform của mình (x86/ARM = little-endian, mainframe SPARC = big-endian), use `htons/htonl` cho network code, specify endianness explicit khi serialize binary.

→ "Endianness" = phép thử nghiêm trọng nhất khi port code mainframe → cloud. Skip = bug invisible cho test, chỉ lộ trên specific data.

---

## 📜 Lịch sử ngắn  *(v3 — etymology + invention)*

- **Tên "big-endian / little-endian"** từ **Jonathan Swift, "Gulliver's Travels" (1726)** — Lilliputians chiến tranh vì bóc trứng nên đập đầu lớn (Big-Endians) hay đầu nhỏ (Little-Endians). **Danny Cohen (1980)** mượn metaphor trong paper *"On Holy Wars and a Plea for Peace"* để khái niệm computer byte order.
- **Network byte order = big-endian** — chọn năm 1981 (RFC 791 IP) vì PDP-10, IBM mainframe, Motorola 68000 đều big-endian.
- **x86 little-endian** — Intel 8080 (1974) chose little-endian cho efficient 8-bit arithmetic (lo byte trước = easier multi-precision).
- **ARM bi-endian** — switchable, default little-endian on most platforms (Android, iOS).
- **Java internal big-endian** — JVM specifies BE regardless of host. `DataOutputStream.writeInt()` always BE.
- **Today (2026):** x86/ARM dominant = little-endian everywhere. Network protocols still big-endian. File formats split (Parquet/Avro LE, JVM class BE, BMP LE, TIFF flexible).

---

## ❌ Bad example / anti-pattern  *(v3 — "Martin's algorithm" style)*

### Anti-pattern 1 — Send `uint16_t` port qua network không htons

```c
// ❌ Bind socket to port 80
struct sockaddr_in addr;
addr.sin_port = 80;              // x86: bytes 50 00
bind(sock, (struct sockaddr*)&addr, sizeof(addr));
// Network expects big-endian → server actually listening on 0x5000 = 20480
```

**Tại sao bad:** Network byte order = BE. x86 native = LE. Skip `htons()` = port wrong silently. **Always** wrap port + IP với htons/htonl trong network code.

### Anti-pattern 2 — Cast pointer to read multi-byte directly

```c
// ❌ Read 4 bytes as int without endian-aware
uint8_t buf[4] = {0x12, 0x34, 0x56, 0x78};
int* p = (int*)buf;
int value = *p;
// x86: 0x78563412
// big-endian machine: 0x12345678
// Code không portable
```

**Tại sao bad:** Pointer cast assume host endianness. Pick explicit:
```c
uint32_t value = ((uint32_t)buf[0] << 24) | ((uint32_t)buf[1] << 16)
               | ((uint32_t)buf[2] << 8)  | buf[3];   // big-endian explicit
```

### Anti-pattern 3 — UTF-16 file không có BOM

```python
# ❌ Save UTF-16 without BOM
text = "Hello"
with open('out.txt', 'wb') as f:
    f.write(text.encode('utf-16-le'))      # raw LE, no BOM

# Receiver doesn't know endianness → may decode as utf-16-be → garbage
```

**Tại sao bad:** UTF-16 needs BOM (`FE FF` BE, `FF FE` LE) hoặc explicit endianness in protocol. Better: use **UTF-8** (no endianness).

### Anti-pattern 4 — Test code chỉ trên 1 architecture

```python
# ❌ Test pass trên Intel x86, prod crash trên ARM
def parse_header(data):
    return struct.unpack('I', data[:4])[0]    # native byte order
# x86 (LE) parse data từ TCP (BE) → 0x12345678 read as 0x78563412
# But test fixture also written from x86 → tests pass
```

**Tại sao bad:** `struct.unpack('I', ...)` = host endianness. Pick `<I` (LE) hoặc `>I` (BE) explicit. Run tests on cross-platform CI (GitHub Actions ARM runner) hoặc QEMU.

---

## 📖 Định nghĩa chính thức

**Endianness** = order of bytes within a multi-byte value.

- **Big-endian (BE)**: most significant byte first. "Network byte order".
- **Little-endian (LE)**: least significant byte first. Intel x86, ARM.

Single-byte values (uint8) → no endianness.
Multi-byte (int16, int32, int64, float32, float64) → endianness matters.

Standards:
- **TCP/IP, UDP, DNS** = big-endian (network order)
- **x86, AMD64** = little-endian (host)
- **ARM** = configurable, default little-endian on Android/iOS
- **PowerPC, SPARC** = big-endian (legacy mainframe)
- **Java internal** = big-endian (regardless of host)
- **JVM `ByteBuffer.order(LITTLE_ENDIAN)`** = switch

C library macros:
- `htons()`, `htonl()` = host to network short/long (16/32 bit)
- `ntohs()`, `ntohl()` = network to host

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Endianness | Endianness | Byte order in multi-byte value |
| Big-endian | Big-endian (BE) | Most significant byte first |
| Little-endian | Little-endian (LE) | Least significant byte first |
| Network byte order | Network byte order | Big-endian, used in TCP/IP |
| Host byte order | Host byte order | Native CPU order |
| Byte order mark | BOM | Initial bytes signaling encoding/endianness |
| Swab / byte swap | Byte swap | Reverse byte order |
| Bi-endian | Bi-endian | Hardware switchable |

---

## 🚀 Real-world impact

### Bug 1 — Read binary file from different system

```python
import struct

# File written on x86 (little-endian): int32 value 1
with open('legacy.bin', 'rb') as f:
    data = f.read(4)   # bytes: 01 00 00 00

# Read assuming network order:
val = struct.unpack('>i', data)[0]   # 16777216 ❌ wrong
# Read explicit little-endian:
val = struct.unpack('<i', data)[0]   # 1 ✓
```

→ `struct` format string: `<` little, `>` big, `=` host (default).

### Bug 2 — UTF-16 without BOM

```
File starts with:
  00 48 00 65 00 6C 00 6C 00 6F   (UTF-16 BE: "Hello")
  
Read as UTF-16 LE:
  48 00 65 00 6C 00 6C 00 6F 00   (= different chars: 䠀攀氀氀漀)
```

→ UTF-16 has BOM (`FE FF` BE, `FF FE` LE) to disambiguate.

### Bug 3 — Network protocol port number

```c
// Want to send connection to port 80
uint16_t port_native = 80;        // x86: bytes 50 00
// Send raw → server sees 0x5000 = 20480 ❌

uint16_t port_net = htons(80);    // BE: 00 50 → server sees 80 ✓
```

→ `htons` essential for network code.

### File formats endianness

| Format | Endianness |
|---|---|
| TCP/IP headers | Big-endian |
| DNS messages | Big-endian |
| JVM `.class` files | Big-endian |
| BMP image | Little-endian |
| TIFF | Both (specified in header) |
| Parquet | Little-endian |
| Avro | Little-endian (for binary) |
| ELF / Mach-O | Either (specified in header) |

---

## 🔧 How to handle

### Python `struct`

```python
import struct

value = 0x12345678

# Big-endian
struct.pack('>I', value)   # b'\x12\x34\x56\x78'

# Little-endian
struct.pack('<I', value)   # b'\x78\x56\x34\x12'

# Host (native)
struct.pack('=I', value)
```

### C / C++

```c
#include <arpa/inet.h>

uint32_t value = 0x12345678;
uint32_t net_value = htonl(value);   // host to network
uint32_t back = ntohl(net_value);    // network to host
```

### Java

```java
ByteBuffer buf = ByteBuffer.allocate(4);
buf.order(ByteOrder.LITTLE_ENDIAN);   // override default BE
buf.putInt(0x12345678);
```

### Hexdump

```bash
echo -n "Hi" | hexdump -C
# 00000000  48 69  |Hi|

printf '\x01\x00\x00\x00' | od -An -tx4 -EL  # little-endian: 1
printf '\x00\x00\x00\x01' | od -An -tx4 -EB  # big-endian: 1
```

---

## ⚠️ Common pitfalls

### Pitfall 1 — Read binary without endianness spec

❌ `struct.unpack('I', data)` uses host endianness → portable code breaks across platforms.

✅ Always specify `<` or `>`.

### Pitfall 2 — Forget htons/htonl in C network code

❌ `bind` with native port → wrong port on big-endian system.

✅ Always wrap port with `htons()`.

### Pitfall 3 — UTF-16 detect endianness wrong

❌ No BOM → guess wrong → text garbled.

✅ Either always use UTF-8 (no endianness), or include BOM.

---

## 🌱 Advanced topics

### A1. Mixed endianness ("PDP-endian", historical)

PDP-11: 32-bit int stored as `byte1 byte0 byte3 byte2` (swap word but keep byte order). Rare today.

### A2. Network byte order legacy

TCP/IP designed 1970s, network protocols stuck with big-endian. Modern CPUs little-endian. Endless `htons/ntohs` boilerplate.

### A3. Apply cho LLM 2026

Model weight files (PyTorch .pt, GGUF, safetensors) specify endianness in header. Quantization tools handle conversion.

---

## 🧠 Self-test

1. Big-endian vs little-endian: which is x86?
2. Network byte order = which?
3. Why `htons(80)` for port?
4. UTF-16 BOM `FE FF` vs `FF FE`: which is BE?
5. Parquet endianness: little or big?

---

## 🔗 Liên kết

- **[F01/01 Bits, bytes](./01-bits-bytes-encoding.md)** — byte foundation
- **[F01/15 String encoding](./15-string-encoding-bugs.md)** — UTF-16 endianness
- **[F06 Networks](../../semester-2-systems-theory/F06-computer-networks/)** — network byte order

---

## 🌐 Đọc thêm — refs cụ thể vào library  *(v3 — pointers chính xác)*

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **Beej Network Programming** → `Beej_NetworkProgramming_C.pdf` — htons/htonl examples + chapter on byte ordering. **Bài đọc bắt buộc** cho topic này.
- **CSAPP samples (CMU)** → byte ordering trong Chapter 2 sample.

📄 **Paper gốc + spec:**
- **Cohen (1980)**, *["On Holy Wars and a Plea for Peace"](https://www.ietf.org/rfc/ien/ien137.txt)*, IEN 137 — coined "endianness".
- **RFC 791 (1981)** — IP, network byte order = big-endian.
- **RFC 1700 (1994)** — Assigned Numbers (replaced by [iana.org](https://www.iana.org/)).
- **Apache Parquet spec** — [github.com/apache/parquet-format](https://github.com/apache/parquet-format) — file format LE.
- **Apache Avro spec** — [avro.apache.org/docs](https://avro.apache.org/docs/) — binary LE.

---

**Đã đọc xong?**
✅ Tick → [F01/17 CRC, MD5, SHA hash families](./17-hash-families.md).
