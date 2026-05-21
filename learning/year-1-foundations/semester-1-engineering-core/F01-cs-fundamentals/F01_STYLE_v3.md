# F01 Style Guide v3 — University-grade Pedagogy Patterns

> **Mục tiêu:** Nâng F01 KUs từ v2 (DE-practical) → v3 (university CS rigor + DE practicality giữ nguyên).
>
> **Nguồn pattern:** Đọc trực tiếp 3 textbook đại học hàng đầu trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):
> 1. **OSTEP** — Arpaci-Dusseau, University of Wisconsin-Madison
> 2. **Algorithms** — Jeff Erickson, UIUC (CC BY 4.0)
> 3. **Algorithms 4e (slides)** — Sedgewick & Wayne, Princeton

---

## 🎯 So sánh v2 vs v3

| Aspect | v2 (current 18 KUs) | v3 (upgrade target) |
|---|---|---|
| **Vietnamese đời thường analogy** | ✓ có | ✓ giữ |
| **Terminology box** | ✓ có | ✓ giữ + thêm etymology cho key terms |
| **Real-world example DE** | ✓ có | ✓ giữ |
| **Self-test 5-6 câu** | ✓ có | ✓ nâng lên **exercises 3 levels (easy/medium/hard)** |
| **Cross-reference** | ✓ có | ✓ giữ |
| **"The Crux of the Problem" box** | ✗ thiếu | ✅ **THÊM** — OSTEP signature pattern |
| **Pseudocode UPPERCASE block** | ✗ thiếu | ✅ **THÊM** — Erickson signature |
| **Historical anecdote** | ✗ thiếu | ✅ **THÊM** — ai phát minh, khi nào, why matter |
| **Cost annotation table per op** | ✗ partial | ✅ **THÊM** — Sedgewick signature |
| **Bad example / anti-pattern code** | ✗ thiếu | ✅ **THÊM** — Erickson "Martin's algorithm" pattern |
| **Recurrence equation** (cho KU recursion/algo) | ✗ thiếu | ✅ **THÊM** — formal proof skeleton |
| **Epigraph quote** | ✗ thiếu | ⚠️ **OPTIONAL** — 1-2 quote ngắn (không bắt buộc) |

---

## 🧱 v3 Template — 22 sections (v2 16 + 6 mới)

```markdown
# KU F01 / NN — <Tên KU>

> [Pose vấn đề ngắn 2-3 câu — không trả lời ngay]

**Module:** ...
**Prereqs:** ...
**Related:** ...
**Đọc trong:** ...
**Mức độ:** Foundational / Intermediate / Advanced

---

### 🧩 The Crux of the Problem    ← MỚI v3 (OSTEP signature)

> **Core question:** [1 câu hỏi cốt lõi — đẩy reader vào tư thế giải quyết]
>
> Why hard: [2-3 câu — tại sao vấn đề không trivial]
> What we need: [mechanism nào / property nào để giải]

---

## 🎯 Nó là gì? (Analogy đời sống)         [giữ v2]
...

## 📖 Định nghĩa chính thức                [giữ v2]
...

## 📜 Lịch sử ngắn (etymology + invention) ← MỚI v3 (Erickson signature)

[2-3 đoạn về:]
- Tên gọi từ đâu (etymology — al-Khwārizmī, von Neumann, Donald Knuth...)
- Ai phát minh, năm nào
- Tại sao thời đó cần
- Today: được dùng ở đâu

## 🔤 Terminology box                       [giữ v2 — thêm cột "etymology" nếu hữu ích]

## 💡 Real-world examples                   [giữ v2]

## 🧮 Pseudocode chuẩn                       ← MỚI v3 (Erickson + Sedgewick signature)

```pseudocode
ALGORITHM_NAME(input1, input2):
    // pre-conditions
    Initialize ...
    for each ...
        if ... then
            ...
        else
            ...
    return ...
```

**Convention:**
- Function names UPPERCASE
- Arrow `←` cho assignment (Erickson) — hoặc `:=`
- Indentation rõ ràng
- Comment dạng `// ...` hoặc `《 ... 》`

## 📊 Cost annotation per operation         ← MỚI v3 (Sedgewick signature)

