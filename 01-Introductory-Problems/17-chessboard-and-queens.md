# Chessboard and Queens (CSES Task 1624 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1624 - Chessboard and Queens](https://cses.fi/problemset/task/1624)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Place 8 queens on an $8 \times 8$ chessboard such that no two queens attack each other. Each square is either free (`.`) or reserved (`*`). Queens can only be placed on free squares. Reserved squares do not block queens from attacking each other. Find the number of valid placements.
- **Constraints**: Grid dimension is fixed at $8 \times 8$.

---

## 1. Problem, Restated

Given an $8 \times 8$ character matrix representing a chessboard where `.` denotes a free square and `*` denotes a reserved square:
Find the total number of ways to place 8 non-attacking queens such that:
1. No two queens share the same row.
2. No two queens share the same column.
3. No two queens share the same diagonal (both major $\searrow$ and minor $\nearrow$).
4. No queen is placed on a reserved square (`*`).

**Input**: 8 lines, each consisting of 8 characters (`.` or `*`).  
**Output**: A single integer representing the count of valid queen configurations.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Classic $N$-Queens / Backtracking / Bitmask State Tracking.
- **Aha! Insight**:
  - Exactly one queen must reside on each of the 8 rows. We can place queens row-by-row ($r = 0, 1, \dots, 7$).
  - When placing a queen at row $r$ and column $c$:
    - Row conflicts are impossible since we place exactly one queen per row.
    - Column $c$ must not already contain a queen.
    - Major diagonal ($\searrow$): all squares on the same diagonal share an invariant difference $r - c$. Shifting by 7 maps $r - c \in [-7, 7]$ to the range $[0, 14]$.
    - Minor diagonal ($\nearrow$): all squares on the same anti-diagonal share an invariant sum $r + c \in [0, 14]$.
    - Cell $(r, c)$ must not equal `'*'`.
  - In a standard $8 \times 8$ board, there are only 92 total valid configurations (the famous 8-Queens solutions). With obstacles, the answer is $\le 92$.
  - Bitwise masks (`col_mask`, `diag1_mask`, `diag2_mask`) reduce conflict checks and updates to $\mathcal{O}(1)$ bit operations.
- **Signal**: Any problem asking to place non-attacking pieces on small chessboards ($N \le 14$) is a backtracking problem with diagonal invariants.

---

## 3. Approach 1 — Naive / Baseline (Permutation Enumeration via `next_permutation`)

### Idea
Since every valid solution places exactly one queen per column, any solution corresponds to a permutation $p$ of $\{0, 1, \dots, 7\}$, where $p[r]$ is the column of the queen on row $r$.
Generate all $8! = 40,320$ permutations. For each, verify obstacle constraints and diagonal conflicts.

