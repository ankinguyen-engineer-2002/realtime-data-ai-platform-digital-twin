# KU F02 / 08 — Higher-order functions (map / reduce / filter)

> **Higher-order function (HOF)** = function nhận function làm argument, hoặc return function. **map / filter / reduce** = 3 HOF căn bản. Spark transformation, pandas/Polars `.apply()`, JavaScript `Array.map`, SQL `GROUP BY` — đều dùng HOF dưới hood. Hiểu HOF = đọc/viết FP code thanh thoát.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/07 Pure functions](./07-pure-functions-immutability.md)
**Related KUs:** [F02/09 ADT + Monads](./09-adt-pattern-matching-monads.md) · [F01/08 Recursion](../F01-cs-fundamentals/08-recursion-iteration.md)
**Đọc trong:** ~14 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn có **dây chuyền sản xuất bánh**:

### Map — "Áp công thức lên từng cái"
- Có 100 cục bột → **mỗi cục** đem cắt thành hình tròn.
- `map(cắt_tròn, 100_cục_bột) → 100_bánh_tròn`.

### Filter — "Chọn cái thoả điều kiện"
- 100 bánh nướng xong → **giữ lại** cái không bị cháy.
- `filter(không_cháy, 100_bánh) → ~80 bánh đẹp`.

### Reduce — "Gom tất cả thành 1"
- 80 bánh đẹp → **đóng gói chung** 1 thùng.
- `reduce(đóng_gói, 80_bánh) → 1 thùng 80 bánh`.

Trong code Python:

```python
numbers = [1, 2, 3, 4, 5]

# Map: square each
squared = list(map(lambda x: x*x, numbers))      # [1, 4, 9, 16, 25]

# Filter: keep evens
evens = list(filter(lambda x: x % 2 == 0, numbers))   # [2, 4]

# Reduce: sum all
from functools import reduce
total = reduce(lambda a, b: a + b, numbers, 0)   # 15
```

**Vai trò function-as-argument:**
- `map`, `filter`, `reduce` không biết "cắt tròn" hay "nướng" — chúng nhận function làm tham số.
- → Higher-order = function ăn function.

→ **HOF = building blocks cho mọi FP code. SQL GROUP BY + aggregation = reduce dưới hood.**

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Câu hỏi cốt lõi:** Cho 1 collection items, làm sao **diễn tả transformation** (filter, map, aggregate) sao cho (a) **compose được**, (b) **parallelize được**, (c) **không phải viết loop bằng tay**?
>
> **Vì sao khó:** Loop imperative `for x in items: ...` gắn chặt "iterate" với "compute". Mỗi loop khác nhau nên khó tách + reuse. Khó parallelize vì có state (accumulator). Khó test từng phần riêng.
>
> **Điều ta cần:** Tách "iterate" ra khỏi "compute" → **HOF (Higher-Order Function)**. `map` = iterate + apply f. `filter` = iterate + giữ nếu pred true. `reduce` = iterate + combine. Mỗi phần reusable, composable, pure.

