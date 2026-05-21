# KU F02 / 04 — OOP fundamentals: encapsulation, inheritance, polymorphism

> **Object-Oriented Programming = bundle data + behavior** thành **object**, mỗi object **encapsulate state** + expose **methods**. Java/C#/Smalltalk = pure OOP. Python/Scala = OOP+FP. **3 trụ chính**: Encapsulation, Inheritance, Polymorphism (đôi khi thêm Abstraction = 4 trụ). OOP dominate enterprise 30 năm; FP gain back gần đây.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/01 Imperative vs Declarative](./01-imperative-vs-declarative.md)
**Related KUs:** [F02/05 Composition over Inheritance](./05-composition-over-inheritance.md) · [F02/06 SOLID](./06-solid-principles.md) · [F02/13 Design Patterns](./13-design-patterns.md)
**Đọc trong:** ~18 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

**Tủ ATM ngân hàng** = perfect OOP analogy:

### Encapsulation — "Tiền trong tủ chỉ được truy cập qua giao diện"
- Tủ ATM có **tiền bên trong** (state) nhưng bạn không thể mở thẳng → phải qua **giao diện** (insert thẻ, nhập PIN, chọn rút).
- Bạn không biết **tủ tổ chức tiền thế nào** (mệnh giá nào ở đâu) — đó là **private**.
- Bạn chỉ thấy **public interface**: "Rút", "Gửi", "Tra cứu số dư".
- → Code: `class Account { private balance; public deposit(); public withdraw(); }`.

### Inheritance — "ATM nâng cấp = ATM cũ + tính năng mới"
- ATM cũ: Rút, Gửi, Tra cứu.
- ATM mới (kế thừa): tất cả tính năng cũ + Chuyển khoản QR, Mua điện thoại.
- → Code: `class SmartATM extends ATM { ... }`.

### Polymorphism — "Cùng nút 'Rút tiền' nhưng làm khác nhau"
- Bạn ấn "Rút 500K" trên ATM Vietcombank → trừ từ tài khoản Vietcombank.
- Cùng động tác trên ATM ACB → trừ từ ACB.
- → Code: `account.withdraw(500_000)` — call same method, different behavior based on account type.

→ **OOP = mỗi entity = 1 đối tượng có state + behavior + interface chuẩn để giao tiếp.**

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Core question:** Khi xây hệ thống lớn (banking, e-commerce, game), làm sao **organize code** để (a) thay đổi 1 phần không break phần khác, (b) reuse code, (c) hide complexity?
>
> **Why hard:** Procedural (C-style) thuần dùng global state + functions → 100K LOC = chaos không ai hiểu nổi. Functional thuần khó model domain với state (user account balance update). OOP propose: bundle related state + behavior together, expose interface, hide internal.
>
> **What we need:** Hiểu **3 trụ encapsulation/inheritance/polymorphism** + biết **khi nào lạm dụng** (inheritance hell, anemic domain models, god classes) + biết khi nào KHÔNG dùng OOP (functional core, imperative shell pattern).

→ Modern (2026): OOP vẫn dominant cho domain modeling, nhưng **prefer composition over inheritance** + mix với FP cho data processing. Pure inheritance hierarchies (Java 1990s style) lỗi thời.

---

## 📖 Định nghĩa chính thức

**Class** = template/blueprint định nghĩa **fields** (state) + **methods** (behavior).

**Object** = instance của class, có actual state.

**3 trụ OOP:**

### 1. Encapsulation (Đóng gói)
Bundle data + methods operating on data into a unit (class). Hide internal state behind interface.

Access modifiers:
- `public` — anyone can access
- `private` — only this class
- `protected` — this class + subclasses
- `internal` / package-private — same module

### 2. Inheritance (Kế thừa)
Class B (`subclass`/`child`) extend Class A (`superclass`/`parent`) → B has all A's members + can override/extend.

