# Coin Combinations I

- **Category**: Dynamic Programming
- **CSES Task ID**: `1635`
- **CSES Problem Link**: [Coin Combinations I](https://cses.fi/problemset/task/1635)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given a set of $n$ distinct positive coin values $c_1, c_2, \dots, c_n$ and a target sum $x$, count the total number of distinct ways to produce the sum $x$ using any number of these coins. 

**The order of coins matters**: for example, if coins are $\{2, 3, 5\}$ and $x = 9$, the sequence $2 + 2 + 5$ is considered distinct from $2 + 5 + 2$ and $5 + 2 + 2$. Print the answer modulo $10^9 + 7$.

### Input Format
- The first line contains two integers $n$ and $x$.
- The second line contains $n$ distinct positive integers $c_1, c_2, \dots, c_n$.

### Output Format
- Print one integer: the number of ordered coin combinations modulo $10^9 + 7$.

### Numerical Constraints
- $1 \le n \le 100$
- $1 \le x \le 10^6$
- $1 \le c_i \le 10^6$

With $n \le 100$ and $x \le 10^6$, an $\mathcal{O}(n \cdot x)$ dynamic programming approach requires $10^8$ iterations, running in $\approx 0.08\text{s}$.

---

## 2. Intuition & Pattern Recognition

Because **order matters**, this problem counts **ordered compositions** of $x$ using elements of $\{c_1, \dots, c_n\}$:
- Consider any valid ordered sequence of coins $(a_1, a_2, \dots, a_m)$ summing to $i$.
- The final coin $a_m$ in this sequence must be one of the available coin denominations $c \in \{c_1, \dots, c_n\}$ such that $c \le i$.
- The prefix sequence $(a_1, \dots, a_{m-1})$ must sum to exactly $i - c$.
- Since sequences ending with distinct coins $c$ are disjoint, the number of ways to form sum $i$ is the sum of ways to form $i - c$ over all eligible coins $c$:
  $$dp[i] = \sum_{c \in \{c_1, \dots, c_n\}, c \le i} dp[i - c] \pmod{10^9 + 7}$$
- **Loop Ordering Rule**:
  To count **ordered** sequences, the **outer loop must iterate over sums $i \in [1, x]$**, and the **inner loop must iterate over all coins**. This ensures that every coin can appear in any position in the sequence.

---

## 3. Approach 1 — Naive / Pure Recursion

Branch recursively across all $n$ coins for each remaining sum.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int MOD = 1e9 + 7;

long long solve_brute(const vector<int>& coins, int rem) {
    if (rem == 0) return 1;
    if (rem < 0) return 0;

    long long ways = 0;
    for (int c : coins) {
        if (rem >= c) {
            ways = (ways + solve_brute(coins, rem - c)) % MOD;
        }
    }
    return ways;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, x;
    if (!(cin >> n >> x)) return 0;

    vector<int> coins(n);
    for (int i = 0; i < n; ++i) cin >> coins[i];

    cout << solve_brute(coins, x) << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^x)$, exponential branching.
- **Space Complexity**: $\mathcal{O}(x)$ recursion stack.
- **CSES Verdict**: TLE for $x > 25$.

---

## 4. Approach 2 — Intermediate / Memoized Top-Down DP

Cache solutions to subproblems in `memo[x]`.

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int MOD = 1e9 + 7;
vector<int> memo;

int solve_memo(const vector<int>& coins, int rem) {
    if (rem == 0) return 1;
    if (rem < 0) return 0;
    if (memo[rem] != -1) return memo[rem];

    long long ways = 0;
    for (int c : coins) {
        if (rem >= c) {
            ways = (ways + solve_memo(coins, rem - c)) % MOD;
        }
    }
    return memo[rem] = ways;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, x;
    if (!(cin >> n >> x)) return 0;

    vector<int> coins(n);
    for (int i = 0; i < n; ++i) cin >> coins[i];

    memo.assign(x + 1, -1);
    cout << solve_memo(coins, x) << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot x)$.
- **Space Complexity**: $\mathcal{O}(x)$ memory + recursion call frames.
- **Verdict**: Accepted, but recursion overhead risks stack overflow for deep $x = 10^6$.

---

## 5. Approach 3 — Optimal CSES Solution (Iterative 1D Tabulation)

Iterate sequentially through sums $i = 1 \dots x$. For each sum, accumulate transitions from all coins $c \le i$.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, x;
    if (!(cin >> n >> x)) return 0;

    vector<int> coins(n);
    for (int i = 0; i < n; ++i) {
        cin >> coins[i];
    }

    const int MOD = 1e9 + 7;

    // dp[i] stores the number of ordered sequences summing to i
    vector<int> dp(x + 1, 0);

    // Base case: exactly 1 way to produce sum 0 (empty sequence)
    dp[0] = 1;

    // Outer loop: target sum i (order matters)
    for (int i = 1; i <= x; ++i) {
        for (int c : coins) {
            if (i >= c) {
                dp[i] = (dp[i] + dp[i - c]);
                if (dp[i] >= MOD) {
                    dp[i] -= MOD;
                }
            }
        }
    }

    cout << dp[x] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot x)$. The outer loop executes $x$ times; the inner loop executes $n$ times. With $n \le 100$ and $x \le 10^6$, total operations are $10^8$. Using `if (dp[i] >= MOD) dp[i] -= MOD;` avoids expensive `%` division instructions, running in $\approx 0.06\text{s}$.
