# Two Sets II

- **Category**: Dynamic Programming
- **CSES Task ID**: `1093`
- **CSES Problem Link**: [Two Sets II](https://cses.fi/problemset/task/1093)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Your task is to count the number of ways to partition the set of integers $\{1, 2, \dots, n\}$ into two non-empty subsets that have equal sum. Print the answer modulo $10^9 + 7$.

### Input Format
- A single line containing an integer $n$.

### Output Format
- Print one integer: the number of valid partitions modulo $10^9 + 7$.

### Numerical Constraints
- $1 \le n \le 500$

The sum of all elements from $1$ to $n$ is $S = \frac{n(n+1)}{2}$. 
- If $S$ is odd, the set cannot be partitioned into two equal-sum subsets; output `0`.
- If $S$ is even, the target sum for each subset is $T = S / 2 \le \frac{500 \times 501}{4} = 62625$.
An $\mathcal{O}(n \cdot T)$ 0/1 knapsack counting DP performs $\approx 500 \times 62625 \approx 3.1 \cdot 10^7$ operations, executing in $\approx 0.04\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is a **0/1 Knapsack Subset Sum Counting** problem with an important symmetry constraint:
- Every valid partition of $\{1, \dots, n\}$ into subsets $(A, B)$ with $\sum_{a \in A} a = \sum_{b \in B} b = T$ has two identical representations: $(A, B)$ and $(B, A)$.
- If we count all subsets of $\{1, \dots, n\}$ that sum to $T$, each valid partition is counted **twice**.
- **Breaking Symmetry Elegantly**:
  To count each partition exactly once without needing modular division by 2, **we fix element $n$ to always belong to the second subset $B$**!
  - Therefore, we only need to choose a subset from the remaining elements $\{1, 2, \dots, n-1\}$ whose sum equals $T$.
  - This establishes a 1-to-1 bijection between subsets of $\{1, \dots, n-1\}$ summing to $T$ and valid partitions of $\{1, \dots, n\}$.
- DP State:
  $$dp[s] = \text{number of subsets of } \{1, \dots, n-1\} \text{ summing to } s$$
  For each $i \in [1, n-1]$, iterate $s$ backwards from $T$ down to $i$:
  $$dp[s] = (dp[s] + dp[s - i]) \pmod{10^9 + 7}$$

---

## 3. Approach 1 — Naive / Pure Recursion

Recursively decide whether to include each element in subset $A$.

### C++17 Baseline Code

```cpp
#include <iostream>

using namespace std;

const int MOD = 1e9 + 7;

long long solve_brute(int idx, int rem_sum) {
    if (rem_sum == 0) return 1;
    if (idx <= 0 || rem_sum < 0) return 0;

    return (solve_brute(idx - 1, rem_sum) + solve_brute(idx - 1, rem_sum - idx)) % MOD;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    long long total_sum = 1LL * n * (n + 1) / 2;
    if (total_sum % 2 != 0) {
        cout << 0 << '\n';
        return 0;
    }

    cout << solve_brute(n - 1, total_sum / 2) << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^n)$.
- **Space Complexity**: $\mathcal{O}(n)$ stack depth.
- **CSES Verdict**: TLE for $n > 30$.

---

## 4. Approach 2 — Intermediate / Modular Inverse Division

Compute all subsets of $\{1, \dots, n\}$ summing to $T$, then multiply by the modular inverse of 2:
$$\text{Ans} = dp[T] \times 2^{-1} = dp[T] \times \frac{\text{MOD} + 1}{2} \pmod{\text{MOD}}$$

While mathematically correct, it performs $500 \times 62625$ extra operations over the full set and requires modular inverse arithmetic. Fixing element $n$ in Approach 3 is strictly simpler and faster.

---

## 5. Approach 3 — Optimal CSES Solution (1D Knapsack over $\{1, \dots, n-1\}$)

We allocate a 1D vector `dp` of size $T + 1$ with $dp[0] = 1$. We iterate items $i$ from $1$ up to $n-1$, sweeping $s$ backwards from $T$ down to $i$.

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

    long long total_sum = 1LL * n * (n + 1) / 2;

    // If total sum is odd, it's impossible to partition into two equal subsets
    if (total_sum % 2 != 0) {
        cout << 0 << '\n';
        return 0;
    }

    int target = total_sum / 2;
    const int MOD = 1e9 + 7;

    // dp[s] stores the number of subsets of {1, 2, ..., n-1} that sum to s
    vector<int> dp(target + 1, 0);
    dp[0] = 1;

    // Fix element n to be in the other subset to avoid double-counting partitions
    for (int i = 1; i < n; ++i) {
        for (int s = target; s >= i; --s) {
            dp[s] += dp[s - i];
            if (dp[s] >= MOD) {
                dp[s] -= MOD;
            }
        }
    }

    cout << dp[target] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot T) = \mathcal{O}(n^3)$. 
  $$T = \frac{n(n+1)}{4} \implies \text{Operations} \approx \sum_{i=1}^{n-1} T \approx n \times \frac{n^2}{4} = \frac{n^3}{4}$$
  For $n = 500$, total iterations $\approx \frac{500^3}{4} \approx 3.1 \cdot 10^7$, taking only $\approx 0.04\text{s}$.
- **Space Complexity**: $\mathcal{O}(T)$ auxiliary space. An array of size $62626$ integers occupies only $\approx 250\text{ KB}$, fitting entirely into L2 cache.
- **Optimality Guarantee**: Partitioning into equal sums is equivalent to 0/1 knapsack, where $\mathcal{O}(n \cdot T)$ is the optimal pseudo-polynomial bound.

---

## 6. Correctness Proof

### Parity Condition
The sum of two equal integers $S_A + S_B = 2 S_A$ is necessarily even. If $S = \frac{n(n+1)}{2}$ is odd, no partition can exist $\implies 0$ ways.

### Symmetry Breaking Bijective Proof
Let $\mathcal{P}$ be the set of all valid unordered partitions $\{A, B\}$ of $\{1, \dots, n\}$ such that $\sum_{a \in A} a = \sum_{b \in B} b = T$.
- In every valid partition $\{A, B\}$, element $n$ belongs to either $A$ or $B$, but not both.
- Without loss of generality, designate $B$ as the subset containing $n$.
- Then $A$ must be a subset of $\{1, 2, \dots, n-1\}$ that satisfies $\sum_{a \in A} a = T$.
- Conversely, for every subset $A \subseteq \{1, 2, \dots, n-1\}$ summing to $T$, the complement $B = \{1, \dots, n\} \setminus A$ uniquely contains $n$ and has sum $S - T = T$.
- Thus, there is a strict bijection between subsets $A \subseteq \{1, \dots, n-1\}$ summing to $T$ and valid partitions $\{A, B\}$.
- Counting subsets of $\{1, \dots, n-1\}$ summing to $T$ counts each partition exactly once.

---

## 7. Dry Run & Visual State Trace

### Sample Input: $n = 7$
$S = \frac{7 \times 8}{2} = 28$ (even). Target $T = 14$.
Items available: $\{1, 2, 3, 4, 5, 6\}$ (element 7 is fixed in subset $B$).

Tracing $dp$ table updates up to target $14$:

| Item $i$ | Subsets summing to $14$ | $dp[14]$ after item $i$ |
| :---: | :---: | :---: |
| $i = 1 \dots 4$ | $\sum_{k=1}^4 k = 10 < 14$ | 0 |
| $i = 5$ | Requires prior sum $9$: $\{4, 5, \dots\}$ | $dp[9] = 1$ ($\{1, 3, 5\} \to 9$) |
| $i = 6$ | Adds subsets using $6$ ($dp[14 - 6] = dp[8]$) | $dp[14] = \mathbf{4}$ |

The 4 valid subsets of $\{1, \dots, 6\}$ that sum to 14 are:
1. $\{1, 2, 5, 6\}$ (complement $\{3, 4, 7\}$, sum = 14)
2. $\{1, 3, 4, 6\}$ (complement $\{2, 5, 7\}$, sum = 14)
3. $\{2, 3, 4, 5\}$ (complement $\{1, 6, 7\}$, sum = 14)
4. $\{3, 5, 6\}$ (complement $\{1, 2, 4, 7\}$, sum = 14)

**Output**: `4`. Matches CSES example.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Odd Total Sum**: $n \equiv 1$ or $2 \pmod 4 \implies \frac{n(n+1)}{2}$ is odd. Handled immediately by `total_sum % 2 != 0`, outputs `0`.
- **$n \equiv 0$ or $3 \pmod 4$**: Sum is even, valid partitions exist.
- **$n = 1$**: Sum is 1 (odd) $\implies 0$.
- **$n = 3$**: Sum is 6 (even), target 3. Items $\{1, 2\}$. Only $\{1, 2\}$ sums to 3 $\implies 1$ partition. Output: `1`.
- **Modulo Fast Subtraction**: Branching subtraction `if (dp[s] >= MOD) dp[s] -= MOD;` accelerates execution over `% MOD`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Partition into $K$ subsets of equal sum ($K \ge 3$)?**
   - NP-hard in the strong sense. For small $n \le 16$, use **Bitmask DP**: $dp[mask]$ stores the remainder sum of the current incomplete bucket.
2. **Minimize difference between two subsets if equal partition is impossible?**
   - Find the largest $s \le \lfloor S/2 \rfloor$ such that $dp[s] > 0$. The minimum possible difference is $S - 2s$.
3. **What if the set contains arbitrary integers $a_1, \dots, a_n$ instead of consecutive $1 \dots n$?**
   - The same 0/1 knapsack algorithm applies with items $a_i$. If $n \le 40$ and elements are large, use **Meet-in-the-Middle**.
4. **Reconstructing the lexicographically first partition?**
   - Backtrack from $T$ using a 2D boolean array to determine whether item $i$ was included.
5. **Generating Function Formulation?**
   - The number of partitions is $\frac{1}{2} [x^T] \prod_{i=1}^n (1 + x^i)$. Can be computed with NTT polynomial multiplication in $\mathcal{O}(T \log T)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, 0-1-knapsack, subset-sum, combinatorics]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n^3)$
  - Space: $\mathcal{O}(n^2)$ ($\approx 250\text{ KB}$)
- **Related CSES Problems**:
  - `CSES 1745` — [Money Sums](https://cses.fi/problemset/task/1745) (Subset sum reachability with bitset).
  - `CSES 1158` — [Book Shop](https://cses.fi/problemset/task/1158) (0/1 Knapsack optimization).
  - `CSES 1097` — [Removal Game](https://cses.fi/problemset/task/1097) (Minimax zero-sum game).
