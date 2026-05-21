# KU F02 / 12 — Error handling: Exceptions vs Result/Either

> **Exceptions** = throw + catch, hidden control flow. **Result/Either** = error in return type, explicit. Modern languages (Rust, Go, Haskell, Swift) prefer **explicit** errors. Python/Java/C# stuck with exceptions but adopt `Optional`/`Result`-like libraries. Khác biệt = code quality + testability + ability to reason about failure modes.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/09 ADT + Pattern matching + Monads](./09-adt-pattern-matching-monads.md)
**Related KUs:** [F02/14 Testing philosophy](./14-testing-philosophy.md) · [F00/05 Failure as feature](../F00-mental-models/05-failure-as-feature.md)
**Đọc trong:** ~14 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

**Vận chuyển bưu phẩm** — 2 cách xử lý "gói hàng có vấn đề":

### Cách 1 — Exception ("Báo động khi lỗi")
- Shipper gói hàng → giao đi → đến nhà bạn.
- Nếu lỗi (sai địa chỉ, package vỡ) → **bưu kiện được trả về kèm "tem báo lỗi"**.
- Người nhận **không nhìn vào package** → giả định nó OK → nhận → bóc ra mới biết.
- → "Bỏ exception lên trên cho ai đó handle". Lỗi **ẩn**, không xuất hiện trong **type signature**.

### Cách 2 — Result/Either ("Trên gói luôn dán nhãn 'OK' hoặc 'Lỗi'")
- Shipper gói + **dán nhãn "OK" hoặc "Lỗi(lý do)"**.
- Người nhận **phải nhìn nhãn trước**: nếu OK → mở ra. Nếu Lỗi → handle.
- Compiler **bắt buộc check nhãn**.
- → Lỗi **hiện diện trong type**. Không thể quên handle.

Trong code:

```python
# Cách 1 — Exception (Python)
def divide(a, b):
    return a / b   # ZeroDivisionError tiềm ẩn

try:
    result = divide(10, 0)
except ZeroDivisionError:
    result = 0
# Caller có thể quên try/except → crash
```

```rust
// Cách 2 — Result (Rust)
fn divide(a: i32, b: i32) -> Result<i32, DivisionError> {
    if b == 0 { return Err(DivisionError::Zero); }
    Ok(a / b)
}

let result = divide(10, 0);
match result {
    Ok(v) => println!("{}", v),
    Err(e) => println!("error: {:?}", e),
}
// Compiler forces match — không thể quên
```

→ **Exception = optimistic. Result = pessimistic. Modern best practice: Result for expected errors, Exception for truly exceptional/unrecoverable.**

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Câu hỏi cốt lõi:** Code có thể fail vì 100 lý do (network mất kết nối, disk đầy, parse error, validation lỗi, race condition). Làm sao **xử lý lỗi** mà (a) không bỏ sót case nào, (b) caller biết function có thể fail thế nào, (c) không lẫn lộn với "happy path"?
>
> **Vì sao khó:** Exception là **hidden control flow** — function signature `int parse(str)` không nói nó throw `NumberFormatException`. Compiler không buộc handle. Bug production: code path edge case → uncaught exception → process crash. Stack unwinding tốn CPU. Try/catch khiến refactor khó.
>
> **Điều ta cần:** Hiểu trade-off — **exception** hợp cho lỗi thực sự bất thường (DB sập, OOM, programmer bug) + **Result/Either** hợp cho expected failure (validation user input, parse string, lookup miss, network timeout có thể retry). Pick đúng cho từng tình huống.

→ **Rust (2010)**, **Go (2009)**, **Swift (2014)** đều chọn explicit error (Result/Either) làm mặc định. Bài học rút ra từ "Java exceptions chaos" (tranh cãi checked exceptions kéo dài 20 năm).

---

## 📖 Định nghĩa chính thức

### **Exception**
Cơ chế **tự động đẩy lỗi lên call stack**. Sinh ra bằng `throw`, bắt bởi `catch`/`except`. Control flow rời function qua "non-local return" (nhảy ra ngoài flow bình thường).

**Phân loại:**
- **Checked exception** (Java) — compiler buộc khai báo `throws` hoặc catch.
- **Unchecked / Runtime exception** — bay tự do lên call stack. Không cần khai báo.
- **Error** — fatal, thường không nên catch (OOM, StackOverflow — chương trình đã hỏng).

**Try-catch-finally:**
```python
try:
    risky_op()
except SpecificError as e:
    handle(e)
except Exception as e:
    log_and_reraise(e)
finally:
    cleanup()
```

