# KU F02 / 13 — Essential Design Patterns (GoF subset)

> **Design Patterns** = "reusable solutions to commonly occurring problems" — Gang of Four (GoF, 1994). 23 patterns chia 3 nhóm: Creational, Structural, Behavioral. **Không học hết 23** — học **8 patterns essential** thường gặp trong DE/AE/AI code. Pick đúng pattern = code maintainable. Lạm dụng = "pattern fever" complexity.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/04 OOP fundamentals](./04-oop-fundamentals.md) · [F02/05 Composition](./05-composition-over-inheritance.md) · [F02/06 SOLID](./06-solid-principles.md)
**Related KUs:** [F02/14 Testing philosophy](./14-testing-philosophy.md)
**Đọc trong:** ~20 phút
**Mức độ:** Intermediate

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn xây **nhà**. Có **mẫu thiết kế chuẩn** cho từng vấn đề:

### Creational — "Cách xây cái gì"
- **Factory**: Có lò sản xuất gạch → mỗi lần cần gạch chỉ gọi "lò ơi cho viên". Không tự đắp.
- **Builder**: Xây nhà phức tạp → có **thợ chỉ huy** từng bước (móng → tường → mái → cửa). Mỗi bước có thể tuỳ chỉnh.
- **Singleton**: Tủ điện chính = **chỉ có 1**. Không ai được xây thêm.

### Structural — "Cách bố trí phòng"
- **Adapter**: Ổ điện châu Âu → adapter sang ổ Việt Nam. Bộ chuyển đổi.
- **Decorator**: Cốc cafe → thêm **đường** + **sữa** + **kem** mỗi lần là 1 lớp bọc.
- **Facade**: Mặt tiền nhà sang trọng → khách thấy đẹp + dễ vào. Nội thất phức tạp ẩn bên trong.

### Behavioral — "Cách các phòng giao tiếp"
- **Strategy**: Cùng món **gà chiên** → có **3 cách chiên**: dầu, lò, không khí. Đầu bếp swap chiến thuật theo yêu cầu.
- **Observer**: Chuông cửa nhà → khi có khách đến, **mọi người trong nhà** nghe được. Subscriber pattern.
- **Iterator**: Tủ sách → đi từng cuốn (next, prev). Không quan tâm tủ tổ chức thế nào.

→ **Patterns = vocabulary chung của developers.** Khi nói "Factory pattern", ai cũng hiểu ngay.

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Câu hỏi cốt lõi:** Cho 1 vấn đề OO design (ví dụ: "muốn tạo objects mà không hard-code tên class", "muốn UI tự update khi data đổi"), làm sao **tránh phát minh lại bánh xe** + có solution đã được industry kiểm chứng?
>
> **Vì sao khó:** Nếu không có patterns, mỗi engineer tự design → variation lớn → maintain địa ngục. Patterns cung cấp **vocabulary chung + reference solutions**. Nhưng lạm dụng → tạo ra `AbstractFactoryStrategySingletonProxyFactory` = "enterprise Java nightmare" nổi tiếng.
>
> **Điều ta cần:** Học **8-10 essential patterns** xuất hiện nhiều trong real code (Strategy, Observer, Decorator, Adapter, Factory, Singleton, Iterator, Composite, Template Method, Command). Biết khi nào dùng + khi nào **không cần** (pattern không phải lúc nào cũng là câu trả lời).

→ **Thực tế 2024-2026:** Nhiều GoF patterns đã "**tan vào ngôn ngữ**" — Iterator = `for x in xs` (Python). Strategy = first-class function. Observer = pub/sub library. Bạn không còn "design" pattern — bạn chỉ dùng feature ngôn ngữ.

---

## 📖 Định nghĩa chính thức — 8 essential patterns

### **1. Strategy (Behavioral)**
Đóng gói thuật toán vào object, **swap (đổi) ở runtime**.

```python
class PaymentProcessor(Protocol):
    def charge(self, amount: Decimal) -> str: ...

class StripeProcessor: ...
class PayPalProcessor: ...

# Use:
processor: PaymentProcessor = pick_processor(country)
processor.charge(100)
```

