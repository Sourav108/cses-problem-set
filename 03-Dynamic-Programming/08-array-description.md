# Array Description

- **Category**: Dynamic Programming
- **CSES Task ID**: `1746`
- **CSES Problem Link**: [Array Description](https://cses.fi/problemset/task/1746)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an array of $n$ integers where every element must be an integer between $1$ and $m$, and the absolute difference between any two adjacent elements is at most $1$:
$$|x_i - x_{i-1}| \le 1 \quad \text{for all } 2 \le i \le n$$

In the initial description, some elements are already fixed ($1 \le x_i \le m$), while unknown elements are marked as `0`. Count the total number of valid full arrays that match the description. Print the answer modulo $10^9 + 7$.

### Input Format
- The first line contains two integers $n$ and $m$.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$.

### Output Format
- Print one integer: the number of valid arrays modulo $10^9 + 7$.

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 100$
- $0 \le x_i \le m$

With $n = 10^5$ and $m = 100$, an $\mathcal{O}(n \cdot m)$ dynamic programming approach requires $10^7$ operations, which finishes in $< 0.03\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is a classic **Prefix-State Dynamic Programming** problem:
- The validity of assigning value $v \in [1, m]$ to position $i$ depends **solely on the value assigned to position $i-1$**.
- If position $i$ has value $v$, the adjacent constraint $|x_i - x_{i-1}| \le 1$ dictates that position $i-1$ must have held one of $\{v - 1, v, v + 1\}$.
- Define state:
  $$dp[i][v] = \text{number of valid prefixes } x_1 \dots x_i \text{ ending with } x_i = v$$
- Recurrence relation for $v \in [1, m]$:
  - If $x_i \ne 0$ and $x_i \ne v$, then $dp[i][v] = 0$.
  - Otherwise (if $x_i == 0$ or $x_i == v$):
    $$dp[i][v] = (dp[i-1][v-1] + dp[i-1][v] + dp[i-1][v+1]) \pmod{10^9 + 7}$$
- Boundary condition: Pad the values with $v = 0$ and $v = m + 1$ set to $0$ to prevent out-of-bounds transitions.
- **Space Optimization**: Since row $i$ depends only on row $i-1$, we can roll between two rows of size $m + 2$, reducing space from $\mathcal{O}(n \cdot m)$ to $\mathcal{O}(m)$.

---

## 3. Approach 1 — Naive / Backtracking

Recursively try every candidate value in $\{1, \dots, m\}$ for each `0`.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <cmath>

using namespace std;

const int MOD = 1e9 + 7;
int n, m;
vector<int> a;

long long solve_brute(int idx, int prev_val) {
    if (idx == n) return 1;

    long long ways = 0;
    if (a[idx] != 0) {
        if (abs(a[idx] - prev_val) <= 1) {
            ways = solve_brute(idx + 1, a[idx]);
        }
    } else {
        for (int v = 1; v <= m; ++v) {
            if (abs(v - prev_val) <= 1) {
                ways = (ways + solve_brute(idx + 1, v)) % MOD;
            }
        }
    }
    return ways;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> m)) return 0;
    a.resize(n);
    for (int i = 0; i < n; ++i) cin >> a[i];

    long long ans = 0;
    if (a[0] != 0) {
        ans = solve_brute(1, a[0]);
    } else {
        for (int v = 1; v <= m; ++v) {
            ans = (ans + solve_brute(1, v)) % MOD;
        }
    }

    cout << ans << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(3^n)$ branching.
- **Space Complexity**: $\mathcal{O}(n)$ recursion depth.
- **CSES Verdict**: TLE for $n \ge 25$.

---

## 4. Approach 2 — Intermediate / 2D DP Table

Maintain the full $n \times (m + 2)$ DP matrix.

