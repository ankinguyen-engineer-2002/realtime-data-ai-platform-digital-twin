# KU F02 / 11 — Async / Event loop + CSP / Actor models

> **Async/await** = cooperative concurrency. **Event loop** = single thread dispatches I/O completions. **CSP** (Communicating Sequential Processes, Hoare 1978) = thread + channels (Go). **Actor model** (Hewitt 1973, Erlang 1986) = isolated state + message-passing. Mỗi model giải quyết concurrency differently — pick đúng cho workload.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/10 Concurrency primitives](./10-concurrency-primitives.md)
**Related KUs:** [F02/07 Pure functions](./07-pure-functions-immutability.md) · [F11 Distributed theory](../F11-distributed-theory/)
**Đọc trong:** ~18 phút
**Mức độ:** Intermediate

---

## 🎯 Nó là gì? (Analogy đời sống)

**Nhà hàng** với 4 cách phục vụ:

### 1. Thread-per-customer (Mutex/Lock — KU 10)
- Mỗi khách = 1 phục vụ riêng. Mỗi phục vụ chia sẻ bếp (shared kitchen) → đua nhau giành cái nồi.
- → Phải có khoá khi dùng nồi. Phục vụ chờ nhau dùng.

### 2. Async / Event loop — 1 phục vụ siêu nhanh
- **Chỉ 1 phục vụ** chạy như Flash. Mỗi khách order → ghi note → đem cho bếp → đi tiếp khách kế.
- Khi bếp xong → phục vụ quay lại bưng ra.
- → **Không bao giờ block.** 1 phục vụ phục vụ 100 khách nếu order/serve không tốn lâu.
- Nhưng nếu khách yêu cầu **"đứng đợi tôi suy nghĩ"** (CPU heavy) → tất cả khách khác phải chờ.

### 3. CSP — channel + goroutine (Go)
- **Mỗi món có 1 quầy** (channel). Khách bỏ note vào quầy. Bếp lấy note từ quầy.
- Nhiều bếp song song lấy. Không ai biết của ai, chỉ thông qua quầy.
- → **Communication > shared memory.** Go slogan.

### 4. Actor — mỗi bếp 1 mailbox
- Mỗi đầu bếp có **hộp thư riêng**. Khách gửi tin "1 phở cho bàn 5" vào mailbox của bếp phở.
- Bếp xử lý tuần tự (single thread per actor). Không share state.
- → Erlang/Akka philosophy. Mỗi actor = "process" độc lập, fault-isolated.

→ **Mỗi model phù hợp 1 use case khác:**
- **Async** = I/O bound (web server, DB calls)
- **CSP** = pipeline + structured concurrency
- **Actor** = stateful entities (game NPC, IoT device, chat user)

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Core question:** Thread-with-locks (KU 10) work nhưng dễ bug + expensive (1 thread ~8MB stack). Cần concurrency cho 10K-100K simultaneous connections (C10K problem) — làm sao?
>
> **Why hard:** Threads scale kém: 10K threads = 80GB RAM cho stack alone, context switch overhead. Locks tạo deadlock + race. Need lighter-weight + safer abstractions.
>
> **What we need:** Hiểu 3 alternative models — **async/await** (one thread, cooperative, I/O), **CSP/channels** (goroutines + channels, Go), **actor model** (isolated state + messages, Erlang). Each solves different problem.

→ **Modern data infrastructure** xài hybrid: Postgres = process-per-conn (legacy), Node.js = async, Go = CSP, Erlang/Elixir = actor, Rust = ownership + tokio. **Knowing 4 models** = pick correctly per system.

---

## 📖 Định nghĩa chính thức

### **Async / await (cooperative concurrency)**

- **Coroutine** = function có thể **pause** giữa chừng + **resume**.
- **await** = pause + yield control to event loop.
- **Event loop** = scheduler chọn coroutine ready để chạy.
- Single OS thread handles 1000s of coroutines via I/O multiplexing.

```python
import asyncio

async def fetch(url):
    response = await http_get(url)   # pause here, scheduler can run other coros
    return response.body

async def main():
    results = await asyncio.gather(
        fetch("url1"),
        fetch("url2"),
        fetch("url3"),
    )
```

### **CSP (Communicating Sequential Processes)** — Hoare 1978

- **Process** = sequential unit of computation
- **Channel** = typed conduit for message passing
- **Send/Receive** = synchronization (blocking until other side ready, or buffered)
- Slogan: *"Don't communicate by sharing memory. Share memory by communicating."*