### **Result / Either**
Function trả về **value HOẶC error** trong return type. Caller buộc phải kiểm tra.

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

```haskell
data Either a b = Left a | Right b
-- Quy ước: Left = lỗi, Right = thành công (chơi chữ "right" = đúng)
```

### **Option / Maybe**
Trường hợp đặc biệt cho "value hoặc không có gì" (không có thông tin lỗi cụ thể).

```rust
enum Option<T> {
    Some(T),
    None,
}
```

### **3 trường phái xử lý lỗi**

1. **Throw / catch exception** (Java, Python, C#, Ruby, C++)
2. **Return value + sentinel** (C — trả -1, set `errno`; Go — cặp `(value, error)`)
3. **Return Result/Either ADT** (Rust, Haskell, Scala, Swift, F#)

**Effect systems** (Koka, Unison) — track exception trong types tĩnh. Best of both worlds (kết hợp ưu điểm cả hai).

**Nguồn:** Stroustrup *Design and Evolution of C++* (exception design). Liskov *"Abstract Data Types and Software Validation"* (CLU's signal mechanism = ancestor of exception). *Effective Java* Item 69-77.

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **PL/I (1964)** — first language với structured exception handling (`ON ERROR`).
- **CLU (Liskov, 1974)** — formal "signal" mechanism, ancestor of modern exceptions.
- **Ada (1980)** — well-defined exception model.
- **C++ (1985)** — exceptions added 1988. Famous performance debates.
- **Java (1995)** — **checked exceptions** controversial design. Force declaration but verbose.
- **Python (1991)** — exceptions throughout, EAFP idiom ("Easier to Ask Forgiveness than Permission").
- **Go (2009)** — **rejected exceptions** intentionally. Use `(value, error)` pair. `panic` for truly fatal.
- **Rust (2010)** — `Result<T, E>` first-class. `?` operator for propagation. **Panic** only for unrecoverable.
- **Haskell** — `IOException` exists but FP idiom = `Either`, `MaybeT`, etc.
- **Swift (2014)** — `try` syntax + `throws` declaration + `Result<T, Error>`.
- **Kotlin (2016)** — `Result<T>`, also exceptions interop with Java.
- **Today (2026):** Modern langs prefer explicit errors. Even Python/Java add `Optional<T>`, `Result`-like libs (`returns` lib Python).

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Exception | Exception | Thrown error |
| Throw / Raise | Throw/Raise | Initiate exception |
| Catch / Except | Catch/Except | Handle exception |
| Finally | Finally | Run cleanup regardless |
| Stack unwinding | Stack unwinding | Unwind frames during propagation |
| Checked exception | Checked exception | Compiler enforces handle (Java) |
| Unchecked exception | Unchecked exception | RuntimeException, optional |
| Error | Error | Unrecoverable (vs exception) |
| Result / Either | Result/Either | ADT for success/failure |
| Option / Maybe | Option/Maybe | ADT for value/absent |
| Try operator `?` | `?` operator | Rust early-return on Err |
| `unwrap()` | unwrap | Get value, panic if Err |
| `expect("msg")` | expect | Like unwrap with custom msg |
| `?` propagate | propagate | Rust auto-return Err |
| Sentinel value | Sentinel value | Magic value indicating error |
| Errno | Errno | C global error indicator |
| Panic | Panic | Rust/Go unrecoverable abort |
| EAFP | EAFP | Easier Ask Forgiveness than Permission |
| LBYL | LBYL | Look Before You Leap |
| Defensive programming | Defensive programming | Validate all inputs |

---

## 💡 Real-world examples

### File reading — 3 paradigms

**Python (exception):**
```python
try:
    with open(path) as f:
        content = f.read()
except FileNotFoundError:
    content = "default"
```

**Go (sentinel pair):**
```go
content, err := os.ReadFile(path)
if err != nil {
    content = []byte("default")
}
```

**Rust (Result):**
```rust
let content = std::fs::read_to_string(path).unwrap_or_else(|_| "default".to_string());

// Or with ? for propagation:
fn process(path: &str) -> Result<String, std::io::Error> {
    let content = std::fs::read_to_string(path)?;   // early return on Err
    Ok(content.to_uppercase())
}
```

### Java checked exception controversy

```java
// Caller forced to handle 5 checked exceptions
public void readFile(String path)
        throws IOException,
               FileNotFoundException,
               SecurityException,
               OutOfMemoryError,
               InterruptedException {
    // ... 50 lines
}

// Caller signature explosion or `throws Exception` (defeating purpose)
```

→ Java checked exceptions = controversial. Effective Java recommends use sparingly.

### Go error wrapping (Go 1.13+)

```go
import "errors"

func process(input string) error {
    if input == "" {
        return errors.New("empty input")
    }
    if err := validate(input); err != nil {
        return fmt.Errorf("validate failed: %w", err)  // wrap
    }
    return nil
}

// Unwrap chain
err := process("")
var verr *ValidateError
if errors.As(err, &verr) {
    // handle specific
}
```

### Rust Result + `?` chain

```rust
use anyhow::{Result, Context};

fn process_order(req: Request) -> Result<Response> {
    let user = authenticate(&req.token)
        .context("authentication failed")?;
    let order = parse_order(&req.body)
        .context("body parsing failed")?;
    let validated = validate(order, &user)
        .context("order validation failed")?;
    let saved = save(validated)
        .context("DB save failed")?;
    Ok(make_response(saved))
}

// Caller sees: Ok(response) | Err(chain of contexts)
// `anyhow` library popular for app code
// `thiserror` library for library code (typed errors)
```

### Production examples

| System | Error model |
|---|---|
| **Postgres** | Exceptions (`raise notice`, `raise exception`) + SQL state codes |
| **Java applications** | Mix checked + unchecked. Many use Optional + sealed types |
| **Python services** | Exception-heavy. FastAPI uses HTTPException |
| **Go services** | `(result, error)` pair. `errors.Is/As` for matching |
| **Rust services** | `Result<T, E>` with `anyhow`/`thiserror` |
| **Kafka clients (Java)** | `Future<RecordMetadata>` with embedded exception |
| **Spark** | Exceptions (Scala/Java) but DataFrame errors = lazy until action |
| **Flink** | Exception throws cancel job, restart from checkpoint |
| **dbt** | Exception-based, surfaced as test failures |

---

## 🧮 Pseudocode — error handling patterns  *(Erickson UIUC style)*

### Exception pattern

```
function withdraw(account, amount):
    if amount ≤ 0:
        THROW InvalidAmountException("must be positive")
    if amount > account.balance:
        THROW InsufficientFundsException(account.balance)
    account.balance ← account.balance − amount
    return account.balance

《Caller》
try:
    new_balance ← withdraw(acc, 1000)
except InsufficientFundsException as e:
    show_message("Only " + e.available + " available")
except InvalidAmountException as e:
    show_message(e.message)
```

### Result/Either pattern

```
ADT WithdrawError:
    InvalidAmount(amount: Int)
    InsufficientFunds(available: Int)

function withdraw(account, amount) → Result<Int, WithdrawError>:
    if amount ≤ 0:
        return Err(InvalidAmount(amount))
    if amount > account.balance:
        return Err(InsufficientFunds(account.balance))
    account.balance ← account.balance − amount
    return Ok(account.balance)

《Caller》
result ← withdraw(acc, 1000)
match result with:
    Ok(new_balance) → show("New: " + new_balance)
    Err(InvalidAmount(_)) → show("Must be positive")
    Err(InsufficientFunds(avail)) → show("Only " + avail + " available")
```

### Error propagation chain

```
Exception version (auto):
function transfer(from, to, amount):
    withdraw(from, amount)            《throws propagate》
    deposit(to, amount)               《throws propagate》

Result version (explicit ?):
function transfer(from, to, amount) → Result<(), TransferError>:
    withdraw(from, amount)?           《? = early return on Err》
    deposit(to, amount)?
    return Ok(())
```

---

## 📊 Cost annotation table — error handling comparison  *(Sedgewick Princeton style)*

| Aspect | Exceptions | Result/Either |
|---|---|---|
| **Signature reveals errors** | ❌ Hidden (or verbose `throws`) | ✅ In type |
| **Compiler forces handle** | Java checked only | ✅ Always |
| **Performance happy path** | Free | Slight overhead (tagged union) |
| **Performance error path** | Expensive stack unwind | Cheap (just return) |
| **Composability** | Try/catch nesting awkward | Monadic chain elegant |
| **Refactoring** | Hard to track | ✅ Compiler guides |
| **Pattern matching** | `instanceof` checks | Exhaustive match |
| **Stack trace** | ✅ Free | Manual (add context) |
| **Cross-thread / async** | Hard (Promise.catch needed) | ✅ Natural |
| **Catch-all easy** | `except Exception` | Less ergonomic |

**Performance benchmarks (Java):**

| Pattern | Throughput |
|---|---|
| `if (x < 0) return ERROR_CODE;` | 200M ops/s |
| `if (x < 0) throw new Exception();` (caught) | 5M ops/s (40× slower) |
| `Optional<T>` return | 180M ops/s |
| `Result<T, E>` lib | 150M ops/s |

→ Exceptions expensive on the **error path** (stack unwind), free on happy path. Don't use cho hot loop validation.

### When to use which

| Scenario | Pick |
|---|---|
| **Truly exceptional** (OOM, hardware fault, programmer bug) | Exception / Panic |
| **Expected validation failure** (bad user input) | Result/Either |
| **Network timeout (retry-able)** | Result/Either |
| **Parse error** | Result/Either |
| **Resource not found** | Option/Maybe |
| **API boundary internal services** | Result/Either (clear contract) |
| **API boundary to users** | Translate to HTTP status |
| **Library code** (consumers vary) | Result/Either |
| **App code** (single context) | Exception OK |
| **Hot loop** (millions of times) | Sentinel/Result (avoid exception cost) |
| **Cleanup** (file close, lock release) | RAII / `finally` / `defer` |

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Dùng exception cho control flow

```python
# ❌ Dùng exception để break loop
def find_first_even(nums):
    for n in nums:
        if n % 2 == 0:
            raise StopIteration(n)   # ← exception thành control flow

try:
    find_first_even([1, 3, 5, 6])
except StopIteration as e:
    result = e.args[0]
```

**Vì sao bad:** Exception machinery chậm (~40× so với if-return) + làm mờ intent (đọc code khó hiểu đây là loop break). Pick: return giá trị hoặc `break`.

### Anti-pattern 2 — Nuốt exception im lặng (catch-all swallow)

```java
// ❌ Nuốt tất cả lỗi không xử lý
try {
    riskyOp();
} catch (Exception e) {
    // ignored — bỏ trống!
}
// Bug ẩn — production log trống rỗng khi có lỗi
```

**Vì sao bad:** Mất toàn bộ thông tin debug. Pick: ít nhất phải `log.error(e)`, lý tưởng là catch specific exception + re-raise kèm context.

### Anti-pattern 3 — Java checked exception explosion

```java
// ❌ Method declares 10 checked exceptions
public Result process(Input in)
    throws IOException, ParseException, ValidationException,
           DatabaseException, NetworkException, TimeoutException,
           AuthException, AuthorizationException, RateLimitException,
           ConfigException { ... }
```

**Vì sao bad:** Caller signature bùng nổ — mọi caller phải khai báo lại 10 exception. Pick: gom vào 1 `BusinessException` chung hoặc dùng Result type.

### Anti-pattern 4 — `unwrap()` everywhere in Rust

```rust
// ❌ unwrap in production
let user = db.find_user(id).unwrap();   // panics if not found
let balance = user.get_balance().unwrap();
```

**Vì sao bad:** Panic mỗi khi có lỗi nhỏ → process crash. Pick: dùng `?` operator để propagate, `match` để xử lý, hoặc `map_err` để chuyển kiểu lỗi:
```rust
let user = db.find_user(id).ok_or(Error::UserNotFound)?;
let balance = user.get_balance()?;
```

### Anti-pattern 5 — Ignore Go error

```go
// ❌ Discard error
result, _ := riskyOp()   // `_` discards error
useResult(result)         // result might be zero value, garbage
```

**Vì sao bad:** Bỏ qua error = silent bug. Pick: luôn handle hoặc log. Linter `errcheck` (Go) bắt lỗi này.

### Anti-pattern 6 — Defensive over-validation

```python
# ❌ Validate everything internally
class User:
    def get_email(self):
        if self is None: raise ValueError("self is None")
        if not hasattr(self, '_email'): raise AttributeError("no _email")
        if not isinstance(self._email, str): raise TypeError("not str")
        if len(self._email) > 1000: raise ValueError("too long")
        return self._email
```

**Vì sao bad:** Validate ở mọi tầng = tốn CPU + code phức tạp. Pick: validate ở **boundary** (API entry, file parser), trust internal layers — đã pass boundary thì coi như sạch.

---

## 🔧 Patterns — practical error handling

### Pattern 1: Error category enum

```rust
#[derive(Debug, thiserror::Error)]
enum OrderError {
    #[error("invalid amount: {0}")]
    InvalidAmount(Decimal),

    #[error("insufficient funds, available: {0}")]
    InsufficientFunds(Decimal),

    #[error("user not found: {0}")]
    UserNotFound(String),

    #[error("payment processor error: {0}")]
    PaymentError(#[from] PaymentError),
}
```

### Pattern 2: Result chain with `?` (Rust)

```rust
fn handle_request(req: Request) -> Result<Response, AppError> {
    let user = authenticate(&req.token)?;
    let order = validate_order(&req.body)?;
    let payment = charge_payment(&order, &user)?;
    let saved = save_order(&order, &payment)?;
    Ok(Response::ok(saved))
}
```

### Pattern 3: Either monad chain (Python `returns`)

```python
from returns.result import Result, Success, Failure
from returns.pipeline import flow

def handle(req):
    return flow(
        req,
        authenticate,           # Result[User, Error]
        validate_order,         # Result[Order, Error]
        charge_payment,
        save_order,
    )
```

### Pattern 4: Translate errors at boundary

```python
@app.exception_handler(BusinessError)
def business_error_handler(request, exc: BusinessError):
    return JSONResponse(
        status_code=400 if isinstance(exc, ValidationError) else 500,
        content={"error": exc.code, "message": exc.message},
    )
```

→ Internal use Result/Either, translate to HTTP at boundary.

### Pattern 5: Retry with backoff (handling transient errors)

```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(stop=stop_after_attempt(3), wait=wait_exponential(min=1, max=10))
def fetch_api():
    response = http.get(url)
    response.raise_for_status()
    return response.json()
```

---

## 🌱 Advanced topics

### A1. Effect systems
**Koka**, **Unison**, **Eff** — track effects in types statically. `(string) -> string + IO + Exception` — compiler knows function does I/O and may throw.

### A2. Continuation passing style (CPS)
Pass success + error continuations. Underlying of async/await. Used in Scheme + sometimes JS.

### A3. Algebraic effects
Generalize exceptions. Allow handler to resume computation. Reverse of try/catch where handler can return value.

### A4. Apply cho DE / AI 2026
- **dbt test failures** = errors as data (test results stored, no exception)
- **Spark `df.failOnFault(false)`** — continue with partial data
- **Iceberg `IsolationLevel`** — handle commit conflicts
- **LLM tool calls** = Result-like (success or tool error)
- **Anthropic `tool_use` errors** — explicit error type
- **Flink restart strategy** = error → checkpoint restore

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. Exception vs Result/Either — phân biệt 1 câu.
2. Java checked exception — controversial vì sao?
3. Rust `?` operator — làm gì?

### 🟡 Medium
4. EAFP vs LBYL Python idiom — explain + example.
5. Exception cho control flow — anti-pattern. Cho example.
6. Performance: exception happy path vs error path — quantify.

### 🔴 Hard
7. Effect systems (Koka) — explain với example.
8. Algebraic effects vs exceptions — diff?
9. Trong DSX Air, where exception OK vs where Result/Either better?

> **6+/9** = sẵn sàng KU 13. **4-5** = đọc Bloch Item 69-77. **<4** = refactor Python project sang Result-style.

---

## 🔗 Liên kết

- **[F02/09 ADT + Monads](./09-adt-pattern-matching-monads.md)** — Result/Either is ADT
- **[F02/14 Testing philosophy](./14-testing-philosophy.md)** — testing error paths
- **[F00/05 Failure as feature](../F00-mental-models/05-failure-as-feature.md)** — fault tolerance
- **[F00/06 Idempotency](../F00-mental-models/06-idempotency.md)** — retry safety

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **PLAI (Krishnamurthi)** → `Krishnamurthi_PLAI_Brown.pdf` — chapter on continuations + effects.
- **Practical Haskell** → `Mena_Practical-Haskell-2ed.pdf` — `Either` + `MaybeT` patterns.

📖 **Sách commercial:**
- **Bloch, *Effective Java* 3rd ed** Items 69-77 — exception design.
- **Cliff Click, JVM expert blog** — exception costs.
- **Rust book** — Chapter 9 *Error Handling*.
- **Pavel Yosifovich, *Windows Internals*** — Windows SEH.

📄 **Paper gốc + reference:**
- Liskov & Snyder (1979), *"Exception Handling in CLU"*, IEEE Transactions on Software Engineering.
- Brachthäuser et al. (2018) — *"Effekt: Effects for Distributed Programming"*.
- Go FAQ — [why Go doesn't have exceptions](https://go.dev/doc/faq#exceptions).
- Joel Spolsky (2003), [*"Exceptions"*](https://www.joelonsoftware.com/2003/10/13/13/) — classic critique.

---

**Đã đọc xong?**
✅ Tick → [F02/13 Essential Design Patterns](./13-design-patterns.md).