| Operation | Time (worst) | Time (avg) | Time (amortized) | Space |
|---|---|---|---|---|
| Insert | O(...) | O(...) | O(...) | O(...) |
| Lookup | O(...) | O(...) | — | O(...) |
| Delete | O(...) | O(...) | O(...) | — |

Note: phân biệt **worst-case · average-case · amortized · expected** rõ ràng.

## 🚀 Real-world impact                     [giữ v2]

## ⚠️ Common pitfalls                        [giữ v2]

## ❌ Bad example / anti-pattern             ← MỚI v3 (Erickson signature)

```python
# ❌ ĐÂY KHÔNG PHẢI là thuật toán hash hợp lệ
def bad_hash(key):
    return 42   # always collision!

# Tại sao bad:
# - Vi phạm uniformity property
# - Lookup degenerates to O(n) linked-list traversal
# - Đây là "Martin's algorithm" style — sounds OK nhưng không phải
```

## 🔧 Patterns / Approaches                 [giữ v2]

## 🌱 Advanced topics                        [giữ v2]

## 📐 Recurrence equation (cho KU recursion / DP / divide-conquer) ← MỚI v3 (Erickson)

Cho thuật toán mergesort:
```
T(n) = 2·T(n/2) + Θ(n)
```
Master Theorem case 2 → **T(n) = Θ(n log n)**.

## 🧠 Self-test → 📚 Exercises 3 cấp        ← MỞ RỘNG v3

**Easy (warm-up — phải làm được trong 1-2 phút):**
1. ...
2. ...

**Medium (apply — 5-10 phút giấy bút):**
3. ...
4. ...

**Hard (synthesis / extend — discussion-level):**
5. ...
6. ...

## 🔗 Liên kết                              [giữ v2]

## 🌐 Đọc thêm                              ← MỞ RỘNG v3

- 📖 **Erickson Algorithms** chapter X (UIUC, free) — section Y
- 📖 **OSTEP** chapter X (Wisconsin, free) — section Y
- 📖 **Sedgewick Princeton slides** — file Z
- 📄 Paper / arXiv link nếu có
```

---

## 🔍 Pattern detail — cách OSTEP / Erickson / Sedgewick triển khai

### Pattern 1 — "The Crux of the Problem" (OSTEP)

Mỗi chương OSTEP có 1-3 ô shaded gray:

```
┌──────────────────────────────────────────┐
│ THE CRUX OF THE PROBLEM:                 │
│ HOW TO VIRTUALIZE THE CPU?               │
│ How can the OS provide the illusion of   │
│ an infinite number of CPUs when there is │
│ only one (or a few)? What is the role of │
│ hardware? Software?                       │
└──────────────────────────────────────────┘
```

**Tác dụng:** Đẩy reader vào trạng thái "tôi đang giải vấn đề", không phải "tôi đang đọc tài liệu".

**Cách apply F01:** Mỗi KU có 1 Crux box ở đầu, sau analogy. Cấu trúc:
- Core question (1 câu)
- Why hard (2-3 câu giải thích tại sao trivial approach fails)
- What property we need (criteria của good solution)

---

### Pattern 2 — UPPERCASE pseudocode (Erickson UIUC)

```
APPORTIONCONGRESS(Pop[1..n], R):
    PQ ← NEWPRIORITYQUEUE
    《Give every state its first representative》
    for s ← 1 to n
        Rep[s] ← 1
        INSERT(PQ, s, Pop[i]/√2)
    《Allocate the remaining n − R representatives》
    for i ← 1 to n − R
        s ← EXTRACTMAX(PQ)
        Rep[s] ← Rep[s] + 1
        priority ← Pop[s] / √(Rep[s] × (Rep[s]+1))
        INSERT(PQ, s, priority)
    return Rep[1..n]
