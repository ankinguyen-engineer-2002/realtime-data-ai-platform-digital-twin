# KU F02 / 10 — Concurrency primitives: threads, locks, race conditions

> **Thread + lock** = oldest concurrency model. Mọi modern lang có thread (Java, Python, C++, Go). **Race condition** = 2 thread access shared mutable state → undefined behavior. **Lock / mutex** giải quyết nhưng có cost (contention) + bug (deadlock). Hiểu primitives này = foundation cho hiểu Flink keyed state, Postgres row locks, Kafka consumer rebalance.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/07 Pure functions + Immutability](./07-pure-functions-immutability.md)
**Related KUs:** [F02/11 Async + CSP/Actor](./11-async-event-loop-csp-actor.md) · [F00/06 Idempotency](../F00-mental-models/06-idempotency.md)
**Đọc trong:** ~18 phút
**Mức độ:** Intermediate

---

## 🎯 Nó là gì? (Analogy đời sống)

**Tủ thuốc gia đình** + **2 người dùng cùng lúc**:

### Race condition — không lock
- Anh A đọc số viên paracetamol trong lọ: **5 viên**.
- Cùng lúc anh B đọc: **5 viên**.
- A lấy 2 viên → lọ còn 3. A ghi "3 viên".
- B (đã đọc 5) lấy 3 viên → tưởng còn 2. B ghi "2 viên".
- **Thực tế lọ rỗng** nhưng số ghi là "2".
- → **State inconsistent**. Lost update.

### Mutex (mutual exclusion)
- Đặt **khoá** trên tủ. Ai dùng = phải lấy khoá trước.
- A lấy khoá → đọc 5 → lấy 2 → ghi 3 → trả khoá.
- B chờ → lấy khoá → đọc 3 → lấy 3 → ghi 0 → trả khoá.
- → Consistent. **Sequential access đảm bảo**.

### Cost của mutex
- B phải **chờ** A xong. Nếu nhiều thread → queue lớn → throughput giảm.
- Nếu lock contention 50% → throughput half.

### Deadlock
- A khoá tủ thuốc, định đi lấy tủ vitamin.
- B khoá tủ vitamin, định đi lấy tủ thuốc.
- A chờ B trả vitamin, B chờ A trả thuốc → **kẹt mãi**.

Trong code:
```python
import threading

balance = 1000
lock = threading.Lock()

def withdraw(amount):
    with lock:                  # acquire mutex
        global balance
        if balance >= amount:
            balance -= amount
        # release mutex automatically
```

→ **Threading classic = power + footgun.** Modern advice: prefer immutability + actor/CSP (KU 11).

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Core question:** Cho 8 CPU cores + workload parallelizable, làm sao chạy **đồng thời** + safely **share state** giữa các thread mà không tạo race condition / deadlock / livelock?
>
> **Why hard:** Modern CPU **reorder memory operations** for perf. Without memory barriers, thread A's writes invisible to thread B. Plus shared mutable state = exponential complexity (n threads × m locks = n×m interaction patterns).
>
> **What we need:** Hiểu 4 hazards (data race, deadlock, livelock, starvation) + 5 primitives (mutex, semaphore, condition variable, atomic, RWLock) + memory ordering models. Plus biết: **immutable + message passing thường tốt hơn lock-based**.

→ **OSTEP Concurrency Part 2** (Wisconsin) là bài đọc tiêu chuẩn. Modern: Go channels, Erlang actors, Rust ownership eliminate large class of bugs.

---

## 📖 Định nghĩa chính thức

### **Thread** vs **Process**
- **Process** = isolated address space + threads + resources
- **Thread** = unit of execution within process, **share** memory with sibling threads

### **Concurrency** vs **Parallelism**
- **Concurrency** = multiple tasks **logically simultaneous** (interleave on 1 CPU)
- **Parallelism** = multiple tasks **physically simultaneous** (multiple CPUs)

Famous Rob Pike quote: *"Concurrency is about structure. Parallelism is about execution."*

### **Race condition** & **Data race**
- **Data race** = 2+ threads access same memory + at least 1 writes + no synchronization → **undefined behavior** in C/C++/Java/Go memory model.
- **Race condition** = broader — incorrect behavior depending on timing.

### **Primitives**

**Mutex** (mutual exclusion) — only 1 thread can hold at a time.
```python
mutex.acquire()
# critical section
mutex.release()
```

