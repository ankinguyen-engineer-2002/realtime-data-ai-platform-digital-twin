# KU F01 / 09 — Time vs Space complexity: trade-off math

> Algorithm có 2 chi phí: **thời gian** (operations) và **không gian** (memory). Senior pick trade-off đúng — không cùng minimize cả 2. Đây là **applied Big-O** với explicit cost analysis.

**Module:** [F01 — CS Fundamentals](./README.md)
**Prereqs:** [F01/02 Big-O](./02-big-o-notation.md) · [F01/08 Recursion](./08-recursion-iteration.md)
**Related KUs:** [F01/18 Complexity classes](./18-complexity-classes.md) · [F00/12 Trade-off triangle](../F00-mental-models/12-trade-off-triangle.md)
**Đọc trong:** ~10 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn nướng **100 cái bánh**. 2 cách:

### Cách 1 — Time-optimized (parallel với nhiều khay)
- Dùng **10 khay**, mỗi khay 10 bánh. Nướng cùng lúc trong 10 lò.
- **Thời gian:** 30 phút (1 mẻ).
- **Space:** 10 khay + 10 lò = đắt + tốn chỗ.

### Cách 2 — Space-optimized (1 khay nhỏ)
- Dùng **1 khay 10 bánh**. Nướng 10 mẻ.
- **Thời gian:** 30 phút × 10 = 300 phút (5 giờ).
- **Space:** 1 khay + 1 lò = tiết kiệm.

→ **Cùng output (100 bánh), 10x time vs 10x space.** Trade-off.

Trong code:
- **Memoization** trades space (cache) for time (avoid recompute)
- **Streaming** trades time (sequential) for space (no full load)
- **Compression** trades CPU (decompress) for storage
- **Index** trades storage (index file) for query time

---

## 🧩 The Crux of the Problem  *(v3 — OSTEP-style framing)*

> **Core question:** Mọi algorithm có 2 chi phí (time + space). Cho 1 vấn đề, làm sao **biết khi nào** chấp nhận tăng memory để giảm CPU, và khi nào ngược lại?
>
> **Why hard:** Junior nhìn Big-O time một mình → pick "nhanh nhất" → OOM production. Senior nhìn cả time + space + cache hierarchy. Memory thường **không miễn phí**: K8s container có limit, GPU VRAM ~80GB max, CPU cache 32KB/L1.
>
> **What we need:** Hiểu **trade-off principle** + **approximate data structures** (Bloom filter, HyperLogLog, Count-Min) để có "good enough" trong memory budget hạn chế.

→ Sketch data structures = sản phẩm của trade-off thinking — chấp nhận ~2% error để tiết kiệm 1000× memory.

---

## 📜 Lịch sử ngắn  *(v3 — etymology + invention)*

- **Space-time trade-off** lần đầu chính thức hoá bởi **Michael Fischer** (1972) trong context of automata theory.
- **Bloom filter (1970)** — **Burton Howard Bloom** (MIT) — *"Space/Time Trade-offs in Hash Coding with Allowable Errors"* — set membership với false positive trade for memory.
- **Memoization (1968)** — **Donald Michie** (Edinburgh) coined term *memo* = "function that remembers". Vehicle cho dynamic programming.
- **HyperLogLog (2007)** — **Philippe Flajolet et al.** (INRIA Paris) — count distinct với KB memory thay vì GB. Today: Redis HLL, ClickHouse uniq estimators, Druid count-distinct.
- **Count-Min sketch (2005)** — **Cormode & Muthukrishnan** — approximate frequency in small memory.
- **External-memory algorithms** — **Aggarwal & Vitter (1988)** formalize I/O complexity model — count disk I/O thay vì CPU ops. Today: Spark/Hadoop shuffle design dùng model này.
- **Today (2026):** Sketch data structures là backbone của observability (Prometheus, Datadog), real-time analytics (Druid, ClickHouse), DNS analytics (Cloudflare HLL).

---

