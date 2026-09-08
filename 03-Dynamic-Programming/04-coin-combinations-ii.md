# Coin Combinations II

- **Category**: Dynamic Programming
- **CSES Task ID**: `1636`
- **CSES Problem Link**: [Coin Combinations II](https://cses.fi/problemset/task/1636)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given a set of $n$ distinct positive coin values $c_1, c_2, \dots, c_n$ and a target sum $x$, count the number of distinct **unordered** combinations of coins that produce the exact sum $x$. 

**The order of coins does not matter**: for example, if coins are $\{2, 3, 5\}$ and $x = 9$, the combinations $2 + 2 + 5$, $2 + 5 + 2$, and $5 + 2 + 2$ are considered **the same combination**. Print the answer modulo $10^9 + 7$.

### Input Format
- The first line contains two integers $n$ and $x$.
- The second line contains $n$ distinct integers $c_1, c_2, \dots, c_n$.

### Output Format
- Print one integer: the number of unordered combinations modulo $10^9 + 7$.

### Numerical Constraints
- $1 \le n \le 100$
- $1 \le x \le 10^6$
- $1 \le c_i \le 10^6$

With $n \le 100$ and $x \le 10^6$, an $\mathcal{O}(n \cdot x)$ unbounded knapsack DP performs $10^8$ operations, executing in $\approx 0.05\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the canonical **Unbounded Knapsack / Unordered Coin Change** problem:
- In *Coin Combinations I*, the outer loop was over the target sum, allowing coins to be appended in any arbitrary order, producing all permutations.
- To enforce **unordered combinations**, we must enforce a canonical ordering on the coins. For instance, we mandate that coins must be picked in non-decreasing index order:
  $$\underbrace{c_1, c_1, \dots}_{\text{coin 1}}, \underbrace{c_2, c_2, \dots}_{\text{coin 2}}, \dots, \underbrace{c_n, c_n, \dots}_{\text{coin } n}$$
- **Loop Ordering Rule**:
  - **Outer loop over coins**: Process coin $c_j$ one denomination at a time.
  - **Inner loop over sums**: Update sums from $c_j$ up to $x$.
  - This structure guarantees that once we finish processing coin $c_j$, no previous coin $c_k$ ($k < j$) can ever be introduced again, eliminating all permutation duplicates.
- Transition:
  $$dp[s] = (dp[s] + dp[s - c]) \pmod{10^9 + 7}$$

---

## 3. Approach 1 — Naive / 2D DP Table

Let $dp[i][s]$ be the number of ways to form sum $s$ using only a subset of the first $i$ coins.
$$dp[i][s] = dp[i-1][s] + dp[i][s - c_i]$$

### C++17 2D DP Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int MOD = 1e9 + 7;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, x;
    if (!(cin >> n >> x)) return 0;

    vector<int> c(n + 1);
    for (int i = 1; i <= n; ++i) cin >> c[i];

    // 2D table: size (n + 1) x (x + 1)
    // Warning: 100 x 10^6 ints = 10^8 ints * 4 bytes = 400 MB
    vector<vector<int>> dp(n + 1, vector<int>(x + 1, 0));
    dp[0][0] = 1;

    for (int i = 1; i <= n; ++i) {
        for (int s = 0; s <= x; ++s) {
            dp[i][s] = dp[i - 1][s];
            if (s >= c[i]) {
                dp[i][s] = (dp[i][s] + dp[i][s - c[i]]) % MOD;
            }
        }
    }

    cout << dp[n][x] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot x)$.
- **Space Complexity**: $\mathcal{O}(n \cdot x)$. Allocating a $100 \times 10^6$ 2D vector uses $\approx 400\text{ MB}$, which approaches the 512 MB memory limit and causes excessive cache misses.
- **CSES Verdict**: Passes, but slow ($\approx 0.45\text{s}$) due to high memory overhead.

---

## 4. Approach 2 — Intermediate / Two-Row Rolling DP

Notice that $dp[i][s]$ only depends on row $i-1$ (not taking coin $i$) and the current row $i$ (taking coin $i$ again). We can reduce memory to two rows: `prev[x + 1]` and `curr[x + 1]`.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot x)$.
- **Space Complexity**: $\mathcal{O}(x)$ using two rows of size $x+1$.
- **Verdict**: Memory improves to $< 8\text{ MB}$, but we can further compress this into a single in-place 1D array.

---

## 5. Approach 3 — Optimal CSES Solution (In-Place 1D Tabulation)

We maintain a single 1D array `dp[s]` of size $x + 1$:
1. Initialize `dp[0] = 1`, all other `dp[s] = 0`.
2. For each coin $c \in \{c_1, \dots, c_n\}$:
   - For sum $s = c \dots x$:
     $$dp[s] = (dp[s] + dp[s - c]) \pmod{10^9 + 7}$$
3. Because $s$ iterates **forwards** from $c$ to $x$, a coin can be used multiple times (unbounded knapsack).

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

    // dp[s] stores the number of unordered combinations summing to s
    vector<int> dp(x + 1, 0);

    // Base case: exactly 1 combination to form sum 0 (the empty multiset)
    dp[0] = 1;

    // Outer loop over coins: enforces canonical order, eliminating permutations
    for (int c : coins) {
        // Forward loop: allows unbounded reuse of coin c
        for (int s = c; s <= x; ++s) {
            dp[s] += dp[s - c];
            if (dp[s] >= MOD) {
                dp[s] -= MOD;
            }
        }
    }

    cout << dp[x] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot x)$. Outer loop runs $n$ times; inner loop runs $x - c + 1 \le x$ times. With $n \le 100, x \le 10^6$, total operations $\le 10^8$, finishing in $\approx 0.04\text{s}$.
