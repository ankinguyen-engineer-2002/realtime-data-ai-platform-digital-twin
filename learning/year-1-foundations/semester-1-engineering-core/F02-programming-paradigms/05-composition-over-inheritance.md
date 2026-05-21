# KU F02 / 05 — Composition over Inheritance

> "**Favor composition over inheritance**" — *Design Patterns* (GoF 1994). Inheritance creates **tight coupling** giữa parent + child. Composition (object **has** other objects) → loose coupling + flexibility. Modern langs (Rust, Go) **bỏ inheritance** hoàn toàn — chỉ có composition + interfaces.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/04 OOP fundamentals](./04-oop-fundamentals.md)
**Related KUs:** [F02/06 SOLID](./06-solid-principles.md) · [F02/13 Design Patterns](./13-design-patterns.md)
**Đọc trong:** ~14 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Cần xây **xe điện tự lái**. 2 cách design:

### Cách 1 — Inheritance ("là một")
```
Vehicle
  └─ MotorizedVehicle
       └─ Car
            └─ ElectricCar
                 └─ SelfDrivingElectricCar
```
- **Cần fix bug ở `Vehicle`** → ảnh hưởng tất cả descendants.
- **Cần xe đạp tự lái** → kẹt: bicycle không phải MotorizedVehicle.
- **Cần xe xăng tự lái** → tạo thêm class SelfDrivingGasCar — duplicate logic SelfDriving.

### Cách 2 — Composition ("có một")
```
class Car {
    engine: Engine             // composition
    wheels: 4 Wheels
    chassis: Chassis
}

class SelfDrivingModule {     // separate component
    detect_lane(): ...
    avoid_obstacle(): ...
}

class SelfDrivingCar {
    car: Car
    autopilot: SelfDrivingModule
}
```

- **Cần xe xăng tự lái?** → `SelfDrivingGasCar { car: GasCar, autopilot: SelfDrivingModule }`. Reuse autopilot.
- **Cần xe đạp tự lái?** → `SelfDrivingBike { bike: Bike, autopilot: SelfDrivingModule }`. Reuse autopilot.
- **Fix bug autopilot** → 1 chỗ, không phá Vehicle.