## 📊 Cost annotation table — space-time trade-offs  *(v3 — practical guide)*

| Need | Pick | Trade for |
|---|---|---|
| Fast lookup by key | Hash table | More memory (load factor + bucket array) |
| Tight memory + ordered | Sorted array binary search | Slower insert (Θ(n) shift) |
| Faster query | B-tree index | Storage (~30% of table) + slower insert |
| Tighter storage | Compression (Zstd/Snappy) | CPU on decompress |
| Process > RAM size | External sort + Spark | Disk I/O = 10-100× slower than RAM |
| Approximate distinct count | HyperLogLog (KB memory) | ~2% error |
| Approximate membership | Bloom filter (bit array) | False positive ~1% with ~10 bits/element |
| Approximate frequency | Count-Min sketch | Over-estimate bias |
| Approximate percentile | t-digest, GK-sketch | <1% error |
| Approximate similarity | MinHash, LSH | ~5% error |
| Cache for repeated compute | Memoization | Memory grows with unique input space |

**Sketch data structures used in real systems:**

| Structure | Memory | Error | Used in |
|---|---|---|---|
| **Bloom filter** | ~10 bits / element | 1% FP | RocksDB, Cassandra, Bitcoin SPV |
| **HyperLogLog** | ~12 KB for any n | <2% error | Redis HLL, ClickHouse, Druid, GCP BigQuery |
| **Count-Min** | Θ(1/ε · log 1/δ) | (ε, δ)-bounded | AT&T traffic analysis |
| **t-digest** | ~few KB | <1% percentile error | Datadog, Apache Druid |
| **MinHash / LSH** | k · sizeof(hash) | tunable | Plagiarism detection, deduplication |

---

## ❌ Bad example / anti-pattern  *(v3 — "Martin's algorithm" style)*

### Anti-pattern 1 — Memoize unbounded → OOM

```python
# ❌ Memoize fibonacci nhưng không bound cache size
memo = {}
def fib(n):
    if n in memo: return memo[n]
    if n <= 1: return n
    memo[n] = fib(n-1) + fib(n-2)
    return memo[n]
# Loop with user input n → memo grows forever → OOM
```

**Tại sao bad:** Memoization trades **bounded** memory for time. Unbounded memo = memory leak. Pick `functools.lru_cache(maxsize=10_000)` — LRU eviction.

### Anti-pattern 2 — HyperLogLog cho billing

```python
# ❌ Use HLL cho count distinct users → billing
distinct_users = redis.pfcount('users:active')
bill = distinct_users * 0.001
# HLL có ~2% error → có thể bill thiếu $thousands hoặc thừa khiến complain
```

**Tại sao bad:** Approximate OK cho analytics dashboard, **KHÔNG OK** cho transactions / billing / counts that must be exact. Pick `SET` (Θ(n) memory) hoặc audit log nếu exact required.

### Anti-pattern 3 — Premature space optimization

```c
// ❌ Bit-pack 8 booleans vào 1 byte cho "save memory"
typedef struct { uint8_t flags; } UserFlags;
#define IS_ADMIN(u) ((u)->flags & 0x01)
#define IS_VERIFIED(u) (((u)->flags & 0x02) >> 1)
// ...

// Cho user struct 100 bytes, 8 booleans = 8 bytes
// Tiết kiệm 7 bytes = 7% memory
// Trade for: code phức tạp, bug risk, debug khó
```

**Tại sao bad:** 7 bytes / 100 bytes = 7% memory trade-off cho code complexity 10×. Premature optimization (KU F00/10). Pick rõ ràng — chỉ bit-pack khi struct chiếm > 50% memory budget.

### Anti-pattern 4 — Brute force "scale by RAM"

```
"Sort 1TB? Buy 1TB RAM."
"Process 100B rows? Spark cluster 100 nodes RAM."
```

