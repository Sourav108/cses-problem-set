# Shortest Routes I

- **Category**: Graph Algorithms
- **CSES Task ID**: `1671`
- **CSES Problem Link**: [Shortest Routes I](https://cses.fi/problemset/task/1671)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ cities and $m$ flight connections between them. Each flight connection is directed from a city $a$ to a city $b$ and has an associated length $c$.

Your task is to determine the length of the shortest route from **city 1** to every city $1, 2, \dots, n$.

### Input Format
- The first line contains two integers $n$ and $m$: the number of cities and flight connections.
- The next $m$ lines each contain three integers $a$, $b$, and $c$: a directed flight connection from city $a$ to city $b$ of length $c$.

### Output Format
- Print $n$ integers: the shortest route lengths from city 1 to cities $1, 2, \dots, n$. (The distance from city 1 to itself is $0$).

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$
- $1 \le c \le 10^9$

With $V = 10^5$ and $E = 2 \cdot 10^5$ and edge weights up to $10^9$, paths can reach $10^{14}$, requiring 64-bit arithmetic (`long long`). Dijkstra's algorithm runs in $\mathcal{O}((n + m) \log n) \approx 0.10\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the canonical **Single-Source Shortest Path (SSSP)** problem on a directed graph with **non-negative edge weights**:
- Because all edge weights $c \ge 1$ are strictly positive, **Dijkstra's Algorithm** is provably optimal.
- **Greedy Principle**:
  At each step, among all unexplored boundary vertices, the vertex $u$ with the minimum tentative distance $\text{dist}[u]$ has already achieved its final, true shortest distance. No alternate path through other unvisited vertices could possibly be shorter, because extending any longer path by positive weights will only increase the total distance.
- **Min-Heap Implementation**:
  Using a binary min-heap (`std::priority_queue` with `greater`), we extract the vertex with minimal distance in $\mathcal{O}(\log V)$, relax its outgoing edges, and push updated distances into the heap in $\mathcal{O}(\log V)$.

---

## 3. Approach 1 — Naive Dijkstra ($\mathcal{O}(V^2)$ Array Scan)

Maintain an array of tentative distances and a boolean `visited` array. In each of the $n$ iterations, perform a linear scan over all $n$ vertices to find the unvisited vertex with minimum tentative distance.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(V^2 + E) = \mathcal{O}(n^2) \approx 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n + m)$.
- **CSES Verdict**: TLE (Time Limit Exceeded).

---

## 4. Approach 2 — SPFA / Bellman-Ford

Maintain a queue of vertices whose distances have been updated (Shortest Path Faster Algorithm). While SPFA can be fast on average, on directed graphs with positive weights it exhibits worst-case $\mathcal{O}(V \cdot E) \approx 2 \cdot 10^{10}$ operations.

### Complexity Analysis
- **Time Complexity**: Worst-case $\mathcal{O}(n \cdot m)$.
- **CSES Verdict**: TLE on adversarial test cases.

---

## 5. Approach 3 — Optimal CSES Solution (Dijkstra with Min-Priority Queue)

1. Represent the graph using an adjacency list of pairs: `adj[u]` contains `{v, weight}`.
2. Initialize `dist[1...n] = INF` ($10^{18}$), and set $\text{dist}[1] = 0$.
3. Maintain a min-priority queue storing `{distance, vertex}`:
   `priority_queue<pair<long long, int>, vector<pair<long long, int>>, greater<pair<long long, int>>> pq;`
4. Push `{0, 1}` into the heap.
5. While the heap is non-empty:
   - Extract the top element: `{d, u}`.
   - **Lazy Deletion / Stale Check**: If $d > \text{dist}[u]$, this entry is outdated (a shorter path to $u$ was already processed); discard and `continue`.
   - For each outgoing edge $(u \to v, w)$:
     - If $\text{dist}[u] + w < \text{dist}[v]$:
       - Update $\text{dist}[v] = \text{dist}[u] + w$.
       - Push $\{\text{dist}[v], v\}$ into the heap.
6. Print $\text{dist}[1], \dots, \text{dist}[n]$.

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

