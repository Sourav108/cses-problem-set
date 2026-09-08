# Police Chase

- **Category**: Graph Algorithms
- **CSES Task ID**: `1695`
- **CSES Problem Link**: [Police Chase](https://cses.fi/problemset/task/1695)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Kaarle is a robber attempting to escape from the bank at **crossing 1** to his harbor hideout at **crossing $n$**. There are $n$ crossings and $m$ bidirectional streets connecting them.

The police want to set up roadblocks on a **minimum number of streets** such that there is no longer any route from crossing 1 to crossing $n$.

Your task is to find the minimum number of streets to block, and list which streets should be blocked. If there are multiple optimal solutions, you may output any of them.

### Input Format
- The first line contains two integers $n$ and $m$: the number of crossings and streets.
- The next $m$ lines each contain two integers $a$ and $b$: a bidirectional street between crossing $a$ and crossing $b$.

### Output Format
- On the first line, print an integer $k$: the minimum number of streets to block.
- On the next $k$ lines, print two integers $a$ and $b$: a street to be blocked.

### Numerical Constraints
- $2 \le n \le 500$
- $1 \le m \le 1000$
- $1 \le a, b \le n$

With $V \le 500$ and $E \le 1000$ and unit edge capacities, Dinic's Algorithm finds the min-cut in $\mathcal{O}(E \sqrt{V}) \approx 0.005\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the standard **Minimum $s$-$t$ Cut Problem** on an undirected, unweighted graph:
- By the **Max-Flow Min-Cut Theorem**:
  The minimum number of edges whose removal disconnects source $s = 1$ from sink $t = n$ is exactly equal to the **Maximum Flow** from $s$ to $t$ when each edge is assigned a capacity of $1$.
- **Modeling Undirected Edges in Flow Networks**:
  A bidirectional street between $u$ and $v$ with capacity $1$ allows flow in either direction. We can model this by adding:
  - Directed edge $u \to v$ with capacity $1$.
  - Directed edge $v \to u$ with capacity $1$.
- **Extracting the Minimum Cut $(S, T)$**:
  After running Dinic's algorithm to compute maximum flow:
  1. Launch a BFS/DFS from source $s = 1$ in the **residual graph** (traversing only edges with positive residual capacity: $\text{cap} - \text{flow} > 0$).
  2. The set of all reachable vertices forms the source component $S$.
  3. The remaining unreached vertices form the sink component $T = V \setminus S$.
  4. Any original undirected edge $(u, v)$ with one endpoint in $S$ and the other in $T$ ($u \in S, v \in T$) is fully saturated and crosses the cut.
  5. Blocking these $k$ edges completely disconnects $s$ from $t$ with the minimum number of roadblocks.

---

## 3. Approach 1 — Naive Edge Subset Enumeration

Enumerate subsets of edges of size $k = 1, 2, \dots$ and test connectivity using BFS.

### Complexity Analysis
- **Time Complexity**: $\binom{m}{k} \cdot \mathcal{O}(n + m)$, which is astronomical for $k \ge 4$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Edmonds-Karp Max Flow

Run Edmonds-Karp with unit capacities to find the min-cut.
- **Time Complexity**: $\mathcal{O}(V \cdot E^2)$.
- **Verdict**: Valid, but Dinic's algorithm (Approach 3) runs significantly faster on unit networks ($\mathcal{O}(E \sqrt{V})$).

---

## 5. Approach 3 — Optimal CSES Solution (Dinic's Algorithm + Residual Reachability)

1. Build flow network for $n$ vertices with source $s = 1$ and sink $t = n$.
2. For each street $(u, v)$, add bidirectional unit capacities:
   - Forward edge $u \to v$ with capacity $1$.
   - Backward edge $v \to u$ with capacity $1$.
   (Keep track of the original list of $m$ input edges).
3. Compute `dinic.max_flow()`.
4. Run BFS from $1$ in the residual graph:
   Mark `visited[u] = true` if reachable from $1$ via edges where `cap - flow > 0`.
5. For each original street $(u, v)$:
   - If `visited[u] != visited[v]`:
     The edge connects $S$ and $T$, meaning it is a cut edge.
     Store `{u, v}` in `cut_edges`.
6. Print `cut_edges.size()`, then each cut edge.

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

    void add_undirected_edge(int u, int v, int cap) {
        adj[u].push_back(edges.size());
        edges.push_back({u, v, cap, 0});
        adj[v].push_back(edges.size());
        edges.push_back({v, u, cap, 0}); // In undirected flow, reverse edge has cap = cap
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
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    Dinic dinic(n, 1, n);
    vector<pair<int, int>> original_edges;
    original_edges.reserve(m);

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        dinic.add_undirected_edge(u, v, 1);
        original_edges.push_back({u, v});
    }

    int min_cut_val = dinic.max_flow();

    // BFS in residual graph to find S component
    vector<bool> in_S(n + 1, false);
    queue<int> q;
    in_S[1] = true;
    q.push(1);

    while (!q.empty()) {
        int u = q.front();
        q.pop();

        for (int id : dinic.adj[u]) {
            const auto& edge = dinic.edges[id];
            if (edge.cap - edge.flow > 0 && !in_S[edge.v]) {
                in_S[edge.v] = true;
                q.push(edge.v);
            }
        }
    }

    vector<pair<int, int>> cut_edges;
    for (const auto& e : original_edges) {
        if (in_S[e.first] != in_S[e.second]) {
            cut_edges.push_back(e);
        }
    }

    cout << cut_edges.size() << '\n';
    for (const auto& e : cut_edges) {
        cout << e.first << ' ' << e.second << '\n';
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(E \sqrt{V})$.
  - Dinic's algorithm on unit-capacity networks operates in $\mathcal{O}(E \sqrt{V})$ time.
  - For $V = 500, E = 1000$: $1000 \times \sqrt{500} \approx 2.2 \cdot 10^4$ operations.
  - Residual BFS: $\mathcal{O}(n + m)$.
  - Total time: $< 0.005\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for flow network and original edge list ($\approx 1\text{ MB}$).

---

## 6. Correctness Proof

### The Max-Flow Min-Cut Theorem on Undirected Graphs
- **Cut Partition**:
  When Dinic finishes, no augmenting path exists from $s$ to $t$ in the residual graph $G_f$.
  Let $S$ be the set of vertices reachable from $s$ in $G_f$, and $T = V \setminus S$.
  Since $s \in S$ and $t \notin S$ ($t \in T$), $(S, T)$ forms an $s$-$t$ cut.
- **Saturated Boundary**:
  For any edge $e = (u, v)$ with $u \in S$ and $v \in T$, the residual capacity $c(e) - f(e)$ must be $0$, because otherwise $v$ would be reachable from $u$, contradicting $v \in T$.
  Since original capacity is $1$, each such edge carries $f(e) = 1$.
- **Minimality**:
  The total capacity of the cut is the number of edges crossing from $S$ to $T$.
  By the Max-Flow Min-Cut Theorem, the net flow across $(S, T)$ equals the total flow value, and the cut capacity achieves the minimum possible among all partitions separating $s$ and $t$.
  Removing these $k$ edges completely disconnects $s$ from $t$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 5$:
- Edges: $(1, 2), (1, 3), (2, 3), (2, 4), (3, 4)$
- Run Dinic:
  - Path $1 \to 2 \to 4$: flow 1.
  - Path $1 \to 3 \to 4$: flow 1.
  - Max flow $= 2$.
- Residual BFS from 1:
  - Edge $(1, 2)$ residual is 0.
  - Edge $(1, 3)$ residual is 0.
  - Only node 1 is reachable: $S = \{1\}$, $T = \{2, 3, 4\}$.
- Cross-edges:
  - $(1, 2)$ has $1 \in S, 2 \in T \implies$ Cut edge!
  - $(1, 3)$ has $1 \in S, 3 \in T \implies$ Cut edge!
  - Other edges have both endpoints in $T$.
- Output: $k = 2$, streets $(1, 2)$ and $(1, 3)$. Correct!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Bridge as a Min Cut**:
   If a single street is a bridge between the component of 1 and the component of $n$, max flow is 1, and that single edge is correctly identified.
2. **Multiple Parallel Streets**:
   If two parallel streets connect $u$ and $v$, each contributes 1 to flow and both must be cut if $(u, v)$ is the bottleneck. Dinic handles parallel edges automatically.
3. **Cut Direction Symmetry**:
   The condition `in_S[e.first] != in_S[e.second]` correctly captures cut edges regardless of whether the original input was ordered $(u, v)$ or $(v, u)$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How do you find the Global Minimum Cut (without fixed $s$ and $t$)?**
   Use **Stoer-Wagner Algorithm** in $\mathcal{O}(V \cdot E + V^2 \log V)$ or Karger's randomized contraction algorithm in $\mathcal{O}(V^2 \log^3 V)$.
2. **What is Menger's Theorem?**
   Menger's Theorem states that the maximum number of edge-disjoint paths between two vertices $s$ and $t$ equals the minimum number of edges whose removal disconnects $s$ and $t$. This is the discrete graph formulation of Max-Flow Min-Cut.
3. **What if we want to find a vertex cut instead of an edge cut?**
   Split each vertex $u$ into $u_{in}$ and $u_{out}$ with a directed edge of capacity 1. Then min-cut on the directed edges finds the minimum vertex cut.
4. **Is the minimum cut always unique?**
   No. Multiple distinct cuts can have the same minimum capacity. The BFS from $s$ produces the **minimal $S$ cut** (closest to source). A backward BFS from $t$ produces the **maximal $S$ cut** (closest to sink).
5. **How does this apply to computer vision and image segmentation?**
   Graph Cuts (Boykov-Kolmogorov) segments foreground from background by setting pixel-to-pixel similarity as edge capacities and solving the min-cut.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Network Flow, Minimum Cut, Max-Flow Min-Cut Theorem, Dinic's Algorithm
- **Complexity Summary**:
  - Time: $\mathcal{O}(E \sqrt{V})$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Download Speed](https://cses.fi/problemset/task/1694) — Standard Maximum Flow
  - [School Dance](https://cses.fi/problemset/task/1696) — Maximum Bipartite Matching
  - [Distinct Routes](https://cses.fi/problemset/task/1711) — Edge-disjoint paths via Flow