**Semaphore** — counter; threads decrement to acquire, increment to release. Mutex = binary semaphore.

**Condition variable** — wait for condition, signal when condition true. E.g., "queue not empty".

**RWLock** (Read-Write lock) — many readers OR one writer.

**Atomic operations** — compare-and-swap (CAS), atomic add. Hardware-level lock-free primitives.

**Memory barrier / Fence** — instruction preventing CPU reorder across the barrier.

### **Hazards**

1. **Deadlock** — circular wait. 4 conditions (Coffman): mutual exclusion, hold-and-wait, no preemption, circular wait.
2. **Livelock** — threads constantly retry but make no progress.
3. **Starvation** — thread waits forever (low priority).
4. **Priority inversion** — high-priority thread waits for low-priority holding lock.
5. **ABA problem** — value changes A → B → A, lock-free algorithm thinks unchanged.

**Nguồn:** **OSTEP Wisconsin** (free, có trong cs-fundamentals/) Parts 4-6 — Concurrency. **Hoare CSP 1978** (có trong programming-paradigms/). Java *Concurrency in Practice* (Goetz).

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **Dijkstra (1965)** — *"Cooperating Sequential Processes"* — coined "**semaphore**". Foundation cho concurrent primitives.
- **Hoare (1974)** — Monitors. *"Monitors: An Operating System Structuring Concept"*. Each object has implicit mutex + condition vars.
- **Hoare CSP (1978)** — *"Communicating Sequential Processes"*, CACM — **message passing > shared memory**.
- **Lamport (1978)** — *"Time, Clocks, and the Ordering of Events"* — happens-before relation, foundation cho distributed concurrency.
- **POSIX threads (1995)** — Unix standard thread API. Java threads (1995) similar.
- **Java memory model (2004, JSR 133)** — define visibility + happens-before for Java.
- **C++11 (2011)** — `std::thread`, `std::atomic`, memory ordering — first standard threading in C++.
- **Go (2009)** — channels + goroutines, follow CSP. *"Don't communicate by sharing memory; share memory by communicating."*
- **Rust (2010)** — ownership eliminates data race **at compile time**. Major innovation.
- **Today (2026):** Mainstream advice = avoid shared mutable state. Prefer immutability, channels, actors. But understand primitives because OS, DB, JVM still use them internally.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Thread | Thread | Lightweight unit of execution |
| Process | Process | Isolated execution context |
| Concurrency | Concurrency | Logically simultaneous |
| Parallelism | Parallelism | Physically simultaneous |
| Mutex | Mutex | Mutual exclusion lock |
| Lock | Lock | General term for mutual exclusion |
| Semaphore | Semaphore | Counting lock |
| Condition variable | Condition variable | Wait for predicate |
| RWLock | Read-Write Lock | Many readers or one writer |
| Monitor | Monitor | Object + implicit lock + condvar |
| Critical section | Critical section | Code that must run serially |
| Atomic | Atomic | Indivisible operation |
| CAS | Compare-and-swap | Atomic conditional update |
| Memory barrier | Memory barrier / Fence | Prevent reorder |
| Happens-before | Happens-before | Lamport's partial order |
| Data race | Data race | Unsync concurrent access with write |
| Race condition | Race condition | Behavior depends on timing |
| Deadlock | Deadlock | Circular wait |
| Livelock | Livelock | Active but no progress |
| Starvation | Starvation | Indefinite wait |
| Reentrant lock | Reentrant lock | Same thread can re-acquire |
| Fair lock | Fair lock | FIFO order |
| Spin lock | Spin lock | Busy-wait instead of block |
| Lock-free | Lock-free | No locks, uses atomic |
| Wait-free | Wait-free | Bounded steps regardless of others |
| GIL | Global Interpreter Lock | Python/Ruby single-thread bytecode |
| Thread pool | Thread pool | Reusable threads |
| Fork-Join | Fork-Join | Divide-conquer parallelism |

---

## 💡 Real-world examples

### Race condition demo — counter

```python
import threading

counter = 0

def increment():
    global counter
    for _ in range(100000):
        counter += 1   # NOT atomic — load, add, store

threads = [threading.Thread(target=increment) for _ in range(10)]
for t in threads: t.start()
for t in threads: t.join()

print(counter)
# Expected: 1,000,000
# Actual (with GIL): around 1,000,000 (Python GIL serializes bytecode)
# Without GIL (e.g., Java equivalent): could be 200,000 — 800,000 (race!)
```

