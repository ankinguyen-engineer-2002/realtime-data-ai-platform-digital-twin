# KU F01 / 18 — Algorithmic complexity classes (P, NP)

> Một số problems **dễ giải** (P), một số **dễ verify nhưng khó giải** (NP), một số **không thể giải hiệu quả** (NP-complete, NP-hard). Hiểu mức này = biết khi nào problem "không có algorithm tốt" → dùng heuristic, approximation.

**Module:** [F01 — CS Fundamentals](./README.md)
**Prereqs:** [F01/09 Time vs space complexity](./09-time-vs-space-complexity.md)
**Related KUs:** [F12 System Design](../../semester-2-systems-theory/F12-system-design-fundamentals/)
**Đọc trong:** ~12 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

3 loại bài toán đời thường:

### P (Polynomial time) — Dễ giải
- **"Sắp xếp 1000 cuốn sách theo ABC."** → có algorithm O(n log n) → giải nhanh.
- **"Tìm đường ngắn nhất A→B."** → Dijkstra O((V+E) log V) → giải nhanh.

### NP (Nondeterministic Polynomial) — Dễ verify, khó giải
- **"Có lịch đi du lịch ghé hết 100 thành phố tổng dưới 2000km?"** (Traveling Salesman Problem).
- **Verify:** cho lịch trình, đo tổng km → easy.
- **Solve:** thử mọi permutation → 100! ≈ 10^158 cách → impossible.

### NP-complete — Hardest in NP
- TSP, 3-SAT, Vertex Cover, Hamiltonian Cycle.
- Tất cả "tương đương" — nếu giải 1 cái polynomial → giải hết.

### NP-hard — At least as hard as NP
- Halting Problem (decide program will halt) — **undecidable**.

---

## 📖 Định nghĩa chính thức

**P (Polynomial)** = problems solvable in O(n^k) time với k constant. "Tractable".

**NP (Nondeterministic Polynomial)** = problems whose **solution can be verified** in polynomial time.

**NP-complete** = problems in NP, all NP problems reducible to it. Hardest in NP.

**NP-hard** = problems at least as hard as NP-complete. May not be in NP (e.g., undecidable).

**Big question: P = NP?**
- Open problem since 1971 (Cook-Levin theorem).
- If P = NP → revolutionary, can solve TSP fast.
- Most computer scientists believe P ≠ NP.

**Nguồn:**
- Garey & Johnson, *"Computers and Intractability"* (1979).
- Cook-Levin theorem (1971).
- Clay Math Millennium Prize.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| P | P (Polynomial time) | Solvable in polynomial time |
| NP | NP | Verifiable in polynomial time |
| NP-complete | NP-complete | Hardest in NP |
| NP-hard | NP-hard | At least as hard as NP |
| Tractable | Tractable | Can solve in reasonable time |
| Intractable | Intractable | Cannot solve in reasonable time |
| Reduction | Reduction | Convert problem A → B |
| Polynomial reduction | Polynomial reduction | Reduction in polynomial time |
| Cook-Levin | Cook-Levin theorem | SAT is NP-complete |
| Decidable | Decidable | Algorithm exists for all inputs |
| Undecidable | Undecidable | No algorithm can solve |
| Halting problem | Halting problem | Famously undecidable |
| Approximation algorithm | Approximation algorithm | Get within X% of optimal |
| Heuristic | Heuristic | Practical good-enough solution |
| Parameterized complexity | Parameterized complexity | Complexity in terms of parameters |

---

## 💡 Real-world examples

### P problems (easy)
- Sorting
- Shortest path (Dijkstra, BFS)
- Maximum flow
- Linear programming
- Primality testing (AKS 2002)
- Connected components

### NP-complete (hard)
- **TSP** (Traveling Salesman) — find shortest tour
- **3-SAT** — satisfy boolean formula
- **Knapsack** (0/1) — pack items max value within weight
- **Graph coloring** — color vertices, neighbors different
- **Hamiltonian Cycle** — find cycle visit each vertex once
- **Vertex Cover** — smallest set covering all edges
- **Set Cover** — smallest collection covering universe
- **Subset Sum** — find subset sum equal target

### NP-hard (but not NP)
- **Halting Problem** — undecidable
- **TSP optimization** (not decision) — NP-hard, not NP

### Real-world impact

- **Compiler optimization**: many problems are NP-hard → use heuristics
- **Scheduling**: NP-hard → use greedy / genetic algorithms
- **Network design**: NP-hard → approximation
- **Cryptography**: based on hardness assumptions (factoring, discrete log — believed NP)

---

## 🚀 What to do when problem is NP-hard

