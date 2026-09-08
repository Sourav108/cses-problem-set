# Knight's Tour

- **Category**: Graph Algorithms
- **CSES Task ID**: `1689`
- **CSES Problem Link**: [Knight's Tour](https://cses.fi/problemset/task/1689)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

A knight is placed on an empty $8 \times 8$ chessboard at position $(x, y)$. Your task is to find a **Knight's Tour**: a sequence of 64 moves where the knight visits every square of the board **exactly once**.

A knight moves two squares horizontally and one square vertically, or two squares vertically and one square horizontally.

Print an $8 \times 8$ grid of integers, where each cell contains a number from $1$ to $64$ indicating the order in which that square was visited. If multiple valid tours exist, you may output any of them.

### Input Format
- The only input line contains two integers $x$ and $y$: the starting square (column $x$ and row $y$, $1$-indexed).

### Output Format
- Print 8 lines, each containing 8 integers: the move numbers for each square on the chessboard.

### Numerical Constraints
- $1 \le x, y \le 8$
- Board size is strictly $8 \times 8$ (64 squares)

Using Warnsdorff's Heuristic, the search finds a complete 64-step Hamiltonian path with virtually zero backtracking in $< 0.001\text{s}$.

---

## 2. Intuition & Pattern Recognition

Finding a Knight's Tour is equivalent to finding a **Hamiltonian Path** in the Knight's Graph of an $8 \times 8$ board:
- Standard backtracking has an exponential branching factor ($8^{64}$ states) and gets trapped in dead ends almost immediately.
- **Warnsdorff's Heuristic (1823)**:
  At each step, among all legal unvisited squares the knight can move to, choose the square that has the **fewest onward accessible unvisited squares** (minimum degree in the unvisited subgraph).
- **Why Warnsdorff's Heuristic Works**:
  - Corners and edge squares on a chessboard have very low degree (a corner has at most 2 moves, edge has 3 or 4, center has up to 8).
  - If low-degree squares are left unvisited until late in the tour, they will become isolated islands with 0 available entry/exit points, making completion impossible.
  - By greedily prioritizing squares with the fewest remaining exits, the knight visits the most constrained squares (corners and edges) early, leaving the highly connected central squares as flexible transit hubs for the end of the tour!
- On an $8 \times 8$ board, Warnsdorff's heuristic finds a complete tour in linear time with almost no backtracking required.

---

## 3. Approach 1 — Pure Backtracking (Naive DFS)

Try all 8 moves in arbitrary fixed order, backtracking upon hitting a dead end.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(8^{64})$ worst case.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Divide and Conquer / Parberry's Algorithm

Decompose the board into smaller $4 \times 4$ sub-boards, solve each, and splice the tours together.
- **Verdict**: Valid, but excessively complex to implement. Warnsdorff's heuristic (Approach 3) is under 50 lines of code and solves any starting position instantaneously.

---

## 5. Approach 3 — Optimal CSES Solution (Backtracking with Warnsdorff's Heuristic)

1. Maintain `board[8][8]` initialized to 0.
2. Define the 8 knight moves:
   $$dr = \{-2, -2, -1, -1, 1, 1, 2, 2\}$$
   $$dc = \{-1, 1, -2, 2, -2, 2, -1, 1\}$$
3. Helper function `count_onward_moves(r, c)`:
   Counts how many adjacent squares from $(r, c)$ are inside the board and currently unvisited (`board == 0`).
4. Recursive solver `solve(r, c, move_num)`:
   - Mark `board[r][c] = move_num`.
   - If `move_num == 64`, tour complete! Return `true`.
   - Collect all valid unvisited moves $(nr, nc)$ and compute their onward degrees.
   - **Sort the candidates in ascending order of onward degree**.
   - For each candidate in sorted order, recursively call `solve(nr, nc, move_num + 1)`.
   - If any branch returns `true`, propagate `true`.
   - If all fail, backtrack: `board[r][c] = 0`, return `false`.
5. Print the $8 \times 8$ grid.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const int N = 8;
const int dr[8] = {-2, -2, -1, -1, 1, 1, 2, 2};
const int dc[8] = {-1, 1, -2, 2, -2, 2, -1, 1};

int board[N][N];

bool is_valid(int r, int c) {
    return r >= 0 && r < N && c >= 0 && c < N && board[r][c] == 0;
}

int count_onward_moves(int r, int c) {
    int count = 0;
    for (int i = 0; i < 8; ++i) {
        int nr = r + dr[i];
        int nc = c + dc[i];
        if (is_valid(nr, nc)) {
            count++;
        }
    }
    return count;
}

struct Candidate {
    int r, c;
    int onward;

    bool operator<(const Candidate& other) const {
        return onward < other.onward;
    }
};

bool solve(int r, int c, int move_num) {
    board[r][c] = move_num;

    if (move_num == 64) {
        return true;
    }

    vector<Candidate> candidates;
    for (int i = 0; i < 8; ++i) {
        int nr = r + dr[i];
        int nc = c + dc[i];
        if (is_valid(nr, nc)) {
            candidates.push_back({nr, nc, count_onward_moves(nr, nc)});
        }
    }

    // Warnsdorff's Heuristic: sort by minimum onward degree
    sort(candidates.begin(), candidates.end());

    for (const auto& next_sq : candidates) {
        if (solve(next_sq.r, next_sq.c, move_num + 1)) {
            return true;
        }
    }

    board[r][c] = 0; // Backtrack
    return false;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int x, y;
    if (!(cin >> x >> y)) return 0;

    // CSES input specifies column x, row y (1-indexed)
    int start_r = y - 1;
    int start_c = x - 1;

    solve(start_r, start_c, 1);

    for (int r = 0; r < N; ++r) {
        for (int c = 0; c < N; ++c) {
            cout << board[r][c] << (c + 1 == N ? '\n' : ' ');
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(64)$ in practice.
  - At each step, computing onward degrees for up to 8 neighbors takes $\mathcal{O}(8 \times 8) = \mathcal{O}(1)$ operations.
  - Because Warnsdorff's heuristic avoids dead ends, total steps $\approx 64$, taking $< 0.001\text{s}$.
- **Space Complexity**: $\mathcal{O}(1)$ board of $8 \times 8$ ints and call stack of depth 64.

---

## 6. Correctness Proof

### The Most-Constrained-Variable Heuristic
- **Theoretical Basis**:
  Warnsdorff's heuristic is an instance of the **Minimum Remaining Values (MRV)** heuristic in Constraint Satisfaction Problems (CSP).
- **Dead-End Avoidance**:
  1. Let $G_t$ be the subgraph of unvisited squares at step $t$.
  2. If any unvisited square $v$ in $G_t$ has degree $0$, it is impossible to visit $v$, so the search fails.
  3. If any unvisited square $v$ has degree $1$, it must be visited immediately via its only available incident edge, or else it will become an isolated node with degree 0 upon moving elsewhere.
  4. By choosing the candidate with minimum degree at each step, Warnsdorff's rule directly prevents squares with low degrees from having their degrees drop to 0.
  5. On an $8 \times 8$ board, this heuristic succeeds in reaching step 64 without backtracking for virtually all starting squares. Combined with the backtracking fallback, correctness is guaranteed. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Start at $(x=1, y=1)$ (top-left corner $(0, 0)$):
- `board[0][0] = 1`.
- Legal moves from $(0, 0)$:
  - $(1, 2)$ has onward degree 5.
  - $(2, 1)$ has onward degree 5.
- Pick $(1, 2)$ with tie-break.
- From $(1, 2)$, legal moves include $(0, 4), (2, 4), (3, 3), (3, 1), (0, 0\text{ visited})$.
  - Move to $(0, 4)$ (edge of board, degree 3).
- Notice how the knight hugs the edges and perimeter, leaving central squares open.
- Step 64 finishes with all numbers $1 \dots 64$ present exactly once.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Input Coordinates Format**:
   CSES specifies $x$ as column and $y$ as row. Ensure `start_r = y - 1` and `start_c = x - 1`.
2. **Tie Breaking**:
   On an $8 \times 8$ board, arbitrary tie breaking is sufficient to succeed. If a tie-breaking rule ever failed, backtracking would resolve it automatically.
3. **Board Size Bounds**:
   Fixed $8 \times 8$ board. No dynamic memory allocation needed.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Does Warnsdorff's heuristic work for arbitrary $N \times N$ boards?**
   It works exceptionally well for $N \le 76$. For very large $N$ (e.g. $N = 1000$), tie-breaking with the **Pohl heuristic** (distance to center) ensures linear-time completion.
2. **What is the difference between an Open and Closed Knight's Tour?**
   An **open** tour visits all 64 squares (a Hamiltonian path). A **closed** tour (or re-entrant tour) ends at a square that can attack the starting square (a Hamiltonian cycle).
3. **Schwenk's Theorem on Closed Knight's Tours**:
   An $m \times n$ chessboard admits a closed Knight's tour if and only if:
   - $m$ and $n$ are not both odd,
   - $m, n \notin \{1, 2, 4\}$,
   - It is not $3 \times 4, 3 \times 6, 3 \times 8$.
4. **How does this connect to Constraint Satisfaction Problems (CSP)?**
   Warnsdorff's heuristic is the classic embodiment of the "Fail-First Principle" / MRV heuristic in CSP solvers.
5. **How can a Knight's Tour be represented as a SAT problem?**
   Create boolean variables $x_{u, t}$ denoting that square $u$ is visited at step $t$, with clauses enforcing exactly one square per step, exactly one step per square, and valid knight transitions.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Hamiltonian Path, Backtracking, Warnsdorff's Heuristic, Chessboard
- **Complexity Summary**:
  - Time: $\mathcal{O}(1)$ (amortized $< 0.001\text{s}$ on $8 \times 8$ board)
  - Space: $\mathcal{O}(1)$
- **Related CSES Problems**:
  - [Hamiltonian Flights](https://cses.fi/problemset/task/1690) — Exact Hamiltonian path counting via bitmask DP
  - [Grid Paths](https://cses.fi/problemset/task/1625) — Grid self-avoiding walks with pruning
  - [Monsters](https://cses.fi/problemset/task/1194) — Multi-source grid traversal
