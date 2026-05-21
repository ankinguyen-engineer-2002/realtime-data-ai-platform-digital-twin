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

**Đã đọc xong?**
✅ Tick → [F01/10 Compression basics](./10-compression-basics.md).
