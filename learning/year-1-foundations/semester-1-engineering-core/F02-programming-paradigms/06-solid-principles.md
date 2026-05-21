# KU F02 / 06 — SOLID principles

> **SOLID** = 5 nguyên tắc thiết kế OOP do **Robert C. Martin** (Uncle Bob) coined (2000-2003). **S**ingle Responsibility, **O**pen-Closed, **L**iskov Substitution, **I**nterface Segregation, **D**ependency Inversion. Apply đúng = code maintainable + testable + extensible. Apply sai (over-engineer) = abstraction hell.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/04 OOP fundamentals](./04-oop-fundamentals.md) · [F02/05 Composition over Inheritance](./05-composition-over-inheritance.md)
**Related KUs:** [F02/13 Design Patterns](./13-design-patterns.md) · [F02/14 Testing philosophy](./14-testing-philosophy.md) · [F00/10 Premature optimization](../F00-mental-models/10-premature-optimization.md)
**Đọc trong:** ~18 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn quản lý **nhà hàng 5 tầng**. 5 quy tắc vàng:

### S — Single Responsibility ("Mỗi bộ phận 1 việc")
- Bếp chỉ nấu. Phục vụ chỉ phục vụ. Thu ngân chỉ tính tiền.
- Nếu bếp vừa nấu vừa tính tiền vừa lau bàn → ai nghỉ thì cả nhà hàng đổ.

### O — Open-Closed ("Mở mở rộng, đóng sửa đổi")
- Thêm món mới = thêm trang vào menu. **Không sửa** menu đã in cho khách cũ.
- Thêm hình thức thanh toán QR → mở rộng, không sửa quy trình thu ngân tiền mặt.

### L — Liskov Substitution ("Thay người vẫn vận hành")
- Bếp trưởng nghỉ, bếp phó thay → khách không nhận ra khác.
- Bếp phó **phải tuân thủ tất cả contract** (menu, chất lượng, thời gian).

### I — Interface Segregation ("Đừng bắt người ta học việc không cần")
- Đào tạo phục vụ: chỉ dạy phục vụ. Không bắt học nấu + sửa máy lạnh + làm marketing.
- Mỗi interface chuyên 1 việc, đừng "fat interface" với 50 methods.

### D — Dependency Inversion ("Sếp nói policy, lính thực hiện")
- Manager không nên gọi thẳng tới thợ điện cụ thể "anh A". Manager nói "cần thợ điện" → HR phân công.
- Code: phụ thuộc vào **abstraction** (interface) không phải **concrete class**.

→ **SOLID = 5 cây chống đỡ cho OOP architecture maintainable.**

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Core question:** Cho dự án 100K LOC, làm sao tránh **code rot** (mỗi feature mới làm break tính năng cũ) + **fragile dependencies** (1 class thay đổi → 50 chỗ khác bị break) + **untestable code** (không thể mock được)?
>
> **Why hard:** Untrained instinct = **god classes** + **deep inheritance** + **tight coupling**. Code "chạy" lúc đầu nhưng sau 1 năm = không ai dám sửa. SOLID = 5 heuristic specifically chống lại 5 anti-pattern cụ thể.
>
> **What we need:** Hiểu **mỗi principle solve 1 problem cụ thể** + biết **khi nào áp dụng** (production code production) **vs khi over-engineer** (prototype, throwaway script). Apply pragma không dogma.

→ **Risk lạm dụng:** Junior học SOLID xong abstract everything → DI container 30 layers, mỗi method có interface. "**Premature abstraction**" cũng tệ như "premature optimization".

---

## 📖 Định nghĩa chính thức

### **S — Single Responsibility Principle (SRP)**
> "A class should have only one reason to change."

Mỗi class **1 trách nhiệm**, **1 lý do thay đổi**. Phân chia theo *actors* (stakeholders who request changes), không theo *functionality*.

### **O — Open-Closed Principle (OCP)**
> "Software entities should be open for extension, but closed for modification." — Bertrand Meyer (1988)

Khi cần thêm tính năng, **thêm code mới** thay vì **sửa code cũ**. Achieved via inheritance, composition, polymorphism.

### **L — Liskov Substitution Principle (LSP)**
> "Subtypes must be substitutable for their base types." — Barbara Liskov (1987)