```go
// Go — CSP-inspired
ch := make(chan int)
go func() {
    ch <- 42      // send (block until receiver)
}()
value := <-ch     // receive
```

### **Actor model** — Hewitt 1973

- **Actor** = entity with:
  - Private state (no shared memory)
  - Mailbox (queue of incoming messages)
  - Behavior (function to process messages)
- Actor processes 1 message at a time, sequentially, from its mailbox
- Communicate via **send** (asynchronous) — fire and forget
- Can create child actors, supervise them
- "Let it crash" philosophy — fault tolerance

```erlang
% Erlang actor (process)
loop(State) ->
    receive
        {get, From} -> From ! {value, State}, loop(State);
        {set, V} -> loop(V);
        stop -> ok
    end.
```

### **Comparison**

| Model | State | Communication | Schedule |
|---|---|---|---|
| Threads + lock | Shared mutable | Lock + condvar | OS preemptive |
| Async / event loop | Shared (single thread) | callbacks/await | Cooperative yield |
| CSP / channels | Per-goroutine | Channels (sync or buffered) | M:N (M goroutines on N OS threads) |
| Actor | Per-actor private | Async messages | Actor system schedules |
| STM (KU 10 A1) | Transactional | Atomic blocks | Optimistic |

**Nguồn:** Hoare *CSP* (1978/1985) · Hewitt *"Actor Model"* (1973) · Joe Armstrong *Programming Erlang* · Modern: Akka docs, Go memory model, tokio docs.

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **Coroutine (Conway, 1958)** — concept of pausable function. Long forgotten until languages re-discovered.
- **Hewitt Actor Model (1973)** — Carl Hewitt at MIT — *"A Universal Modular ACTOR Formalism for Artificial Intelligence"*. Inspired by physics + concurrent processes.
- **Hoare CSP (1978)** — *"Communicating Sequential Processes"*, CACM. Formal calculus + practical channels.
- **Erlang (1986, Joe Armstrong, Ericsson)** — actor model for telecom switches. 9-nines uptime requirement.
- **Smalltalk** — message passing built-in.
- **Stackless Python (2001)** — coroutines on Python.
- **Twisted Python (2002)** — async networking framework, callback-based.
- **Node.js (2009)** — JavaScript event loop + async. Popularize "asynchronous I/O" mainstream.
- **Go (2009)** — goroutines + channels, CSP-inspired.
- **Akka (2010)** — actor framework on JVM, inspired by Erlang.
- **Python asyncio (2014, Python 3.4)** — first-class async/await syntax in 3.5.
- **Rust tokio (2017)** — async runtime + ownership = memory-safe async.
- **Today (2026):** Hybrid era — Web servers use async, distributed systems use actor (Akka, Orleans), pipelines use CSP (Go). Each tool's strength understood.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Coroutine | Coroutine | Pausable function |
| Generator | Generator | Iterator coroutine |
| Async / await | Async/await | Coroutine syntax |
| Event loop | Event loop | Scheduler for coroutines |
| Reactor | Reactor | Event loop pattern |
| Future / Promise | Future/Promise | Placeholder for async result |
| Goroutine | Goroutine | Go's lightweight thread |
| Channel | Channel | CSP communication primitive |
| Select | Select | Multiplex over channels |
| Buffered channel | Buffered channel | Channel with capacity |
| Actor | Actor | Isolated entity with mailbox |
| Mailbox | Mailbox | Actor's message queue |
| Send / Tell | Send/Tell | Async message send |
| Ask | Ask | Synchronous send-wait-reply |
| Supervisor | Supervisor | Actor that manages children |
| Let it crash | Let it crash | Fault tolerance philosophy |
| C10K | C10K | Concurrent 10,000 connections |
| Reactor pattern | Reactor | Single thread + event dispatch |
| Proactor pattern | Proactor | Completion-based async |
| epoll / kqueue / IOCP | epoll / kqueue / IOCP | OS I/O multiplexing APIs |
| Green thread | Green thread | User-space thread |
| Fiber | Fiber | Cooperative green thread |
| M:N threading | M:N threading | M user threads on N OS threads |

---

## 💡 Real-world examples

### Python asyncio — async/await