- **Space Complexity**: $\mathcal{O}(x)$ auxiliary space for the flat DP table ($4\text{ MB}$).
- **Optimality Guarantee**: Every pair $(i, c)$ must be processed to account for all ordered suffixes, so $\mathcal{O}(n \cdot x)$ is optimal.

---

## 6. Correctness Proof

### Ordered Composition Bijection
Let $\mathcal{S}_i$ be the set of all ordered sequences $(a_1, \dots, a_m)$ with $a_j \in \{c_1, \dots, c_n\}$ such that $\sum a_j = i$.
- For $i = 0$, $\mathcal{S}_0 = \{ ()\} \implies |\mathcal{S}_0| = 1$.
- For $i \ge 1$, we partition $\mathcal{S}_i$ based on the last element $a_m = c$:
  $$\mathcal{S}_i = \bigcup_{c \in \{c_1, \dots, c_n\}, c \le i} \{ (a_1, \dots, a_{m-1}, c) \mid (a_1, \dots, a_{m-1}) \in \mathcal{S}_{i-c} \}$$
- Since the last coin $c$ uniquely identifies each subset, these subsets are mutually disjoint.
- Therefore:
  $$|\mathcal{S}_i| = \sum_{c \le i} |\mathcal{S}_{i-c}|$$
- By mathematical induction on $i$, $dp[i] = |\mathcal{S}_i| \pmod{10^9+7}$ for all $1 \le i \le x$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
3 9
2 3 5
```
$n = 3, x = 9$, coins = $\{2, 3, 5\}$.

| Sum $i$ | Transitions $i - c \ge 0$ | Calculation: $\sum dp[i - c]$ | $dp[i]$ |
| :---: | :---: | :---: | :---: |
| **0** | Base Case | - | **1** |
| **1** | None | 0 | **0** |
| **2** | $c=2 \implies dp[0]$ | $1$ | **1** (`[2]`) |
| **3** | $c=3 \implies dp[0]$ | $1$ | **1** (`[3]`) |
| **4** | $c=2 \implies dp[2]$ | $1$ | **1** (`[2, 2]`) |
| **5** | $c=2 \implies dp[3]$, $c=3 \implies dp[2]$, $c=5 \implies dp[0]$ | $1 + 1 + 1$ | **3** (`[3, 2]`, `[2, 3]`, `[5]`) |
| **6** | $c=2 \implies dp[4]$, $c=3 \implies dp[3]$ | $1 + 1$ | **2** (`[2, 2, 2]`, `[3, 3]`) |
| **7** | $c=2 \implies dp[5]$, $c=3 \implies dp[4]$, $c=5 \implies dp[2]$ | $3 + 1 + 1$ | **5** |
| **8** | $c=2 \implies dp[6]$, $c=3 \implies dp[5]$, $c=5 \implies dp[3]$ | $2 + 3 + 1$ | **6** |
| **9** | $c=2 \implies dp[7]$, $c=3 \implies dp[6]$, $c=5 \implies dp[4]$ | $5 + 2 + 1$ | **8** |

**Final Output**: `8` (Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Coin Greater than Target**: Handled by `if (i >= c)`.
- **Target Sum Impossible to Form**: Returns `0` naturally (e.g. only even coins and odd $x$).
- **Modulo Fast Subtraction**:
  Instead of `dp[i] = (dp[i] + dp[i - c]) % MOD;`, writing:
  ```cpp
  dp[i] += dp[i - c];
  if (dp[i] >= MOD) dp[i] -= MOD;
  ```
  yields a $2\times$ to $3\times$ speedup because hardware integer division `%` is slow.
- **Ordered vs. Unordered Gotcha**:
  - Outer loop = sums, inner loop = coins $\implies$ **Ordered** (Permutations).
  - Outer loop = coins, inner loop = sums $\implies$ **Unordered** (Combinations, as in *Coin Combinations II*).

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How to count UNORDERED combinations instead?**
   - Swap the loop order: loop coins on the outside, and sums $i$ on the inside (`CSES 1636: Coin Combinations II`).
2. **What if $x \le 10^{18}$ and coins are small ($c_i \le 20$)?**
   - The recurrence has constant coefficients. We can construct a $C_{\max} \times C_{\max}$ transition matrix and compute $dp[x]$ using **Matrix Exponentiation** in $\mathcal{O}(C_{\max}^3 \log x)$.
3. **What if each coin can be used at most $k$ times (bounded knapsack)?**
   - Use generating functions or binary decomposition of weights with prefix sum optimizations.
4. **Length-constrained compositions (exactly $K$ coins)?**
   - Expand state to $dp[k][i]$: number of ways to form sum $i$ using exactly $k$ coins: $dp[k][i] = \sum_c dp[k - 1][i - c]$.
5. **Reconstructing a random valid sequence of coins uniformly at random?**
   - Start at $x$. Choose the next transition $c$ with probability $\frac{dp[x - c]}{dp[x]}$, transition to $x - c$, and repeat until reaching $0$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, coin-change, combinatorics, modular-arithmetic]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot x)$
  - Space: $\mathcal{O}(x)$
- **Related CSES Problems**:
  - `CSES 1633` — [Dice Combinations](https://cses.fi/problemset/task/1633) (Special case with coins $\{1, 2, 3, 4, 5, 6\}$).
  - `CSES 1634` — [Minimizing Coins](https://cses.fi/problemset/task/1634) (Minimization instead of counting).
  - `CSES 1636` — [Coin Combinations II](https://cses.fi/problemset/task/1636) (Unordered combinations).