```

**Tác dụng:**
- Language-agnostic (không bias về Python/Java)
- UPPERCASE = primitive operations rõ ràng
- `←` thay vì `=` để phân biệt assignment vs equality
- `《...》` cho structural comment

**Cách apply F01:** Mỗi KU thuật toán/data structure có ít nhất 1 pseudocode block. Code Python cụ thể vẫn giữ ở phần Real-world impact, nhưng nên có abstract pseudocode song song.

---

### Pattern 3 — Historical anecdote (Erickson)

Erickson Chapter 0 dành 2 trang để kể:
- "Algorithm" từ tên al-Khwārizmī (Persian scholar 9th century)
- Algorism vs algorithm — folk etymology từ Greek `algos` (đau)
- Người làm thuật toán = "algorist" / "computator" / "computer"
- Multiplication algorithm có từ Sumer 2600 BCE

**Tác dụng:** Cho khái niệm chiều sâu lịch sử → reader không thấy nó "trừu tượng" mà thấy "có nguồn gốc, có người, có lý do".

**Cách apply F01:** Mỗi KU có 1 đoạn ngắn (~150 từ) về:
- Tên khái niệm từ đâu
- Ai phát minh / formalize
- Ngữ cảnh lịch sử (thời chiến tranh, time-sharing, big data...)

---

### Pattern 4 — Cost annotation per operation (Sedgewick)

Sedgewick slides có table chuẩn:

| Implementation | Search | Insert | Delete | Search (worst) | Insert (worst) |
|---|---|---|---|---|---|
| Sequential search (linked list) | N | N | N | N | N |
| Binary search (sorted array) | log N | N | N | log N | N |
| BST | log N (avg) | log N (avg) | √N (avg) | N | N |
| Red-black BST | log N | log N | log N | 2 log N | 2 log N |
| Hash table (separate chaining) | 1* | 1* | 1* | N | N |
| Hash table (linear probing) | 1* | 1* | 1* | N | N |

\* = under uniform hashing assumption.

**Tác dụng:** Engineer chọn data structure không cần đoán → nhìn bảng pick đúng cái.

**Cách apply F01:** KU 03 (Array vs LL), KU 04 (Hash), KU 05 (Tree), KU 07 (Sorting) **phải có** bảng kiểu này.

---

### Pattern 5 — Bad example (Erickson "Martin's algorithm")

Erickson §0.4:
```
BEAMILLIONAIREANDNEVERPAYTAXES():
    Get a million dollars.
    If the tax man comes to your door and says,
    "You have never paid taxes!"
        Say "I forgot."