**Tại sao bad:** RAM cost ~$5/GB cloud monthly = $5K/TB/month. Disk ~$0.05/GB = $50/TB. **External-memory algorithms** (Spark shuffle, mergesort) handle TB data với GB RAM. Aggarwal-Vitter EM model = senior knowledge.

---

## 📖 Định nghĩa chính thức

**Time complexity** = số operations as function of n.

**Space complexity** = memory used as function of n.

3 components of space:
1. **Input space** — data itself, thường không count
2. **Auxiliary space** — temporary memory algorithm uses
3. **Output space** — result memory

**Big-O usually means time** unless explicit "space O(...)".

**Trade-off principle:** Most algorithms have inverse time-space trade-off:
- More memory → faster (cache, lookup tables)
- Less memory → slower (recompute, scan)

**Nguồn:**
- CLRS Chapter 3.
- "Mythical Man-Month" Brooks — trade-off in engineering.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Time complexity | Time complexity | Operations as function of n |
| Space complexity | Space complexity | Memory as function of n |
| Auxiliary space | Auxiliary space | Extra memory beyond input |
| Memoization | Memoization | Cache results (space cost) |
| Dynamic programming | Dynamic programming | Iterative memo |
| Trade-off | Trade-off | Improve A by sacrificing B |
| In-place | In-place | O(1) auxiliary space |
| External memory | External memory | Disk, slower but larger |
| Streaming | Streaming | Process without full load |
| Online algorithm | Online algorithm | Process data incrementally |
| Offline algorithm | Offline algorithm | Need all data first |
| Approximate algorithm | Approximate | Trade accuracy for time/space |
| Bloom filter | Bloom filter | Probabilistic membership (space win) |
| HyperLogLog | HyperLogLog | Probabilistic count distinct |
| Count-Min sketch | Count-Min sketch | Probabilistic frequency |

---

## 🚀 Real-world trade-offs

### Memoization — space for time

Fibonacci naive O(2^n) time, O(n) space.
Memoized: O(n) time, O(n) space.
Iterative O(1) space: O(n) time, O(1) space.

→ Picking version based on n + memory budget.

### Index — storage for query speed

Postgres B-tree index:
- **Storage:** ~10-30% of table size
- **Query time:** O(n) → O(log n)
- **Insert time:** O(1) → O(log n) (update index)

→ Trade insert speed + storage for query speed.

### Compression — CPU for storage

Parquet column compression:
- Snappy: 5x compression, 500MB/s decompress
- Zstd: 8x compression, 200MB/s decompress
- LZ4: 4x compression, 1GB/s decompress

→ Trade decompress CPU for storage.

### Streaming — time for space

Sort 1TB on 16GB RAM:
- **Full load:** impossible (out of memory)
- **External sort:** disk I/O, 10-100x slower than RAM sort

→ Trade time for ability to handle larger-than-memory.

### Approximate data structures

| Structure | Trades |
|---|---|
| **Bloom filter** | Approximation (false positive) for 100x less memory |
| **HyperLogLog** | ~2% error for count distinct in KB instead of GB |
| **Count-Min sketch** | Approximate frequency in small memory |
| **t-digest** | Approximate percentile |
| **MinHash / LSH** | Approximate similarity |

→ Used in Druid, ClickHouse, Datadog for ingestion-time aggregation.

---

## 🔧 Common patterns

### Pattern 1: Time-space trade-off

| Need | Trade for |
|---|---|
| Fast lookup | Hash table (more memory) |
| Small memory | Slower scan |
| Faster query | Index (storage cost) |
| Tighter storage | Compression (CPU cost) |
| Larger than RAM | External + slower |
| Real-time + approximate | Sketch data structures |

### Pattern 2: Calculating both T and S

```python
# Sum of array
def sum_arr(arr):
    total = 0
    for x in arr:
        total += x
    return total

# Time: O(n)
# Space: O(1) auxiliary
```

```python
# Mergesort
# Time: O(n log n)
# Space: O(n) auxiliary (merge array)
```