### **2. Observer / Pub-Sub (Behavioral)**
Publisher thông báo nhiều subscribers khi có event xảy ra.

```python
class EventBus:
    def __init__(self): self.subs = {}
    def subscribe(self, topic, callback):
        self.subs.setdefault(topic, []).append(callback)
    def publish(self, topic, data):
        for cb in self.subs.get(topic, []):
            cb(data)
```

### **3. Decorator (Structural)**
Thêm behavior cho object **không sửa class gốc**. Wrap object trong object khác.

```python
def with_logging(fn):
    def wrapper(*args, **kw):
        print(f"calling {fn.__name__}")
        return fn(*args, **kw)
    return wrapper

@with_logging
def process(): ...
```

### **4. Adapter (Structural)**
Chuyển đổi interface này sang interface khác. Như ổ cắm châu Âu → Việt Nam.

```python
class StripeToGenericAdapter:
    def __init__(self, stripe_client):
        self.stripe = stripe_client
    def charge(self, amount):
        return self.stripe.create_charge(int(amount * 100), 'usd')
```

### **5. Factory Method (Creational)**
Tách quá trình tạo object khỏi nơi dùng. Giấu logic chọn class nào.

```python
class PaymentFactory:
    @staticmethod
    def create(provider: str) -> PaymentProcessor:
        if provider == "stripe": return StripeProcessor()
        if provider == "paypal": return PayPalProcessor()
        if provider == "momo": return MoMoProcessor()
        raise ValueError(provider)
```

### **6. Singleton (Creational)** — dùng tiết kiệm
Chỉ duy nhất 1 instance trong toàn chương trình.

```python
class DBConnection:
    _instance = None
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
```

→ Thường là **anti-pattern** vì = global state, khó test. Ưu tiên Dependency Injection.

### **7. Iterator (Behavioral)**
Duyệt collection mà không lộ cấu trúc bên trong (linked list hay array đều dùng cùng cách `for x in xs`).

```python
# Built into Python via __iter__ / __next__
for item in my_collection:
    process(item)
```

→ Đã "tan vào ngôn ngữ" — Python `for`, JS `for-of`, không cần "design pattern" nữa.

### **8. Composite (Structural)**
Cây các object + interface đồng nhất cho cả leaf (lá) và branch (nhánh) — như file/folder trong file system.

```python
class FileSystemEntry(Protocol):
    def size(self) -> int: ...

class File:
    def size(self): return self.bytes

class Directory:
    def __init__(self, entries: list[FileSystemEntry]):
        self.entries = entries
    def size(self):
        return sum(e.size() for e in self.entries)   # recursive composite
```

**Nguồn:** Gang of Four *Design Patterns: Elements of Reusable Object-Oriented Software* (1994) — Gamma, Helm, Johnson, Vlissides. Refactoring.Guru *Dive Into Design Patterns* (Shvets, 2018). Freeman *Head First Design Patterns*.

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **Christopher Alexander (1977)** — *A Pattern Language* — architect (buildings, not code) introduced "pattern" concept. Inspired CS.
- **Kent Beck + Ward Cunningham (1987)** — first software patterns paper at OOPSLA.
- **Gang of Four (Gamma, Helm, Johnson, Vlissides — 1994)** — *Design Patterns* book. 23 patterns. Used Smalltalk + C++ examples.
- **POSA series (1996-2007)** — patterns for distributed systems, concurrent programming.
- **Domain-Driven Design (Evans, 2003)** — patterns for domain modeling (Entity, Value Object, Aggregate, Repository).
- **Refactoring (Fowler, 1999)** — patterns + refactoring catalog.
- **Patterns in functional programming** — Hughes "Why FP Matters" + monad as design pattern.
- **Refactoring.Guru (Alexander Shvets, 2018)** — modern visual rewrite, available in **8 languages** (EN/中文/日本語/한국어/Français/Español/русский/Polski/Ukrainian).
- **Today (2026):** Patterns acknowledged as **vocabulary**, not solutions. Many "dissolve" into language features (iterator, lambda, async/await). Critique: GoF patterns often workaround for missing language features.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Pattern | Pattern | Reusable solution to common problem |
| Anti-pattern | Anti-pattern | Common but harmful "solution" |
| GoF | Gang of Four | Gamma, Helm, Johnson, Vlissides |
| Creational | Creational | Patterns for object creation |
| Structural | Structural | Patterns for class composition |
| Behavioral | Behavioral | Patterns for object interaction |
| Strategy | Strategy | Swap algorithm at runtime |
| Observer | Observer | Pub-sub event notification |
| Decorator | Decorator | Wrap to add behavior |
| Adapter | Adapter | Convert interface |
| Factory | Factory | Encapsulate creation |
| Singleton | Singleton | Exactly 1 instance |
| Composite | Composite | Tree of uniform parts |
| Iterator | Iterator | Sequential access |
| Template Method | Template Method | Skeleton with hooks |
| Command | Command | Encapsulate request as object |
| Chain of Responsibility | Chain of Responsibility | Pass through chain of handlers |
| Visitor | Visitor | Operations on heterogeneous tree |
| Bridge | Bridge | Separate abstraction from impl |
| Proxy | Proxy | Stand-in for another object |
| Facade | Facade | Simplified interface to subsystem |
| State | State | Behavior change based on internal state |
| MVP | Memento | Capture state for undo |
| Builder | Builder | Step-by-step complex object construction |
| Prototype | Prototype | Clone existing instance |

