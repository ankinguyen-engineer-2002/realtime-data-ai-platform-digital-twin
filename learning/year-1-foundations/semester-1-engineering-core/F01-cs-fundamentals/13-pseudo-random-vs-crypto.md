# KU F01 / 13 — Pseudo-random vs crypto-random

> Random number generator (RNG) chia 2 nhánh: **fast pseudo-random** (cho simulation, sampling) vs **slow crypto-random** (cho security). Dùng **sai** = bug nghiêm trọng (predictable token, biased sampling).

**Module:** [F01 — CS Fundamentals](./README.md)
**Prereqs:** [F01/12 Bit manipulation](./12-bit-manipulation.md)
**Related KUs:** [F13 Security](../../semester-2-systems-theory/F13-security-privacy/)
**Đọc trong:** ~10 phút
**Mức độ:** Foundational

---

## 🎯 Nó là gì? (Analogy đời sống)

Hai cách "random":

### Cách 1 — Pseudo-random: máy "có vẻ" random
- Một **công thức** chạy đi chạy lại: `x_(n+1) = (a * x_n + c) mod m`
- Cho 1 seed → output sequence trông như random nhưng **DETERMINISTIC**.
- Cùng seed → cùng sequence.
- Nhanh, dùng cho simulation, shuffle, sampling.

### Cách 2 — Crypto-random: lấy từ "noise tự nhiên"
- Lấy entropy từ **thiết bị vật lý**: timing keystrokes, mouse movement, network packets, thermal noise.
- **Không predictable** dù attacker có hệ thống mạnh.
- Chậm hơn (~10-100x), dùng cho password, session token, encryption key.

**Quan trọng:** Dùng nhầm = bug nghiêm trọng:
- Dùng `Math.random()` cho session token → attacker predict được → account takeover.
- Dùng `secrets.token_bytes()` cho game shuffle → chậm vô lý.

---

## 🧩 The Crux of the Problem  *(v3 — OSTEP-style framing)*

> **Core question:** Cần "số ngẫu nhiên" cho 2 mục đích khác nhau (simulation/game vs security token), khi nào pick PRNG vs CSPRNG?
>
> **Why hard:** PRNG nhanh (Mersenne Twister ~1 GB/s) nhưng **deterministic** — biết seed = predict toàn bộ sequence. CSPRNG safe nhưng cần **entropy source** (`/dev/urandom`) — chậm hơn, có thể block. Dùng nhầm = pre-2010 Bitcoin wallet bị brute-force, Java SecureRandom bug 2013 (Android wallets bị empty).
>
> **What we need:** Hiểu rõ **threat model** — có attacker không? Nếu có → CSPRNG. Nếu không (Monte Carlo simulation, game shuffle) → PRNG nhanh.

→ Senior pick correctly = không gây security incident. Junior nhầm `random` cho session token = mất account.

---

## 📜 Lịch sử ngắn  *(v3 — etymology + invention)*

- **Middle-square method (1949)** — **John von Neumann** — PRNG đầu tiên (computer-based). Square seed, take middle digits. Crude but pioneer.
- **Linear Congruential Generator (LCG, 1951)** — **D.H. Lehmer** — `Xₙ₊₁ = (a·Xₙ + c) mod m`. Đơn giản. Dùng trong `rand()` C/C++ legacy. Bad statistics.
- **Mersenne Twister (1997)** — **Makoto Matsumoto & Takuji Nishimura** (Hiroshima) — period 2^19937 − 1 (a Mersenne prime!). Today: Python `random`, NumPy default, MATLAB.
- **Xorshift (2003)** — **George Marsaglia** — extremely fast PRNG. PCG (2014) better statistics.
- **CSPRNG era:** Linux `/dev/random` (1994), `/dev/urandom` for blocking. Modern: ChaCha20-based (Linux 4.8+ 2016), Fortuna (Schneier 2003).
- **Famous failures:**
  - **Netscape SSL (1995)** — seed từ PID + thời gian → brute-force crack 30 phút.
  - **Debian OpenSSL (2008)** — bug làm RNG seed chỉ 32K possible values. Tất cả keys generated 2006-2008 vulnerable.
  - **Bitcoin Android (2013)** — Java SecureRandom collision → wallet thefts.
- **Today (2026):** Python `secrets`, Node `crypto.randomBytes`, Java `SecureRandom`, Go `crypto/rand` — đều dùng OS CSPRNG (chacha20 on Linux).

---

## ❌ Bad example / anti-pattern  *(v3 — "Martin's algorithm" style)*

### Anti-pattern 1 — `Math.random()` cho session token

```javascript
// ❌ Generate session token
const sessionToken = Math.random().toString(36).slice(2);
// V8 dùng XorShift128+ (PRNG). Attacker với vài samples có thể recover state.
// 2015: paper "Cracking V8 Math.random" reverse-engineer V8 state.
```

**Tại sao bad:** PRNG output predictable từ past outputs. Attacker collect session tokens → predict next → account takeover. Pick `crypto.randomBytes(32).toString('hex')`.

