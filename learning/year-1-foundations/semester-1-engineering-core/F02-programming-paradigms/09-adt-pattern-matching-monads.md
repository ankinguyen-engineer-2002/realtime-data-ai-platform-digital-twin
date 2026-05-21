# KU F02 / 09 — Algebraic Data Types + Pattern matching + Monads

> **ADT** = compose types qua **product** (`(A, B)` = tuple) + **sum** (`A | B` = enum). Combined với **pattern matching** = elegant data model + exhaustive case analysis. **Monad** = wrapper for sequencing effectful computations (Maybe, Either, IO, Future). Đây là **FP power tools** — Haskell, Rust, Scala, Swift, Kotlin all support. Iceberg metadata + Spark plan optimization heavily use ADT.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/04 OOP fundamentals](./04-oop-fundamentals.md) · [F02/07 Pure functions](./07-pure-functions-immutability.md)
**Related KUs:** [F02/08 Higher-order functions](./08-higher-order-functions.md) · [F02/12 Error handling](./12-error-handling.md)
**Đọc trong:** ~20 phút
**Mức độ:** Intermediate

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn xây **hệ thống đặt món online**. Order có thể ở 4 trạng thái:

### ADT — "Định nghĩa shape rõ ràng"
```
Order =
  | Pending
  | Confirmed(payment_id: String)
  | Shipped(tracking: String, eta: Date)
  | Cancelled(reason: String)
  | Delivered(at: DateTime, rating: Optional<Int>)
```

→ **5 variants**, mỗi variant có data **khác nhau**. Compiler **biết tất cả case**.

### Pattern matching — "Xử lý đúng từng case"
```
function describe(order):
    match order:
        Pending → "Waiting for payment"
        Confirmed(tx) → "Paid, tx=" + tx
        Shipped(t, e) → "On the way, ETA " + e
        Cancelled(r) → "Cancelled: " + r
        Delivered(at, r) → "Done at " + at
```

→ Compiler **báo lỗi nếu thiếu case** (exhaustiveness check). Junior code Java: `if/else` chain, dễ miss case → bug ngầm.

### Monad — "Tự động truyền context qua các bước"
- Bạn cần check: User exists? → has payment method? → balance enough? → place order?
- Mỗi bước có thể fail (return None).
- Monad pattern: tự động skip remaining steps nếu fail.

```python
# Without monad: nested if
user = find_user(email)
if user is not None:
    payment = user.payment_method
    if payment is not None:
        if payment.balance >= amount:
            return place_order(...)
        else:
            return None
    else:
        return None
else:
    return None
```

```haskell
-- With Maybe monad
do
    user <- findUser email
    payment <- user.paymentMethod
    if payment.balance >= amount
        then Just (placeOrder ...)
        else Nothing
```

→ **ADT + Pattern Matching + Monad = elegant data model + safe error handling.** Java/Python truyền thống stuck với null + exception chaos.

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Core question:** Khi modeling domain phức tạp (Order với 5 state, JSON với nested values, AST của compiler, network message types), làm sao **enforce exhaustiveness** + **make illegal states unrepresentable** + **compose error handling**?
>
> **Why hard:** OOP class hierarchy + `instanceof` checks không exhaustive (compiler không biết). Null/Optional propagation tediously verbose. Throwing exceptions = control flow + lose type safety.
>
> **What we need:** **ADT** to express "this OR that" (sum) + "this AND that" (product). **Pattern matching** to deconstruct safely. **Monad** to chain operations qua context (Maybe for null, Either for errors, Future for async, IO for effects).

→ **Rust, Swift, Kotlin, Scala 3, TypeScript** all adopt ADT + pattern matching từ Haskell/ML lineage. **Java 21 (2023)** finally add pattern matching (sealed classes + record patterns).

---

## 📖 Định nghĩa chính thức

### **Algebraic Data Types (ADT)**

Two constructors:

**1. Product types** = `(A, B, C)` — tuple, struct, record. Contains all of A, B, C.
- Example: `Point = (x: Float, y: Float)`
- Size: `|A| × |B| × |C|`

