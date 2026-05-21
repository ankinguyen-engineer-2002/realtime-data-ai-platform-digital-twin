# KU F02 / 01 — Imperative vs Declarative paradigm

> Cùng 1 vấn đề có 2 cách tả: "**làm theo bước**" (imperative) hay "**nói cái cần**" (declarative). SQL `SELECT * WHERE x > 5` = declarative. Python `for row in data: if row.x > 5: yield row` = imperative. Hiểu phân biệt = pick đúng paradigm + đọc Spark / pandas / SQL với tư duy đúng.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F00 Trade-off thinking](../F00-mental-models/02-trade-off-thinking.md) · [F01 Big-O](../F01-cs-fundamentals/02-big-o-notation.md)
**Related KUs:** [F02/02 Typing](./02-static-vs-dynamic-typing.md) · [F02/07 Pure functions](./07-pure-functions-immutability.md)
**Đọc trong:** ~14 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn đặt **bún bò Huế** ở quán quen. 2 cách:

### Cách 1 — Imperative ("Theo dõi từng bước")
> Em ơi, lấy tô lớn (300ml), múc 250ml nước dùng nóng vào, cho 1 lạng bún tươi đã chần qua nước sôi 30 giây, thêm 3 lát thịt bò tái, 2 viên giò heo, 1 nhúm rau quế + giá, rắc tiêu, vắt nửa chanh, mang ra bàn số 5.

→ Bạn **kiểm soát từng bước** + biết chính xác cách thực hiện.
→ Nếu thiếu nguyên liệu → bạn phải sửa quy trình.
→ Code-style: `for`, `while`, mutable state, step-by-step.

### Cách 2 — Declarative ("Nói cái muốn")
> Em ơi, **1 tô bún bò Huế đầy đủ, không cay**.

→ Bạn **chỉ nói cái cần**, không quan tâm thực hiện.
→ Quán tự pick nguyên liệu thay thế nếu thiếu.
→ Code-style: SQL, regex, HTML, declarative DSL.

**Hai cách KHÔNG có "tốt/xấu"** — phụ thuộc context:
- Bạn là **đầu bếp mới** (chưa biết quy trình) → imperative (chỉ rõ).
- Bạn là **khách quen** → declarative (gọn).
- Bạn **debug món lạ** → imperative (kiểm soát).
- Bạn **đặt 100 món** → declarative (scale tốt).

→ **Imperative = HOW. Declarative = WHAT.** Đây là divide quan trọng nhất trong programming paradigms.

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Core question:** Cho 1 task (filter rows > 5, render UI button, train ML model), bạn nên (a) **viết từng bước** (imperative) hay (b) **declare cái cần và để runtime tự chạy** (declarative)?
>
> **Why hard:** Imperative cho perf tốt nhất (control mọi memory access), nhưng code dài + dễ bug + khó parallelize. Declarative gọn + để optimizer tự pick best plan, nhưng nếu optimizer dở → perf horror (Spark Catalyst pre-Tungsten era).
>
> **What we need:** Hiểu **execution model** của mỗi paradigm + biết khi nào nào declarative actually = imperative dưới surface (Python list comprehension → bytecode for loop), khi nào declarative thực sự khác (SQL → query planner).

→ Senior data engineer xài cả 2: SQL/DataFrame cho transform (declarative), Python control flow cho orchestration (imperative). Junior thường stuck ở 1 paradigm → code dở.

---

## 📖 Định nghĩa chính thức

**Imperative programming** = paradigm where computation is described as **sequence of statements that change program state**.

- Focus: **HOW** (steps to achieve goal)
- Building blocks: assignments, loops, conditionals, mutable variables
- Examples: C, Python (procedural style), Java (procedural style), Go, Rust, assembly

**Declarative programming** = paradigm where computation is described by **declaring what should be true** about the desired result, without specifying control flow.

- Focus: **WHAT** (desired outcome)
- Building blocks: expressions, definitions, transformations
- Examples: SQL, HTML, regex, Haskell, Prolog, Make, Terraform

