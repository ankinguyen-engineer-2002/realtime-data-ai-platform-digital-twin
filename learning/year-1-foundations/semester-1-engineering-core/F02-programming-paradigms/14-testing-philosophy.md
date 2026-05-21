# KU F02 / 14 — Testing philosophy + Property-based testing

> Test có 3 cấp: **unit** (1 hàm), **integration** (nhiều module), **e2e** (toàn hệ thống). Mỗi cấp giải quyết loại bug khác nhau. **Property-based testing** (QuickCheck Haskell, Hypothesis Python) generate hàng ngàn input ngẫu nhiên thoả property — bắt được bug mà example-based test bỏ sót. Hiểu philosophy = viết test đúng chỗ + đúng mức.

**Module:** [F02 — Programming Paradigms](./README.md)
**Prereqs:** [F02/06 SOLID](./06-solid-principles.md) · [F02/12 Error handling](./12-error-handling.md)
**Related KUs:** [F02/07 Pure functions](./07-pure-functions-immutability.md) · [F00/05 Failure as feature](../F00-mental-models/05-failure-as-feature.md)
**Đọc trong:** ~14 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Bạn mở **quán phở mới**. Có 3 cấp **kiểm tra chất lượng**:

### Unit test — "Thử từng nguyên liệu"
- Thịt bò có mềm không? Nước dùng có ngọt không? Bánh phở có dai không?
- Mỗi nguyên liệu **test riêng**. Nếu thịt cứng → biết ngay vấn đề thịt, không phải nước dùng.
- → Code: test 1 function độc lập, mock dependencies.

### Integration test — "Thử ghép 2-3 nguyên liệu"
- Bỏ thịt vào nước dùng → có tan vị không? Bánh phở chần nước sôi 30s có vừa chín không?
- Test **interaction** giữa các phần.
- → Code: test multiple modules cùng nhau, real DB (in test container), real HTTP mock.

### End-to-end (e2e) test — "Khách hàng đặt tô phở thật"
- Khách order → bếp nhận → phục vụ bưng ra → khách ăn → trả tiền.
- Test **toàn quy trình** như user thật.
- → Code: launch app, click button UI, verify final state.

### Property-based test — "Quy luật món ăn"
- Quy luật: "Mọi tô phở đều có **đúng 1 trứng** nếu khách yêu cầu thêm trứng."
- Generator: thử 1000 đơn hàng random (có/không trứng, nhiều topping, cay/không...).
- Tool kiểm tra **property luôn đúng** với mọi input — bắt bug bạn không nghĩ tới.
- → Code: `forall(orders, lambda o: assert pho(o).egg_count == o.egg_request)`.

→ **4 loại test = 4 lớp bảo vệ.** Pick đúng cấp cho từng loại bug.

---

## 🧩 The Crux of the Problem  *(OSTEP-style framing)*

> **Câu hỏi cốt lõi:** Bạn có code 50K dòng, mỗi commit mới đều có thể **break** tính năng cũ. Làm sao **catch regression** trước deploy + **không tốn 100% time viết test** thay vì viết feature?
>
> **Vì sao khó:** Test quá ít → bug ra prod. Test quá nhiều → code base maintenance hell, mỗi refactor phải sửa 200 test. Test sai cấp → unit test cho code phụ thuộc DB (chậm + flaky), e2e test cho logic thuần (chậm + overkill). Mock quá nhiều → test mock behavior, không phải real logic.
>
> **Điều ta cần:** Hiểu **Test Pyramid** (nhiều unit < integration < e2e) + biết viết **property** không phải example + biết **trade-off** giữa coverage vs maintenance.

→ **Reality 2026:** Modern teams xài kết hợp: unit (60%) + integration (30%) + e2e (10%) + property cho critical paths. Plus **CI** + **mutation testing** để verify test quality.

---

## 📖 Định nghĩa chính thức

### **3 loại test theo phạm vi**

**Unit test** — test 1 đơn vị (function/method/class) isolated. **Mock** dependencies. Run nhanh (ms). Output: tin tưởng function đúng logic.

**Integration test** — test 2+ module work together. Real DB (test container), real HTTP (test server). Run trung bình (seconds). Output: tin tưởng integration đúng.

