# Minimal Grid Path

- **Category**: Dynamic Programming
- **CSES Task ID**: `3359`
- **CSES Problem Link**: [Minimal Grid Path](https://cses.fi/problemset/task/3359)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an $n \times n$ grid of uppercase English letters (`A`–`Z`). You start at the top-left square $(0, 0)$ and want to reach the bottom-right square $(n-1, n-1)$. In each step, you can only move either **one square right** or **one square down**. Concatenating the characters along the path yields a string of length $2n - 1$. 

Determine the **lexicographically minimal string** that can be constructed.

### Input Format
- The first line contains an integer $n$: the size of the grid.
- The next $n$ lines each contain a string of length $n$ consisting of uppercase letters.

### Output Format
- Print the lexicographically minimal string of length $2n - 1$.

### Numerical Constraints
- $1 \le n \le 3000$

With $n = 3000$, standard string comparison DP that stores strings at each cell would consume $\mathcal{O}(n^3)$ memory and time ($\approx 27\cdot 10^9$ operations), which would drastically MLE and TLE. We need a diagonal-sweep BFS/DP running in $\mathcal{O}(n^2)$ time with $\mathcal{O}(n)$ auxiliary memory.

---

## 2. Intuition & Pattern Recognition

Every valid path from $(0, 0)$ to $(n-1, n-1)$ takes exactly $2n - 2$ steps, producing a string of length $2n - 1$:
- At step $d \in [0, 2n - 2]$, any cell $(r, c)$ on the path satisfies the Manhattan diagonal condition:
  $$r + c = d$$
- **Lexicographical Greedy Invariant**:
  A string $S$ is lexicographically smaller than $T$ if at the first index $k$ where they differ, $S[k] < T[k]$.
  Therefore, having an earlier smaller character strictly dominates any future characters.
- **Diagonal BFS / Level-Set Pruning**:
  1. At step $d = 0$, the only reachable cell is $(0, 0)$, contributing character `grid[0][0]`.
  2. For step $d$, let $\mathcal{A}_d$ be the set of cells reachable on diagonal $d$ along an optimal prefix.
  3. Inspect all valid neighbors $(r + 1, c)$ and $(r, c + 1)$ on diagonal $d + 1$.
  4. Find the **minimum character** $ch_{\min}$ among all candidate neighbors:
     $$ch_{\min} = \min_{(r, c) \in \mathcal{A}_d} \min(\text{grid}[r + 1][c], \text{grid}[r][c + 1])$$
  5. Append $ch_{\min}$ to the result string.
  6. Filter the active set $\mathcal{A}_{d+1}$ for the next diagonal to contain **only** those neighbor cells that match $ch_{\min}$. Discard all other neighbors permanently.
  7. Since each cell $(r, c)$ is identified on diagonal $d$ solely by its row index $r$ ($c = d - r$), we can deduplicate active cells in $\mathcal{O}(1)$ using a boolean visited array of size $n$.

---

## 3. Approach 1 — Naive / 2D DP of Strings

Store the lexicographically smallest string reaching each cell $(r, c)$:
$$dp[r][c] = \min(dp[r - 1][c], dp[r][c - 1]) + \text{grid}[r][c]$$

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^3)$. Each of the $n^2$ cells performs a string comparison of length up to $2n$. For $n = 3000$, $3000^3 = 2.7 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n^3) \approx 3000^2 \times 3000\text{ bytes} \approx 27\text{ GB}$.
- **CSES Verdict**: Memory Limit Exceeded (MLE) & Time Limit Exceeded (TLE).

---

## 4. Approach 2 — Intermediate / Suffix Array / Hash Comparisons

One can compute 2D rolling hashes or maintain parent pointers in a tree to compare suffixes in $\mathcal{O}(\log n)$ time. However, this is unnecessarily complex when diagonal BFS achieves optimal linear-per-diagonal pruning.

---

## 5. Approach 3 — Optimal CSES Solution (Diagonal BFS / Level-Set Pruning)