### C++17 2D DP Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int MOD = 1e9 + 7;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<int> x(n + 1);
    for (int i = 1; i <= n; ++i) cin >> x[i];

    vector<vector<int>> dp(n + 1, vector<int>(m + 2, 0));

    // Base case: i = 1
    if (x[1] == 0) {
        for (int v = 1; v <= m; ++v) dp[1][v] = 1;
    } else {
        dp[1][x[1]] = 1;
    }

    for (int i = 2; i <= n; ++i) {
        for (int v = 1; v <= m; ++v) {
            if (x[i] != 0 && x[i] != v) continue;
            long long sum = (long long)dp[i - 1][v - 1] + dp[i - 1][v] + dp[i - 1][v + 1];
            dp[i][v] = sum % MOD;
        }
    }

    long long total = 0;
    for (int v = 1; v <= m; ++v) {
        total = (total + dp[n][v]) % MOD;
    }

    cout << total << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot m)$.
- **Space Complexity**: $\mathcal{O}(n \cdot m) = 10^5 \times 102 \times 4\text{ bytes} \approx 40\text{ MB}$.
- **Verdict**: Accepted, but uses unnecessary 2D storage.

---

## 5. Approach 3 — Optimal CSES Solution (Rolling 1D Array DP)

We keep only two rows: `prev_dp` and `curr_dp` of size $m + 2$. After each index, `prev_dp = move(curr_dp)`.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<int> x(n);
    for (int i = 0; i < n; ++i) {
        cin >> x[i];
    }

    const int MOD = 1e9 + 7;

    // dp array of size m + 2 to easily handle boundary conditions (0 and m + 1)
    vector<int> dp(m + 2, 0);

    // Initialize base case: index 0
    if (x[0] == 0) {
        for (int v = 1; v <= m; ++v) {
            dp[v] = 1;
        }
    } else {
        dp[x[0]] = 1;
    }

    // Iterate through positions 1 to n - 1
    for (int i = 1; i < n; ++i) {
        vector<int> next_dp(m + 2, 0);

        if (x[i] == 0) {
            // Position i can take any value v from 1 to m
            for (int v = 1; v <= m; ++v) {
                long long ways = (long long)dp[v - 1] + dp[v] + dp[v + 1];
                next_dp[v] = ways % MOD;
            }
        } else {
            // Position i has a fixed value x[i]
            int v = x[i];
            long long ways = (long long)dp[v - 1] + dp[v] + dp[v + 1];
            next_dp[v] = ways % MOD;
        }

        dp = move(next_dp);
    }

    // Sum all valid completions at the final index
    long long total_arrays = 0;
    for (int v = 1; v <= m; ++v) {
        total_arrays += dp[v];
    }

    cout << (total_arrays % MOD) << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot m)$. The outer loop executes $n - 1$ times; the inner loop executes at most $m$ times with $\mathcal{O}(1)$ arithmetic. Total operations $\approx 10^7$, taking $< 0.02\text{s}$.
- **Space Complexity**: $\mathcal{O}(m)$ auxiliary space. Two vectors of size $m + 2 \approx 102$ integers ($< 1\text{ KB}$), achieving near-perfect L1 cache performance.
- **Optimality Guarantee**: Any valid configuration must inspect all $n$ positions across all $m$ states, establishing an $\Omega(n \cdot m)$ lower bound.

---

## 6. Correctness Proof

### Markovian Substructure
The array condition is local: $x_i$ is constrained only by $x_{i-1}$. Therefore, conditioned on $x_{i-1} = u$, the choices for $x_i, x_{i+1}, \dots$ are independent of $x_1, \dots, x_{i-2}$.

### Invariant
At step $i$, $dp[v]$ represents the exact count of valid prefixes $x_1 \dots x_i$ conforming to the input description such that $x_i = v$.
- **Base Case ($i = 0$)**: 
  - If $x_0 = 0$, any $v \in [1, m]$ is valid $\implies dp[v] = 1$.
  - If $x_0 = c$, only $c$ is valid $\implies dp[c] = 1$ and $dp[v \ne c] = 0$.
