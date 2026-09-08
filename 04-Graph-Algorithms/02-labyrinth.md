# Labyrinth

- **Category**: Graph Algorithms
- **CSES Task ID**: `1193`
- **CSES Problem Link**: [Labyrinth](https://cses.fi/problemset/task/1193)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a labyrinth represented as an $n \times m$ grid. The squares are walls (`#`), floors (`.`), a start square (`A`), and an end square (`B`). You can move between floor squares that are 4-directionally adjacent (Up `'U'`, Down `'D'`, Left `'L'`, Right `'R'`). 

Determine whether there is a path from `A` to `B`. If a path exists:
1. Print `YES`.
2. Print the length of the **shortest path**.
3. Print the sequence of moves as a string of characters (`U`, `D`, `L`, `R`).

If no path exists, print `NO`.

### Input Format
- The first line contains two integers $n$ and $m$: the height and width of the map.
- The next $n$ lines each contain a string of length $m$ describing the labyrinth.

### Output Format
- If a path exists:
  - Print `YES`
  - Print the length of the shortest path
  - Print the path string
- If no path exists, print `NO`.

### Numerical Constraints
- $1 \le n, m \le 1000$

With $V = n \cdot m \le 10^6$ vertices and $E \le 4 \cdot 10^6$ edges, an unweighted shortest path search via Breadth-First Search (BFS) runs in $\mathcal{O}(n \cdot m)$ time ($\approx 0.05\text{s}$).

---

## 2. Intuition & Pattern Recognition

This is the canonical **Single-Source Shortest Path on an Unweighted Grid Graph**:
- **Why BFS**:
  In an unweighted graph where every transition has cost $1$, BFS guarantees that vertices are visited in non-decreasing order of their distance from the source `A`. The first time cell `B` is dequeued or discovered, the path found is guaranteed to be of **minimal length**.
- **Path Reconstruction**:
  To reconstruct the sequence of moves without storing large path strings in each state:
  - We store the direction taken to enter each cell in a 2D array `parent_dir[r][c]`:
    - Moving to $(r-1, c)$ records `'U'`.
    - Moving to $(r+1, c)$ records `'D'`.
    - Moving to $(r, c-1)$ records `'L'`.
    - Moving to $(r, c+1)$ records `'R'`.
  - When `B` is reached, we backtrack from `B` back to `A` by reversing each step using `parent_dir`.
  - Finally, reverse the collected path string to obtain the forward directions from `A` to `B`.

---

## 3. Approach 1 — Naive / DFS (Fails Shortest Path)

Using Depth-First Search to explore paths.

### Complexity Analysis
- **Failure**: DFS does **not** find the shortest path in unweighted graphs. It can take a long, winding path and may even encounter stack overflow on a $1000 \times 1000$ grid.
- **CSES Verdict**: Wrong Answer (WA) & TLE.

---

## 4. Approach 2 — Intermediate / Dijkstra's Algorithm

Model the grid as a weighted graph with all weights equal to 1, using `std::priority_queue`.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(V \log V) = \mathcal{O}(n \cdot m \log(n \cdot m))$.
- **Space Complexity**: $\mathcal{O}(n \cdot m)$.
- **Verdict**: Accepted, but $\log(nm)$ overhead is redundant when queue-based BFS achieves $\mathcal{O}(V + E) = \mathcal{O}(n \cdot m)$ time.

---

## 5. Approach 3 — Optimal CSES Solution (Breadth-First Search with Backtracking)

1. Locate start coordinates $(sr, sc)$ of `A` and destination $(er, ec)$ of `B`.
2. Initialize a queue of `pair<int, int>` with $(sr, sc)$.
3. Maintain `parent_dir[r][c]` initialized to `0`. Mark $(sr, sc)$ as visited.
4. Run BFS:
   - For each neighbor $(nr, nc)$, if valid and not visited:
     - Record `parent_dir[nr][nc] = dir_char[d]`.
     - If $(nr, nc) == (er, ec)$, stop early!
     - Enqueue $(nr, nc)$ and mark as visited.
5. If `B` was reached, backtrack from $(er, ec)$ to $(sr, sc)$, reverse the collected characters, and output. Otherwise, output `NO`.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <queue>
#include <algorithm>

using namespace std;

// Direction deltas and their corresponding move characters
const int dr[4] = {-1, 1, 0, 0};
const int dc[4] = {0, 0, -1, 1};
const char move_char[4] = {'U', 'D', 'L', 'R'};

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<string> grid(n);
    int start_r = -1, start_c = -1;
    int end_r = -1, end_c = -1;

    for (int i = 0; i < n; ++i) {
        cin >> grid[i];
        for (int j = 0; j < m; ++j) {
            if (grid[i][j] == 'A') {
                start_r = i;
                start_c = j;
            } else if (grid[i][j] == 'B') {
                end_r = i;
                end_c = j;
            }
        }
    }

    // parent_dir[r][c] stores the direction character taken to enter cell (r, c)
    // '0' indicates unvisited
    vector<vector<char>> parent_dir(n, vector<char>(m, 0));

    queue<pair<int, int>> q;
    q.push({start_r, start_c});
    parent_dir[start_r][start_c] = 'S'; // Mark start cell as visited

    bool found = false;

    while (!q.empty()) {
        auto [r, c] = q.front();
        q.pop();

        if (r == end_r && c == end_c) {
            found = true;
            break;
        }

        for (int d = 0; d < 4; ++d) {
            int nr = r + dr[d];
            int nc = c + dc[d];

            if (nr >= 0 && nr < n && nc >= 0 && nc < m) {
                // Must not be a wall and not yet visited
                if (grid[nr][nc] != '#' && parent_dir[nr][nc] == 0) {
                    parent_dir[nr][nc] = move_char[d];
                    q.push({nr, nc});
                }
            }
        }
    }

    if (!found) {
        cout << "NO\n";
        return 0;
    }

    // Backtrack from end cell B to start cell A
    string path = "";
    int curr_r = end_r;
    int curr_c = end_c;

    while (curr_r != start_r || curr_c != start_c) {
        char move = parent_dir[curr_r][curr_c];
        path.push_back(move);

        // Reverse the direction to find the parent cell
        if (move == 'U') curr_r++;
        else if (move == 'D') curr_r--;
        else if (move == 'L') curr_c++;
        else if (move == 'R') curr_c--;
    }

    reverse(path.begin(), path.end());

    cout << "YES\n";
    cout << path.size() << '\n';
    cout << path << '\n';

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot m)$. Each cell is pushed into the queue at most once. For each cell, 4 neighbors are examined. Backtracking takes $\mathcal{O}(\text{path length}) \le \mathcal{O}(n \cdot m)$. Total runtime: $\approx 0.05\text{s}$.
- **Space Complexity**: $\mathcal{O}(n \cdot m)$ auxiliary space for `parent_dir` and the BFS queue ($\approx 2\text{ MB}$).
- **Optimality Guarantee**: Shortest path in unweighted graphs requires exploring connected vertices in level order ($\Omega(V + E)$), matching $\mathcal{O}(n \cdot m)$.