**Why race:** `counter += 1` =
1. Load counter to register
2. Add 1
3. Store back

Between (1) and (3), another thread can also load → both write same value → lost update.

### Fix with lock

```python
import threading
counter = 0
lock = threading.Lock()

def increment():
    global counter
    for _ in range(100000):
        with lock:        # acquire
            counter += 1
        # release
```

### Deadlock demo

```python
lock_a = threading.Lock()
lock_b = threading.Lock()

def task1():
    with lock_a:
        time.sleep(0.1)
        with lock_b:   # waits for task2 to release
            ...

def task2():
    with lock_b:
        time.sleep(0.1)
        with lock_a:   # waits for task1 to release
            ...

# Deadlock — both wait forever
```

**Mitigation:** **Lock ordering** — always acquire in same global order (a then b).

### Production examples — DSX Air

| System | Concurrency primitive |
|---|---|
| **Postgres row-level lock** | RWLock on each row tuple |
| **Kafka partition** | Single-writer per partition (no lock needed at partition level) |
| **Flink keyed state** | Sharded by key, no cross-key contention |
| **RocksDB MemTable** | Spin lock + lock-free skip list |
| **Iceberg metadata file** | Atomic file rename for commit |
| **Python `threading.Lock`** | Used in libraries like `requests.Session` for shared HTTP pool |
| **Spark driver** | Thread pool for task scheduling |
| **dbt** | Connection pool with semaphore |

### Java vs Go vs Rust

```java
// Java — mutex + condvar
synchronized (queue) {
    while (queue.isEmpty()) {
        queue.wait();
    }
    Item item = queue.poll();
    queue.notifyAll();
}
```

```go
// Go — channel
item := <- queue  // blocks if queue empty
// channels eliminate explicit lock
```

```rust
// Rust — ownership prevents data race at compile time
let queue: Arc<Mutex<VecDeque<Item>>> = Arc::new(Mutex::new(VecDeque::new()));
let q = queue.clone();
thread::spawn(move || {
    let mut guard = q.lock().unwrap();   // can't access queue without lock
    guard.push_back(item);
    // guard auto-released at scope end
});
```

→ Rust's borrow checker = type system enforces lock discipline.

---

## 🧮 Pseudocode — classic concurrency patterns  *(Erickson UIUC style)*

### Producer-Consumer with semaphore

```
shared queue: Queue                            《protected》
sem_items: Semaphore(0)                        《count items》
sem_slots: Semaphore(BUFFER_SIZE)              《count empty slots》
mutex: Mutex                                    《protect queue》

PRODUCER:
    while true:
        item ← produce()
        sem_slots.acquire()                    《wait for slot》
        mutex.acquire()
        queue.enqueue(item)
        mutex.release()
        sem_items.release()                    《signal item available》

CONSUMER:
    while true:
        sem_items.acquire()                    《wait for item》
        mutex.acquire()
        item ← queue.dequeue()
        mutex.release()
        sem_slots.release()                    《signal slot free》
        consume(item)
```

### Reader-Writer (RWLock manually)

```
read_count: int = 0
read_mutex: Mutex
write_lock: Mutex

READER:
    read_mutex.acquire()
    read_count ← read_count + 1
    if read_count = 1 then write_lock.acquire()
    read_mutex.release()
    read_data()
    read_mutex.acquire()
    read_count ← read_count − 1
    if read_count = 0 then write_lock.release()
    read_mutex.release()

WRITER:
    write_lock.acquire()
    write_data()
    write_lock.release()
```

### Dining philosophers (classic deadlock)

```
N philosophers, N forks (each fork shared between 2 philosophers)

NAIVE (deadlocks):
    PHILOSOPHER(i):
        while true:
            think()
            fork_left.acquire()
            fork_right.acquire()
            eat()
            fork_left.release()
            fork_right.release()

ORDERED (deadlock-free):
    PHILOSOPHER(i):
        while true:
            think()
            (lower, higher) ← (min(left,right), max(left,right))
            lower.acquire()
            higher.acquire()
            eat()
            higher.release()
            lower.release()
```

→ **Lock ordering** = standard deadlock prevention.

### CAS lock-free counter

```
ATOMIC_INCREMENT(counter):
    loop:
        old ← LOAD(counter)
        new ← old + 1
        if CAS(counter, old, new) = SUCCESS then
            return new
        《else retry》
```

