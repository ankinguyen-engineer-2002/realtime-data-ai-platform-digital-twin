# KU F01 / 14 — Floating point: bẫy precision

> `0.1 + 0.2 = 0.30000000000000004` trong float. Đây không phải bug Python — đây là **IEEE 754** standard cho mọi computer trên đời. Hiểu floating point = tránh bug nghiêm trọng trong tính tiền, đo lường, ML.

**Module:** [F01 — CS Fundamentals](./README.md)
**Prereqs:** [F01/01 Bits, bytes](./01-bits-bytes-encoding.md)
**Related KUs:** [F14 Math for AI](../../semester-2-systems-theory/F14-math-for-data-ai/)
**Đọc trong:** ~12 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn dùng **máy tính cầm tay 8 chữ số** đo bột mì:

- Cần đo 1/3 kg → máy hiển thị `0.33333333` (8 chữ số) — KHÔNG phải chính xác 1/3.
- Cộng 3 lần: `0.33333333 + 0.33333333 + 0.33333333 = 0.99999999` (gần nhưng KHÔNG bằng 1).

Máy tính cầm tay = **limited precision**. Mỗi phép tính làm tròn → tích luỹ sai số.

Floating point trong máy tính = y vậy nhưng tệ hơn: **lưu binary, không phải decimal**.

`0.1` (decimal) trong binary = `0.0001100110011001100...` (infinite repeating).
Float chỉ lưu 23 bits (single) hoặc 52 bits (double) mantissa → cut off → **không exact**.

```python
>>> 0.1 + 0.2
0.30000000000000004
```

→ Không phải bug, đây là **IEEE 754 reality**. Mọi programmer phải hiểu.

---

## 📖 Định nghĩa chính thức

**IEEE 754** = standard cho floating point (1985, updated 2008/2019).

Format float32 (single):
```
sign (1 bit) | exponent (8 bits) | mantissa (23 bits) = 32 bits total
```

Value = `(-1)^sign × 2^(exponent-127) × 1.mantissa`

Format float64 (double):
```
sign (1) | exponent (11) | mantissa (52) = 64 bits
```

**Special values:**
- `+Inf`, `-Inf` (divide by zero)
- `NaN` (Not-a-Number, 0/0)
- `+0`, `-0` (signed zero)
- Denormals (very small numbers)

**Precision:**
- float32: ~7 decimal digits
- float64: ~15-17 decimal digits
- float128 (rare): ~33 digits

**Nguồn:**
- IEEE 754-2008 standard.
- "What Every Computer Scientist Should Know About Floating-Point Arithmetic" (Goldberg 1991).

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Số phẩy động | Floating point | Number with mantissa + exponent |
| Single precision | Single precision (float32) | 32-bit IEEE 754 |
| Double precision | Double precision (float64) | 64-bit IEEE 754 |
| Mantissa / Significand | Mantissa | Fractional part bits |
| Exponent | Exponent | Power of 2 |
| Sign bit | Sign bit | + or - |
| Subnormal / Denormal | Denormal | Very small numbers below normal range |
| NaN | Not-a-Number | Invalid result (0/0, sqrt(-1)) |
| Infinity | Infinity | Overflow result |
| Underflow | Underflow | Too small, becomes 0 or denormal |
| Overflow | Overflow | Too big, becomes Inf |
| Rounding | Rounding | Convert exact to representable |
| Machine epsilon | Machine epsilon | Smallest x: 1+x ≠ 1 |
| ULP | Unit in Last Place | Distance between adjacent floats |
| Catastrophic cancellation | Catastrophic cancellation | Subtract nearly equal → lose precision |
| Kahan summation | Kahan summation | Algorithm reducing summation error |
| Decimal type | Decimal | Exact decimal arithmetic (slower) |
| Fixed-point | Fixed-point | Integer with implicit decimal position |

---

## 💡 Real-world bugs from floating point

### Bug 1 — Money in float

```python
total = 0.1 + 0.2  # 0.30000000000000004
amount_paid = 0.30
if total == amount_paid:    # False!
    print("Paid in full")
```

→ Customer pays $0.30, system says "still owes $0.0000000000000004", complaint.

**Fix:** use `Decimal` for money.

```python
from decimal import Decimal
total = Decimal('0.1') + Decimal('0.2')  # Decimal('0.3') exact
```

### Bug 2 — Accumulation drift

```python
total = 0.0
for _ in range(1_000_000):
    total += 0.1
print(total)  # 99999.9999998... not 100000
```

→ 1M errors accumulate. Use Kahan summation or Decimal.

### Bug 3 — Float comparison

```python
if (a / b) * b == a:  # often False
    ...
```

✅ Use `abs(a - b) < epsilon` for comparison.

### Bug 4 — Loss in subtraction (catastrophic cancellation)

```python
a = 1.0000001
b = 1.0
diff = a - b  # 1.000000082740371e-07 (~10% relative error)
```

→ Subtraction of similar magnitudes loses precision. Reformulate algorithms.

### Bug 5 — int → float64 → int loss

```python
n = 10**20
f = float(n)        # 1e+20
back = int(f)
print(back == n)    # False, lost precision
```

→ int64 has 64-bit precision, float64 has 53-bit mantissa.

---

## 🚀 Where it matters in DE

### Postgres NUMERIC vs DOUBLE PRECISION

```sql
-- ❌ Money in DOUBLE PRECISION
CREATE TABLE orders (amount DOUBLE PRECISION);
-- $0.1 + $0.2 might not equal $0.3

-- ✅ Money in NUMERIC (Decimal)
CREATE TABLE orders (amount NUMERIC(10, 2));
-- Exact decimal arithmetic
```

