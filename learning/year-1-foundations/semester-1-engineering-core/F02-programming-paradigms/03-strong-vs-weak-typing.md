# KU F02 / 03 — Strong vs Weak typing

> Ngôn ngữ có **silent type coercion** (`"5" + 3 = "53"` JS) hay **strict refuse** (`TypeError` Python)? **Strong typing** = không tự convert, error khi mismatch. **Weak typing** = silent convert, có thể bug ẩn. Axis này **orthogonal** với static/dynamic.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/02 Static vs Dynamic typing](./02-static-vs-dynamic-typing.md)
**Related KUs:** [F02/12 Error handling](./12-error-handling.md) · [F04 Type Systems](../F04-type-systems-validation/)
**Đọc trong:** ~12 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn đưa **đồng 50,000 VND** cho 2 quán khác nhau mua bún 30,000 VND:

### Quán 1 — Strong typing
- Cô bán hàng: "Anh ơi tiền Việt thật chứ ko phải đôla?"
- Bạn: "VND chứ"
- Cô: "OK 30k bún + 20k thối lại."
- → **Strict type check.** Tiền phải đúng kiểu.

### Quán 2 — Weak typing (JavaScript-style)
- Bạn đưa 50 đôla Mỹ nhầm.
- Cô **tự convert silently**: "50 đôla = 50 nghìn VND" (sai vì tỷ giá thật ~25K).
- Cô đưa bún + thối 20k.
- → Bạn mất 5× tiền vì silent coercion sai!

Trong code:

```javascript
// JavaScript weak typing
"5" + 3    // "53"   (string concat — coerce number → string)
"5" - 3    // 2      (numeric — coerce string → number)
"5" * "3"  // 15     (numeric — both coerced)
[] + []    // ""     (empty string)
[] + {}    // "[object Object]"
true + 1   // 2      (true → 1)
```

```python
# Python strong typing
"5" + 3        # TypeError: can only concatenate str (not "int") to str
"5" - 3        # TypeError
True + 1       # 2 (True is int — historical accident, but consistent)
```

→ **Strong = strict, fail loud. Weak = silent convert, fail late (or never... wrong result).**

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Core question:** Khi 2 type khác nhau gặp nhau (`int + string`, `null + 5`), ngôn ngữ nên (a) **reject** rõ ràng (strong) hay (b) **silently convert** theo coercion rule (weak)?
>
> **Why hard:** Weak typing convenient cho quick scripting (PHP, JS, Bash) nhưng tạo bug ẩn — code "chạy" nhưng output sai. Strong typing reject ngay nhưng buộc developer viết explicit conversion (`str(5)`, `int(s)`) — nhiều typing.
>
> **What we need:** Hiểu **coercion rules** ngôn ngữ đang dùng + biết khi nào weak typing causes silent bug (financial calculations, schema validation). Pick ngôn ngữ strong cho production data pipelines.

→ JS WTFJS memes = consequence của weak typing. PHP 5 `==` vs `===` = workaround historical mistakes.

---

## 📖 Định nghĩa chính thức

**Strong typing** = type system **không tự động coerce** giữa unrelated types. Operations on mismatched types raise error.

**Weak typing** = type system **tự động coerce** types qua implicit rules (e.g., `int → float`, `int → string` for concat).

**Important:** Strong/Weak axis **orthogonal** với Static/Dynamic:

| | Static | Dynamic |
|---|---|---|
| **Strong** | Haskell, Rust, OCaml, Java | Python, Ruby |
| **Weak** | C, C++ (implicit casts) | JavaScript, PHP, Bash, Perl |

C là **static + weak**: `int x = 5; float f = x;` silent convert. `void*` cast bypass type.
Python là **dynamic + strong**: `"5" + 3` lỗi nhưng `5 + 3.0 = 8.0` (OK vì numeric tower).
JavaScript là **dynamic + weak**: silent convert toàn bộ.

**Levels of strength:**

| Level | Behavior | Examples |
|---|---|---|
| **Strongest** | No implicit conversion at all | Haskell (`1 + 2.0` ERROR — need `fromIntegral`) |
| **Strong** | Numeric tower OK, no cross-category | Python, Ruby |
| **Medium** | Some implicit (int↔float, primitives) | Java, C# |
| **Weak** | Many implicit conversions | C, C++, JavaScript |
| **Weakest** | Everything coerces | PHP 5, Perl, Bash |