---

## 💡 Real-world examples — patterns trong DSX Air

### Strategy — Spark partitioner

```scala
trait Partitioner {
    def numPartitions: Int
    def getPartition(key: Any): Int
}

class HashPartitioner extends Partitioner { ... }
class RangePartitioner extends Partitioner { ... }
class CustomPartitioner extends Partitioner { ... }

// Spark RDD
rdd.partitionBy(new HashPartitioner(100))   // swap strategy
```

### Observer — Kafka consumer

```python
from kafka import KafkaConsumer

consumer = KafkaConsumer('events', group_id='analytics')
for msg in consumer:
    process(msg)         # subscriber notified per message
```

### Decorator — Python `@cached_property`, `@retry`, `@deprecated`

```python
from functools import lru_cache, cached_property
from tenacity import retry

@retry(stop=stop_after_attempt(3))
@lru_cache(maxsize=1000)
def fetch_user(id):
    return db.get(id)
```

### Adapter — Iceberg FileIO

```java
// Iceberg FileIO interface — adapter pattern
interface FileIO {
    InputFile newInputFile(String path);
    OutputFile newOutputFile(String path);
}

class HadoopFileIO implements FileIO { ... }   // wrap Hadoop FileSystem
class S3FileIO implements FileIO { ... }        // wrap AWS S3 SDK
class GCSFileIO implements FileIO { ... }
```

### Factory — dbt adapter

```python
# dbt creates adapter via factory based on profile.yml
adapter = AdapterFactory.create(profile.type)  # postgres, snowflake, bigquery, ...
```

### Singleton — Spark SparkSession

```python
spark = SparkSession.builder.appName("app").getOrCreate()
# Single SparkSession per JVM
```

### Composite — JSON tree

```python
# JSON value is composite (recursive structure)
data = {
    "users": [
        {"name": "A", "orders": [...]},
        {"name": "B", "orders": [...]}
    ]
}
# Treat list/dict/scalar uniformly via recursive functions
```

### Production patterns matrix

| Pattern | DE/AE/AI tool example |
|---|---|
| **Strategy** | Spark partitioner, Kafka serializer, Flink keyselector |
| **Observer** | Kafka consumer, dbt run notifications, Airflow event listeners |
| **Decorator** | Python `@retry`, `@cache`, Spark transformations chain |
| **Adapter** | Iceberg FileIO, dbt adapter, Kafka Connect connectors |
| **Factory** | dbt adapter factory, Spark session builder, Pydantic create_model |
| **Builder** | Spark DataFrame builder pattern, Pydantic BaseModel |
| **Composite** | JSON tree, AST in compilers, Spark LogicalPlan, file system trees |
| **Iterator** | All collections, Spark RDD/DataFrame iteration |
| **Visitor** | Spark Catalyst plan rewriter, AST walkers |
| **Chain of Responsibility** | Spring Security filter chain, Airflow operator chain |
| **Template Method** | Spark `RDD.compute()` hook, Airflow `BaseOperator.execute()` |
| **Command** | Kafka Connect SinkTask, Spark task scheduling |
| **Proxy** | RPC stubs, ORM lazy loading |
| **Facade** | dbt CLI wrapping internal complexity, FastAPI hiding Starlette/uvicorn |
| **State** | Connection lifecycle (idle, busy, error), Flink job states |

