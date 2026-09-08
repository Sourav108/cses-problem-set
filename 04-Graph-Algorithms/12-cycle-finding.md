# Cycle Finding

- **Category**: Graph Algorithms
- **CSES Task ID**: `1197`
- **CSES Problem Link**: [Cycle Finding](https://cses.fi/problemset/task/1197)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a directed graph with $n$ vertices and $m$ edges. Each edge has an associated weight that can be positive, zero, or negative.

Your task is to determine whether the graph contains a **negative weight cycle** (a directed cycle whose sum of edge weights is strictly negative). If such a cycle exists, print `YES` followed by the sequence of vertices in the cycle (starting and ending at the same vertex). If no negative cycle exists, print `NO`.

### Input Format
- The first line contains two integers $n$ and $m$: the number of vertices and edges.
- The next $m$ lines each contain three integers $a$, $b$, and $c$: a directed edge from $a$ to $b$ with weight $c$.

### Output Format
- If a negative cycle exists:
  - Print `YES` on the first line.
  - Print the cycle on the second line (e.g., $v_1, v_2, \dots, v_k, v_1$).
- If no negative cycle exists:
  - Print `NO`.

### Numerical Constraints
- $1 \le n \le 2500$
- $1 \le m \le 5000$
- $1 \le a, b \le n$
- $-10^9 \le c \le 10^9$

With $V = 2500$ and $E = 5000$, Bellman-Ford cycle detection with parent trace executes in $\mathcal{O}(V \cdot E) \approx 1.25 \cdot 10^7$ operations $\approx 0.03\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the standard **Negative Weight Cycle Detection and Extraction** problem:
- **Global Reachability via 0-Distance Initialization**:
  A negative cycle could exist in any disconnected component. Rather than running Bellman-Ford from each vertex or adding an explicit virtual super-source $0$ connected to all vertices with weight $0$, we can simply initialize:
  $$\text{dist}[i] = 0 \quad \text{for all } i \in \{1, 2, \dots, n\}$$
  This simultaneously checks all connected components in a single pass.
- **Bellman-Ford Relaxation**:
  In a graph without negative cycles, the shortest simple path contains at most $n - 1$ edges. Thus, after $n - 1$ relaxation passes, all distances stabilize.
- **The $n$-th Relaxation & Cycle Entry**:
  If any edge $(u, v)$ can still be relaxed in the $n$-th pass, a negative cycle exists!
  However, the vertex $v$ updated in round $n$ is not necessarily part of the cycle itself; it may simply be reachable from the cycle.
- **The Pigeonhole Guarantee**:
  Because there are only $n$ distinct vertices in the graph, if we trace backwards along `parent` pointers $n$ times starting from $v$:
  $$\text{curr} \leftarrow \text{parent}[\text{curr}] \quad (\text{repeated } n \text{ times})$$
  By the Pigeonhole Principle, we are guaranteed to land on a vertex $x$ that is **strictly inside the negative cycle**.
- Tracing backwards from $x$ until $x$ is reached again extracts the exact cycle. Reversing the vertices gives the cycle in forward traversal order.

---

## 3. Approach 1 — Naive Cycle Enumeration (Floyd-Warshall / DFS)

Run Floyd-Warshall in $\mathcal{O}(n^3) \approx 1.56 \cdot 10^{10}$ operations or DFS cycle enumeration.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^3)$ for Floyd-Warshall or exponential for DFS.
- **CSES Verdict**: TLE immediately ($n = 2500$).

---

## 4. Approach 2 — SPFA with In-Queue Counters

Run SPFA (Shortest Path Faster Algorithm) tracking `cnt[u]`: the number of times vertex $u$ is pushed into the queue. If `cnt[u] >= n`, a negative cycle is detected.
- **Drawback**: SPFA is vulnerable to worst-case graphs where queue updates cascade, degrading to $\mathcal{O}(V \cdot E)$ with higher queue overhead. Tracing parent pointers can also encounter cycles before all updates finish.
- **Verdict**: Bellman-Ford is simpler, has deterministic runtime, and guarantees clean parent pointer structure.

---

## 5. Approach 3 — Optimal CSES Solution (Bellman-Ford with Back-Pointers)