**2. Sum types** (tagged unions, discriminated unions) = `A | B | C`. Is exactly **one** of A, B, C with tag.
- Example: `Shape = Circle(radius: Float) | Square(side: Float) | Triangle(a, b, c: Float)`
- Size: `|A| + |B| + |C|`

**Combined** = build complex types via product + sum.

```haskell
-- Haskell
data Tree a = Leaf | Node a (Tree a) (Tree a)
-- Sum of: Leaf (no data) OR Node (with a, left subtree, right subtree)
```

```rust
// Rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

```scala
// Scala 3
enum Shape:
    case Circle(radius: Double)
    case Square(side: Double)
```

### **Pattern matching**

Deconstruct value by structure + bind variables.

```rust
match shape {
    Circle(r) => 3.14 * r * r,
    Square(s) => s * s,
    Triangle(a, b, c) => {
        let s = (a + b + c) / 2.0;
        (s * (s-a) * (s-b) * (s-c)).sqrt()
    }
}
// Compiler error if you forget a variant!
```

**Patterns include:** literal, variable, wildcard `_`, tuple, struct destructure, enum variant, guard.

### **Monad** (informal — sequencing context)

Monad = type `M<A>` với 2 operations:

1. **`return` / `unit`** : `A → M<A>` — wrap a value
2. **`bind` / `flatMap`** : `M<A> → (A → M<B>) → M<B>` — chain operations

Laws (informal):
- `return(x).bind(f) = f(x)` (left identity)
- `m.bind(return) = m` (right identity)
- `m.bind(f).bind(g) = m.bind(λx. f(x).bind(g))` (associativity)

**Common monads:**
- **Maybe / Option** = `Some(x)` | `None`. Chain over possible null.
- **Either / Result** = `Right(x)` | `Left(error)`. Chain over errors.
- **List** = `[]` | `[x, ...]`. Non-determinism.
- **IO** = `IO<A>`. Side effects.
- **Future / Promise** = async value.
- **State** = `State<S, A>`. Threaded state.

**Do-notation / syntactic sugar:**
```haskell
do
    user <- findUser email      -- = bind
    payment <- user.payment
    return (place_order user payment)
```
= equivalent to manual `bind` chain.

**Nguồn:** Wadler (1992) *"The Essence of Functional Programming"* — monad popularization. SICP Chapter 4 (continuations). PLAI types section.

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **ML (Milner, 1973)** — first to combine type inference + ADT + pattern matching. Foundation cho mọi successor.
- **Hope (Burstall, 1980)** + **Miranda (Turner, 1985)** — lazy FP with ADT.
- **Haskell (1990)** — standardize ADT + pattern matching + monad. Originally to unify lazy FP research community.
- **Monad concept in CS** — **Eugenio Moggi** (1989) — *"Notions of Computation and Monads"* — applied category theory's monad to programming language semantics.
- **Philip Wadler (1992)** — *"The Essence of Functional Programming"* — popularize monads cho Haskell community.
- **Scala (2004)** — bring ADT + monad to JVM with mainstream syntax.
- **F# (2005)** — ML on .NET.
- **Rust (2010)** — `enum` + `match` + `Option` + `Result`. Influential cho mainstream adoption.
- **Swift (2014)** — `enum` cases with associated values.
- **TypeScript (~2017)** — tagged union types + discriminated unions.
- **Kotlin (2016)** + **Java 17/21 (2021-2023)** — sealed classes + records + pattern matching. JVM finally has ADT.
- **Today (2026):** ADT mainstream. Even Python 3.10 added `match` statement (PEP 634).

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| ADT | Algebraic Data Type | Sum + product type construction |
| Product type | Product type | Tuple/struct/record |
| Sum type | Sum type / Tagged union / Discriminated union | "OR" of variants |
| Tagged union | Tagged union | Sum type with discriminator |
| Variant | Variant | One case of sum type |
| Constructor | Constructor | Build instance of variant |
| Pattern matching | Pattern matching | Deconstruct by structure |
| Exhaustiveness | Exhaustiveness | All cases covered |
| Refutability | Refutability | Pattern might not match |
| Guard | Guard | Condition in pattern |
| Maybe / Option | Maybe / Option | `Just(x)` | `Nothing` |
| Either / Result | Either / Result | `Right(x)` | `Left(err)` |
| Monad | Monad | Composable wrapper |
| Functor | Functor | Mappable wrapper |
| Applicative | Applicative | Functor + can lift function |
| Bind / flatMap | Bind / flatMap | Chain monadic ops |
| Do-notation | Do-notation | Syntactic sugar for monad |
| Sealed class | Sealed class | Closed hierarchy (= ADT) |
| Record | Record | Compact product type |

---

## 💡 Real-world examples

### ADT — Modeling JSON

```haskell
-- Haskell
data Json
    = JNull
    | JBool Bool
    | JNumber Double
    | JString String
    | JArray [Json]
    | JObject [(String, Json)]