**Nguồn:** Pierce *TAPL*, Cardelli "Type Systems" Handbook.

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **"Strong" vs "weak" typing** terms ra đời 1960s-1970s, **không có định nghĩa formal universal**. Vẫn argue trong CS community.
- **Algol 60 (1960)** — first language với explicit type discipline. Algol 68 stronger.
- **C (1972, Dennis Ritchie)** — weak typing với silent casts (legacy of B/BCPL). `(int)pointer` cho phép mọi cast.
- **Pascal (1970, Wirth)** — stronger than C. No implicit type conversion. Created backlash → Pascal viewed "too restrictive".
- **JavaScript (1995, 10 ngày Brendan Eich)** — copy Java syntax + Self prototype + Scheme functional + **lax coercion** vì designed cho HTML embed (cần resilient). Today: WTFJS memes, `==` vs `===` saga.
- **PHP (1994, Rasmus Lerdorf)** — also weak. PHP 5 introduce `===` strict equality. PHP 7+ has type hints + strict mode.
- **TypeScript (2012)** + **PHP 7 strict types** + **Python type hints** = trend "**strengthen** weak/dynamic languages".
- **Today (2026):** Mọi ngôn ngữ mới (Rust, Go, Zig, Swift, Kotlin) **strong typing default**. "Weak typing" gần như extinct trong new langs.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Type coercion | Type coercion | Implicit type conversion |
| Type cast | Type cast | Explicit conversion |
| Numeric tower | Numeric tower | Int ⊂ Rational ⊂ Real ⊂ Complex |
| Truthiness | Truthiness | Non-bool values as bool (`""`, `0`, `null` = false) |
| Loose equality | Loose equality | `==` with coercion |
| Strict equality | Strict equality | `===` no coercion |
| Implicit conversion | Implicit conversion | Auto cast |
| Explicit conversion | Explicit conversion | Must call `int()`, `str()`, etc. |
| Type safety | Type safety | No undefined behavior from type misuse |
| Memory safety | Memory safety | No out-of-bounds, use-after-free |
| Type soundness | Type soundness | Well-typed programs don't crash |

---

## 💡 Real-world examples

### JavaScript coercion hell

```javascript
// Famous WTFJS
0 == ""          // true   (both → 0)
0 == "0"         // true   (both → 0)
"" == "0"        // false  (string comparison, no coercion)
null == undefined // true
null == 0        // false  (special rule)
[] == false      // true   (both → 0)
[] == ![]        // true   (both → 0!)
NaN == NaN       // false  (NaN never equal)

// Mitigation: use ===
0 === ""         // false
null === undefined // false
```

→ Modern JS: **always use `===`**. ESLint rule `eqeqeq` enforce.

### Financial calculation bug — weak typing

```python
# ❌ PHP-style weak typing (hypothetical)
$total = "100";   # from form input as string
$discount = 10;
$final = $total - $discount;   # PHP: 90 (silent convert)
# Bug: nếu user nhập "100abc"? → PHP: $total = 100 silent
# → bug ẩn lâu mới phát hiện
```

```python
# ✅ Python strong typing
total = "100"   # from form input
discount = 10
final = total - discount   # TypeError ngay
# Fix: explicit Decimal(total) — caller phải nghĩ về parsing
```

→ Financial code = **never** weak typing. Bug = real money lost.

### C silent integer overflow

```c
// ❌ C weak + silent overflow
int x = 2147483647;   // INT_MAX
int y = x + 1;         // -2147483648 (silent overflow)
// Behavior undefined in C standard but most compilers wrap
```

```rust
// ✅ Rust strong + checked
let x: i32 = i32::MAX;
let y = x + 1;          // PANIC in debug, wraps in release
let y = x.checked_add(1);  // Returns Option<i32>
let y = x.wrapping_add(1); // Explicit wrap
let y = x.saturating_add(1); // Saturate at MAX
```

→ Rust forces developer to **choose explicitly** what to do on overflow.

### Production DE example

| Language | `int(user_input)` behavior khi `user_input = "abc"` |
|---|---|
| Python | `ValueError: invalid literal for int()` — fail fast |
| JavaScript | `parseInt("abc") = NaN` — silent NaN, propagates |
| PHP < 7 | `(int)"abc" = 0` — silent zero! Bug |
| PHP 7+ strict | `TypeError` |
| Rust | `"abc".parse::<i32>()` returns `Result<i32, ParseIntError>` — force handle |

