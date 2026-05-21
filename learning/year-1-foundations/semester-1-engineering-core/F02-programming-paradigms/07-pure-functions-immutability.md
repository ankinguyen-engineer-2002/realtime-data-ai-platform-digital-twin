# KU F02 / 07 — Pure functions + Immutability

> **Pure function** = output **chỉ phụ thuộc input** + **no side effect** (không modify external state, không I/O). **Immutability** = data không bao giờ mutate sau create. Đây là **trụ cột của FP** + backbone của Spark/Flink (immutable DataFrame), React (immutable state), blockchain (immutable ledger).

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/01 Imperative vs Declarative](./01-imperative-vs-declarative.md) · [F02/04 OOP fundamentals](./04-oop-fundamentals.md)
**Related KUs:** [F02/08 Higher-order functions](./08-higher-order-functions.md) · [F02/09 ADT + Monads](./09-adt-pattern-matching-monads.md) · [F02/10 Concurrency](./10-concurrency-primitives.md)
**Đọc trong:** ~16 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn có **công thức nấu phở**. 2 cách áp dụng:

### Cách 1 — Pure function ("Cùng nguyên liệu, cùng kết quả")
- Công thức: `phở(thịt, bánh, gia vị) → tô phở`.
- Bạn nấu với **đúng nguyên liệu hôm qua** → ra **đúng tô phở** hôm qua.
- Không phụ thuộc thời tiết, không phụ thuộc tâm trạng, không **lén thêm gì vào** (no side effect).
- → **Predictable**. Test được. Cache được.

### Cách 2 — Impure function ("Tuỳ tâm trạng")
- Nấu phở **xem thử nước dùng** mặn không, **thêm muối nếu cần**.
- Mỗi lần nấu khác — phụ thuộc **state ngoài** (gói muối còn không, đầu bếp đang ngủ thiếu giấc...).
- Lén **uống thử trước khi serve** → khách mất thìa nước dùng (side effect không ai biết).

**Immutability:**
- **Mutable:** Tô phở mang ra cho khách rồi → khách lén bỏ thêm tương → tô phở thay đổi.
- **Immutable:** Tô phở đã serve = **frozen**. Khách muốn ngọt hơn → **làm tô mới**, không sửa tô cũ.

Trong code:

```python
# ❌ Impure + mutable
counter = 0
def increment():
    global counter
    counter += 1          # side effect: modify global
    print(f"Now {counter}")  # side effect: print
    return counter
```

```python
# ✅ Pure + immutable
def increment(counter: int) -> int:
    return counter + 1    # depends only on input, no side effect
```

→ **Pure + immutable = predictable + parallelizable + cacheable.**

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Core question:** Cho 1 function, làm sao biết nó **an toàn để chạy parallel** + **safe to cache** + **easy to test**?
>
> **Why hard:** Imperative code có **hidden state** — global vars, file system, network, database. Function `compute(x)` có thể return khác lần thứ 2 vì state bên ngoài đổi. → Race condition trong concurrent code. Bug hard to reproduce.
>
> **What we need:** **Pure function** + **immutability** giải quyết tất cả: pure function output deterministic → safe to parallelize, safe to cache, easy to test. Immutable data → no race condition. Đây là **why FP shine cho big data + concurrent systems**.

→ **Spark, Flink, MapReduce đều dùng immutable data.** Đó là lý do parallelize bigger-than-RAM datasets được. Java mutable List = chết khi distribute.

---

## 📖 Định nghĩa chính thức

**Pure function** = function thỏa **2 properties**:

1. **Deterministic** — same input → always same output. `f(x) = f(x)` always.
2. **No side effects** — không modify external state (global vars, files, DB, network).

**Side effect** = bất kỳ change ngoài return value:
- Modify global / instance variable
- Print, log
- File I/O, network call
- Database query (read = arguable, write = definitely)
- Modify argument (mutable input)
- Throw exception (debatable — usually counted as side effect)

**Referential transparency** = property tương đương: expression có thể **thay thế bằng giá trị** mà không thay đổi behavior. Pure function có referential transparency.