**End-to-end (e2e)** — test toàn application from user perspective. UI clicks, full backend stack, real DB. Run chậm (minutes). Output: tin tưởng user flow OK.

### **Test Pyramid** (Mike Cohn, 2009)

```
        /\
       /e2e\        ~10% (slow, brittle, broad)
      /------\
     /  int   \     ~30% (medium speed)
    /----------\
   /    unit    \   ~60% (fast, focused)
  /--------------\
```

Recommend: **nhiều unit, ít e2e**. Ngược lại = "ice cream cone anti-pattern".

### **Test theo cách approach**

**Example-based test** = "given X → expected Y". Concrete examples.
```python
def test_add():
    assert add(2, 3) == 5
    assert add(0, 0) == 0
    assert add(-1, 1) == 0
```

**Property-based test** = "for all valid input, property P holds". Generator + shrinking.
```python
from hypothesis import given, strategies as st

@given(a=st.integers(), b=st.integers())
def test_add_commutative(a, b):
    assert add(a, b) == add(b, a)   # property: commutative
```

→ Property test sinh hàng ngàn input (kể cả edge case như `MAX_INT`, `0`, negative).

### **Test doubles** — fakes cho test

| Loại | Mô tả |
|---|---|
| **Stub** | Cung cấp pre-canned answer ("user X exists") |
| **Mock** | Stub + verify interactions ("`save()` called 3 times") |
| **Fake** | Hoạt động giống real nhưng đơn giản (in-memory DB) |
| **Spy** | Record what's called, verify later |
| **Dummy** | Object truyền vào nhưng không dùng (placeholder) |

### **Coverage metrics**
- **Line coverage** = % dòng code chạy bởi test
- **Branch coverage** = % nhánh if/else được test
- **Mutation testing** = thay đổi nhỏ trong code (mutant) — test có catch không? Tỷ lệ mutant chết = quality of tests.

**Nguồn:** Kent Beck *Test-Driven Development* (2002), Cohn *Succeeding with Agile* (2009) — Test Pyramid, Hughes *QuickCheck* paper (2000) — property-based testing.

---

## 📜 Lịch sử ngắn  *(etymology + invention)*

- **Unit testing** có từ rất sớm (Mercury computer 1950s, NASA). Nhưng kỉ luật hoá bởi **Kent Beck** với **SUnit (1989)** cho Smalltalk.
- **JUnit (1997)** — **Kent Beck + Erich Gamma** — viết trên máy bay. Phổ biến testing cho Java cộng đồng.
- **Test-Driven Development (TDD)** — Kent Beck phổ biến (2002) — viết test trước, code sau. Red-Green-Refactor cycle.
- **QuickCheck (2000)** — **Koen Claessen + John Hughes** (Chalmers, Thuỵ Điển) — *"QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs"*. Phát minh **property-based testing**.
- **Hypothesis (2013)** — **David MacIver** — port QuickCheck sang Python với shrinking improvements.
- **Behavior-Driven Development (BDD)** — Dan North (2003) — Cucumber, Given-When-Then DSL.
- **Mutation testing (Stryker, PIT)** — measure test quality bằng cách mutate code.
- **Today (2026):** Mỗi modern lang có ecosystem test mature. Property-based testing dần phổ biến (Hypothesis cho Python, fast-check cho JS, proptest cho Rust). **Snapshot testing** (Jest) cho UI. **Mutation testing** ngày càng phổ biến CI.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Unit test | Unit test | Test 1 đơn vị isolated |
| Integration test | Integration test | Test nhiều module cùng nhau |
| End-to-end test | End-to-end / e2e | Test toàn app từ user view |
| Smoke test | Smoke test | Quick sanity check |
| Regression test | Regression test | Catch bug đã sửa trước đó |
| Test fixture | Test fixture | Setup data cho test |
| Mock | Mock | Test double verify behavior |
| Stub | Stub | Pre-canned answer |
| Fake | Fake | Simplified working impl |
| Spy | Spy | Record + verify calls |
| Test double | Test double | Generic term |
| Test runner | Test runner | Framework chạy tests |
| Assertion | Assertion | Verify condition |
| Property | Property | Universal statement |
| Generator | Generator | Random input source |
| Shrinking | Shrinking | Find minimal failing input |
| Coverage | Coverage | % code tested |
| Mutation testing | Mutation testing | Mutate code → test detect? |
| TDD | TDD | Write test first, code second |
| BDD | BDD | Given-When-Then style |
| Flaky test | Flaky test | Sometimes pass, sometimes fail |
| Test pyramid | Test pyramid | Nhiều unit < integration < e2e |
| Ice cream cone | Ice cream cone | Anti-pattern: ngược pyramid |
| Snapshot test | Snapshot test | Compare output với baseline |
| Golden file | Golden file | Saved expected output |
| Property-based | Property-based testing | Test ∀ input |

