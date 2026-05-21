# KU F01 / 07 — Sorting algorithms: khi nào dùng cái nào

> **Sorting** là operation tốn 30-50% CPU trong analytics workload. Quicksort, Mergesort, Heapsort, Radix sort — mỗi cái thắng/thua khác nhau tuỳ data + memory + parallelism. Hiểu trade-off = pick sort algo + tune đúng.

**Module:** [F01 — CS Fundamentals](./README.md)
**Prereqs:** [F01/04 Hash table](./04-hash-table.md) · [F01/05 Tree](./05-tree-bst-btree.md)
**Related KUs:** [F01/08 Recursion](./08-recursion-iteration.md) · [F01/09 Complexity](./09-time-vs-space-complexity.md)
**Đọc trong:** ~12 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn cần **xếp 100 cuốn sách** theo thứ tự ABC trên kệ.

### Cách 1 — Bubble sort: "đổi cặp liên tục"
- So 2 cuốn cạnh nhau, ngược thứ tự → đổi chỗ.
- Lặp đến khi hết. **n² thao tác**. Chỉ làm khi n < 50.

### Cách 2 — Insertion sort: "chèn từng cuốn vào vị trí đúng"
- Cuốn 1 đặt riêng. Cuốn 2 chèn vào trước/sau cuốn 1.
- Cuốn 3 chèn vào vị trí đúng giữa 1-2. ...
- **n² worst case** nhưng **rất nhanh cho dữ liệu gần sorted**.

### Cách 3 — Mergesort: "chia 2 nửa, sắp riêng, gộp lại"
- Chia 100 cuốn thành 2 stack 50, mỗi stack chia tiếp 25, ..., 1 cuốn (đã sort).
- Gộp lại: 2 stack đã sort → 1 stack sorted (O(n) merge).
- **n log n guaranteed.** Cần memory phụ.

### Cách 4 — Quicksort: "chọn 1 cuốn làm pivot, đặt nhỏ trái lớn phải"
- Pick "S". Đặt cuốn < S sang trái, > S sang phải.
- Lặp cho 2 nửa.
- **Average n log n.** Worst n² (pivot dở).

### Cách 5 — Radix sort: "phân loại theo từng chữ cái"
- Cuốn bắt đầu bằng "A" → ngăn A. "B" → ngăn B. ...
- Sau đó sort trong từng ngăn theo chữ cái 2, 3...
- **O(n × k)** where k = key length. **Faster than n log n** cho data đặc biệt.

---

## 🧩 The Crux of the Problem  *(v3 — OSTEP-style framing)*

> **Core question:** Cho 1B records cần sort theo 1 column, làm sao **đảm bảo Θ(n log n) trong mọi trường hợp** + **stable** (giữ thứ tự cũ cho equal keys) + **in-place** (RAM hạn chế)?
>
> **Why hard:** Quicksort fast nhưng Θ(n²) worst-case + unstable. Mergesort Θ(n log n) guarantee + stable nhưng tốn Θ(n) extra memory. Heapsort in-place + Θ(n log n) nhưng cache-unfriendly + unstable. Không một algorithm thắng cả 3 trade-off.
>
> **What we need:** Hiểu **hybrid sort** — production code (Python TimSort, Java DualPivotQuicksort, Linux kernel) combine 2-3 algorithms để cover edge case. Pure textbook algorithm không bao giờ dùng raw trong production.

→ Lower bound **comparison-based sorting = Ω(n log n)** đã proven — không thuật toán nào beat điều này. Chỉ radix sort beat bằng cách **không so sánh** (dùng cấu trúc key).

---

## 📜 Lịch sử ngắn  *(v3 — etymology + invention)*