### Anti-pattern 2 — `secrets.token_bytes()` cho game shuffle

```python
# ❌ Shuffle deck of 52 cards bằng CSPRNG cho 1M games/sec
import secrets
def shuffle(deck):
    return sorted(deck, key=lambda _: secrets.randbits(32))
# /dev/urandom syscall overhead → block khi entropy pool low
```

**Tại sao bad:** Game shuffle không có threat model security. Pick `random.shuffle` (Mersenne Twister) — 100× nhanh hơn. CSPRNG chỉ cho password, token, key, salt.

### Anti-pattern 3 — Seed PRNG bằng `time.time()`

```python
# ❌ Reproducible seed across servers
import random, time
random.seed(int(time.time()))
token = random.randint(0, 2**32)
# Server time có thể sync close → seed collide
# Attacker với 1s window → 1000 candidates
```

**Tại sao bad:** `time.time()` ~32 bits entropy + predictable. Đây chính là Netscape SSL bug 1995. Pick CSPRNG (no seed).

### Anti-pattern 4 — Re-seed CSPRNG trong loop

```python
# ❌ "Want different randomness mỗi call"
import secrets, os
def my_random():
    secrets.SystemRandom(os.urandom(32))     # re-seed
    return secrets.randbits(32)
# OS RNG already cryptographic — re-seeding **giảm** security
```

**Tại sao bad:** OS RNG đã handle entropy properly. Re-seed = noise + slower. Just call `secrets.randbits(32)` directly.

---

## 📖 Định nghĩa chính thức

**PRNG (Pseudo-Random Number Generator)** — deterministic algorithm, đầu vào 1 seed (small entropy), output sequence "looks random" statistically.

Examples: Mersenne Twister (Python `random`), Xorshift, LCG, PCG.

**CSPRNG (Cryptographically Secure PRNG)** — PRNG satisfy security properties:
- Output **không predictable** dù biết past outputs.
- Forward + backward secrecy.
- Use OS entropy pool (/dev/urandom on Linux).

Examples: ChaCha20, AES-CTR DRBG, `secrets` module Python, `crypto.randomBytes()` Node.

**TRNG (True Random)** — pure physical noise (thermal, radioactive decay). Hardware-only.

**Nguồn:**
- Knuth TAOCP Vol 2 (Random Number Generation).
- RFC 4086 — Randomness Requirements for Security.

---

## 🔤 Terminology box

| Thuật ngữ | Tiếng Anh | Giải thích 1 câu |
|---|---|---|
| Số ngẫu nhiên giả | Pseudo-random number | Deterministic but looks random |
| Số ngẫu nhiên mật mã | Crypto-random | Unpredictable for security |
| Số ngẫu nhiên thật | True random | Physical noise source |
| PRNG | Pseudo-Random Number Generator | |
| CSPRNG | Cryptographically Secure PRNG | |
| TRNG | True RNG | Hardware-based |
| Seed | Seed | Initial value to PRNG |
| Entropy | Entropy | Unpredictability measure |
| Entropy pool | Entropy pool | OS-collected randomness |
| LCG | Linear Congruential Generator | Simple PRNG |
| Mersenne Twister | Mersenne Twister | Python default PRNG |
| Xorshift | Xorshift | Fast PRNG |
| PCG | Permuted Congruential Generator | Modern fast PRNG |
| ChaCha20 | ChaCha20 | Modern CSPRNG stream cipher |
| /dev/urandom | /dev/urandom | Linux entropy source |
| getrandom() | getrandom() | Modern Linux entropy syscall |
| Reseeding | Reseeding | Periodically refresh entropy |

---

## 💡 Real-world impact

### Use case map

| Use case | RNG type | Why |
|---|---|---|
| Game shuffle | PRNG (Math.random) | Speed, no security need |
| ML data shuffling | PRNG with seed | Reproducible experiments |
| A/B test assignment | PRNG | Reproducible |
| Monte Carlo simulation | PRNG | Speed, billions of calls |
| Session token | **CSPRNG** | Unpredictable required |
| Password reset link | **CSPRNG** | Don't want attacker predict |
| Encryption key | **CSPRNG** | Security critical |
| API rate limit token | **CSPRNG** | Avoid replay |
| UUID v4 | **CSPRNG** (most impls) | Uniqueness + security |
| Salt for password hash | **CSPRNG** | Defeat rainbow tables |

### Real bug — JS Math.random() for token

```js
// ❌ BAD
const token = Math.random().toString(36).slice(2);
// → Attacker knows V8 algorithm + state → predict next tokens
```

```js
// ✅ GOOD
const crypto = require('crypto');
const token = crypto.randomBytes(32).toString('hex');
```

### Python equivalent

```python
import random
import secrets

# Pseudo (OK for shuffle, sampling)
random.shuffle(my_list)
random.seed(42)  # reproducible

# Crypto (REQUIRED for security)
token = secrets.token_hex(32)
api_key = secrets.token_urlsafe(32)
```