---

## 💡 Real-world examples

### Unit test (pytest)

```python
def add(a: int, b: int) -> int:
    return a + b

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    assert add(0, 0) == 0
```

→ Test thuần logic, không phụ thuộc DB / network. Chạy ms.

### Integration test với testcontainers

```python
from testcontainers.postgres import PostgresContainer

def test_user_repo():
    with PostgresContainer("postgres:16") as pg:
        repo = UserRepository(pg.get_connection_url())
        repo.create(User(name="Aric", email="a@b.com"))
        loaded = repo.find_by_email("a@b.com")
        assert loaded.name == "Aric"
# Real Postgres trong Docker, chạy seconds
```

### End-to-end test với Playwright

```python
def test_user_signup(page):
    page.goto("https://app.example.com/signup")
    page.fill("#email", "a@b.com")
    page.fill("#password", "secret123")
    page.click("button[type=submit]")
    page.wait_for_url("**/dashboard")
    assert "Welcome" in page.content()
# Real browser, real backend, real DB, chạy 30s+
```

### Property-based test với Hypothesis

```python
from hypothesis import given, strategies as st

# Property: reverse(reverse(xs)) == xs
@given(xs=st.lists(st.integers()))
def test_reverse_involution(xs):
    assert reverse(reverse(xs)) == xs

# Property: sort(xs) là permutation của xs + sorted
@given(xs=st.lists(st.integers()))
def test_sort_correct(xs):
    sorted_xs = my_sort(xs)
    assert len(sorted_xs) == len(xs)
    assert all(sorted_xs[i] <= sorted_xs[i+1] for i in range(len(sorted_xs)-1))
    assert sorted(sorted_xs) == sorted(xs)   # same multiset

# Property: encode → decode = identity
@given(s=st.text())
def test_encode_decode(s):
    assert decode(encode(s)) == s
```

→ Hypothesis sinh 1000+ test cases tự động: empty list, single element, sorted, reverse-sorted, duplicates, Unicode characters, các edge case bạn không nghĩ ra.

### Khi property-based catch bug example test miss

```python
def calculate_discount(price, percent):
    return price * (1 - percent / 100)

# Example test pass
def test_discount():
    assert calculate_discount(100, 10) == 90
    assert calculate_discount(50, 50) == 25

# Property test catch bug
@given(price=st.floats(min_value=0), percent=st.floats(min_value=0, max_value=200))
def test_discount_positive(price, percent):
    result = calculate_discount(price, percent)
    assert result >= 0    # ← Hypothesis tìm ra: percent=150 → negative price!
```

→ Property test phát hiện edge case `percent > 100` mà human-written examples bỏ sót.

### Production testing — DSX Air examples

| Component | Test approach |
|---|---|
| **Spark transformation function** | Unit (mock DataFrame) + Integration (real Spark local) |
| **Kafka consumer logic** | Unit (mock consumer) + Integration (testcontainers Kafka) |
| **Iceberg table writer** | Integration (local MinIO + Hadoop catalog) |
| **dbt model** | dbt test (`unique`, `not_null`, `relationships`) + custom SQL test |
| **API endpoint** | Unit (FastAPI TestClient) + e2e (Playwright nếu UI) |
| **Schema migration** | Integration (apply migration on test DB) |
| **Flink job** | Integration (MiniCluster) |
| **Anthropic LLM tool call** | Mock LLM response + property test schema validity |

### Production property test — Spark transformation