**Sub-paradigms:**

| Paradigm | Sub-paradigm | Example |
|---|---|---|
| Imperative | Procedural | C, Pascal |
| Imperative | Object-oriented | Java, C# |
| Declarative | Functional | Haskell, Erlang, Lisp |
| Declarative | Logic | Prolog, Datalog |
| Declarative | Query | SQL, GraphQL |
| Declarative | DSL | HTML, CSS, Make |

**Nguồn:** Krishnamurthi *PLAI* (Brown) Chapter 1 · UPenn Lecture HPC 7 Programming Paradigms.

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **Imperative** (Latin *imperare* = "to command"): style đầu tiên. **John von Neumann (1945)** thiết kế EDVAC stored-program computer — execution = sequence of instructions modifying state. Mọi assembly language, FORTRAN (1957), COBOL (1959), C (1972) đều imperative.
- **Declarative**: ra đời từ math + logic.
  - **Lambda calculus (Alonzo Church, 1936)** = foundation cho FP, pure expressions không có state.
  - **LISP (John McCarthy, 1958)** = ngôn ngữ functional + declarative đầu tiên (MIT AI Lab).
  - **Prolog (Colmerauer-Roussel, 1972)** = logic programming.
  - **SQL (Chamberlin-Boyce, IBM 1974)** — Structured Query Language — declarative for relational data.
- **Today (2026):** Modern systems mix cả 2.
  - **React** = declarative UI ("render this state") nhưng internal reconciler = imperative.
  - **TensorFlow/PyTorch** = declarative computation graph + imperative gradient backprop.
  - **Spark DataFrame** = declarative DSL + Catalyst optimizer chuyển thành physical imperative.
  - **Iceberg / Delta Lake** = declarative table state + imperative compaction.

→ Trend 50 năm: **declarative chiếm dần** — không phải imperative biến mất, mà runtime ngày càng smart hơn.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Imperative | Imperative | Step-by-step state mutation |
| Declarative | Declarative | State the goal, runtime executes |
| Procedural | Procedural | Imperative organized into procedures |
| Functional | Functional | Declarative via pure functions |
| Logic | Logic programming | Declarative via predicates + unification |
| Query language | Query language | Declarative for data retrieval |
| DSL | Domain-Specific Language | Declarative narrow purpose |
| Eager evaluation | Eager evaluation | Evaluate immediately (imperative default) |
| Lazy evaluation | Lazy evaluation | Defer until needed (Haskell, Spark) |
| Side effect | Side effect | Modify state outside function scope |
| Referential transparency | Referential transparency | Expression always = its value |
| Control flow | Control flow | Order of execution |
| Mutation | Mutation | Change of state |
| Optimizer | Optimizer | Component that picks execution plan |
| Logical plan | Logical plan | Declarative description |
| Physical plan | Physical plan | Imperative execution steps |

---

## 💡 Real-world examples

### Filter list > 5 — 4 paradigm side-by-side

```python
# 1. Imperative procedural (C-style)
result = []
for x in numbers:
    if x > 5:
        result.append(x)
```

```python
# 2. Imperative OOP (Java-style)
result = ArrayList()
for x in numbers:
    if x > 5:
        result.add(x)
```

```python
# 3. Declarative functional
result = list(filter(lambda x: x > 5, numbers))
# or:
result = [x for x in numbers if x > 5]
```

```sql
-- 4. Declarative query
SELECT x FROM numbers WHERE x > 5;
```

**Comparing:**
| Aspect | Imperative | Declarative |
|---|---|---|
| Lines of code | Lower-level, more lines | Higher-level, fewer lines |
| Performance control | High (manual loop) | Lower (runtime optimize) |
| Parallelization | Hard (mutable shared state) | Easy (no state) |
| Debug | Step-through possible | Black-box, depends on runtime |
| Optimization | You optimize | Runtime optimizer optimizes |

### Production examples từ DSX Air project

