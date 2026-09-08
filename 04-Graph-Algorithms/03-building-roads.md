# Building Roads

- **Category**: Graph Algorithms
- **CSES Task ID**: `1666`
- **CSES Problem Link**: [Building Roads](https://cses.fi/problemset/task/1666)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ cities numbered $1, 2, \dots, n$ and $m$ bidirectional roads between them. Your task is to determine the **minimum number of new roads** required so that there is a route between any two cities (i.e., the entire graph becomes connected). Furthermore, you must print the endpoints of the new roads to construct.

### Input Format
- The first line contains two integers $n$ and $m$: the number of cities and roads.
- The next $m$ lines each contain two integers $a$ and $b$: a road between cities $a$ and $b$.

### Output Format
- First print an integer $k$: the minimum number of new roads needed.
- Then print $k$ lines, each containing two integers $u$ and $v$ describing a new road to build. (If there are multiple solutions, print any of them).

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$ and $a \ne b$

With $V = 10^5$ and $E = 2 \cdot 10^5$, an $\mathcal{O}(n + m)$ connected components algorithm executes in $\approx 0.04\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the standard **Connected Components & Minimum Spanning Forest** problem:
- The cities and existing roads form an undirected graph $G = (V, E)$.
- Suppose $G$ consists of $C$ disjoint connected components: $\mathcal{K}_1, \mathcal{K}_2, \dots, \mathcal{K}_C$.
- A single new road between a city in $\mathcal{K}_i$ and a city in $\mathcal{K}_j$ ($i \ne j$) merges the two components, reducing the total number of components by at most $1$.
- To reduce $C$ components to $1$ single connected component, we must add at least:
  $$k = C - 1$$
  new roads.
- **Construction Strategy**:
  1. Pick one representative node from each component: say $r_1 \in \mathcal{K}_1, r_2 \in \mathcal{K}_2, \dots, r_C \in \mathcal{K}_C$.
  2. Add $C - 1$ roads connecting adjacent representatives in a chain:
     $$(r_1, r_2), \; (r_2, r_3), \; \dots, \; (r_{C-1}, r_C)$$
  3. This connects all components into a single connected graph using the minimal number of edges.

---

## 3. Approach 1 — Naive / All-Pairs Shortest Path (Floyd-Warshall)

Compute connectivity using Floyd-Warshall to identify unreached pairs.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^3) \approx 10^{15}$ operations.
- **Space Complexity**: $\mathcal{O}(n^2)$.
- **CSES Verdict**: TLE and MLE for $n > 500$.

---

## 4. Approach 2 — Intermediate / Disjoint Set Union (DSU)

Maintain a DSU over $n$ vertices. For each road $(u, v)$, call `unite(u, v)`. After processing all edges, collect all vertices that are their own parent (`parent[i] == i`). If there are $C$ roots, print $C - 1$ and connect $root_i$ to $root_{i+1}$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m \cdot \alpha(n))$.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space.
- **Verdict**: Optimal, clean, and competitive-ready.

---

## 5. Approach 3 — Optimal CSES Solution (Breadth-First Search / Component Representatives)

We represent the graph with an adjacency list `vector<vector<int>> adj`.
1. Maintain a boolean array `visited` of size $n + 1$.
2. Iterate $i$ from $1$ to $n$:
   - If city $i$ is not yet visited:
     - Record $i$ as a component representative: `reps.push_back(i)`.
     - Launch a BFS from $i$ to mark all cities in its component as visited.