```python
from pyspark.sql import SparkSession
from hypothesis import given
from hypothesis.strategies import lists, integers
import pyspark.sql.functions as F

def total_revenue(df):
    return df.agg(F.sum("amount").alias("total")).first()["total"]

@given(amounts=lists(integers(min_value=0, max_value=1_000_000), min_size=1))
def test_total_revenue_property(spark, amounts):
    df = spark.createDataFrame([(a,) for a in amounts], ["amount"])
    result = total_revenue(df)
    assert result == sum(amounts)   # property: aggregate matches Python sum
```

---

## 🧮 Pseudocode — TDD cycle + Property test  *(Erickson UIUC style)*

### TDD Red-Green-Refactor cycle

```
TDD_CYCLE(feature):
    《1. RED — Viết test failing》
    write_test("test_" + feature)
    run_test()                       《expected: FAIL》

    《2. GREEN — Viết code minimum để pass》
    write_minimal_code()
    run_test()                       《expected: PASS》

    《3. REFACTOR — Cải thiện code không break test》
    refactor_code()
    run_test()                       《expected: STILL PASS》

    《Repeat》
```

### Property-based test với shrinking

```
PROPERTY_TEST(property, generator):
    for trial in 1..1000:
        input ← generator.next()         《random input》
        if not property(input):
            minimal ← SHRINK(input, property)
            return FAIL(minimal)         《report smallest failing input》
    return PASS

SHRINK(input, property):
    《Try smaller variations until still fails》
    while exists smaller input with !property:
        input ← smaller_variant
    return input

《Ví dụ: list [3, 7, 1, 9, 2] fails reverse property》
《Shrink: [3, 7, 1, 9] → [3, 7] → [3] → [] → minimal》
```

### Test pyramid balance

```
TEST_SUITE:
    《60% unit tests》
    for each function f:
        test_normal_case(f)
        test_edge_cases(f)
        test_error_cases(f)

    《30% integration tests》
    for each major workflow:
        setup_test_db_kafka_s3()
        run_workflow()
        verify_state()
        teardown()

    《10% e2e tests》
    for each critical user flow:
        launch_app()
        simulate_user_actions()
        verify_outcome()
        cleanup()
```

---

## 📊 Cost annotation table — test type trade-offs  *(Sedgewick Princeton style)*

| Test type | Speed | Confidence | Maintenance | Flakiness | Khi nào dùng |
|---|---|---|---|---|---|
| **Unit** | ⚡ ms | Hẹp (1 function) | Low | Hiếm | Logic thuần |
| **Integration** | seconds | Trung bình | Medium | Medium | Kiểm tra module ghép |
| **End-to-end** | minutes | Cao (user view) | High | High | Critical user flow |
| **Property-based** | seconds | Rộng (∀ input) | Medium | Có thể (nếu non-deterministic) | Logic có invariants |
| **Snapshot** | ms | UI rendering | Medium (lots of update) | Low | UI components |
| **Smoke** | seconds | Quick sanity | Low | Low | CI deploy verification |
| **Mutation** | minutes-hours | Test quality | High | n/a | Verify test thoroughness |

### Khi nào pick mỗi loại

| Scenario | Pick |
|---|---|
| Function thuần (pure) | Unit + property |
| Function gọi DB | Integration |
| API endpoint | Integration (request/response) |
| Critical user flow checkout | E2E |
| Distributed system fail tolerance | Integration với chaos injection |
| Logic có rule rõ (sort, reverse, encode/decode) | Property-based |
| LLM tool call validation | Property-based + integration |
| Critical algorithm (compression, hash) | Property-based |

### Cost-benefit empirical

Theo Google + Microsoft research:
- **80% test = unit + integration** — ROI tốt nhất
- **5-10% e2e** — bắt regression user flow, đắt nhưng cần
- **Property-based critical logic** — bắt bug example test bỏ sót
- **Mutation testing** — verify test quality, chạy weekly không daily

---

## ❌ Bad example / anti-pattern  *("Martin's algorithm" style)*

### Anti-pattern 1 — Ice cream cone (ngược pyramid)

```
       __________
      / many e2e \      ❌ 60% e2e tests → chậm, flaky, brittle
     /------------\
    /  some int    \
   /----------------\
  /   few unit       \  ← thiếu base
```