```

```rust
// Rust serde
enum Value {
    Null,
    Bool(bool),
    Number(Number),
    String(String),
    Array(Vec<Value>),
    Object(Map<String, Value>),
}
```

vs OOP class hierarchy:
```java
abstract class JsonValue { ... }
class JsonNull extends JsonValue { ... }
class JsonBool extends JsonValue { boolean value; ... }
class JsonNumber extends JsonValue { double value; ... }
// ... 6 classes, no exhaustiveness check
```

→ ADT enforces "exactly 6 cases" at type level.

### Pattern matching — Spark Catalyst optimizer (Scala)

```scala
// Real Spark Catalyst code (simplified)
def optimize(plan: LogicalPlan): LogicalPlan = plan match {
    case Filter(p1, Filter(p2, child)) =>
        // Combine consecutive filters
        Filter(And(p1, p2), optimize(child))
    case Project(cols1, Project(cols2, child)) =>
        // Combine projects
        Project(cols1, optimize(child))
    case Filter(pred, Project(cols, child)) =>
        // Push filter below project
        Project(cols, optimize(Filter(pred, child)))
    case _ => plan
}
```

→ Compiler optimizer = ADT + pattern matching natural. Without ADT, would be 100+ lines of instanceof.

### Maybe / Option monad — eliminate null

```python
# Python 3.10+ match
from typing import Optional

def find_user(email: str) -> Optional[User]: ...
def get_balance(user: User) -> Optional[Decimal]: ...

# Without monad — nested check
def withdraw_balance(email: str) -> Optional[Decimal]:
    user = find_user(email)
    if user is None: return None
    balance = get_balance(user)
    if balance is None: return None
    return balance - 100

# With Optional monad-like (using returns library):
from returns.maybe import Maybe, Nothing

def withdraw_balance(email: str) -> Maybe[Decimal]:
    return (Maybe.from_optional(find_user(email))
            .bind(lambda u: Maybe.from_optional(get_balance(u)))
            .map(lambda b: b - 100))
```

```rust
// Rust idiomatic
fn withdraw_balance(email: &str) -> Option<Decimal> {
    find_user(email)?         // ? = early return if None
        .balance()?
        .checked_sub(100)
}
```

```haskell
-- Haskell do-notation
withdrawBalance email = do
    user <- findUser email
    balance <- getBalance user
    return (balance - 100)
```

### Either / Result monad — error handling

```rust
// Rust Result
fn parse_and_double(s: &str) -> Result<i32, ParseError> {
    let n: i32 = s.parse()?;       // ? propagates error
    Ok(n * 2)
}