3. The number of new roads needed is $k = \text{reps.size()} - 1$.
4. Print $k$, followed by edges `(reps[i], reps[i + 1])` for $0 \le i < k$.

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

    vector<bool> visited(n + 1, false);
    vector<int> representatives;

    // Find all connected components
    for (int i = 1; i <= n; ++i) {
        if (!visited[i]) {
            representatives.push_back(i);

            // BFS traversal of the component
            queue<int> q;
            q.push(i);
            visited[i] = true;

            while (!q.empty()) {
                int u = q.front();
                q.pop();

                for (int v : adj[u]) {
                    if (!visited[v]) {
                        visited[v] = true;
                        q.push(v);
                    }
                }
            }
        }
    }

    int k = (int)representatives.size() - 1;
    cout << k << '\n';

    // Connect adjacent component representatives
    for (int i = 0; i < k; ++i) {
        cout << representatives[i] << ' ' << representatives[i + 1] << '\n';
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$. Constructing the adjacency list takes $\mathcal{O}(n + m)$. Across all BFS runs, every vertex is visited once and every undirected edge is traversed twice ($2m$). Outputting the roads takes $\mathcal{O}(C) \le \mathcal{O}(n)$. Total runtime: $\approx 0.04\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ auxiliary space to store the adjacency list, `visited` array, and BFS queue ($\approx 10\text{ MB}$).
- **Optimality Guarantee**: Reading the graph requires $\Omega(n + m)$, making $\mathcal{O}(n + m)$ asymptotically optimal.

---

## 6. Correctness Proof

### Component Minimality Theorem
1. Let $G = (V, E)$ be a graph with $C$ connected components.
2. In any graph, adding an edge $(u, v)$ can decrease the number of connected components by at most $1$:
   - If $u$ and $v$ belong to the same component, the number of components remains unchanged.
   - If $u$ and $v$ belong to distinct components, those two components merge into one, reducing the count of components by exactly $1$.
3. Therefore, to reach $1$ connected component, at least $C - 1$ edges must be added.
4. Adding the $C - 1$ edges $(r_1, r_2), (r_2, r_3), \dots, (r_{C-1}, r_C)$ connects all components into a tree of components, producing a single connected graph.
5. Hence, $C - 1$ is both necessary and sufficient.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
4 2
1 2
3 4
```
$n = 4, m = 2$.
Edges: $(1, 2)$ and $(3, 4)$.

| Step | Vertex $i$ | `visited[i]`? | Action | Representatives Collected |
| :---: | :---: | :---: | :---: | :---: |
| **1** | 1 | False | Add `1` to reps. BFS marks $\{1, 2\}$ visited. | `[1]` |
| **2** | 2 | True | Skip | `[1]` |
| **3** | 3 | False | Add `3` to reps. BFS marks $\{3, 4\}$ visited. | `[1, 3]` |
| **4** | 4 | True | Skip | `[1, 3]` |

$C = 2$ components.  
New roads needed: $k = 2 - 1 = \mathbf{1}$.  
Road added: `1 3`.  
**Output**:  
`1`  
`1 3`  
(Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Already Connected ($C = 1$)**: Outputs `0` with no additional lines.
- **No Roads ($m = 0$)**: $n$ isolated vertices $\implies C = n$ components. Outputs $n - 1$ edges: `(1, 2), (2, 3), ..., (n-1, n)`.
- **$n = 1$**: Outputs `0`.
- **Multi-edges and Self-loops**: Adjacency list with BFS naturally handles multiple edges and self-loops without failure.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Star Graph Connection vs Chain Connection?**
   - Instead of chaining $(r_1, r_2), (r_2, r_3), \dots$, one can connect all components to a central hub $(r_1, r_2), (r_1, r_3), \dots, (r_1, r_C)$. Both are valid; star connections minimize the graph diameter.
2. **What if building road $(u, v)$ has cost $c(u, v)$?**
   - This becomes the **Minimum Spanning Tree (MST)** problem on the complete metric graph between components, solved using Kruskal's or Prim's algorithm.
3. **Dynamic Graph with Road Additions and Connectivity Queries?**
   - Use **Disjoint Set Union (DSU)** to maintain component counts in $\mathcal{O}(\alpha(n))$ time per addition (`CSES 1676: Road Construction`).
4. **Biconnected Components (2-Edge Connectivity)?**
   - If the network must remain connected after any single road failure, bridge detection (Tarjan's bridge algorithm) and leaf-block tree condensation are required.
5. **Connecting Components on a Grid?**
   - Solved with Multi-source BFS or Manhattan MST (Delaunay triangulation subset) in $\mathcal{O}(n \log n)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[graph-algorithms, connected-components, bfs, dsu]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - `CSES 1192` — [Counting Rooms](https://cses.fi/problemset/task/1192) (Connected components on grid).
  - `CSES 1676` — [Road Construction](https://cses.fi/problemset/task/1676) (Dynamic DSU component tracking).
  - `CSES 1675` — [Road Reparation](https://cses.fi/problemset/task/1675) (Kruskal's MST with edge weights).