| Tool | Paradigm | Why pick |
|---|---|---|
| **SQL trong Postgres / Trino / ClickHouse** | Declarative | Optimizer chọn join order, index use, parallelism |
| **Spark DataFrame** | Declarative + Catalyst optimizer | Lazy evaluation + cost-based query plan |
| **Flink keyed state** | Imperative (Java/Scala loops) | Control over state mutation |
| **Iceberg DDL** (`ALTER TABLE ... PARTITION FIELD`) | Declarative | Hide partition rewrite details |
| **Dagster asset definitions** | Declarative DAG | Auto-resolve dependencies |
| **Python orchestrator code** | Imperative | Need control + logging |
| **Terraform / Pulumi (infra)** | Declarative | "Want 3 EC2 instances" — provider figures out create/update/destroy |
| **NumPy vectorized ops** | Declarative (under SIMD) | `arr * 2` — vectorized C loop |

→ **Rule of thumb:** Data-shape transformations → declarative. Imperative cho orchestration + system code.

---

## 🧮 Pseudocode — same algorithm 2 styles  *(Erickson UIUC style)*

### Sum of squares of even numbers 1..N

```
SUM_SQUARES_EVEN_IMPERATIVE(N):
    total ← 0
    for i ← 1 to N
        if i mod 2 = 0 then
            total ← total + (i × i)
    return total
```

```
SUM_SQUARES_EVEN_DECLARATIVE(N):
    return SUM(SQUARE(x) for x in 1..N where IS_EVEN(x))
```

**Same complexity** Θ(N) **same output**. Khác:
- Imperative: `total` mutable, accumulator updated step by step
- Declarative: composition of `range`, `filter`, `map`, `sum` — no mutable state

**Wall-clock comparison** (Python 3.12):
```python
# Imperative
def imp(n):
    total = 0
    for i in range(1, n+1):
        if i % 2 == 0: total += i*i
    return total
# ~ 80 ms cho n = 10^6

# Declarative
def dec(n):
    return sum(i*i for i in range(1, n+1) if i % 2 == 0)
# ~ 60 ms cho n = 10^6

# Vectorized declarative (NumPy)
def vec(n):
    arr = np.arange(1, n+1)
    return (arr[arr % 2 == 0] ** 2).sum()
# ~ 4 ms cho n = 10^6 — 20× nhanh hơn imperative pure Python
```

→ Declarative + vectorized engine = best perf vì optimizer chuyển thành SIMD/parallel.

---

## 📊 Cost annotation table — paradigm pick guide  *(Sedgewick Princeton style)*

| Aspect | Imperative wins | Declarative wins |
|---|---|---|
| **Performance ceiling** | ⚡ Highest (manual optimization) | High but optimizer-dependent |
| **Performance floor** | High (predictable) | ⚠️ Variable (depends on optimizer) |
| **Lines of code** | More | ⚡ Fewer |
| **Readability for experts** | Step-by-step clear | ⚡ Intent clear |
| **Readability for beginners** | ⚡ Easier (familiar) | Harder (need to know primitives) |
| **Parallelism** | Hard (locks, mutex) | ⚡ Easy (no state) |
| **Distributed execution** | Hard | ⚡ Easy (Spark, Flink) |
| **Side effects** | ⚡ Natural | Awkward (need monad/effect) |
| **Domain-specific extensions** | Manual | ⚡ Easy (DSL) |
| **Debugging** | ⚡ Step-through | Black-box optimizer |
| **Lazy evaluation** | Hard | ⚡ Natural |
| **Memoization / caching** | Manual | ⚡ Automatic in pure FP |

**Picking guide:**
- **Pick Imperative** khi: hot loop perf-critical (C, Rust), need step-by-step debugging, OS / driver code, embedded systems
- **Pick Declarative** khi: data transforms (SQL/DataFrame), UI (React), infra (Terraform), parallel/distributed
- **Mix both** (modern reality): React (declarative UI + imperative effects), Spark (declarative DataFrame + imperative UDF), TensorFlow (declarative graph + imperative training loop)

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Imperative cho data transforms