```python
import asyncio
import aiohttp

async def fetch(session, url):
    async with session.get(url) as response:
        return await response.text()

async def main():
    urls = [f"https://api.example.com/data/{i}" for i in range(100)]
    async with aiohttp.ClientSession() as session:
        tasks = [fetch(session, url) for url in urls]
        results = await asyncio.gather(*tasks)
    return results

# 100 concurrent HTTP requests on 1 thread
# Single thread, ~1MB memory total
# vs 100 threads = ~800MB
```

### Go — CSP channels

```go
package main

import "fmt"

func producer(ch chan<- int) {
    for i := 0; i < 10; i++ {
        ch <- i           // send to channel
    }
    close(ch)
}

func consumer(ch <-chan int, done chan<- bool) {
    for value := range ch {   // receive until closed
        fmt.Println(value)
    }
    done <- true
}

func main() {
    ch := make(chan int)
    done := make(chan bool)
    go producer(ch)
    go consumer(ch, done)
    <-done   // wait for consumer
}
```

### Erlang/Elixir — Actor

```elixir
# Elixir GenServer (built on actors)
defmodule Counter do
    use GenServer

    # Public API
    def start_link(init) do
        GenServer.start_link(__MODULE__, init)
    end

    def increment(pid) do
        GenServer.cast(pid, :increment)   # fire and forget
    end

    def value(pid) do
        GenServer.call(pid, :value)        # send + wait reply
    end

    # Callbacks
    def init(state), do: {:ok, state}
    def handle_cast(:increment, state), do: {:noreply, state + 1}
    def handle_call(:value, _from, state), do: {:reply, state, state}
end

{:ok, pid} = Counter.start_link(0)
Counter.increment(pid)
Counter.value(pid)   # 1
```

### Production examples — DSX Air

| System | Concurrency model |
|---|---|
| **PostgreSQL** | Process-per-connection (heavyweight, legacy) |
| **Postgres pgbouncer** | Async event loop in front of Postgres |
| **Redis** | Single-threaded event loop (mostly) |
| **Nginx** | Event-driven async (epoll/kqueue) |
| **Node.js APIs** | libuv event loop |
| **Python FastAPI / Starlette** | asyncio under hood |
| **Go API servers** | Goroutines + channels |
| **Akka data pipeline** | Actor model (used in Spark < 2.0 driver) |
| **Erlang/Elixir RabbitMQ** | Actor processes per queue/connection |
| **Apache Kafka** | Java + Reactor pattern + per-broker threads |
| **Flink stream processor** | Operator chains + actor-like task threads |

### When to pick which

| Workload | Best model |
|---|---|
| 10K HTTP connections, each makes DB call | **Async** (Node.js, Python FastAPI, Rust tokio) |
| ETL pipeline with stages | **CSP** (Go channels, Rust + tokio mpsc) |
| Distributed system with stateful entities (chat user, game NPC, IoT device) | **Actor** (Akka, Erlang, Orleans) |
| Math-heavy CPU computation 100% busy | **OS threads** (rayon Rust, OpenMP C++) |
| Long-running stream processor with windows | **Actor + state** (Flink, Akka Streams) |
| Real-time low-latency (game engine, HFT) | **OS threads + lock-free** |

---

## 🧮 Pseudocode — 3 models side-by-side  *(Erickson UIUC style)*

### Async/await

```
ASYNC FUNCTION fetch_url(url):
    response ← AWAIT http_get(url)         《pause, yield to event loop》
    body ← AWAIT response.read()           《pause again》
    return body

ASYNC FUNCTION main():
    urls ← ["a.com", "b.com", "c.com"]
    tasks ← MAP(fetch_url, urls)            《tasks not running yet》
    results ← AWAIT gather(tasks)           《run all concurrently, await all》
    return results

《Event loop pseudocode》
EVENT_LOOP:
    ready_queue ← empty
    while not done:
        《Check OS for I/O completions》
        completions ← POLL(epoll/kqueue)
        for each (fd, event) in completions:
            coro ← waiting_on[fd]
            ready_queue.push(coro)

        《Run ready coroutines until they yield》
        while ready_queue not empty:
            coro ← ready_queue.pop()
            RUN_UNTIL_YIELD(coro)
```

### CSP / Channels

```
CHANNEL ch                                    《create》

GOROUTINE producer:
    for i in 1..10:
        SEND ch ← i                          《block until receiver ready (unbuffered)》

GOROUTINE consumer:
    while not closed(ch):
        v ← RECEIVE ch                       《block until sender sends》
        PROCESS(v)
```

### Actor