→ Python clearly separates: `random` module = PRNG, `secrets` = CSPRNG.

---

## 🔧 PRNG mechanics

### Linear Congruential Generator (LCG) — simplest

```
x_(n+1) = (a * x_n + c) mod m

Common: a=1103515245, c=12345, m=2^31 (C library rand)
```

→ Period limited. Predictable. Don't use for serious work.

### Mersenne Twister (Python `random`)

Period 2^19937 - 1. Statistical quality excellent. **NOT crypto secure** (state recoverable from 624 outputs).

### Xorshift, PCG (modern fast)

Tiny state, good distribution, very fast. Modern game engines, simulations.

### ChaCha20 (modern CSPRNG)

Stream cipher repurposed as CSPRNG. Used in Linux /dev/urandom (since 5.18), BSD arc4random.

---

## ⚠️ Common pitfalls

### Pitfall 1 — Math.random() for security

❌ Predictable. Attacker recovers state → predict tokens.

✅ `crypto.randomBytes()` / `secrets.token_*`.

### Pitfall 2 — Seed PRNG with predictable value

❌ `random.seed(int(time.time()))` → attacker knows ~time → narrow seed space.

✅ For security: don't seed, use CSPRNG. For repro: explicit seed in tests only.

### Pitfall 3 — Same seed across processes

❌ Multiple worker processes seed with same `os.getpid() % small_n` → same sequence → biased sampling.

✅ Use `os.urandom()` to seed, or unique seed per worker.

### Pitfall 4 — UUID v1 for security

❌ UUID v1 = MAC address + timestamp → predictable + leaks info.

✅ UUID v4 (random) or v7 (time-ordered random).

### Pitfall 5 — Modulo bias

❌ `random_int % n` → if `MAX % n != 0` → bias.

✅ Reject samples until uniform: `secrets.randbelow(n)`.

---

## 🌱 Advanced topics

### A1. /dev/random vs /dev/urandom

Old Linux: `/dev/random` block when entropy low. `/dev/urandom` non-blocking, reuse pool.

Modern (5.18+): both equivalent, use ChaCha20 DRBG.

→ Use `getrandom()` syscall (Linux 3.17+) for best.

### A2. Quantum RNG

Hardware using quantum effects (photon detection, beam splitter). True randomness.

→ ID Quantique, IBM cloud quantum random.

### A3. Reproducible randomness in ML

```python
import random, numpy as np, torch

SEED = 42
random.seed(SEED)
np.random.seed(SEED)
torch.manual_seed(SEED)
torch.cuda.manual_seed_all(SEED)
torch.backends.cudnn.deterministic = True
```

→ Multiple sources of randomness in ML. Seed all.

### A4. Apply cho LLM 2026

- **LLM sampling**: temperature, top-k, top-p use PRNG. `seed` parameter cho reproducible.
- **Differential privacy noise**: needs CSPRNG cho security.
- **Adversarial robustness**: random initialization needs care.

---

## 🧠 Self-test

1. PRNG vs CSPRNG: difference + 1 use case each.
2. Why `Math.random()` for session token is critical bug?
3. Mersenne Twister: secure? Why?
4. UUID v1 vs v4: which secure?
5. Modulo bias: explain + fix.
6. Reproducible ML: how many seeds to set?

---

## 🔗 Liên kết

- **[F01/12 Bit manipulation](./12-bit-manipulation.md)** — XOR-based PRNG
- **[F13 Security](../../semester-2-systems-theory/F13-security-privacy/)** — crypto deep
- **[F14 Math for AI](../../semester-2-systems-theory/F14-math-for-data-ai/)** — random sampling

---

## 🌐 Đọc thêm — refs cụ thể vào library  *(v3 — pointers chính xác)*

📚 **Trong [library/books/cs-fundamentals/](../../../../library/books/cs-fundamentals/):**

- **MIT Math for CS** → `Lehman_MIT_MathForCS.pdf` — probability + random variable foundations.
- **Downey ThinkStats2** → `Downey_ThinkStats2.pdf` — statistical inference cần PRNG quality awareness.

📄 **Paper gốc + spec:**
- von Neumann (1949), *"Various Techniques Used in Connection with Random Digits"* — middle-square method.
- Lehmer (1951) — LCG original.
- Matsumoto & Nishimura (1998), *"Mersenne Twister: A 623-dimensionally Equidistributed Uniform Pseudo-random Number Generator"*, ACM TOMACS.
- O'Neill (2014), *"PCG: A Family of Simple Fast Space-Efficient Statistically Good Algorithms for Random Number Generation"* — [pcg-random.org](https://www.pcg-random.org/).
- NIST SP 800-90A — DRBG mechanisms (CSPRNG standard).
- Goldberg & Wagner (1996), *"Randomness and the Netscape Browser"* — first major SSL RNG break.
- [How "Math.random()" is implemented in V8](https://v8.dev/blog/math-random) — public V8 design.

---

**Đã đọc xong?**
✅ Tick → [F01/14 Floating point](./14-floating-point.md).
