# Monsters

- **Category**: Graph Algorithms
- **CSES Task ID**: `1194`
- **CSES Problem Link**: [Monsters](https://cses.fi/problemset/task/1194)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are trapped in an $n \times m$ grid labyrinth containing walls (`#`), empty floor tiles (`.`), your starting position (`A`), and zero or more monsters (`M`). 

Each second:
1. You may move to any adjacent floor tile (Up, Down, Left, or Right).
2. Each monster may also move to an adjacent floor tile simultaneously. Monsters know your location and move optimally to intercept you.

Your goal is to reach any boundary square of the grid (i.e., any square in row $0$, row $n-1$, column $0$, or column $m-1$) **without ever sharing a cell with a monster** at any point in time. If you step on an exit square, you immediately escape safely, provided no monster reaches that square at the same or earlier time.

If an escape route exists, print `YES`, followed by the length of the path and the sequence of moves (`U`, `D`, `L`, `R`). If escape is impossible, print `NO`.

### Input Format
- The first line contains two integers $n$ and $m$: the grid dimensions.
- The next $n$ lines each contain $m$ characters describing the labyrinth map.

### Output Format
- If escape is possible:
  - First line: `YES`
  - Second line: An integer $k$, the number of steps.
  - Third line: A string of $k$ characters consisting of `U`, `D`, `L`, `R`.
- If escape is impossible:
  - Print `NO`.

### Numerical Constraints
- $1 \le n, m \le 1000$
- Total cells $n \cdot m \le 10^6$

With $V \le 10^6$ and $E \le 4 \cdot 10^6$, a two-phase Breadth-First Search (BFS) operates in $\mathcal{O}(n \cdot m)$ time, running well within $0.25\text{s}$.

---

## 2. Intuition & Pattern Recognition

This problem requires coordinating movement against multiple pursuers with equal speed on an unweighted grid:
- **Observation 1 (Independence of Monster Times)**:
  Monsters move at the exact same speed as the player ($1$ tile per second). If any monster can reach cell $(r, c)$ in $t$ steps, a monster can always intercept the player if the player arrives at $(r, c)$ at time $\ge t$.
- **Observation 2 (Earliest Monster Arrival)**:
  By running a **Multi-Source BFS** starting simultaneously from all monster positions at time $0$, we can determine `monster_dist[r][c]`: the minimum time any monster requires to reach cell $(r, c)$.
- **Observation 3 (Player Reachability Condition)**:
  The player can safely occupy an adjacent floor cell $(nr, nc)$ at time $t+1$ if and only if:
  $$t + 1 < \text{monster\_dist}[nr][nc]$$
  If $\text{monster\_dist}[nr][nc] \le t + 1$, some monster can reach that tile at the same time as the player or earlier, blocking it.
- **Escape Criterion**:
  Any cell $(r, c)$ on the boundary ($r = 0, r = n-1, c = 0, c = m-1$) that the player can safely reach is an immediate winning terminal state!

---

## 3. Approach 1 — Naive / Pure Minimax Tree Search

Treat the game as an alternating 2-player game (player vs. team of monsters) and search using Minimax with alpha-beta pruning.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(4^{k \cdot M})$ where $k$ is the path length and $M$ is the number of monsters.
- **Space Complexity**: $\mathcal{O}(k \cdot M)$ call stack.
- **CSES Verdict**: TLE and Memory Limit Exceeded (MLE) immediately.

---

## 4. Approach 2 — Single Simultaneous BFS (Queue Merging)

Push all monsters into a single queue first, followed by the player. Simulate step-by-step: pop all monsters at time $t$ to mark cells as occupied by monsters, then pop player positions at time $t$ to explore valid moves.

- **Drawback**: Managing dual entities in a single lock-step queue requires careful layer-by-layer synchronization and state tracking.
- **Verdict**: Valid, but decoupling the search into two separate clean BFS passes (Multi-source Monster BFS, then Player BFS) is far simpler, less error-prone, and faster.

---

## 5. Approach 3 — Optimal CSES Solution (Multi-Source BFS + Player BFS)

1. **Phase 1: Monster Multi-Source BFS**:
   - Initialize `monster_dist[n][m]` with $\infty$ ($10^9$).
   - Enqueue all monster starting coordinates into a queue $Q_M$, setting $\text{monster\_dist}[r_M][c_M] = 0$.
   - Run standard BFS: for each cell $(r, c)$ popped, explore adjacent floor cells $(nr, nc)$. If $\text{monster\_dist}[nr][nc] == \infty$, set $\text{monster\_dist}[nr][nc] = \text{monster\_dist}[r][c] + 1$ and enqueue $(nr, nc)$.
2. **Phase 2: Player BFS**:
   - Initialize `player_dist[n][m]` with $\infty$ and `parent_move[n][m]` with a sentinel.
   - Enqueue player start $(r_A, c_A)$ with $\text{player\_dist}[r_A][c_A] = 0$.
   - If $(r_A, c_A)$ is already on the grid boundary, the player can escape immediately in $0$ steps!
   - Otherwise, while $Q_A$ is non-empty:
     - Pop $(r, c)$.
     - For each of the $4$ cardinal moves $(dr, dc) \in \{(-1, 0), (1, 0), (0, -1), (0, 1)\}$:
       - If $(nr, nc)$ is inside grid, floor (`.` or boundary), unvisited by player, and satisfies:
         $$\text{player\_dist}[r][c] + 1 < \text{monster\_dist}[nr][nc]$$
       - Record `player_dist[nr][nc] = player_dist[r][c] + 1` and record the move direction.
       - If $(nr, nc)$ is on the boundary of the grid, target reached! Reconstruct and exit.
       - Enqueue $(nr, nc)$.
3. **Reconstruction**:
   - Backtrack from the escape boundary tile to $(r_A, c_A)$ using `parent_move`.
   - Reverse the sequence of moves and output.

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <queue>
#include <algorithm>

using namespace std;

const int INF = 1e9;
const int dr[4] = {-1, 1, 0, 0};
const int dc[4] = {0, 0, -1, 1};
const char dir_char[4] = {'U', 'D', 'L', 'R'};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<string> grid(n);
    for (int i = 0; i < n; ++i) {
        cin >> grid[i];
    }

    int start_r = -1, start_c = -1;
    queue<pair<int, int>> q_monster;
    vector<vector<int>> dist_monster(n, vector<int>(m, INF));

    for (int r = 0; r < n; ++r) {
        for (int c = 0; c < m; ++c) {
            if (grid[r][c] == 'M') {
                dist_monster[r][c] = 0;
                q_monster.push({r, c});
            } else if (grid[r][c] == 'A') {
                start_r = r;
                start_c = c;
            }
        }
    }

    // Phase 1: Multi-source BFS for monsters
    while (!q_monster.empty()) {
        auto [r, c] = q_monster.front();
        q_monster.pop();

        for (int i = 0; i < 4; ++i) {
            int nr = r + dr[i];
            int nc = c + dc[i];

            if (nr >= 0 && nr < n && nc >= 0 && nc < m) {
                if (grid[nr][nc] != '#' && dist_monster[nr][nc] == INF) {
                    dist_monster[nr][nc] = dist_monster[r][c] + 1;
                    q_monster.push({nr, nc});
                }
            }
        }
    }

    // Phase 2: BFS for player A
    queue<pair<int, int>> q_player;
    vector<vector<int>> dist_player(n, vector<int>(m, INF));
    vector<vector<int>> parent_dir(n, vector<int>(m, -1));

    dist_player[start_r][start_c] = 0;
    q_player.push({start_r, start_c});

    int exit_r = -1, exit_c = -1;

    // Check if player starts already at boundary
    if (start_r == 0 || start_r == n - 1 || start_c == 0 || start_c == m - 1) {
        exit_r = start_r;
        exit_c = start_c;
    } else {
        while (!q_player.empty()) {
            auto [r, c] = q_player.front();
            q_player.pop();

            if (r == 0 || r == n - 1 || c == 0 || c == m - 1) {
                exit_r = r;
                exit_c = c;
                break;
            }

            for (int i = 0; i < 4; ++i) {
                int nr = r + dr[i];
                int nc = c + dc[i];

                if (nr >= 0 && nr < n && nc >= 0 && nc < m) {
                    if (grid[nr][nc] != '#' && dist_player[nr][nc] == INF) {
                        int next_time = dist_player[r][c] + 1;
                        if (next_time < dist_monster[nr][nc]) {
                            dist_player[nr][nc] = next_time;
                            parent_dir[nr][nc] = i;
                            q_player.push({nr, nc});
                        }
                    }
                }
            }
        }
    }

    if (exit_r == -1) {
        cout << "NO\n";
    } else {
        cout << "YES\n";
        string path = "";
        int curr_r = exit_r, curr_c = exit_c;
        while (curr_r != start_r || curr_c != start_c) {
            int d = parent_dir[curr_r][curr_c];
            path.push_back(dir_char[d]);
            curr_r -= dr[d];
            curr_c -= dc[d];
        }
        reverse(path.begin(), path.end());
        cout << path.size() << '\n';
        cout << path << '\n';
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot m)$.
  - Multi-source BFS visits each cell at most once: $\mathcal{O}(n \cdot m)$.
  - Player BFS visits each cell at most once: $\mathcal{O}(n \cdot m)$.
  - Path reconstruction takes $\mathcal{O}(\text{path length}) \le \mathcal{O}(n \cdot m)$.
- **Space Complexity**: $\mathcal{O}(n \cdot m)$ for grid, distance tables, and BFS queues.

---

## 6. Correctness Proof

### Optimal Monster Strategy & Strict Inequality
- **Claim**: The player can safely transition along path $(p_0, p_1, \dots, p_k)$ to the boundary if and only if for every step $i \in \{1, \dots, k\}$, $\text{dist}_A(p_i) < \text{dist}_M(p_i)$.
- **Proof**:
  1. Suppose $\text{dist}_A(p_i) \ge \text{dist}_M(p_i)$. Then there exists at least one monster $M^*$ that can arrive at cell $p_i$ in $\le i$ seconds.
  2. The monster can simply move along its shortest path to cell $p_i$ and wait there. When the player arrives at second $i$, the monster is either already present at $p_i$ or enters $p_i$ at that exact instant, capturing the player.
  3. Conversely, if $\text{dist}_A(p_i) < \text{dist}_M(p_i)$ for all $i \in \{1, \dots, k\}$, no monster can reach cell $p_i$ in $\le i$ seconds. Since player and monsters move at the same uniform speed of 1 step/sec, no monster can intercept the player at $p_i$ or along the edge $(p_{i-1}, p_i)$.
  4. BFS discovers the shortest path from $A$ to any boundary cell satisfying this condition. By BFS optimality, if a valid escape exists, the first boundary cell dequeued yields a valid shortest escape. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider the grid ($5 \times 8$):
```
########
#...M#.#
#.#A#..#
#M#.#..#
########
```

1. **Monsters Multi-source BFS**:
   - `M1` at `(1, 4)`, `M2` at `(3, 1)`.
   - Propagate distances outward from both `M` tiles through empty cells.
2. **Player BFS**:
   - `A` starts at `(2, 3)` at $t=0$.
   - Move up to `(1, 3)`: distance to monster is $1$, player arrival time is $1$. $1 < 1$ is FALSE (monster can reach `(1, 3)` in 1 step from `(1, 4)`). Player blocked!
   - Move down to `(3, 3)`: check distance from monsters: `M2` takes $2$ steps, `M1` takes $3$ steps. Player arrives at $t=1 < 2$. Valid!
   - Continue expanding until reaching an exterior boundary tile.
3. Path is reconstructed cleanly backwards to start.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Player Starts on Boundary**:
   If the player's initial position $(r_A, c_A)$ is already on the grid boundary ($r=0, r=n-1, c=0, c=m-1$), the player has escaped instantly:
   Output `YES`, `0`, and an empty line for path.
2. **Zero Monsters**:
   If the grid contains no `M`, `dist_monster` remains `INF` everywhere. The player can move freely to any reachable boundary cell. Handled seamlessly without special cases.
3. **Player Completely Enclosed by Walls**:
   If player cannot move anywhere, BFS terminates and correctly prints `NO`.
4. **Tie Between Monster and Player**:
   If monster and player arrive at cell $(nr, nc)$ at the same time ($t_A = t_M$), the player is caught! The strict inequality `next_time < dist_monster[nr][nc]` correctly enforces this requirement.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if monsters move at twice the player's speed?**
   The condition becomes $\text{next\_time} < \lceil \text{dist}_M[nr][nc] / 2 \rceil$. A 0-1 BFS or Dijkstra would be used if edge traversal times differ.
2. **What if monsters can see through walls or destroy walls?**
   If monsters move as Euclidean distance regardless of walls, $\text{dist}_M[r][c] = \min_{M_i} (|r - r_{M_i}| + |c - c_{M_i}|)$ or Euclidean $\sqrt{(r - r_{M_i})^2 + (c - c_{M_i})^2}$.
3. **Can the monsters move dynamically based on the player's observed actions?**
   Because monsters have equal speed and shortest distance represents their earliest possible arrival time, precomputing the static shortest distance lower bounds their arrival time under all possible adversarial strategies.
4. **Why is BFS preferred over DFS for this grid problem?**
   A grid of size $1000 \times 1000$ contains $10^6$ nodes. DFS can recurse up to depth $10^6$, causing stack overflow. Furthermore, DFS does not find the shortest path, whereas BFS guarantees the minimum number of steps.
5. **How can memory be minimized on very tight memory limits?**
   Instead of storing 4 full $n \times m$ 2D arrays, pack `dist_player` and `parent_dir` into 16-bit integers or single bytes, or mutate the input `grid` characters directly.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Multi-Source BFS, Grid Traversal, Shortest Path, Path Reconstruction
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot m)$
  - Space: $\mathcal{O}(n \cdot m)$
- **Related CSES Problems**:
  - [Labyrinth](https://cses.fi/problemset/task/1193) — Single-source BFS grid path reconstruction
  - [Counting Rooms](https://cses.fi/problemset/task/1192) — Connected components on grid
  - [Message Route](https://cses.fi/problemset/task/1667) — Unweighted shortest path on general graphs