```

→ "This is NOT actually an algorithm — first step is too vague to be considered an actual algorithm."

**Tác dụng:** Counter-example bằng humor → reader nhớ chính xác **đặc tính của thuật toán hợp lệ**: unambiguous, mechanically-executable, finite.

**Cách apply F01:** Mỗi KU có 1 anti-pattern block — code/logic LOOKS plausible nhưng vi phạm property cốt lõi.

---

### Pattern 6 — Recurrence equation (Erickson formal arguments)

Erickson không chỉ "Mergesort là O(n log n)" → ông viết:
```
T(n) = 2·T(n/2) + Θ(n)
```
Rồi giải bằng Master Theorem hoặc recursion tree.

**Tác dụng:** Bridge giữa code và Big-O — không phải "magic", có math chứng minh.

**Cách apply F01:**
- KU 02 Big-O: thêm 1 box recurrence vs solution
- KU 07 Sorting: 4 recurrences (merge, quick, heap, radix)
- KU 08 Recursion: recurrence cho fib, fact, ackermann
- KU 18 NP: hiển nhiên không phải recurrence nhưng cần formal reduction.

---

### Pattern 7 — Exercises 3 cấp (Erickson signature)

Cuối mỗi chương Erickson có ~30 exercises chia level:
- ♥ Easy (definition recall)
- (no symbol) Medium (apply known technique)
- ♦ Hard (extend / synthesize)

**Tác dụng:** Reader pace theo level — không phải "đọc xong là xong" mà "làm exercise xong mới xong".

**Cách apply F01:** Self-test 5-6 câu → mở rộng thành **3 cấp ≥ 9 câu**.

---

## 📋 Checklist apply v3 cho 1 KU

Khi nâng cấp 1 KU từ v2 lên v3, thêm 6 phần mới:

- [ ] **🧩 The Crux of the Problem** box ở đầu (sau Analogy)
- [ ] **📜 Lịch sử ngắn** (~150 từ — etymology + invention + why matter today)
- [ ] **🧮 Pseudocode UPPERCASE** block (nếu KU là algorithm/DS)
- [ ] **📊 Cost annotation table** worst/avg/amortized/expected (nếu KU là DS)
- [ ] **❌ Bad example / anti-pattern** code block
- [ ] **📐 Recurrence equation** (nếu KU là recursion/DP/divide-conquer)
- [ ] **📚 Exercises 3 cấp** (thay self-test): easy 2 câu + medium 2 câu + hard 2 câu = 6 tối thiểu
- [ ] **🌐 Đọc thêm** mở rộng: trỏ vào cụ thể chapter của Erickson/OSTEP/Sedgewick trong library

---

## 🎓 Mapping cụ thể v3 cho 18 KUs

| KU | Crux | Pseudocode | Cost table | Recurrence | Bad example |
|---:|:---:|:---:|:---:|:---:|:---:|
| 01 Bits encoding | ✓ | — | — | — | ✓ (broken UTF-8) |
| 02 Big-O | ✓ | ✓ | — | ✓ | ✓ (O(n²) sort) |
| 03 Array vs LL | ✓ | — | ✓ | — | ✓ |
| 04 Hash table | ✓ | ✓ | ✓ | — | ✓ (bad hash fn) |
| 05 Tree BST/B-tree | ✓ | ✓ | ✓ | ✓ | ✓ (skewed BST) |
| 06 Graph BFS/DFS | ✓ | ✓ | ✓ | — | ✓ (no visited set) |
| 07 Sorting | ✓ | ✓ × 5 | ✓ | ✓ × 4 | ✓ (bubble naively) |
| 08 Recursion | ✓ | ✓ | — | ✓ × 3 | ✓ (no base case) |
| 09 Time vs space | ✓ | — | ✓ | — | ✓ (premature opt) |
| 10 Compression | ✓ | ✓ (Huffman) | ✓ | — | ✓ (zip random data) |
| 11 Checksums | ✓ | ✓ (CRC poly) | — | — | ✓ (md5 password) |
| 12 Bit manip | ✓ | ✓ | — | — | ✓ |
| 13 Pseudo-rand vs crypto | ✓ | ✓ | — | — | ✓ (Math.random token) |
| 14 Floating point | ✓ | ✓ (Kahan sum) | — | — | ✓ (== compare) |
| 15 String encoding | ✓ | — | — | — | ✓ (UTF-16 no BOM) |
| 16 Endianness | ✓ | ✓ (htons) | — | — | ✓ (raw uint16 send) |
| 17 Hash families | ✓ | ✓ (HMAC) | ✓ | — | ✓ (length extension) |
| 18 Complexity classes | ✓ | ✓ (reduction) | — | — | ✓ (exact TSP 50 cities) |

---

## 🛣 Roadmap apply

**Phase 1 — Pilot 3 KUs (đại diện):**
- KU 02 Big-O (algorithm + recurrence flagship)
- KU 04 Hash table (data structure flagship)
- KU 18 Complexity classes (theory flagship)

→ User review feedback → adjust style guide nếu cần.

**Phase 2 — 7 KUs còn lại nhóm A (DS + algorithm):**
- KU 03, 05, 06, 07, 08, 09, 10

**Phase 3 — 8 KUs còn lại nhóm B (encoding + low-level):**
- KU 01, 11, 12, 13, 14, 15, 16, 17

**Tổng wordcount target:** v2 hiện ~38k từ. v3 dự kiến ~55-60k từ (thêm ~22k cho 6 sections × 18 KUs).

---

## 📝 Notes

- **Không thay đổi phần v2 hiện có** — chỉ THÊM 6 sections mới.
- **Vietnamese vẫn primary** — tất cả section mới viết tiếng Việt + technical term tiếng Anh.
- **Library reference cụ thể** — khi thêm "Đọc thêm", trỏ vào file PDF có thật trong `library/books/cs-fundamentals/`.
- **Style consistent** — sau khi apply pilot 3 KUs, dùng output làm template cho phần còn lại.

---

**Style guide này = grounded trong textbooks đại học thật, không phải fabricated. Mọi pattern citation đều có file PDF chứng minh trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/).**
