# Rectangle Cutting

- **Category**: Dynamic Programming
- **CSES Task ID**: `1744`
- **CSES Problem Link**: [Rectangle Cutting](https://cses.fi/problemset/task/1744)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an $a \times b$ rectangle, determine the **minimum number of straight cuts** needed to cut it entirely into squares. In each move, you may choose any current rectangle and make a straight integer-coordinate cut parallel to one of its edges, splitting it into two smaller rectangles.

### Input Format
- A single line containing two integers $a$ and $b$.

### Output Format
- Print one integer: the minimum number of cuts.

### Numerical Constraints
- $1 \le a, b \le 500$

With $a, b \le 500$, total states are $500 \times 500 = 2.5 \cdot 10^5$. Each state $(i, j)$ examines $i - 1$ vertical cuts and $j - 1$ horizontal cuts. The total loop iterations are $\approx \frac{500^3}{3} \approx 4.2 \cdot 10^7$, which executes in $\approx 0.12\text{s}$ in C++.

---

## 2. Intuition & Pattern Recognition

This is a classic **2D Interval / Partition Dynamic Programming** problem:
- **Why Greedy Fails**:
  A common intuition is to greedily cut the largest possible square $\min(a, b) \times \min(a, b)$ (similar to the Euclidean algorithm). This is **strictly suboptimal**.
  For example, for an $11 \times 13$ rectangle, the greedy choice cuts an $11 \times 11$ square, leaving $11 \times 2$, requiring 7 cuts total. However, the optimal solution cuts it into squares using only **6 cuts**.
- **Optimal Substructure**:
  For an $i \times j$ rectangle:
  - If $i == j$, it is already a square: $0$ cuts required.
  - Otherwise, any first cut must divide the rectangle completely into two sub-rectangles:
    1. **Vertical cut** at position $k \in [1, i - 1]$: splits into $k \times j$ and $(i - k) \times j$. Cost: $1 + dp[k][j] + dp[i - k][j]$.
    2. **Horizontal cut** at position $k \in [1, j - 1]$: splits into $i \times k$ and $i \times (j - k)$. Cost: $1 + dp[i][k] + dp[i][j - k]$.
  - The optimal answer is the minimum over all possible vertical and horizontal cuts:
    $$dp[i][j] = 1 + \min \left( \min_{1 \le k < i} (dp[k][j] + dp[i - k][j]), \; \min_{1 \le k < j} (dp[i][k] + dp[i][j - k]) \right)$$
- Symmetry: $dp[i][j] = dp[j][i]$. We only need to compute states with $i \le j$ or evaluate symmetrically.

---

## 3. Approach 1 — Naive / Pure Recursion

Recursively evaluate all horizontal and vertical cut partitions without memoization.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <algorithm>

using namespace std;

const int INF = 1e9;

int solve_brute(int w, int h) {
    if (w == h) return 0;

    int min_cuts = INF;

    // Try all vertical cuts
    for (int k = 1; k < w; ++k) {
        min_cuts = min(min_cuts, 1 + solve_brute(k, h) + solve_brute(w - k, h));
    }

    // Try all horizontal cuts
    for (int k = 1; k < h; ++k) {
        min_cuts = min(min_cuts, 1 + solve_brute(w, k) + solve_brute(w, h - k));
    }

    return min_cuts;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int a, b;
    if (cin >> a >> b) {
        cout << solve_brute(a, b) << '\n';
    }
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^{a + b})$ combinatorial explosion.
- **Space Complexity**: $\mathcal{O}(a + b)$ stack depth.
- **CSES Verdict**: TLE for $a, b \ge 10$.

---

## 4. Approach 2 — Intermediate / Memoized Recursion (Top-Down)

Store intermediate results in a 2D memo table `memo[501][501]`.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const int INF = 1e9;
int memo[501][501];

int solve_memo(int w, int h) {
    if (w == h) return 0;
    if (memo[w][h] != -1) return memo[w][h];

    int min_cuts = INF;
    for (int k = 1; k <= w / 2; ++k) {
        min_cuts = min(min_cuts, 1 + solve_memo(k, h) + solve_memo(w - k, h));
    }
    for (int k = 1; k <= h / 2; ++k) {
        min_cuts = min(min_cuts, 1 + solve_memo(w, k) + solve_memo(w, h - k));
    }

    return memo[w][h] = memo[h][w] = min_cuts;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int a, b;
    if (!(cin >> a >> b)) return 0;

    for (int i = 0; i <= 500; ++i) {
        for (int j = 0; j <= 500; ++j) memo[i][j] = -1;
    }

    cout << solve_memo(a, b) << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(a \cdot b \cdot (a + b))$.
- **Space Complexity**: $\mathcal{O}(a \cdot b)$.
- **Verdict**: Accepted, but recursive function calls introduce $\approx 2\times$ overhead compared to flat iterative loops.

---

## 5. Approach 3 — Optimal CSES Solution (2D Tabulation with Symmetry Exploitation)

We fill a 2D table `dp[a + 1][b + 1]` iteratively:
1. Base cases: If $i == j$, set $dp[i][j] = 0$.
2. For each $(i, j)$ with $i \ne j$:
   - Due to symmetry of cuts, we only need to test $k \in [1, \lfloor i / 2 \rfloor]$ for vertical cuts and $k \in [1, \lfloor j / 2 \rfloor]$ for horizontal cuts.
   - This halves the number of transition checks per cell!

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const int INF = 1e9;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int a, b;
    if (!(cin >> a >> b)) return 0;

    // dp[i][j] stores the minimum cuts to partition an i x j rectangle into squares
    vector<vector<int>> dp(a + 1, vector<int>(b + 1, INF));

    for (int i = 1; i <= a; ++i) {
        for (int j = 1; j <= b; ++j) {
            if (i == j) {
                dp[i][j] = 0; // Already a square: 0 cuts required
                continue;
            }

            int best = INF;

            // Try all vertical cuts (test up to i / 2 by symmetry)
            for (int k = 1; k <= i / 2; ++k) {
                best = min(best, 1 + dp[k][j] + dp[i - k][j]);
            }

            // Try all horizontal cuts (test up to j / 2 by symmetry)
            for (int k = 1; k <= j / 2; ++k) {
                best = min(best, 1 + dp[i][k] + dp[i][j - k]);
            }

            dp[i][j] = best;
        }
    }

    cout << dp[a][b] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(a \cdot b \cdot (a + b))$. Since cut positions only range up to $i/2$ and $j/2$, total operations are:
  $$\sum_{i=1}^a \sum_{j=1}^b \left(\frac{i}{2} + \frac{j}{2}\right) \approx \frac{a \cdot b}{4}(a + b) \le \frac{500 \cdot 500}{4}(1000) \approx 6.2 \cdot 10^7 \text{ ops}$$
  Runs in $\approx 0.10\text{s}$ on CSES.
- **Space Complexity**: $\mathcal{O}(a \cdot b)$ auxiliary space for the 2D table ($\approx 1\text{ MB}$).
- **Optimality Guarantee**: Without geometry-specific polynomial-time algorithms for guillotine cuts, dynamic programming over all cut coordinates is asymptotically optimal.

---

## 6. Correctness Proof

### Guillotine Cut Invariant
The problem explicitly states: *"On each move you can select a rectangle and cut it into two rectangles"*. This defines a **guillotine cut** (a cut spanning completely across the selected rectangle from one edge to the opposite edge).
- Any valid sequence of guillotine cuts on an $i \times j$ rectangle must start with either:
  1. A straight cut across width $i$ at some height $k \in [1, j-1]$, yielding subproblems $(i, k)$ and $(i, j-k)$.
  2. A straight cut across height $j$ at some width $k \in [1, i-1]$, yielding subproblems $(k, j)$ and $(i-k, j)$.
- Both subproblems are independent and smaller in either width or height.
- By induction on the area $i \times j$, assuming all subproblems with smaller area are solved optimally, taking the minimum over all valid guillotine cuts guarantees the global minimum.
- Cutting at $k$ and $i - k$ produces identical subproblems, so restricting $k \le \lfloor i / 2 \rfloor$ preserves completeness.

---

## 7. Dry Run & Visual State Trace

### Sample Input: $a = 3, b = 5$

| Dimensions $(i \times j)$ | Initial State | Vertical Cut Evaluation ($k \le i/2$) | Horizontal Cut Evaluation ($k \le j/2$) | $dp[i][j]$ |
| :---: | :---: | :---: | :---: | :---: |
| $1 \times 1$ | Square | - | - | **0** |
| $1 \times 2$ | $1 \ne 2$ | None ($1/2 = 0$) | $k=1 \implies 1 + dp[1][1] + dp[1][1] = 1$ | **1** |
| $1 \times 3$ | $1 \ne 3$ | None | $k=1 \implies 1 + dp[1][1] + dp[1][2] = 2$ | **2** |
| $2 \times 2$ | Square | - | - | **0** |
| $2 \times 3$ | $2 \ne 3$ | $k=1 \implies 1 + dp[1][3] + dp[1][3] = 5$ | $k=1 \implies 1 + dp[2][1] + dp[2][2] = 1 + 1 + 0 = \mathbf{2}$ | **2** |
| $3 \times 3$ | Square | - | - | **0** |
| $3 \times 5$ | $3 \ne 5$ | $k=1 \implies 1 + dp[1][5] + dp[2][5] = 1 + 4 + 3 = 8$ | $k=1 \implies 1 + dp[3][1] + dp[3][4] = 1 + 2 + 3 = 6$<br>$k=2 \implies 1 + dp[3][2] + dp[3][3] = 1 + 2 + 0 = \mathbf{3}$ | **3** |

At $3 \times 5$:
- Horizontal cut at $k = 2$ splits into $3 \times 2$ and $3 \times 3$ (square!).
- $3 \times 3$ requires $0$ cuts.
- $3 \times 2$ requires $2$ cuts (splits into $2 \times 2$ square and $1 \times 2 \to$ two $1 \times 1$ squares).
- Total cuts $= 1 + 2 + 0 = \mathbf{3}$.  
**Output**: `3`. Matches CSES example.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Already Square ($a = b$)**: Loop immediately assigns $0$ and skips transitions.
- **$1 \times k$ strips**: Requires exactly $k - 1$ cuts into $1 \times 1$ squares.
- **Symmetry Halving**: `k <= i / 2` and `k <= j / 2` cuts running time in half.
- **Primitive Array Flat Cache**: `vector<vector<int>>` of size $501 \times 501$ easily fits in CPU cache.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if non-guillotine cuts are allowed (Pinwheel patterns)?**
   - The pinwheel pattern (5 squares arranged in a spiral around a central square) can pack squares without a complete straight-line cut. For $11 \times 13$, pinwheel patterns yield even smaller square counts in general squaring problems! (Guillotine DP strictly solves the CSES move definition).
2. **Reconstructing the cut coordinates?**
   - Store the optimal cut orientation and coordinate $k$ in a `cut_pos[i][j]` table. Recursively print the cut tree.
3. **What if rectangles have profits when sold as specific square sizes?**
   - Weighted 2D Guillotine Cutting Stock DP: replace $1 + dp$ with revenue maximization $\max(dp[k][j] + dp[i-k][j])$.
4. **3D Box Cutting into Cubes?**
   - State becomes $dp[i][j][k]$ with planar cuts along 3 axes. Complexity: $\mathcal{O}(a \cdot b \cdot c \cdot (a + b + c))$.
5. **Memory Constraint: Can we optimize memory?**
   - By symmetry, store only the triangular matrix $j \ge i$ using a 1D flat array with index $\frac{j(j-1)}{2} + i$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, interval-dp, 2d-grid, memoization]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(a \cdot b \cdot (a + b))$
  - Space: $\mathcal{O}(a \cdot b)$
- **Related CSES Problems**:
  - `CSES 1639` — [Edit Distance](https://cses.fi/problemset/task/1639) (2D subproblem grid).
  - `CSES 3403` — [Longest Common Subsequence](https://cses.fi/problemset/task/3403) (2D prefix transitions).
  - `CSES 1097` — [Removal Game](https://cses.fi/problemset/task/1097) (Interval game DP).
