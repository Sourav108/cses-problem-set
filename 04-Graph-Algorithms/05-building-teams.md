# Building Teams

- **Category**: Graph Algorithms
- **CSES Task ID**: `1668`
- **CSES Problem Link**: [Building Teams](https://cses.fi/problemset/task/1668)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ pupils in a school and $m$ friendship connections between pairs of pupils. Your task is to divide the pupils into two teams (Team 1 and Team 2) such that **no two friends are on the same team**.

If such a division is possible, print the team number ($1$ or $2$) for each pupil. If it is impossible, print `IMPOSSIBLE`.

### Input Format
- The first line contains two integers $n$ and $m$: the number of pupils and friendships.
- The next $m$ lines each contain two integers $a$ and $b$: a friendship between pupil $a$ and pupil $b$.

### Output Format
- Print $n$ integers: for each pupil $1, 2, \dots, n$, print the team number ($1$ or $2$).
- If no valid division exists, print `IMPOSSIBLE`.

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$ and $a \ne b$

With $V = 10^5$ and $E = 2 \cdot 10^5$, an $\mathcal{O}(n + m)$ graph 2-coloring algorithm (BFS or DFS) runs in $\approx 0.04\text{s}$.

---

## 2. Intuition & Pattern Recognition

This problem is the classic **Graph 2-Coloring / Bipartite Graph Testing**:
- A graph is bipartite (2-colorable) if and only if its vertices can be divided into two disjoint sets such that every edge connects a vertex in one set to a vertex in the other.
- **Fundamental Theorem of Bipartite Graphs**:
  A graph is bipartite **if and only if it contains no odd cycles** (cycles with an odd number of edges).
- **Algorithm (BFS 2-Coloring)**:
  1. We color the vertices using colors $\{1, 2\}$.
  2. For every uncolored vertex $i$, assign it color $1$ and launch a BFS.
  3. Whenever we traverse an edge $(u, v)$:
     - If neighbor $v$ is uncolored, assign it the opposite color:
       $$\text{color}[v] = 3 - \text{color}[u]$$
       and enqueue $v$.
     - If neighbor $v$ is already colored and has the **same color** as $u$ ($\text{color}[v] == \text{color}[u]$), we have detected an odd cycle! The graph is not bipartite $\implies$ print `IMPOSSIBLE`.
  4. If all components are colored without conflicts, the coloring is valid.

---

## 3. Approach 1 — Naive / Pure Backtracking

Try all $2^n$ color assignments for the pupils.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^n \cdot m)$.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE for $n > 25$.

---

## 4. Approach 2 — Intermediate / Recursive DFS 2-Coloring

Traverse each component using recursive DFS, assigning alternate colors.

```cpp
#include <iostream>
#include <vector>

using namespace std;

int n, m;
vector<vector<int>> adj;
vector<int> color;
bool possible = true;

void dfs(int u, int c) {
    color[u] = c;
    for (int v : adj[u]) {
        if (color[v] == 0) {
            dfs(v, 3 - c);
        } else if (color[v] == c) {
            possible = false;
        }
    }
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$.
- **Space Complexity**: $\mathcal{O}(n + m)$ adjacency list + call stack depth up to $10^5$.
- **Verdict**: Can pass, but a deep chain of $10^5$ vertices risks stack overflow on systems with restricted stack limits. Queue BFS in Approach 3 is strictly memory-safe.

---

## 5. Approach 3 — Optimal CSES Solution (Queue-Based BFS 2-Coloring)

We maintain `color` initialized to $0$ (uncolored). We iterate through all components, using a BFS queue to alternate colors and detect conflicts.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<vector<int>> adj(n + 1);
    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    // color[i] stores the team number (1 or 2) for pupil i
    // 0 indicates that pupil i has not yet been assigned
    vector<int> color(n + 1, 0);

    for (int i = 1; i <= n; ++i) {
        if (color[i] == 0) {
            // Start coloring a new connected component with Team 1
            color[i] = 1;
            queue<int> q;
            q.push(i);

            while (!q.empty()) {
                int u = q.front();
                q.pop();

                int next_color = (color[u] == 1 ? 2 : 1);

                for (int v : adj[u]) {
                    if (color[v] == 0) {
                        // Assign the opposite color to neighbor
                        color[v] = next_color;
                        q.push(v);
                    } else if (color[v] == color[u]) {
                        // Conflict: adjacent vertices share the same team -> odd cycle
                        cout << "IMPOSSIBLE\n";
                        return 0;
                    }
                }
            }
        }
    }

    // Output team assignments for all pupils
    for (int i = 1; i <= n; ++i) {
        cout << color[i] << (i == n ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$. Building the graph takes $\mathcal{O}(n + m)$. In BFS, each vertex is enqueued once and each undirected edge is checked twice ($2m$). Outputting teams takes $\mathcal{O}(n)$. Total runtime: $\approx 0.04\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ auxiliary space to store the adjacency list, `color` array, and queue ($\approx 10\text{ MB}$).
- **Optimality Guarantee**: Testing 2-colorability requires reading all edges ($\Omega(n + m)$), making linear time optimal.

---

## 6. Correctness Proof

### Bipartite Equivalence Invariant
1. In any valid 2-coloring, every edge $(u, v)$ must satisfy $\text{color}[u] \ne \text{color}[v]$.
2. Fix the color of an arbitrary component root $r$ to $1$.
   - Any vertex $v$ at distance $d$ from $r$ must have color:
     $$\text{color}[v] = \begin{cases} 1 & \text{if } d \text{ is even} \\ 2 & \text{if } d \text{ is odd} \end{cases}$$
   - This parity assignment is forced; no alternative coloring of this component exists up to swapping colors $1 \leftrightarrow 2$.
3. **Odd Cycle Detection**:
   - If an edge $(u, v)$ connects two vertices with $\text{color}[u] == \text{color}[v]$, both $u$ and $v$ have distances of the same parity from $r$.
   - The path from $r$ to $u$, edge $(u, v)$, and path from $v$ to $r$ form a closed walk of length $d_u + 1 + d_v$.
   - Since $d_u \equiv d_v \pmod 2$, the cycle length $d_u + d_v + 1$ is odd.
   - A graph with an odd cycle cannot be 2-colored.
4. Hence, the algorithm outputs `IMPOSSIBLE` if and only if no valid partition exists.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
1 2
1 3
4 5
```
$n = 5, m = 3$.
Friendships: $(1, 2), (1, 3), (4, 5)$.

