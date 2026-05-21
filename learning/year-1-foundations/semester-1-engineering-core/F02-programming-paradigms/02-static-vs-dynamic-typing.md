# KU F02 / 02 — Static vs Dynamic typing

> Compiler check kiểu **trước khi chạy** (static) hay **lúc chạy** (dynamic)? Python = dynamic. Java/Rust/Go = static. TypeScript = static layer trên dynamic JS. Pick đúng = balance giữa **safety + tốc độ dev**. Wrong pick = bug ở prod hoặc team năng suất thấp.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/01 Imperative vs Declarative](./01-imperative-vs-declarative.md)
**Related KUs:** [F02/03 Strong vs Weak typing](./03-strong-vs-weak-typing.md) · [F04 Type Systems](../F04-type-systems-validation/)
**Đọc trong:** ~14 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn mua **vé tàu lửa Hà Nội-Sài Gòn**. 2 cách check vé:

### Cách 1 — Static check (trước khi lên tàu)
- Nhân viên check vé ở **cổng ga** trước khi vào toa.
- Vé sai/giả → bị chặn ngay, **không lên tàu**.
- An toàn cao nhưng tốn thời gian xếp hàng + check.

### Cách 2 — Dynamic check (sau khi tàu chạy)
- Bạn lên tàu thoải mái không check.
- Nhân viên đi qua từng toa khi tàu chạy → check vé.
- Vé sai → bị mời xuống ở ga kế tiếp (tàu đã chạy được vài giờ).
- Nhanh ban đầu nhưng có thể bị "đuổi" giữa đường.

**Programming tương tự:**
- **Static typing** = compiler check kiểu **trước run** (compile time). Sai → reject ngay.
- **Dynamic typing** = runtime check **khi gặp** (execution time). Sai → exception ở line đó.

Ví dụ Python (dynamic):
```python
def add(a, b):
    return a + b

add(1, 2)     # 3 — OK
add("hi", 5)  # TypeError ở line này — runtime crash!
```

Ví dụ Rust (static):
```rust
fn add(a: i32, b: i32) -> i32 { a + b }

add(1, 2);       // compile OK
add("hi", 5);    // compile ERROR — không bao giờ chạy
```

→ **Static = an toàn nhưng chậm dev cycle. Dynamic = nhanh dev nhưng bug runtime.**

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Core question:** Cho team build production system, làm sao **catch bug type ASAP** (sớm = rẻ fix) + **không làm chậm tốc độ feature**?
>
> **Why hard:** Static catches bug trước run (Σ tốt) nhưng (a) ép lập trình viên viết type annotation, (b) compile slow team workflow. Dynamic nhanh viết nhưng bug type chỉ lộ ra **khi chạy đến code path đó** → có thể bug tồn tại trong code 6 tháng mới phát hiện ở prod.
>
> **What we need:** Hiểu **gradient** static→dynamic + tools middle ground (TypeScript, Python `mypy`, Ruby `sorbet`, PHP `Psalm`) + biết khi nào upgrade từ dynamic → typed.

→ **Modern (2026):** Mọi codebase Python production > 10K LOC đều có `mypy` hoặc `pyright`. "Pure dynamic" thua dần.

---

## 📖 Định nghĩa chính thức

**Static typing** = type checking xảy ra tại **compile time / type-check time**, trước khi chạy code.

- **Compile-time guarantees:** type errors caught before deployment
- **Cost:** annotations required (or inferred), compile step
- **Examples:** C, C++, Java, C#, Rust, Go, Haskell, OCaml, Scala, Kotlin, TypeScript

**Dynamic typing** = type checking xảy ra tại **runtime**, khi expression được evaluate.

- **Runtime checks:** type errors raise exceptions when hit
- **Cost:** errors discovered late, harder to refactor large codebases
- **Examples:** Python, JavaScript, Ruby, PHP, Lisp, Smalltalk, Erlang