**Vì sao bad:** E2e tests chạy phút, vài fail/run vì flaky. CI lúc nào cũng đỏ. Pick: invert thành pyramid — nhiều unit, ít e2e.

### Anti-pattern 2 — Mock everything

```python
# ❌ Test gì cũng mock
def test_order():
    mock_db = Mock()
    mock_db.save.return_value = None
    mock_emailer = Mock()
    mock_payment = Mock()
    mock_logger = Mock()
    # ... 10 mocks

    service = OrderService(mock_db, mock_emailer, mock_payment, mock_logger)
    service.place_order(...)

    mock_db.save.assert_called_once()    # Test mock interaction, not real logic
```

**Vì sao bad:** Test verify mock được gọi đúng, không verify real behavior. Mọi thay đổi implementation → test fail dù logic vẫn đúng. Pick: integration test với real DB + only mock external services.

### Anti-pattern 3 — Test implementation chi tiết

```python
# ❌ Test private method / internal state
def test_internal():
    user = User("Aric")
    assert user._password_hash[:4] == "$2b$"   # ← bcrypt-specific!
    # Đổi sang argon2 → test fail dù behavior đúng
```

**Vì sao bad:** Test coupled với implementation. Pick: test behavior (`user.check_password("secret")`), not implementation.

### Anti-pattern 4 — Test snapshot không bao giờ review

```javascript
// ❌ Auto-accept snapshot updates
toMatchSnapshot()

// Khi UI thay đổi → "u" key update snapshot
// Sau 6 tháng → snapshot file 5000 dòng không ai review
```

**Vì sao bad:** Snapshot test trở thành no-op. Cần review snapshot diff như review code.

### Anti-pattern 5 — Flaky test ignored

```python
# ❌ Test fail thỉnh thoảng → mark là "known flaky"
@pytest.mark.flaky(reruns=3)
def test_eventual_consistency():
    create_user()
    time.sleep(1)
    assert find_user() is not None    # sometimes still None
```

**Vì sao bad:** Bug giấu trong flaky test. Pick: fix root cause (polling instead of sleep, or proper sync primitive). Không ignore.

### Anti-pattern 6 — Coverage gaming

```python
# ❌ Viết test chỉ để tăng coverage %
def test_all_branches():
    foo(1); foo(2); foo(3); foo(-1)
    # No assertions! 100% line coverage but 0% behavior verification
```

**Vì sao bad:** Coverage không = quality. Pick: mutation testing để verify test thật catch bugs.

---

## 🔧 Patterns — testing best practices

### Pattern 1: Arrange-Act-Assert (AAA)

```python
def test_withdraw():
    # Arrange — setup
    account = Account(balance=100)

    # Act — single action
    account.withdraw(30)

    # Assert — verify outcome
    assert account.balance == 70
```

### Pattern 2: Given-When-Then (BDD style)

```gherkin
Given a user with balance 100
When user withdraws 30
Then balance should be 70
```

### Pattern 3: Fixture sharing với pytest

```python
@pytest.fixture
def test_db():
    db = create_test_db()
    yield db
    db.cleanup()

def test_user(test_db):
    test_db.save(User("Aric"))
    assert test_db.count() == 1
```

### Pattern 4: Property invariants cho data structures

Cho stack:
- `push(x).pop() == x` (LIFO)
- `is_empty() == (size() == 0)`
- `push(x).size() == size() + 1`

Cho sort:
- Length unchanged: `len(sort(xs)) == len(xs)`
- Permutation: `sorted(sort(xs)) == sorted(xs)` (same multiset)
- Ordered: `∀i: sort(xs)[i] ≤ sort(xs)[i+1]`

Cho encoder/decoder:
- Round-trip: `decode(encode(x)) == x`
- Length: `len(encode(x)) ≥ len(x)` (no compression loss)

### Pattern 5: Snapshot test với golden files

```python
def test_render_invoice():
    inv = Invoice(items=[Item("A", 100)], tax=10)
    rendered = render(inv)
    expected = open("testdata/invoice_golden.txt").read()
    assert rendered == expected
# Khi UI/format đổi: review golden diff, update có ý thức
```

---

## 🌱 Advanced topics

