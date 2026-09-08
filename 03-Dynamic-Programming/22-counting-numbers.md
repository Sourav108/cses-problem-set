# Counting Numbers

- **Category**: Dynamic Programming
- **CSES Task ID**: `2220`
- **CSES Problem Link**: [Counting Numbers](https://cses.fi/problemset/task/2220)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Your task is to count the total number of integers between $a$ and $b$ inclusive ($a \le x \le b$) that have **no two adjacent digits that are the same** in their decimal representation (e.g., $123$, $101$, and $7$ are valid, whereas $112$, $1001$, and $55$ are invalid).

### Input Format
- A single line containing two integers $a$ and $b$.

### Output Format
- Print one integer: the count of valid numbers in the range $[a, b]$.

### Numerical Constraints
- $0 \le a \le b \le 10^{18}$

The range spans up to $10^{18}$, making any linear loop $\mathcal{O}(b - a)$ impossible. We need a **Digit Dynamic Programming** solution running in $\mathcal{O}(\log_{10} b)$ time ($< 0.001\text{s}$).

---

## 2. Intuition & Pattern Recognition

This is the quintessential **Digit Dynamic Programming** paradigm:
- **Prefix Decomposition**:
  Let $f(n)$ denote the number of valid integers in the range $[0, n]$.
  Then the count of valid numbers in $[a, b]$ is:
  $$\text{Count}(a, b) = \begin{cases} f(b) & \text{if } a = 0 \\ f(b) - f(a - 1) & \text{if } a > 0 \end{cases}$$
- **State Representation for $f(N)$**:
  Convert $N$ to its string of decimal digits $S = d_0 d_1 \dots d_{m-1}$ of length $m \le 19$.
  We construct valid numbers from left to right (most significant digit to least significant digit).
  Define the state as a 4-tuple:
  $$(\text{idx}, \; \text{prev\_digit}, \; \text{is\_tight}, \; \text{is\_leading\_zero})$$
  1. `idx` $\in [0, m]$: current digit index being determined.
  2. `prev_digit` $\in [0, 9]$ (or $10$ for none): the digit placed at position `idx - 1`.
  3. `is_tight` $\in \{0, 1\}$: boolean flag. If true, the digits placed so far match the prefix of $N$, meaning the current digit cannot exceed $S[\text{idx}]$. If false, the prefix is strictly less than $N$, so the current digit can range freely from $0$ to $9$.
  4. `is_leading_zero` $\in \{0, 1\}$: boolean flag indicating whether all digits placed so far were leading zeros. If true, placing another $0$ does **not** count as an adjacent duplicate zero (e.g. `$007$` is simply the number $7$).
- **State Transition**:
  For each candidate digit $d \in [0, \text{limit}]$:
  - If `!is_leading_zero && d == prev_digit`, skip (violates adjacent distinctness).
  - Otherwise, transition to:
    $$(\text{idx} + 1, \; d, \; \text{is\_tight} \land (d == \text{limit}), \; \text{is\_leading\_zero} \land (d == 0))$$
- Total states: $19 \times 11 \times 2 \times 2 \approx 836$ states, evaluated in $< 0.001\text{s}$.

---

## 3. Approach 1 — Naive / Range Iteration

Iterate from $a$ to $b$ and test each number for adjacent duplicate digits.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}((b - a) \cdot \log_{10} b)$. For $b - a = 10^{18}$, requires $10^{19}$ operations.
- **Space Complexity**: $\mathcal{O}(1)$.
- **CSES Verdict**: TLE for ranges $> 10^7$.

---

## 4. Approach 2 — Combinatorial Counting (Math by Length)

For numbers with $k$ digits (no leading zeros), the first digit has $9$ choices ($1 \dots 9$), and each subsequent digit has $9$ choices (any digit except the previous one). Thus, there are $9 \times 9^{k-1} = 9^k$ valid $k$-digit numbers. 
While pure combinatorics can count strictly smaller lengths, matching the exact prefix of an arbitrary upper bound $N$ is tedious and bug-prone. Standard Digit DP provides a cleaner, bug-free implementation.

