# Counting Rooms

- **Category**: Graph Algorithms
- **CSES Task ID**: `1192`
- **CSES Problem Link**: [Counting Rooms](https://cses.fi/problemset/task/1192)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a map of a building represented as an $n \times m$ grid of characters. Each square is either a floor (`.`) or a wall (`#`). You can walk between floor squares that are adjacent horizontally or vertically. A **room** is defined as a maximal connected component of floor squares.

Calculate the total number of rooms in the building.

### Input Format
- The first line contains two integers $n$ and $m$: the height and width of the map.
- The next $n$ lines each contain a string of length $m$ consisting of characters `.` and `#`.

### Output Format
- Print one integer: the number of rooms.

### Numerical Constraints
- $1 \le n, m \le 1000$

With $n, m \le 1000$, the total number of squares is $V = n \cdot m \le 10^6$. An $\mathcal{O}(n \cdot m)$ graph traversal (BFS or Disjoint Set Union) visits each cell in constant time, executing in $\approx 0.05\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the standard **Connected Components in a Grid Graph** problem:
- We can view the grid as an undirected graph where:
  - Vertices are floor squares `.`
  - Edges exist between 4-directionally adjacent floor squares (Up, Down, Left, Right).
- A room is simply a connected component of this graph.
- We iterate through all cells $(r, c)$ in the grid. Whenever an unvisited floor square is encountered:
  1. Increment the room counter.
  2. Launch a graph traversal (BFS or iterative DFS) to mark all floor squares reachable from $(r, c)$ as visited.
- **Stack Overflow Caution**: A standard recursive DFS on a $1000 \times 1000$ grid can reach recursion depth $10^6$, exceeding the default 8 MB stack limit and causing a runtime segmentation fault. We use **Iterative BFS** with a queue to ensure memory safety.

---

## 3. Approach 1 — Naive / Recursive DFS (Stack Risk)

Traverse each component using recursive DFS.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <string>

using namespace std;

int n, m;
vector<string> grid;

const int dr[] = {-1, 1, 0, 0};
const int dc[] = {0, 0, -1, 1};

void dfs(int r, int c) {
    grid[r][c] = '#'; // Mark as visited in-place

    for (int i = 0; i < 4; ++i) {
        int nr = r + dr[i];
        int nc = c + dc[i];
        if (nr >= 0 && nr < n && nc >= 0 && nc < m && grid[nr][nc] == '.') {
            dfs(nr, nc);
        }
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> m)) return 0;
    grid.resize(n);
    for (int i = 0; i < n; ++i) cin >> grid[i];

    int rooms = 0;
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < m; ++j) {
            if (grid[i][j] == '.') {
                rooms++;
                dfs(i, j); // Can cause stack overflow on deep paths
            }
        }
    }

    cout << rooms << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot m)$.
- **Space Complexity**: $\mathcal{O}(n \cdot m)$ call stack memory.
- **CSES Verdict**: Runtime Error (SIGSEGV) on test cases with snake-like winding paths due to call-stack overflow.

---

## 4. Approach 2 — Intermediate / Disjoint Set Union (DSU)

Flatten each cell $(r, c)$ into an integer ID $r \times m + c$. Run DSU across all 4-neighbor pairs of `.`. Count the number of unique DSU roots corresponding to floor cells.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot m \cdot \alpha(n \cdot m))$.
- **Space Complexity**: $\mathcal{O}(n \cdot m)$ for parent and rank arrays.
- **Verdict**: Fully passes, but BFS in Approach 3 avoids union-find overhead and is simpler.

---

## 5. Approach 3 — Optimal CSES Solution (Iterative BFS Queue)

We perform a Breadth-First Search using a queue of coordinate pairs or encoded single integers `r * m + c`. To avoid auxiliary memory, we mark visited floor cells in-place by flipping `.` to `#`.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <queue>

using namespace std;

// Direction offsets for 4-directional movement (Up, Down, Left, Right)
const int dr[4] = {-1, 1, 0, 0};
const int dc[4] = {0, 0, -1, 1};

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<string> grid(n);
    for (int i = 0; i < n; ++i) {
        cin >> grid[i];
    }

    int room_count = 0;
    queue<pair<int, int>> q;

    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < m; ++j) {
            if (grid[i][j] == '.') {
                room_count++;

                // Launch BFS to mark all connected floor cells
                grid[i][j] = '#'; // Mark visited in-place
                q.push({i, j});

                while (!q.empty()) {
                    auto [r, c] = q.front();
                    q.pop();

                    for (int d = 0; d < 4; ++d) {
                        int nr = r + dr[d];
                        int nc = c + dc[d];

                        if (nr >= 0 && nr < n && nc >= 0 && nc < m && grid[nr][nc] == '.') {
                            grid[nr][nc] = '#'; // Mark visited before pushing to prevent duplicates
                            q.push({nr, nc});
                        }
                    }
                }
            }
        }
    }

    cout << room_count << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot m)$. Every square $(r, c)$ is enqueued and dequeued at most once. For each popped square, exactly 4 directional checks are performed. For $n, m \le 1000$, total operations $\le 5 \cdot 10^6$, finishing in $\approx 0.04\text{s}$.