---

## 6. Correctness Proof

### BFS Shortest Path Theorem
In any graph with uniform edge weights ($w(e) = 1$):
1. **FIFO Invariant**: The queue maintains vertices ordered by distance: all vertices at distance $d$ are dequeued before any vertex at distance $d+1$.
2. **First Encounter Optimality**:
   When vertex $B = (end\_r, end\_c)$ is first reached, the path length from $A$ to $B$ is the true geodesic distance $\text{dist}(A, B)$.
3. **Predecessor Invertibility**:
   At each transition $(r, c) \xrightarrow{move} (nr, nc)$, `parent_dir[nr][nc]` stores $move$.
   Since $nr = r + \Delta r$ and $nc = c + \Delta c$, subtracting $\Delta r$ and $\Delta c$ uniquely reconstructs the parent cell $(r, c)$.
   The sequence terminates at $A$ (marked with `'S'`), recovering the shortest path without cycles.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 8
########
#.A#...#
#.##.#B#
#......#
########
```
- Start: `A` at $(1, 2)$
- End: `B` at $(2, 6)$

| Queue Pop $(r, c)$ | Dist | Valid Unvisited Neighbors | Direction Recorded in `parent_dir` |
| :---: | :---: | :---: | :---: |
| $(1, 2)$ (`A`) | 0 | $(1, 1) \to \text{'L'}, (2, 1) \to \text{invalid}, (3, 2) \to \text{invalid}$ | `parent_dir[1][1] = 'L'` |
| $(1, 1)$ | 1 | $(2, 1) \to \text{'D'}, (3, 1) \to \text{queued later}$ | `parent_dir[2][1] = 'D'` |
| $(2, 1)$ | 2 | $(3, 1) \to \text{'D'}$ | `parent_dir[3][1] = 'D'` |
| $(3, 1)$ | 3 | $(3, 2) \to \text{'R'}$ | `parent_dir[3][2] = 'R'` |
| $\dots$ | $\dots$ | $(3, 2) \to (3, 3) \to (3, 4) \to (3, 5) \to (3, 6)$ | Sweeps along bottom row via `'R'` |
| $(3, 6)$ | 8 | $(2, 6) \to \text{'U'}$ (`B` reached!) | `parent_dir[2][6] = 'U'` |

Backtracking from $(2, 6)$:
1. At $(2, 6)$: `move = 'U'` $\implies$ step Down to $(3, 6)$.
2. At $(3, 6) \dots (3, 2)$: `moves = 'R'` $\implies$ steps Left to $(3, 1)$.
3. At $(3, 1)$: `move = 'D'` $\implies$ step Up to $(2, 1)$.
4. At $(2, 1)$: `move = 'D'` $\implies$ step Up to $(1, 1)$.
5. At $(1, 1)$: `move = 'L'` $\implies$ step Right to $(1, 2)$ (`A`).

Reverse string: `L D D R R R R R U`.  
Length: `9`.  
**Output**:  
`YES`  
`9`  
`LDDRRRRRU`  
(Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **No Path Available**: Destination `B` is completely walled off $\implies$ queue empties with `found = false`, outputs `NO`.
- **`A` and `B` Immediately Adjacent**: Path length 1 (e.g., `R`).
- **Visited Marking on Push**: `parent_dir[nr][nc]` must be set **immediately upon pushing** to the queue. Delaying until pop causes duplicate node expansions and memory explosion.
- **Backtracking Coordinates**: Reversing direction must use inverted arithmetic (`U` moves down, `D` moves up, etc.).

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if edge weights are non-uniform (e.g. mud costs 2, floor costs 1)?**
   - BFS fails. Use **0-1 BFS** (with `std::deque`) if weights are in $\{0, 1\}$, or **Dijkstra's Algorithm** with `priority_queue` for general non-negative weights in $\mathcal{O}(E \log V)$.
2. **Multiple Destinations (Find closest of many `B`s)?**
   - Stop BFS at the very first `B` popped from the queue.
3. **Multiple Start Points and Multiple End Points?**
   - Multi-source BFS: push all start points into the queue at distance 0.
4. **Bidirectional BFS?**
   - Expand two BFS frontiers simultaneously from `A` and `B`. When the frontiers meet, reconstruct both halves. Reduces peak memory and operations from $\mathcal{O}(b^d)$ to $\mathcal{O}(b^{d/2})$.
5. **Path with at most $K$ turns (minimum cornering)?**
   - 0-1 BFS where state is $(r, c, dir)$. Moving in the same direction costs 0; turning costs 1.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[graph-algorithms, bfs, shortest-path, grid-graph, path-reconstruction]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot m)$
  - Space: $\mathcal{O}(n \cdot m)$
- **Related CSES Problems**:
  - `CSES 1192` — [Counting Rooms](https://cses.fi/problemset/task/1192) (Grid connected components).
  - `CSES 1194` — [Monsters](https://cses.fi/problemset/task/1194) (Multi-source BFS vs player escape).
  - `CSES 1667` — [Message Route](https://cses.fi/problemset/task/1667) (BFS shortest path on general graph).
