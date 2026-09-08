# Message Route

- **Category**: Graph Algorithms
- **CSES Task ID**: `1667`
- **CSES Problem Link**: [Message Route](https://cses.fi/problemset/task/1667)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

A computer network has $n$ computers numbered $1, 2, \dots, n$ and $m$ bidirectional connections between them. You wish to send a message from computer $1$ to computer $n$. Determine whether a route exists, and if so, find a route that visits the **minimum possible number of computers**.

### Input Format
- The first line contains two integers $n$ and $m$: the number of computers and connections.
- The next $m$ lines each contain two integers $a$ and $b$: a connection between computers $a$ and $b$.

### Output Format
- If a route exists:
  - First print an integer $k$: the minimum number of computers on the route (including computers $1$ and $n$).
  - Then print the sequence of $k$ computer numbers along the route.
- If no route exists, print `IMPOSSIBLE`.

### Numerical Constraints
- $2 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$ and $a \ne b$

With $V = 10^5$ and $E = 2 \cdot 10^5$, an unweighted shortest path search using Breadth-First Search (BFS) runs in $\mathcal{O}(n + m)$ time ($\approx 0.04\text{s}$).

---

## 2. Intuition & Pattern Recognition

This is the standard **Single-Source Shortest Path on an Unweighted Graph**:
- Each connection between two computers represents an unweighted undirected edge of cost $1$.
- **Why BFS**:
  Breadth-First Search visits vertices in order of increasing distance from the source computer $1$. The first time computer $n$ is reached, the path length is guaranteed to be minimal.
- **Path Reconstruction**:
  To reconstruct the route:
  - Maintain a `parent` array of size $n + 1$, initialized to $0$.
  - When visiting neighbor $v$ from vertex $u$, set `parent[v] = u`.
  - Once BFS terminates, if `parent[n] == 0`, computer $n$ is unreachable $\implies$ print `IMPOSSIBLE`.
  - Otherwise, backtrack from $n$ to $1$ via $curr \gets parent[curr]$, reverse the resulting path, and print its length and nodes.

---

## 3. Approach 1 — Naive / Depth-First Search (DFS)

Using DFS to find a route from $1$ to $n$.

### Complexity Analysis
- **Failure**: DFS does not guarantee the shortest path in unweighted graphs (it can find an arbitrarily long path of length $n$). Furthermore, deep recursion on $n = 10^5$ causes call-stack overflow (SIGSEGV).
- **CSES Verdict**: Wrong Answer (WA) & Runtime Error (RE).

---

## 4. Approach 2 — Intermediate / Dijkstra's Algorithm

Use Dijkstra's algorithm with unit edge weights.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}((V + E) \log V) \approx \mathcal{O}((n + m) \log n)$.
- **Space Complexity**: $\mathcal{O}(n + m)$.
- **Verdict**: Fully passes, but the $\log n$ factor from the priority queue adds unnecessary overhead compared to simple queue BFS.

---

## 5. Approach 3 — Optimal CSES Solution (Breadth-First Search)

1. Build an adjacency list `adj` of size $n + 1$.
2. Maintain `parent` array initialized to $0$. Set `parent[1] = 1` to mark the source as visited.
3. Push $1$ into a queue `q`.
4. While `!q.empty()`:
   - Pop $u$.
   - If $u == n$, break early!
   - For each neighbor $v \in adj[u]$:
     - If `parent[v] == 0` (unvisited):
       - `parent[v] = u;`
       - `q.push(v);`
5. If `parent[n] == 0`, print `IMPOSSIBLE`.
6. Otherwise, backtrack from $n$ to $1$ to assemble the route, reverse it, and print.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>

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

    // parent[v] stores the predecessor node of v on the shortest path from 1
    // 0 indicates that vertex v has not yet been visited
    vector<int> parent(n + 1, 0);

    queue<int> q;
    q.push(1);
    parent[1] = 1; // Mark start node as visited

    while (!q.empty()) {
        int u = q.front();
        q.pop();

        if (u == n) break; // Destination reached with minimal edges

        for (int v : adj[u]) {
            if (parent[v] == 0) {
                parent[v] = u;
                q.push(v);
            }
        }
    }

    // If destination n was never reached
    if (parent[n] == 0) {
        cout << "IMPOSSIBLE\n";
        return 0;
    }

    // Reconstruct the shortest path from n back to 1
    vector<int> path;
    int curr = n;
    while (curr != 1) {
        path.push_back(curr);
        curr = parent[curr];
    }
    path.push_back(1);

    reverse(path.begin(), path.end());

    cout << path.size() << '\n';
    for (size_t i = 0; i < path.size(); ++i) {
        cout << path[i] << (i + 1 == path.size() ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$. Building the graph takes $\mathcal{O}(n + m)$. BFS enqueues each vertex at most once and scans each undirected edge twice ($2m$). Path reconstruction takes $\mathcal{O}(k) \le \mathcal{O}(n)$ time. Total runtime: $\approx 0.04\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ auxiliary space to store the adjacency list, `parent` array, and queue ($\approx 10\text{ MB}$).
- **Optimality Guarantee**: Shortest path in unweighted graphs requires exploring connected edges in breadth-first order ($\Omega(V + E)$), matching $\mathcal{O}(n + m)$.

---

## 6. Correctness Proof

### Shortest Path Tree Invariant
1. In an unweighted graph with edge weights $w(e) = 1$, Breadth-First Search discovers vertices strictly in non-decreasing order of their distance from the source:
   $$\text{dist}(1, v_1) \le \text{dist}(1, v_2) \quad \text{for any } v_1 \text{ dequeued before } v_2$$
2. The first time computer $n$ is discovered, the path stored via predecessor pointers has length equal to the true minimum graph distance $\text{dist}(1, n)$.
3. **Loop Invariant on `parent`**:
   For every visited vertex $v \ne 1$, `parent[v]` is a valid neighbor on a shortest path from $1$ to $v$ with $\text{dist}(1, v) = \text{dist}(1, parent[v]) + 1$.
4. Backtracking from $n$ along `parent` strictly decreases the distance by $1$ at each step, reaching $1$ in exactly $\text{dist}(1, n)$ steps without cycles.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 5
1 2
1 3
1 4
2 3
5 4
```
$n = 5, m = 5$.
Edges: $(1, 2), (1, 3), (1, 4), (2, 3), (5, 4)$.

| Queue State | Pop $u$ | Neighbors of $u$ | Unvisited Neighbor $v$ | Set `parent[v]` | Updated Queue |
| :---: | :---: | :---: | :---: | :---: | :---: |
| `[1]` | 1 | $2, 3, 4$ | 2, 3, 4 | `parent[2]=1`<br>`parent[3]=1`<br>`parent[4]=1` | `[2, 3, 4]` |
| `[2, 3, 4]` | 2 | $1, 3$ | None (already visited) | - | `[3, 4]` |
| `[3, 4]` | 3 | $1, 2$ | None | - | `[4]` |
| `[4]` | 4 | $1, 5$ | 5 | `parent[5]=4` | `[5]` |
| `[5]` | 5 | $4$ | None | Target reached, break | `[]` |

Backtracking from 5:
- $curr = 5 \implies parent[5] = 4$
- $curr = 4 \implies parent[4] = 1$
- $curr = 1 \implies$ start reached.

Path collected: `[5, 4, 1]`.  
Reversed path: `1 4 5`.  
Number of computers: `3`.  
**Output**:  
`3`  
`1 4 5`  
(Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Disconnected Target**: Computer $n$ is in a different connected component $\implies parent[n] == 0$, correctly outputs `IMPOSSIBLE`.
- **Direct Connection ($1$ is connected to $n$)**: Handled immediately, output length 2: `1 n`.
- **$n = 2$**: Minimum possible $n$. Handled properly.
- **Multiple Edges / Cycles**: `parent[v] == 0` check guarantees no vertex is processed more than once, ignoring duplicate edges.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Count the number of distinct shortest paths from $1$ to $n$?**
   - Maintain a `ways[v]` array along with `dist[v]`. If `dist[u] + 1 == dist[v]`, `ways[v] = (ways[v] + ways[u]) % MOD`.
2. **Shortest path with weighted edges?**
   - Use **Dijkstra's Algorithm** with `priority_queue` in $\mathcal{O}(m \log n)$ (`CSES 1671: Shortest Routes I`).
3. **All-Pairs Shortest Paths?**
   - Use **Floyd-Warshall** in $\mathcal{O}(n^3)$ for $n \le 500$ (`CSES 1672: Shortest Routes II`).
4. **Print ALL shortest routes?**
   - Run BFS to construct the DAG of shortest paths (`dist[v] == dist[u] + 1`), then run DFS on this DAG to enumerate all paths.
5. **Shortest Cycle containing vertex $1$?**
   - Remove edge $(1, v)$, run BFS from $1$ to find shortest path to $v$, and add 1.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[graph-algorithms, bfs, shortest-path, path-reconstruction]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - `CSES 1193` — [Labyrinth](https://cses.fi/problemset/task/1193) (Shortest path on 2D grid with BFS).
  - `CSES 1668` — [Building Teams](https://cses.fi/problemset/task/1668) (Bipartite graph coloring with BFS).
  - `CSES 1671` — [Shortest Routes I](https://cses.fi/problemset/task/1671) (Weighted shortest paths with Dijkstra).
