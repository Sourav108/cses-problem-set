# Grid Paths I

- **Category**: Dynamic Programming
- **CSES Task ID**: `1638`
- **CSES Problem Link**: [Grid Paths I](https://cses.fi/problemset/task/1638)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an $n \times n$ grid where each cell is either empty (`.`) or contains a trap (`*`). You start at the top-left cell $(1, 1)$ and wish to reach the bottom-right cell $(n, n)$. From any cell $(r, c)$, you can only move either **one step down** to $(r + 1, c)$ or **one step right** to $(r, c + 1)$. You cannot step on any cell with a trap.

Calculate the total number of distinct valid paths from $(1, 1)$ to $(n, n)$ modulo $10^9 + 7$.

### Input Format
- The first line contains an integer $n$.
- The next $n$ lines each contain a string of length $n$ consisting of `.` and `*`.

### Output Format
- Print one integer: the number of paths modulo $10^9 + 7$.

### Numerical Constraints
- $1 \le n \le 1000$

With $n = 1000$, the total cells are $n^2 = 10^6$. An $\mathcal{O}(n^2)$ dynamic programming approach processes $10^6$ states in $\approx 0.02\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the standard **2D Grid Dynamic Programming / DAG Path Counting** problem:
- Any step into cell $(r, c)$ must come from either its top neighbor $(r - 1, c)$ or its left neighbor $(r, c - 1)$.
- Therefore, if cell $(r, c)$ is not a trap:
  $$dp[r][c] = (dp[r - 1][c] + dp[r][c - 1]) \pmod{10^9 + 7}$$
- If cell $(r, c)$ contains a trap (`*`), it cannot be visited, so $dp[r][c] = 0$.
- Base case: If the starting cell $(1, 1)$ has a trap, the answer is immediately $0$. Otherwise, $dp[1][1] = 1$.
- **Space Optimization**: Because calculating row $r$ only requires the previous row $r-1$ and the current row's left cell, we can compress the 2D DP matrix into a single 1D array of size $n$, using $\mathcal{O}(n)$ auxiliary memory instead of $\mathcal{O}(n^2)$.

---

## 3. Approach 1 — Naive / Pure DFS Recursion

Explore all paths by branching down and right recursively.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <string>

using namespace std;

const int MOD = 1e9 + 7;
int n;
vector<string> grid;

int solve_brute(int r, int c) {
    if (r >= n || c >= n || grid[r][c] == '*') return 0;
    if (r == n - 1 && c == n - 1) return 1;

    return (solve_brute(r + 1, c) + solve_brute(r, c + 1)) % MOD;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n)) return 0;
    grid.resize(n);
    for (int i = 0; i < n; ++i) cin >> grid[i];

    cout << solve_brute(0, 0) << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^{2n})$, exponential number of paths.
- **Space Complexity**: $\mathcal{O}(n)$ recursion depth.
- **CSES Verdict**: TLE for $n \ge 16$.

---

## 4. Approach 2 — Intermediate / 2D Tabulation DP

Maintain a full 2D table `dp[n][n]`.

### C++17 2D DP Code

