# KU F01 / 08 — Recursion + iteration: 2 cách "lặp"

> **Recursion** (đệ quy) và **iteration** (lặp) là 2 cách diễn đạt thuật toán. Mỗi cái có chỗ thắng/thua. Hiểu trade-off + biết convert qua lại = senior skill. Đặc biệt: recursion can blow stack, iteration không.

**Module:** [F01 — CS Fundamentals](./README.md)
**Prereqs:** [F01/07 Sorting](./07-sorting-algorithms.md)
**Related KUs:** [F01/09 Complexity](./09-time-vs-space-complexity.md) · [F01/05 Tree](./05-tree-bst-btree.md)
**Đọc trong:** ~10 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn cần **gọt 100 quả táo**:

### Iteration (vòng lặp)
```
Đặt rổ táo bên cạnh.
While còn táo:
    lấy 1 quả → gọt → bỏ vào rổ kết quả.
```
- Tuyến tính, đơn giản, ít memory.

### Recursion (đệ quy)
```
gọt_rổ(rổ_táo):
    if rổ_táo empty: return []
    lấy 1 quả ra → gọt nó
    return [gọt_đó] + gọt_rổ(rổ còn lại)
```
- "Tự gọi mình" với rổ nhỏ hơn.
- Mỗi call **đẩy vào call stack** — memory grows.
- 100 quả → 100 levels stack → OK. 1M quả → stack overflow ❌.

**Cả 2 giải cùng vấn đề** — chỉ khác cách diễn đạt. Quy tắc:

- **Recursion** đẹp khi vấn đề **tự nhiên đệ quy** (tree, divide-and-conquer, fractal).
- **Iteration** an toàn khi data lớn (no stack overflow).
- Mọi recursion có thể convert sang iteration (explicit stack).

---

## 🧩 The Crux of the Problem  *(v3 — OSTEP-style framing)*

> **Core question:** Cho 1 bài toán có cấu trúc tự nhiên đệ quy (tree, fractal, divide-and-conquer), khi nào dùng recursion + khi nào iteration + khi nào BẮT BUỘC convert?
>
> **Why hard:** Recursion đọc tự nhiên nhưng tiêu thụ **call stack** — mỗi level = 1 stack frame ~500B. Python default `sys.setrecursionlimit(1000)` → quá 1000 levels = `RecursionError`. Iteration không có giới hạn này nhưng code khó hiểu khi vấn đề bản chất đệ quy.
>
> **What we need:** Biết **stack space** thực sự dùng (call stack vs heap), **tail call optimization** (TCO) ngôn ngữ nào hỗ trợ, và khi nào convert recursion → iteration bắt buộc (large n, no TCO).

→ **Python KHÔNG có TCO** (Guido từ chối, 2009). Java cũng không. Scheme/Scala/Haskell có. Biết điều này = không viết code sập production.

---

## 📜 Lịch sử ngắn  *(v3 — etymology + invention)*

- **Recursion theory (1937)** — **Alan Turing** trong paper *"On Computable Numbers"* dùng recursion làm core của Turing machine. Đồng thời **Kurt Gödel** + **Alonzo Church** (lambda calculus 1936) dùng recursion làm foundation toán học.
- **Tên "recursion"** từ Latin *recurrere* = "chạy ngược lại". Bookman quote nổi tiếng: *"To understand recursion, you must first understand recursion"*.
- **LISP (1958)** — **John McCarthy** (MIT) — programming language đầu tiên support recursion thật + first-class function. Trước LISP, FORTRAN không support recursion.
- **Tail call optimization (TCO)** — Scheme R5RS standard (1998) **bắt buộc** TCO. Guido van Rossum 2009 từ chối thêm TCO vào Python với 4 lý do: debugging stack trace, simplicity, performance, dynamic typing.
- **Today (2026):** Recursion ubiquitous (parser, AST, JSON traversal, file system walk, MCTS) nhưng production code thường convert sang iteration cho large n.

---

## 🧮 Pseudocode — 3 paradigm conversion  *(v3 — Erickson UIUC style)*

### Factorial — recursion vs iteration vs tail-recursion

