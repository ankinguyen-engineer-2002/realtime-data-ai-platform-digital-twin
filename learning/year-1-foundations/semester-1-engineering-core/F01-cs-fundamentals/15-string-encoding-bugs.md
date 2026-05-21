# KU F01 / 15 — String encoding bugs: UTF-8 vs Latin-1 trap

> 99% bug "ký tự lạ" trong DE bắt nguồn từ **encoding mismatch**. UTF-8 và Latin-1 trông như nhau cho ASCII nhưng **khác nhau hoàn toàn cho tiếng Việt**. Hiểu = debug encoding bugs trong 30 giây thay vì 1 tiếng.

**Module:** [F01 — CS Fundamentals](./README.md)
**Prereqs:** [F01/01 Bits, bytes](./01-bits-bytes-encoding.md)
**Related KUs:** [F01/16 Endianness](./16-endianness.md)
**Đọc trong:** ~10 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn gửi **bức thư viết bằng tiếng Việt** cho ông Pháp. Ông Pháp đọc thư theo **bảng chữ cái Pháp**:

```
Thư gửi: "Tiếng Việt rất hay"
Ông Pháp đọc qua bảng Pháp: "Tiá»…ng Viá»‡t rất hay"  ← Mojibake
```

→ Cùng bytes, **decode khác bảng** = lộn xộn.

UTF-8 + Latin-1 trên ASCII (A-Z, 0-9) **giống y nhau**. Nhưng **khác hoàn toàn cho dấu tiếng Việt**:

```
Chữ 'ế' trong UTF-8:    bytes E1 BA BF (3 bytes)
Chữ 'ế' trong Latin-1:  KHÔNG TỒN TẠI (Latin-1 chỉ có ñ, é, à...)

Decode UTF-8 bytes E1 BA BF as Latin-1:
  E1 = 'á' (Latin-1)
  BA = 'º' (Latin-1)
  BF = '¿' (Latin-1)
→ Output: "áº¿"  ← ký tự lạ
```

Đây là **Mojibake** (文字化け, "character corruption" tiếng Nhật) — phổ biến nhất khi file CSV legacy Latin-1 đọc bằng UTF-8, hoặc Excel mở UTF-8 file không có BOM.

---

## 📖 Quick reference: encoding map

| Encoding | Bytes/char | Tiếng Việt | Note |
|---|---|---|---|
| **ASCII** | 1 (7-bit) | ❌ | 128 chars only |
| **Extended ASCII / Latin-1** | 1 | ❌ | 256 chars, no Vietnamese |
| **Windows-1252** | 1 | ❌ | Microsoft Latin-1 |
| **VNI / TCVN3** | 1-2 | ✅ legacy | Vietnamese legacy |
| **UTF-8** | 1-4 | ✅ | Modern standard, 99% web |
| **UTF-16** | 2-4 | ✅ | Java/Windows internal |
| **UTF-32** | 4 | ✅ | Easy indexing, wasteful |

---

## 🔤 Common bug patterns

### Pattern 1 — "Tiá»…ng Viá»‡t" (UTF-8 bytes decoded as Latin-1)

**Cause:** File written UTF-8, opened as Latin-1.
**Fix:** Specify encoding: `read_csv(file, encoding='utf-8')`.

### Pattern 2 — "T?i?ng Vi?t" (replacement chars)

**Cause:** Bytes can't be decoded → replacement `?` or `�` (U+FFFD).
**Fix:** Try different encoding; check raw bytes with `hexdump`.

### Pattern 3 — "T  i  ế  n  g" extra space between

**Cause:** UTF-16 (2 bytes/char) read as UTF-8 (1 byte). High byte is 0 → displayed as null.
**Fix:** Specify `encoding='utf-16'`.

### Pattern 4 — "ï»¿Tiếng" (extra chars at start)

**Cause:** BOM (Byte Order Mark) `EF BB BF` not consumed by parser.
**Fix:** Use `utf-8-sig` to strip BOM.

### Pattern 5 — Length mismatch