Object của subclass phải **dùng được ở mọi chỗ** object của superclass dùng — **without breaking** behavior contracts.

Formal: nếu `S` is subtype of `T`, thì objects of type `T` may be replaced với objects of type `S` mà không thay đổi correctness.

Common violations:
- Override method với stricter precondition
- Override method với weaker postcondition
- Override throwing new exception parent doesn't declare
- "Rectangle/Square" classic example

### **I — Interface Segregation Principle (ISP)**
> "Clients should not be forced to depend upon interfaces that they do not use."

Many small specific interfaces > one "fat" interface.

### **D — Dependency Inversion Principle (DIP)**
> "High-level modules should not depend on low-level modules. Both should depend on abstractions. Abstractions should not depend on details. Details should depend on abstractions."

Depend on interfaces, not concrete classes. Enables testability + flexibility.

**Source:** Robert C. Martin (Uncle Bob), *Agile Software Development: Principles, Patterns, and Practices* (2002). Updated in *Clean Architecture* (2017).

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **SRP** ý tưởng có từ **Tom DeMarco** (1979) — "Cohesion" trong structured design.
- **OCP** — **Bertrand Meyer** (1988) trong *Object-Oriented Software Construction*.
- **LSP** — **Barbara Liskov** (1987) — "Data Abstraction and Hierarchy" OOPSLA. Liskov is MIT prof, won Turing Award 2008.
- **ISP** + **DIP** — **Robert C. Martin** (1996) trong "The Dependency Inversion Principle" article cho *C++ Report* magazine.
- **Acronym "SOLID"** — coined by **Michael Feathers** in early 2000s discussing Martin's principles.
- **Today (2026):** Universally taught in CS programs. Adoption rate ~80% in production OOP codebases. Critique: applies primarily to OOP; FP has different principles (referential transparency, pure functions).

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| SRP | Single Responsibility Principle | 1 class, 1 reason to change |
| OCP | Open-Closed Principle | Mở extension, đóng modification |
| LSP | Liskov Substitution Principle | Subtype substitutable |
| ISP | Interface Segregation Principle | Small specific interfaces |
| DIP | Dependency Inversion Principle | Depend on abstractions |
| DI | Dependency Injection | Pass dependencies as parameters |
| IoC | Inversion of Control | Framework calls your code |
| Cohesion | Cohesion | How related elements within a module |
| Coupling | Coupling | How dependent modules are on each other |
| Abstraction | Abstraction | Hide details, expose essence |
| Concrete | Concrete | Specific implementation |
| Behavioral subtype | Behavioral subtype | Substitutable subtype |
| Mock | Mock | Test double impl |
| Stub | Stub | Hardcoded test impl |
| Spy | Spy | Recorded test impl |

---

## 💡 Real-world examples

### S — Single Responsibility

```python
# ❌ God class violates SRP
class Order:
    def add_item(self): ...
    def calculate_total(self): ...
    def save_to_db(self): ...        # different responsibility
    def send_email(self): ...        # different responsibility
    def export_to_pdf(self): ...     # different responsibility
    def calculate_tax(self): ...     # different responsibility
```

```python
# ✅ Each class has 1 reason to change
class Order:
    def add_item(self): ...
    def calculate_total(self): ...

class OrderRepository:
    def save(self, order: Order): ...      # DB layer

class OrderNotifier:
    def send_confirmation(self, order: Order): ...   # email layer

class OrderExporter:
    def to_pdf(self, order: Order): ...    # export layer

class TaxCalculator:
    def calculate(self, order: Order, region: str): ...   # tax logic
```

### O — Open-Closed

```python
# ❌ Modify existing code to add new shape
class AreaCalculator:
    def area(self, shape):
        if isinstance(shape, Circle):
            return math.pi * shape.r ** 2
        elif isinstance(shape, Rectangle):
            return shape.w * shape.h
        # Need to add Triangle? → modify this method
```

```python
# ✅ Open for extension via polymorphism
class Shape(ABC):
    @abstractmethod
    def area(self) -> float: ...

class Circle(Shape):
    def area(self): return math.pi * self.r ** 2

class Rectangle(Shape):
    def area(self): return self.w * self.h

class Triangle(Shape):    # new — no modification to existing
    def area(self): return 0.5 * self.base * self.height
```

