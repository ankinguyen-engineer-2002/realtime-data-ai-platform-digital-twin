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

**Đã đọc xong?**
✅ Tick → [F01/09 Time vs Space Complexity](./09-time-vs-space-complexity.md).