```
ACTOR Counter:
    state: int = 0

    receive message:
        case Increment:
            state ← state + 1
        case GetValue(reply_to):
            SEND reply_to ← state
        case Stop:
            TERMINATE

《Use》
let actor ← SPAWN Counter()
SEND actor ← Increment
SEND actor ← Increment
let reply ← ASK actor ← GetValue           《send + wait reply》
print(reply)                                《2》
```

---

## 📊 Cost annotation table — concurrency model comparison  *(Sedgewick Princeton style)*

| Aspect | OS thread + lock | Async / event loop | CSP / channels | Actor |
|---|---|---|---|---|
| **Memory / unit** | ~8 MB stack | ~few KB coro | ~2-8 KB goroutine | ~few KB actor |
| **Max units** | ~10K (RAM limit) | 100K+ | 1M+ goroutines (Go) | millions (Erlang) |
| **Context switch** | OS kernel ~µs | User-space ~ns | User-space ~ns | User-space ~ns |
| **CPU-bound parallelism** | ✅ Multi-core | ❌ Single thread | ✅ M:N scheduler | ✅ Many cores |
| **I/O-bound** | OK | ✅ Excellent | ✅ Good | ✅ Good |
| **Code complexity** | Medium (locks) | Low (linear code) | Medium (channel patterns) | Medium (mailbox) |
| **Debugging** | Hard (race) | Medium (callback hell?) | Medium (channel deadlock) | Medium (msg tracing) |
| **Fault isolation** | None | None (one bug crashes all) | Partial (goroutine panic) | ✅ Excellent (let it crash) |
| **Distributed (across nodes)** | Hard | Hard | Hard | ✅ Easy (location transparency) |
| **Best for** | CPU parallel | I/O concurrent | Pipelines | Stateful distributed |

### Famous benchmarks

| Server | Concurrent connections (C10K era) |
|---|---|
| Apache (process/thread per conn) | ~1K, RAM limit |
| Nginx (event loop) | 100K easily |
| Node.js (async) | 100K easily |
| Go (goroutine) | 1M+ |
| Erlang | 2.2M (WhatsApp 2012) |

→ Async + actor scale 100-1000× better cho I/O bound workload.

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Block in async function

```python
import asyncio, time

async def slow_task():
    time.sleep(5)        # ❌ BLOCKS event loop — no other coro can run for 5s!
    return "done"

await slow_task()
```

**Tại sao bad:** Sync sleep blocks entire event loop. Pick:
```python
await asyncio.sleep(5)   # async sleep, yields to event loop
```

### Anti-pattern 2 — CPU-heavy in async

```python
async def hash_password(pw):
    return bcrypt.hashpw(pw, salt)   # ❌ CPU heavy ~100ms, blocks
```

**Tại sao bad:** Async = cooperative, no preemption. Heavy CPU = starves other coros. Pick: offload to threadpool:
```python
import asyncio
async def hash_password(pw):
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, bcrypt.hashpw, pw, salt)
```

### Anti-pattern 3 — Forget to close channel (Go)

```go
// ❌ Producer never closes channel
go func() {
    for i := 0; i < 10; i++ {
        ch <- i
    }
    // forgot close(ch)
}()

for v := range ch {  // ❌ blocks forever after 10 values
    fmt.Println(v)
}
```

**Tại sao bad:** `for range` waits for `close()`. Pick: defer close, or signal end with sentinel.

### Anti-pattern 4 — Actor with synchronous DB call

```scala
class UserActor extends Actor {
    def receive = {
        case GetUser(id) =>
            val user = db.query(s"SELECT * FROM users WHERE id=$id")  // ❌ block actor
            sender() ! user
    }
}
```

**Tại sao bad:** Actor processes 1 message at a time. Blocking call = mailbox backed up. Pick: async DB driver, or dedicate actor pool for DB.

### Anti-pattern 5 — Send too many messages

```scala
// ❌ Flood actor with millions of messages
for (i <- 1 to 10_000_000) {
    actor ! IncrementBy(1)
}
```

**Tại sao bad:** Mailbox grows unbounded → OOM. Pick: batch messages, use bounded mailbox with backpressure.

---

## 🔧 Patterns — practical

### Pattern 1: Async fan-out

```python
async def fetch_all(urls):
    return await asyncio.gather(*[fetch(u) for u in urls])
```

### Pattern 2: CSP pipeline

```go
// 3-stage pipeline
func stage1(in <-chan Item) <-chan Item {
    out := make(chan Item)
    go func() {
        defer close(out)
        for item := range in { out <- transform1(item) }
    }()
    return out
}
// Compose: stage1(stage2(stage3(input)))
```

