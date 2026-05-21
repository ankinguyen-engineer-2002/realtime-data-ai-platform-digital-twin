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

**Đã đọc xong?**
✅ Tick → [F01/14 Floating point](./14-floating-point.md).