→ Postgres NUMERIC = arbitrary precision decimal. Use for money.

### Spark / Iceberg DecimalType

```python
from pyspark.sql.types import DecimalType
schema = StructType([
    StructField("amount", DecimalType(10, 2), True)
])
```

→ Same — `Decimal(10, 2)` cho money. Float for measurements OK.

### ML — usually float32 (or even float16, bfloat16)

```python
# ML training
weights = torch.zeros(1000, 1000, dtype=torch.float32)

# Inference
weights = weights.half()  # float16 for speed/memory
```

→ ML accepts precision loss for speed. Modern: bfloat16 (16-bit with float32 range).

### Trong project DSX Air

| Use case | Type |
|---|---|
| `amount` in payment | `NUMERIC(12, 2)` Postgres, `Decimal(12,2)` Parquet |
| `risk_score` (0-1) | `DOUBLE PRECISION` OK |
| `event_time` | `TIMESTAMP` (not float!) |
| `latency_ms` | `DOUBLE PRECISION` OK |
| ML model weights | `float32` or `bfloat16` |

---

## 🔧 Float representation deep

### float32 example: 0.1

```
0.1 decimal = 0.0001100110011001100110011... binary (repeating)

float32 rounds to 23 mantissa bits:
  sign=0, exponent=01111011 (= -4 after bias), mantissa=10011001100110011001101
  
Decoded back: 0.10000000149011612...
```

→ **0.1 không exact biểu diễn float32**. float64 mantissa 52 bits gần hơn nhưng vẫn không exact.

### Machine epsilon

`float64 epsilon ≈ 2.22e-16`

Means: `1.0 + 1e-16 == 1.0` (smaller can't be added).

→ When testing equality, threshold should be `~1e-10` for float64, `~1e-6` for float32.

### Denormals (subnormals)

Very small numbers below `2^-126` (float32) — represented with leading zeros in mantissa, lower precision.

→ Modern CPU 100x slower on denormals. Audio code often disables them.

---

## ⏰ When to use what

| Use case | Type |
|---|---|
| Money / Finance | `Decimal` (Python), `NUMERIC` (Postgres), `BigDecimal` (Java) |
| Scientific measurement | `float64` (`double`) |
| ML weights | `float32` default, `float16/bfloat16` for speed |
| Counters | Integer (int64) |
| Timestamps | Dedicated time type (not float seconds) |
| Geographic coordinates | `float64` (precision matters for global scale) |
| Game physics | `float32` (speed > precision) |

---

## ⚠️ Common pitfalls

### Pitfall 1 — Float for money

❌ Always. Use Decimal.

### Pitfall 2 — `==` comparison

❌ `if x == 0.1:`. Use `abs(x - 0.1) < epsilon`.

### Pitfall 3 — Accumulate small numbers

❌ Sum 1M small floats naively. Use `math.fsum()` or Kahan.

### Pitfall 4 — NaN propagation

NaN compares != to everything including itself.
```python
NaN == NaN   # False!
math.isnan(x)  # use this
```

→ Filter NaN from arrays explicitly.

### Pitfall 5 — Convert int → float → int

Large ints (> 2^53) lose precision in float64.

---

## 🌱 Advanced topics

### A1. bfloat16 (Brain Float)

Google Brain (2018): 16-bit with float32-range exponent (8 bits) + 7 mantissa bits.

→ ML-friendly: same range as float32, less precision OK for gradient. Used by TPUs, modern GPUs.

### A2. FP8 (NVIDIA H100+, 2022)

8-bit floats with 2 variants (E4M3, E5M2). Used for LLM inference.

→ 4x throughput vs float32. Quantization-aware training preserves accuracy.

### A3. Posit numbers (alternative to IEEE 754)

Newer format with better precision near 1.0, graceful overflow.

→ Research; not yet mainstream.

### A4. Kahan summation algorithm

```python
def kahan_sum(arr):
    s = 0.0
    c = 0.0  # compensation
    for x in arr:
        y = x - c
        t = s + y
        c = (t - s) - y
        s = t
    return s
```

→ Reduces error from O(n × epsilon) to O(epsilon).

### A5. Apply cho LLM 2026

- **Training**: bfloat16 mostly, float32 for accumulators
- **Inference**: INT8/FP8 quantization
- **Loss scaling**: prevent gradient underflow in float16

---

## 🧠 Self-test

1. Why `0.1 + 0.2 != 0.3`?
2. float32 vs float64 mantissa bits + decimal digits precision?
3. NaN != NaN. How to check?
4. Money: Decimal vs float?
5. bfloat16: when use vs float16?
6. Catastrophic cancellation: example + mitigation?

---

## 🔗 Liên kết

- **[F01/01 Bits, bytes](./01-bits-bytes-encoding.md)** — IEEE 754 = byte layout
- **[F14 Math for AI](../../semester-2-systems-theory/F14-math-for-data-ai/)** — numerical stability
- **[D29 Deep Learning](../../../year-2-specialization/semester-4-ai-ops-architecture/D29-deep-learning-basics/)** — bfloat16 training
- **[D30 LLM Engineering](../../../year-2-specialization/semester-4-ai-ops-architecture/D30-llm-engineering/)** — FP8 quantization

---

**Đã đọc xong?**
✅ Tick → [F01/15 String encoding bugs](./15-string-encoding-bugs.md).