---

## 🧮 Pseudocode — 4 patterns deep  *(Erickson UIUC style)*

### Strategy

```
INTERFACE SortStrategy:
    sort(data: List) -> List

CLASS QuickSortStrategy IMPLEMENTS SortStrategy:
    sort(data):
        return QUICKSORT(data)

CLASS MergeSortStrategy IMPLEMENTS SortStrategy:
    sort(data):
        return MERGESORT(data)

CLASS Sorter:
    strategy: SortStrategy

    constructor(s):
        this.strategy ← s

    do_sort(data):
        return this.strategy.sort(data)

《Use》
sorter ← new Sorter(new QuickSortStrategy())
sorter.do_sort([3, 1, 2])
sorter.strategy ← new MergeSortStrategy()      《swap at runtime》
sorter.do_sort([9, 8, 7])
```

### Observer

```
CLASS EventEmitter:
    subscribers: Map<String, List<Function>>

    on(event, callback):
        this.subscribers[event].append(callback)

    emit(event, data):
        for each cb in this.subscribers[event]:
            cb(data)

《Use》
bus ← new EventEmitter()
bus.on("user_created", λu → send_welcome_email(u))
bus.on("user_created", λu → log("New user: " + u.email))
bus.emit("user_created", new_user)
《All subscribers receive》
```

### Decorator (function composition)

```
function with_logging(fn):
    return λargs → {
        log("calling " + fn.name)
        result ← fn(args)
        log("result: " + result)
        return result
    }

function with_timing(fn):
    return λargs → {
        start ← now()
        result ← fn(args)
        log("took " + (now() - start) + "ms")
        return result
    }

《Compose decorators》
process_decorated ← with_logging(with_timing(process))
process_decorated(input)
```

### Composite

```
INTERFACE Component:
    operation()

CLASS Leaf IMPLEMENTS Component:
    operation():
        return single_unit_work()

CLASS Composite IMPLEMENTS Component:
    children: List<Component>

    operation():
        results ← []
        for each child in this.children:
            results.append(child.operation())
        return COMBINE(results)         《uniform interface》
```

---

## 📊 Cost annotation table — when each pattern fits  *(Sedgewick Princeton style)*

| Pattern | Use when | Don't use when |
|---|---|---|
| **Strategy** | Multiple algorithms, swap runtime | Algorithm fixed, only 1 |
| **Observer** | One-to-many event notification | One-to-one direct call sufficient |
| **Decorator** | Add behavior without subclassing | Single fixed behavior |
| **Adapter** | Integrate incompatible interfaces | Interfaces already match |
| **Factory** | Hide creation complexity, pick at runtime | `new` directly fine |
| **Singleton** | Truly global resource | Pass as dependency (testability) |
| **Composite** | Recursive structure with uniform ops | Flat or asymmetric |
| **Iterator** | Custom traversal logic | Built into language |
| **Builder** | Object with many optional fields | Constructor with few args |
| **Template Method** | Algorithm skeleton + variations | Composition + Strategy cleaner |
| **Visitor** | Many ops on stable hierarchy | Hierarchy changes often |
| **Proxy** | Lazy load, access control, remoting | Direct access fine |

**Pattern frequency in real codebases (empirical):**

