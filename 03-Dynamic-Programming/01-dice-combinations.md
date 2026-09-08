# Dice Combinations

- **Category**: Dynamic Programming
- **CSES Task ID**: `1633`
- **CSES Problem Link**: [Dice Combinations](https://cses.fi/problemset/task/1633)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Your task is to count the number of ways to construct a total sum $n$ by throwing a standard 6-sided die one or more times. Each throw produces an integer outcome between $1$ and $6$. Because the order of throws matters (e.g., $1+2 \ne 2+1$), we are counting ordered compositions of $n$ with parts in $\{1, 2, 3, 4, 5, 6\}$. Print the answer modulo $10^9 + 7$.

### Input Format
- A single line containing an integer $n$.

### Output Format
- Print one integer: the number of ways modulo $10^9 + 7$.

### Numerical Constraints
- $1 \le n \le 10^6$

With $n = 10^6$, any branching tree recursion $\mathcal{O}(6^n)$ is hopelessly impossible. An optimal $\mathcal{O}(n)$ dynamic programming solution is required.

---

## 2. Intuition & Pattern Recognition

This is a classic **1D Linear Dynamic Programming** problem (generalized Fibonacci recurrence):
- Any sequence of die rolls summing to $n$ must end with some roll $d \in \{1, 2, 3, 4, 5, 6\}$ (provided $n \ge d$).
- Before rolling that final die $d$, the preceding rolls must have summed to exactly $n - d$.
- By the Sum Rule of combinatorics, the total number of ways to form $n$ is the sum of ways to form each prerequisite sum $n - d$:
  $$dp[n] = \sum_{d=1}^{\min(6, n)} dp[n - d]$$
- Base case: There is exactly $1$ way to produce a sum of $0$ (by making zero throws): $dp[0] = 1$.

---

## 3. Approach 1 — Naive / Pure Recursion

Recursively branch into all 6 possibilities from $n$ down to $0$.

### C++17 Baseline Code

```cpp
#include <iostream>

using namespace std;

const int MOD = 1e9 + 7;

long long solve_brute(int n) {
    if (n == 0) return 1;
    if (n < 0) return 0;

    long long ways = 0;
    for (int d = 1; d <= 6; ++d) {
        ways = (ways + solve_brute(n - d)) % MOD;
    }
    return ways;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (cin >> n) {
        cout << solve_brute(n) << '\n';
    }
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(6^n)$. Branching factor of 6.
- **Space Complexity**: $\mathcal{O}(n)$ recursion depth.
- **CSES Verdict**: TLE for $n \ge 25$.

---

## 4. Approach 2 — Intermediate / Memoized Recursion (Top-Down)

Store already computed states in a memoization table `memo[n]`.

### C++17 Top-Down Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int MOD = 1e9 + 7;
vector<int> memo;

int solve_memo(int rem) {
    if (rem == 0) return 1;
    if (rem < 0) return 0;
    if (memo[rem] != -1) return memo[rem];

    long long ways = 0;
    for (int d = 1; d <= 6; ++d) {
        if (rem >= d) {
            ways = (ways + solve_memo(rem - d)) % MOD;
        }
    }
    return memo[rem] = ways;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    memo.assign(n + 1, -1);
    cout << solve_memo(n) << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n)$. Each state from $1$ to $n$ is evaluated once with $6$ transitions.
- **Space Complexity**: $\mathcal{O}(n)$ for memo array and call stack.
- **Verdict**: Accepted, but recursion overhead adds unnecessary call-stack memory.

---

## 5. Approach 3 — Optimal CSES Solution (Iterative Tabulation)

We compute the states iteratively from $i = 1$ to $n$ using a flat `vector<int>` (or a 6-element rolling window for $\mathcal{O}(1)$ auxiliary memory).

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    const int MOD = 1e9 + 7;

    // dp[i] stores the number of valid dice combinations that sum to i
    vector<int> dp(n + 1, 0);

    // Base case: 1 way to form sum 0 (empty sequence of throws)
    dp[0] = 1;

    for (int i = 1; i <= n; ++i) {
        long long current_ways = 0;
        for (int d = 1; d <= 6; ++d) {
            if (i >= d) {
                current_ways += dp[i - d];
            }
        }
        dp[i] = current_ways % MOD;
    }

    cout << dp[n] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n)$. The outer loop runs $n$ times; the inner loop executes exactly $6$ iterations. Total operations $\le 6 \cdot 10^6 \approx 0.01\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ to store the DP table. (Can be reduced to $\mathcal{O}(1)$ using a rolling array of size 6).
- **Optimality Guarantee**: Since each value up to $n$ depends directly on predecessors, $\mathcal{O}(n)$ is asymptotically optimal for sequential evaluation.

---

## 6. Correctness Proof

### State & Recurrence Invariant
Let $dp[i]$ denote the exact number of ordered tuples $(d_1, d_2, \dots, d_m)$ such that $d_j \in \{1, \dots, 6\}$ and $\sum d_j = i$.
- Base case $i = 0$: The empty tuple $()$ is the unique sequence summing to $0$, so $dp[0] = 1$.
- Inductive Step: Suppose $dp[k]$ is correct for all $0 \le k < i$. Every valid sequence summing to $i$ must end with some throw $d \in \{1, \dots, 6\}$. 
  - If it ends in $d$, the prefix sequence must sum to $i - d$.
  - By the induction hypothesis, there are exactly $dp[i - d]$ such prefix sequences.
  - Since the final die roll $d$ is mutually exclusive for different values of $d \in \{1, \dots, 6\}$, the sets of sequences ending in distinct dice are disjoint.
  - Hence, the total count is strictly $\sum_{d=1}^{\min(6, i)} dp[i - d]$.
- By mathematical induction, $dp[n]$ holds the exact answer for all $n \ge 1$.

---

## 7. Dry Run & Visual State Trace

### Sample Input: $n = 3$

| $i$ | Formula: $\sum_{d=1}^6 dp[i-d]$ | Valid Transitions | Calculation | $dp[i]$ |
| :---: | :---: | :---: | :---: | :---: |
| **0** | Base Case | - | Initialized | **1** |
| **1** | $dp[0]$ | $d=1$ | $1$ | **1** |
| **2** | $dp[1] + dp[0]$ | $d=1, 2$ | $1 + 1$ | **2** |
| **3** | $dp[2] + dp[1] + dp[0]$ | $d=1, 2, 3$ | $2 + 1 + 1$ | **4** |

The 4 ways to form sum 3 are:
1. `1 + 1 + 1`
2. `1 + 2`
3. `2 + 1`
4. `3`

Output: `4`. Matches CSES example.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1$**: Sum of die rolls is simply $dp[0] = 1$.
- **$n < 6$**: Guarded by `if (i >= d)` to avoid out-of-bounds indexing.
- **Modulo Arithmetic**: Since we add up to 6 integers each bounded by $10^9+7$, `current_ways` can reach $6 \cdot 10^9$. Accumulating into `long long` avoids 32-bit signed overflow before taking `% MOD`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if $n \le 10^{18}$?**
   - The recurrence $dp[i] = \sum_{d=1}^6 dp[i-d]$ is a linear recurrence with constant coefficients. We can express transitions as a $6 \times 6$ companion matrix and compute $dp[n]$ in $\mathcal{O}(6^3 \log n)$ time using **Matrix Exponentiation**.
2. **Rolling Window $\mathcal{O}(1)$ Memory?**
   - Maintain a circular buffer `int dp[6]` where $dp[i \bmod 6] = \sum_{d=1}^6 dp[(i - d + 6) \bmod 6] \bmod \text{MOD}$. Space reduces to $\mathcal{O}(1)$.
3. **What if the die has $K$ faces ($1 \le K \le 10^6$)?**
   - Direct summation takes $\mathcal{O}(n \cdot K)$. Maintain a sliding window sum of the last $K$ terms: $dp[i] = (2 \cdot dp[i-1] - dp[i - K - 1]) \bmod \text{MOD}$, bringing total time to $\mathcal{O}(n)$!
4. **Weighted Outcomes / Biased Die?**
   - If face $d$ has probability $P_d$, expected value / probability distribution can be computed using the same transition DAG.
5. **Counting Unordered Combinations?**
   - Order does not matter $\implies$ this becomes the classic Coin Change problem (`CSES 1636: Coin Combinations II`), solved by looping coins outside and sums inside.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, linear-recurrence, combinatorics, fast-io]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n)$
  - Space: $\mathcal{O}(n)$ (or $\mathcal{O}(1)$ rolling)
- **Related CSES Problems**:
  - `CSES 1634` — [Minimizing Coins](https://cses.fi/problemset/task/1634) (Optimization DP over coin denominations).
  - `CSES 1635` — [Coin Combinations I](https://cses.fi/problemset/task/1635) (Ordered coin combinations).
  - `CSES 1636` — [Coin Combinations II](https://cses.fi/problemset/task/1636) (Unordered coin combinations).