### Approach 1 — Approximation algorithm
Find solution within X% of optimal in polynomial time.
- TSP: Christofides 1.5-approximation
- Vertex Cover: 2-approximation (greedy)

### Approach 2 — Heuristic
Practical good-enough solutions without guarantee.
- Genetic algorithms
- Simulated annealing
- Tabu search

### Approach 3 — ILP / SAT solver
Use industrial solvers (Gurobi, CPLEX, Z3) for small instances. Surprisingly effective in practice.

### Approach 4 — Special cases
Some special structures admit polynomial algorithm.
- TSP on planar graph: PTAS
- 2-SAT (instead of 3-SAT): polynomial

### Approach 5 — Reduce problem scope
Solve smaller version. Accept partial solution.

### Approach 6 — Quantum (future)
Some NP problems may be faster on quantum computers (Grover's algorithm for unstructured search).

→ Today: 2026 quantum advantage exists for select problems, not general NP.

---

## 🔧 Reductions show NP-completeness

Show problem X is NP-complete by:
1. X ∈ NP (verify in polynomial time)
2. Reduce known NP-complete (e.g., 3-SAT) to X in polynomial time.

Famous reductions:
- 3-SAT ≤ Vertex Cover ≤ Hamiltonian Cycle ≤ TSP
- 3-SAT ≤ Subset Sum ≤ Knapsack

---

## 💡 Trong DE / AI 2026

| Problem | Class |
|---|---|
| Query optimization (general) | NP-hard → cost-based estimator + heuristics |
| Schema design | NP-hard normalization |
| Workload scheduling (DAG) | NP-hard → greedy |
| Bin packing (capacity planning) | NP-hard → first-fit decreasing |
| K8s scheduler | NP-hard → score-based heuristic |
| ML feature selection | NP-hard → greedy forward selection |
| Network optimization | NP-hard → ILP solver |
| Job shop scheduling | NP-hard |
| Knapsack-style cost optimization | NP-hard |
| LLM agent task planning | Often NP-hard → MCTS, beam search |

→ Most "real-world hard problems" are NP-hard → industrial uses approximation + heuristic, NOT exact algorithm.

---

## ⚠️ Common pitfalls

### Pitfall 1 — Try to solve NP-hard exactly

❌ Brute force TSP 50 cities → universe heat death.

✅ Use approximation or heuristic. Or accept smaller scope.

### Pitfall 2 — Confuse worst case with average

NP-hard worst-case slow. Many instances solvable in practice (SAT solvers).

→ Real-world data often has structure.

### Pitfall 3 — Assume P=NP for design

❌ Hope future algorithm fixes it.

✅ Design around NP-hardness now.

---

## 🌱 Advanced topics

### A1. PSPACE, EXPTIME

Beyond NP. PSPACE = polynomial space. EXPTIME = exponential time. EXPSPACE = exponential space.

Hierarchy: P ⊆ NP ⊆ PSPACE ⊆ EXPTIME.

### A2. Co-NP

Problems whose **non-solution** verifiable in polynomial time. NP vs co-NP relationship unclear.

### A3. Randomized complexity

BPP (Bounded-error Probabilistic Polynomial) = randomized polynomial. AKS primality moved primality from BPP to P (2002).

### A4. Quantum complexity (BQP)

Some NP-incomplete problems faster on quantum (factoring — Shor's algorithm). Quantum doesn't solve NP-complete polynomially (believed).

### A5. P vs NP — what would change

If P=NP:
- Cryptography breaks (factoring, RSA)
- TSP, scheduling efficient
- AI revolution (many ML problems are NP)

→ Most believe P ≠ NP. Cryptography depends on it.

---

## 🧠 Self-test

1. P vs NP: difference + example each.
2. NP-complete: definition + 3 examples.
3. Halting problem: P, NP, or NP-hard?
4. TSP: how to handle in practice (5 approaches)?
5. P=NP implications for cryptography?
6. Why most computer scientists believe P ≠ NP?

---

## 🔗 Liên kết

- **[F01/09 Time vs space complexity](./09-time-vs-space-complexity.md)** — foundation
- **[F12 System Design](../../semester-2-systems-theory/F12-system-design-fundamentals/)** — real-world heuristics

---

## 🌐 Đọc thêm
- Garey & Johnson "Computers and Intractability"
- Cook 1971 paper.

---

**🎉 Đã đọc xong F01/18 — bạn hoàn thành toàn bộ Module F01 CS Fundamentals (18/18)!**

Tiếp theo:
- ✅ Tick checklist
- ➡️ Đi sang [F02 Programming Paradigms](../F02-programming-paradigms/)