### A1. Mutation testing
Tools: Stryker (JS), PIT (Java), mutmut (Python). Tự động thay đổi nhỏ trong code (mutant) → run test → đếm % mutant "chết" (test catch). Mutation score 70%+ = test thật sự kiểm tra logic.

### A2. Fuzz testing
Cousin của property-based. Sinh random bytes / mutations để stress test parsers, file readers, network protocols. Tools: AFL, libFuzzer, Atheris (Python).

### A3. Chaos engineering
Test production resilience bằng cách injected fault: kill process, network partition, CPU spike. Netflix Chaos Monkey, Litmus Chaos cho K8s.

### A4. Contract testing (Pact)
Test API contract giữa services trong microservices. Provider + consumer agree contract, test verify cả 2 side tuân thủ.

### A5. Apply cho DE / AI 2026
- **dbt** — built-in test: `unique`, `not_null`, `accepted_values`, `relationships`. Plus custom SQL test.
- **Great Expectations** — data quality testing framework.
- **Iceberg unit tests** — Apache Iceberg repo dùng property test cho metadata operations.
- **Spark** — `SparkSession` local mode cho unit, MiniCluster cho integration.
- **LLM evaluation** — golden test set + property check (e.g., output is valid JSON, không chứa PII).
- **Anthropic prompt caching** — property test prompt prefix → cache key deterministic.

---

## 🧠 Self-test (3 levels)

### 🟢 Easy
1. Unit / integration / e2e — phân biệt 1 câu.
2. Test pyramid — tỉ lệ recommend?
3. Property-based test — khác example test thế nào?

### 🟡 Medium
4. Mock vs Stub vs Fake — diff?
5. Ice cream cone anti-pattern — explain hậu quả.
6. Cho 1 ví dụ property mà bạn áp dụng cho `sort` function.

### 🔴 Hard
7. Mutation testing — explain workflow.
8. TDD Red-Green-Refactor — explain với 1 ví dụ.
9. Trong DSX Air, đâu unit test, đâu integration, đâu property test? (Hint: Spark transformation, Iceberg metadata, dbt model).

> **6+/9** = hoàn thành F02! **4-5** = đọc Kent Beck TDD By Example. **<4** = viết 1 dự án nhỏ với TDD cycle.

---

## 🔗 Liên kết

- **[F02/06 SOLID](./06-solid-principles.md)** — DIP enable testing (mock dependencies)
- **[F02/07 Pure functions](./07-pure-functions-immutability.md)** — easiest to unit test
- **[F02/12 Error handling](./12-error-handling.md)** — test error paths
- **[F00/05 Failure as feature](../F00-mental-models/05-failure-as-feature.md)** — accept failures gracefully

---

## 🌐 Đọc thêm — refs cụ thể vào library

📚 **Trong [library/books/programming-paradigms/](../../../../library/books/programming-paradigms/):**

- **PLAI (Krishnamurthi)** → `Krishnamurthi_PLAI_Brown.pdf` — testing language semantics.

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **Downey ThinkPython2** → `Downey_ThinkPython2.pdf` — chương về testing.

📖 **Sách commercial:**
- **Kent Beck, *Test-Driven Development By Example*** (2002) — foundational TDD book.
- **Gerard Meszaros, *xUnit Test Patterns*** — testing patterns catalog.
- **Lisa Crispin & Janet Gregory, *Agile Testing*** — testing in agile teams.
- **Hypothesis docs** — [hypothesis.readthedocs.io](https://hypothesis.readthedocs.io/) — Python property testing.

📄 **Paper gốc + reference:**
- Claessen & Hughes (2000), *"QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs"*, ICFP.
- Beck (2002) — *Test-Driven Development By Example*.
- Cohn (2009) — *Succeeding with Agile* (test pyramid).
- Google Testing Blog — [testing.googleblog.com](https://testing.googleblog.com/).
- Spotify Engineering blog on test pyramid evolution.
- pytest documentation — [docs.pytest.org](https://docs.pytest.org/).

---

**Đã đọc xong?** 🎉 **F02 Programming Paradigms COMPLETE — 14/14 KUs!**
✅ Tick checklist → đi tiếp [F03 Modern Python for Data](../F03-modern-python-for-data/).