### L — Liskov Substitution

```python
# ❌ Classic Square/Rectangle violation
class Rectangle:
    def __init__(self, w, h):
        self.w = w
        self.h = h

    def set_width(self, w): self.w = w
    def set_height(self, h): self.h = h

class Square(Rectangle):    # IS-A Rectangle? Mathematically yes
    def set_width(self, w):
        self.w = w
        self.h = w           # auto-sync
    def set_height(self, h):
        self.h = h
        self.w = h           # auto-sync

# Caller assumes Rectangle behavior:
def test(r: Rectangle):
    r.set_width(5)
    r.set_height(4)
    assert r.area() == 20    # FAILS for Square (returns 16, not 20!)
```

**Fix:** Square is NOT a Rectangle in OOP sense (behavioral subtype). Use composition or separate hierarchy.

### I — Interface Segregation

```python
# ❌ Fat interface
class Worker(ABC):
    def work(self): ...
    def eat(self): ...
    def sleep(self): ...

class RobotWorker(Worker):
    def work(self): ...
    def eat(self): raise NotImplementedError    # ← LSP violation too
    def sleep(self): raise NotImplementedError
```

```python
# ✅ Segregated interfaces
class Workable(ABC):
    def work(self): ...

class Eatable(ABC):
    def eat(self): ...

class Sleepable(ABC):
    def sleep(self): ...

class HumanWorker(Workable, Eatable, Sleepable): ...
class RobotWorker(Workable): ...    # implement only what's needed
```

### D — Dependency Inversion

```python
# ❌ High-level depends on concrete low-level
class OrderProcessor:
    def __init__(self):
        self.stripe = StripeProcessor()    # concrete dependency
        self.email = SendGridClient()       # concrete dependency

    def process(self, order):
        tx_id = self.stripe.charge(order.total)
        self.email.send(order.customer.email, "Confirmed")
```

```python
# ✅ Depend on abstractions
class OrderProcessor:
    def __init__(self,
                 payment: PaymentGateway,    # abstraction
                 notifier: Notifier):         # abstraction
        self.payment = payment
        self.notifier = notifier

    def process(self, order):
        tx_id = self.payment.charge(order.total)
        self.notifier.notify(order.customer.email, "Confirmed")

# Wire up at top level:
processor = OrderProcessor(
    payment=StripeProcessor(),
    notifier=SendGridNotifier()
)

# Or for testing:
processor = OrderProcessor(
    payment=MockPaymentGateway(),
    notifier=MockNotifier()
)
```

### Production DE example

| SOLID | Application in DE |
|---|---|
| **SRP** | Spark `DataFrame` (data), `DataFrameWriter` (output) separate. Iceberg `Table`, `Snapshot`, `Manifest` separate concerns. |
| **OCP** | dbt — add new model = new SQL file, no change to compiler. Iceberg custom catalog = implement interface, no fork. |
| **LSP** | `Iterator` in Java/Python — any `Iterator<T>` works in `for` loop |
| **ISP** | Iceberg `FileIO` interface (small) vs hypothetical "FabricFileSystem" (big) |
| **DIP** | Spark Catalyst optimizer depends on logical plan abstraction, not specific storage. Plugin via `DataSource API`. |

---

## 🧮 Pseudocode — DIP container pattern  *(Erickson UIUC style)*

```
《Without DIP - tight coupling》
class OrderService:
    constructor():
        this.db ← new PostgresDB("connstr")   《hardcoded》
        this.emailer ← new SendGridEmailer("api_key")

《With DIP - dependency injection》
interface Database:
    save(record)
    fetch(id)

interface Emailer:
    send(to, subject, body)

class OrderService:
    db: Database               《abstraction》
    emailer: Emailer

    constructor(db, emailer):  《inject at construction》
        this.db ← db
        this.emailer ← emailer

    process_order(order):
        this.db.save(order)
        this.emailer.send(order.customer_email, "OK", "...")

《Composition root - top of app wires concrete impls》
function main():
    db ← new PostgresDB("connstr")
    emailer ← new SendGridEmailer("api_key")
    service ← new OrderService(db, emailer)
    service.process_order(...)

《Testing - swap with mocks》
function test():
    db ← new MockDatabase()
    emailer ← new MockEmailer()
    service ← new OrderService(db, emailer)
    service.process_order(...)
    assert db.save_called == True
```