→ No lock. Hardware CAS instruction. ABA problem still possible nếu pointers.

---

## 📊 Cost annotation table — concurrency primitive comparison  *(Sedgewick Princeton style)*

| Primitive | Use case | Overhead | Risk |
|---|---|---|---|
| **Mutex** | General mutual exclusion | ~25-50 ns acquire+release uncontended | Deadlock |
| **Spin lock** | Very short critical section | ~5 ns uncontended, 100% CPU contended | Wasted CPU |
| **RWLock** | Read-heavy | ~50 ns | Writer starvation |
| **Semaphore** | Resource counting | ~50 ns | Forget to release |
| **Condition var** | Wait for condition | ~100 ns + sleep | Lost wakeup |
| **Atomic CAS** | Lock-free counter | ~10 ns | ABA |
| **Channel** (Go) | Message passing | ~30-100 ns | None usually |
| **Immutable + copy** | Functional | Memory allocation | None |

**Lock contention impact (8 cores, increment counter):**

| Approach | Throughput |
|---|---|
| No lock (race) | 800M ops/sec (but wrong) |
| Spin lock | 50M ops/sec |
| Mutex | 30M ops/sec |
| RWLock (write) | 25M ops/sec |
| Atomic increment | 80M ops/sec ⚡ |
| Per-thread counter + sum | 800M ops/sec ⚡ |
| Sharded counter (16 shards) | 600M ops/sec |

→ **Lock-free / sharded** thường thắng. Pick atomic operations cho counters.

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Check-then-act without lock

```python
# ❌ Race condition
if balance >= amount:        # CHECK
    balance -= amount         # ACT — but another thread might withdraw between!
```

**Tại sao bad:** Time-of-check vs time-of-use (TOCTOU). Pick atomic compare-and-subtract or lock entire block.

### Anti-pattern 2 — Forget to release lock on exception

```java
// ❌ Manual lock — bug if exception thrown
lock.lock();
process();   // ← if throws, lock never released
lock.unlock();
```

**Tại sao bad:** Lock leak → all future threads block. Pick **try-finally**:
```java
lock.lock();
try {
    process();
} finally {
    lock.unlock();
}
```

Or **with-statement** Python / **RAII** C++/Rust.

### Anti-pattern 3 — Double-checked locking (broken without memory barrier)

```java
// ❌ Famous broken pattern (pre-Java 5)
class Singleton {
    private static Singleton instance;
    public static Singleton getInstance() {
        if (instance == null) {            // first check, no lock
            synchronized (Singleton.class) {
                if (instance == null) {    // second check, with lock
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }
}
```

**Tại sao bad:** Without `volatile`, JVM may reorder constructor — other thread sees partial instance. Pick `volatile` (Java 5+) or **enum singleton** (Bloch Item 3).

### Anti-pattern 4 — Lock held during I/O

```python
# ❌ Hold lock during slow I/O
with cache_lock:
    data = http_get(url)         # 200ms blocking
    cache[url] = data
```

**Tại sao bad:** Other threads block 200ms. Pick: release lock during I/O.
```python
data = http_get(url)             # do I/O without lock
with cache_lock:
    cache[url] = data            # only protect dict write
```

### Anti-pattern 5 — Sharing mutable state across threads when immutable would work

```python
# ❌ Share mutable list
shared_list = []
lock = threading.Lock()

def worker(items):
    for item in items:
        result = process(item)
        with lock:
            shared_list.append(result)
```

**Tại sao bad:** Lock contention. Pick: each worker produces own list, merge at end:
```python
def worker(items):
    return [process(item) for item in items]   # pure
results = [r for batch in pool.map(worker, batches) for r in batch]
```

---

## 🔧 Patterns — best practices

### Pattern 1: Immutable + workers pull

Worker pool. Job queue immutable per job. No shared mutable state. Workers pull from queue → process → push result.

### Pattern 2: Sharding to reduce contention

Instead of 1 global counter with lock, use N counters (N = num cores). Each thread updates 1 specific shard. Sum at read time.

### Pattern 3: Lock-free with atomic CAS

For simple counters/flags, atomic ops > mutex.

### Pattern 4: Read-mostly with RCU (Read-Copy-Update)

Linux kernel pattern. Readers see consistent snapshot, writers create new version. Old version deferred-free.