→ **Spark DataFrame, pandas, dplyr (R), LINQ (C#)** — tất cả build trên HOF. Skill data engineer modern = nghĩ trong HOF, không nghĩ trong loop.

---

## 📖 Định nghĩa chính thức

**Higher-order function** = function thỏa 1 hoặc cả 2:
1. Take function as parameter
2. Return function

**Examples:**
- `map(f, xs)` — apply `f` to each `x in xs`, return new collection
- `filter(p, xs)` — keep `x in xs` where `p(x)` true
- `reduce(f, xs, init)` — combine `xs` from left: `f(f(f(init, x1), x2), x3)...`
- `sort(xs, key=f)` — sort using `f` to extract key
- `compose(f, g) = λx. f(g(x))` — function composition

**First-class function** = functions can be passed as values, stored in vars, returned. Prerequisite cho HOF.

**Currying** = transform `f(a, b, c)` → `f(a)(b)(c)`. Each call returns function expecting next arg. Native trong Haskell.

**Partial application** = fix some args of function, return function expecting remaining args.
```python
from functools import partial
add = lambda a, b: a + b
add5 = partial(add, 5)   # fix a=5
add5(3)   # 8
```

**Function composition** = `(f ∘ g)(x) = f(g(x))`. Sequential application.

**Closures** = function + captured environment. Function "remembers" outer variables.

**Nguồn:** SICP Chapter 1.3 *"Formulating Abstractions with Higher-Order Procedures"* · Hughes 1989 *Why FP Matters* — argues HOF for composability.

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **Lambda calculus (Church, 1936)** — functions can take functions as args. Theoretical foundation.
- **LISP (McCarthy, 1958)** — first practical first-class functions. `mapcar` = early `map`.
- **APL (Iverson, 1962)** — array operations as primitives. Operator-based equivalent of HOF.
- **MapReduce (Dean & Ghemawat, Google, 2004)** — distributed map + reduce. Popularize HOF for big data.
- **Hadoop (2006)** — open source MapReduce. Foundation cho Spark.
- **Spark (2014, Berkeley)** — RDD with HOF: `rdd.map(f).filter(p).reduce(g)`. Replace MapReduce.
- **Java 8 (2014)** — Stream API + lambda — Java finally first-class functions.
- **JavaScript / TypeScript** — `Array.prototype.map/filter/reduce`, arrow functions.
- **Python 3.x** — `map`, `filter`, `reduce`, list comprehensions, lambdas.
- **Today (2026):** Mọi modern lang có HOF. SQL GROUP BY = reduce. CSS animations = HOF (compose transitions). React render = HOF (component as function).

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Higher-order function | Higher-order function | Takes/returns function |
| First-class function | First-class function | Function as value |
| Lambda | Lambda / Anonymous function | Function without name |
| Closure | Closure | Function + captured env |
| Map | Map | Apply function to each |
| Filter | Filter | Keep matching |
| Reduce / Fold | Reduce/Fold | Combine all into one |
| Foldl / Foldr | Foldl/Foldr | Left or right associative fold |
| Currying | Currying | Multi-arg → chain of single-arg |
| Partial application | Partial application | Fix some args |
| Function composition | Function composition | f ∘ g |
| Identity function | Identity function | `λx. x` |
| Constant function | Constant function | `λx. c` |
| Point-free / tacit | Point-free | Define without naming args |
| Functor | Functor | Mappable (e.g., List, Maybe) |
| Monad | Monad | Composable effect wrapper |
| MapReduce | MapReduce | Distributed map + reduce |

---

## 💡 Real-world examples

### Map / Filter / Reduce in 4 paradigms

**Task:** Sum squares of even numbers 1..100.

```python
# Imperative
total = 0
for i in range(1, 101):
    if i % 2 == 0:
        total += i * i
```

```python
# HOF (Python)
from functools import reduce
total = reduce(
    lambda acc, x: acc + x*x,
    filter(lambda x: x % 2 == 0, range(1, 101)),
    0
)
```

```python
# Comprehension (declarative Python)
total = sum(x*x for x in range(1, 101) if x % 2 == 0)
```

```sql
-- SQL declarative
SELECT SUM(x * x) FROM numbers WHERE x % 2 = 0;
```

```scala
// Spark Scala
val total = sc.parallelize(1 to 100)
              .filter(_ % 2 == 0)
              .map(x => x * x)
              .sum()
```

### MapReduce — distributed word count

```python
# Original MapReduce paper (Dean-Ghemawat 2004)
documents = ["hello world", "world peace", ...]

# Map: each doc → (word, 1) pairs
def map_fn(doc):
    return [(word, 1) for word in doc.split()]

# Reduce: group by word, sum counts
def reduce_fn(word, counts):
    return (word, sum(counts))

# Distributed:
mapped = parallel_map(map_fn, documents)        # ~M machines
shuffled = group_by_key(mapped)                  # cluster shuffle
reduced = parallel_reduce(reduce_fn, shuffled)   # ~R machines
```

→ Foundation cho Spark/Hadoop/Flink. Pure functions critical to distribute safely.

### React component as function

```jsx
// HOF returning component
function withLogging(WrappedComponent) {
    return function(props) {
        console.log('Rendering', WrappedComponent.name);
        return <WrappedComponent {...props} />;
    };
}

// Usage: enhance any component with logging
const LoggedButton = withLogging(Button);
```

→ Higher-order Component (HOC) pattern — JS React's way of dependency injection / cross-cutting concerns.

### Production DE examples

| Tool | HOF usage |
|---|---|
| **Spark DataFrame** | `.filter()`, `.select()`, `.groupBy().agg()` — all HOF |
| **pandas / Polars** | `.apply()`, `.map()`, `.transform()` |
| **dbt macros** | Jinja macros = HOF for SQL |
| **Airflow DAG** | TaskFlow `@task` decorator wraps function |
| **JavaScript stream processing** | RxJS operators |
| **LangChain** | `RunnableLambda`, `RunnableMap`, pipe |

---

## 🧮 Pseudocode — implementing map/filter/reduce  *(Erickson UIUC style)*

```
MAP(f, xs):
    result ← EMPTY
    for each x in xs
        APPEND(result, f(x))
    return result

FILTER(p, xs):
    result ← EMPTY
    for each x in xs
        if p(x) then APPEND(result, x)
    return result

REDUCE(f, xs, init):
    acc ← init
    for each x in xs
        acc ← f(acc, x)
    return acc
```

### Function composition

```
COMPOSE(f, g):
    return λx. f(g(x))             《function returning function》

《Example use:》
let double ← λx. x * 2
let addOne ← λx. x + 1
let doubleThenAddOne ← COMPOSE(addOne, double)
doubleThenAddOne(5) = addOne(double(5)) = addOne(10) = 11
```

### Currying

```
CURRY(f):                          《f takes (a, b)》
    return λa. λb. f(a, b)         《now f(a)(b)》

let add ← CURRY(λa,b. a + b)
let add5 ← add(5)
add5(3) = 8
```

### MapReduce skeleton (distributed)

```
MAPREDUCE(input, map_fn, reduce_fn):
    《Phase 1: Map (parallel across M workers)》
    intermediate ← PARALLEL_MAP_WORKERS(input, map_fn)
    《intermediate = list of (key, value)》

    《Phase 2: Shuffle (group by key, network-heavy)》
    grouped ← GROUP_BY_KEY(intermediate)

    《Phase 3: Reduce (parallel across R workers)》
    output ← PARALLEL_REDUCE_WORKERS(grouped, reduce_fn)

    return output
```

---

## 📊 Cost annotation table — HOF performance  *(Sedgewick Princeton style)*

| Operation | Time | Space | Parallelizable |
|---|---|---|---|
| `map(f, n elements)` | Θ(n · f_cost) | Θ(n) new collection | ✅ Embarrassingly |
| `filter(p, n elements)` | Θ(n · p_cost) | Θ(k) where k ≤ n | ✅ Embarrassingly |
| `reduce(f, n, init)` left fold | Θ(n · f_cost) | Θ(1) | ✅ if f associative |
| `reduce_right(f, n, init)` | Θ(n · f_cost) | Θ(n) stack | ❌ sequential |
| `sort(xs, key=f)` | Θ(n log n) | Θ(n) | Partial (merge sort) |
| `compose(f, g)` call once | Θ(f_cost + g_cost) | depends | depends |

**Associative reduce can parallelize:**
```
sum([1,2,3,4,5,6,7,8])
= ((((((1+2)+3)+4)+5)+6)+7)+8   [sequential, 7 steps]

Tree reduce (parallel):
= ((1+2)+(3+4)) + ((5+6)+(7+8))   [3 levels, log n parallel steps]
```

→ Sum, max, min, count = associative → Spark parallelizes safely. Subtract = non-associative → don't.

**Performance comparison (sum 1B integers):**
| Approach | Time |
|---|---|
| Python `for x in xs: total += x` | ~80 sec |
| Python `sum(xs)` | ~50 sec (less interpreter overhead) |
| NumPy `arr.sum()` | ~0.5 sec (vectorized C) |
| Spark RDD `.reduce(_+_)` 8 cores | ~7 sec (parallel) |
| Spark DataFrame `.sum()` 8 cores | ~5 sec (Catalyst optimized) |
| Rust `.iter().sum()` | ~0.3 sec |

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Side effect in map

```python
# ❌ Map with side effect
counter = 0
def process(x):
    global counter
    counter += 1     # side effect!
    return x * 2

list(map(process, range(1000)))
# counter? Maybe 1000, maybe wrong if parallel
```

**Vì sao bad:** Map should be pure. Side effects break parallelization. Pick: separate counting from transformation, or use `enumerate`.

### Anti-pattern 2 — Reduce với non-associative function

```python
# ❌ Non-associative
reduce(lambda a, b: a - b, [10, 1, 2, 3], 0)
# Result depends on parallelization order!
# Sequential left: (((0-10)-1)-2)-3 = -16
# Parallel tree: cannot guarantee same result
```

**Vì sao bad:** Subtraction not associative. Pick: only associative ops (sum, max, min, AND, OR, concat).

### Anti-pattern 3 — Closure capturing mutable variable

```python
# ❌ Closure over loop variable
funcs = []
for i in range(5):
    funcs.append(lambda: i)   # all lambdas capture same `i`

print([f() for f in funcs])
# [4, 4, 4, 4, 4] — all see final value of i!
```

**Vì sao bad:** Late binding of `i`. Pick: use default arg `lambda i=i: i` or list comp `[lambda i=i: i for i in range(5)]`.

### Anti-pattern 4 — Over-clever HOF chain unreadable

```python
# ❌ Unreadable
result = reduce(
    lambda acc, x: acc + [x[0]] if x[1] > 0 else acc,
    map(lambda y: (y, y % 3),
        filter(lambda z: z > 5,
               sorted(items, key=lambda i: -i)
        )
    ),
    []
)
```

**Vì sao bad:** Nested 5 levels deep, unclear intent. Pick: refactor into named functions or use comprehensions:
```python
sorted_items = sorted(items, key=lambda i: -i)
filtered = [z for z in sorted_items if z > 5]
result = [y for y in filtered if y % 3 > 0]
```

---

## 🔧 Patterns — functional toolkit

### Pattern 1: Pipe / pipeline

```python
# Python: use methods chaining
result = (data
    .pipe(filter_outliers)
    .pipe(normalize)
    .pipe(aggregate)
    .pipe(format_output))
```

```python
# Or functional toolkit (toolz, funcy)
from toolz import pipe, curry

result = pipe(data,
              filter_outliers,
              normalize,
              aggregate,
              format_output)
```

### Pattern 2: Partial application for configuration

```python
from functools import partial

def transform(scale, offset, x):
    return x * scale + offset

# Pre-configure
celsius_to_fahrenheit = partial(transform, 9/5, 32)
temps = [0, 10, 20, 30]
print(list(map(celsius_to_fahrenheit, temps)))   # [32.0, 50.0, 68.0, 86.0]
```

### Pattern 3: Decorator = HOF returning function

```python
def timing(fn):
    @wraps(fn)
    def wrapper(*args, **kw):
        start = time.time()
        result = fn(*args, **kw)
        print(f"{fn.__name__}: {time.time() - start:.3f}s")
        return result
    return wrapper

@timing
def slow_op(): time.sleep(1)
```

### Pattern 4: Monadic pipeline (preview KU 09)

```python
from typing import Optional

def safe_divide(a, b) -> Optional[float]:
    return a / b if b != 0 else None

def safe_sqrt(x) -> Optional[float]:
    return math.sqrt(x) if x >= 0 else None

def pipeline(x, y):
    result = safe_divide(x, y)
    if result is None: return None
    return safe_sqrt(result)
```

→ KU 09 generalizes via monad.

---

## 🌱 Advanced topics

### A1. Transducers (Clojure)
Compose transformations without intermediate collections. `(comp (map f) (filter p))` = single-pass transform.

### A2. Lazy evaluation + HOF
Haskell `map f (filter p xs)` — never builds intermediate list, fused into one loop. Spark transformations lazy.

### A3. Apply cho DE / AI 2026
- **dbt `ref()` + `source()`** = HOF over SQL
- **Spark Window functions** = HOF over partitions
- **LangChain Runnable** = function composition
- **LLM agent loops** = `reduce` over reasoning steps
- **MCP tools** = HOF over input schema

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. map vs filter vs reduce — phân biệt 1 câu mỗi cái.
2. Cho ví dụ Python `lambda` đơn giản.
3. Higher-order function — định nghĩa.

### 🟡 Medium
4. Tại sao `reduce` cần init? Cho counterexample khi không có init.
5. Cuộn (closure) capture loop variable — anti-pattern. Show fix.
6. Spark MapReduce: shuffle stage cost gì? Tại sao reduce tốn hơn map?

### 🔴 Hard
7. Currying vs partial application — diff?
8. Transducer pattern — explain + cho ví dụ implementation.
9. Trong DSX Air, HOF ở đâu? (Hint: Flink keyed stream, Spark transformations, Iceberg manifest list operations).

> **6+/9** = sẵn sàng KU 09. **4-5** = đọc SICP Chapter 1.3. **<4** = implement `map/filter/reduce` from scratch.

---

## 🔗 Liên kết

- **[F02/07 Pure functions](./07-pure-functions-immutability.md)** — prereq cho safe HOF
- **[F02/09 ADT + Monads](./09-adt-pattern-matching-monads.md)** — HOF over algebraic types
- **[F01/08 Recursion](../F01-cs-fundamentals/08-recursion-iteration.md)** — FP idiom
- **[D18 Spark](../../../year-2-specialization/semester-3-data-engineering-deep/D18-spark-distributed-compute/)** — distributed HOF

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **PLAI (Krishnamurthi)** → `Krishnamurthi_PLAI_Brown.pdf` Chapter 6 "First-Class Functions" — implementation deep dive.
- **Haskell Craft (Thompson)** → `Thompson_Haskell-Craft-3ed.pdf` — natural HOF examples.
- **Practical Haskell** → `Mena_Practical-Haskell-2ed.pdf`.

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **SICP (MIT)** → `Abelson-Sussman_SICP_MIT.pdf` Chapter 1.3 "Formulating Abstractions with Higher-Order Procedures" — **bài đọc bắt buộc**.

📖 **Sách commercial:**
- **Erickson, *Algorithms*** (UIUC, có trong cs-fundamentals) — recursion + HOF.
- **Vermeulen, *Functional Programming in Scala***.
- **Brian Lonsdorf, *Mostly Adequate Guide to Functional Programming*** (JavaScript free online).

📄 **Paper gốc:**
- Dean & Ghemawat (2004), *"MapReduce: Simplified Data Processing on Large Clusters"*, OSDI — Google paper.
- Hughes (1989), *"Why Functional Programming Matters"*.
- McCarthy (1960), *"Recursive Functions of Symbolic Expressions"*, CACM.

---

**Đã đọc xong?**
✅ Tick → [F02/09 ADT + Pattern matching + Monads](./09-adt-pattern-matching-monads.md).