| Pattern | Frequency in OSS | Notes |
|---|---|---|
| Strategy | Very high | Often via lambdas/functions |
| Iterator | Universal | Built into language |
| Factory | High | Hidden in frameworks |
| Observer | High | pub/sub frameworks |
| Decorator | High | Python `@`, JS HOC |
| Adapter | High | Integration code |
| Singleton | Medium | Used + abused |
| Template Method | Medium | Framework hooks |
| Composite | Medium | Tree/AST code |
| Builder | Medium | Fluent builders (Spark, OkHttp) |
| Visitor | Low | Compiler/AST work |
| Chain of Responsibility | Low | Middleware (Express, FastAPI) |
| Memento | Low | Undo systems |
| Flyweight | Low | Memory optimization |

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Lạm dụng Singleton

```python
# ❌ Dùng Singleton cho mọi thứ
class UserService(Singleton): ...
class OrderService(Singleton): ...
class EmailService(Singleton): ...
# Hidden global state — test phải chạy tuần tự, không mock được
```

**Vì sao bad:** Singleton = global state = không testable. Pick **Dependency Injection** (truyền dependency vào constructor):
```python
class OrderService:
    def __init__(self, user_service, email_service):
        self.user_service = user_service
        self.email_service = email_service
```

### Anti-pattern 2 — Over-engineering với pattern

```python
# ❌ Style "AbstractSingletonProxyFactoryBean" của Java enterprise
class StringConcatenator(AbstractStringOperationStrategy):
    @staticmethod
    def get_instance() -> 'StringConcatenator':
        return StringConcatenatorFactory.create().build()
# Chỉ muốn nối 2 string — viết 20 dòng + 3 abstraction layers
```

**Vì sao bad:** Pattern là **công cụ**, không phải **mục tiêu**. Vấn đề đơn giản = code đơn giản:
```python
result = a + b
```

### Anti-pattern 3 — Visitor for stable types in language with pattern matching

```scala
// ❌ Visitor in Scala when sealed trait + match work
trait Shape
case class Circle(r: Double) extends Shape
case class Square(s: Double) extends Shape

trait Visitor[R] {
    def visit(c: Circle): R
    def visit(s: Square): R
}

// Use:
val visitor = new AreaVisitor()
shape.accept(visitor)
```

**Vì sao bad:** Trong Scala/Rust với sealed types + pattern matching, code đơn giản hơn nhiều:
```scala
val area = shape match {
    case Circle(r) => math.Pi * r * r
    case Square(s) => s * s
}
```

### Anti-pattern 4 — Factory cho everything

```python
# ❌ Factory for trivial creation
class IntegerFactory:
    @staticmethod
    def create(n: int) -> int:
        return int(n)
# Just use int() directly
```