// Vs Java exceptions — runtime, not in type
public int parseAndDouble(String s) throws NumberFormatException {
    return Integer.parseInt(s) * 2;
}
```

### Production examples — DSX Air

| Tool | ADT / Pattern matching usage |
|---|---|
| **Iceberg `Operation`** | `enum { APPEND, OVERWRITE, REPLACE, DELETE }` |
| **Iceberg `Snapshot.SummaryFields`** | tagged metadata |
| **Spark `LogicalPlan`** | full ADT — Filter, Project, Join, Aggregate, etc. |
| **Flink `Time`** | `EventTime | ProcessingTime | IngestionTime` |
| **Kafka `Result<RecordMetadata, KafkaException>`** | Java equivalent of Either |
| **Pydantic discriminated unions** | Tagged union for API schemas |
| **TypeScript Redux actions** | Discriminated union on `type` field |

---

## 🧮 Pseudocode — ADT + pattern matching  *(Erickson UIUC style)*

### Define ADT

```
ADT BinaryTree<T>:
    Leaf
    Node(value: T, left: BinaryTree<T>, right: BinaryTree<T>)

ADT Result<T, E>:
    Ok(value: T)
    Err(error: E)

ADT JsonValue:
    Null
    Bool(b: Boolean)
    Number(n: Double)
    String(s: String)
    Array(items: List<JsonValue>)
    Object(pairs: List<(String, JsonValue)>)
```

### Pattern matching with exhaustiveness

```
function tree_sum(t: BinaryTree<Int>) -> Int:
    match t with:
        Leaf → 0
        Node(v, left, right) → v + tree_sum(left) + tree_sum(right)
    《Compiler verifies all cases covered》
```

### Maybe monad implementation (manual)

```
ADT Maybe<T>:
    Some(value: T)
    None

function bind(m: Maybe<A>, f: A → Maybe<B>) → Maybe<B>:
    match m with:
        Some(x) → f(x)
        None → None

function map(m: Maybe<A>, f: A → B) → Maybe<B>:
    return bind(m, λx. Some(f(x)))

《Usage》
function compute(email):
    return bind(find_user(email), λuser →
           bind(get_balance(user), λbalance →
           Some(balance - 100)))
```

### Either monad

```
ADT Either<L, R>:
    Left(error: L)
    Right(value: R)

function bind(e: Either<L, R>, f: R → Either<L, S>) → Either<L, S>:
    match e with:
        Left(err) → Left(err)              《propagate error》
        Right(val) → f(val)                《continue》
```

---

## 📊 Cost annotation table — ADT vs OOP class hierarchy  *(Sedgewick Princeton style)*

| Aspect | ADT + Pattern Matching | OOP class hierarchy + instanceof |
|---|---|---|
| **Exhaustiveness check** | ✅ Compile time | ❌ Runtime |
| **Add new variant** | ❌ Modify all match sites | ✅ Just add subclass |
| **Add new operation** | ✅ Just add new function | ❌ Modify all classes (or visitor pattern) |
| **Code locality** | ✅ Operations grouped | ❌ Operations scattered across classes |
| **Mutability** | ✅ Naturally immutable | OOP often mutable |
| **Closed extension** | ✅ Compiler enforces | ❌ Open by default |
| **Boilerplate** | Low | High (subclasses, getters) |
| **Java familiarity** | Lower (newer feature) | Higher (decades) |
| **Runtime cost** | Tag check + jump (~1 ns) | Vtable lookup (~2-3 ns) |

**"Expression Problem":** Can you add (a) new variants and (b) new operations without modifying existing code?

| Approach | Easy to add variant | Easy to add operation |
|---|---|---|
| OOP class hierarchy | ✅ | ❌ (modify all subclasses) |
| ADT + match | ❌ (modify all matches) | ✅ |
| Type classes (Haskell) | ✅ | ✅ |
| Multimethods (Clojure) | ✅ | ✅ |

→ Each has trade-off. Pick based on which axis changes more.

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Missing pattern case (non-exhaustive)

```rust
// ❌ Rust compiler catches this
enum Status { Active, Inactive, Pending }
fn describe(s: Status) -> &'static str {
    match s {
        Status::Active => "active",
        Status::Inactive => "inactive",
        // ← compile error: non-exhaustive, missing Pending
    }
}
```

```java
// ❌ Java — silently incomplete (pre-Java 21)
String describe(Status s) {
    if (s == Status.ACTIVE) return "active";
    if (s == Status.INACTIVE) return "inactive";
    // missing PENDING — returns null! → NPE later
    return null;
}
```

**Tại sao bad:** Without exhaustiveness, new variant silently broken. Pick: Rust/Scala/Java 21 sealed types.

### Anti-pattern 2 — Stringly-typed enum

```python
# ❌ Use string for state
order.status = "pending"   # typo "pendng" → silent bug
order.status = "confirmed"
order.status = "compelted"   # ← typo, runtime bug