- **Inductive Step**: Assume $dp[u]$ is correct for all $u \in [1, m]$ at step $i-1$.
  - For step $i$, any valid assignment $x_i = v$ requires $x_{i-1} \in \{v-1, v, v+1\} \cap [1, m]$.
  - Since the previous states are mutually exclusive, the total ways to arrive at state $(i, v)$ is the sum of ways from $(i-1, v-1)$, $(i-1, v)$, and $(i-1, v+1)$.
  - Padding with $dp[0] = dp[m+1] = 0$ safely handles boundary values $v = 1$ and $v = m$.
  - If $x_i \ne 0$, only $v = x_i$ is non-zero, correctly enforcing the fixed element constraint.
- Summing $dp[v]$ for $v \in [1, m]$ at step $n-1$ counts all valid completed arrays.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
3 5
2 0 2
```
$n = 3, m = 5$. Fixed values: $x_0 = 2$, $x_1 = 0$, $x_2 = 2$.

| Position $i$ | $x_i$ | $dp[1]$ | $dp[2]$ | $dp[3]$ | $dp[4]$ | $dp[5]$ | Sum of Valid Ways |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | `2` | 0 | **1** | 0 | 0 | 0 | 1 |
| **1** | `0` | $0+1+0 = \mathbf{1}$ | $1+1+0 = \mathbf{1}$ | $1+0+0 = \mathbf{1}$ | 0 | 0 | 3 |
| **2** | `2` | 0 | $dp[1]+dp[2]+dp[3] = 1+1+1 = \mathbf{3}$ | 0 | 0 | 0 | **3** |

The 3 valid arrays are:
1. `[2, 1, 2]`
2. `[2, 2, 2]`
3. `[2, 3, 2]`

**Output**: `3`. Matches CSES example.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Contradictory Input**: If fixed adjacent elements have $|x_i - x_{i-1}| > 1$ (e.g. `2 5`), $dp[x_i]$ will naturally evaluate to $0$, producing output `0`.
- **$n = 1$**: Single element: if $x_0 = 0$, outputs $m$; otherwise outputs $1$.
- **Boundary Transitions**: Elements at $v = 1$ only transition from $\{1, 2\}$, and at $v = m$ only from $\{m-1, m\}$. The zero-padded array `size = m + 2` handles this automatically.
- **Fast Modulo**: Accumulating into 64-bit `sum` prevents 32-bit overflow before taking `% MOD`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if difference condition is $|x_i - x_{i-1}| \le K$ for arbitrary $K$?**
   - Naive transitions become $\mathcal{O}(K \cdot m)$. Optimize with prefix sums over $dp[i-1]$ to compute range sums $[v-K, v+K]$ in $\mathcal{O}(1)$, keeping overall complexity $\mathcal{O}(n \cdot m)$.
2. **What if $n \le 10^9$ and only a few positions $Q \le 1000$ are fixed?**
   - Between fixed positions, the transitions form a banded Toeplitz matrix of size $m \times m$. Use **Matrix Exponentiation** over intervals of length $L$ in $\mathcal{O}(Q \cdot m^3 \log L)$ time.
3. **What if $m$ is also large ($m \le 10^9$) but number of 0s is small?**
   - Use dynamic coordinate intervals / polynomial interpolation.
4. **Circular Array ($|x_n - x_1| \le 1$)?**
   - Fix $x_1 = v_1$ for each $v_1 \in [1, m]$, run DP, and take $dp[n][v_1-1 \dots v_1+1]$. Total time: $\mathcal{O}(m \cdot (n \cdot m)) = \mathcal{O}(n \cdot m^2)$.
5. **Reconstruct a random valid array?**
   - Backtrack from $n-1$ to $0$: at step $i$, pick $x_{i-1} \in \{x_i-1, x_i, x_i+1\}$ with probability proportional to $dp[i-1][x_{i-1}]$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, array-counting, space-optimization, modular-arithmetic]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot m)$
  - Space: $\mathcal{O}(m)$
- **Related CSES Problems**:
  - `CSES 2413` — [Counting Towers](https://cses.fi/problemset/task/2413) (DP with finite transition states).
  - `CSES 1638` — [Grid Paths I](https://cses.fi/problemset/task/1638) (Grid path counting).
  - `CSES 2220` — [Counting Numbers](https://cses.fi/problemset/task/2220) (Digit DP with no adjacent identical digits).