```haskell
-- Pure: ref transparent
let x = f(5)
-- Anywhere x is used, can substitute f(5) — same meaning
y = x + x      -- = f(5) + f(5) — runs f twice but same result
```

**Immutability** = data structure **không change** sau khi created. Operations return **new** data structure.

```python
# Mutable
lst = [1, 2, 3]
lst.append(4)         # lst is now [1, 2, 3, 4]

# Immutable
tup = (1, 2, 3)
new_tup = tup + (4,)  # tup still (1, 2, 3), new_tup is (1, 2, 3, 4)
```

**Persistent data structures** = immutable data với efficient updates (share structure). E.g., Clojure persistent vector, Scala `List`. Update cost Θ(log n) thay vì Θ(n) copy.

**Nguồn:** PLAI Krishnamurthi · SICP Abelson-Sussman · Hughes (1989) *"Why Functional Programming Matters"*.

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **Lambda calculus (Alonzo Church, 1936)** — functions as first-class values, pure computation. Foundation cho FP.
- **LISP (McCarthy, 1958)** — first practical FP language. Recursive functions, lists. Functions pure by default but allow mutation.
- **John Backus (1977 Turing Lecture)** — *"Can Programming Be Liberated from the von Neumann Style?"* — Manifesto FP, criticize imperative side effects.
- **ML (Milner, 1973)** — type inference + FP. Influence cho Haskell + Scala + F#.
- **Hughes (1989)** — *"Why Functional Programming Matters"* — popularize FP benefits.
- **Haskell (1990)** — first major **pure** FP language. Force IO via monads (KU 09). Lazy evaluation default.
- **Clojure (2007, Rich Hickey)** — FP on JVM với **immutable persistent data structures** mainstream.
- **React (2013, Facebook)** — immutable UI state — popularize FP cho frontend.
- **Spark (2014, Berkeley AMPLab)** — immutable RDD/DataFrame — FP for big data.
- **Today (2026):** Mainstream langs (Python, Java, C#, JS) đều thêm FP features. **Immutability by default** trend (Kotlin `val`, Rust `let` immutable, Swift `let`).

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Pure function | Pure function | Output depends only on input, no side effect |
| Side effect | Side effect | Modify state outside function |
| Referential transparency | Referential transparency | Expression replaceable by value |
| Idempotent | Idempotent | `f(f(x)) = f(x)` |
| Memoization | Memoization | Cache pure function results |
| Immutable | Immutable | Cannot change after creation |
| Mutable | Mutable | Can change in place |
| Persistent data structure | Persistent data structure | Immutable with efficient updates |
| Structural sharing | Structural sharing | Persistent uses shared subtrees |
| Copy-on-write | Copy-on-write | Lazy copy when actually modified |
| Defensive copy | Defensive copy | Eager copy to prevent mutation |
| Frozen | Frozen | Object marked immutable |
| Const correctness | Const correctness | C++ const propagation |
| Effect | Effect | Computational effect (IO, state, exception) |
| Monad | Monad | Wrapper to compose effects |

---

## 💡 Real-world examples

### Side effect cost — Spark RDD vs Python list

```python
# Python list — mutable, single machine
data = [1, 2, 3, 4, 5]
data.append(6)             # mutates in-place
result = [x*2 for x in data]   # new list

# Spark RDD — immutable, distributed
rdd = sc.parallelize([1, 2, 3, 4, 5])
new_rdd = rdd.map(lambda x: x * 2)
# rdd unchanged, new_rdd is new
# Distributed: workers receive immutable partition → no race condition
```

→ Spark **requires** immutability to distribute safely. If RDD mutable → 2 workers fight over partition.

### Pure function benefits — memoization

```python
from functools import lru_cache

@lru_cache(maxsize=10000)
def fibonacci(n: int) -> int:
    if n <= 1: return n
    return fibonacci(n-1) + fibonacci(n-2)

# Pure → safe to cache
fibonacci(50)   # First call: 1.5 minutes
fibonacci(50)   # Second call: instant (from cache)
```

vs impure:
```python
import random

def random_calc(n: int) -> int:
    return n + random.randint(0, 100)   # depends on random state

# Cannot memoize — output changes
```

### Concurrency — pure functions safe

```python
from concurrent.futures import ProcessPoolExecutor

# Pure functions safe to parallelize
def square(x): return x * x
with ProcessPoolExecutor() as exec:
    results = list(exec.map(square, range(1000000)))   # safe

# Impure with shared state — DANGER
counter = 0
def add_to_counter(x):
    global counter
    counter += x        # race condition!
    return counter
with ProcessPoolExecutor() as exec:
    list(exec.map(add_to_counter, range(1000000)))     # unpredictable!
```

### Production examples

| Tool | Pure / Immutable |
|---|---|
| **Spark DataFrame** | Immutable. Transformations return new DataFrames. |
| **Flink DataStream** | Immutable transformations |
| **Iceberg snapshot** | Immutable. Each update = new snapshot. Old snapshots persist for time travel |
| **Delta Lake log** | Append-only immutable transaction log |
| **Git commits** | Immutable. Each commit references parent |
| **Blockchain** | Immutable ledger by design |
| **React state** | Best practice: immutable, use `setState` to create new |
| **Redux store** | Strictly immutable via reducer = pure function |

---

## 🧮 Pseudocode — pure vs impure  *(Erickson UIUC style)*

### Pure function pattern

```
PURE_FUNCTION(input):
    《No globals, no I/O, no mutation of input》
    let result ← compute(input)
    return result          《same input → same result always》
```

### Persistent data structure update — Clojure-style

```
PERSISTENT_UPDATE(old_map, key, value):
    《Don't mutate old_map》
    《Create new map sharing most structure》
    new_node ← COPY(old_map.node)
    new_node[key] ← value
    return new_map with new_node

《Old map still usable》
let m1 ← {a: 1, b: 2}
let m2 ← PERSISTENT_UPDATE(m1, "c", 3)
《m1 still {a: 1, b: 2}, m2 is {a: 1, b: 2, c: 3}》
```

### Tree-based persistent map (Hash Array Mapped Trie, HAMT)

```
《Trie-based — share unchanged subtrees》
       ROOT
      /  |  \
   node1 node2 node3       ← old map
                 |
              [old leaves]

《Update node3 leaf》

       ROOT'                ← NEW root
      /  |  \
   node1 node2 node3'       ← only node3 copied
                 |
              [new leaf]

《Cost: O(log_32 n) instead of O(n) full copy》
```

→ Persistent data structures = key trick để immutability practical.

---

## 📊 Cost annotation table — pure/impure trade-offs  *(Sedgewick Princeton style)*

| Aspect | Pure / Immutable ⚡ | Impure / Mutable ⚡ |
|---|---|---|
| **Testability** | ✅ Trivial (just check input → output) | ❌ Mock state, setup/teardown |
| **Parallelization** | ✅ Safe by construction | ❌ Need locks, race condition |
| **Memoization** | ✅ Free (lru_cache) | ❌ Cannot cache safely |
| **Reasoning** | ✅ Local — can ignore everything else | ❌ Need to track all callers |
| **Refactoring** | ✅ Move functions freely | ❌ State dependencies |
| **Memory usage** | ❌ More allocations (new objects) | ✅ Mutate in place |
| **Performance (raw)** | ❌ Allocations + GC | ✅ Direct mutation faster |
| **Performance (parallel)** | ✅ Linear scale | ❌ Lock contention limits |
| **Cache efficiency** | ❌ More allocations | ✅ Hot cache lines |
| **Debug** | ✅ Reproducible | ❌ Heisenbug |
| **Time travel debug** | ✅ Replay state history | ❌ Hard |

**When to pick:**

| Workload | Pick |
|---|---|
| Distributed compute (Spark, Flink) | **Immutable** (required) |
| Hot inner loop, perf-critical | Mutable (with care) |
| Multi-threaded shared state | **Immutable** + concurrent collections |
| React/Redux UI | **Immutable** (Redux strict) |
| Game engine ECS | Mutable (perf) |
| Financial calculations | **Immutable Decimal** (avoid mutation bugs) |
| Time-travel debugger | **Immutable** (Redux DevTools, Elm) |
| Embedded systems | Mutable (memory constraint) |

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Mutate function argument

```python
# ❌ Modify caller's list
def add_default(items: list):
    items.append("default")    # ← side effect!
    return items

my_list = [1, 2, 3]
result = add_default(my_list)
# my_list now [1, 2, 3, "default"] — caller surprised
```

**Tại sao bad:** Hidden side effect breaks caller's assumption. Pick:
```python
# ✅ Return new list
def with_default(items: list) -> list:
    return items + ["default"]    # new list, no mutation
```

### Anti-pattern 2 — Global state read in "pure" function

```python
# ❌ "Looks pure" but isn't
TAX_RATE = 0.1
def calculate_tax(amount: Decimal) -> Decimal:
    return amount * TAX_RATE      # depends on global!

# If TAX_RATE changes mid-program → calculate_tax gives different output
# Cache breaks
```

**Tại sao bad:** Pure function = output depends only on input. Pick: pass TAX_RATE as parameter.

### Anti-pattern 3 — Singleton mutable state in tests

```python
# ❌ Tests rely on global ORM session state
class TestUser:
    def test_create(self):
        user = User.objects.create(name="A")
        assert User.objects.count() == 1   # depends on test order!

    def test_count(self):
        assert User.objects.count() == 1   # might be 0 if run first
```

**Tại sao bad:** Tests have order-dependency from mutable shared state. Pick: rollback transaction or in-memory DB per test.

### Anti-pattern 4 — Defensive copy bloat

```python
# ❌ Excessive defensive copy
def calculate(data: list) -> int:
    safe_copy = data.copy()        # defensive copy
    inner = process(safe_copy)
    safer_copy = inner.copy()      # another copy
    return sum(safer_copy)
# 3 copies for 1 calculation
```

**Tại sao bad:** If data already immutable (tuple, frozen list), no need copy. Pick: use immutable types from start.

### Anti-pattern 5 — Hidden mutability in "immutable" wrapper

```python
# ❌ "Immutable" Python class
@dataclass(frozen=True)
class Config:
    settings: dict        # ← dict is mutable!

cfg = Config(settings={"debug": False})
cfg.settings["debug"] = True   # mutates internal dict!
# Frozen dataclass only prevents reassign cfg.settings, not mutation of dict
```

**Tại sao bad:** Shallow immutability. Pick: use `MappingProxyType` or `frozendict` for inner immutability.

---

## 🔧 Patterns — functional core, imperative shell

### Pattern 1: Functional core, imperative shell

```python
# Pure core
def calculate_invoice(order: Order) -> Invoice:
    """Pure: no I/O, no DB, just transform"""
    subtotal = sum(item.price * item.qty for item in order.items)
    tax = subtotal * TAX_RATE
    return Invoice(subtotal=subtotal, tax=tax, total=subtotal + tax)

# Imperative shell — handles I/O
def process_order_endpoint(request):
    order = db.get_order(request.order_id)        # I/O
    invoice = calculate_invoice(order)             # pure
    db.save_invoice(invoice)                       # I/O
    email_service.send(order.customer, invoice)    # I/O
```

→ Core = testable easily, shell = thin orchestration.

### Pattern 2: Persistent data structures library

- Python: `pyrsistent` (PVector, PMap, PSet)
- Clojure: built-in (`vec`, `hash-map`)
- Scala: `List`, `Vector`, `Map` immutable
- Java: `Collections.unmodifiableList()` (read-only view), or use Guava `ImmutableList`
- C++: const correctness + `const` everywhere

### Pattern 3: Builder for immutable construction

```python
@dataclass(frozen=True)
class Config:
    host: str
    port: int
    timeout: int

# Build immutably
config = Config(host="localhost", port=8080, timeout=30)
# "Update" via dataclasses.replace
new_config = dataclasses.replace(config, port=9090)
# config still original, new_config is new
```

### Pattern 4: Event sourcing

```
State at time T = fold over events from beginning of time
```

Each event = immutable. Current state = derived. Time travel + audit log free.

---

## 🌱 Advanced topics

### A1. Effect systems
**Haskell IO monad**, **Koka effects**, **Unison abilities** — track side effects in types. Compiler verifies "this function pure", "this function does network", etc.

### A2. Linear types (Rust ownership)
Each value used exactly once → no aliasing → easier to reason about mutation. Rust achieves "immutability-like" guarantees while allowing in-place mutation when ownership clear.

### A3. CRDT (Conflict-free Replicated Data Types)
Distributed immutable structures that converge without conflict. Used in collaborative editing (Google Docs), distributed databases (Riak).

### A4. Apply cho DE / AI 2026
- **Iceberg snapshots** = immutable, append-only metadata log
- **Delta Lake transactions** = immutable log
- **Spark DataFrame** = immutable, lazy evaluation
- **dbt models** = each run creates new snapshot of derived data
- **Anthropic prompt caching** = pure function over prompt prefix
- **LangChain Runnable** = functional composition

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. Pure function vs impure — phân biệt 1 câu.
2. Cho ví dụ side effect (3 cái).
3. Tại sao Spark DataFrame immutable?

### 🟡 Medium
4. Persistent data structure: HAMT structural sharing. Tại sao update O(log n) thay vì O(n)?
5. Memoization chỉ làm được với pure function. Tại sao?
6. Functional core / imperative shell — show 1 ví dụ refactor.

### 🔴 Hard
7. Clojure HAMT vs Scala Vector — diff implementation strategies?
8. CRDT — counter, set, register: cho 1 ví dụ cách converge không conflict.
9. Trong DSX Air project, immutability ở đâu? (Hint: Iceberg, Kafka log, Flink state).

> **6+/9** = sẵn sàng KU 08. **4-5** = đọc Hughes 1989 *Why FP Matters*. **<4** = implement persistent list trong Python.

---

## 🔗 Liên kết

- **[F02/08 Higher-order functions](./08-higher-order-functions.md)** — FP composition
- **[F02/09 ADT + Monads](./09-adt-pattern-matching-monads.md)** — Effect tracking
- **[F02/10 Concurrency](./10-concurrency-primitives.md)** — Immutability + concurrency
- **[F01/08 Recursion](../F01-cs-fundamentals/08-recursion-iteration.md)** — FP idiom
- **[D18 Spark](../../../year-2-specialization/semester-3-data-engineering-deep/D18-spark-distributed-compute/)** — Immutable RDD

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **PLAI (Krishnamurthi)** → `Krishnamurthi_PLAI_Brown.pdf` — Chapter on state + functions.
- **Practical Haskell** → `Mena_Practical-Haskell-2ed.pdf` — pure functions in Haskell.
- **Haskell Craft (Thompson)** → `Thompson_Haskell-Craft-3ed.pdf` — bài đọc cơ bản.

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **SICP (MIT)** → `Abelson-Sussman_SICP_MIT.pdf` Chapter 1.2 (Procedures and the Processes They Generate) + Chapter 3.1 (Assignment and Local State) — crucial reading.

📖 **Sách commercial:**
- **Pierre-Yves Saumont, *Functional Programming in Java***
- **Vermeulen, *Functional Programming in Scala*** (Scala bible)

📄 **Paper gốc:**
- Hughes (1989), *"Why Functional Programming Matters"*, Computer Journal. **MUST READ.**
- Backus (1978), *"Can Programming Be Liberated from the von Neumann Style?"*, Turing Lecture.
- Bagwell (2001), *"Ideal Hash Trees"* — HAMT foundation.
- Okasaki (1998), *Purely Functional Data Structures* — PhD thesis, foundational.

---

**Đã đọc xong?**
✅ Tick → [F02/08 Higher-order functions (map/reduce/filter)](./08-higher-order-functions.md).