→ **Inheritance = "is-a", composition = "has-a".** Composition flexible hơn 10x.

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Core question:** Cần reuse code giữa nhiều class. Nên (a) **inherit** từ base class chung hay (b) **compose** — class chứa class khác làm field?
>
> **Why hard:** Inheritance look "natural" cho beginner — DRY (Don't Repeat Yourself), automatic reuse. Nhưng inheritance creates **tight coupling**: subclass biết internal của parent → parent thay đổi = subclass break. Plus inheritance = static (chosen at compile time), no flexibility runtime.
>
> **What we need:** Hiểu **Fragile Base Class problem**, **Diamond Problem**, **Inheritance tax** + biết khi nào composition rõ ràng thắng. Apply **GoF lesson**: "**Favor object composition over class inheritance**".

→ **Rust, Go bỏ inheritance hẳn.** Chỉ có structs + interfaces (traits). Lesson learned 30 năm OOP excesses.

---

## 📖 Định nghĩa chính thức

**Inheritance (is-a)** = subclass extend superclass, inherit all members. Static relationship.

**Composition (has-a)** = object contains references to other objects. Dynamic relationship.

**Aggregation** = special case of composition where contained object can exist independently.

**Delegation** = forward method calls to contained object (manual via methods, or automatic via language feature).

**Mixin / Trait** = partial implementation that can be mixed into multiple classes — middle ground.

**Fragile Base Class Problem:** Change in superclass breaks subclasses in non-obvious ways. Classic example: change `add()` method to call `addAll()` internally → subclass overriding `add()` breaks because `addAll()` now uses overridden `add()` → infinite loop or wrong behavior.

**Diamond Problem (Multiple Inheritance):**
```
    A
   / \
  B   C        # B and C inherit from A
   \ /
    D          # D inherits from B and C
```
If A has method `foo()`, and B + C both override → which `foo()` does D get?

- C++: must disambiguate manually
- Python: MRO (Method Resolution Order) — C3 linearization algorithm
- Java: forbids multiple class inheritance (allows multiple interface)

**Nguồn:** GoF *Design Patterns* (1994) — "Favor object composition over class inheritance" mantra. Bloch *Effective Java* Item 18-19.

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **Inheritance** giới thiệu trong **Simula 67** (Dahl & Nygaard). Look revolutionary cho code reuse.
- **1980s-1990s:** Java + C++ popularize. Inheritance hierarchies **20 levels deep** common. AWT GUI library (Java 1) = deep inheritance disaster.
- **GoF Design Patterns (1994)** by Gamma, Helm, Johnson, Vlissides — "**Favor object composition over class inheritance**" trở thành mantra.
- **Effective Java (2001/2008/2018)** by Bloch — Item 18 "Favor composition over inheritance" - bài đọc bắt buộc Java devs.
- **Go (2009, Google)** — Rob Pike, Ken Thompson — **no inheritance**. Only structs + interfaces. Lessons learned từ C++.
- **Rust (2010)** — Graydon Hoare, Mozilla — **no inheritance**. Only traits (composition). Make impossible to have fragile base class.
- **Kotlin (2011)** — final classes by default. Must explicitly `open` for inheritance.
- **Today (2026):** Modern "best practice" = **prefer composition**, use inheritance sparingly cho narrow cases (true is-a relationships, framework hooks).

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Inheritance | Inheritance | Subclass extends superclass |
| Composition | Composition | Object contains other object |
| Aggregation | Aggregation | Loose composition, parts independent |
| Delegation | Delegation | Forward calls to contained object |
| Mixin | Mixin | Partial impl mixed into classes |
| Trait | Trait | Rust/Scala mixin |
| Interface | Interface | Pure contract |
| Fragile Base Class | Fragile Base Class | Parent change breaks subclass |
| Diamond Problem | Diamond Problem | Ambiguous multiple inheritance |
| MRO | Method Resolution Order | Python algorithm for multiple inheritance |
| C3 linearization | C3 linearization | Python 2.3+ MRO algorithm |
| LSP | Liskov Substitution | Subtype substitutable for supertype |
| Open-Closed Principle | OCP | Open for extension, closed for modification |

---

## 💡 Real-world examples

### Refactor: deep inheritance → composition

**Before (inheritance):**
```python
class Bird:
    def fly(self): print("Flying")
    def speak(self): pass

class Penguin(Bird):
    def fly(self):
        raise NotImplementedError("Penguins can't fly!")    # Violates LSP

class Eagle(Bird):
    def speak(self): print("Screech")
```

**Problem:** `Penguin` IS-A `Bird` but can't `fly()`. Violates Liskov.

**After (composition):**
```python
class Animal:
    def __init__(self, name: str, can_fly: bool):
        self.name = name
        self.movement = FlyingMovement() if can_fly else SwimmingMovement()
        self.voice = ScreechVoice() if name == "Eagle" else SilentVoice()

    def move(self): self.movement.move()
    def speak(self): self.voice.speak()
```

→ No more LSP violation. Easy to add new movement types (Climbing, Burrowing).

### Strategy pattern via composition

```python
class PaymentGateway:
    def __init__(self, processor: PaymentProcessor):
        self.processor = processor          # composition!

    def charge(self, amount: Decimal):
        return self.processor.charge(amount)

# Compose at runtime:
gateway = PaymentGateway(StripeProcessor())
gateway = PaymentGateway(PayPalProcessor())
gateway = PaymentGateway(MoMoProcessor())    # Vietnam-specific
```

→ Vs inheritance: `class StripeGateway extends PaymentGateway: ...` — need new class per processor. Composition: single class, swap impl runtime.

### Spark transformations — composition

```python
# PySpark uses composition heavily
df.filter(col('amount') > 100) \
  .groupBy('region') \
  .agg(sum('amount')) \
  .sort('amount', ascending=False) \
  .show()
```

Each `.filter()`, `.groupBy()` returns a new DataFrame (composition of transformations). No inheritance hierarchy.

### Production DE example

| Tool | Pattern |
|---|---|
| **Iceberg Catalog** | Has-a `FileIO` interface (composition, not inherit) |
| **Spark DataFrame** | Has-a `LogicalPlan` (composition) |
| **dbt model** | Has-a `Compiler`, `Adapter` (composition) |
| **Kafka client** | Composition of `Producer` + `Serializer` + `Partitioner` |
| **Java legacy ORM** | Often inheritance hell — modern: composition (e.g., MyBatis) |

---

## 🧮 Pseudocode — inheritance vs composition  *(Erickson UIUC style)*

### Inheritance pattern

```
CLASS Vehicle:
    speed: int
    move():
        return "moving at " + this.speed

CLASS Car EXTENDS Vehicle:                  《inheritance》
    wheels: int = 4
    move():                                 《override》
        return "Car " + super.move()
```

### Composition pattern

```
INTERFACE Movement:
    move() -> String

CLASS WheelMovement IMPLEMENTS Movement:
    wheels: int
    move():
        return "rolling on " + this.wheels + " wheels"

CLASS RocketMovement IMPLEMENTS Movement:
    fuel: int
    move():
        return "blasting with " + this.fuel + " fuel"

CLASS Vehicle:
    speed: int
    movement: Movement                      《composition!》

    constructor(s, m):
        this.speed ← s
        this.movement ← m

    describe():
        return "Speed " + this.speed + ", " + this.movement.move()
```

```
《Use:》
car ← new Vehicle(60, new WheelMovement(4))
rocket ← new Vehicle(28000, new RocketMovement(1000))
《Same Vehicle class — different behavior via composed Movement》
```

→ **Composition** = swap behavior at runtime. **Inheritance** = swap behavior at compile time (new class).

---

## 📊 Cost annotation table — inheritance vs composition  *(Sedgewick Princeton style)*

| Aspect | Inheritance | Composition |
|---|---|---|
| **Code reuse** | ✅ Easy (automatic) | Manual (delegation) |
| **Flexibility** | ❌ Static (compile time) | ✅ Dynamic (runtime swap) |
| **Coupling** | ❌ Tight | ✅ Loose |
| **Encapsulation** | ❌ Breaks (subclass sees private) | ✅ Preserved |
| **Testing** | ❌ Hard (mock parent) | ✅ Easy (inject mock) |
| **Refactoring base** | ❌ Breaks subclasses | ✅ No impact |
| **Cognitive load** | ❌ Trace hierarchy | ✅ Single class clear |
| **Multiple behaviors** | ❌ Diamond problem | ✅ Easy compose multiple |
| **Code volume** | ✅ Less initially | ❌ More boilerplate |
| **Lines of indirection** | ✅ Direct | ❌ More layers |

**Decision matrix:**

| Question | Pick |
|---|---|
| Is it truly an "is-a" relationship that NEVER changes? | Inheritance |
| Does subtype have ALL behaviors of supertype + add more? | Inheritance (LSP) |
| Want to reuse implementation? | **Composition** |
| Want flexible swap at runtime? | **Composition** |
| Multiple sources of behavior? | **Composition** (or mixin/trait) |
| Framework requires it (extend abstract class)? | Inheritance |
| Modeling domain (Customer, Order, Product)? | Either; prefer composition |
| Behaviors are independent (Flyable, Swimmable)? | Strategy pattern via composition |

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Inherit for code reuse only

```python
# ❌ "Inherit to get logging"
class Logger:
    def log(self, msg): ...

class UserService(Logger): ...      # UserService is NOT a Logger!
class PaymentService(Logger): ...   # PaymentService is NOT a Logger!
```

**Tại sao bad:** Violates is-a semantic. Pick:
```python
# ✅ Composition
class UserService:
    def __init__(self, logger: Logger):
        self.logger = logger
```

### Anti-pattern 2 — Inherit just to override 1 method

```python
# ❌ Override single method
class Animal:
    def speak(self): print("...")

class Dog(Animal):
    def speak(self): print("Woof")    # override only
```

If only difference is `speak()` → consider passing function as constructor:
```python
# ✅ Strategy via function composition
class Animal:
    def __init__(self, speak_fn: Callable[[], None]):
        self._speak = speak_fn
    def speak(self): self._speak()

dog = Animal(lambda: print("Woof"))
cat = Animal(lambda: print("Meow"))
```

### Anti-pattern 3 — Diamond chaos

```python
# ❌ Multiple inheritance maze
class A:
    def foo(self): print("A.foo")

class B(A):
    def foo(self): print("B.foo")

class C(A):
    def foo(self): print("C.foo")

class D(B, C):
    pass

D().foo()    # Python MRO: B.foo (left first)
# What if B.foo calls super().foo()? → C.foo (via MRO)
# Confusing!
```

**Tại sao bad:** MRO confusion, hard to debug. Pick **interfaces + composition**.

### Anti-pattern 4 — Inherit to add unrelated behavior

```python
# ❌ Java AbstractList example (real Java bug pattern)
class CountingList<E> extends ArrayList<E> {
    private int addCount = 0;

    @Override
    public boolean add(E e) {
        addCount++;
        return super.add(e);
    }

    @Override
    public boolean addAll(Collection<? extends E> c) {
        addCount += c.size();
        return super.addAll(c);    // BUG: super.addAll() calls add() — addCount doubled!
    }
}
```

**Tại sao bad:** Fragile Base Class. `super.addAll()` internal use `add()` → counts double. Famous Bloch example. Pick composition wrapper.

---

## 🔧 Patterns — composition recipes

### Pattern 1: Strategy
Encapsulate algorithm in object, swap at runtime.
```python
class Sorter:
    def __init__(self, strategy: SortStrategy):
        self.strategy = strategy
    def sort(self, data): return self.strategy.sort(data)
```

### Pattern 2: Decorator
Wrap object with additional behavior.
```python
class CachingProcessor:
    def __init__(self, processor: Processor):
        self.processor = processor
        self.cache = {}
    def process(self, key):
        if key not in self.cache:
            self.cache[key] = self.processor.process(key)
        return self.cache[key]
```

### Pattern 3: Adapter
Convert interface of one class to another.
```python
class StripeToGenericAdapter:
    def __init__(self, stripe_client: StripeClient):
        self.stripe = stripe_client
    def charge(self, amount: Decimal) -> str:
        return self.stripe.create_charge(amount * 100, "usd")
```

### Pattern 4: Mixin / Trait (middle ground)

```python
# Python mixin
class JsonSerializable:
    def to_json(self) -> str:
        return json.dumps(self.__dict__)

class CsvSerializable:
    def to_csv(self) -> str: ...

class User(JsonSerializable, CsvSerializable):
    name: str
    email: str
```

→ Multiple mixins compose. Better than deep inheritance.

---

## 🌱 Advanced topics

### A1. Go's approach: no inheritance
```go
type Animal struct {
    Name string
}
type Dog struct {
    Animal       // embedding (not inheritance!)
    Breed string
}
```
Embedding = composition with delegation. Methods on `Animal` callable on `Dog` but no polymorphism.

### A2. Rust traits + dynamic dispatch
```rust
trait Speak {
    fn speak(&self) -> String;
}

struct Dog;
impl Speak for Dog {
    fn speak(&self) -> String { "Woof".to_string() }
}

fn introduce(s: &dyn Speak) {    // dyn = dynamic dispatch
    println!("{}", s.speak());
}
```
No classes, no inheritance. Composition + traits = OOP-like flexibility.

### A3. Apply cho DE / AI
- **Spark transformations** = composed chain (filter ∘ groupBy ∘ agg) — pure composition
- **dbt models** = each model = composition of source + transformation logic
- **LangChain Chains** = composable steps, no inheritance
- **Kubernetes operators** = composition of controllers + reconcilers

### A4. Functional composition (KU 08 deep)
`compose(f, g)(x) = f(g(x))`. FP equivalent of "method chaining" without OOP.

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. Inheritance vs composition — diff 1 câu.
2. "Favor composition over inheritance" — quote này từ đâu?
3. Cho 1 ví dụ relationship "is-a" (inheritance) vs "has-a" (composition).

### 🟡 Medium
4. Fragile Base Class — explain with example.
5. Penguin extends Bird — violates LSP. Fix bằng composition.
6. Rust + Go bỏ inheritance. Tại sao? Mất gì? Được gì?

### 🔴 Hard
7. Java AbstractList `addAll` bug pattern — explain + fix.
8. Python MRO C3 linearization — cho `class D(B, C): pass` với B,C extends A, MRO of D?
9. Trong Spark DataFrame API, transformations là composition. Tại sao không inheritance? Quantify benefit.

> **6+/9** = sẵn sàng KU 06. **4-5** = đọc Bloch Item 18-19. **<4** = refactor 3 inheritance hierarchies → composition.

---

## 🔗 Liên kết

- **[F02/04 OOP fundamentals](./04-oop-fundamentals.md)** — context
- **[F02/06 SOLID principles](./06-solid-principles.md)** — applied (OCP, LSP)
- **[F02/13 Design Patterns](./13-design-patterns.md)** — Strategy, Decorator, Adapter
- **[F02/08 Higher-order functions](./08-higher-order-functions.md)** — FP composition

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **Refactoring.Guru Design Patterns** → `RefactoringGuru_Design-Patterns-Demo_*.pdf` (8 langs) — Strategy/Decorator/Adapter patterns in detail.
- **Design Patterns Debrecen Univ** → `Jeszenszky_Design-Patterns-UnideDebrecen.pdf` — academic treatment.

📖 **Sách commercial:**
- **GoF Design Patterns** (1994) — Chapter 1 "Favor composition over inheritance".
- **Bloch, *Effective Java* 3rd ed** Item 18-19 — bài đọc bắt buộc.
- **Eric Freeman, *Head First Design Patterns*** — illustrated intro.
- **Martin Fowler, *Refactoring*** — "Replace Inheritance with Delegation" recipe.

📄 **Paper + reference:**
- Stata & Guttag (1995), *"Modular Reasoning in the Presence of Subclassing"*.
- Allen Holub blog — *"Why extends is evil"*.
- Go Language design rationale on inheritance.
- Rust RFC on traits — [github.com/rust-lang/rfcs](https://github.com/rust-lang/rfcs).

---

**Đã đọc xong?**
✅ Tick → [F02/06 SOLID principles](./06-solid-principles.md).
