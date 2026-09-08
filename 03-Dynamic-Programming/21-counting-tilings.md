# Counting Tilings

- **Category**: Dynamic Programming
- **CSES Task ID**: `2181`
- **CSES Problem Link**: [Counting Tilings](https://cses.fi/problemset/task/2181)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Your task is to calculate the number of distinct ways to tile an $n \times m$ grid using $1 \times 2$ and $2 \times 1$ dominoes. All dominoes must fit entirely within the grid, without overlapping or leaving any empty squares. Print the answer modulo $10^9 + 7$.

### Input Format
- A single line containing two integers $n$ and $m$.

### Output Format
- Print one integer: the number of tilings modulo $10^9 + 7$.

### Numerical Constraints
- $1 \le n \le 10$
- $1 \le m \le 1000$

Note that $n$ is very small ($n \le 10$), while $m$ is moderately large ($m \le 1000$). If $n \times m$ is odd, the grid cannot be tiled by dominoes of area 2; the answer is immediately `0`. An $\mathcal{O}(m \cdot 2^n)$ profile dynamic programming solution finishes in $< 0.05\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the standard **Broken Profile DP / Column-by-Column Profile DP with Bitmasks**:
- **Profile Definition**:
  We process the grid column by column from column $0$ to $m-1$.
  At column $c$, some cells may already be covered by horizontal dominoes that originated in column $c - 1$.
  We represent the state of column $c$ as an $n$-bit mask `current_mask` $\in [0, 2^n - 1]$:
  - Bit $r = 1$: cell $(r, c)$ is **already occupied** by a horizontal domino extending from $(r, c - 1)$.
  - Bit $r = 0$: cell $(r, c)$ is **empty** and must be filled in column $c$.
- **Transitions within Column $c$**:
  We iterate through rows $r = 0 \dots n-1$ in column $c$:
  1. If bit $r$ in `current_mask` is $1$:
     Cell $(r, c)$ is already occupied. We move to row $r + 1$ without setting any bit in `next_mask`.
  2. If bit $r$ in `current_mask` is $0$:
     - **Option A (Horizontal domino)**: Place a $1 \times 2$ horizontal domino covering $(r, c)$ and $(r, c + 1)$. This requires bit $r$ in `next_mask` to be set to $1$. Move to row $r + 1$.
     - **Option B (Vertical domino)**: Place a $2 \times 1$ vertical domino covering $(r, c)$ and $(r + 1, c)$. This is valid only if $r + 1 < n$ and bit $r + 1$ in `current_mask` is also $0$. Both cells are filled in column $c$, so `next_mask` is unaffected. Move to row $r + 2$.
- **DP Table**:
  Let $dp[c][\text{mask}]$ be the number of ways to tile the first $c$ columns such that column $c$ has occupied profile `mask`.
  - Base case: $dp[0][0] = 1$.
  - Final answer: $dp[m][0]$ (all columns up to $m-1$ fully covered, with 0 dominoes protruding past column $m-1$).
- Using a rolling array reduces auxiliary memory from $\mathcal{O}(m \cdot 2^n)$ to $\mathcal{O}(2^n)$.

---

## 3. Approach 1 — Naive / Pure Backtracking

Recursively attempt placing dominoes cell by cell without memoization.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^{n \cdot m})$.
- **Space Complexity**: $\mathcal{O}(n \cdot m)$.
- **CSES Verdict**: TLE for $n \cdot m > 20$.

---

## 4. Approach 2 — Intermediate / Matrix Exponentiation

Since transitions between column masks form a constant $2^n \times 2^n$ transition matrix $T$, we can compute $dp[m] = T^m \times dp[0]$ using Matrix Exponentiation in $\mathcal{O}((2^n)^3 \log m)$. For $n = 10$, $2^{10} = 1024$, and $1024^3 \approx 10^9$ operations, which is too slow compared to linear column DP $\mathcal{O}(m \cdot 2^n)$. Matrix exponentiation is optimal only when $m \ge 10^9$ and $n \le 8$.

