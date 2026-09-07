# Grid Coloring I (CSES Task 3311 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 3311 - Grid Coloring I](https://cses.fi/problemset/task/3311)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Given an $n \times m$ grid of characters `A`, `B`, `C`, `D`, change every character to one of `A`, `B`, `C`, `D` such that the new character differs from the old character, and no two adjacent cells share the same character. If no solution exists, print `IMPOSSIBLE`.
- **Constraints**: $1 \le n, m \le 500$.

---

## 1. Problem, Restated

Given a 2D grid of dimensions $n \times m$ where each square initially contains a character $S[r][c] \in \{\text{'A'}, \text{'B'}, \text{'C'}, \text{'D'}\}$:
Construct a new grid $G[r][c]$ over the same 4-letter alphabet such that:
1. $G[r][c] \ne S[r][c]$ for all $0 \le r < n$ and $0 \le c < m$ (every cell's character changes).
2. For all horizontally or vertically adjacent cells $u, v$: $G[u] \ne G[v]$.

If no valid grid exists, output `IMPOSSIBLE`. Otherwise, output the constructed $n \times m$ grid.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Bipartite 2-Coloring / Disjoint Alphabet Partitioning / Constructive Graph Theory.
- **Aha! Insight**:
  - The standard grid graph is **bipartite**: cells naturally partition into two independent sets based on coordinate parity:
    - **Even cells**: $(r + c) \equiv 0 \pmod 2$.
    - **Odd cells**: $(r + c) \equiv 1 \pmod 2$.
  - Any edge in a grid connects an Even cell to an Odd cell. No two cells of the same parity are ever adjacent!
  - We have an alphabet of **4** distinct symbols: $\{\text{'A'}, \text{'B'}, \text{'C'}, \text{'D'}\}$.
  - Partition the alphabet into two disjoint sets of size 2:
    - Set 1 for Even cells: $\{\text{'A'}, \text{'B'}\}$
    - Set 2 for Odd cells: $\{\text{'C'}, \text{'D'}\}$
  - Because Set 1 and Set 2 are completely disjoint, **any** choice from Set 1 for an Even cell will automatically differ from **any** choice from Set 2 for an adjacent Odd cell!
  - Can an Even cell always pick a character from $\{\text{'A'}, \text{'B'}\}$ that differs from its original character $S[r][c]$?
    - If $S[r][c] == \text{'A'}$, choose $\text{'B'}$.
    - Otherwise ($S[r][c] \in \{\text{'B'}, \text{'C'}, \text{'D'}\}$), choose $\text{'A'}$.
    - Since $|\{\text{'A'}, \text{'B'}\}| = 2$ and there is only 1 forbidden character, at least one option always differs!
  - By symmetry, for any Odd cell choosing from $\{\text{'C'}, \text{'D'}\}$:
    - If $S[r][c] == \text{'C'}$, choose $\text{'D'}$.
    - Otherwise, choose $\text{'C'}$.
  - This guarantees:
    1. Every cell changes its character.
    2. No two adjacent cells ever have the same character.
    3. The solution always exists for any grid size and any initial configuration!
- **Signal**: Four colors on a bipartite planar grid with neighbor and self-change constraints is solved instantly by splitting the 4 colors into two disjoint pairs.

---

## 3. Approach 1 — Naive / Baseline (Backtracking / 2-SAT)

Formulating this as a general constraint satisfaction problem (CSP) or backtracking depth-first search explores an exponential search tree of $3^{n \times m}$ states, leading to immediate Time Limit Exceeded (TLE) for $500 \times 500 = 250,000$ cells.

---

## 4. Approach 2 — Intermediate (Greedy Traversal with Conflict Resolution)

Traversing cells in row-major order and greedily choosing the first valid character from $\{\text{'A'}, \text{'B'}, \text{'C'}, \text{'D'}\}$ that differs from the original and left/top neighbors.
While this often works on random grids, it can encounter dead-ends on pathological inputs, requiring rollback logic.

---

## 5. Approach 3 — Optimal CSES Solution (Deterministic Bipartite Alphabet Split)

### Idea
Assign each cell independently based strictly on its coordinate parity $(r + c) \pmod 2$:
- If $(r + c) \pmod 2 == 0$:
  `G[r][c] = (S[r][c] == 'A' ? 'B' : 'A')`
- If $(r + c) \pmod 2 == 1$:
  `G[r][c] = (S[r][c] == 'C' ? 'D' : 'C')`

Print the resulting grid directly.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <string>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<string> grid(n);
    for (int i = 0; i < n; ++i) {
        cin >> grid[i];
    }

    for (int r = 0; r < n; ++r) {
        for (int c = 0; c < m; ++c) {
            if ((r + c) % 2 == 0) {
                // Even parity: choose from {'A', 'B'}
                grid[r][c] = (grid[r][c] == 'A') ? 'B' : 'A';
            } else {
                // Odd parity: choose from {'C', 'D'}
                grid[r][c] = (grid[r][c] == 'C') ? 'D' : 'C';
            }
        }
        cout << grid[r] << '\n';
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \cdot m)$. Each cell is evaluated and modified in $\mathcal{O}(1)$ time. For $n, m \le 500$, $n \cdot m \le 250,000$ operations, which finishes in $\approx 0.01$ seconds.
- **Space Complexity**: $\mathcal{O}(n \cdot m)$ to store the grid strings.

---

## 6. Correctness Proof

1. **Cell Modification Invariant**:
   - For an even cell $(r, c)$, $G[r][c] \in \{\text{'A'}, \text{'B'}\}$.
     - If $S[r][c] = \text{'A'}$, $G[r][c] = \text{'B'} \ne \text{'A'}$.
     - If $S[r][c] \ne \text{'A'}$, $G[r][c] = \text{'A'} \ne S[r][c]$.
     In all cases, $G[r][c] \ne S[r][c]$.
   - Similarly, for an odd cell $(r, c)$, $G[r][c] \in \{\text{'C'}, \text{'D'}\}$.
     - If $S[r][c] = \text{'C'}$, $G[r][c] = \text{'D'} \ne \text{'C'}$.
     - If $S[r][c] \ne \text{'C'}$, $G[r][c] = \text{'C'} \ne S[r][c]$.
     In all cases, $G[r][c] \ne S[r][c]$.
2. **Neighbor Adjacency Invariant**:
   - In any grid, two cells $(r_1, c_1)$ and $(r_2, c_2)$ are adjacent if and only if $|r_1 - r_2| + |c_1 - c_2| = 1$.
   - Thus, $(r_1 + c_1) \not\equiv (r_2 + c_2) \pmod 2$.
   - Therefore, one cell is even and the other is odd.
   - All even cells satisfy $G[\text{even}] \in \{\text{'A'}, \text{'B'}\}$.
   - All odd cells satisfy $G[\text{odd}] \in \{\text{'C'}, \text{'D'}\}$.
   - Because $\{\text{'A'}, \text{'B'}\} \cap \{\text{'C'}, \text{'D'}\} = \emptyset$, it is impossible for $G[\text{even}] = G[\text{odd}]$.
3. **Conclusion**:
   Both problem conditions are universally satisfied across all $n, m$. The answer is never `IMPOSSIBLE`. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input Grid:
```text
AAAA
BBBB
CCDD
```

Step-by-step transformation:
- Row 0 ($r = 0$):
  - $c = 0$ (Even, orig `'A'`): $\implies$ `'B'`
  - $c = 1$ (Odd, orig `'A'`): $\implies$ `'C'`
  - $c = 2$ (Even, orig `'A'`): $\implies$ `'B'`
  - $c = 3$ (Odd, orig `'A'`): $\implies$ `'C'`
  $\implies$ `BCBC`
- Row 1 ($r = 1$):
  - $c = 0$ (Odd, orig `'B'`): $\implies$ `'C'`
  - $c = 1$ (Even, orig `'B'`): $\implies$ `'A'`
  - $c = 2$ (Odd, orig `'B'`): $\implies$ `'C'`
  - $c = 3$ (Even, orig `'B'`): $\implies$ `'A'`
  $\implies$ `CACA`
- Row 2 ($r = 2$):
  - $c = 0$ (Even, orig `'C'`): $\implies$ `'A'`
  - $c = 1$ (Odd, orig `'C'`): $\implies$ `'D'`
  - $c = 2$ (Even, orig `'D'`): $\implies$ `'A'`
  - $c = 3$ (Odd, orig `'D'`): $\implies$ `'C'`
  $\implies$ `ADAC`

Final output satisfies all conditions with zero neighbor collisions and 100% cell alterations.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1, m = 1$**: Single cell. Parity $(0+0)=0$, changes `'A'` to `'B'`, etc. Handled correctly.
- **$n = 1$ or $m = 1$ (Linear Strip)**: Adjacent cells still alternate parity; correctness holds.
- **`IMPOSSIBLE` Condition**: With 4 characters on a bipartite grid, every cell has at least one valid choice. `IMPOSSIBLE` is unreachable under the problem constraints.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the alphabet had only 3 characters (`A`, `B`, `C`)?**
   - The disjoint partition into pairs is no longer possible because $3 < 2 \times 2$. This requires a more complex chromatic coloring / 2-SAT approach, and some configurations may be impossible.
2. **What if the grid allowed diagonal neighbors (8-connectivity)?**
   - 8-connected grids are not bipartite (cells form triangles). 4 colors would be divided into a $2 \times 2$ repeating modulus pattern: $(r \bmod 2, c \bmod 2)$.
3. **Can this approach be used to solve Grid Coloring II?**
   - Grid Coloring II may impose stricter balance or frequency constraints, solvable using network flow or bipartite matching.
4. **Why are Fast I/O and `'\n'` necessary here?**
   - Printing $500$ lines of length $500$ outputting $2.5 \times 10^5$ characters is fast, but flushing on each line with `std::endl` causes noticeable overhead.
5. **Is it possible to solve this in $\mathcal{O}(1)$ extra memory?**
   - Yes, by reading and streaming characters directly cell-by-cell without storing the 2D grid in memory.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Constructive Algorithms, Bipartite Graph, 2-Coloring, Grid Traversal.
- **Time Complexity**: $\mathcal{O}(n \cdot m)$ optimal time.
- **Space Complexity**: $\mathcal{O}(n \cdot m)$ or $\mathcal{O}(1)$ streaming.

### Related CSES Tasks
- [CSES 1668 - Building Teams](https://cses.fi/problemset/task/1668): Bipartite graph 2-coloring.
- [CSES 1070 - Permutations](https://cses.fi/problemset/task/1070): Parity-based constructive separation.
- [CSES 1192 - Counting Rooms](https://cses.fi/problemset/task/1192): Grid connectivity traversal.