---

## 📊 Cost annotation table — SOLID benefit/cost matrix  *(Sedgewick Princeton style)*

| Principle | Benefit when applied | Cost when over-applied |
|---|---|---|
| **SRP** | Small focused classes, easy test | Class explosion, navigate burden |
| **OCP** | New features without modifying | Premature abstraction, complexity |
| **LSP** | Reliable polymorphism | Awkward hierarchies, forced workarounds |
| **ISP** | Lean interfaces | Interface explosion |
| **DIP** | Testable, swappable | Indirection, DI container complexity |

**Apply by codebase size:**

| Codebase | SOLID application |
|---|---|
| **< 1K LOC prototype** | Skip — premature, just code |
| **1K-10K LOC** | Apply SRP + LSP basic |
| **10K-100K LOC** | All 5 principles essential |
| **> 100K LOC** | All 5 + Domain-Driven Design + Hexagonal Architecture |

→ **Pragmatic SOLID:** Don't apply mechanically. Each principle solves specific pain point — apply when pain shows up.

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Over-abstracting prototype

```python
# ❌ Single Python script 200 LOC abstracts everything
class IDataReader(ABC): ...
class CsvReaderFactory(IDataReader): ...
class AbstractCsvReader(CsvReaderFactory): ...
class ConcreteCsvReaderImpl(AbstractCsvReader): ...
# 10 abstraction layers for 1 CSV read
```

