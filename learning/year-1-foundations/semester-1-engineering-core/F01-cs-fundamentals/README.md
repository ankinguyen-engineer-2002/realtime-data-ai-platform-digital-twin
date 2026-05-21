# F01 — CS Fundamentals

> **🎉 Module COMPLETE: 18/18 KUs at v2 university-grade.**
>
> **Vốn chung của mọi engineer.** Bytes / Big-O / data structures / algorithms / encoding / compression. Đây là **bộ từ điển** mọi tool (Postgres, Kafka, Iceberg, ClickHouse, Python) đều xài.

**Học kỳ:** Wave 1 — HK1 Engineering Core
**Số KUs:** 18/18 ✅
**Ưu tiên:** ⭐⭐⭐
**Prerequisites:** [F00 Mental Models](../F00-mental-models/)
**Đọc trong:** ~3.5 giờ tổng
**Words:** ~38,000 ở chuẩn v2

---

## 🎯 Sau khi học xong F01

- **Đọc EXPLAIN ANALYZE** của Postgres và hiểu vì sao query chậm (B-tree, hash join, sort).
- **Hiểu vì sao Kafka chọn append-only log** thay vì update-in-place (sequential write speed).
- **Đoán complexity** của bất kỳ algorithm/operation nào (O(1) lookup hash, O(log n) tree, O(n) scan).
- **Debug encoding bug** (UTF-8 vs Latin-1, "Mojibake" Tiếng Việt).
- **Pick compression đúng** (Snappy fast vs Zstd small vs LZ4 balanced).
- **Tránh floating point trap** trong tính tiền/giá ($0.1 + $0.2 ≠ $0.3 trong float).
- **Đọc đoạn code CS** ở textbook / paper mà không khựng.
- **Biết khi nào problem NP-hard** → dùng heuristic thay vì giải exact.

---

## 🧭 Dependency map

```mermaid
flowchart TD
    classDef done fill:#1e5f1e,color:#fff

    K01["01 Bits, bytes, encoding ⭐"]:::done
    K02["02 Big-O đời thường ⭐"]:::done
    K03["03 Array vs Linked list ⭐"]:::done
    K04["04 Hash table ⭐"]:::done
    K05["05 Tree BST/B-tree/LSM ⭐"]:::done
    K06["06 Graph + BFS/DFS ⭐"]:::done
    K07["07 Sorting algorithms ⭐"]:::done
    K08["08 Recursion + iteration ⭐"]:::done
    K09["09 Time vs space complexity ⭐"]:::done
    K10["10 Compression basics ⭐"]:::done
    K11["11 Checksums + integrity hash ⭐"]:::done
    K12["12 Bit manipulation ⭐"]:::done
    K13["13 Pseudo-random vs crypto ⭐"]:::done
    K14["14 Floating point ⭐"]:::done
    K15["15 String encoding bugs ⭐"]:::done
    K16["16 Endianness ⭐"]:::done
    K17["17 CRC/MD5/SHA families ⭐"]:::done
    K18["18 Algorithmic complexity classes ⭐"]:::done

    K01 --> K02
    K02 --> K03 --> K04 --> K05 --> K06
    K04 -.-> K07
    K05 -.-> K07
    K07 --> K08 --> K09
    K01 --> K10 --> K11 --> K17
    K01 --> K12 --> K13
    K01 --> K14
    K01 --> K15
    K01 --> K16
    K09 --> K18
```

---

## 📋 KU list (18/18 ✅)

| # | KU | Đọc | Status |
|---:|---|---:|:---:|
| 01 | [Bits, bytes, encoding](./01-bits-bytes-encoding.md) | 12' | ✅ |
| 02 | [Big-O notation đời thường](./02-big-o-notation.md) | 12' | ✅ |
| 03 | [Array vs Linked list](./03-array-vs-linked-list.md) | 12' | ✅ |
| 04 | [Hash table — collision + Robin Hood](./04-hash-table.md) | 12' | ✅ |
| 05 | [Tree: BST, B-tree, B+tree, LSM](./05-tree-bst-btree.md) | 14' | ✅ |
| 06 | [Graph + BFS/DFS](./06-graph-bfs-dfs.md) | 10' | ✅ |
| 07 | [Sorting algorithms](./07-sorting-algorithms.md) | 12' | ✅ |
| 08 | [Recursion + iteration](./08-recursion-iteration.md) | 10' | ✅ |
| 09 | [Time vs space complexity](./09-time-vs-space-complexity.md) | 10' | ✅ |
| 10 | [Compression (Snappy/gzip/LZ4/Zstd)](./10-compression-basics.md) | 12' | ✅ |
| 11 | [Checksums + integrity hash](./11-checksums-integrity.md) | 10' | ✅ |
| 12 | [Bit manipulation cơ bản](./12-bit-manipulation.md) | 10' | ✅ |
| 13 | [Pseudo-random vs crypto](./13-pseudo-random-vs-crypto.md) | 10' | ✅ |
| 14 | [Floating point — bẫy precision](./14-floating-point.md) | 12' | ✅ |
| 15 | [String encoding bugs (UTF-8 vs Latin-1)](./15-string-encoding-bugs.md) | 10' | ✅ |
| 16 | [Endianness (big vs little)](./16-endianness.md) | 8' | ✅ |
| 17 | [CRC, MD5, SHA hash families](./17-hash-families.md) | 12' | ✅ |
| 18 | [Algorithmic complexity classes (P, NP)](./18-complexity-classes.md) | 12' | ✅ |

**Tổng F01:** 18 KUs · ~3.5 giờ đọc · ~38,000 từ.

---

## 📚 Sách tham khảo từ library

- **CLRS — Introduction to Algorithms** — bible cho algorithms (Chapters 1-12, 18, 22-26).
- **Bhargava — Grokking Algorithms** (Manning 2016) — illustrated, dễ tiếp cận.
- **Stevens — TCP/IP Illustrated Vol 1** — for KU 16 endianness.
- **Goldberg — "What Every Computer Scientist Should Know About Floating-Point"** — for KU 14.
- **Joel Spolsky — "Unicode and Character Sets"** — for KU 15.

---

## 🗺 Navigation

- ⬆️ [Semester 1](../README.md)
- 🏠 [Learning home](../../../README.md)
- ➡️ Next: [F02 Programming Paradigms](../F02-programming-paradigms/)