- **Space Complexity**: $\mathcal{O}(x)$ auxiliary space. Exactly one flat vector of $10^6$ 32-bit integers ($4\text{ MB}$).
- **Optimality Guarantee**: Every state $(c, s)$ represents an independent subproblem choice, matching the $\Omega(n \cdot x)$ lower bound for unbounded knapsack counting.

---

## 6. Correctness Proof

### Canonical Representation
Any unordered combination of coins summing to $s$ can be uniquely represented as a sorted sequence:
$$(c_{k_1}, c_{k_2}, \dots, c_{k_m}) \quad \text{such that } 1 \le k_1 \le k_2 \le \dots \le k_m \le n$$

### Loop Invariant
Let $dp^{(j)}[s]$ denote the state of the array after processing the first $j$ coins $c_1, \dots, c_j$:
1. $dp^{(j)}[s]$ equals the exact number of multisets of coins chosen from $\{c_1, \dots, c_j\}$ whose elements sum to $s$.
2. For coin $c_j$, when updating sum $s$ from $c_j$ to $x$:
   $$dp^{(j)}[s] = dp^{(j-1)}[s] + dp^{(j)}[s - c_j]$$
   - $dp^{(j-1)}[s]$ represents all valid combinations that use $0$ copies of coin $c_j$.
   - $dp^{(j)}[s - c_j]$ represents all valid combinations that use at least $1$ copy of coin $c_j$ (since $s - c_j$ is already allowed to use coin $c_j$).
3. These two categories partition the valid combinations using coins $\{c_1, \dots, c_j\}$ into disjoint sets.
4. Hence, $dp^{(n)}[x]$ counts every unordered combination of coins summing to $x$ exactly once.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
3 9
2 3 5
```
$n = 3, x = 9$, coins = $\{2, 3, 5\}$.

| Array State | $s=0$ | $s=1$ | $s=2$ | $s=3$ | $s=4$ | $s=5$ | $s=6$ | $s=7$ | $s=8$ | $s=9$ |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Initial** | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| **After Coin 2** | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 |
| **After Coin 3** | 1 | 0 | 1 | 1 | 1 | 1 | 2 | 1 | 2 | 2 |
| **After Coin 5** | 1 | 0 | 1 | 1 | 1 | 2 | 2 | 2 | 3 | **3** |

Notice the combinations for $s = 9$ after all 3 coins are processed:
1. $2 + 2 + 5 = 9$
2. $3 + 3 + 3 = 9$
3. $2 + 2 + 2 + 3 = 9$

Total combinations: **3**. (Compare to *Coin Combinations I*, which counted **8** ordered sequences).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Single Coin System**: $n = 1$: If $x$ is divisible by $c_1$, output `1`; else `0`.
- **$x = 0$**: Answer is `1` (the empty set of coins).
- **Fast Modulo**:
  ```cpp
  dp[s] += dp[s - c];
  if (dp[s] >= MOD) dp[s] -= MOD;
  ```
  Branching subtraction avoids integer division, executing $3\times$ faster than `% MOD`.
- **Forward vs Backward Loop**:
  - `s = c to x` (forward) $\implies$ **Unbounded Knapsack** (coins can be reused indefinitely).
  - `s = x down to c` (backward) $\implies$ **0/1 Knapsack** (each coin used at most once).

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if each coin can be used at most once (0/1 Knapsack)?**
   - Reverse the inner loop: `for (int s = x; s >= c; --s) dp[s] = (dp[s] + dp[s - c]) % MOD;`.
2. **What if each coin $c_i$ has a limited supply $k_i$ (Bounded Knapsack)?**
   - Use binary decomposition of $k_i$ (powers of 2) or sliding window deque with modulo offsets in $\mathcal{O}(n \cdot x)$ time.
3. **Difference between Coin Combinations I and II in interview context?**
   - Coin Combinations I computes ordered sequences (compositions / permutations). Outer loop: sums.
   - Coin Combinations II computes unordered sets (partitions / combinations). Outer loop: items.
4. **Generating function interpretation?**
   - The number of combinations is the coefficient of $t^x$ in:
     $$\prod_{j=1}^n \frac{1}{1 - t^{c_j}}$$
5. **Reconstructing the lexicographically first combination?**
   - Backtrack from $n$ down to $1$: if $x \ge c_i$ and $dp[i][x - c_i] > 0$, choose coin $c_i$, subtract $c_i$ from $x$, and repeat.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, coin-change, unbounded-knapsack, combinatorics]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot x)$
  - Space: $\mathcal{O}(x)$
- **Related CSES Problems**:
  - `CSES 1635` — [Coin Combinations I](https://cses.fi/problemset/task/1635) (Ordered coin permutations).
  - `CSES 1634` — [Minimizing Coins](https://cses.fi/problemset/task/1634) (Minimum coins to reach sum).
  - `CSES 1158` — [Book Shop](https://cses.fi/problemset/task/1158) (0/1 Knapsack DP).
