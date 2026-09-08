# Distinct Routes

- **Category**: Graph Algorithms
- **CSES Task ID**: `1711`
- **CSES Problem Link**: [Distinct Routes](https://cses.fi/problemset/task/1711)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

A game has $n$ rooms and $m$ directed teleporters between them. Room 1 is the starting room, and room $n$ is the destination room.

Your task is to find the **maximum number of edge-disjoint paths** from room 1 to room $n$ (paths that do not share any teleporters), and output the exact sequence of rooms for each path. If there are multiple optimal collections of paths, you may print any of them.

### Input Format
- The first line contains two integers $n$ and $m$: the number of rooms and teleporters.
- The next $m$ lines each contain two integers $a$ and $b$: a directed teleporter from room $a$ to room $b$.

### Output Format
- First line: an integer $k$, the maximum number of edge-disjoint routes.
- Then, for each of the $k$ routes:
  - Print the number of rooms on the route.
  - Print the sequence of rooms in order, starting at 1 and ending at $n$.

### Numerical Constraints
- $2 \le n \le 500$
- $1 \le m \le 1000$
- $1 \le a, b \le n$

With $V \le 500$ and $E \le 1000$ on a unit capacity network, Dinic's Algorithm and path decomposition execute in $\mathcal{O}(E \sqrt{V}) \approx 0.005\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the standard **Edge-Disjoint Paths Problem** on a directed graph:
- **Menger's Theorem (Directed Version, 1927)**:
  The maximum number of mutually edge-disjoint directed paths from source $s$ to sink $t$ is equal to the minimum number of edges whose deletion destroys all paths from $s$ to $t$.
- **Reduction to Maximum Flow**:
  Assign every directed teleporter a capacity of $1$:
  $$\text{cap}(u, v) = 1$$
  Any valid integer flow of value $k$ on this unit network decomposes into exactly $k$ unit-flow paths from $1$ to $n$. Because capacities are 1, each edge can carry at most 1 unit of flow, guaranteeing that no edge is shared between any two paths!
- **Path Extraction via Flow Cancellation**:
  After running Dinic's algorithm:
  - Exactly $k$ units of flow leave source 1 and arrive at sink $n$.
  - We extract the $k$ paths one by one using a simple DFS:
    1. Start at room 1.
    2. At room $u$, find an outgoing edge $(u \to v)$ that has $\text{flow} == 1$.
    3. Cancel the flow on this edge ($\text{flow} = 0$) so that subsequent paths cannot reuse it.
    4. Move to $v$ and repeat until reaching $n$.
  - Each path is guaranteed to terminate at $n$ without cycles.

---

## 3. Approach 1 — Naive Greedy BFS Path Finding

Find paths from 1 to $n$ via BFS, remove the edges, and repeat.
- **Flaw**: Greedy choices can choose edges that block multiple other paths, resulting in sub-optimal counts (e.g. finding 1 path when 2 disjoint paths exist). Max Flow with residual edges allows pushing back flow to find the global optimum.

---

## 4. Approach 2 — Edmonds-Karp Max Flow + DFS Extraction

Augment unit paths using BFS, then extract paths with DFS.
- **Complexity**: $\mathcal{O}(V \cdot E^2)$.
- **Verdict**: Optimal, but Dinic's algorithm (Approach 3) is faster on unit networks ($\mathcal{O}(E \sqrt{V})$) and uses the standardized flow template.

---

## 5. Approach 3 — Optimal CSES Solution (Dinic's Algorithm + Flow Decomposition)

1. Build a flow network with $n$ vertices, source $s = 1$, sink $t = n$.
2. For each teleporter $a \to b$, add a directed edge with capacity $1$ (and reverse edge with capacity $0$).
3. Compute $k = \text{dinic.max\_flow}()$.
4. Print $k$.
5. For each of the $k$ paths:
   - Start at vertex 1. Maintain vector `path`.
   - Repeatedly walk to the next room along an edge with `edge.flow == 1`.
   - Once traversed, set `edge.flow = 0` (consume the flow).
   - Stop when reaching $n$.
   - Print `path.size()` and the sequence of rooms.

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>

using namespace std;

const int INF = 1e9;

struct Edge {
    int u, v;
    int cap;
    int flow;
};

struct Dinic {
    int n, s, t;
    vector<Edge> edges;
    vector<vector<int>> adj;
    vector<int> level;
    vector<int> head;

    Dinic(int n, int s, int t) : n(n), s(s), t(t) {
        adj.resize(n + 1);
        level.resize(n + 1);
        head.resize(n + 1);
    }

    void add_edge(int u, int v, int cap) {
        adj[u].push_back(edges.size());
        edges.push_back({u, v, cap, 0});
        adj[v].push_back(edges.size());
        edges.push_back({v, u, 0, 0}); // Reverse edge
    }

    bool bfs() {
        fill(level.begin(), level.end(), -1);
        level[s] = 0;
        queue<int> q;
        q.push(s);

        while (!q.empty()) {
            int u = q.front();
            q.pop();

            for (int id : adj[u]) {
                const auto& edge = edges[id];
                if (edge.cap - edge.flow > 0 && level[edge.v] == -1) {
                    level[edge.v] = level[u] + 1;
                    q.push(edge.v);
                }
            }
        }

        return level[t] != -1;
    }

    int dfs(int u, int pushed) {
        if (pushed == 0 || u == t) return pushed;

        for (int& cid = head[u]; cid < (int)adj[u].size(); ++cid) {
            int id = adj[u][cid];
            auto& edge = edges[id];
            int v = edge.v;

            if (level[u] + 1 != level[v] || edge.cap - edge.flow == 0) continue;

            int tr = dfs(v, min(pushed, edge.cap - edge.flow));
            if (tr == 0) continue;

            edge.flow += tr;
            edges[id ^ 1].flow -= tr;
            return tr;
        }

        return 0;
    }

    int max_flow() {
        int flow = 0;
        while (bfs()) {
            fill(head.begin(), head.end(), 0);
            while (int pushed = dfs(s, INF)) {
                flow += pushed;
            }
        }
        return flow;
    }

    void extract_paths(int k) {
        for (int p = 0; p < k; ++p) {
            vector<int> path;
            int curr = s;
            path.push_back(curr);

            while (curr != t) {
                for (int id : adj[curr]) {
                    // Only follow original forward edges that have positive flow
                    if (id % 2 == 0 && edges[id].flow == 1) {
                        edges[id].flow = 0; // Consume the edge
                        curr = edges[id].v;
                        path.push_back(curr);
                        break;
                    }
                }
            }

            cout << path.size() << '\n';
            for (size_t i = 0; i < path.size(); ++i) {
                cout << path[i] << (i + 1 == path.size() ? '\n' : ' ');
            }
        }
    }
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    Dinic dinic(n, 1, n);

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        dinic.add_edge(u, v, 1);
    }

    int k = dinic.max_flow();
    cout << k << '\n';
    dinic.extract_paths(k);

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(E \sqrt{V} + k \cdot V)$.
  - Dinic on unit networks: $\mathcal{O}(E \sqrt{V}) \approx 1000 \times \sqrt{500} \approx 2.2 \cdot 10^4$ operations.
  - Path extraction: each of the $k \le m$ paths has length $\le n$. Total extraction time: $\mathcal{O}(k \cdot n) \le 1000 \times 500 = 5 \cdot 10^5$ operations.
  - Total time: $< 0.005\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for the flow network and path buffers ($\approx 1\text{ MB}$).

---

## 6. Correctness Proof

### Flow Decomposition Theorem
- **Theorem**: Any non-negative circulation or $s$-$t$ flow on a directed graph can be decomposed into at most $E$ simple paths and cycles.
- **Edge Disjointness on Unit Networks**:
  1. Each forward edge $e$ has integer capacity $c(e) = 1$. By the integrality theorem of Network Flow, the maximum flow computed is integral: $f(e) \in \{0, 1\}$.
  2. Because $f(e) \le 1$, at most one unit of flow passes through each directed edge.
  3. Flow conservation at all intermediate nodes ensures that whenever an edge enters $u$ with flow 1, there exists an outgoing edge from $u$ with flow 1.
  4. By following edges with $f(e) = 1$ from $s = 1$, we are guaranteed to reach $t = n$.
  5. Zeroing the flow along the extracted path removes 1 unit of flow, preserving flow conservation for remaining flow paths.
  6. Since each edge is chosen at most once and flow is zeroed immediately, the extracted paths are strictly edge-disjoint. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 5$:
- Edges: $(1, 2), (1, 3), (2, 3), (2, 4), (3, 4)$
- Capacities: 1 for all edges.
- Dinic Max Flow:
  - Path 1: $1 \to 2 \to 4$ (flow 1)
  - Path 2: $1 \to 3 \to 4$ (flow 1)
  - Total flow $k = 2$.
- Path Extraction:
  - Route 1: from 1, follow $(1, 2) \to (2, 4)$. Set flow to 0. Path: `1 2 4`.
  - Route 2: from 1, follow $(1, 3) \to (3, 4)$. Set flow to 0. Path: `1 3 4`.
- Output:
  ```
  2
  3
  1 2 4
  3
  1 3 4
  ```
  Edge-disjoint and valid!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Cycles of Flow**:
   Dinic augments along shortest paths in the level graph, which avoids creating useless cycles of flow. If flow cancellation left a cycle, simple DFS loop avoidance could be used, but level graph augmentation guarantees acyclic flow decompositions.
2. **Forward vs Reverse Edges in Extraction**:
   In Dinic, edge IDs are even for original forward edges and odd for reverse residual edges (`id % 2 == 0`). Checking `id % 2 == 0` ensures path extraction only follows original input teleporters.
3. **Zero Paths Reachable**:
   If 1 cannot reach $n$, `k = 0`. Output is 0, no paths printed.
4. **Multiple Edges between Same Pair**:
   Multiple identical edges each get capacity 1 and can be used in separate paths.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the problem asked for VERTEX-DISJOINT paths instead of edge-disjoint?**
   Split each internal vertex $u \in \{2, \dots, n-1\}$ into two vertices $u_{in}$ and $u_{out}$ connected by a directed edge $u_{in} \to u_{out}$ with capacity 1.
2. **How does this connect to Dilworth's Theorem?**
   In a DAG, the minimum number of path covers equals the size of the maximum antichain. Vertex-disjoint path cover on a DAG can be solved via bipartite matching.
3. **What if we want the $k$ edge-disjoint paths that minimize total route length?**
   Use **Minimum-Cost Maximum-Flow (MCMF)** with edge costs equal to edge lengths.
4. **How do you find the maximum number of edge-disjoint paths in an UNDIRECTED graph?**
   Add bidirectional unit capacities. Dinic handles undirected capacity graphs identically.
5. **How does Suurballe's Algorithm work for $k = 2$?**
   Suurballe's algorithm finds two edge-disjoint paths of minimum total length using two passes of Dijkstra with edge reweighting in $\mathcal{O}(m + n \log n)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Network Flow, Edge-Disjoint Paths, Dinic's Algorithm, Flow Decomposition
- **Complexity Summary**:
  - Time: $\mathcal{O}(E \sqrt{V} + k \cdot V)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Download Speed](https://cses.fi/problemset/task/1694) — Standard Maximum Flow
  - [Police Chase](https://cses.fi/problemset/task/1695) — Minimum Cut via Max Flow
  - [School Dance](https://cses.fi/problemset/task/1696) — Maximum Bipartite Matching