### Pattern 5: Actor model (preview KU 11)

Each actor has private state. Communicate via message-passing. No shared memory → no race condition.

---

## 🌱 Advanced topics

### A1. Software Transactional Memory (STM)
Haskell STM, Clojure ref. Transaction over memory like DB. Compose atomic operations. No deadlock by construction.

### A2. Wait-free vs lock-free
- **Lock-free**: System makes progress (at least one thread). May starve some.
- **Wait-free**: Every thread completes in bounded steps.

Wait-free much harder. Practical lock-free libs: Java `ConcurrentHashMap`, Rust `crossbeam`.

### A3. Hardware memory ordering
x86: relatively strong (TSO — Total Store Order). ARM/PowerPC: weak ordering. C++/Rust `Acquire`/`Release`/`SeqCst` explicit memory ordering.

### A4. Apply cho DE / AI 2026
- **Flink keyed state** = single-thread per key (no lock)
- **Iceberg commit** = atomic file rename (CAS-like)
- **Kafka log** = single-writer per partition
- **Postgres MVCC** = multi-version concurrency, lock-free reads
- **LLM inference batching** = lock-free queues for request batching
- **vLLM continuous batching** = sophisticated lock-free scheduling

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. Race condition vs Data race — diff?
2. Deadlock 4 conditions Coffman — liệt kê.
3. Concurrency vs Parallelism — Rob Pike's quote?

### 🟡 Medium
4. Python GIL — implication cho threading? Khi nào dùng multiprocessing thay vì threading?
5. Lock ordering — explain với dining philosophers.
6. Atomic CAS lock-free counter — implement pseudo.

### 🔴 Hard
7. Double-checked locking pre-Java 5 broken. Vì sao? Fix?
8. Read-Copy-Update (RCU) Linux pattern — explain.
9. Postgres MVCC — explain isolation level vs lock-based.

> **6+/9** = sẵn sàng KU 11. **4-5** = đọc OSTEP Concurrency Parts 4-6 (Wisconsin free). **<4** = implement producer-consumer + dining philosophers.

---

## 🔗 Liên kết

- **[F02/07 Pure functions](./07-pure-functions-immutability.md)** — immutability avoid race
- **[F02/11 Async + CSP/Actor](./11-async-event-loop-csp-actor.md)** — alternative concurrency models
- **[F00/06 Idempotency](../F00-mental-models/06-idempotency.md)** — retry-safe operations
- **[F01/08 Recursion](../F01-cs-fundamentals/08-recursion-iteration.md)** — stack model
- **[D17 Stream Processing](../../../year-2-specialization/semester-3-data-engineering-deep/D17-stream-processing/)** — Flink keyed state

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **Hoare CSP** → `Hoare_CSP-CACM-Original.pdf` — original 1978 paper (10 pages, dense).
- **Pragmatic Functional Sample** → `Pragmatic_Functional-Sample-from-7Concurrency.pdf` — FP concurrency intro.

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):** ⭐

- **OSTEP (Wisconsin)** → `OSTEP_threads-intro.pdf`, `OSTEP_threads-api.pdf`, `OSTEP_threads-locks.pdf`, `OSTEP_threads-locks-usage.pdf`, `OSTEP_threads-cv.pdf`, `OSTEP_threads-sema.pdf`, `OSTEP_threads-bugs.pdf` — **bài đọc bắt buộc**. Full concurrency primer free.

📖 **Sách commercial:**
- **Brian Goetz et al., *Java Concurrency in Practice*** (2006) — JVM concurrency bible.
- **Maurice Herlihy & Nir Shavit, *The Art of Multiprocessor Programming*** — academic deep dive.
- **Paul McKenney, *Is Parallel Programming Hard, And, If So, What Can You Do About It?*** — free PDF, Linux kernel perspective.

📄 **Paper gốc:**
- Dijkstra (1965), *"Cooperating Sequential Processes"* — semaphore.
- Hoare (1974), *"Monitors: An Operating System Structuring Concept"*, CACM.
- Lamport (1978), *"Time, Clocks, and the Ordering of Events"*, CACM — happens-before.
- Brinch Hansen (1975) — *"The Programming Language Concurrent Pascal"*.
- Java JSR 133 — Java Memory Model.

---

**Đã đọc xong?**
✅ Tick → [F02/11 Async + Event loop + CSP/Actor](./11-async-event-loop-csp-actor.md).