---

## 5. Approach 3 — Optimal CSES Solution (Digit DP with Memoization)

We implement $f(N)$ using memoized DFS. We memoize the function on states where `!is_tight`, because untight states depend only on $(\text{idx}, \text{prev\_digit}, \text{is\_leading\_zero})$ and are identical across queries.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <string>
#include <vector>
#include <cstring>

using namespace std;

// memo[idx][prev_digit][is_leading_zero]
long long memo[20][11][2];

long long digit_dp(const string& s, int idx, int prev_digit, bool is_tight, bool is_leading_zero) {
    // Base case: successfully formed a valid number
    if (idx == (int)s.size()) {
        return 1;
    }

    // Return memoized result if not constrained by upper bound
    if (!is_tight && memo[idx][prev_digit][is_leading_zero] != -1) {
        return memo[idx][prev_digit][is_leading_zero];
    }

    int limit = is_tight ? (s[idx] - '0') : 9;
    long long count = 0;

    for (int d = 0; d <= limit; ++d) {
        // Cannot place the same digit as the adjacent previous digit
        // (unless we are still forming leading zeros)
        if (!is_leading_zero && d == prev_digit) {
            continue;
        }

        bool next_tight = is_tight && (d == limit);
        bool next_leading = is_leading_zero && (d == 0);
        int next_prev = next_leading ? 10 : d;

        count += digit_dp(s, idx + 1, next_prev, next_tight, next_leading);
    }

    if (!is_tight) {
        memo[idx][prev_digit][is_leading_zero] = count;
    }

    return count;
}

long long count_valid(long long n) {
    if (n < 0) return 0;
    if (n == 0) return 1; // 0 has no adjacent digits, so it is valid

    string s = to_string(n);
    memset(memo, -1, sizeof(memo));

    // Start at index 0, prev_digit = 10 (none), is_tight = true, is_leading_zero = true
    return digit_dp(s, 0, 10, true, true);
}

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    long long a, b;
    if (!(cin >> a >> b)) return 0;

    long long ans = count_valid(b) - count_valid(a - 1);
    cout << ans << '\n';

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(\log_{10} b)$. The number of decimal digits $m \le 19$. The number of unique memoized states is $19 \times 11 \times 2 = 418$. Each state iterates through at most $10$ digits. Total function calls $\le 5000$, executing in $< 0.001\text{s}$.
- **Space Complexity**: $\mathcal{O}(\log_{10} b)$ auxiliary space for the `memo` table ($20 \times 11 \times 2 \times 8\text{ bytes} \approx 3.5\text{ KB}$) and recursion stack of depth $\le 20$.
- **Optimality Guarantee**: Logarithmic with respect to input value, matching the information-theoretic lower bound for digit generation.

---

## 6. Correctness Proof

### Exhaustive Digit Prefix Construction
Every non-negative integer $\le N$ can be written with leading zeros as a string of length $m = \lfloor \log_{10} N \rfloor + 1$.
1. **Upper Bound Tightness Invariant**:
   - As long as `is_tight` is true and we choose $d = \text{limit}$, the prefix matches $N$.
   - The first time a digit $d < \text{limit}$ is chosen, all subsequent digits can be chosen arbitrarily from $[0, 9]$ because the resulting number is guaranteed to be strictly less than $N$.
   - Thus, every integer $x \in [0, N]$ is generated exactly once.
2. **Adjacent Distinctness Invariant**:
   - If `is_leading_zero` is true, the current $0$ is part of the leading padding and does not represent an actual digit in the number. Setting `next_prev = 10` ensures that the first non-zero digit is free to be any digit in $[1, 9]$.
   - Once `is_leading_zero` becomes false, the condition `d != prev_digit` strictly enforces that no two consecutive digits match.
3. **Partitioning**:
   - The leaves of the recursion tree correspond bijectively to valid integers in $[0, N]$.
   - Subtracting $f(a - 1)$ from $f(b)$ yields the exact count in $[a, b]$.