→ Pick language reject silent error cho data ingestion. Trino, ClickHouse có strict mode cho CAST.

---

## 🧮 Pseudocode — explicit conversion patterns  *(Erickson UIUC style)*

### Pattern A — strong: explicit conversion required

```
PARSE_USER_INPUT_STRONG(raw_string):
    《Strong typing: must explicitly convert》
    if raw_string is not numeric then
        return ERROR("invalid input")
    return PARSE_INT(raw_string)
```

### Pattern B — weak: silent coercion (dangerous)

```
PARSE_USER_INPUT_WEAK(raw_string):
    《Weak typing: silent coerce》
    return raw_string + 0   《"abc" + 0 = 0 in PHP / NaN in JS》
    《Caller has no way to detect failure!》
```

### Pattern C — defensive parsing (recommended)

```
PARSE_DEFENSIVE(raw_string):
    try:
        value ← PARSE_INT_STRICT(raw_string)
        return SUCCESS(value)
    catch ParseError as e:
        return FAILURE(e.message)
```

→ Rust `Result<T, E>`, Haskell `Either`, Go `(value, error)` — make failure explicit.

---

## 📊 Cost annotation table — strong vs weak picking  *(Sedgewick Princeton style)*

| Use case | Strong typing | Weak typing |
|---|---|---|
| Quick shell script | ❌ verbose | ✅ Bash, Perl natural |
| Web form parsing | ✅ catch malformed | ❌ silent NaN/0 |
| Financial calculation | ✅ MUST | ❌ DANGER |
| Production data pipeline | ✅ MUST | ❌ DANGER |
| Browser console quick math | OK | ✅ convenient |
| Embedded systems | ✅ predictable | ❌ undefined behavior |
| Game scripting | ✅ Lua mixed | ✅ JavaScript flex |

**Equality matrix:**

| Language | `5 == "5"` | `5 === "5"` (if strict exists) |
|---|---|---|
| Python | False | n/a |
| Java | compile ERROR | n/a |
| Rust | compile ERROR | n/a |
| Haskell | compile ERROR | n/a |
| JavaScript | true (coerce) | false (no coerce) |
| PHP 5 | true | false |
| PHP 7+ strict | depends | false |
| Ruby | false (no coerce) | n/a |

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Trust JavaScript `==`

```javascript
// ❌ Use loose equality
if (user.age == 18) { ... }
// "18" == 18 → true (coerce)
// 18.0 == 18 → true
// "  18  " == 18 → true (trim + coerce)
// "18abc" == 18 → false (NaN comparison) ← unexpected
```

**Tại sao bad:** Coercion rules non-obvious. Pick `===` always.

### Anti-pattern 2 — Implicit cast trong C cho size_t

```c
// ❌ Bug pattern
size_t n = list.size();   // unsigned
int i = -1;
if (i < n) { ... }         // BUG: i promoted to size_t → -1 → SIZE_MAX → always true!
```

**Tại sao bad:** Signed-to-unsigned silent cast. Pick `ssize_t` hoặc cast explicit.

### Anti-pattern 3 — Python `bool` is `int` historical accident

```python
# Weird Python behavior
True + True == 2          # True (bool ⊂ int)
sum([True, False, True]) == 2   # True
isinstance(True, int)     # True
# Type system "leaks" — bool is int subclass
```

**Tại sao bad:** Historic decision (Python 2.2). Today: prefer `int(bool_val)` explicit nếu muốn convert.

### Anti-pattern 4 — PHP truthiness traps

```php
// ❌ PHP truthiness
"0" == false      // true
"0.0" == false    // FALSE (only "0" coerces to 0!)
" " == false      // false (whitespace not zero-like)
"FALSE" == false  // false (non-empty string is truthy)
```

**Tại sao bad:** Inconsistent rules. Modern PHP: `===` + strict types.

---

## 🔧 Patterns — defensive practices

### Pattern 1: Strict equality everywhere
- JavaScript: `===` + ESLint `eqeqeq`
- PHP: `===` + `declare(strict_types=1);`
- Python: `is` for identity, `==` for equality (Python `==` strong)

### Pattern 2: Validation layer at boundaries