```cpp
#include <iostream>
#include <vector>
#include <string>

using namespace std;

const int MOD = 1e9 + 7;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<string> grid(n);
    for (int i = 0; i < n; ++i) {
        cin >> grid[i];
    }

    if (grid[0][0] == '*' || grid[n - 1][n - 1] == '*') {
        cout << 0 << '\n';
        return 0;
    }

    vector<vector<int>> dp(n, vector<int>(n, 0));
    dp[0][0] = 1;

    for (int r = 0; r < n; ++r) {
        for (int c = 0; c < n; ++c) {
            if (grid[r][c] == '*') {
                dp[r][c] = 0;
                continue;
            }
            if (r > 0) {
                dp[r][c] = (dp[r][c] + dp[r - 1][c]) % MOD;
            }
            if (c > 0) {
                dp[r][c] = (dp[r][c] + dp[r][c - 1]) % MOD;
            }
        }
    }

    cout << dp[n - 1][n - 1] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2)$.
- **Space Complexity**: $\mathcal{O}(n^2)$ memory ($\approx 4\text{ MB}$).
- **Verdict**: Accepted, but uses full 2D matrix storage.

---

## 5. Approach 3 — Optimal CSES Solution (1D Row-Compressed Tabulation)

We collapse the DP table into a single 1D vector `dp` of size $n$:
- Before processing cell $(r, c)$, `dp[c]` holds the value from the row above $(r - 1, c)$.
- `dp[c - 1]` holds the value from the cell to the left $(r, c - 1)$.
- Therefore, updating `dp[c] = (dp[c] + dp[c - 1]) % MOD` directly computes the new state in place!
- If `grid[r][c] == '*' `, we set `dp[c] = 0`.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <string>

using namespace std;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<string> grid(n);
    for (int i = 0; i < n; ++i) {
        cin >> grid[i];
    }

    // Edge case: start or end cell blocked by trap
    if (grid[0][0] == '*' || grid[n - 1][n - 1] == '*') {
        cout << 0 << '\n';
        return 0;
    }

    const int MOD = 1e9 + 7;

    // dp[c] represents the number of paths to current row at column c
    vector<int> dp(n, 0);
    dp[0] = 1;

    for (int r = 0; r < n; ++r) {
        for (int c = 0; c < n; ++c) {
            if (grid[r][c] == '*') {
                dp[c] = 0; // Trapped cell contributes 0 paths
            } else if (c > 0) {
                dp[c] += dp[c - 1];
                if (dp[c] >= MOD) {
                    dp[c] -= MOD;
                }
            }
        }
    }

    cout << dp[n - 1] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2)$. Each of the $n^2$ cells is visited once with $\mathcal{O}(1)$ operations. For $n = 1000$, total iterations $= 10^6 \approx 0.01\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space for the compressed 1D `dp` array ($4\text{ KB}$), plus $\mathcal{O}(n^2)$ to store the grid strings.
- **Optimality Guarantee**: Every cell must be inspected to determine if it is a trap, so $\Omega(n^2)$ is the absolute lower bound.

---

## 6. Correctness Proof

### Path Induction
Let $P(r, c)$ denote the set of all valid paths from $(0, 0)$ to $(r, c)$ using only right and down moves without traversing any trap.
1. **Base Case**: At $(0, 0)$, if `grid[0][0] == '.'`, there is exactly $1$ path (the null path of length 0). $dp[0] = 1$.
2. **Inductive Step**: Assume $P(r-1, c)$ and $P(r, c-1)$ are correctly computed.
   - Any path to $(r, c)$ must arrive either from above via $(r-1, c) \to (r, c)$ or from the left via $(r, c-1) \to (r, c)$.
   - These two arrival directions are mutually exclusive (a path cannot arrive from both above and left simultaneously at the final step).
   - If `grid[r][c] == '*' `, no path can enter $(r, c) \implies |P(r, c)| = 0$.
   - If `grid[r][c] == '.' `, $|P(r, c)| = |P(r-1, c)| + |P(r, c-1)|$.
3. In the 1D rolling array, before the inner update at column $c$, `dp[c]` holds $|P(r-1, c)|$ and `dp[c-1]` holds $|P(r, c-1)|$. Adding them maintains the exact induction.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
4
....
.*..
...*
*...
```

| Row $r$ | Grid Row | `c = 0` | `c = 1` | `c = 2` | `c = 3` | `dp` Array After Row $r$ |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Initial** | - | - | - | - | - | `[1, 0, 0, 0]` |
| **0** | `....` | 1 | $1+0=1$ | $1+0=1$ | $1+0=1$ | `[1, 1, 1, 1]` |
| **1** | `.*..` | 1 | **0** (trap) | $1+0=1$ | $1+1=2$ | `[1, 0, 1, 2]` |
| **2** | `...*` | 1 | $1+0=1$ | $1+1=2$ | **0** (trap) | `[1, 1, 2, 0]` |
| **3** | `*...` | **0** (trap) | $0+1=1$ | $1+2=3$ | $3+0=3$ | `[0, 1, 3, 3]` |

**Final Output**: `3` (Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Blocked Endpoints**: If `grid[0][0] == '*'` or `grid[n-1][n-1] == '*' `, output must be `0`.
- **$n = 1$**: Single cell: outputs `1` if `.`, else `0`.
- **Completely Trapped Row/Column**: Correctly propagates `0` to subsequent cells.
- **Fast Modulo**: Replacing `% MOD` with `if (dp[c] >= MOD) dp[c] -= MOD;` eliminates division hardware latency.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if $n \le 10^5$ and the number of traps is small ($K \le 2000$)?**
   - $n$ is too large for $\mathcal{O}(n^2)$ DP.
   - Use **Combinatorics + Inclusion-Exclusion**: total paths without traps is $\binom{2n-2}{n-1}$. Subtract paths passing through traps using $\mathcal{O}(K^2)$ DP over sorted trap coordinates.
2. **Recover the lexicographically smallest path?**
   - Traverse greedily from $(0, 0)$: move right if $dp[r][c+1] > 0$; otherwise move down.
3. **Maximum Coins collected on path?**
   - Change transition from addition to maximum: $dp[c] = \text{coins}[r][c] + \max(dp[c], dp[c-1])$.
4. **Moves allowed in 3 directions (Down, Right, Diagonal Down-Right)?**
   - Maintain a third variable `prev_diag` to store $dp[r-1][c-1]$ during the 1D sweep.
5. **Count paths of length exactly $L$ on a general DAG?**
   - Dynamic programming by topological sort order in $\mathcal{O}(V + E)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, 2d-grid, dag-paths, modular-arithmetic]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n^2)$
  - Space: $\mathcal{O}(n)$ auxiliary ($\mathcal{O}(n^2)$ total for grid)
- **Related CSES Problems**:
  - `CSES 1633` — [Dice Combinations](https://cses.fi/problemset/task/1633) (1D linear path counting).
  - `CSES 1158` — [Book Shop](https://cses.fi/problemset/task/1158) (0/1 Knapsack with 1D space compression).
  - `CSES 3359` — [Minimal Grid Path](https://cses.fi/problemset/task/3359) (Grid path optimization).