```
FACT_REC(n):                    《O(n) time, O(n) call stack》
    if n ≤ 1 then return 1
    return n × FACT_REC(n − 1)

FACT_ITER(n):                   《O(n) time, O(1) space》
    result ← 1
    for i ← 2 to n
        result ← result × i
    return result

FACT_TAIL_REC(n, acc):          《tail-recursive — Scheme/Erlang optimize》
    if n ≤ 1 then return acc
    return FACT_TAIL_REC(n − 1, acc × n)
```

### Fibonacci 3 ways

```
FIB_NAIVE(n):                   《Θ(φ^n) ≈ Θ(2^n) — terrible》
    if n ≤ 1 then return n
    return FIB_NAIVE(n − 1) + FIB_NAIVE(n − 2)

FIB_MEMO(n, memo):              《Θ(n) — top-down DP》
    if n ≤ 1 then return n
    if memo[n] ≠ NIL then return memo[n]
    memo[n] ← FIB_MEMO(n − 1, memo) + FIB_MEMO(n − 2, memo)
    return memo[n]

FIB_ITER(n):                    《Θ(n) time, Θ(1) space — bottom-up DP》
    a ← 0; b ← 1
    for i ← 2 to n
        c ← a + b; a ← b; b ← c
    return b
```

### DFS recursion → iteration (explicit stack)

```
DFS_REC(node):                  《O(depth) call stack》
    if node = NIL then return
    PROCESS(node)
    for each child of node
        DFS_REC(child)

DFS_ITER(node):                 《O(depth) heap stack — controllable》
    stack ← NEW_STACK()
    PUSH(stack, node)
    while stack is not empty
        n ← POP(stack)
        PROCESS(n)
        for each child of n
            PUSH(stack, child)
```

→ **Same complexity, memory location khác.** Heap stack = explicit + size có thể tự control.

---

## 📐 Recurrence equations — 7 patterns canonical  *(v3 — formal analysis)*

| Pattern | Recurrence | Solution | Example |
|---|---|---|---|
| Linear | `T(n) = T(n−1) + Θ(1)` | Θ(n) | factorial, sum |
| Linear with work | `T(n) = T(n−1) + Θ(n)` | Θ(n²) | naive selection sort |
| Halving | `T(n) = T(n/2) + Θ(1)` | Θ(log n) | binary search |
| Halving with merge | `T(n) = 2T(n/2) + Θ(n)` | Θ(n log n) | mergesort |
| Halving with quadratic | `T(n) = 2T(n/2) + Θ(n²)` | Θ(n²) | naive divide-conquer |
| Naive two-way | `T(n) = T(n−1) + T(n−2)` | Θ(φⁿ) | naive Fibonacci |
| Ackermann-style | nested | hyper-exponential | Ackermann |

**Substitution method** cho non-Master recurrence:
```
T(n) = T(n − 1) + n
     = T(n − 2) + (n − 1) + n
     = T(0) + 1 + 2 + ... + n
     = Θ(n²)
```

→ Erickson Algorithms Chapter 1 dành 50 trang chi tiết về recurrence solving techniques.

---

## ❌ Bad example / anti-pattern  *(v3 — "Martin's algorithm" style)*

### Anti-pattern 1 — Recursion không có base case

```python
# ❌ Forget base case
def fact(n):
    return n * fact(n - 1)
# fact(5) → fact(4) → ... → fact(0) → fact(-1) → RecursionError
```

**Tại sao bad:** Base case = invariant của recursion. Quên = infinite loop → stack overflow.

### Anti-pattern 2 — Naive recursion cho overlapping subproblems

```python
# ❌ Fibonacci naive cho n=50
def fib(n):
    if n <= 1: return n
    return fib(n-1) + fib(n-2)
# fib(50) ≈ 1.5 phút (1.25 tỷ calls)
# fib(40) ≈ 3 giây
# Mỗi +10 → ×10 chậm
```

**Tại sao bad:** `fib(40)` được tính ~165M lần qua các nhánh khác nhau. Pick **memoization** (top-down DP) hoặc **iteration** (bottom-up DP) → Θ(n).

### Anti-pattern 3 — Python recursion depth 100K

```python
# ❌ Walk linked list 100K nodes by recursion
def length(node):
    if node is None: return 0
    return 1 + length(node.next)
# n=2000 → RecursionError (Python default limit 1000)
# sys.setrecursionlimit(100_000)?
# → still bad: 100K stack frames × ~500B = 50MB stack → segfault interpreter
```