### C++17 Code
```cpp
#include <iostream>
#include <vector>
#include <string>
#include <numeric>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    vector<string> board(8);
    for (int i = 0; i < 8; ++i) {
        cin >> board[i];
    }

    vector<int> cols(8);
    iota(cols.begin(), cols.end(), 0);

    int valid_count = 0;
    do {
        bool ok = true;
        // Check reserved squares
        for (int r = 0; r < 8; ++r) {
            if (board[r][cols[r]] == '*') {
                ok = false;
                break;
            }
        }
        if (!ok) continue;

        // Check diagonals
        for (int r1 = 0; r1 < 8 && ok; ++r1) {
            for (int r2 = r1 + 1; r2 < 8; ++r2) {
                if (abs(r1 - r2) == abs(cols[r1] - cols[r2])) {
                    ok = false;
                    break;
                }
            }
        }

        if (ok) ++valid_count;
    } while (next_permutation(cols.begin(), cols.end()));

    cout << valid_count << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(8! \cdot 8^2) \approx 40,320 \times 64 \approx 2.5 \times 10^6$ operations.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary space.
- **Bottleneck**: Explores dead-end branches fully without early pruning.

---

## 4. Approach 2 — Intermediate (Recursive Backtracking with Boolean Arrays)

Instead of generating entire configurations before validation, backtrack row-by-row and prune immediately when a column or diagonal collision occurs. Use boolean arrays `col_used[8]`, `diag1_used[15]`, `diag2_used[15]`.

This reduces explored states from $40,320$ to just a few hundred nodes.

---

## 5. Approach 3 — Optimal CSES Solution (Backtracking with Bitmasks)

### Idea
Maintain visited columns and diagonals using single integer bitmasks:
- `cols`: bit $c$ is set if column $c$ is occupied.
- `diag1`: bit $(r - c + 7)$ is set if major diagonal is occupied.
- `diag2`: bit $(r + c)$ is set if minor diagonal is occupied.
A placement is valid if and only if `board[r][c] != '*'` and none of the corresponding bits are set.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <string>

using namespace std;

int ways = 0;
vector<string> board(8);

void search(int r, int cols, int diag1, int diag2) {
    if (r == 8) {
        ++ways;
        return;
    }

    for (int c = 0; c < 8; ++c) {
        if (board[r][c] == '*') continue;

        int d1 = r - c + 7;
        int d2 = r + c;

        // Check if column or diagonals are already occupied
        if ((cols & (1 << c)) || (diag1 & (1 << d1)) || (diag2 & (1 << d2))) {
            continue;
        }

        // Place queen and recurse
        search(r + 1, cols | (1 << c), diag1 | (1 << d1), diag2 | (1 << d2));
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    for (int i = 0; i < 8; ++i) {
        if (!(cin >> board[i])) return 0;
    }

    search(0, 0, 0, 0);

    cout << ways << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: The search tree on an unobstructed $8 \times 8$ board visits only 2,057 nodes. With obstacles, the number of visited nodes is even smaller. Each step is $\mathcal{O}(1)$ bitwise operations. Runtime is $< 0.001$ seconds (essentially instantaneous).
- **Space Complexity**: $\mathcal{O}(N)$ recursion depth stack frames ($N = 8$).

---

## 6. Correctness Proof

1. **Row Exclusivity**: Queens are placed recursively row by row ($r = 0, 1, \dots, 7$). At depth 8, exactly 8 queens have been placed, one per row.
2. **Column & Diagonal Exclusivity**:
   - Column bitmask prevents two queens from sharing column $c$.
   - Major diagonal identity: all cells $(r, c)$ on a line parallel to the main diagonal satisfy $r - c = k \implies k \in [-7, 7]$. Mapping $k + 7 \in [0, 14]$ provides a unique bit index.
   - Minor diagonal identity: all cells $(r, c)$ on a line parallel to the anti-diagonal satisfy $r + c = k \implies k \in [0, 14]$.
3. **Obstacle Compliance**: Condition `board[r][c] != '*'` guarantees queens are never placed on reserved cells.
4. **Completeness**: Backtracking systematically explores all valid partial assignments. Any branch with conflicts is pruned without missing valid descendants. Therefore, every configuration reaching $r = 8$ is distinct, valid, and counted exactly once.

---

## 7. Dry Run & Visual State Trace

Consider placing queens on rows $0, 1, 2$:
- Row 0: choose $c = 0$.
  - State: `cols = 0b00000001`, `diag1 = 1 << 7`, `diag2 = 1 << 0`.
- Row 1:
  - $c = 0$ is blocked by `cols`.
  - $c = 1$ is blocked by `diag1` ($r - c + 7 = 1 - 1 + 7 = 7$).
  - $c = 2$: valid. Place queen at $(1, 2)$.
- Pruning immediately prevents invalid configurations from generating trillions of combinations.

On the CSES example input with obstacles, exactly 65 of the 92 standard solutions survive.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Board with all free cells (`.` only)**: The output is exactly 92.
- **Unsolvable obstacles**: If an entire row or column consists of `*`, the function returns 0 immediately.
- **Bitmask Size**: We need 15 bits for diagonals ($0 \le d \le 14$). A standard 32-bit `int` easily accommodates up to 32 bits without overflow.
- **1-based vs 0-based indexing**: Maintaining 0-based indexing ensures $r - c + 7 \ge 0$ never indices negative bits.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does this scale to general $N \times N$?**
   - For $N \le 16$, bitwise backtracking with `available = ~(cols | diag1 | diag2) & ((1 << N) - 1)` using low-bit extraction `c = available & -available` computes the $N$-Queens count in milliseconds.
2. **Can reserved squares block queen attacks?**
   - No, the problem specifies that reserved squares do not prevent queens from attacking each other. If obstacles *did* block sightlines, the problem transforms into a bipartite matching / rook-polynomial problem on grids.
3. **How would you print the actual board layout of any valid solution?**
   - Maintain an array `queens[8]` where `queens[r] = c`. Upon reaching $r = 8$, print the board with `Q` at $(r, \text{queens}[r])$ and `.` elsewhere.
4. **Why is bit manipulation preferred over arrays in competitive programming?**
   - Single CPU register operations avoid memory reads/writes and cache misses, executing up to $10\times$ faster.
5. **How many total configurations are possible without obstacle constraints for $N=8$?**
   - 92 solutions, consisting of 12 fundamentally unique solutions up to rotations and reflections.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Backtracking, Bit Manipulation, Recursion, Chessboard, Pruning.
- **Time Complexity**: $\mathcal{O}(N!)$ upper bound, practically $\le 2000$ operations for $N = 8$.
- **Space Complexity**: $\mathcal{O}(N)$ recursion stack depth.

### Related CSES Tasks
- [CSES 1622 - Creating Strings](https://cses.fi/problemset/task/1622): Permutation generation via exhaustive search.
- [CSES 1625 - Grid Path Description](https://cses.fi/problemset/task/1625): Advanced backtracking with aggressive geometric pruning.
- [CSES 1623 - Apple Division](https://cses.fi/problemset/task/1623): Complete search over binary subsets.