```python
# ❌ Loop 100M rows in Python to sum sales by region
sales_by_region = {}
for row in df.iterrows():    # iterrows = SLOW
    region = row['region']
    if region not in sales_by_region:
        sales_by_region[region] = 0
    sales_by_region[region] += row['amount']
# ~ 5 minutes
```

**Tại sao bad:** Python interpreter loop, no vectorization, no parallelism. Pick **declarative** với pandas/Polars/Spark:
```python
# ✅ Declarative
sales_by_region = df.groupby('region')['amount'].sum()
# ~ 2 seconds (200x faster)
```

### Anti-pattern 2 — Declarative cho stateful orchestration

```python
# ❌ Pure functional cho pipeline orchestration
@dataclass(frozen=True)
class Pipeline:
    state: tuple
    def step(self): return Pipeline(self.state + (new_step,))
# Can't pause/resume, can't log, can't retry — declarative bad fit
```

**Tại sao bad:** Orchestration **needs** state (retry count, partial completion, logs). Pick **imperative** với Dagster/Airflow operators.

### Anti-pattern 3 — Lạm dụng `for` trong SQL

```sql
-- ❌ Procedural inside SQL
DO $$
DECLARE rec RECORD;
BEGIN
    FOR rec IN SELECT * FROM big_table LOOP
        UPDATE result SET total = total + rec.x WHERE region = rec.region;
    END LOOP;
END $$;
-- 10M rows, sequential update, ~30 min
```

**Tại sao bad:** SQL optimizer không thấy intent. Pick **set-based declarative**:
```sql
-- ✅ Declarative
UPDATE result r
SET total = (SELECT SUM(x) FROM big_table b WHERE b.region = r.region);
-- ~ 30 seconds
```

### Anti-pattern 4 — "Functional purity" obsession trong I/O code

```python
# ❌ Trying to be pure trong code mà bản chất là side effect
def write_file(path, content):
    # "I'll make this pure by returning IO action"
    return lambda: open(path, 'w').write(content)
# Python không có IO monad → just complexity overhead
```

**Tại sao bad:** Python không phải Haskell. **Lying about purity** khi I/O không tránh được = trade rõ ràng for fake elegance. Pick **honest imperative** + isolate side effects ở boundary.

---

## 🔧 Patterns — modern mixed paradigm

### Pattern 1: Pipeline = declarative chain

```python
# pandas / Polars / Spark — declarative chain
(df
  .filter(pl.col('amount') > 100)
  .group_by('region')
  .agg(pl.col('amount').sum())
  .sort('amount', descending=True)
  .head(10))
```

→ Mỗi step là **declarative description**. Engine optimizes vào single physical plan.

### Pattern 2: Sandwich = imperative outer + declarative inner

```python
# Imperative outer (orchestration)
for date in date_range:
    # Declarative inner (transformation)
    daily = spark.read.parquet(f's3://data/{date}').filter(...).groupBy(...).agg(...)
    daily.write.parquet(f's3://result/{date}')
```

→ Loop imperatively for control + retry, but each iteration's work is declarative.

### Pattern 3: DSL = embed declarative trong imperative host

```python
# Python (imperative) embed SQL (declarative)
result = duckdb.sql("""
    SELECT region, SUM(amount) AS total
    FROM df
    WHERE date >= '2026-01-01'
    GROUP BY region
""").df()
```

→ Most data engineering work look kiểu này.

---

## 🌱 Advanced topics

### A1. Reactive programming
RxJS, React Server Components — declarative streams + dependency tracking. UI ngày càng declarative.

### A2. Declarative infrastructure (IaC)
Terraform, Pulumi, Kubernetes YAML, Helm — declare desired state, reconciler does diff + apply. Imperative scripts (Bash, Ansible imperative mode) đang được thay thế.

### A3. Differential dataflow (Materialize, Naiad)
Spark = batch declarative. Materialize = **streaming declarative** with incremental view maintenance. Same SQL semantic, runtime tự update khi data đổi.

### A4. Apply cho LLM 2026
- **System prompts** = declarative ("be a helpful assistant")
- **Tool/function calling** = declarative ("here are tools, pick one")
- **Agent reasoning** = imperative (sequence of tool calls + state)
- **Tool definitions trong code** = declarative DSL