**Tại sao bad:** Stack growth không tự release. Pick **iteration** với explicit loop.

### Anti-pattern 4 — Đặt cược vào TCO trong Python/Java

```python
# ❌ "Python sẽ optimize tail call"
def sum_tail(arr, i, acc):
    if i >= len(arr): return acc
    return sum_tail(arr, i + 1, acc + arr[i])
# arr 1M elements → RecursionError. Python KHÔNG TCO.
```

**Tại sao bad:** TCO là **language-specific**. Python/Java không có. Scheme/Erlang/Scala/Haskell có. Senior biết → quyết định đúng.

---

## 📖 Định nghĩa chính thức

**Recursion** — function calls itself với input nhỏ hơn, base case dừng.

Components:
1. **Base case** — input nhỏ nhất, không recurse.
2. **Recursive case** — break problem → smaller subproblems → call self.
3. **Combine** — combine subproblem results.

**Iteration** — repeat block via loop (`while`, `for`).

**Tail recursion** — recursive call là statement cuối cùng. Compiler có thể optimize → no stack growth.

**Mutual recursion** — A calls B, B calls A.

**Nguồn:**
- CLRS Chapters 2-4 (recursive algorithms).
- "Structure and Interpretation of Computer Programs" (SICP) — recursion deep.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Đệ quy | Recursion | Function calls itself |
| Lặp | Iteration | Loop construct (while, for) |
| Base case | Base case | Stopping condition của recursion |
| Recursive case | Recursive case | Smaller subproblem |
| Tail recursion | Tail recursion | Recursive call là statement cuối |
| Tail call optimization | TCO | Compiler optimize tail recursion thành loop |
| Stack overflow | Stack overflow | Stack memory exhausted |
| Mutual recursion | Mutual recursion | A → B → A |
| Memoization | Memoization | Cache recursive results (top-down DP) |
| Dynamic programming | Dynamic programming | Bottom-up iterative with memo |
| Call stack | Call stack | Memory area for function calls |
| Stack frame | Stack frame | Per-call data on stack |
| Divide and conquer | Divide and conquer | Recursion pattern |
| Backtracking | Backtracking | Recursion + undo |
| Recursive data type | Recursive data type | Self-referential structure (tree, list) |

---

## 💡 Khi dùng cái nào

### Use recursion when:
- Problem **tự nhiên recursive**: tree traversal, fractal, divide-and-conquer
- Code **đẹp hơn** iteration (tree DFS recursive vs explicit stack)
- Data có **bounded depth** (log n typical)

### Use iteration when:
- Data có thể lớn (> 1000 depth)
- Performance critical (no function call overhead)
- Sequential simple loop

---

## 🧪 Examples

### Factorial

```python
# Recursive
def fact_r(n):
    if n <= 1: return 1                    # base
    return n * fact_r(n - 1)                # recursive

# Iterative
def fact_i(n):
    result = 1
    for i in range(2, n + 1):
        result *= i
    return result

# Tail recursive (Python doesn't optimize, but conceptually)
def fact_t(n, acc=1):
    if n <= 1: return acc
    return fact_t(n - 1, n * acc)           # tail call
```

### Fibonacci — recursion trap

```python
# Naive recursion: O(2^n) → catastrophic
def fib_naive(n):
    if n < 2: return n
    return fib_naive(n - 1) + fib_naive(n - 2)
# fib_naive(50) takes years

# Memoized: O(n)
from functools import lru_cache
@lru_cache(maxsize=None)
def fib_memo(n):
    if n < 2: return n
    return fib_memo(n - 1) + fib_memo(n - 2)

# Iterative: O(n), O(1) space
def fib_iter(n):
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a
```

→ Recursion **without memoization** for overlapping subproblems = exponential.

### Tree DFS — recursion shines

```python
def tree_sum(node):
    if node is None: return 0
    return node.value + tree_sum(node.left) + tree_sum(node.right)
```

→ Mỗi node O(1) work. Total O(n). Stack depth = tree height O(log n) for balanced.

### Iterative DFS via explicit stack

```python
def tree_sum_iter(root):
    if root is None: return 0
    total = 0
    stack = [root]
    while stack:
        node = stack.pop()
        total += node.value
        if node.left: stack.append(node.left)
        if node.right: stack.append(node.right)
    return total
```