---

## 7. Dry Run & Visual State Trace

### Sample Input: $a = 123, b = 321$

1. $f(321)$:
   - 1-digit numbers ($0 \dots 9$): all 10 are valid $\implies 10$.
   - 2-digit numbers ($10 \dots 99$): $9 \times 9 = 81$.
   - 3-digit numbers starting with 1 ($100 \dots 199$): $1 \times 9 \times 9 = 81$.
   - 3-digit numbers starting with 2 ($200 \dots 299$): $1 \times 9 \times 9 = 81$.
   - 3-digit numbers starting with 3 up to 321:
     - $300 \dots 309$: first digit 3, second digit 0, third digit can be anything except 0 ($9$ choices).
     - $310 \dots 319$: first digit 3, second digit 1, third digit can be anything except 1 ($9$ choices).
     - $320 \dots 321$: $320$ (valid), $321$ (valid) $\implies 2$ choices.
     - Sum for 300..321 $= 9 + 9 + 2 = 20$.
   - Total $f(321) = 10 + 81 + 81 + 81 + 20 = 273$.
2. $f(122)$ (i.e. $a - 1$):
   - 1-digit numbers: $10$.
   - 2-digit numbers: $81$.
   - 3-digit numbers starting with 1 up to 122:
     - $100 \dots 109$: $9$ choices.
     - $110 \dots 119$: $0$ choices (adjacent 11).
     - $120 \dots 122$: $120$ (valid), $121$ (valid), $122$ (invalid: 22) $\implies 2$ choices.
     - Sum for 100..122 $= 9 + 0 + 2 = 11$.
   - Total $f(122) = 10 + 81 + 11 = 102$.
3. $\text{Count}(123, 321) = f(321) - f(122) = 273 - 102 = \mathbf{171}$.  
(Matches CSES example: `171`).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$a = 0$**: The number $0$ has 1 digit and no adjacent identical digits, so it is valid. $f(0) = 1$. The code correctly evaluates $f(b) - f(-1) = f(b) - 0$.
- **$a = b$**: Correctly computes $f(a) - f(a - 1) \in \{0, 1\}$.
- **Leading Zeros Gotcha**: Treating leading zeros as actual digits would invalidate numbers like `101` (if padded as `0101`, duplicate adjacent zeros could be falsely triggered). The `is_leading_zero` flag resolves this completely.
- **64-bit Limits**: $10^{18}$ requires `long long` for $a$, $b$, and return counts.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the base is $B$ instead of 10?**
   - Loop $d \in [0, \min(\text{limit}, B - 1)]$. Digit DP generalizes identically to any base $B \ge 2$.
2. **Find the $K$-th valid number in $[a, b]$?**
   - Binary search on the answer $X \in [a, b]$ using `count_valid(X) - count_valid(a - 1) == K` in $\mathcal{O}(\log(10^{18}) \cdot \log_{10}(10^{18}))$.
3. **No THREE adjacent digits equal?**
   - State tracks the count of consecutive identical digits: `consec_count` $\in \{1, 2\}$.
4. **Sum of all valid numbers in $[a, b]$?**
   - Return a pair `{count, sum}` from the DP, accumulating place values:
     $$\text{sum} = \sum (\text{child.sum} + \text{child.count} \times d \times 10^{\text{len} - 1 - \text{idx}})$$
5. **No adjacent identical digits in 2D grids?**
   - 2D grid digit assignment is equivalent to proper vertex coloring of the grid graph, solved via Profile DP.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, digit-dp, combinatorics, memoization]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(\log_{10} b)$
  - Space: $\mathcal{O}(\log_{10} b)$
- **Related CSES Problems**:
  - `CSES 1637` — [Removing Digits](https://cses.fi/problemset/task/1637) (Digit manipulation).
  - `CSES 2181` — [Counting Tilings](https://cses.fi/problemset/task/2181) (Profile bitmask DP).
  - `CSES 1746` — [Array Description](https://cses.fi/problemset/task/1746) (Adjacent constraint DP).