- **Space Complexity**: $\mathcal{O}(\min(n, m))$ auxiliary space for the BFS queue (the wavefront boundary of any component cannot exceed $\mathcal{O}(\min(n, m))$ active cells simultaneously). Visited state is tracked in-place in `grid`.
- **Optimality Guarantee**: Every cell must be inspected to distinguish walls from floors, establishing an $\Omega(n \cdot m)$ lower bound. $\mathcal{O}(n \cdot m)$ matches this bound.

---

## 6. Correctness Proof

### Connected Component Invariant
1. A room is an equivalence class under the reflexive, symmetric, transitive reachability relation on floor cells:
   $$u \sim v \iff \text{there exists a 4-connected path of floor cells between } u \text{ and } v$$
2. **Exhaustion of Component**:
   When BFS begins at an unvisited floor square $(i, j)$, it visits all squares in the equivalence class containing $(i, j)$ because:
   - The queue starts with $(i, j)$.
   - By induction, if square $u$ is in the component and has an adjacent unvisited floor square $v$, $v$ will be discovered, marked as `#`, and enqueued.
   - BFS terminates only when no unvisited floor square adjacent to any square in the component exists.
3. **Disjoint Counting**:
   Marking visited floor squares as `#` guarantees that no square in this component will ever trigger another BFS launch.
   Hence, the counter `room_count` increments exactly once per connected component.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 8
########
#..#...#
####.#.#
#..#...#
########
```
$n = 5, m = 8$.

1. First floor found at $(1, 1)$: `room_count = 1`.
   - BFS traverses $(1, 1), (1, 2)$. Blocked by `#`.
   - Area cleared to `#`.
2. Next floor found at $(1, 4)$: `room_count = 2`.
   - BFS traverses $(1, 4), (1, 5), (1, 6)$.
   - From $(1, 6)$, moves down to $(2, 6)$ and $(3, 6)$.
   - From $(3, 6)$, reaches $(3, 5), (3, 4)$.
   - Area cleared to `#`.
3. Next floor found at $(3, 1)$: `room_count = 3`.
   - BFS traverses $(3, 1), (3, 2)$.
   - Area cleared to `#`.
4. All remaining cells are `#`.

**Final Output**: `3`. Matches CSES example!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **No Floor Squares**: All `#` $\implies$ loop never enters BFS, outputs `0`.
- **Entire Grid Floor**: All `.` $\implies$ single BFS traverses all $n \times m$ cells, outputs `1`.
- **Marking Before Enqueueing Gotcha**: In grid BFS, `grid[nr][nc] = '#'` **must** be executed *before* pushing to the queue. If marked upon popping, duplicate cells will be pushed by multiple neighbors, exploding queue size to $\mathcal{O}(n \cdot m)$ and causing TLE/MLE.
- **Memory Safety**: Flipping in-place eliminates the need for an extra `bool visited[1000][1000]` array.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Size of each room (number of cells in component)?**
   - Maintain a local counter `int current_size = 0` inside the BFS while-loop and record component sizes in a vector.
2. **Largest Room Area?**
   - Track `max_room = max(max_room, current_size)`.
3. **What if diagonal movement is allowed (8-directional)?**
   - Add the 4 diagonal offsets: `dr = {-1,-1,-1,0,0,1,1,1}`, `dc = {-1,0,1,-1,1,-1,0,1}`.
4. **Dynamic Grid with Changing Walls (Percolation)?**
   - If walls turn into floors dynamically, use **Disjoint Set Union (DSU)** with path compression and union by rank to merge components in $\mathcal{O}(\alpha(n \cdot m))$.
5. **Shortest Distance Between Two Specific Rooms?**
   - Multi-source BFS starting simultaneously from all cells in Room 1 to find the shortest path of walls that must be converted.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[graph-algorithms, bfs, grid-graph, connected-components]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot m)$
  - Space: $\mathcal{O}(\min(n, m))$
- **Related CSES Problems**:
  - `CSES 1193` — [Labyrinth](https://cses.fi/problemset/task/1193) (Grid BFS shortest path with path reconstruction).
  - `CSES 1666` — [Building Roads](https://cses.fi/problemset/task/1666) (Connected components on general graphs).
  - `CSES 1194` — [Monsters](https://cses.fi/problemset/task/1194) (Multi-source BFS on grids).