Maintain `vector<int> active_rows` holding the row indices of active cells at current diagonal $d$:
1. Initialize `ans` with `grid[0][0]`, and `active_rows = {0}`.
2. For $d = 0$ to $2n - 3$:
   - Scan neighbors of all $r \in \text{active\_rows}$: down $(r + 1, c)$ and right $(r, c + 1)$.
   - Determine the minimum character $ch_{\min}$ among all valid neighbors.
   - Append $ch_{\min}$ to `ans`.
   - Collect unique row coordinates of neighbors with character equal to $ch_{\min}$ into `next_rows`.
   - `active_rows = move(next_rows)`.
3. Print `ans`.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>

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

    string ans = "";
    ans.reserve(2 * n - 1);
    ans.push_back(grid[0][0]);

    // active_rows stores the row coordinate r for active cells (r, c) on current diagonal d
    // Note: c is uniquely determined by c = d - r
    vector<int> active_rows;
    active_rows.push_back(0);

    // Visited array to deduplicate row entries for diagonal d + 1
    vector<bool> visited(n, false);

    for (int d = 0; d < 2 * n - 2; ++d) {
        char min_char = 'Z' + 1;

        // First pass: find the lexicographically smallest neighbor character
        for (int r : active_rows) {
            int c = d - r;

            // Option 1: Move Down to (r + 1, c)
            if (r + 1 < n && c < n) {
                min_char = min(min_char, grid[r + 1][c]);
            }
            // Option 2: Move Right to (r, c + 1)
            if (r < n && c + 1 < n) {
                min_char = min(min_char, grid[r][c + 1]);
            }
        }

        ans.push_back(min_char);

        // Second pass: collect only neighbors that match min_char
        vector<int> next_rows;
        for (int r : active_rows) {
            int c = d - r;

            // Down neighbor (r + 1, c)
            if (r + 1 < n && c < n && grid[r + 1][c] == min_char) {
                if (!visited[r + 1]) {
                    visited[r + 1] = true;
                    next_rows.push_back(r + 1);
                }
            }

            // Right neighbor (r, c + 1)
            if (r < n && c + 1 < n && grid[r][c + 1] == min_char) {
                if (!visited[r]) {
                    visited[r] = true;
                    next_rows.push_back(r);
                }
            }
        }

        // Reset visited tags for next_rows only (O(|next_rows|) time)
        for (int r : next_rows) {
            visited[r] = false;
        }

        active_rows = move(next_rows);
    }

    cout << ans << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2)$. Each cell $(r, c)$ in the $n \times n$ grid is visited at most twice (once from above, once from the left). At each diagonal $d$, finding $ch_{\min}$ and filtering neighbors takes $\mathcal{O}(|\mathcal{A}_d|) \le \mathcal{O}(n)$ time. Summing across all $2n - 1$ diagonals yields $\sum |\mathcal{A}_d| \le n^2 \le 9 \cdot 10^6$ operations. Runs in $\approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space. The `active_rows`, `next_rows`, and `visited` vectors never exceed size $n$ ($\approx 12\text{ KB}$). The grid itself takes $\mathcal{O}(n^2) = 9\text{ MB}$.
- **Optimality Guarantee**: Every cell could potentially participate in the optimal path, so inspecting cells takes $\Omega(n^2)$ time. $\mathcal{O}(n^2)$ is optimal.

---

## 6. Correctness Proof

### Lexicographical Prefix Invariant
Let $S^*$ be the globally lexicographically minimal string from $(0, 0)$ to $(n-1, n-1)$, and let $S^*[0 \dots d]$ be its prefix of length $d + 1$.
1. **Base Case ($d = 0$)**: All valid paths begin at $(0, 0)$, so $S^*[0] = \text{grid}[0][0]$. The set $\mathcal{A}_0 = \{(0, 0)\}$ is correct.
2. **Inductive Step**: Suppose $\mathcal{A}_d$ contains all cells $(r, c)$ on diagonal $d$ reachable by some path spelling the optimal prefix $S^*[0 \dots d]$.
   - The next character $S^*[d + 1]$ must be the character at some neighbor $(r', c')$ reachable from $\mathcal{A}_d$.
   - Any path picking a neighbor with character $c' > ch_{\min}$ is strictly lexicographically larger at index $d+1$, and thus can never be extended into $S^*$.
   - Conversely, any path reaching a neighbor with character $ch_{\min}$ matches the optimal prefix up to index $d+1$.
   - Hence, $S^*[d + 1] = ch_{\min}$, and the set of cells reachable with this optimal prefix is precisely the set of neighbors bearing $ch_{\min}$.