| Step | Component Root $i$ | Traversal & Action | Color Assignments |
| :---: | :---: | :---: | :---: |
| **1** | 1 | `color[1] = 1`, enqueue 1 | `color[1] = 1` |
| **-** | Pop 1 | Neighbors: $2, 3$. Both uncolored $\implies$ color $2$ | `color[2] = 2`, `color[3] = 2` |
| **-** | Pop 2, Pop 3 | Neighbors of 2: 1 (`color[1]=1 != 2`). Neighbors of 3: 1 (`color[1]=1 != 2`). Component complete | Valid |
| **2** | 2 | `color[2] != 0`, skip | - |
| **3** | 3 | `color[3] != 0`, skip | - |
| **4** | 4 | `color[4] = 0` $\implies$ new component. `color[4] = 1`, enqueue 4 | `color[4] = 1` |
| **-** | Pop 4 | Neighbor 5 is uncolored $\implies$ color $2$ | `color[5] = 2` |
| **-** | Pop 5 | Neighbor 4 has `color=1 != 2`. Component complete | Valid |

No conflicts detected.  
**Output**: `1 2 2 1 2` (Matches CSES valid answer).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Odd Cycle (Triangle: $1-2-3-1$)**: When checking edge $(3, 1)$, both have color $1 \implies$ immediately prints `IMPOSSIBLE`.
- **Self-Loops ($a = b$)**: The problem specifies $a \ne b$. If a self-loop existed, vertex $u$ would check itself and detect `color[u] == color[u]`, correctly reporting `IMPOSSIBLE`.
- **Multiple Disconnected Components**: The outer loop `for (int i = 1; i <= n; ++i)` independently colors every component.
- **Isolated Vertices ($m = 0$)**: Every vertex colored $1$, valid.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Find and Print the Odd Cycle if Impossible?**
   - Maintain `parent[v]`. When a conflict edge $(u, v)$ is found with $\text{color}[u] == \text{color}[v]$, backtrack along `parent` from both $u$ and $v$ to their Lowest Common Ancestor (LCA) to extract the odd cycle (`CSES 1669: Round Trip`).
2. **Maximum Independent Set on Bipartite Graphs?**
   - By König's theorem, $\text{MIS} = |V| - \text{MaxMatching}$. Solved using Hopcroft-Karp in $\mathcal{O}(E \sqrt{V})$.
3. **Graph 3-Coloring?**
   - 2-coloring is in $\mathcal{P}$ (linear time); 3-coloring is $\mathcal{NP}$-complete for general graphs.
4. **2-SAT Connection?**
   - 2-coloring is a special case of 2-SAT where each edge $(u, v)$ represents $(u \lor v) \land (\neg u \lor \neg v)$.
5. **Bipartite Matching (School Dance)?**
   - Once the graph is verified bipartite, maximum matching can be computed using Dinic's Algorithm or Hopcroft-Karp (`CSES 1696`).

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[graph-algorithms, bipartite-graph, 2-coloring, bfs]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - `CSES 1669` — [Round Trip](https://cses.fi/problemset/task/1669) (Cycle detection and reconstruction).
  - `CSES 1667` — [Message Route](https://cses.fi/problemset/task/1667) (BFS shortest path).
  - `CSES 1696` — [School Dance](https://cses.fi/problemset/task/1696) (Bipartite matching with Ford-Fulkerson/Hopcroft-Karp).
