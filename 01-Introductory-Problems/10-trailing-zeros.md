# Trailing Zeros (CSES Task 1618 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1618 - Trailing Zeros](https://cses.fi/problemset/task/1618)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Your task is to calculate the number of trailing zeros in the decimal representation of the factorial $n!$.
- **Constraints**: $1 \le n \le 10^9$.

---

## 1. Problem, Restated

Find the number of consecutive zeros at the end of the number $n! = 1 \times 2 \times 3 \times \dots \times n$.

**Input**: A single integer $n$ via `cin`.  
**Output**: Print the number of trailing zeros on `cout` ending with `\n`.  
**Critical Constraints**: $n \le 10^9$. Directly computing $n!$ is impossible, as $n!$ for $n = 10^9$ has over $8.5 \times 10^9$ decimal digits. An $\mathcal{O}(n)$ scan counting prime factors of each number also heavily TLEs ($10^9$ operations). An $\mathcal{O}(\log_5 n)$ closed-form reduction is required.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Number Theory / Prime Factorization / Legendre's Formula.
- **Aha! Insight**:
  - In base 10, a trailing zero is produced by each factor of $10 = 2 \times 5$.
  - In the prime factorization of $n! = 2^{a} \cdot 3^{b} \cdot 5^{c} \cdots$, the number of trailing zeros is given by $\min(a, c)$.
  - In any factorial $n!$, every second integer is a multiple of 2, while only every fifth integer is a multiple of 5. Therefore, prime factor 2 occurs strictly more frequently than prime factor 5 ($a > c$).
  - Hence, the count of trailing zeros is exactly equal to the exponent of 5 in the prime factorization of $n!$, denoted $E_5(n!)$.
  - By **Legendre's Formula**:
    $$E_5(n!) = \sum_{k=1}^{\infty} \left\lfloor \frac{n}{5^k} \right\rfloor = \left\lfloor \frac{n}{5} \right\rfloor + \left\lfloor \frac{n}{25} \right\rfloor + \left\lfloor \frac{n}{125} \right\rfloor + \dots$$
  - Since $5^{13} \approx 1.22 \times 10^9 > 10^9$, the summation terminates in at most 13 divisions!
- **Signal**: "Count trailing zeros in $n!$ or combinations $\binom{n}{k}$" $\implies$ Count prime factors of the prime base (typically 5 for base 10) using Legendre's Formula.

---

## 3. Approach 1 — Naive / Baseline (Explicit Factorial Calculation)

### Idea
Compute $n!$ and count how many times it can be divided by 10.

### Complexity & Feasibility
- $10^9!$ cannot be stored in any primitive or BigInt memory within 512 MB.
- Time Complexity: $\mathcal{O}(n^2 \log n)$ using big integer arithmetic.
- CSES Verdict: Extreme TLE and MLE.

---

## 4. Approach 2 — Intermediate (Iterating over All Multiples of 5)

Iterate over all integers $5, 10, 15, \dots \le n$. For each multiple, count how many times it can be divided by 5:
```cpp
long long zeros = 0;
for (long long i = 5; i <= n; i += 5) {
    long long temp = i;
    while (temp % 5 == 0) {
        zeros++;
        temp /= 5;
    }
}
```
Time Complexity: $\mathcal{O}(n/5) = 2 \cdot 10^8$ operations. While $\mathcal{O}(n)$, it approaches the 1.00s time limit on CSES.

---

## 5. Approach 3 — Optimal CSES Solution (Legendre's Formula in $\mathcal{O}(\log_5 n)$)

### Idea
Repeatedly divide $n$ by 5 and add $\lfloor n / 5 \rfloor$ to the total count until $n = 0$.