```python
s = "Tiếng Việt"
len(s)          # 10 (Python 3: code points)
len(s.encode('utf-8'))  # 14 bytes
```

**Bug:** Database VARCHAR(10) accepts 'Tiếng Việt' string len 10, but bytes 14 → truncated.
**Fix:** Use TEXT or larger VARCHAR, or specify in chars not bytes.

---

## 💡 Debug workflow

### Step 1 — Hexdump raw bytes

```bash
hexdump -C file.csv | head -3
```

### Step 2 — Detect encoding

```python
import chardet
with open('file.csv', 'rb') as f:
    raw = f.read(10000)
    result = chardet.detect(raw)
    print(result)   # {'encoding': 'utf-8', 'confidence': 0.99}
```

### Step 3 — Read with correct encoding

```python
df = pd.read_csv('file.csv', encoding=result['encoding'])
```

### Step 4 — Re-export as UTF-8

```python
df.to_csv('cleaned.csv', encoding='utf-8-sig', index=False)
```

---

## 🚀 Real-world checks

### Check 1 — Database client encoding

```sql
SHOW client_encoding;            -- Postgres
SET client_encoding = 'UTF8';
```

```sql
SHOW VARIABLES LIKE 'character_set%';  -- MySQL
```

### Check 2 — HTTP API charset

```http
Content-Type: application/json; charset=utf-8
```

→ Without `charset`, browsers may default to Latin-1 or local encoding.

### Check 3 — File BOM

```
EF BB BF       → UTF-8 BOM
FF FE          → UTF-16 LE BOM
FE FF          → UTF-16 BE BOM
00 00 FE FF    → UTF-32 BE
FF FE 00 00    → UTF-32 LE
```

`hexdump -C file | head -1` shows first bytes.

### Trong project DSX Air

| Source | Encoding standard |
|---|---|
| Producer events | UTF-8 JSON |
| Schema Registry | UTF-8 JSON Schema |
| Kafka message keys | UTF-8 (Avro/JSON) |
| Postgres OLTP | UTF-8 (`client_encoding=UTF8`) |
| Parquet column strings | UTF-8 |
| Logs / Loki | UTF-8 |
| HTTP API responses | UTF-8 with explicit charset header |

→ Standard everywhere → no Mojibake.

---

## ⚠️ Common pitfalls

### Pitfall 1 — Assume UTF-8 default

❌ Different platforms default differently. Windows often Latin-1 / cp1252.
✅ Always specify encoding explicitly.

### Pitfall 2 — Excel + UTF-8

❌ Excel opens UTF-8 file (no BOM) as Latin-1 → Mojibake.
✅ Save with `utf-8-sig` (with BOM) for Excel.

### Pitfall 3 — Database VARCHAR truncation

❌ VARCHAR(10) truncates 'Tiếng Việt' if column counted in bytes.
✅ Use TEXT or check column definition.

### Pitfall 4 — Mixed encoding in 1 file

❌ Some rows UTF-8, some Latin-1 → unable to read entire file uniformly.
✅ Reject + clean upstream.

### Pitfall 5 — Compare strings normalized differently

❌ 'ế' (NFC, 1 code point) != 'ế' (NFD, 3 code points) visually same.
✅ `unicodedata.normalize('NFC', s)` before compare.

---

## 🧠 Self-test

1. Mojibake "Tiá»…ng Viá»‡t" — root cause? Fix?
2. UTF-8 vs Latin-1: when same? When different?
3. BOM `EF BB BF`: what + why useful?
4. NFC vs NFD: difference for 'ế'?
5. Excel open UTF-8: best practice?

---

## 🔗 Liên kết

- **[F01/01 Bits, bytes](./01-bits-bytes-encoding.md)** — encoding fundamentals
- **[F01/16 Endianness](./16-endianness.md)** — UTF-16 endianness
- **[F09 Databases I](../../semester-2-systems-theory/F09-databases-relational/)** — client_encoding

---

**Đã đọc xong?**
✅ Tick → [F01/16 Endianness](./16-endianness.md).