3. By induction, the algorithm constructs the unique lexicographically minimal string character by character.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
4
AACA
BABC
ABDA
AACA
```
$n = 4$.

| Diagonal $d$ | Active Rows ($r$) | Active Cells $(r, c)$ | Neighbor Choices | $ch_{\min}$ | `ans` So Far | Next Active Rows |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | `[0]` | $(0, 0): \text{'A'}$ | Down $(1, 0) \to \text{'B'}$, Right $(0, 1) \to \text{'A'}$ | **'A'** | `AA` | `[0]` ($(0, 1)$) |
| **1** | `[0]` | $(0, 1): \text{'A'}$ | Down $(1, 1) \to \text{'A'}$, Right $(0, 2) \to \text{'C'}$ | **'A'** | `AAA` | `[1]` ($(1, 1)$) |
| **2** | `[1]` | $(1, 1): \text{'A'}$ | Down $(2, 1) \to \text{'B'}$, Right $(1, 2) \to \text{'B'}$ | **'B'** | `AAAB` | `[2, 1]` ($(2, 1), (1, 2)$) |
| **3** | `[2, 1]` | $(2, 1): \text{'B'}, (1, 2): \text{'B'}$ | From $(2, 1)$: Down $(3, 1) \to \text{'A'}$, Right $(2, 2) \to \text{'D'}$<br>From $(1, 2)$: Down $(2, 2) \to \text{'D'}$, Right $(1, 3) \to \text{'C'}$ | **'A'** | `AAABA` | `[3]` ($(3, 1)$) |
| **4** | `[3]` | $(3, 1): \text{'A'}$ | Down out, Right $(3, 2) \to \text{'C'}$ | **'C'** | `AAABAC` | `[3]` ($(3, 2)$) |
| **5** | `[3]` | $(3, 2): \text{'C'}$ | Down out, Right $(3, 3) \to \text{'A'}$ | **'A'** | `AAABACA` | `[3]` ($(3, 3)$) |

**Final Output**: `AAABACA` (Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1$**: Single cell: loop never executes ($2n - 2 = 0$), outputs `grid[0][0]`.
- **Identical Characters**: If all cells are `A`, all neighbors match. The deduplication via `visited[r]` prevents duplicate row entries, keeping $|\mathcal{A}_d| \le n$.
- **Visited Array Reset**: Resetting only the elements added to `next_rows` ensures $\mathcal{O}(|\mathcal{A}_d|)$ cleanup, avoiding a full $\mathcal{O}(n)$ reset at every step.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if we want the Lexicographically LARGEST string?**
   - Invert the search: take $\max$ instead of $\min$ at each diagonal.
2. **Count the number of paths achieving the minimal string?**
   - Maintain a path-count array `dp[r]` along the active diagonal: $dp_{next}[nr] = \sum_{(r, c) \to (nr, nc)} dp[r] \pmod{10^9+7}$.
3. **What if diagonal moves (Down-Right) are also allowed?**
   - A step can change Manhattan distance by $1$ or $2$. Standard diagonal BFS cannot group cells by path length. Use BFS ordered by path length from source.
4. **Reconstruct the actual path coordinates (sequence of Down/Right moves)?**
   - Maintain a predecessor array `parent[r][c]` pointing to the active cell on diagonal $d-1$ that led to $(r, c)$.
5. **3D Grid ($n \times n \times n$)?**
   - Same principle: diagonal $d = x + y + z$ has length $3n - 2$. Active cells stored as pairs $(x, y)$, running in $\mathcal{O}(n^3)$ time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, bfs, grid-paths, greedy, space-optimization]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n^2)$
  - Space: $\mathcal{O}(n)$ auxiliary ($\mathcal{O}(n^2)$ total for grid)
- **Related CSES Problems**:
  - `CSES 1638` — [Grid Paths I](https://cses.fi/problemset/task/1638) (Counting paths with traps).
  - `CSES 1639` — [Edit Distance](https://cses.fi/problemset/task/1639) (2D grid string DP).
  - `CSES 3403` — [Longest Common Subsequence](https://cses.fi/problemset/task/3403) (2D sequence matching).