### C++17 Contest-Ready Code
```cpp
#include <iostream>

using namespace std;

int main() {
    // Standardized Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    long long n;
    if (!(cin >> n)) return 0;

    long long zeros = 0;
    while (n > 0) {
        zeros += n / 5;
        n /= 5;
    }

    cout << zeros << '\n';

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(\log_5 n)$ — for $n = 10^9$, $\lfloor \log_5(10^9) \rfloor = 12$ iterations. Runs in $< 0.001$ ms.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary memory.
- **Optimality Guarantee**: Matches the best known/asymptotically optimal complexity for prime exponent counting in factorials and comfortably satisfies the CSES limits.

---

## 6. Correctness Proof

- **Equivalence to Exponent of 5**:
  - Every 10 in the prime factorization requires one factor of 2 and one factor of 5.
  - The number of factors of 2 in $n!$ is $E_2(n!) = \sum_{k=1}^\infty \lfloor n/2^k \rfloor$.
  - The number of factors of 5 in $n!$ is $E_5(n!) = \sum_{k=1}^\infty \lfloor n/5^k \rfloor$.
  - Since $\lfloor n/2^k \rfloor \ge \lfloor n/5^k \rfloor$ for all $k \ge 1$, we have $E_2(n!) > E_5(n!)$.
  - Therefore, the number of factors of 10 is $\min(E_2(n!), E_5(n!)) = E_5(n!)$.
- **Proof of Legendre's Formula**:
  - $n! = 1 \times 2 \times \dots \times n$.
  - Each multiple of 5 in $\{1, \dots, n\}$ contributes at least one factor of 5. There are $\lfloor n / 5 \rfloor$ such multiples.
  - Each multiple of $5^2 = 25$ contributes a second factor of 5. There are $\lfloor n / 25 \rfloor$ such multiples.
  - In general, each multiple of $5^k$ contributes an additional factor of 5 beyond those counted by powers $< k$.
  - Summing over all powers $k \ge 1$:
    $$E_5(n!) = \sum_{k=1}^\infty \left\lfloor \frac{n}{5^k} \right\rfloor$$
- **Algorithmic Equivalence**:
  In the loop:
  - Iteration 1: `zeros += n / 5`, update $n \leftarrow \lfloor n / 5 \rfloor$.
  - Iteration 2: `zeros += (n / 5) / 5 = n / 25`.
  - Iteration $k$: adds $\lfloor n / 5^k \rfloor$.
  The loop terminates precisely when $5^k > n$, summing the exact infinite series with zero truncation error.

---

## 7. Dry Run & Visual State Trace

Input: `n = 28`

| Iteration | `n` (start) | `n / 5` added | Cumulative `zeros` | Next `n = n / 5` |
|:---:|:---:|:---:|:---:|:---:|
| 1 | 28 | $\lfloor 28 / 5 \rfloor = 5$ | 5 | 5 |
| 2 | 5 | $\lfloor 5 / 5 \rfloor = 1$ | 6 | 1 |
| 3 | 1 | $\lfloor 1 / 5 \rfloor = 0$ | 6 | 0 (Terminate) |

Multiples of 5 in $28!$: $5, 10, 15, 20, 25$.
$5, 10, 15, 20$ contribute 1 factor each (4 factors).
$25 = 5^2$ contributes 2 factors.
Total factors of $5 = 4 + 2 = 6$.
Output: `6` ✅

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n < 5$ (e.g. $n = 1, 2, 3, 4$)**: $n / 5 = 0$; prints `0`. Correct since $4! = 24$ has no trailing zeros.
- **Power of 5 Boundaries (e.g. $n = 25$)**: Multiples of 25 correctly contribute 2 zeros ($25/5 + 5/5 = 5 + 1 = 6$).
- **$n = 10^9$ Maximum Constraint**: $n / 5 + n / 25 + \dots \approx 2.49 \times 10^8$. This easily fits in a standard 32-bit signed integer without overflow. We use `long long` for $n$ to guarantee safety across all platforms.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Q1: What if we need trailing zeros in base $B$ instead of base 10?**
   - **A**: Prime factorize $B = p_1^{a_1} p_2^{a_2} \cdots p_m^{a_m}$. For each prime factor $p_i$, compute $E_{p_i}(n!)$ using Legendre's formula. The answer is $\min_{i} \lfloor E_{p_i}(n!) / a_i \rfloor$.
2. **Q2: What is the inverse problem: given $Z$ trailing zeros, find the smallest $n$ such that $n!$ has $Z$ trailing zeros?**
   - **A**: Since $E_5(n!)$ is monotonically non-decreasing with respect to $n$, binary search for $n$ in the range $[0, 5Z]$. Check if $E_5(n!) == Z$ (some values of $Z$ have no valid $n$, e.g. $Z = 5$).
3. **Q3: How do we find the LAST NON-ZERO digit of $n!$?**
   - **A**: Compute $n! / 10^Z \pmod{10}$. Factor out all 2s and 5s, compute the remaining product modulo 10 using recurrence and Chinese Remainder Theorem (CRT).
4. **Q4: What if we need trailing zeros in the binomial coefficient $\binom{n}{k} = \frac{n!}{k!(n-k)!}$?**
   - **A**: By Kummer's Theorem, the exponent of prime $p$ dividing $\binom{n}{k}$ is equal to the number of carries when adding $k$ and $n-k$ in base $p$. For base 10 trailing zeros, compute $\min(E_2(\binom{n}{k}), E_5(\binom{n}{k}))$, where $E_p(\binom{n}{k}) = E_p(n!) - E_p(k!) - E_p((n-k)!)$.
5. **Q5: What is the exact formula for $E_p(n!)$ in terms of digit sums?**
   - **A**: Legendre's identity states $E_p(n!) = \frac{n - S_p(n)}{p - 1}$, where $S_p(n)$ is the sum of digits of $n$ when written in base $p$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `Math`, `Number-Theory`, `Legendre-Formula`, `Prime-Factorization`, `Fast-IO`
- **Complexity Summary**:
  - **Time**: $\mathcal{O}(\log_5 n)$ (at most 13 steps)
  - **Space**: $\mathcal{O}(1)$ auxiliary space
- **Related CSES Problems**:
  - **[CSES 1617 - Bit Strings](https://cses.fi/problemset/task/1617)**: Binary exponentiation and modular arithmetic.
  - **[CSES 1713 - Counting Divisors](https://cses.fi/problemset/task/1713)**: Prime factorization and divisor counts.
  - **[CSES 1081 - Maximum GCD](https://cses.fi/problemset/task/1081)**: Multiples counting and harmonic bounds.