1. Store edges in a flat list: `struct Edge { int u, v; long long w; }`.
2. Initialize `dist[1...n] = 0` and `parent[1...n] = 0`.
3. Run Bellman-Ford for $n$ rounds:
   - In each round, iterate over all $m$ edges:
     If $\text{dist}[u] + w < \text{dist}[v]$, update:
     $$\text{dist}[v] = \text{dist}[u] + w, \quad \text{parent}[v] = u$$
   - In round $n$, record the last updated vertex $x$.
4. If $x == -1$ (no edge relaxed in round $n$), no negative cycle exists $\implies$ output `NO`.
5. If $x \ne -1$:
   - Set $x \leftarrow \text{parent}[x]$ repeatedly $n$ times. Now $x$ is guaranteed to lie on the negative cycle.
   - Trace the cycle backwards: start at $x$, follow `parent` pointers, recording each vertex until $x$ is encountered again.
   - Reverse the sequence and output `YES` followed by the cycle path.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Edge {
    int u, v;
    long long w;
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<Edge> edges(m);
    for (int i = 0; i < m; ++i) {
        cin >> edges[i].u >> edges[i].v >> edges[i].w;
    }

    vector<long long> dist(n + 1, 0);
    vector<int> parent(n + 1, 0);
    int x = -1;

    for (int i = 1; i <= n; ++i) {
        x = -1;
        for (const auto& e : edges) {
            if (dist[e.u] + e.w < dist[e.v]) {
                dist[e.v] = dist[e.u] + e.w;
                parent[e.v] = e.u;
                x = e.v;
            }
        }
    }

    if (x == -1) {
        cout << "NO\n";
    } else {
        cout << "YES\n";
        // Walk back n times to guarantee entering the cycle
        for (int i = 0; i < n; ++i) {
            x = parent[x];
        }

        vector<int> cycle;
        for (int curr = x; ; curr = parent[curr]) {
            cycle.push_back(curr);
            if (curr == x && cycle.size() > 1) {
                break;
            }
        }
        reverse(cycle.begin(), cycle.end());

        for (size_t i = 0; i < cycle.size(); ++i) {
            cout << cycle[i] << (i + 1 == cycle.size() ? '\n' : ' ');
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot m)$.
  - $n$ relaxation rounds over $m$ edges: $2500 \times 5000 = 1.25 \cdot 10^7$ operations $\approx 0.03\text{s}$.
  - Tracing back $n$ steps: $\mathcal{O}(n)$.
  - Total time is $\mathcal{O}(n \cdot m)$, well within the 1.00s limit.
- **Space Complexity**: $\mathcal{O}(n + m)$ for the edge list, distance array, and parent array.

---

## 6. Correctness Proof

### The Pigeonhole Argument for Cycle Extraction
- **Lemma 1**: If an edge relaxes on the $n$-th iteration of Bellman-Ford, there exists a negative cycle reachable from the virtual source (i.e. anywhere in the graph).
  - *Proof*: By induction on $k$, after $k$ passes, $\text{dist}[v]$ is the minimum weight of a walk of length $\le k$ ending at $v$. If $\text{dist}[v]$ strictly decreases in pass $n$, there exists a walk of length $n$ that is strictly shorter than any walk of length $< n$. By the Pigeonhole Principle, any walk of length $n$ containing $n + 1$ vertices must visit some vertex twice, thus containing a cycle $C$. If the weight of $C$ were $\ge 0$, removing $C$ would yield a shorter or equal walk with fewer than $n$ edges, which would have already been achieved in an earlier round $< n$. Hence, $w(C) < 0$.
- **Lemma 2**: Let $x$ be the vertex relaxed in pass $n$. Following the parent pointers $n$ times ($x \leftarrow \text{parent}[x]$) places $x$ strictly inside the negative cycle.
  - *Proof*: The parent pointer $\text{parent}[v] = u$ indicates that the edge $(u, v)$ was the latest edge to reduce $\text{dist}[v]$. Tracing backwards $n$ steps follows the sequence of edge updates that caused the relaxation. In a graph with $n$ vertices, a backward path of $n$ edges must revisit at least one vertex. The cycle formed by this repetition must be negative, and because $n$ steps is at least the length of the longest simple path in the graph, tracing $n$ steps backwards guarantees that the pointer has entered the cycle.
- Reversing the backward trace yields the vertices in forward traversal order. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 5$:
- Edges: $(1, 2, 1)$, $(2, 3, 2)$, $(3, 1, -4)$, $(2, 4, 1)$, $(4, 1, 1)$
- Initial: `dist = [0, 0, 0, 0, 0]`, `parent = [0, 0, 0, 0, 0]`
- **Round 1**:
  - Edge $(3, 1, -4)$: `dist[1] = dist[3] - 4 = -4`, `parent[1] = 3`
- **Round 2**:
  - Edge $(1, 2, 1)$: `dist[2] = dist[1] + 1 = -3`, `parent[2] = 1`
- **Round 3**:
  - Edge $(2, 3, 2)$: `dist[3] = dist[2] + 2 = -1`, `parent[3] = 2`
- **Round 4 ($n = 4$)**:
  - Edge $(3, 1, -4)$: `dist[1] = dist[3] - 4 = -5 < -4`, `parent[1] = 3`, `x = 1`.
- **Extraction**:
  - Walk backwards $n=4$ times from $x = 1$:
    - $1 \to 3 \to 2 \to 1 \to 3 \implies x = 3$.
  - Trace cycle from $3$:
    - $3 \to \text{parent}[3]=2 \to \text{parent}[2]=1 \to \text{parent}[1]=3$ (stop).
    - Reverse $[3, 2, 1, 3] \implies [3, 1, 2, 3]$ (or cyclic shift $[1, 2, 3, 1]$).
  - Output: `YES`, followed by `3 1 2 3`. (Cycle sum: $-4 + 1 + 2 = -1 < 0$).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Disconnected Components**:
   Setting `dist[i] = 0` for all $1 \le i \le n$ ensures that Bellman-Ford searches for negative cycles across all connected components simultaneously without missing isolated subgraphs.
2. **Negative Self-Loops**:
   A directed edge $(u, u, -5)$ is a valid negative cycle of length 1. The code handles this cleanly: `cycle` outputs `u u`.
3. **Negative 2-Cycles**:
   Two opposite directed edges $(u \to v, -3)$ and $(v \to u, 1)$ form a negative 2-cycle with sum $-2$. Output is `u v u`.
4. **Distance Underflow / Overflow**:
   With edge weights up to $-10^9$ and $n = 2500$, distances after $n$ rounds can reach $-2.5 \cdot 10^{12}$. Using `long long` prevents arithmetic overflow.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Why does initializing `dist` with 0 work instead of using a virtual super-source?**
   Adding a virtual super-source $0$ with 0-weight edges to every vertex $1 \dots n$ would set `dist[i] = 0` after the first relaxation of the super-source edges anyway. Pre-initializing `dist[i] = 0` achieves the exact same effect without creating extra vertices or edges.
2. **Why must we step back $n$ times before extracting the cycle?**
   The vertex $v$ updated in pass $n$ might be a vertex downstream of the negative cycle (i.e. on a path leaving the cycle). Stepping back $n$ times guarantees that we have entered the cycle itself.
3. **Can we detect negative cycles in an undirected graph using Bellman-Ford?**
   In an undirected graph, any negative edge $(u, v, -w)$ with $w > 0$ forms a negative 2-cycle $u \leftrightarrow v$ of cost $-2w$. Hence, negative cycles in undirected graphs are either trivial (single negative edge) or can be found via Edmonds' Blossom algorithm with min-weight matching.
4. **How do we find the minimum mean-weight cycle in a directed graph?**
   Use **Karp's Algorithm**, which runs Bellman-Ford for $n+1$ passes and computes $\min_u \max_{0 \le k \le n-1} \frac{\text{dist}_{n}[u] - \text{dist}_k[u]}{n - k}$ in $\mathcal{O}(V \cdot E)$.
5. **What is the difference between this problem and CSES High Score?**
   CSES High Score requires the negative cycle to be on a path from source $1$ to target $n$. CSES Cycle Finding requires finding ANY negative cycle anywhere in the graph.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Bellman-Ford, Negative Cycle, Cycle Reconstruction, Pigeonhole Principle
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [High Score](https://cses.fi/problemset/task/1673) — Longest path / negative cycle on path to $n$
  - [Flight Discount](https://cses.fi/problemset/task/1195) — Layered Dijkstra
  - [Round Trip II](https://cses.fi/problemset/task/1678) — Directed cycle detection via 3-state DFS