**Tại sao bad:** YAGNI (You Ain't Gonna Need It). Premature abstraction. Pick simple:
```python
def read_csv(path: str) -> pd.DataFrame:
    return pd.read_csv(path)
```

### Anti-pattern 2 — Mock everything in unit tests

```python
# ❌ Unit test with 10 mocks
def test_order():
    mock_db = Mock()
    mock_email = Mock()
    mock_payment = Mock()
    mock_logger = Mock()
    mock_metrics = Mock()
    mock_cache = Mock()
    mock_audit = Mock()
    mock_clock = Mock()
    mock_user = Mock()
    mock_config = Mock()
    # ... test setup 50 lines, actual test 5 lines
```

**Tại sao bad:** Tests testing mock behavior, not real logic. Pick **integration test** + **functional core**.

### Anti-pattern 3 — Interface for everything

```java
// ❌ Java enterprise style
interface IUser {}
class UserImpl implements IUser {}
interface IUserService {}
class UserServiceImpl implements IUserService {}
interface IUserController {}
class UserControllerImpl implements IUserController {}
// Every class has interface with "I" prefix, single impl
```

**Tại sao bad:** Useless abstraction. Pick concrete unless second impl actually needed.

### Anti-pattern 4 — LSP violation — exceptions

```python
# ❌ Subclass throws new exception parent doesn't
class Animal:
    def feed(self): ...

class Dog(Animal):
    def feed(self):
        if self.is_sleeping:
            raise SleepingException("can't feed")   # ← parent doesn't declare!
```

**Tại sao bad:** Caller of `Animal.feed()` doesn't handle SleepingException → crash. Pick: subclass exceptions should be subtype of parent's, or no new exceptions.

### Anti-pattern 5 — SRP misinterpretation

```python
# ❌ "SRP = 1 method per class"
class AddOne:
    def do(self, x): return x + 1
class MultiplyByTwo:
    def do(self, x): return x * 2
class Square:
    def do(self, x): return x * x
# Anemic OOP — should be functions
```

**Tại sao bad:** Single function = function, not class. Pick functions or operator overloading.

---

## 🔧 Patterns — applying SOLID

### Pattern 1: Hexagonal Architecture (Ports & Adapters)
- Core domain (entities, business logic) = pure, no dependencies
- Ports = interfaces (DIP)
- Adapters = concrete impls (DB, HTTP, message bus)
- Test core in isolation

### Pattern 2: Strategy + DI

```python
class TaxCalculator(ABC):
    @abstractmethod
    def calculate(self, amount: Decimal) -> Decimal: ...

class VATCalculator(TaxCalculator):
    def calculate(self, amount): return amount * Decimal('0.1')

class GSTCalculator(TaxCalculator):
    def calculate(self, amount): return amount * Decimal('0.07')

class Invoice:
    def __init__(self, tax: TaxCalculator):
        self.tax = tax    # DI

    def total(self, subtotal):
        return subtotal + self.tax.calculate(subtotal)
```

### Pattern 3: Inversion of Control container

```python
# Modern Python — dependency-injector library
from dependency_injector import containers, providers

class Container(containers.DeclarativeContainer):
    db = providers.Singleton(PostgresDB, conn_str="...")
    emailer = providers.Singleton(SendGridEmailer, api_key="...")
    order_service = providers.Factory(
        OrderService,
        db=db,
        emailer=emailer,
    )

container = Container()
service = container.order_service()
```

---

## 🌱 Advanced topics

### A1. SOLID critique
- Dan North + others critique: SOLID = OO-centric, doesn't apply cleanly to FP
- FP equivalent: referential transparency, immutability, pure functions, type-driven design
- Modern: SOLID + functional principles mix

### A2. Beyond SOLID
- **GRASP** (General Responsibility Assignment Software Principles) — Larman
- **CUPID** (Composable, Unix philosophy, Predictable, Idiomatic, Domain-based) — Dan North 2022
- **Clean Architecture** — Martin
- **Domain-Driven Design** — Eric Evans

### A3. Apply cho DE / AI 2026
- **Spark Catalyst** = OCP applied (add optimization rules, no core change)
- **Iceberg Catalog interface** = ISP (small focused interface)
- **dbt adapter** = DIP (depend on adapter abstraction, not specific warehouse)
- **LangChain LLM abstraction** = DIP (swap Claude/GPT/local)

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. Liệt kê 5 chữ SOLID.
2. SRP với 1 ví dụ vi phạm cụ thể.
3. DIP nghĩa là gì? Cho ví dụ DI vs hardcoded dependency.

### 🟡 Medium
4. LSP Rectangle/Square — vi phạm thế nào? Fix?
5. ISP — Worker fat interface — refactor.
6. OCP — `if isinstance` chain → polymorphism. Show with example.

### 🔴 Hard
7. SOLID critique: trong FP code base có cần SOLID không? Equivalent principles?
8. Premature SOLID = anti-pattern. Cho 1 case real-world (Java enterprise).
9. Trong Spark Catalyst optimizer, các principle nào được áp dụng? Show specific.

> **6+/9** = sẵn sàng KU 07 (FP). **4-5** = đọc Bloch Item 38-44. **<4** = refactor 1 god class theo SOLID.

---

## 🔗 Liên kết

- **[F02/04 OOP fundamentals](./04-oop-fundamentals.md)** — context
- **[F02/05 Composition over Inheritance](./05-composition-over-inheritance.md)** — applied (OCP)
- **[F02/13 Design Patterns](./13-design-patterns.md)** — SOLID + patterns
- **[F02/14 Testing philosophy](./14-testing-philosophy.md)** — DI enables testing
- **[F00/10 Premature optimization](../F00-mental-models/10-premature-optimization.md)** — apply pragma

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **Refactoring.Guru Design Patterns** → `RefactoringGuru_Design-Patterns-Demo_*.pdf` — 8 ngôn ngữ, applies SOLID concepts.

📖 **Sách commercial (bài đọc bắt buộc):**
- **Robert C. Martin, *Clean Architecture*** (2017) — modern SOLID + architecture.
- **Robert C. Martin, *Agile Software Development: Principles, Patterns, and Practices*** (2002) — SOLID origin.
- **Robert C. Martin, *Clean Code*** (2008) — code-level practices.
- **Bloch, *Effective Java* 3rd ed** — SOLID-related items (Item 16-25, 38-44).
- **Eric Evans, *Domain-Driven Design*** (2003) — DDD complements SOLID.

📄 **Paper + reference:**
- Liskov & Wing (1994), *"A Behavioral Notion of Subtyping"*, ACM TOPLAS — LSP formal.
- Martin (1996), *"The Dependency Inversion Principle"*, C++ Report.
- Meyer (1988), *Object-Oriented Software Construction* — OCP.
- Dan North (2022) — [*"CUPID for joyful coding"*](https://dannorth.net/cupid-for-joyful-coding/) — SOLID critique.

---

**Đã đọc xong?**
✅ Tick → [F02/07 Pure functions + Immutability](./07-pure-functions-immutability.md).