→ Same complexity, no stack overflow risk for deep tree.

---

## ⚠️ Common pitfalls

### Pitfall 1 — Stack overflow trên deep recursion

❌ `def descend(n): return descend(n-1) if n > 0 else 0` for `descend(100000)` → stack overflow.

✅ Convert to iteration, or increase `sys.setrecursionlimit()` (Python).

### Pitfall 2 — Fibonacci naive

❌ `fib(50)` exponential → years.

✅ Memoize hoặc iterative.

### Pitfall 3 — Python không TCO

❌ Tail recursion in Python = still stack growth.

✅ Convert tail recursion to loop manually.

### Pitfall 4 — Mutual recursion infinite

❌ A calls B, B calls A, no base case → infinite.

✅ Always have base case in at least one.

---

## 🌱 Advanced topics

### A1. Trampolining

Manual TCO: return a thunk (closure) instead of recursing.

```python
def trampoline(fn):
    while callable(fn):
        fn = fn()
    return fn

def even(n):
    if n == 0: return True
    return lambda: odd(n - 1)

def odd(n):
    if n == 0: return False
    return lambda: even(n - 1)

trampoline(even(10000))   # works, no stack overflow
```

### A2. Dynamic programming = iterative memo

DP = bottom-up version of memoized recursion. Often more efficient (no function call overhead).

### A3. Continuation-passing style (CPS)

Function takes "what to do next" as argument. Used in compilers.

### A4. Apply cho LLM 2026

- **Tree-of-thoughts**: explore via recursive thought tree
- **Recursive prompt**: agent calls itself with refined prompt
- **Beam search**: iterative with state pruning

---

## 🧠 Self-test

1. Recursion always slower than iteration? When/when not?
2. Tail recursion: vì sao compiler có thể optimize? Python có không?
3. Fibonacci naive O(2^n) vs memoized O(n). Vì sao memo work?
4. Stack overflow: depth 100k recursive call → bao nhiêu memory?
5. Mutual recursion: cho 1 ví dụ legit (even/odd).
6. Convert factorial recursive to iterative + tail recursive forms.

---

## 🔗 Liên kết

- **[F01/05 Tree](./05-tree-bst-btree.md)** — natural recursion
- **[F01/07 Sorting](./07-sorting-algorithms.md)** — Quicksort, Mergesort recursive
- **[F01/09 Complexity](./09-time-vs-space-complexity.md)** — call stack = space cost

---

## 🌐 Đọc thêm — refs cụ thể vào library  *(v3 — pointers chính xác)*

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **SICP (MIT, CC BY-SA 4.0)** → `Abelson-Sussman_SICP_MIT.pdf` Chapter 1.2 (Procedures and the Processes They Generate) — phân biệt recursive process vs iterative process, tail recursion. **Bài đọc bắt buộc**.
- **Erickson Algorithms (UIUC)** → `Erickson_2019_Algorithms_UIUC.pdf` Chapter 1 (Recursion) — 50 trang về divide-and-conquer + recurrence + master theorem + tower of Hanoi proof.
- **Open Data Structures (Morin)** → `Morin_OpenDataStructures_python.pdf` — recursive tree traversals.
- **Downey ThinkPython2** → `Downey_ThinkPython2.pdf` Chapter 5 (Conditional and Recursion) + Chapter 6 (Fruitful Functions) — Python-specific recursion patterns.

📖 **Sách commercial:**
- CLRS Chapter 4 — Recurrences (Master theorem, substitution, recursion tree).
- Skiena, *The Algorithm Design Manual* — recursion + DP catalog.

📄 **Paper gốc + spec:**
- Turing (1937), *"On Computable Numbers, with an Application to the Entscheidungsproblem"*.
- Church (1936), *"An Unsolvable Problem of Elementary Number Theory"* — lambda calculus.
- McCarthy (1960), *"Recursive Functions of Symbolic Expressions and Their Computation by Machine, Part I"* — LISP foundation.
- Van Rossum (2009), *"Tail Recursion Elimination"* blog — why Python rejects TCO.

---

**Đã đọc xong?**
✅ Tick → [F01/09 Time vs Space Complexity](./09-time-vs-space-complexity.md).
