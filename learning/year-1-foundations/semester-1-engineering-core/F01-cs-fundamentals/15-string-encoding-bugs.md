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

## 🧩 The Crux of the Problem  *(v3 — OSTEP-style framing)*

> **Core question:** Cho dữ liệu text gửi qua N hệ thống khác nhau (database, file system, API, browser), làm sao **đảm bảo encoding bảo toàn** end-to-end + detect khi nào bị broken?
>
> **Why hard:** Mỗi system có default encoding khác. Database charset, file system encoding, browser interpretation, JSON spec, CSV implementation, BOM presence. Mỗi điểm = potential corruption.
>
> **What we need:** **UTF-8 everywhere policy** + explicit encoding declaration ở mọi boundary (HTTP header `charset=utf-8`, DB `utf8mb4`, file `# -*- coding: utf-8 -*-` Python 2 era, BOM consideration). Plus debugging skill cho khi Mojibake xảy ra.

→ KU 01 dạy "encoding là gì". KU này dạy "khi nó vỡ thì làm sao". Bài học từ trận chiến thật.

---

## 📜 Lịch sử ngắn  *(v3 — etymology + invention)*

- **Mojibake (文字化け)** — Japanese term, từ "mojibe" (character) + "bake" (transform, corrupt). Era 1990s khi Japan dùng Shift-JIS, EUC-JP, ISO-2022-JP concurrent → swap encoding = unreadable. Nay là universal term.
- **"Tofu" (□)** — Visual term cho ký tự không render được. Microsoft Noto font phổ biến nhờ "**N**o-more-**oto**fu" goal (Noto).
- **Charset wars 1990s** — Latin-1 (Western Europe) vs Windows-1252 (Microsoft extend) vs ISO-8859-1 vs ISO-8859-15 (€ symbol added). Excel/Outlook default Windows-1252, web standardize ISO-8859-1, → Mojibake epidemic.
- **UTF-8 adoption (2000s-2010s)** — Web slowly migrate. 2008: UTF-8 vượt qua ISO-8859-1 trên web. 2010: vượt qua ASCII. 2025: ~98% web pages UTF-8.
- **CSV problem** — RFC 4180 không specify encoding. Mỗi tool decide khác nhau. Excel mặc định Windows-1252 hoặc system default → user gửi CSV cross-platform = Mojibake.
- **Today (2026):** Vẫn còn legacy systems Latin-1 / Windows-1252. Vietnamese tăng dùng UTF-8 từ thập kỷ 2000, nhưng government legacy còn TCVN3 / VNI / VPS.

---

## ❌ Bad example / anti-pattern  *(v3 — "Martin's algorithm" style)*

### Anti-pattern 1 — Excel CSV "UTF-8"

```
User: "Save as CSV (UTF-8)" trong Excel
→ Excel save BOM (0xEF 0xBB 0xBF) ở đầu file
→ Some downstream tools (older pandas, sqlite import) treat BOM as data
→ First column header trở thành "﻿customer_id" thay vì "customer_id"
```

**Tại sao bad:** Excel BOM behavior inconsistent across versions. Pick:
- Khi WRITE CSV: skip BOM, explicit `encoding='utf-8'`
- Khi READ: `encoding='utf-8-sig'` để skip BOM if present

### Anti-pattern 2 — MySQL `utf8` charset

```sql
-- ❌ Use "utf8" charset trong MySQL
CREATE TABLE users (
  name VARCHAR(100) CHARACTER SET utf8
);
-- "utf8" trong MySQL CHỈ support 3-byte UTF-8 → mất emoji (4-byte) + 1 số chữ Hán hiếm
-- Bug: insert "😀" → error 1366 hoặc silent truncate
```

**Tại sao bad:** MySQL "utf8" = "utf8mb3" (legacy). Real UTF-8 = "utf8mb4". Always use `utf8mb4` cho MySQL.

### Anti-pattern 3 — Auto-detect encoding

```python
# ❌ "Just guess encoding"
import chardet
with open('mystery.csv', 'rb') as f:
    raw = f.read()
encoding = chardet.detect(raw)['encoding']
# chardet đôi khi miss → Latin-1 vs Windows-1252 detect wrong
# Vietnamese files thường mis-detect as Latin-2 hoặc Greek
```

**Tại sao bad:** Auto-detect unreliable cho short text or ambiguous encoding. Pick **explicit encoding** từ metadata (HTTP header, DB charset, file convention). Detect = last resort.

### Anti-pattern 4 — Print Unicode trong terminal Windows

```python
# ❌ Windows cmd.exe default cp1252 hoặc cp936
print("Tiếng Việt")
# Windows: UnicodeEncodeError: 'charmap' codec can't encode character 'ế'
```

**Tại sao bad:** Windows console legacy encoding. Pick:
- `chcp 65001` (UTF-8) trong cmd
- PowerShell 7+ default UTF-8
- Python: `sys.stdout.reconfigure(encoding='utf-8')` (3.7+)

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

## 🌐 Đọc thêm — refs cụ thể vào library  *(v3 — pointers chính xác)*

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **Downey ThinkPython2** → `Downey_ThinkPython2.pdf` — Python 3 string handling chapter.

📄 **Reference + spec:**
- **Joel Spolsky (2003)**, *"The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets"* — [joelonsoftware.com](https://www.joelonsoftware.com/2003/10/08/the-absolute-minimum-every-software-developer-absolutely-positively-must-know-about-unicode-and-character-sets-no-excuses/).
- **Unicode Standard (latest)** — [unicode.org/versions](https://www.unicode.org/versions/latest/).
- **RFC 4180** — Common Format and MIME Type for CSV Files.
- **W3C Internationalization** — [w3.org/International/](https://www.w3.org/International/).
- **MySQL UTF-8 documentation** — utf8mb3 vs utf8mb4 history.
- **PEP 3120** — Python 3 default UTF-8 source.

---

**Đã đọc xong?**
✅ Tick → [F01/16 Endianness](./16-endianness.md).
