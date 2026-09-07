# Bit Strings (CSES Task 1617 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1617 - Bit Strings](https://cses.fi/problemset/task/1617)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Your task is to calculate the number of bit strings of length $n$. Because the answer may be very large, print it modulo $10^9 + 7$.
- **Constraints**: $1 \le n \le 10^6$.

---

## 1. Problem, Restated

Compute $2^n \pmod{10^9 + 7}$, where $n$ is an integer up to $10^6$.

**Input**: A single integer $n$ via `cin`.  
**Output**: Print $2^n \pmod{10^9 + 7}$ on `cout` ending with `\n`.  
**Constraints**: $n \le 10^6$. Since $2^{10^6}$ has over $300,000$ digits, we must apply modulo arithmetic $10^9 + 7$ at every multiplication step to prevent integer overflow.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Combinatorics (Rule of Product) / Binary Exponentiation / Modular Arithmetic.
- **Aha! Insight**:
  - A bit string of length $n$ is an ordered sequence $(b_1, b_2, \dots, b_n)$ where each $b_i \in \{0, 1\}$.
  - Each of the $n$ independent positions has exactly 2 options. By the multiplication principle:
    $$\text{Total Bit Strings} = \underbrace{2 \times 2 \times \dots \times 2}_{n \text{ times}} = 2^n$$
  - To compute $2^n \pmod{10^9 + 7}$:
    - A simple linear loop takes $\mathcal{O}(n)$ time.
    - Binary Exponentiation (repeated squaring) computes $2^n$ in $\mathcal{O}(\log n)$ time by utilizing the property:
      $$2^n = \begin{cases} (2^{n/2})^2 & \text{if } n \text{ is even} \\ 2 \cdot 2^{n-1} & \text{if } n \text{ is odd} \end{cases}$$
- **Signal**: "Count strings of length $n$ with alphabet size $k$ modulo $M$" is the canonical power $k^n \pmod M$ problem.

---

## 3. Approach 1 — Naive / Baseline (Linear Modular Multiplication)

### Idea
Iterate $n$ times, multiplying an accumulator by 2 and taking modulo $10^9 + 7$ at each step.

### C++17 Code
```cpp
#include <iostream>

using namespace std;

int main() {
    int n;
    if (!(cin >> n)) return 0;

    const int MOD = 1e9 + 7;
    long long ans = 1;

    for (int i = 0; i < n; i++) {
        ans = (ans * 2) % MOD;
    }

    cout << ans << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n)$ — $n$ multiplications. For $n = 10^6$, takes $\approx 3$ ms.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary memory.
- **CSES Verdict**: Passes comfortably, but is sub-optimal for generalized constraints ($n \le 10^{18}$).

---

## 4. Approach 2 — Intermediate

No meaningful intermediate step — Approach 1 is already $\mathcal{O}(n)$, and binary exponentiation below improves it to $\mathcal{O}(\log n)$.

---

## 5. Approach 3 — Optimal CSES Solution (Binary Exponentiation in $\mathcal{O}(\log n)$)

### Idea
Use binary exponentiation (divide-and-conquer exponent squaring) to compute $2^n \pmod{10^9 + 7}$ in $\mathcal{O}(\log n)$ multiplications using 64-bit integers.

### C++17 Contest-Ready Code
```cpp
#include <iostream>

using namespace std;

const long long MOD = 1e9 + 7;

long long power(long long base, long long exp) {
    long long res = 1;
    base %= MOD;
    while (exp > 0) {
        if (exp & 1) {
            res = (res * base) % MOD;
        }
        base = (base * base) % MOD;
        exp >>= 1;
    }
    return res;
}