→ LLM era mixed paradigm: declarative spec + imperative execution loop.

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. Cho code Python `result = [x*2 for x in items if x > 0]`. Đây là imperative hay declarative?
2. SQL `SELECT * FROM users` là paradigm gì? Tại sao?
3. Đầu bếp mới vào quán — bạn order bằng imperative hay declarative?

### 🟡 Medium
4. Pandas `df.groupby('region').sum()` declarative ở mức user, nhưng dưới chạy như thế nào? (Hint: cython/numpy)
5. Cho 1 task data transform 1TB. Pick paradigm + reason.
6. Functional purity tốt cho parallelize. Tại sao? Cho 1 ví dụ cụ thể.

### 🔴 Hard
7. Spark Catalyst optimizer rewrite declarative DataFrame thành RDD imperative. Cho 1 ví dụ optimization mà Catalyst thực hiện được nhưng pure imperative không.
8. React virtual DOM declarative-style. Trade-off với imperative DOM manipulation (jQuery)? Quantify.
9. Trong project DSX Air, KU nào dùng declarative + KU nào imperative? Pattern overall của project?

> **6+/9** = sẵn sàng KU 02. **4-5** = đọc PLAI Chapter 1 + UPenn Programming Paradigms lecture. **<4** = code 5 algorithms 2 paradigm + benchmark.

---

## 🔗 Liên kết

- **[F00 Trade-off thinking](../F00-mental-models/02-trade-off-thinking.md)** — meta framework cho pick
- **[F01 Big-O](../F01-cs-fundamentals/02-big-o-notation.md)** — perf measurement nền tảng
- **[F02/07 Pure functions](./07-pure-functions-immutability.md)** — FP deep
- **[F02/13 Design Patterns](./13-design-patterns.md)** — patterns chéo paradigm
- **[D17 Stream Processing](../../../year-2-specialization/semester-3-data-engineering-deep/D17-stream-processing/)** — Flink imperative vs Spark declarative
- **[D18 Spark](../../../year-2-specialization/semester-3-data-engineering-deep/D18-spark-distributed-compute/)** — Catalyst optimizer

---

## 🌐 Đọc thêm — refs cụ thể vào library  *(v3 — pointers chính xác)*

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **Krishnamurthi *Programming Languages: Application and Interpretation*** → `Krishnamurthi_PLAI_Brown.pdf` — Brown University textbook, free CC BY-NC-SA. **Bài đọc bắt buộc** Chapter 1 "Modeling Languages" + Chapter 6 "First-Class Functions".
- **UPenn lecture** → `UPenn_Programming-Paradigms-Lecture.pdf` — Jesús Fernández-Villaverde 6-paradigm overview.
- **arXiv 2025 FP vs OOP** → `arXiv-2508_FP-vs-OOP-Architectural.pdf` — empirical comparison của FP vs OOP cho architectural characteristics.

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **SICP (MIT)** → `Abelson-Sussman_SICP_MIT.pdf` Chapter 1.1 "The Elements of Programming" — classic intro to expressions vs procedures.

📖 **Sách commercial:**
- **Bruce Tate, *Seven Languages in Seven Weeks*** — paradigm tour qua 7 ngôn ngữ.
- **Peter Van Roy & Seif Haridi, *Concepts, Techniques, and Models of Computer Programming*** — paradigm bible (MIT Press).

📄 **Paper gốc + spec:**
- McCarthy (1960), *"Recursive Functions of Symbolic Expressions and Their Computation by Machine, Part I"* — LISP foundation.
- Codd (1970), *"A Relational Model of Data for Large Shared Data Banks"*, CACM — SQL declarative roots.
- Backus (1978), *"Can Programming Be Liberated from the von Neumann Style?"* — Turing lecture, FP manifesto.

---

**Đã đọc xong?**
✅ Tick → [F02/02 Static vs Dynamic typing](./02-static-vs-dynamic-typing.md).