```python
# Recursion factorial
def fact(n):
    if n <= 1: return 1
    return n * fact(n - 1)

# Time: O(n)
# Space: O(n) call stack
```

```python
# Iterative factorial
def fact(n):
    r = 1
    for i in range(2, n+1): r *= i
    return r

# Time: O(n)
# Space: O(1)
```

---

## ⚠️ Common pitfalls

### Pitfall 1 — Forget space cost

❌ Pick algorithm O(n log n) time. Forget it uses O(n) extra memory. OOM in production.

✅ Always state **time + space** for production decisions.

### Pitfall 2 — Premature space optimization

❌ Use complex bit manipulation to save bytes when memory abundant.

✅ Pick clarity unless space measurably costly.

### Pitfall 3 — Approximate without measure error

❌ Use HyperLogLog blindly for billing → wrong count → revenue loss.

✅ Approximate OK for analytics, NOT for transactions.

### Pitfall 4 — Cache without eviction

❌ Memoize unbounded → memory grows → OOM.

✅ LRU cache with size limit. `functools.lru_cache(maxsize=1000)`.

---

## 🌱 Advanced topics

### A1. PRAM model — parallel time-space

Time × processors = work. Speedup limited by Amdahl's Law.

### A2. Locality of reference

CPU caches reward time-locality (recent access) + space-locality (nearby access). Big-O doesn't capture this.

### A3. Energy complexity (2026 emerging)

Energy = time × processor power. Mobile + sustainability concerns.

### A4. Apply cho LLM 2026

- **KV cache** trades GPU memory for repeated computation
- **Quantization** trades accuracy for memory + speed
- **Speculative decoding** trades extra compute for latency

---

## 🧠 Self-test

1. Time vs space — give 3 examples each from data engineering.
2. Memoization trades what for what?
3. Bloom filter saves how much memory vs Python set?
4. Postgres index: storage cost trade for query time benefit, quantify ratio.
5. External sort: trade time for what?
6. HyperLogLog: when acceptable, when not?

---

## 🔗 Liên kết

- **[F01/02 Big-O](./02-big-o-notation.md)** — foundation
- **[F01/08 Recursion](./08-recursion-iteration.md)** — call stack = space
- **[F01/10 Compression](./10-compression-basics.md)** — CPU/storage trade
- **[F00/12 Trade-off triangle](../F00-mental-models/12-trade-off-triangle.md)** — speed/cost/quality

---

## 🌐 Đọc thêm — refs cụ thể vào library  *(v3 — pointers chính xác)*

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **Erickson Algorithms (UIUC)** → `Erickson_2019_Algorithms_UIUC.pdf` — chapters on dynamic programming (memoization), randomized algorithms (sketches).
- **OSTEP (Wisconsin)** → `OSTEP_vm-paging.pdf`, `OSTEP_vm-beyondphys.pdf` — memory hierarchy (RAM vs disk swap) ảnh hưởng space complexity.
- **Open Data Structures (Morin)** → `Morin_OpenDataStructures_python.pdf` Chapter 4 — Skiplists (probabilistic data structure trade-off).

📖 **Sách commercial:**
- CLRS Chapter 3 — Growth of Functions (time + space analysis foundation).
- Petrov, *Database Internals* — chapter on external sort + B-tree page management.

📄 **Paper gốc:**
- Bloom (1970), *"Space/Time Trade-offs in Hash Coding with Allowable Errors"*, CACM. [DOI 10.1145/362686.362692](https://doi.org/10.1145/362686.362692).
- Flajolet et al. (2007), *"HyperLogLog: the analysis of a near-optimal cardinality estimation algorithm"*, AofA.
- Cormode & Muthukrishnan (2005), *"An Improved Data Stream Summary: The Count-Min Sketch and its Applications"*.
- Aggarwal & Vitter (1988), *"The Input/Output Complexity of Sorting and Related Problems"*, CACM — EM model foundation.

---

**Đã đọc xong?**
✅ Tick → [F01/10 Compression basics](./10-compression-basics.md).