- **Hollerith sorting machine (1887)** — Herman Hollerith dùng punch card mechanical sort cho US census 1890. Phương pháp sau này được gọi là **radix sort**.
- **Bubble sort (1956)** — "bubble" do small elements nổi lên như bong bóng. Authors có lẽ là Friend (1956). Worst sort algorithm — dùng để dạy là chính.
- **Mergesort (1945)** — **John von Neumann** invent khi build EDVAC computer. Designed quanh tape storage limitation — sequential read, no random access.
- **Quicksort (1959-1961)** — **Tony Hoare** (British) phát minh ở Moscow khi học Russian, dùng để sort câu Russian dictionary. Là sorting algorithm nổi tiếng nhất + dạy nhiều nhất thế giới.
- **Heapsort (1964)** — **J.W.J. Williams**. Build trên binary heap data structure.
- **TimSort (2002)** — **Tim Peters** for CPython. Hybrid (mergesort + insertion sort) detect existing "runs" (sub-sequences đã sorted). Default sort trong Python, Java 7+, Android.
- **Pdqsort (2014)** — **Orson Peters**. Pattern-defeating quicksort, default trong Rust.
- **Today (2026):** TimSort thắng trong real workload vì real data thường partially sorted. Pure quicksort/mergesort = textbook.

---

## 🧮 Pseudocode — 5 algorithms classic  *(v3 — Erickson UIUC style)*

### Bubble sort (educational only)

```
BUBBLESORT(A[1..n]):
    for i ← 1 to n − 1
        for j ← 1 to n − i
            if A[j] > A[j+1] then
                SWAP(A[j], A[j+1])
```

### Insertion sort (good for small n, almost-sorted)

```
INSERTIONSORT(A[1..n]):
    for i ← 2 to n
        key ← A[i]
        j ← i − 1
        while j ≥ 1 and A[j] > key
            A[j+1] ← A[j]
            j ← j − 1
        A[j+1] ← key
```

### Mergesort

```
MERGESORT(A[1..n]):
    if n ≤ 1 then return A
    mid ← ⌊n/2⌋
    L ← MERGESORT(A[1..mid])
    R ← MERGESORT(A[mid+1..n])
    return MERGE(L, R)

MERGE(L, R):
    result ← EMPTY
    i ← 1; j ← 1
    while i ≤ length(L) and j ≤ length(R)
        if L[i] ≤ R[j] then
            APPEND(result, L[i]); i ← i + 1
        else
            APPEND(result, R[j]); j ← j + 1
    APPEND_ALL(result, L[i..]); APPEND_ALL(result, R[j..])
    return result
```

### Quicksort (Hoare partition)

```
QUICKSORT(A[lo..hi]):
    if lo < hi then
        p ← PARTITION(A, lo, hi)
        QUICKSORT(A[lo..p])
        QUICKSORT(A[p+1..hi])

PARTITION(A, lo, hi):
    pivot ← A[lo]                           《pivot choice critical》
    i ← lo − 1; j ← hi + 1
    loop
        repeat i ← i + 1 until A[i] ≥ pivot
        repeat j ← j − 1 until A[j] ≤ pivot
        if i ≥ j then return j
        SWAP(A[i], A[j])
```

### Heapsort

```
HEAPSORT(A[1..n]):
    BUILDHEAP(A)                            《Θ(n) — surprisingly not Θ(n log n)》
    for i ← n down to 2
        SWAP(A[1], A[i])
        SIFTDOWN(A[1..i−1], 1)
```

### TimSort (sketch — Python real algorithm)

```
TIMSORT(A[1..n]):
    runs ← DETECT_RUNS(A)                   《existing sorted/reverse sub-sequences》
    while runs has ≥ 2 elements
        《Merge runs satisfying invariant size(top) > size(top-1) + size(top-2)》
        MERGE_TOP_RUNS(runs)
    return A
```

---

## 📐 Recurrence equations  *(v3 — formal analysis)*