### Pattern 3: Actor supervisor tree (Erlang/Akka)

```
Top supervisor
├── Database actor
├── Cache actor
└── API supervisor
    ├── Worker1
    ├── Worker2
    └── Worker3
```

Supervisor monitors children. On crash, restart based on strategy.

### Pattern 4: Backpressure

When producer faster than consumer:
- **Async**: bounded queue + `await put()` (blocks producer)
- **CSP**: buffered channel with capacity
- **Actor**: bounded mailbox + drop or block

### Pattern 5: Structured concurrency (Trio Python, Java structured concurrency)

Group of related coroutines treated as unit. Cancel together, wait together. Better than `gather` for safety.

---

## 🌱 Advanced topics

### A1. Workflow engines (Temporal, Cadence, Step Functions)
Durable async — survive process restart. State persisted in DB. Like actors but with full event sourcing.

### A2. Reactive Streams (Akka Streams, Project Reactor)
CSP + async + backpressure as first-class. Used in JVM data processing.

### A3. io_uring (Linux 5.1+, 2019)
New async I/O API. Submit operations as ring buffer entries. Up to 10× faster than epoll for some workloads. Tokio + libuv migrating.

### A4. Apply cho DE / AI 2026
- **Flink Async I/O** = async fan-out for external lookups
- **Anthropic streaming response** = async generator
- **LangChain agent loop** = sequential async + parallel tool calls
- **vLLM continuous batching** = sophisticated scheduler over actor-like model

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. Async/await vs thread — diff?
2. CSP slogan ("don't communicate by sharing memory") — explain.
3. Actor model — what's mailbox?

### 🟡 Medium
4. Why blocking call in async function bad? Show example.
5. Goroutine vs OS thread — memory + count.
6. Erlang "let it crash" — explain philosophy.

### 🔴 Hard
7. Implement actor in pseudo using thread + mailbox + dispatcher.
8. CSP deadlock — show with 2 channels.
9. Trong DSX Air, async/CSP/actor đâu hợp? (Hint: Flink, Anthropic, Akka legacy).

> **6+/9** = sẵn sàng KU 12. **4-5** = đọc Akka docs Chapter 1 + Go Tour. **<4** = code small async + Go channel.

---

## 🔗 Liên kết

- **[F02/10 Concurrency primitives](./10-concurrency-primitives.md)** — foundation
- **[F02/07 Pure functions](./07-pure-functions-immutability.md)** — immutability enable safe concurrency
- **[F00/07 Backpressure](../F00-mental-models/07-backpressure.md)** — handle flow control
- **[F11 Distributed theory](../../semester-2-systems-theory/F11-distributed-theory/)** — actor + CAP
- **[D17 Stream Processing](../../../year-2-specialization/semester-3-data-engineering-deep/D17-stream-processing/)** — Flink async I/O

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **Hoare CSP** → `Hoare_CSP-CACM-Original.pdf` — original 1978 paper. Dense but foundational.
- **Pragmatic Functional sample** → `Pragmatic_Functional-Sample-from-7Concurrency.pdf` — Butcher 7 Concurrency Models intro.

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **OSTEP threads chapters** — concurrency primitives complementary.
- **Beej IPC** → `Beej_IPC.pdf` — Unix pipes (CSP-inspired).

📖 **Sách commercial:**
- **Joe Armstrong, *Programming Erlang*** (2007/2013) — actor model bible.
- **Paul Butcher, *Seven Concurrency Models in Seven Weeks*** (2014) — survey 7 models.
- **Brian Goetz, *Java Concurrency in Practice*** — futures + executors.

📄 **Paper gốc:**
- Hewitt (1973), *"A Universal Modular ACTOR Formalism for Artificial Intelligence"*.
- Hoare (1978), *"Communicating Sequential Processes"*, CACM.
- Armstrong (2003), *"Making reliable distributed systems in the presence of software errors"*, PhD thesis (Erlang foundation).
- Pike (2012), [Concurrency Is Not Parallelism](https://blog.golang.org/concurrency-is-not-parallelism) — Go blog.
- Akka documentation — [akka.io/docs/](https://akka.io/docs/).
- Tokio book — [tokio.rs/tokio/tutorial](https://tokio.rs/tokio/tutorial).

---

**Đã đọc xong?**
✅ Tick → [F02/12 Error handling: Exceptions vs Result/Either](./12-error-handling.md).