const long long INF = 1e18; // 10^18 comfortably avoids 64-bit overflow

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<vector<pair<int, int>>> adj(n + 1);
    for (int i = 0; i < m; ++i) {
        int u, v, w;
        cin >> u >> v >> w;
        adj[u].push_back({v, w});
    }

    vector<long long> dist(n + 1, INF);
    priority_queue<pair<long long, int>, vector<pair<long long, int>>, greater<pair<long long, int>>> pq;

    dist[1] = 0;
    pq.push({0, 1});

    while (!pq.empty()) {
        auto [d, u] = pq.top();
        pq.pop();

        if (d > dist[u]) continue; // Stale heap entry

        for (auto& edge : adj[u]) {
            int v = edge.first;
            long long weight = edge.second;

            if (dist[u] + weight < dist[v]) {
                dist[v] = dist[u] + weight;
                pq.push({dist[v], v});
            }
        }
    }

    for (int i = 1; i <= n; ++i) {
        cout << dist[i] << (i == n ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}((n + m) \log n)$.
  - Each edge produces at most one insertion into the priority queue, yielding at most $m$ pushes.
  - Heap extraction takes $\mathcal{O}(\log m) = \mathcal{O}(\log n)$ per element.
- **Space Complexity**: $\mathcal{O}(n + m)$ for adjacency list and distance array.

---

## 6. Correctness Proof

### Invariant & Induction on Non-Negative Weights
- **Inductive Hypothesis**: When a vertex $u$ is popped from the priority queue with distance $d = \text{dist}[u]$ for the first time, $d$ is the exact shortest path distance from the source $1$ to $u$: $\delta(1, u) = \text{dist}[u]$.
- **Base Case**: At initialization, vertex $1$ is popped with distance $0$. Since all edge weights are $c \ge 1$, no path from $1$ back to $1$ can have negative cost, so $\delta(1, 1) = 0$.
- **Inductive Step**:
  1. Suppose the hypothesis holds for all previously finalized vertices set $S$.
  2. Let $u \notin S$ be the vertex with the minimum tentative distance $\text{dist}[u]$ among all vertices not in $S$.
  3. Assume for contradiction that there exists a shorter path $P$ from $1$ to $u$ such that $\text{weight}(P) < \text{dist}[u]$.
  4. Since $1 \in S$ and $u \notin S$, path $P$ must leave $S$ at some edge $(x, y)$, where $x \in S$ and $y \notin S$.
  5. By the inductive hypothesis, $\text{dist}[x] = \delta(1, x)$. When $x$ was finalized, edge $(x, y)$ was relaxed, ensuring $\text{dist}[y] \le \text{dist}[x] + w(x, y) \le \text{weight}(P)$.
  6. Because all edge weights along $P$ are non-negative, $\text{weight}(P) \ge \text{dist}[y]$.
  7. However, the min-heap selected $u$ over $y$, which means $\text{dist}[u] \le \text{dist}[y]$.
  8. Therefore, $\text{dist}[u] \le \text{dist}[y] \le \text{weight}(P) < \text{dist}[u]$, a direct contradiction!
  9. Thus, $\text{dist}[u] = \delta(1, u)$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 3, m = 4$:
- Edges: $(1, 2, 6)$, $(1, 3, 2)$, $(3, 2, 3)$, $(1, 3, 4)$

1. **Initialization**:
   - `dist = [INF, 0, INF, INF]`
   - `pq = {(0, 1)}`
2. **Pop (0, 1)**:
   - Relax $(1, 2, 6)$: `dist[2] = 6`, push `{6, 2}`.
   - Relax $(1, 3, 2)$: `dist[3] = 2`, push `{2, 3}`.
   - Relax $(1, 3, 4)$: $0 + 4 = 4 > \text{dist}[3]$ (no change).
3. **Pop (2, 3)** (smallest in heap):
   - Relax $(3, 2, 3)$: $\text{dist}[3] + 3 = 2 + 3 = 5 < \text{dist}[2]$ ($6$).
   - Update `dist[2] = 5`, push `{5, 2}`.
4. **Pop (5, 2)**:
   - Node 2 has no outgoing edges.
5. **Pop (6, 2)**:
   - $6 > \text{dist}[2]$ ($5$) $\implies$ stale entry! Ignored by `continue`.
6. Output: `0 5 2`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow**:
   With $n = 10^5$ and max edge weight $10^9$, the total path distance can reach $10^{14}$, which exceeds signed 32-bit `int` ($\approx 2.14 \times 10^9$). Using `long long` for distances and `INF = 1e18` is strictly required.
2. **Multi-edges and Self-loops**:
   Multiple flight connections may exist between the same pair of cities. Dijkstra handles parallel edges and self-loops naturally: the min-heap always prioritizes the cheapest edge.
3. **Disconnected Vertices**:
   The problem statement guarantees that city 1 can reach all other cities in the test data. If an unreachable vertex existed, `dist[v]` would remain `INF`.
4. **Stale Priority Queue Entries**:
   Without the check `if (d > dist[u]) continue;`, the time complexity can degrade because vertices would process outdated edge relaxations repeatedly.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Why cannot Dijkstra handle negative edge weights?**
   The greedy choice property relies on edge weights being non-negative. If negative edges exist, popping the minimum distance node no longer guarantees that its distance is final; a path with negative edges explored later could reduce it further.
2. **How does Dijkstra with Fibonacci Heap compare to Binary Heap?**
   A Fibonacci heap offers $\mathcal{O}(1)$ amortized `decrease-key`, lowering theoretical complexity to $\mathcal{O}(E + V \log V)$. However, due to large hidden constant factors, `std::priority_queue` (binary heap) is significantly faster in practice.
3. **How do we reconstruct the actual shortest paths?**
   Maintain a `parent` array: whenever $\text{dist}[u] + w < \text{dist}[v]$, set $\text{parent}[v] = u$. Backtrack from target to source.
4. **What if edge weights are only 0 or 1?**
   Use **0-1 BFS** with a `std::deque`: push 0-weight relaxations to the front and 1-weight relaxations to the back in $\mathcal{O}(V + E)$ time without heap overhead.
5. **What if all edge weights are small integers in $[1, W]$?**
   Use **Dial's Algorithm** with an array of buckets (queues) modulo $(W + 1)$, running in $\mathcal{O}(V \cdot W + E)$ time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, SSSP, Dijkstra's Algorithm, Priority Queue, Greedy
- **Complexity Summary**:
  - Time: $\mathcal{O}((n + m) \log n)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Shortest Routes II](https://cses.fi/problemset/task/1672) — All-pairs shortest paths via Floyd-Warshall
  - [Flight Discount](https://cses.fi/problemset/task/1195) — State-expanded Dijkstra (halving one edge)
  - [Flight Routes](https://cses.fi/problemset/task/1196) — $k$-shortest paths with Dijkstra