| Algorithm | Recurrence | Best | Avg | Worst | Note |
|---|---|---|---|---|---|
| Bubble sort | `T(n) = T(n−1) + Θ(n)` | Θ(n²) | Θ(n²) | Θ(n²) | early-exit can give Θ(n) on sorted |
| Insertion sort | `T(n) = T(n−1) + Θ(n)` | Θ(n) sorted input | Θ(n²) | Θ(n²) | thắng cho n < ~50 |
| Mergesort | `T(n) = 2·T(n/2) + Θ(n)` | Θ(n log n) | Θ(n log n) | Θ(n log n) | Master case 2 |
| Quicksort | `T(n) = T(n−1) + Θ(n)` worst (bad pivot) | Θ(n log n) | Θ(n log n) | Θ(n²) | random pivot expected Θ(n log n) |
| Quicksort balanced | `T(n) = 2·T(n/2) + Θ(n)` | Θ(n log n) | Θ(n log n) | Θ(n log n) | với random/median-of-three pivot |
| Heapsort | `T(n) = Θ(n) + n·Θ(log n)` | Θ(n log n) | Θ(n log n) | Θ(n log n) | build heap Θ(n), then n siftdowns |
| Radix sort | `T(n,k) = Θ(n · k)` | Θ(n·k) | Θ(n·k) | Θ(n·k) | k = key length, not comparison-based |
| TimSort | hybrid | Θ(n) ⚡ | Θ(n log n) | Θ(n log n) | best case = nearly sorted |

**Comparison-based lower bound proof:** Decision tree với n! leaves cần depth ≥ log₂(n!) = Θ(n log n) → **bất kỳ** comparison sort phải Ω(n log n) so sánh. CLRS Chapter 8 chứng minh hoàn chỉnh.

---

## 📊 Cost annotation table — 7 sorting algorithms  *(v3 — Sedgewick Princeton style)*

| Algorithm | Best | Avg | Worst | Space | Stable | In-place | Use case |
|---|---|---|---|---|:---:|:---:|---|
| Bubble sort | Θ(n) | Θ(n²) | Θ(n²) | Θ(1) | ✓ | ✓ | educational only |
| Selection sort | Θ(n²) | Θ(n²) | Θ(n²) | Θ(1) | ✗ | ✓ | minimal swaps |
| Insertion sort | Θ(n) | Θ(n²) | Θ(n²) | Θ(1) | ✓ | ✓ | small n, nearly sorted |
| Shell sort | Θ(n log n) | Θ(n^1.3) | Θ(n^1.5) | Θ(1) | ✗ | ✓ | embedded systems |
| **Mergesort** | Θ(n log n) | Θ(n log n) | Θ(n log n) | Θ(n) | ✓ ⚡ | ✗ | external sort (disk), stable required |
| **Quicksort** | Θ(n log n) | Θ(n log n) | Θ(n²) | Θ(log n) stack | ✗ | ✓ | general-purpose, cache-friendly |
| **Heapsort** | Θ(n log n) | Θ(n log n) | Θ(n log n) | Θ(1) ⚡ | ✗ | ✓ | hard real-time, worst-case guarantee |
| **TimSort** ⚡ | Θ(n) | Θ(n log n) | Θ(n log n) | Θ(n) | ✓ | ✗ | Python/Java default, real data |
| **Radix sort** | Θ(n·k) | Θ(n·k) | Θ(n·k) | Θ(n+k) | ✓ | ✗ | integer keys, GPU sort |