if order.status == "completed":  # never True
    ship()
```

**Tại sao bad:** String typos undetected. Pick **enum** or **ADT**:
```python
from enum import Enum
class OrderStatus(Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    COMPLETED = "completed"
```

### Anti-pattern 3 — Null instead of Optional

```java
// ❌ Java return null
public User findUser(String email) {
    return null;   // not found
}

// Caller forgets to check
User u = findUser("bad");
u.getName();   // NullPointerException
```

**Tại sao bad:** Compiler doesn't enforce null check. Pick `Optional<User>` (Java 8+) or use Kotlin nullable types.

### Anti-pattern 4 — Catching exception for control flow

```python
# ❌ Use exception as control flow
def parse_int_or_default(s, default):
    try:
        return int(s)
    except ValueError:
        return default
# Exception machinery 100x slower than condition check
```

**Tại sao bad:** Exceptions designed for **exceptional** cases. For predictable failures, use **Result/Either**:
```rust
fn parse_int_or_default(s: &str, default: i32) -> i32 {
    s.parse().unwrap_or(default)   // Result-based, fast
}
```

### Anti-pattern 5 — Nested monad pyramid

```haskell
-- ❌ Without do-notation, monad chains are ugly
findUser email >>= \user ->
    getPayment user >>= \payment ->
        checkBalance payment 100 >>= \ok ->
            if ok
                then placeOrder ...
                else fail "no balance"
```

**Tại sao bad:** Hard to read. Pick **do-notation**:
```haskell
do
    user <- findUser email
    payment <- getPayment user
    ok <- checkBalance payment 100
    if ok then placeOrder ... else fail "no balance"
```

---

## 🔧 Patterns — applied ADT + monad

### Pattern 1: State machine via ADT

```rust
enum OrderState {
    Pending,
    Confirmed { payment_id: String },
    Shipped { tracking: String, eta: DateTime },
    Delivered { at: DateTime, rating: Option<u8> },
    Cancelled { reason: String },
}

fn transition(state: OrderState, event: Event) -> Result<OrderState, Error> {
    match (state, event) {
        (OrderState::Pending, Event::Pay(tx)) =>
            Ok(OrderState::Confirmed { payment_id: tx }),
        (OrderState::Confirmed { .. }, Event::Ship(t, e)) =>
            Ok(OrderState::Shipped { tracking: t, eta: e }),
        _ => Err(Error::InvalidTransition),
    }
}
```

### Pattern 2: Result chain for fallible pipelines

```rust
fn process_request(req: Request) -> Result<Response, AppError> {
    let user = authenticate(req.token)?;
    let order = parse_order(req.body)?;
    let validated = validate(order, user)?;
    let saved = save(validated)?;
    Ok(make_response(saved))
}
```

→ `?` operator early-returns on `Err`. No try/catch indentation.

### Pattern 3: Discriminated union — Pydantic / TypeScript

```python
from typing import Literal, Union
from pydantic import BaseModel

class CreditCardPayment(BaseModel):
    type: Literal["credit_card"]
    card_number: str

class PayPalPayment(BaseModel):
    type: Literal["paypal"]
    email: str

class BankTransferPayment(BaseModel):
    type: Literal["bank_transfer"]
    iban: str

Payment = Union[CreditCardPayment, PayPalPayment, BankTransferPayment]
```

→ TypeScript / Pydantic recognize `type` field as discriminator → narrow at use site.

### Pattern 4: Result + monadic chaining trong Python

```python
# Using returns library
from returns.result import Result, Success, Failure

def validate_order(order) -> Result[Order, str]:
    if order.total <= 0: return Failure("invalid total")
    return Success(order)

def charge_payment(order: Order) -> Result[str, str]:
    # ... attempt charge
    return Success("tx_123") if ok else Failure("payment failed")

# Chain
result = (validate_order(order)
          .bind(charge_payment)
          .map(lambda tx: place_order(tx)))
```

---

## 🌱 Advanced topics

### A1. GADTs (Generalized Algebraic Data Types)
Haskell GADTs allow constructors to refine type parameters. `Expr Int` can only be `IntLit` or `Add`, while `Expr Bool` can only be `BoolLit` or `If`. Used in type-safe interpreters.

### A2. Monad transformers
Combine multiple monads (e.g., State + IO + Either). Useful but complex. **Effects systems** (Koka, Eff, Polysemy) try to simplify.

### A3. Free monads
Build interpreter for embedded DSL using a monad. Allow mocking/testing effects.

### A4. Apply cho DE / AI 2026
- **Iceberg manifest entries** = ADT (DATA file | DELETE file)
- **Spark SQL types** = ADT (`DataType` hierarchy)
- **Flink Watermark** = ADT (`Bounded` | `MaxOutOfOrderness` | `Punctuated`)
- **LangChain runnables** = functor + monad-like
- **Anthropic Claude tool_use** = discriminated union for tool calls

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. Product vs sum type — diff?
2. Pattern matching exhaustiveness — vì sao quan trọng?
3. Maybe / Option giải quyết vấn đề gì?

### 🟡 Medium
4. Visitor pattern (OOP) vs ADT + pattern matching — diff?
5. Either monad — explain với example error chain.
6. Java sealed classes (Java 17+) — feature gì? Tương đương ADT?

### 🔴 Hard
7. Expression problem — explain. Cho 1 example từng case.
8. Monad laws — 3 laws. Verify cho Maybe monad.
9. Spark Catalyst Logical Plan — explain ADT structure + 1 optimization rule via pattern match.

> **6+/9** = sẵn sàng KU 10 (concurrency). **4-5** = đọc Wadler 1992 Essence of FP. **<4** = implement Maybe + Either in Python.

---

## 🔗 Liên kết

- **[F02/07 Pure functions](./07-pure-functions-immutability.md)** — ADT naturally immutable
- **[F02/08 HOF](./08-higher-order-functions.md)** — map over functor
- **[F02/12 Error handling](./12-error-handling.md)** — Result/Either applied
- **[F04 Type Systems](../F04-type-systems-validation/)** — Pydantic discriminated unions
- **[D18 Spark](../../../year-2-specialization/semester-3-data-engineering-deep/D18-spark-distributed-compute/)** — Catalyst LogicalPlan ADT

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **PLAI (Krishnamurthi)** → `Krishnamurthi_PLAI_Brown.pdf` — Chapter on types + variants.
- **Haskell Craft (Thompson)** → `Thompson_Haskell-Craft-3ed.pdf` — ADT + pattern matching natural.
- **Practical Haskell** → `Mena_Practical-Haskell-2ed.pdf` — monads applied.

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **SICP (MIT)** → `Abelson-Sussman_SICP_MIT.pdf` Chapter 2.3 "Symbolic Data" + Chapter 4 — type tagging + dispatch.

📖 **Sách commercial:**
- **Vermeulen, *Functional Programming in Scala*** — monad chapters.
- **Bartosz Milewski, *Category Theory for Programmers*** — free online, deep monad theory.

📄 **Paper gốc:**
- Wadler (1992), *"The Essence of Functional Programming"*, POPL — bring monads to FP.
- Moggi (1989), *"Notions of Computation and Monads"*.
- Wadler (1995), *"Monads for Functional Programming"* — tutorial.
- Standard ML — milner-led report.
- Rust RFC 2008 — *non_exhaustive* attribute.
- Java JEP 441 — Pattern Matching for switch.

---

**Đã đọc xong?**
✅ Tick → [F02/10 Concurrency primitives](./10-concurrency-primitives.md).