Forms:
- **Single inheritance** — 1 parent (Java, C#)
- **Multiple inheritance** — multiple parents (C++, Python)
- **Interface inheritance** — only contracts, no implementation (Java interface, Go interface)
- **Mixin / trait** — partial implementation reuse (Scala traits, Rust traits, Python multiple inheritance)

### 3. Polymorphism (Đa hình)
Same operation, different behavior based on type.

Forms:
- **Subtype polymorphism** — `Dog extends Animal; animal.speak()` — runtime dispatch
- **Parametric polymorphism (generics)** — `List<T>` works for any T
- **Ad-hoc polymorphism (overloading)** — same method name, different signatures
- **Coercion polymorphism** — implicit type conversion (đã thảo luận KU 03)

**Bonus 4th: Abstraction (Trừu tượng hoá)**
Hide implementation details. `interface` / `abstract class` = pure contracts.

**Nguồn:** Booch *Object-Oriented Analysis and Design*, Meyer *Object-Oriented Software Construction*, Bloch *Effective Java*.

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **Simula (1962-67)** — **Ole-Johan Dahl & Kristen Nygaard** (Norway) — first OOP language. Designed for **simulation** (boats, cars). Introduce `class` + `object` + inheritance. Won Turing Award 2001.
- **Smalltalk (1972, Alan Kay, Xerox PARC)** — Coined "**Object-Oriented Programming**". Pure OOP — everything is object + message-passing. Inspired GUIs (Mac, Windows).
- **C++ (1985, Bjarne Stroustrup)** — bolted OOP onto C. Made OOP mainstream. Pragmatic compromises (multiple inheritance, no GC).
- **Java (1995, James Gosling, Sun)** — "write once run anywhere". OOP + GC + portable. Dominated enterprise 1995-2015.
- **Eiffel (1986, Bertrand Meyer)** — introduced **Design by Contract** (preconditions, postconditions, invariants).
- **Python (1991, Guido)** — practical OOP (multiple inheritance, duck typing, dunder methods).
- **Ruby (1993, Yukihiro Matsumoto)** — pure OOP với Smalltalk influence + Perl pragmatism.
- **Rust (2010, Graydon Hoare)** — **rejected inheritance** entirely, only traits (composition). Lesson learned từ OOP excesses.
- **Today (2026):** OOP vẫn dominant, but **"composition over inheritance"** mainstream. Modern langs (Rust, Go, Zig) không có classical inheritance.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Class | Class | Blueprint cho object |
| Object / Instance | Object/Instance | Concrete realization của class |
| Field / Attribute | Field/Attribute | Data member |
| Method | Method | Function thuộc class |
| Constructor | Constructor | Special method to initialize |
| Destructor / Finalizer | Destructor/Finalizer | Cleanup khi object destroyed |
| Encapsulation | Encapsulation | Hide internal state |
| Inheritance | Inheritance | Extend existing class |
| Polymorphism | Polymorphism | Same interface, different behavior |
| Abstraction | Abstraction | Hide details, expose essence |
| Interface | Interface | Contract without implementation |
| Abstract class | Abstract class | Partial implementation |
| Concrete class | Concrete class | Full implementation, can instantiate |
| Override | Override | Subclass redefine parent method |
| Overload | Overload | Multiple methods same name, different signatures |
| Virtual method | Virtual method | Method dispatched dynamically |
| Static method | Static method | Belongs to class, not instance |
| Singleton | Singleton | Pattern: exactly 1 instance |
| Composition | Composition | Object contains other objects |
| Aggregation | Aggregation | Composition where parts can exist alone |
| Coupling | Coupling | Degree of dependency between modules |
| Cohesion | Cohesion | Degree of relatedness within module |
| LSP | Liskov Substitution Principle | Subtype must be substitutable for supertype |
| DRY | Don't Repeat Yourself | Avoid duplication |
| God class | God class | Anti-pattern: class does too much |
| Anemic domain model | Anemic domain model | Anti-pattern: classes only have data, no behavior |

---

## 💡 Real-world examples

### Example: BankAccount class

```python
from decimal import Decimal
from datetime import datetime

class BankAccount:
    """Encapsulates account state + provides transaction interface."""

    def __init__(self, account_id: str, initial_balance: Decimal = Decimal(0)):
        self._account_id = account_id      # private (Python convention: _)
        self._balance = initial_balance     # private
        self._transactions: list = []        # private history

    @property
    def balance(self) -> Decimal:            # read-only public
        return self._balance

    def deposit(self, amount: Decimal) -> None:
        if amount <= 0:
            raise ValueError("Deposit must be positive")
        self._balance += amount
        self._transactions.append(('deposit', amount, datetime.utcnow()))

    def withdraw(self, amount: Decimal) -> None:
        if amount <= 0:
            raise ValueError("Withdraw must be positive")
        if amount > self._balance:
            raise ValueError("Insufficient funds")
        self._balance -= amount
        self._transactions.append(('withdraw', amount, datetime.utcnow()))

    def transaction_history(self) -> list:
        return self._transactions.copy()      # return copy, không expose internal
```

→ State (`_balance`, `_transactions`) **encapsulated**. Caller can only modify qua methods.

### Example: Inheritance — Animal hierarchy

```python
class Animal:
    def __init__(self, name: str):
        self.name = name

    def speak(self) -> str:
        raise NotImplementedError

    def describe(self) -> str:
        return f"{self.name} says {self.speak()}"   # uses speak() — polymorphism

class Dog(Animal):
    def speak(self) -> str:
        return "Woof!"

class Cat(Animal):
    def speak(self) -> str:
        return "Meow"

class Duck(Animal):
    def speak(self) -> str:
        return "Quack"

# Polymorphism in action:
animals = [Dog("Rex"), Cat("Tom"), Duck("Donald")]
for a in animals:
    print(a.describe())
# Rex says Woof!
# Tom says Meow
# Donald says Quack
```

→ Each subclass override `speak()`. `describe()` calls `speak()` dynamically dispatched to actual type.

### Example: Polymorphism — Stripe payment processor

```python
from abc import ABC, abstractmethod

class PaymentProcessor(ABC):
    @abstractmethod
    def charge(self, amount: Decimal) -> str: ...   # returns transaction_id

class StripeProcessor(PaymentProcessor):
    def charge(self, amount: Decimal) -> str:
        # Call Stripe API
        return f"stripe_tx_{uuid()}"

class PayPalProcessor(PaymentProcessor):
    def charge(self, amount: Decimal) -> str:
        # Call PayPal API
        return f"paypal_tx_{uuid()}"

class MoMoProcessor(PaymentProcessor):
    def charge(self, amount: Decimal) -> str:
        # Call MoMo Vietnam API
        return f"momo_tx_{uuid()}"

def process_order(order: Order, processor: PaymentProcessor):
    tx_id = processor.charge(order.total)
    order.mark_paid(tx_id)
```

→ `process_order` works với bất kỳ processor implementation. **Open-Closed Principle** (KU 06).

### Production DE examples

| Tool | Use of OOP |
|---|---|
| **Apache Spark** | RDD/DataFrame classes; transformations as methods |
| **Apache Flink** | Job/Operator class hierarchy |
| **Apache Kafka client** | Producer/Consumer/Admin client classes |
| **Iceberg Java SDK** | Catalog/Table/Snapshot classes with inheritance |
| **dbt Python models** | Inherit base model class |
| **FastAPI** | Pydantic BaseModel + route handlers |
| **SQLAlchemy ORM** | Heavy OOP — Mapper/Session/Query |

→ Java + Scala + Python DE tools = OOP backbone.

---

## 🧮 Pseudocode — OOP basic structure  *(Erickson UIUC style)*

```
CLASS Animal:
    fields:
        name: String                    《instance field》
    methods:
        constructor(n):
            this.name ← n
        speak() -> String:              《abstract》
            ERROR("must override")
        describe() -> String:
            return this.name + " says " + this.speak()

CLASS Dog EXTENDS Animal:
    methods:
        speak() -> String:              《override》
            return "Woof!"

《Polymorphic dispatch》
let d ← new Dog("Rex")
let a: Animal ← d                      《upcast》
print(a.describe())                    《calls Dog.speak() — dynamic dispatch》
```

### Virtual method table (vtable) — under the hood

```
《Object layout in memory》
struct Dog {
    pointer to vtable_Dog              《at fixed offset, usually offset 0》
    name: String
}

vtable_Dog:
    [0] = pointer to Dog.speak()
    [1] = pointer to Animal.describe()  《inherited》

《Call a.describe():》
1. Load vtable pointer from a
2. Lookup vtable[1] → Animal.describe
3. Call Animal.describe(a)
   Inside: call a.speak()
4. Lookup vtable[0] → Dog.speak (NOT Animal.speak — dynamic dispatch!)
5. Return "Woof!"
```

→ Vtable = OOP runtime cost. Each virtual method call = 1 extra indirection.

---

## 📊 Cost annotation table — OOP feature trade-offs  *(Sedgewick Princeton style)*

| Feature | Benefit | Cost |
|---|---|---|
| **Encapsulation** | Hide changes from clients | Discipline required (private fields) |
| **Inheritance** | Code reuse | Tight coupling, fragile base class |
| **Single inheritance** | Simpler model | Less reuse |
| **Multiple inheritance** | Maximum reuse | Diamond problem |
| **Interfaces** | Loose coupling | More boilerplate |
| **Polymorphism (virtual call)** | Flexibility | ~1-2 ns overhead per call |
| **Generics / templates** | Type-safe reuse | Compile time slower, binary bloat (C++) |
| **Reflection** | Dynamic behavior | Slow, type-unsafe |
| **GC (in OOP langs)** | No manual memory | GC pauses (5-50ms typical) |

**Performance comparison (call 1M virtual methods):**

| Language | Time | Note |
|---|---|---|
| C function | ~3 ms | direct call |
| C++ virtual | ~4 ms | vtable lookup |
| Java | ~5 ms | JIT can devirtualize |
| Python method | ~80 ms | dynamic dispatch in interpreter |
| Python `__getattr__` | ~200 ms | metaclass overhead |

→ OOP dispatch fast in JIT/native, slow in interpreters.

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — God class

```python
# ❌ God class — does everything
class UserManager:
    def create_user(self): ...
    def delete_user(self): ...
    def send_email(self): ...
    def calculate_tax(self): ...
    def generate_report(self): ...
    def export_pdf(self): ...
    def authenticate(self): ...
    def hash_password(self): ...
    def encrypt_data(self): ...
    def log_audit(self): ...
    # ... 200 more methods
```

**Tại sao bad:** Violates Single Responsibility (KU 06). High coupling, untestable, fragile. Split into: `UserRepository`, `EmailService`, `TaxCalculator`, `AuthService`, etc.

### Anti-pattern 2 — Deep inheritance hierarchy

```python
# ❌ Inheritance depth = 6+
class Vehicle: ...
class MotorizedVehicle(Vehicle): ...
class WheeledMotorizedVehicle(MotorizedVehicle): ...
class FourWheeledMotorizedVehicle(WheeledMotorizedVehicle): ...
class Car(FourWheeledMotorizedVehicle): ...
class SportsCar(Car): ...
class FerrariSportsCar(SportsCar): ...
```

**Tại sao bad:** Fragile — change in `Vehicle` breaks everything. Hard to test. Prefer **composition** (KU 05).

### Anti-pattern 3 — Anemic domain model

```python
# ❌ Anemic: classes only data, no behavior
class Order:
    id: int
    items: list
    total: Decimal
    # ... only getters/setters

class OrderService:
    def calculate_total(self, order: Order):
        order.total = sum(item.price for item in order.items)

    def apply_discount(self, order: Order, percent: float):
        order.total *= (1 - percent/100)
```

**Tại sao bad:** Behavior should belong to Order. Anemic = procedural code wearing OOP clothes. Pick **rich domain model**:
```python
class Order:
    def add_item(self, item: Item): ...
    def calculate_total(self) -> Decimal: ...
    def apply_discount(self, percent: float): ...
```

### Anti-pattern 4 — Inheritance for code reuse only

```python
# ❌ "Inherit to reuse logging method"
class Logger:
    def log(self, msg): print(msg)

class UserService(Logger): ...    # WRONG: UserService is NOT a Logger
class PaymentService(Logger): ... # WRONG: PaymentService is NOT a Logger
```

**Tại sao bad:** Inheritance models "**is-a**" relationship. UserService is NOT a Logger. Pick **composition**:
```python
class UserService:
    def __init__(self, logger: Logger):
        self.logger = logger
```

### Anti-pattern 5 — Setter for every field (mutable everywhere)

```java
// ❌ Java Bean pattern overuse
class Order {
    private long id;
    private Date date;
    private BigDecimal total;
    // 20 fields with public setters
    public void setId(long id) { this.id = id; }
    public void setDate(Date d) { this.date = d; }
    // ... 20 setters
}
```

**Tại sao bad:** Defeats encapsulation. Order mất invariants. Pick **immutable + builder** hoặc **constructor + private fields**.

---

## 🔧 Patterns — when OOP shines

### Pattern 1: Domain modeling
Banking domain: Account, Transaction, Customer, Loan. Each has state + invariants + behavior. OOP natural.

### Pattern 2: Plugin / strategy
PaymentProcessor interface + Stripe/PayPal/MoMo impls. Easy to add new.

### Pattern 3: GUI / event-driven
Button, Form, Widget classes with `onClick` methods. OOP standard for GUI.

### Pattern 4: Long-lived stateful entities
Database connection pool, HTTP session, game character. OOP encapsulate lifecycle.

### When OOP **NOT** ideal:
- **Stateless data transforms** → FP win (Spark, pandas)
- **High-throughput numeric** → C/Rust + no virtual calls
- **Parsers / interpreters** → ADT + pattern matching (KU 09) win
- **Concurrent shared state** → actor / CSP (KU 11) better

---

## 🌱 Advanced topics

### A1. Mixin / Trait
Scala/Rust traits + Python multiple inheritance = mixin pattern. Compose behaviors without classical inheritance.

### A2. Object capability model
Security pattern: object = capability. Holding reference = permission. Used in Erlang, E language.

### A3. Prototype-based OOP
JavaScript, Self, Lua — no classes, objects clone other objects. More flexible but harder to reason.

### A4. Apply cho DE / AI 2026
- **Spark Dataset[Row]** = OOP wrapper over RDD (compile-time typed)
- **Pydantic BaseModel** = OOP for validation
- **LangChain agents** = OOP class hierarchy + tool composition
- **Anthropic Claude Tools** = strongly-typed function definitions

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. 3 trụ OOP là gì?
2. Encapsulation thực hiện thế nào trong Python (không có `private` keyword)?
3. Override vs Overload khác gì?

### 🟡 Medium
4. Diamond problem là gì? Python solve thế nào (hint: MRO)?
5. Virtual method dispatch overhead bao nhiêu nanoseconds? Khi nào ảnh hưởng?
6. God class: 5 dấu hiệu nhận biết.

### 🔴 Hard
7. Java vs Python: encapsulation enforcement khác thế nào? Cái nào "strict" hơn? Pros + cons?
8. Spark `Dataset[Row]` Scala là OOP wrapper. So sánh với Python `DataFrame` (PySpark). Trade-off?
9. Trong project DSX Air, KU nào áp dụng OOP tốt (domain modeling)? KU nào tránh OOP (FP win)?

> **6+/9** = sẵn sàng KU 05. **4-5** = đọc Bloch *Effective Java* Item 16-23. **<4** = code 3 mini domain models (Bank, Library, Shop).

---

## 🔗 Liên kết

- **[F02/05 Composition over Inheritance](./05-composition-over-inheritance.md)** — counter-balance to inheritance
- **[F02/06 SOLID](./06-solid-principles.md)** — OOP design principles
- **[F02/09 ADT](./09-adt-pattern-matching-monads.md)** — FP alternative to inheritance
- **[F02/13 Design Patterns](./13-design-patterns.md)** — applied OOP patterns
- **[F09 Databases I](../../semester-2-systems-theory/F09-databases-relational/)** — ORM (Object-Relational Mapping)

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **arXiv FP vs OOP 2025** → `arXiv-2508_FP-vs-OOP-Architectural.pdf` — empirical comparison.
- **arXiv OO modeling** → `arXiv-cs-0603016_OO-Modeling-Programming-Paradigms.pdf`.
- **Refactoring.Guru Design Patterns** → `RefactoringGuru_Design-Patterns-Demo_*.pdf` (8 languages: EN/ZH/JA/KO/FR/ES/RU/PL/UK).
- **Design Patterns Debrecen Univ** → `Jeszenszky_Design-Patterns-UnideDebrecen.pdf`.

📖 **Sách commercial (mua / library):**
- **Bertrand Meyer, *Object-Oriented Software Construction*** (1988/1997) — OOP bible, Design by Contract.
- **Grady Booch, *Object-Oriented Analysis and Design with Applications*** (1990/2007) — UML + design.
- **Joshua Bloch, *Effective Java* 3rd ed** — best practices Java OOP.
- **Kent Beck, *Smalltalk Best Practice Patterns*** — original OOP wisdom.

📄 **Paper gốc:**
- Dahl & Nygaard (1966), *"SIMULA: An ALGOL-Based Simulation Language"*, CACM.
- Kay (1993), *"The Early History of Smalltalk"*, ACM SIGPLAN HOPL-II.
- Liskov (1987), *"Data Abstraction and Hierarchy"* — LSP foundation.

---

**Đã đọc xong?**
✅ Tick → [F02/05 Composition over Inheritance](./05-composition-over-inheritance.md).