**Picking guide:**
- Python/Java `list.sort()` → already TimSort (don't reimplement)
- C++ `std::sort` → Introsort (quicksort + heapsort fallback)
- Rust `slice::sort` → Pdqsort
- Spark/Hadoop external sort 1TB on 16GB RAM → **Mergesort** + disk spill
- Sort 1B integer keys → **Radix sort** if range bounded
- Top-K only (k ≪ n) → **partial sort** via heap, Θ(n log k)

---

## ❌ Bad example / anti-pattern  *(v3 — "Martin's algorithm" style)*

### Anti-pattern 1 — Reimplement sort thay vì xài built-in

```python
# ❌ "Tôi tự implement quicksort cho nhanh hơn"
def my_quicksort(arr):
    if len(arr) <= 1: return arr
    pivot = arr[0]
    return my_quicksort([x for x in arr[1:] if x < pivot]) + [pivot] + my_quicksort([x for x in arr[1:] if x >= pivot])

# So với list.sort() = TimSort optimized C code
# my_quicksort 1M list: ~30 giây
# list.sort() 1M list: ~0.3 giây = 100× nhanh hơn
```

**Tại sao bad:** TimSort optimized C + detect runs + insertion sort tail + memory-efficient. Pure-Python quicksort tạo nhiều list temporary + recursion overhead. **Default to built-in.**

### Anti-pattern 2 — Quicksort với pivot là `A[0]` trên sorted input

```python
# ❌ pivot = first element trên sorted array
def bad_quicksort(arr):
    if len(arr) <= 1: return arr
    pivot = arr[0]
    less = [x for x in arr[1:] if x < pivot]
    greater = [x for x in arr[1:] if x >= pivot]
    return bad_quicksort(less) + [pivot] + bad_quicksort(greater)

# Input [1,2,3,...,1M] sorted → pivot luôn min → partition Θ(n) mỗi level → Θ(n²)
# 1M sorted → 10^12 ops → ~hours
```

**Tại sao bad:** Worst-case Θ(n²) là **deterministic** với pivot first-element + sorted input. Pick **random pivot** hoặc **median-of-three** để expected Θ(n log n).

### Anti-pattern 3 — Bubble sort production

```python
# ❌ Bubble sort cho 100K elements
def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(n - i - 1):
            if arr[j] > arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]
    return arr
# 100K elements = 10^10 ops = ~3 giờ
# TimSort = 100K · log 100K ≈ 1.7M ops = milliseconds
```

**Tại sao bad:** Θ(n²) trong tất cả case (best/avg/worst). Educational only.

### Anti-pattern 4 — Sort khi không cần

```sql
-- ❌ SELECT TOP 10 customers by revenue:
SELECT * FROM customers
ORDER BY revenue DESC
LIMIT 10;
-- Nếu Postgres không có index trên revenue → sort toàn bộ 100M rows → 30s
```

**Tại sao bad:** Top-K không cần full sort. Pick **heap of size K** = Θ(n log K) thay vì Θ(n log n). Postgres `LIMIT` với index DESC = Θ(K). **Index + LIMIT** giảm 30s → 10ms.

---

## 📖 Định nghĩa chính thức

**Sort** = arrange elements theo total order (defined by comparator).

**Stability** — equal-key elements giữ relative order? Stable: Mergesort, TimSort. Unstable: Quicksort, Heapsort.

**In-place** — sort không dùng O(n) extra memory. In-place: Heapsort, Quicksort. Not in-place: Mergesort.

**Comparison-based lower bound: O(n log n)** — proven theorem. Cannot beat. Radix sort beats by NOT comparing (uses key structure).

| Algorithm | Average | Worst | Space | Stable | In-place | Notes |
|---|---|---|---|:---:|:---:|---|
| Bubble sort | O(n²) | O(n²) | O(1) | ✓ | ✓ | Teaching only |
| Insertion sort | O(n²) | O(n²) | O(1) | ✓ | ✓ | Fast for small n, nearly sorted |
| Selection sort | O(n²) | O(n²) | O(1) | ✗ | ✓ | Min swaps |
| Mergesort | O(n log n) | O(n log n) | O(n) | ✓ | ✗ | Guaranteed, external sort |
| Quicksort | O(n log n) | O(n²) | O(log n) | ✗ | ✓ | Fast in practice, cache-friendly |
| Heapsort | O(n log n) | O(n log n) | O(1) | ✗ | ✓ | Guaranteed in-place |
| Radix sort | O(n × k) | O(n × k) | O(n + b) | ✓ | ✗ | Integers, fixed-length strings |
| Counting sort | O(n + k) | O(n + k) | O(k) | ✓ | ✗ | Small key range |
| TimSort | O(n log n) | O(n log n) | O(n) | ✓ | ✗ | Python, Java default — hybrid |

**Nguồn:**
- CLRS Chapters 7-8.
- "Programming Pearls" Bentley — quicksort optimization.
- TimSort by Tim Peters (Python `sorted()`).

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Sắp xếp | Sort | Arrange elements in order |
| So sánh | Comparison-based | Sort by comparing pairs |
| Stable | Stable sort | Equal-key elements keep original order |
| Tại chỗ | In-place | No extra O(n) memory |
| Pivot | Pivot | Quicksort chosen element |
| Partition | Partition | Divide around pivot |
| Merge | Merge | Combine 2 sorted arrays |
| Quicksort | Quicksort | Pivot-based recursive sort |
| Mergesort | Mergesort | Divide-and-conquer guaranteed |
| Heapsort | Heapsort | Use binary heap |
| Radix sort | Radix sort | Digit-by-digit, non-comparison |
| Counting sort | Counting sort | Use key count array |
| TimSort | TimSort | Hybrid Mergesort + Insertion (Python, Java) |
| Introsort | Introsort | Hybrid Quicksort + Heapsort (C++ std::sort) |
| External sort | External sort | Sort data larger than RAM (uses disk) |
| Tournament sort | Tournament sort | Multi-way merge using heap |
| Parallel sort | Parallel sort | Use multiple cores |

---

## 💡 Nó làm được gì?

- **ORDER BY** SQL — under the hood sort
- **GROUP BY** sort-based — pre-sort then aggregate
- **Sort-merge join** — sort both tables on key
- **Window functions** — sort by partition
- **Top-k** — partial sort
- **Median, percentile** — sort then index
- **Spark / Flink shuffle** — sort by key before sending

---

## 🚀 Nó giúp ích gì?

### Spark Sort-Merge Join

```
1. Sort both DataFrames by join key
2. Walk both sorted, match
Total: O((n + m) log (n + m))
```

vs Hash Join O(n + m) but needs memory cho hash table.

→ Spark choose between sort-merge vs broadcast vs shuffle hash based on size.

### Top-k query

```sql
SELECT * FROM events ORDER BY amount DESC LIMIT 10;
```

Naive: sort all n → O(n log n).
Better: heap of size k → O(n log k). Linear scan + maintain heap.

→ For k=10 on 1B rows: 10x faster than full sort.

### TimSort efficiency on real data

Python `sorted([3, 1, 4, 1, 5, 9, 2, 6])` uses TimSort:
- Detect existing runs (already sorted subsequences)
- Insertion sort for small runs
- Merge runs (Mergesort)

→ Most real-world data has structure → TimSort ~2-3x faster than vanilla Mergesort.

### External sort (data > RAM)

```
Sort 100GB data on 16GB RAM:
1. Read chunks 10GB, sort in memory (Quicksort), write to disk
2. 10 sorted runs on disk
3. Multi-way merge (10 → 1 via heap)
```

Used by Postgres `work_mem` overflow, Spark shuffle spill.

### Trong project DSX Air

| Op | Sort use |
|---|---|
| Flink window aggregate | Sort by event_time |
| Spark sort-merge join | Sort both sides |
| Iceberg compaction | Sort within partition |
| ClickHouse MergeTree | Sorted by primary key |
| Trino window function | Sort by partition |

→ Sort everywhere trong analytics.

---

## 🔧 Algorithms walkthrough

### Quicksort

```python
def quicksort(arr, lo=0, hi=None):
    if hi is None: hi = len(arr) - 1
    if lo >= hi: return
    pivot = arr[(lo + hi) // 2]
    i, j = lo, hi
    while i <= j:
        while arr[i] < pivot: i += 1
        while arr[j] > pivot: j -= 1
        if i <= j:
            arr[i], arr[j] = arr[j], arr[i]
            i += 1; j -= 1
    quicksort(arr, lo, j)
    quicksort(arr, i, hi)
```

→ Worst case O(n²) khi pivot luôn min/max. Fix: random pivot, median-of-3.

### Mergesort

```python
def mergesort(arr):
    if len(arr) <= 1: return arr
    mid = len(arr) // 2
    left = mergesort(arr[:mid])
    right = mergesort(arr[mid:])
    return merge(left, right)

def merge(a, b):
    result = []
    i = j = 0
    while i < len(a) and j < len(b):
        if a[i] <= b[j]: result.append(a[i]); i += 1
        else: result.append(b[j]); j += 1
    result.extend(a[i:]); result.extend(b[j:])
    return result
```

→ O(n log n) guaranteed. Stable. O(n) extra memory.

### Heapsort

```python
def heapsort(arr):
    n = len(arr)
    # Build max-heap
    for i in range(n//2 - 1, -1, -1):
        heapify(arr, n, i)
    # Extract max one-by-one
    for i in range(n-1, 0, -1):
        arr[0], arr[i] = arr[i], arr[0]
        heapify(arr, i, 0)
```

→ O(n log n) guaranteed. In-place. Not stable.

### Radix sort (LSD — Least Significant Digit)

```python
def radix_sort(arr, max_digits):
    for digit in range(max_digits):
        buckets = [[] for _ in range(10)]
        for x in arr:
            d = (x // 10**digit) % 10
            buckets[d].append(x)
        arr = [x for bucket in buckets for x in bucket]
    return arr
```

→ O(n × k). Faster than n log n cho integer/fixed-length keys.

---

## ⏰ Khi nào dùng cái nào?

| Workload | Best sort |
|---|---|
| Small array (< 50) | **Insertion sort** |
| General purpose | **TimSort** (Python) / **Introsort** (C++) / **Dual-pivot Quicksort** (Java) |
| Guaranteed worst case | **Heapsort** or **Mergesort** |
| Stable sort needed | **TimSort** or **Mergesort** |
| Integer with small range | **Counting sort** or **Radix sort** |
| External (data > RAM) | **External Mergesort** (multi-way) |
| Parallel | **Sample sort** (Spark/MapReduce shuffle) |
| Top-k | **Heap** O(n log k), not full sort |
| Nearly sorted | **Insertion sort** O(n) best, **TimSort** detect runs |

---

## ⚠️ Common pitfalls

### Pitfall 1 — Quicksort sorted input

❌ **Sai:** Quicksort `[1,2,3,...,n]` với first-element pivot → O(n²).

✅ **Đúng:** Random pivot or median-of-3.

### Pitfall 2 — Heap sort cache unfriendly

❌ **Sai:** "Heapsort guaranteed O(n log n), always pick it."

✅ **Đúng:** Heapsort cache-unfriendly (random access). Quicksort/TimSort faster in practice on modern CPUs.

### Pitfall 3 — Sort entire dataset cho top-k

❌ **Sai:** `sorted(data, reverse=True)[:10]` cho top-10 từ 1M items → O(n log n).

✅ **Đúng:** `heapq.nlargest(10, data)` → O(n log 10).

### Pitfall 4 — Compare floats with ==

❌ **Sai:** Sort floats then `sorted_arr[i] == target` → may miss due to precision.

✅ **Đúng:** `abs(a - b) < epsilon`. See [F01/14 Floating point](./14-floating-point.md).

---

## 🌱 Advanced topics

### A1. External sort (Postgres, Spark)

When data > RAM:
1. Split into chunks fitting RAM
2. Sort each chunk (Quicksort), write to disk as "run"
3. K-way merge runs using min-heap → final sorted output

Postgres uses this when `ORDER BY` exceeds `work_mem`.

### A2. Parallel sort

**Sample sort** (used in MapReduce, Spark):
1. Sample data → pick pivots → divide range
2. Each worker sorts its partition locally
3. Merge partitions (already sorted by pivot range)

→ O(n log n / p) with p workers.

### A3. TimSort details

Tim Peters 2002. Detects "runs" (already sorted subsequences).
- Minimum run length: 32-64 (binary insertion sort)
- Galloping mode for merging when 1 run dominates
- Stable

Used in Python `sorted()`, Java `Arrays.sort()` for objects.

### A4. Apply cho LLM 2026

- **Beam search** in decoding = top-k sort at each step
- **Vector search rerank** = sort by similarity score
- **Cache eviction** = sort by recency (LRU)

---

## 🔗 Liên kết

- **[F01/04 Hash table](./04-hash-table.md)** — alternative for groupby
- **[F01/05 Tree](./05-tree-bst-btree.md)** — heap-based sort
- **[F01/08 Recursion](./08-recursion-iteration.md)** — divide-and-conquer
- **[F01/09 Complexity](./09-time-vs-space-complexity.md)** — sort lower bound proof

---

## 🧠 Self-test

### 🟢 Easy
1. Comparison-based sort lower bound là gì? Vì sao Radix sort beat?
2. Quicksort average vs worst complexity?
3. Stable sort là gì? Cho 1 stable + 1 unstable algorithm.

### 🟡 Medium
4. Top-k từ 1B items với k=10: dùng full sort vs heap, complexity?
5. TimSort detect "runs" — vì sao thắng vanilla Mergesort cho real-world data?
6. External sort khi data 100GB > RAM 16GB: workflow?

### 🔴 Hard
7. Sort-merge join vs Hash join: trade-off memory + I/O?
8. Spark sample sort cho 1TB across 100 workers: complexity? Communication cost?
9. Why Java prefers dual-pivot Quicksort over Introsort?

---

## 📌 Trong repo

- **Flink window aggregate** — sort by event_time: [`docs/08-stream-processing.md`](../../../../docs/08-stream-processing.md)
- **Iceberg compaction** — sort within partition: [`lakehouse/sql/`](../../../../lakehouse/)
- **ClickHouse MergeTree** = primary key sort: [`docs/11-serving-layer.md`](../../../../docs/11-serving-layer.md)

---

## 🌐 Đọc thêm — refs cụ thể vào library  *(v3 — pointers chính xác)*

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **Sedgewick Princeton slides** → 4 PDFs trực tiếp:
  - `Sedgewick_Princeton_ElementarySorts.pdf` — bubble/selection/insertion/shell
  - `Sedgewick_Princeton_Mergesort.pdf` — visualization + bottom-up vs top-down
  - `Sedgewick_Princeton_Quicksort.pdf` — partition + 3-way + median-of-three
  - `Sedgewick_Princeton_PriorityQueues.pdf` — heap + heapsort
- **Erickson Algorithms (UIUC)** → `Erickson_2019_Algorithms_UIUC.pdf` Chapter 1 (Recursion: mergesort, quicksort, selection in worst-case linear time).
- **Open Data Structures (Morin)** → `Morin_OpenDataStructures_python.pdf` Chapter 11 (Sorting Algorithms — mergesort, quicksort, heapsort, comparison-based lower bound).

📖 **Sách commercial:**
- CLRS Chapter 6-8 — heap, heapsort, quicksort, comparison lower bound proof.
- Sedgewick & Wayne, *Algorithms 4e* — companion book của các slides Princeton.

📄 **Paper gốc + spec:**
- Hoare (1961), *"Algorithm 64: Quicksort"*, CACM. [DOI 10.1145/366622.366644](https://doi.org/10.1145/366622.366644) — bài báo gốc.
- Williams (1964), *"Algorithm 232: Heapsort"*, CACM.
- Peters (2002), [*"TimSort spec"*](https://github.com/python/cpython/blob/main/Objects/listsort.txt) — CPython official.
- Peters O. (2014), *"pdqsort"* — Rust default sort.

**Đã đọc xong?**
✅ Tick → [F01/08 Recursion + iteration](./08-recursion-iteration.md).