int main() {
    // Standardized Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    long long n;
    if (cin >> n) {
        cout << power(2, n) << '\n';
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(\log n)$ — at most $2 \lfloor \log_2 n \rfloor$ modular multiplications. For $n = 10^6$, this takes $\le 20$ operations ($< 0.01$ ms).
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary space.
- **Optimality Guarantee**: Matches the best known/asymptotically optimal complexity for the problem and easily generalizes to $n \le 10^{18}$.

---

## 6. Correctness Proof

- **Combinatorial Characterization**: The set of bit strings of length $n$ is the Cartesian product $\{0, 1\}^n$. The cardinality is $|\{0, 1\}|^n = 2^n$.
- **Modular Homomorphism**: For integers $a, b$ and modulus $M$:
  $$(a \cdot b) \bmod M = ((a \bmod M) \cdot (b \bmod M)) \bmod M$$
  Therefore, reducing modulo $M$ at each step of repeated squaring preserves the exact congruence class of $2^n \pmod M$.
- **Binary Exponentiation Invariant**:
  - Let the binary representation of the exponent be $n = \sum_{i=0}^k b_i 2^i$, with $b_i \in \{0, 1\}$.
  - Then $2^n = \prod_{i=0}^k 2^{b_i 2^i} = \prod_{i: b_i = 1} 2^{2^i}$.
  - In the algorithm, the variable `base` computes $2^{2^i} \pmod M$ via successive squaring `base = (base * base) % MOD`.
  - The variable `res` accumulates factors where the $i$-th bit of $n$ is 1 (`if (exp & 1)`).
  - Loop invariant: At the start of iteration $i$, $\text{res} \cdot \text{base}^{\text{exp}} \equiv 2^n \pmod M$.
  - When $\text{exp} = 0$, $\text{res} \cdot \text{base}^0 = \text{res} \equiv 2^n \pmod M$.
- **Termination**: The exponent `exp` is halved on every iteration (`exp >>= 1`). It reaches 0 in exactly $\lfloor \log_2 n \rfloor + 1$ iterations.

---

## 7. Dry Run & Visual State Trace

Input: `n = 13` (Binary: `1101`$_2 = 8 + 4 + 1$)

| Step | `exp` | `exp & 1`? | `base` (before) | `res` (after step) | `base` (after squaring) |
|:---:|:---:|:---:|:---:|:---:|:---:|
| 0 | 13 | Yes | 2 | $(1 \times 2) = 2$ | $2^2 = 4$ |
| 1 | 6 | No | 4 | 2 | $4^2 = 16$ |
| 2 | 3 | Yes | 16 | $(2 \times 16) = 32$ | $16^2 = 256$ |
| 3 | 1 | Yes | 256 | $(32 \times 256) = 8192$ | $256^2 = 65536$ |
| 4 | 0 | - | - | **8192** | Terminate |

Check: $2^{13} = 8192$. $8192 \pmod{10^9 + 7} = 8192$ ✅

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1$**: Loop runs once, returns $2 \pmod{10^9 + 7} = 2$.
- **$n = 0$ Boundary**: Algorithm handles $n = 0$ cleanly, returning $2^0 = 1$.
- **Overflow During Multiplication**:
  `res * base` can reach $(10^9 + 6) \times (10^9 + 6) \approx 10^{18}$.
  This exceeds 32-bit signed integer limits ($2.14 \times 10^9$).
  `res`, `base`, and `MOD` must be declared as `long long` to prevent arithmetic overflow before the modulo reduction is applied.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Q1: What if $n$ is as large as $10^{18}$?**
   - **A**: The binary exponentiation implementation already supports $n \le 10^{18}$ with `long long` without modification, finishing in $\le 60$ iterations.
2. **Q2: What if $n$ is given as an extremely large string of $10^6$ digits?**
   - **A**: Use Fermat's Little Theorem: since $10^9 + 7$ is prime, $a^{M - 1} \equiv 1 \pmod M$. We can first reduce the large exponent $n$ modulo $M - 1 = 10^9 + 6$ using Horner's method, then compute $2^{n \bmod (M - 1)} \pmod M$.
3. **Q3: What if we need the number of bit strings of length $n$ without consecutive 1s?**
   - **A**: This satisfies the Fibonacci recurrence $F(n + 2)$, computable via $2 \times 2$ Matrix Exponentiation in $\mathcal{O}(\log n)$ time.
4. **Q4: What if the modulus $M$ is not prime?**
   - **A**: Binary exponentiation works for any positive modulus $M$. For string-based huge exponents, use Euler's Totient Theorem: $a^n \equiv a^{n \bmod \phi(M) + \phi(M)} \pmod M$ for $n \ge \phi(M)$.
5. **Q5: Can we precompute answers for $Q \le 10^6$ queries in $\mathcal{O}(1)$ time per query?**
   - **A**: Yes. Precompute powers of 2 into an array `pow2[1000001]` in $\mathcal{O}(N)$ time. Each query is then answered in $\mathcal{O}(1)$ lookup time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `Math`, `Binary-Exponentiation`, `Combinatorics`, `Modular-Arithmetic`, `Fast-IO`
- **Complexity Summary**:
  - **Time**: $\mathcal{O}(\log n)$
  - **Space**: $\mathcal{O}(1)$ auxiliary space
- **Related CSES Problems**:
  - **[CSES 1095 - Exponentiation](https://cses.fi/problemset/task/1095)**: Direct binary exponentiation of $a^b \pmod{10^9 + 7}$.
  - **[CSES 1096 - Exponentiation II](https://cses.fi/problemset/task/1096)**: Tower of powers $a^{b^c}$ using Fermat's Little Theorem.
  - **[CSES 1715 - Creating Strings II](https://cses.fi/problemset/task/1715)**: Combinatorial multinomial coefficients modulo $10^9 + 7$.