**Gradient — modern reality:**

```
Pure Dynamic  ←──────────────────────────→  Pure Static
Lisp          Python+mypy   TypeScript    Java   Rust+ownership
JavaScript    Ruby+sorbet   Python+pyright C#    Haskell
              PHP+psalm     Dart           Go    OCaml
                            Scala          Kotlin
```

**Sub-categories:**
- **Type inference**: Compiler đoán type từ context (Hindley-Milner trong ML/Haskell, partial trong Rust/Go).
- **Gradual typing**: Mix static + dynamic (TypeScript `any`, Python `Any`).
- **Structural typing**: Type compatible nếu shape match (TypeScript, Go interfaces).
- **Nominal typing**: Type compatible nếu name match (Java, C#).
- **Duck typing**: "If it walks like a duck..." — dynamic structural (Python, Ruby).

**Nguồn:** Krishnamurthi *PLAI* Chapter on Types · Pierce *Types and Programming Languages* (commercial bible).

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **Static typing** ra đời cùng compiler đầu tiên — **FORTRAN (1957)** explicit declare `INTEGER X, REAL Y`.
- **Type inference (Hindley-Milner, 1969-1978)** — **Roger Hindley** (1969) + **Robin Milner** (1978) độc lập phát minh. Algorithm W: compiler đoán toàn bộ types không cần annotation. Foundation cho ML (1973), Haskell (1990), Rust (2010), Scala (2004).
- **Dynamic typing** ra đời cùng **LISP (McCarthy, 1958)** — symbolic AI cần flexibility. Smalltalk (1972) đẩy thêm với OOP message-passing.
- **JavaScript (1995, Brendan Eich, 10 ngày)** — dynamic typing + weak typing + prototype OOP. Today: 13M+ developers, biggest dev community.
- **Python (1991, Guido van Rossum)** — dynamic + duck typing. PEP 484 (2014) introduce type hints (optional), thay đổi văn hoá.
- **TypeScript (2012, Anders Hejlsberg, Microsoft)** — gradual typing on JS. Today: 78% web devs use it (State of JS 2023).
- **Rust (2010, Graydon Hoare, Mozilla)** — static + ownership types. Eliminates entire class of bugs (use-after-free, data race).
- **Today (2026):** "Static + inference" thắng cuộc tranh. Major dynamic langs (Python, JS, Ruby, PHP) đều có optional static layer.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Static typing | Static typing | Type check compile time |
| Dynamic typing | Dynamic typing | Type check runtime |
| Type annotation | Type annotation | Explicit type khai báo |
| Type inference | Type inference | Compiler đoán type |
| Duck typing | Duck typing | "Walks like duck" structural dynamic |
| Gradual typing | Gradual typing | Mix static + dynamic |
| Structural typing | Structural typing | Shape match |
| Nominal typing | Nominal typing | Name match |
| Hindley-Milner | Hindley-Milner | Algorithm W type inference |
| Type erasure | Type erasure | Generic types removed at runtime (Java) |
| Reified types | Reified types | Generics preserved (C#) |
| Phantom types | Phantom types | Type param không xài trong representation |
| Dependent types | Dependent types | Type depends on value (Idris, Coq) |
| Linear types | Linear types | Value xài đúng 1 lần (Rust ownership) |

---

## 💡 Real-world examples

### Type bug trong production

**Case 1 — Python dynamic (real-world incident pattern):**
```python
# data_pipeline.py
def calculate_revenue(orders):
    return sum(order.amount for order in orders)

# 6 tháng later, someone passes dict instead of Order:
calculate_revenue([{"amount": 100}, {"amount": 200}])
# AttributeError: 'dict' object has no attribute 'amount'
# Bug ở Monday 3am production — page on-call
```

**Same bug với static typing:**
```python
# Same code + mypy
def calculate_revenue(orders: list[Order]) -> Decimal:
    return sum(order.amount for order in orders)
# mypy check before deploy → reject if caller pass dict
```

**Case 2 — JavaScript `null + undefined` bugs:**
```javascript
// Famous JS bugs
[] + []           // ""
[] + {}           // "[object Object]"
{} + []           // 0
{} + {}           // NaN
null + 1          // 1
undefined + 1     // NaN
```

→ Dynamic + weak typing → "WTFJS" memes. TypeScript `strict` mode reject all these.

### Static typing helps refactoring

**Scenario:** Rename `email` → `emailAddress` ở User class trong 100K LOC codebase.

| Language | Effort |
|---|---|
| **Java + IntelliJ** | Right-click → Refactor → Rename. Compiler verifies. ~10 seconds, zero runtime error |
| **TypeScript + VSCode** | F2 rename. Compiler verifies usages. ~30 seconds, zero runtime |
| **Python (no types)** | grep + replace. Pray. Run tests. Find missed usages in prod next month |
| **Python + mypy strict** | F2 rename + mypy check. ~1 minute |

→ Static typing = **refactoring safety net**. Crucial cho large team / long-lived code.

### Performance impact

Static typing thường = **faster runtime** vì:
1. Không cần dynamic dispatch cho method calls
2. Compiler có thể inline + optimize
3. Memory layout known → cache-friendly

| Workload (sum 1B integers) | Time |
|---|---|
| Python (dynamic) | ~50 sec |
| Python + Cython types | ~3 sec |
| Java (static, JIT) | ~1 sec |
| Rust (static, native) | ~0.5 sec |
| C (static, native) | ~0.4 sec |

→ Pure Python ~100× slower than C cho numeric. Dynamic dispatch overhead.

---

## 🧮 Pseudocode — type inference Hindley-Milner sketch  *(Erickson UIUC style)*

```
INFER(expression, environment):
    case expression of
        literal n:
            return type(n)                    《Int, String, Bool inferred》

        variable x:
            return environment[x]              《lookup》

        lambda x. body:
            α ← FRESH_TYPE_VAR()
            extended_env ← environment ∪ {x: α}
            body_type ← INFER(body, extended_env)
            return FunctionType(α, body_type)

        application f a:
            f_type ← INFER(f, environment)
            a_type ← INFER(a, environment)
            result_type ← FRESH_TYPE_VAR()
            UNIFY(f_type, FunctionType(a_type, result_type))
            return result_type

        let x = e1 in e2:
            e1_type ← INFER(e1, environment)
            generalized ← GENERALIZE(e1_type, environment)
            return INFER(e2, environment ∪ {x: generalized})

UNIFY(t1, t2):
    if t1 = t2 then return
    if t1 is type var then bind t1 ← t2
    if t2 is type var then bind t2 ← t1
    if t1 = F(a1) and t2 = F(a2) then UNIFY(a1, a2)
    else FAIL("type mismatch")
```

→ Algorithm W (Milner 1978): compiler infer toàn bộ types không cần annotation. Foundation cho ML/Haskell/OCaml.

---

## 📊 Cost annotation table — picking guide  *(Sedgewick Princeton style)*

| Aspect | Static wins ⚡ | Dynamic wins ⚡ |
|---|---|---|
| **Catch bugs early** | ✅ compile-time | ❌ runtime |
| **Refactoring large codebase** | ✅ IDE + compiler | ❌ grep + pray |
| **Runtime performance** | ✅ ~10-100x | ❌ slower |
| **Memory footprint** | ✅ compact | ❌ ~2-3x more |
| **Self-documenting code** | ✅ types are docs | ❌ docstrings needed |
| **Time to first prototype** | ❌ annotations | ✅ no overhead |
| **Notebook / REPL exploration** | ❌ awkward | ✅ natural |
| **Metaprogramming** | ❌ harder | ✅ easy (reflection) |
| **Duck typing flexibility** | ❌ rigid | ✅ flexible |
| **Generic programming** | ✅ type-safe generics | ❌ runtime checks |
| **Team onboarding** | ❌ syntax barrier | ✅ easier read |
| **Cross-team contract** | ✅ types as API | ❌ doc/test |
| **Compile time** | ❌ slow (Rust ~minutes) | ✅ instant |

**Real-world picking matrix:**

| Project type | Recommended typing | Reason |
|---|---|---|
| Quick prototype, MVP | Dynamic (Python, JS) | Speed of iteration |
| Notebook / data science exploration | Dynamic | REPL feedback loop |
| Production data pipeline | Static (mypy, Scala, Rust) | Catch schema bugs |
| System / OS / driver | Static + linear types (Rust, C) | Memory safety |
| Frontend web app | Static (TypeScript) | Refactoring safety |
| Backend microservice | Static (Go, Java, TypeScript) | API contracts |
| Embedded firmware | Static (C, Rust) | Resource constraints |
| Game engine | Static (C++) | Perf |
| ML training | Dynamic (Python) | Library ecosystem |
| ML inference / serving | Static (Rust, Go, Scala) | Perf + reliability |

→ **Senior 2026** chọn ngôn ngữ theo workload, không theo "yêu thích".

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Python dynamic cho production large codebase

```python
# ❌ Production data pipeline 50K LOC, no type hints
def process(data):
    return data.transform()

# Caller: process(123)  # AttributeError: 'int' has no 'transform'
# Bug discovered 3 months later in prod
```

**Tại sao bad:** Without types, large dynamic codebases accumulate "type debt". Pick **Python + mypy strict** hoặc **migrate to Go/Rust** cho > 10K LOC production.

### Anti-pattern 2 — Lạm dụng `Any` / `any` defeat static system

```typescript
// ❌ Defeating TypeScript with any
function calculate(data: any): any {
    return data.value * 2;
}
// Đã viết TypeScript mà như JavaScript
```

**Tại sao bad:** `any` opt-out của type system. Pick `unknown` (forces narrow check) hoặc generics `<T extends {value: number}>`.

### Anti-pattern 3 — `is` thay vì `==` trong Python

```python
# ❌ Type-related but actually identity check
if user_id is 0:  # Python 3.8+ warns
    ...
# CPython interns small ints — `is` works for small but breaks for large
if user_id is 256: ...   # True (interned)
if user_id is 257: ...   # False (not interned)
```

**Tại sao bad:** `is` = identity, `==` = equality. Subtle dynamic-typing trap. Always `==` for value.

### Anti-pattern 4 — Generic `Object` / `interface{}` lưu mọi thứ

```java
// ❌ Java pre-generics era
Map params = new HashMap();   // Map<Object, Object>
params.put("count", 5);
int c = (Integer) params.get("count");  // unchecked cast, ClassCastException risk
```

**Tại sao bad:** Defeats type system. Pick **generics** `Map<String, Object>` minimum, ideally typed config class.

---

## 🔧 Patterns — gradual typing migration

### Pattern 1: Add types incrementally

```python
# Day 1: untyped
def process(data): ...

# Day 7: add type hints
def process(data: list) -> dict: ...

# Day 30: refine types
def process(data: list[Order]) -> dict[str, Decimal]: ...

# Day 60: enable mypy strict
# add `mypy.ini` with disallow_untyped_defs = True
```

### Pattern 2: Boundary typing — strict outside, loose inside

```python
@app.post("/orders")  # FastAPI = strict typed boundary
def create_order(order: OrderRequest) -> OrderResponse:
    # Inside: can be loose if pure logic
    internal_data = order.dict()  # convert to dict for legacy code
    ...
    return OrderResponse(...)
```

→ Type contract ở API boundary, flex inside.

### Pattern 3: Migrate dynamic → static gradually

| Step | Tool | Effort |
|---|---|---|
| 1. Add docstrings with types | Sphinx | Low |
| 2. Add inline `# type:` comments | mypy | Low |
| 3. Add PEP 484 annotations | Python 3.5+ | Medium |
| 4. Enable mypy basic | `mypy.ini` | Medium |
| 5. Enable mypy strict | `--strict` | High |
| 6. Migrate to typed lang | Rust/Go/Scala | Highest |

---

## 🌱 Advanced topics

### A1. Dependent types
**Idris**, **Coq**, **Agda** — types parameterized by values. `Vec n a` = vector of `n` elements. Eliminates index-out-of-bounds at compile time.

### A2. Linear types / Ownership
**Rust** ownership = linear types in disguise. Each value xài đúng 1 lần (or borrowed). Eliminates use-after-free, data races.

### A3. Type-level programming
TypeScript / Scala 3 / Haskell có **type-level computation**. E.g., `Length<["a", "b", "c"]> = 3` at compile time.

### A4. Apply cho LLM 2026
- **Function calling schema** = static typing for LLM tools (Pydantic, JSON Schema)
- **Structured outputs** (Anthropic / OpenAI) = forced static schema
- **TypedDict / dataclass** cho prompt templates
- **Schema-guided generation** = LLM bị constrain bởi type schema

→ Type systems crucial cho reliable LLM apps.

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. Python static hay dynamic? TypeScript? Rust?
2. Duck typing là gì? Cho 1 ví dụ Python.
3. Type inference khác type annotation thế nào?

### 🟡 Medium
4. Refactoring 50K LOC: Python pure vs Python + mypy strict. Quantify effort difference.
5. JavaScript `[] + {}` ra `"[object Object]"`. Vì sao? TypeScript có catch không?
6. Rust ownership = linear types. Cho 1 case bug mà Rust catch nhưng Java không.

### 🔴 Hard
7. Hindley-Milner Algorithm W: explain `let x = 1 in x + 2.0` type inference (or error).
8. Gradual typing performance overhead trong TypeScript runtime? (Hint: erasure)
9. Trong project DSX Air, KU nào nên typed strict + KU nào để dynamic? Phân tích trade-off.

> **6+/9** = sẵn sàng KU 03. **4-5** = đọc PLAI Types chapter. **<4** = implement mini type checker từ PLAI.

---

## 🔗 Liên kết

- **[F02/01 Imperative vs Declarative](./01-imperative-vs-declarative.md)** — foundation paradigm
- **[F02/03 Strong vs Weak typing](./03-strong-vs-weak-typing.md)** — orthogonal axis
- **[F02/09 ADT](./09-adt-pattern-matching-monads.md)** — static type construction
- **[F04 Type Systems & Validation](../F04-type-systems-validation/)** — applied: Pydantic, schemas

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **PLAI (Krishnamurthi)** → `Krishnamurthi_PLAI_Brown.pdf` — Section "Semantics and Types" — formal type system construction.
- **Practical Haskell** → `Mena_Practical-Haskell-2ed.pdf` — Hindley-Milner inference + type classes in real code.

📖 **Sách commercial:**
- **Pierce, *Types and Programming Languages*** (MIT Press 2002) — type theory bible.
- **Pierce ed., *Advanced Topics in Types and Programming Languages*** (MIT 2005).

📄 **Paper gốc + spec:**
- Hindley (1969), *"The Principal Type-Scheme of an Object in Combinatory Logic"*.
- Milner (1978), *"A Theory of Type Polymorphism in Programming"*, JCSS.
- Cardelli (1996), *"Type Systems"*, Handbook of Computer Science.
- TypeScript official handbook — [typescriptlang.org/docs/handbook](https://www.typescriptlang.org/docs/handbook/intro.html).
- Python PEP 484 — Type Hints.

---

**Đã đọc xong?**
✅ Tick → [F02/03 Strong vs Weak typing](./03-strong-vs-weak-typing.md).