---

## 5. Approach 3 — Optimal CSES Solution (Column Profile DP)

We precompute or recursively generate all valid `next_mask` transitions from `current_mask` using DFS. Then we sweep $c$ from $0$ to $m-1$, updating states modulo $10^9 + 7$.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int MOD = 1e9 + 7;
int n, m;

// Generate all valid next_masks for column c + 1 given current_mask in column c
void generate_transitions(int r, int current_mask, int next_mask, 
                          vector<int>& valid_next) {
    if (r == n) {
        valid_next.push_back(next_mask);
        return;
    }

    if (current_mask & (1 << r)) {
        // Cell (r, c) is already filled by a horizontal domino from column c - 1
        generate_transitions(r + 1, current_mask, next_mask, valid_next);
    } else {
        // Option 1: Place a horizontal domino covering (r, c) and (r, c + 1)
        generate_transitions(r + 1, current_mask, next_mask | (1 << r), valid_next);

        // Option 2: Place a vertical domino covering (r, c) and (r + 1, c)
        if (r + 1 < n && !(current_mask & (1 << (r + 1)))) {
            generate_transitions(r + 2, current_mask, next_mask, valid_next);
        }
    }
}

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> m)) return 0;

    // Odd total area can never be tiled by 1x2 dominoes
    if ((n * m) % 2 != 0) {
        cout << 0 << '\n';
        return 0;
    }

    int total_masks = 1 << n;

    // Precompute transitions from each current_mask to all valid next_masks
    vector<vector<int>> transitions(total_masks);
    for (int mask = 0; mask < total_masks; ++mask) {
        generate_transitions(0, mask, 0, transitions[mask]);
    }

    // dp[mask] = number of ways to tile up to current column with profile mask
    vector<int> dp(total_masks, 0);
    dp[0] = 1; // Base case: column 0 has 0 protruding dominoes

    for (int c = 0; c < m; ++c) {
        vector<int> next_dp(total_masks, 0);

        for (int mask = 0; mask < total_masks; ++mask) {
            if (dp[mask] == 0) continue;

            for (int next_mask : transitions[mask]) {
                next_dp[next_mask] += dp[mask];
                if (next_dp[next_mask] >= MOD) {
                    next_dp[next_mask] -= MOD;
                }
            }
        }

        dp = move(next_dp);
    }

    // dp[0] at column m represents all columns fully filled with nothing protruding
    cout << dp[0] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(m \cdot 2^n \cdot C_n)$ where $C_n \le 3^{n/2}$ is the average number of transitions per mask.
  - For $n \le 10$, $2^n \le 1024$. The maximum number of valid `next_mask` for any state is at most $F_{n+1} \le 89$.
  - Number of transitions across all masks is only $\approx 5000$.
  - Total operations over $m = 1000$ columns $\approx 1000 \times 5000 = 5 \cdot 10^6$, finishing in $\approx 0.03\text{s}$.
- **Space Complexity**: $\mathcal{O}(2^n)$ auxiliary space for the rolling DP vector and transitions table ($\approx 100\text{ KB}$).
- **Optimality Guarantee**: Profile DP matches the standard complexity for grid domino tilings.

---

## 6. Correctness Proof

### Disjoint Exhaustion of Column Choices
Consider column $c$ with input profile `current_mask`:
- Every cell $(r, c)$ must be covered by exactly one domino.
- If $(r, c)$ was covered from the left (bit $r$ in `current_mask` is 1), it cannot receive another domino.
- If $(r, c)$ is empty:
  - Placing a horizontal domino claims $(r, c)$ and forces $(r, c+1)$ to be occupied in the next column (`next_mask` bit $r$ becomes 1).
  - Placing a vertical domino claims $(r, c)$ and $(r+1, c)$, requiring that $(r+1, c)$ is also unoccupied.