```python
# Pydantic — strict at API boundary
from pydantic import BaseModel, ValidationError

class OrderRequest(BaseModel):
    amount: int            # strict int
    currency: Literal["USD", "VND", "EUR"]

try:
    order = OrderRequest(amount="100", currency="USD")
    # By default Pydantic coerces "100" → 100 (allowed)
    # Set strict=True to reject
except ValidationError as e:
    print(e)
```

→ Validation libraries close gap between dynamic Python + strict DE need.

### Pattern 3: Result type — never throw on conversion

```python
from typing import Generic, TypeVar
T = TypeVar('T')

class Result(Generic[T]):
    @staticmethod
    def ok(value: T) -> 'Result[T]': ...

    @staticmethod
    def err(msg: str) -> 'Result[T]': ...

def parse_int(s: str) -> Result[int]:
    try: return Result.ok(int(s))
    except: return Result.err(f"can't parse {s}")
```

→ FP idiom. Force caller to handle failure explicit. KU 12 expand.

---

## 🌱 Advanced topics

### A1. Type-driven development
Haskell community: write types first, let them guide implementation. "If it compiles, it's correct" (paraphrase).

### A2. Refinement types
**Liquid Haskell**, **F\***: types with predicates. `Vec n` (length-indexed vector), `{x: Int | x > 0}` (positive int). Catch bugs at compile that simple types miss.

### A3. Effect systems
**Koka, Eff, Unison**: types describe side effects (IO, State, Exception). "Pure" function vs "IO" function vs "Network" function statically known.

### A4. Apply cho DE / LLM 2026
- **dbt** Yaml config + Jinja = weakly-typed historically; **dbt v2** add strict types
- **Spark** schema = strong typing for distributed compute
- **Iceberg** schema evolution rules = strong typing for storage layer
- **Pydantic** + **JSON Schema** = strong typing for LLM structured outputs
- **TypeScript** + **Zod** runtime validation = strong at API boundaries

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. Python `"5" + 3` ra gì? Tại sao?
2. JavaScript `[] + {}` ra gì? Vì sao?
3. Strong vs Weak typing — phân biệt 1 câu.

### 🟡 Medium
4. C: `size_t n; if (-1 < n) { ... }` true hay false? Vì sao?
5. PHP 7 `declare(strict_types=1);` thay đổi gì?
6. Pydantic default coerce `"100" → 100`. Bật `strict=True` thay đổi gì? Khi nào dùng strict?

### 🔴 Hard
7. JavaScript `==` so sánh phức tạp — viết complete coercion rules.
8. Rust `i32::MAX + 1` 3 mode: panic, wrap, saturate. Khi nào dùng cái nào?
9. Trong DSX Air, schema validation cho Kafka events: pick weak (default Avro) hay strong (Confluent Schema Registry strict)? Phân tích trade-off.

> **6+/9** = sẵn sàng KU 04. **4-5** = đọc Pierce TAPL Chapter 1. **<4** = code Python + Pydantic strict examples.

---

## 🔗 Liên kết

- **[F02/02 Static vs Dynamic typing](./02-static-vs-dynamic-typing.md)** — orthogonal axis
- **[F02/12 Error handling](./12-error-handling.md)** — Result/Either pattern
- **[F04 Type Systems & Validation](../F04-type-systems-validation/)** — Pydantic, JSON Schema applied
- **[F01/14 Floating point](../F01-cs-fundamentals/14-floating-point.md)** — numeric typing bugs

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **PLAI (Krishnamurthi)** → `Krishnamurthi_PLAI_Brown.pdf` — type chapters cover both static/dynamic + strong/weak.
- **Practical Haskell** → `Mena_Practical-Haskell-2ed.pdf` — strongest typing in mainstream lang.

📖 **Sách commercial:**
- Pierce, *Types and Programming Languages* — type theory bible.
- **Effective Java** (Bloch) — Item on Generics + Type Safety.
- **JavaScript: The Good Parts** (Crockford) — chương về coercion to avoid.

📄 **Paper + reference:**
- Cardelli (1996), *"Type Systems"*, Handbook of Computer Science — strong/weak/static/dynamic classification.
- TC39 ECMAScript spec — equality operators detail.
- Brendan Eich blog — JavaScript history.
- PHP RFC: strict types — [wiki.php.net/rfc/scalar_type_hints](https://wiki.php.net/rfc/scalar_type_hints_v5).

---

**Đã đọc xong?**
✅ Tick → [F02/04 OOP fundamentals](./04-oop-fundamentals.md).