**Vì sao bad:** YAGNI (You Ain't Gonna Need It). Factory chỉ có giá trị khi việc tạo phức tạp (nhiều implementation, có config logic).

### Anti-pattern 5 — Observer leak

```javascript
// ❌ Subscribe but never unsubscribe
class Component {
    constructor() {
        eventBus.on('update', () => this.handleUpdate());
    }
    // No `destroy()` removing listener
}
// Memory leak — components garbage but listeners remain
```

**Vì sao bad:** Lifecycle mismatch — listener tồn tại lâu hơn component → memory leak. Luôn ghép `subscribe` với `unsubscribe`.

---

## 🔧 Patterns — modern reality

### Modern alternative: function-first

```python
# Strategy via functions (no class needed)
sorters = {
    'quicksort': quicksort,
    'mergesort': mergesort,
}
sort_fn = sorters[user_choice]
result = sort_fn(data)
```

### Modern alternative: language features

| GoF Pattern | Modern alternative |
|---|---|
| Iterator | `for x in xs` |
| Strategy | First-class function / lambda |
| Observer | `RxJS`, `asyncio.Event`, pub-sub library |
| Singleton | DI container with singleton lifetime |
| Command | Function + closure |
| Visitor | Pattern matching (Rust, Scala, Java 21) |
| Builder | Named args / dataclass with defaults |
| Adapter | Trait/interface in Rust/Go |

### When to still apply GoF

- **Mature codebase** with stable abstractions
- **Framework code** users will extend
- **Cross-team API contracts**
- **Mainstream OOP languages** (Java, C#) without modern features

---

## 🌱 Advanced topics

### A1. Patterns in functional programming
- **Functor** = generalization of Strategy / map
- **Monad** = Strategy for sequencing effects
- **Foldable** = generalization of Composite
- **Type classes** = ad-hoc polymorphism / Strategy

### A2. Architectural patterns (beyond GoF)
- **MVC, MVVM, MVP** (UI)
- **Repository** (data access)
- **CQRS** (Command Query Responsibility Segregation)
- **Event Sourcing**
- **Saga** (distributed transactions)
- **Circuit Breaker** (resilience)
- **Bulkhead** (isolation)

### A3. Apply cho DE / AI 2026
- **Strategy** = Spark partitioner, Flink keyselector
- **Decorator** = Python `@cache`, `@retry`, `@trace`
- **Observer** = Kafka consumer, Airflow scheduler
- **Adapter** = Iceberg FileIO, dbt adapter, LangChain LLM wrapper
- **Factory** = Spark session builder, dbt adapter factory
- **Composite** = JSON tree, Spark LogicalPlan, AST
- **Visitor** = Spark Catalyst rewrite rules
- **Circuit Breaker** = LLM API calls với fallback
- **Saga** = distributed transactions across microservices

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. GoF 23 patterns chia 3 nhóm — kể tên.
2. Strategy pattern — explain với 1 ví dụ.
3. Singleton pattern thường bị critique. Vì sao?

### 🟡 Medium
4. Decorator pattern — show Python `@decorator` syntax.
5. Adapter vs Bridge — diff?
6. Cho 1 ví dụ patterns dissolve vào language modern.

### 🔴 Hard
7. Visitor pattern vs ADT pattern matching — trade-off.
8. CQRS + Event Sourcing — explain.
9. Trong DSX Air, choose 3 patterns + explain where applied.

> **6+/9** = sẵn sàng KU 14. **4-5** = đọc Refactoring.Guru top 8 patterns. **<4** = implement Strategy + Observer + Decorator from scratch.

---

## 🔗 Liên kết

- **[F02/04 OOP fundamentals](./04-oop-fundamentals.md)** — context cho patterns
- **[F02/05 Composition over Inheritance](./05-composition-over-inheritance.md)** — preferable
- **[F02/06 SOLID](./06-solid-principles.md)** — principles patterns implement
- **[F02/09 ADT](./09-adt-pattern-matching-monads.md)** — FP alternative to Visitor

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **Refactoring.Guru Design Patterns (Shvets)** → `RefactoringGuru_Design-Patterns-Demo_*.pdf` — **8 ngôn ngữ** EN/ZH/JA/KO/FR/ES/RU/PL/UK. **Bài đọc bắt buộc**. Modern + visual.
- **Design Patterns Debrecen Univ (Jeszenszky)** → `Jeszenszky_Design-Patterns-UnideDebrecen.pdf` — academic treatment.
- **Game Programming Patterns sample (Nystrom)** → `Nystrom_Game-Programming-Patterns_sample.pdf` — game-specific patterns.

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **Nystrom Crafting Interpreters sample** → `Nystrom_CraftingInterpreters_sample.pdf` — Visitor pattern in compiler.

📖 **Sách commercial:**
- **Gamma, Helm, Johnson, Vlissides, *Design Patterns: Elements of Reusable Object-Oriented Software*** (1994) — original GoF.
- **Eric Freeman et al., *Head First Design Patterns*** (2004/2020) — visual intro.
- **Martin Fowler, *Patterns of Enterprise Application Architecture*** — backend patterns.
- **Vaughn Vernon, *Implementing Domain-Driven Design*** — DDD patterns.

📄 **Online + reference:**
- **Refactoring.Guru** — [refactoring.guru/design-patterns](https://refactoring.guru/design-patterns) — interactive examples 8 languages.
- **Microservices.io** — Chris Richardson's distributed patterns.
- **Java Design Patterns iluwatar** — [github.com/iluwatar/java-design-patterns](https://github.com/iluwatar/java-design-patterns) — Java implementations.

---

**Đã đọc xong?**
✅ Tick → [F02/14 Testing philosophy + Property-based testing](./14-testing-philosophy.md).