- The recursive function `generate_transitions` enumerates every possible assignment of dominoes covering all empty cells in column $c$.
- Each valid tiling configuration of column $c$ maps to a unique `next_mask` configuration for column $c+1$.
- By induction on column index $c$, $dp[c][\text{mask}]$ stores the exact count of valid tilings of the subgrid $n \times c$ with protrusion `mask`.
- In column $m$, $dp[m][0]$ requires that no domino protrudes outside the $n \times m$ rectangle, guaranteeing a complete and valid tiling.

---

## 7. Dry Run & Visual State Trace

### Sample Input: $n = 4, m = 7$
$n = 4$ rows, $m = 7$ columns. Total cells $= 28$ (even). $2^4 = 16$ masks.

- **Column 0**:
  Starts with $dp[0] = 1$. Transitions from mask `0000`:
  1. 2 vertical dominoes: rows $(0, 1)$ and $(2, 3) \implies next = \text{0000}$.
  2. 1 vertical $(0, 1)$, 2 horizontal on $(2, 3) \implies next = \text{1100}$.
  3. 2 horizontal on $(0, 1)$, 1 vertical $(2, 3) \implies next = \text{0011}$.
  4. 1 vertical on $(1, 2)$, 2 horizontal on $(0, 3) \implies next = \text{1001}$.
  5. 4 horizontal dominoes on all 4 rows $\implies next = \text{1111}$.
- As columns advance, each step propagates DP values across the graph of 16 states.
- At $c = 7$, $dp[0]$ contains the total valid ways.
- **Output**: `781`. (Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Odd Area ($n \times m$ is odd)**: Handled immediately at the start by `(n * m) % 2 != 0`, prints `0`.
- **$n = 1$**: Single row: can only be tiled if $m$ is even with horizontal dominoes, yielding $1$ tiling.
- **$m = 1$**: Single column: can only be tiled if $n$ is even with vertical dominoes, yielding $1$ tiling.
- **Fast Modulo**: Branching subtraction `if (next_dp[next_mask] >= MOD) next_dp[next_mask] -= MOD;` avoids hardware division.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if $m \le 10^{18}$ and $n \le 8$?**
   - The transition matrix $T$ has size $2^n \times 2^n \le 256 \times 256$.
   - Use **Matrix Exponentiation** in $\mathcal{O}((2^n)^3 \log m) \approx 256^3 \times 60 \approx 10^9$ operations (or $\mathcal{O}(2^{2n} \log m)$ with Cayley-Hamilton).
2. **Kasteleyn's Formula (Pfaffian / Determinant Method)?**
   - For planar graphs, the exact number of domino tilings of an $n \times m$ grid has a closed-form trigonometric formula:
     $$\prod_{j=1}^{\lceil n/2 \rceil} \prod_{k=1}^{\lceil m/2 \rceil} 4 \left( \cos^2 \frac{j\pi}{n+1} + \cos^2 \frac{k\pi}{m+1} \right)$$
3. **Broken Profile DP with Cell-by-Cell Transitions?**
   - Instead of column-by-column, advance cell-by-cell $(r, c)$ maintaining a sliding profile of length $n + 1$ in $\mathcal{O}(n \cdot m \cdot 2^n)$ time.
4. **Tilings with $L$-trominoes or other polyomino shapes?**
   - Profile DP generalizer: bits in the profile encode shape footprints.
5. **Counting Tilings with Obstacles / Holes in the Grid?**
   - Profile DP seamlessly incorporates holes: if cell $(r, c)$ is a hole, it must be empty in `current_mask` and skipped without placing dominoes.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, profile-dp, bitmask-dp, combinatorics]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(m \cdot 2^n \cdot 3^{n/2})$
  - Space: $\mathcal{O}(2^n)$
- **Related CSES Problems**:
  - `CSES 2413` — [Counting Towers](https://cses.fi/problemset/task/2413) (2-column tiling state machine).
  - `CSES 1653` — [Elevator Rides](https://cses.fi/problemset/task/1653) (Bitmask DP).
  - `CSES 2220` — [Counting Numbers](https://cses.fi/problemset/task/2220) (Digit DP with constraints).
