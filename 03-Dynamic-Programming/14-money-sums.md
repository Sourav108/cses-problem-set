# Money Sums

- **Category**: Dynamic Programming
- **CSES Task ID**: `1745`
- **CSES Problem Link**: [Money Sums](https://cses.fi/problemset/task/1745)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given $n$ coins with values $x_1, x_2, \dots, x_n$. You can choose any subset of these coins (using each coin at most once). Find all distinct positive money sums that can be produced using these coins.

### Input Format
- The first line contains an integer $n$: the number of coins.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the values of the coins.

### Output Format
- First, print an integer $k$: the number of distinct positive money sums.
- After this, print all $k$ distinct sums in strictly increasing order separated by spaces.

### Numerical Constraints
- $1 \le n \le 100$
- $1 \le x_i \le 1000$

The maximum possible sum is $S_{\max} = \sum_{i=1}^n x_i \le 100 \times 1000 = 10^5$. An $\mathcal{O}(n \cdot S_{\max})$ boolean DP performs $10^7$ operations. With `std::bitset`, bit-level parallelism reduces operations by $64\times$ to $\approx 1.5 \cdot 10^5$, finishing in $< 0.002\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the **Subset Sum Reachability** problem (0/1 Knapsack without values):
- Let $dp[s]$ be a boolean flag indicating whether sum $s$ can be formed by some subset of the coins processed so far.
- Base case: $dp[0] = \text{true}$ (empty subset has sum 0).
- For a coin of value $c$, any currently reachable sum $s$ can transition to a new reachable sum $s + c$:
  $$dp_{new}[s] = dp_{old}[s] \lor dp_{old}[s - c]$$
- **Bit-Parallel Acceleration (`std::bitset`)**:
  Notice that transitioning all sums by adding $c$ is algebraically identical to a **left bit-shift by $c$ positions**:
  $$\text{dp} \gets \text{dp} \lor (\text{dp} \ll c)$$
  The C++ `std::bitset` implements this operation across 64-bit machine words in parallel, executing up to $64$ state transitions in a single CPU cycle!

---

## 3. Approach 1 — Naive / Recursive Subset Generation

Enumerate all $2^n$ subsets and insert sums into a `std::set<int>`.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <set>

using namespace std;

void solve_brute(const vector<int>& x, int idx, int cur_sum, set<int>& sums) {
    if (idx == (int)x.size()) {
        if (cur_sum > 0) sums.insert(cur_sum);
        return;
    }
    // Exclude coin idx
    solve_brute(x, idx + 1, cur_sum, sums);
    // Include coin idx
    solve_brute(x, idx + 1, cur_sum + x[idx], sums);
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> x(n);
    for (int i = 0; i < n; ++i) cin >> x[i];

    set<int> sums;
    solve_brute(x, 0, 0, sums);

    cout << sums.size() << '\n';
    for (auto it = sums.begin(); it != sums.end(); ++it) {
        cout << *it << (next(it) == sums.end() ? '\n' : ' ');
    }
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^n \log(2^n))$.
- **Space Complexity**: $\mathcal{O}(2^n)$.
- **CSES Verdict**: TLE for $n > 22$.

---

## 4. Approach 2 — Intermediate / 1D Boolean Vector DP

Maintain a boolean vector `dp` of size $S_{\max} + 1$, iterating backwards from $S_{\max}$ down to $c$ for each coin.

### C++17 Boolean Vector Code

```cpp
#include <iostream>
#include <vector>
#include <numeric>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> x(n);
    int max_sum = 0;
    for (int i = 0; i < n; ++i) {
        cin >> x[i];
        max_sum += x[i];
    }

    vector<bool> dp(max_sum + 1, false);
    dp[0] = true;

    for (int c : x) {
        for (int s = max_sum; s >= c; --s) {
            if (dp[s - c]) {
                dp[s] = true;
            }
        }
    }

    vector<int> valid_sums;
    for (int s = 1; s <= max_sum; ++s) {
        if (dp[s]) valid_sums.push_back(s);
    }

    cout << valid_sums.size() << '\n';
    for (size_t i = 0; i < valid_sums.size(); ++i) {
        cout << valid_sums[i] << (i + 1 == valid_sums.size() ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot S_{\max}) \approx 10^7$ operations ($\approx 0.05\text{s}$).
- **Space Complexity**: $\mathcal{O}(S_{\max})$ memory.
- **Verdict**: Accepted, but we can make it $50\times$ faster and simpler using `bitset`.

---

## 5. Approach 3 — Optimal CSES Solution (`std::bitset` Bit-Parallel DP)

Using `std::bitset<100001>`, each coin update is a single operation: `dp |= (dp << c)`.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <bitset>

using namespace std;

// Maximum possible sum is 100 coins * 1000 max_value = 100,000
const int MAX_SUM = 100000;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> coins(n);
    int total_possible = 0;
    for (int i = 0; i < n; ++i) {
        cin >> coins[i];
        total_possible += coins[i];
    }

    // bitset where bit s is 1 if sum s is reachable
    bitset<MAX_SUM + 1> dp;

    // Base case: sum 0 is reachable with the empty subset
    dp[0] = 1;

    // Update reachable sums for each coin in bit-parallel fashion
    for (int c : coins) {
        dp |= (dp << c);
    }

    // dp.count() counts all reachable sums including 0
    int distinct_sums = dp.count() - 1;
    cout << distinct_sums << '\n';

    // Output all reachable positive sums in increasing order
    bool first = true;
    for (int s = 1; s <= total_possible; ++s) {
        if (dp[s]) {
            if (!first) cout << ' ';
            cout << s;
            first = false;
        }
    }
    cout << '\n';

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}\left( \frac{n \cdot S_{\max}}{64} \right)$. For $n = 100$ and $S_{\max} = 10^5$, the number of 64-bit word operations is $\frac{100 \times 10^5}{64} \approx 156\,250$. This finishes in $< 0.002\text{s}$, effectively instantaneous.
- **Space Complexity**: $\mathcal{O}(S_{\max})$ bits. A bitset of size $100\,001$ bits occupies just $12.5\text{ KB}$, sitting comfortably inside the fastest L1 CPU data cache.
- **Optimality Guarantee**: Harnesses full 64-bit SIMD/word-level hardware parallelism for subset-sum reachability.

---

## 6. Correctness Proof

### Subset Sum Characteristic Vector
Let the state after $k$ coins be represented by the binary sequence $b \in \{0, 1\}^{S_{\max}+1}$ where $b[s] = 1 \iff \exists \text{ subset } S \subseteq \{x_1, \dots, x_k\} \text{ with } \sum_{x \in S} x = s$.
- **Base Case ($k = 0$)**: The empty set gives sum $0$, so $b[0] = 1$ and $b[s] = 0$ for $s > 0$.
- **Inductive Step**: When adding coin $x_{k+1} = c$:
  - Any sum $s$ reachable without $c$ remains reachable: bit $s$ is $1$ in $b$.
  - Any sum $s$ reachable with $c$ requires $s - c$ to be reachable without $c$: bit $s - c$ is $1$ in $b$.
  - The vector of sums reachable using $c$ is precisely the vector $b$ shifted left by $c$ bits: $(b \ll c)[s] = b[s - c]$.
  - The union of both sets is the bitwise OR: $b_{new} = b \lor (b \ll c)$.
- By mathematical induction, bit $s$ is set if and only if sum $s$ can be formed by some subset of $\{x_1, \dots, x_n\}$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
4
4 2 5 2
```
$n = 4$, coins = $[4, 2, 5, 2]$.
Max possible sum $= 4 + 2 + 5 + 2 = 13$.

| Step | Coin Added | Shifted Bitset (`dp << c`) | Updated Bitset (`dp | (dp << c)`) | Reachable Positive Sums |
| :---: | :---: | :---: | :---: | :---: |
| **Initial** | - | - | `{0}` | None |
| **1** | 4 | `{4}` | `{0, 4}` | 4 |
| **2** | 2 | `{2, 6}` | `{0, 2, 4, 6}` | 2, 4, 6 |
| **3** | 5 | `{5, 7, 9, 11}` | `{0, 2, 4, 5, 6, 7, 9, 11}` | 2, 4, 5, 6, 7, 9, 11 |
| **4** | 2 | `{2, 4, 6, 7, 8, 9, 11, 13}` | `{0, 2, 4, 5, 6, 7, 8, 9, 11, 13}` | 2, 4, 5, 6, 7, 8, 9, 11, 13 |

Total distinct positive sums: **9**.  
Reachable sums in order: `2 4 5 6 7 8 9 11 13`. (Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Single Coin ($n = 1$)**: Count is 1, prints $x_1$.
- **Duplicate Coin Values**: Handled naturally by bitwise OR (idempotent: $1 \lor 1 = 1$).
- **Excluding Zero**: The problem asks for positive sums; $0$ must not be counted in $k$ or printed.
- **Fixed Size Bitset**: The bitset size must be a compile-time constant $\ge 100\,001$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Reconstruct which coins form a given sum $S$?**
   - Bitset alone loses predecessor history. To reconstruct, maintain a 2D boolean array or backtrack: if $dp[i-1][S - x_i]$ is true, coin $i$ can be part of the subset.
2. **What if $x_i$ can be negative?**
   - Offset all sums by $\sum |x_i|$ to ensure all bit indices remain positive.
3. **Number of ways to form each sum?**
   - Replace bitset with integer polynomial multiplication (Convolution) using **Fast Fourier Transform (FFT / NTT)** in $\mathcal{O}(S_{\max} \log S_{\max})$.
4. **Partition array into two subsets with minimal difference?**
   - Run the bitset DP. Find the sum $s \le \lfloor S_{\max}/2 \rfloor$ closest to $S_{\max}/2$ where $dp[s] == 1$. The minimal difference is $S_{\max} - 2s$.
5. **What if $n \le 40$ and $x_i \le 10^9$?**
   - Bitset table size $10^{10}$ exceeds memory. Use **Meet-in-the-Middle**: generate all $2^{20}$ sums for both halves and merge.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, bitset, subset-sum, knapsack]`
- **Complexity Summary**:
  - Time: $\mathcal{O}\left( \frac{n \cdot S_{\max}}{64} \right)$
  - Space: $\mathcal{O}(S_{\max})$ bits
- **Related CSES Problems**:
  - `CSES 1093` — [Two Sets II](https://cses.fi/problemset/task/1093) (Count partitions with equal sum).
  - `CSES 1158` — [Book Shop](https://cses.fi/problemset/task/1158) (0/1 Knapsack optimization).
  - `CSES 1636` — [Coin Combinations II](https://cses.fi/problemset/task/1636) (Unbounded coin change).
