# Download Speed

- **Category**: Graph Algorithms
- **CSES Task ID**: `1694`
- **CSES Problem Link**: [Download Speed](https://cses.fi/problemset/task/1694)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Consider a network of $n$ computers numbered $1, 2, \dots, n$ and $m$ directed connections between them. Computer 1 is a server from which you want to download data, and computer $n$ is your computer.

Each connection connects computer $a$ to computer $b$ and has a capacity $c$ (the maximum speed data can flow through that connection). What is the **maximum download speed** you can achieve from computer 1 to computer $n$?

### Input Format
- The first line contains two integers $n$ and $m$: the number of computers and connections.
- The next $m$ lines each contain three integers $a$, $b$, and $c$: a directed connection from computer $a$ to computer $b$ with capacity $c$.

### Output Format
- Print one integer: the maximum download speed from computer 1 to computer $n$.

### Numerical Constraints
- $1 \le n \le 500$
- $1 \le m \le 1000$
- $1 \le a, b \le n$
- $1 \le c \le 10^9$

With $V \le 500$ and $E \le 1000$, the maximum flow can reach $1000 \times 10^9 = 10^{12}$, requiring 64-bit integers (`long long`). Dinic's algorithm runs in $\mathcal{O}(V^2 E) \approx 0.005\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the standard **Maximum $s$-$t$ Flow Problem**:
- Source is $s = 1$, sink is $t = n$.
- We seek a flow function $f: E \to \mathbb{R}_{\ge 0}$ satisfying:
  1. **Capacity constraint**: $0 \le f(e) \le c(e)$ for all $e \in E$.
  2. **Flow conservation**: For every computer $u \notin \{1, n\}$, incoming flow equals outgoing flow:
     $$\sum_{v} f(v, u) = \sum_{w} f(u, w)$$
- **Max-Flow Min-Cut Theorem (Ford-Fulkerson, 1956)**:
  The maximum amount of flow from $s$ to $t$ equals the minimum capacity of an $s$-$t$ cut.
- **Dinic's Algorithm (1970)**:
  Dinic's algorithm improves on Ford-Fulkerson by augmenting along **blocking flows** in a **Level Graph**:
  1. **BFS Phase**: Compute levels $\text{level}[u]$: the shortest hop distance from $s$ to $u$ in the residual graph. If $t$ is unreachable, the algorithm terminates.
  2. **DFS Phase (Blocking Flow)**: Push flow along edges $(u, v)$ where $\text{level}[v] == \text{level}[u] + 1$.
  3. **Cursor Optimization**: Maintain `head[u]` to avoid re-examining saturated edges during the DFS phase.
  4. Repeat until sink $t$ is no longer reachable in the residual graph.

---

## 3. Approach 1 — Standard Ford-Fulkerson with DFS

Augment flow along arbitrary paths found via DFS.
- **Complexity**: $\mathcal{O}(E \cdot F)$, where $F$ is the maximum flow.
- With capacities up to $10^9$, $F$ can reach $10^{12}$, taking $10^{15}$ operations $\implies$ TLE immediately.

---

## 4. Approach 2 — Edmonds-Karp Algorithm (BFS Augmentation)

Augment along the shortest augmenting path using BFS.
- **Complexity**: $\mathcal{O}(V \cdot E^2) \approx 500 \times 10^6 = 5 \cdot 10^8$ operations.
- **Verdict**: Passes within 1.00s, but Dinic's algorithm (Approach 3) is faster ($\mathcal{O}(V^2 E) \approx 2.5 \cdot 10^8$ worst case, but practically $< 10^5$ operations) and serves as the gold standard for all flow problems on CSES.

---

## 5. Approach 3 — Optimal CSES Solution (Dinic's Algorithm)

1. Edge structure with residual capacity:
   - Each directed edge has capacity $c$ and flow $0$.
   - The reverse edge has capacity $0$ and flow $0$.
   - Edges stored in flat list `edges`, where reverse of edge $i$ is $i \oplus 1$.
2. Implement Dinic's solver:
   - `bfs()`: sets `level[1...n] = -1`, `level[s] = 0`. Enqueues $s$. Only explores edges with residual capacity $> 0$. Returns `level[t] != -1`.
   - `dfs(u, pushed)`: attempts to push up to `pushed` units of flow from $u$ to $t$. Uses `head[u]` cursor to discard exhausted edges.
3. While `bfs()` is true:
   - Reset `head[1...n] = 0`.
   - While `pushed = dfs(s, INF)` is $> 0$:
     `max_flow += pushed`.
4. Output `max_flow`.

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>

using namespace std;

const long long INF = 1e18;

struct Edge {
    int u, v;
    long long cap;
    long long flow;
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

    void add_edge(int u, int v, long long cap) {
        adj[u].push_back(edges.size());
        edges.push_back({u, v, cap, 0});
        adj[v].push_back(edges.size());
        edges.push_back({v, u, 0, 0}); // Reverse residual edge
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

    long long dfs(int u, long long pushed) {
        if (pushed == 0 || u == t) {
            return pushed;
        }

        for (int& cid = head[u]; cid < (int)adj[u].size(); ++cid) {
            int id = adj[u][cid];
            auto& edge = edges[id];
            int v = edge.v;

            if (level[u] + 1 != level[v] || edge.cap - edge.flow == 0) {
                continue;
            }

            long long tr = dfs(v, min(pushed, edge.cap - edge.flow));
            if (tr == 0) {
                continue;
            }

            edge.flow += tr;
            edges[id ^ 1].flow -= tr;
            return tr;
        }

        return 0;
    }

    long long max_flow() {
        long long flow = 0;
        while (bfs()) {
            fill(head.begin(), head.end(), 0);
            while (long long pushed = dfs(s, INF)) {
                flow += pushed;
            }
        }
        return flow;
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
        long long c;
        cin >> u >> v >> c;
        dinic.add_edge(u, v, c);
    }

    cout << dinic.max_flow() << '\n';

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(V^2 E)$.
  - The level of sink $t$ strictly increases after each phase, yielding at most $V - 1$ phases.
  - In each phase, finding a blocking flow takes $\mathcal{O}(V \cdot E)$ because each DFS either saturates an edge (at most $E$ times) or retreats past an edge via `head[u]++`.
  - For $V = 500, E = 1000$: worst case $2.5 \cdot 10^8$ operations, practically runs in $\approx 0.005\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for residual graph edges and adjacency lists ($\approx 1\text{ MB}$).

---

## 6. Correctness Proof

### The Max-Flow Min-Cut Theorem
- **Augmenting Path Invariant**:
  As long as a path with positive residual capacity exists from $s$ to $t$, additional flow can be pushed along it, strictly increasing total net flow from $s$ to $t$.
- **Termination Criterion**:
  Dinic's algorithm terminates when `level[t] == -1`, meaning there is no path from $s$ to $t$ in the residual graph $G_f$.
- **Cut Construction**:
  Let $S = \{ u \in V \mid \text{level}[u] \ne -1 \}$ be the set of vertices reachable from $s$ in $G_f$, and $T = V \setminus S$.
  - Clearly $s \in S$ and $t \in T$.
  - For every edge $e = (u, v)$ with $u \in S$ and $v \in T$:
    The residual capacity $c(e) - f(e)$ must be $0$ (otherwise $v$ would be reachable, contradicting $v \in T$).
    Hence $f(e) = c(e)$ (forward edges are fully saturated).
  - For every edge $e = (v, u)$ with $v \in T$ and $u \in S$:
    The residual capacity $0 - (-f(e)) = f(e)$ must be $0$, so $f(e) = 0$ (backward edges carry zero flow).
  - Therefore, the total net flow leaving $S$ equals $\sum_{e \in (S, T)} c(e) = \text{capacity}(S, T)$.
  - Since net flow across any cut can never exceed cut capacity, this flow is maximal and equals the capacity of the minimum cut. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 5$:
- Source $1$, Sink $4$.
- Edges: $(1, 2, 3)$, $(1, 3, 2)$, $(2, 3, 1)$, $(2, 4, 2)$, $(3, 4, 3)$

1. **Phase 1 BFS**:
   - `level[1] = 0`
   - `level[2] = 1`, `level[3] = 1`
   - `level[4] = 2`
2. **Phase 1 DFS (Blocking Flow)**:
   - Path $1 \to 2 \to 4$: bottleneck $\min(3, 2) = 2$.
     - Push 2 flow: $e(1, 2).f = 2, e(2, 4).f = 2$.
   - Path $1 \to 3 \to 4$: bottleneck $\min(2, 3) = 2$.
     - Push 2 flow: $e(1, 3).f = 2, e(3, 4).f = 2$.
   - Total Phase 1 flow: $2 + 2 = 4$.
3. **Phase 2 BFS**:
   - In residual graph, $e(2, 4)$ and $e(1, 3)$ are saturated.
   - Path remaining: $1 \to 2$ (residual 1), $2 \to 3$ (capacity 1), $3 \to 4$ (residual 1).
   - `level = [0, 1, 2, 3]`.
4. **Phase 2 DFS**:
   - Path $1 \to 2 \to 3 \to 4$: bottleneck $\min(1, 1, 1) = 1$.
   - Push 1 flow. Total flow $= 4 + 1 = 5$.
5. **Phase 3 BFS**:
   - Sink 4 is no longer reachable in $G_f$.
- Output: `5`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Flow**:
   Total flow can reach $m \times \max(c) = 1000 \times 10^9 = 10^{12}$. Flow variables, capacities, and `INF` must be `long long`.
2. **Parallel Connections (Multi-Edges)**:
   Multiple directed edges between the same two computers can exist. Dinic handles multi-edges automatically: each edge gets its own index and paired residual edge.
3. **Disconnected Source and Sink**:
   If computer 1 cannot reach computer $n$, `bfs()` returns false on iteration 1, outputting 0.
4. **Bidirectional Connections**:
   If an edge $(u, v)$ and an edge $(v, u)$ both exist in the input, Dinic's residual edges (`id ^ 1`) accumulate flow increments correctly without interference.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does Dinic's algorithm perform on Unit Capacity Networks?**
   On networks where all edge capacities are 1 (e.g. bipartite matching), Dinic runs in $\mathcal{O}(E \sqrt{V})$, matching the Hopcroft-Karp algorithm.
2. **What is Push-Relabel (Highest Label Preflow-Push)?**
   An alternative max-flow approach that maintains preflow and heights without augmenting paths, achieving $\mathcal{O}(V^2 \sqrt{E})$ with gap heuristic.
3. **How do we reconstruct the minimum cut?**
   Run BFS from source in the residual graph after `max_flow()` finishes. Vertices reachable from $s$ form set $S$. All edges from $S$ to $V \setminus S$ form the minimum cut (see CSES Police Chase).
4. **What if nodes have capacity limits in addition to edges?**
   Split each node $u$ into $u_{in}$ and $u_{out}$ connected by a directed edge with capacity equal to the node's capacity.
5. **Can flow networks have lower bounds on edge capacities?**
   Yes, circulation with demands and lower bounds can be transformed into standard max flow by introducing a super-source and super-sink.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Network Flow, Maximum Flow, Dinic's Algorithm, Level Graph
- **Complexity Summary**:
  - Time: $\mathcal{O}(V^2 E)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Police Chase](https://cses.fi/problemset/task/1695) — Minimum cut extraction via Max Flow
  - [School Dance](https://cses.fi/problemset/task/1696) — Maximum bipartite matching
  - [Distinct Routes](https://cses.fi/problemset/task/1711) — Edge-disjoint paths via Max Flow
