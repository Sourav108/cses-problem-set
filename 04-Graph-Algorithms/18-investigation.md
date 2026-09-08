# Investigation

- **Category**: Graph Algorithms
- **CSES Task ID**: `1202`
- **CSES Problem Link**: [Investigation](https://cses.fi/problemset/task/1202)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a directed flight network with $n$ cities and $m$ flights. Each flight connects city $a$ to city $b$ with a positive price $c$.

You want to travel from **city 1** to **city $n$** with the minimum total price. Among all such minimum-price routes, you need to investigate four properties:
1. The **minimum price** of a route from city 1 to city $n$.
2. The **number of minimum-price routes** modulo $10^9 + 7$.
3. The **minimum number of flights** in a minimum-price route.
4. The **maximum number of flights** in a minimum-price route.

### Input Format
- The first line contains two integers $n$ and $m$: the number of cities and flights.
- The next $m$ lines each contain three integers $a$, $b$, and $c$: a flight from city $a$ to city $b$ with price $c$.

### Output Format
- Print four integers on a single line separated by spaces:
  1. Minimum route price
  2. Number of minimum-price routes modulo $10^9 + 7$
  3. Minimum flight hops
  4. Maximum flight hops

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$
- $1 \le c \le 10^9$

With $V = 10^5$ and $E = 2 \cdot 10^5$, an augmented Dijkstra algorithm executes in $\mathcal{O}((n + m) \log n) \approx 0.12\text{s}$.

---

## 2. Intuition & Pattern Recognition

This problem unites **Dijkstra's Shortest Path Algorithm** with **Dynamic Programming on the Shortest Path DAG**:
- All shortest paths from a source in a graph with non-negative weights form a Directed Acyclic Graph (the **Shortest Path DAG**).
- On this DAG, we need to compute:
  1. Shortest distance $\text{dist}[v]$
  2. Path count $\text{ways}[v]$
  3. Shortest hop path $\text{min\_flights}[v]$
  4. Longest hop path $\text{max\_flights}[v]$
- Rather than extracting the shortest path DAG in a separate pass and topologically sorting it, we can maintain and update all four DP states **online directly inside Dijkstra's relaxation step**!
- Why does online updating during Dijkstra work?
  - Dijkstra pops vertices from the priority queue in strictly increasing order of their shortest distance $\text{dist}[u]$.
  - Because all edge weights $w \ge 1$, whenever a vertex $u$ is finalized, its shortest distance $\text{dist}[u]$ is immutable.
  - When relaxing an edge $u \to v$ with weight $w$:
    - **Case 1: $\text{dist}[u] + w < \text{dist}[v]$ (Strict Improvement)**:
      A strictly cheaper path to $v$ is discovered. Reset all four quantities for $v$:
      $$\text{dist}[v] = \text{dist}[u] + w$$
      $$\text{ways}[v] = \text{ways}[u]$$
      $$\text{min\_flights}[v] = \text{min\_flights}[u] + 1$$
      $$\text{max\_flights}[v] = \text{max\_flights}[u] + 1$$
      Push $\{\text{dist}[v], v\}$ to the min-priority queue.
    - **Case 2: $\text{dist}[u] + w == \text{dist}[v]$ (Tie / Alternative Shortest Path)**:
      Another optimal path to $v$ has been found through $u$. Accumulate:
      $$\text{ways}[v] = (\text{ways}[v] + \text{ways}[u]) \pmod{10^9 + 7}$$
      $$\text{min\_flights}[v] = \min(\text{min\_flights}[v], \; \text{min\_flights}[u] + 1)$$
      $$\text{max\_flights}[v] = \max(\text{max\_flights}[v], \; \text{max\_flights}[u] + 1)$$

---

## 3. Approach 1 — Naive Two-Phase: Dijkstra + Topological Sort

1. Run Dijkstra from 1 to compute $\text{dist}[1 \dots n]$.
2. Filter the graph to keep only edges $(u \to v, w)$ satisfying $\text{dist}[u] + w == \text{dist}[v]$ (the shortest path DAG).
3. Run topological sort and compute the 3 DP quantities.
- **Verdict**: Asymptotically $\mathcal{O}((n + m) \log n)$, but requires two separate graphs and traversals. Updating simultaneously in Dijkstra (Approach 3) is faster, cleaner, and uses half the memory.

---

## 4. Approach 2 — Bellman-Ford Multi-State DP

Relax all 4 arrays using Bellman-Ford across $n$ rounds.
- **Complexity**: $\mathcal{O}(V \cdot E) \approx 2 \cdot 10^{10}$ operations.
- **Verdict**: TLE.

---

## 5. Approach 3 — Optimal CSES Solution (Augmented Dijkstra DP)

1. Define arrays:
   - `dist[n+1]` initialized to $\text{INF} = 10^{18}$, `dist[1] = 0`.
   - `ways[n+1]` initialized to $0$, `ways[1] = 1`.
   - `min_flights[n+1]` initialized to $\text{INF}$, `min_flights[1] = 0`.
   - `max_flights[n+1]` initialized to $0$, `max_flights[1] = 0`.
2. Push `{0, 1}` into the min-priority queue `pq`.
3. While `pq` is non-empty:
   - Pop `{d, u}`.
   - If $d > \text{dist}[u]$, continue (stale entry).
   - For each edge $(u \to v, w)$:
     - If $\text{dist}[u] + w < \text{dist}[v]$:
       - Update $\text{dist}[v]$, `ways[v] = ways[u]`, `min_flights[v] = min_flights[u] + 1`, `max_flights[v] = max_flights[u] + 1`.
       - Push $\{\text{dist}[v], v\}$ to `pq`.
     - Else if $\text{dist}[u] + w == \text{dist}[v]$:
       - `ways[v] = (ways[v] + ways[u]) % MOD`.
       - `min_flights[v] = min(min_flights[v], min_flights[u] + 1)`.
       - `max_flights[v] = max(max_flights[v], max_flights[u] + 1)`.
4. Output `dist[n]`, `ways[n]`, `min_flights[n]`, and `max_flights[n]`.

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>

using namespace std;

const long long INF = 1e18;
const int MOD = 1e9 + 7;

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
    vector<long long> ways(n + 1, 0);
    vector<int> min_flights(n + 1, 1e9);
    vector<int> max_flights(n + 1, 0);

    priority_queue<pair<long long, int>, 
                   vector<pair<long long, int>>, 
                   greater<pair<long long, int>>> pq;

    dist[1] = 0;
    ways[1] = 1;
    min_flights[1] = 0;
    max_flights[1] = 0;

    pq.push({0, 1});

    while (!pq.empty()) {
        auto [d, u] = pq.top();
        pq.pop();

        if (d > dist[u]) continue;

        for (const auto& edge : adj[u]) {
            int v = edge.first;
            long long w = edge.second;

            if (dist[u] + w < dist[v]) {
                dist[v] = dist[u] + w;
                ways[v] = ways[u];
                min_flights[v] = min_flights[u] + 1;
                max_flights[v] = max_flights[u] + 1;
                pq.push({dist[v], v});
            } else if (dist[u] + w == dist[v]) {
                ways[v] = (ways[v] + ways[u]) % MOD;
                min_flights[v] = min(min_flights[v], min_flights[u] + 1);
                max_flights[v] = max(max_flights[v], max_flights[u] + 1);
            }
        }
    }

    cout << dist[n] << ' ' 
         << ways[n] << ' ' 
         << min_flights[n] << ' ' 
         << max_flights[n] << '\n';

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}((n + m) \log n)$.
  - Standard Dijkstra priority queue operations: at most $m$ pushes and $n$ pops.
  - Constant-time $\mathcal{O}(1)$ updates for `ways`, `min_flights`, and `max_flights` during edge relaxation.
  - Total time: $\approx 0.12\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for adjacency list and 4 linear state arrays.

---

## 6. Correctness Proof

### Equivalence to DP on Shortest Path DAG
- **Lemma**: Because all edge weights $w \ge 1 > 0$, the shortest path subgraph $G_{SP} = (V, E_{SP})$, where $E_{SP} = \{ (u, v) \in E \mid \text{dist}[u] + w(u, v) == \text{dist}[v] \}$, is strictly a **Directed Acyclic Graph (DAG)**.
  - *Proof*: For every edge $(u, v) \in E_{SP}$, $\text{dist}[v] = \text{dist}[u] + w(u, v) > \text{dist}[u]$. Since distances strictly increase along every edge in $E_{SP}$, no cycle can exist.
- **Topological Order of Processing**:
  - Dijkstra pops vertices in non-decreasing order of distance $\text{dist}[u]$.
  - Because $\text{dist}[u] < \text{dist}[v]$ for every edge $(u, v) \in E_{SP}$, every predecessor $u$ of $v$ in $G_{SP}$ is popped and relaxes its edges strictly before $v$ is finalized.
  - Therefore, by the time $v$ is popped, all incoming edges from all predecessors in $G_{SP}$ have contributed their `ways`, `min_flights`, and `max_flights` values.
  - Thus, the accumulated values at $v$ are exact. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 5$:
- Edges: $(1, 2, 4)$, $(1, 3, 2)$, $(3, 2, 2)$, $(2, 4, 3)$, $(3, 4, 5)$

1. **Pop 1 ($d = 0$)**:
   - $1 \to 2$ ($w = 4$): `dist[2] = 4, ways[2] = 1, min_f[2] = 1, max_f[2] = 1`.
   - $1 \to 3$ ($w = 2$): `dist[3] = 2, ways[3] = 1, min_f[3] = 1, max_f[3] = 1`.
2. **Pop 3 ($d = 2$)**:
   - $3 \to 2$ ($w = 2$): $\text{dist}[3] + 2 = 4 == \text{dist}[2]$!
     - Tie relaxation for node 2:
     - `ways[2] = (ways[2] + ways[3]) = 1 + 1 = 2`.
     - `min_f[2] = min(1, 1 + 1) = 1`.
     - `max_f[2] = max(1, 1 + 1) = 2`.
   - $3 \to 4$ ($w = 5$): `dist[4] = 7, ways[4] = 1, min_f[4] = 2, max_f[4] = 2`.
3. **Pop 2 ($d = 4$)**:
   - $2 \to 4$ ($w = 3$): $\text{dist}[2] + 3 = 7 == \text{dist}[4]$!
     - Tie relaxation for node 4:
     - `ways[4] = (ways[4] + ways[2]) = 1 + 2 = 3`.
     - `min_f[4] = min(2, min_f[2] + 1) = min(2, 2) = 2`.
     - `max_f[4] = max(2, max_f[2] + 1) = max(2, 3) = 3`.
4. **Pop 4 ($d = 7$)**: Destination reached!
- Output: `7 3 2 3`. (Distance: 7, Routes: 3, Min flights: 2, Max flights: 3).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow for Distances**:
   Path weights can reach $10^5 \times 10^9 = 10^{14}$. Distance values must be `long long` with `INF = 1e18`.
2. **Modulo Arithmetic**:
   `ways[v]` can grow exponentially (e.g. $2^{n/2}$). Always perform modulo $10^9 + 7$ upon addition.
3. **Multiple Edges with Same Weight**:
   If parallel edges of identical weight connect $u \to v$, each edge provides a distinct route. The tie-check `dist[u] + w == dist[v]` properly accumulates each parallel edge independently.
4. **Weights of Value 0**:
   The problem constraints state $c \ge 1$. If 0-weight edges were permitted, $\text{dist}[u] == \text{dist}[v]$ could form zero-weight cycles, breaking the DAG property. Since $c \ge 1$, acyclicity of $G_{SP}$ is guaranteed.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the graph contains 0-weight edges?**
   0-weight edges can create cycles of 0 cost within the shortest path subgraph, leading to infinitely many shortest paths. We would contract strongly connected components of 0-weight edges using Tarjan's algorithm before DP.
2. **Can this be solved using Bellman-Ford if negative edges exist?**
   If negative edges exist but no negative cycles, Bellman-Ford finds shortest distances, but counting shortest paths on general graphs with negative edges requires building the DAG after distances stabilize and running topological sort.
3. **How do you reconstruct all shortest paths?**
   Maintain a list of predecessors $\text{pred}[v]$ for each node. Any edge $(u, v)$ where $\text{dist}[u] + w == \text{dist}[v]$ is added to $\text{pred}[v]$. Backtracking DFS generates all paths.
4. **How do you find the edge betweenness centrality of edges?**
   Brandes' Algorithm runs Dijkstra augmented with path counts $\sigma[v]$ and dependency accumulations $\delta[u]$ backward from targets, running in $\mathcal{O}(V(E + V \log V))$.
5. **Why can't we just use BFS?**
   Edge weights $c$ are arbitrary positive integers up to $10^9$, not uniform $1$. Dijkstra is required.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Dijkstra, Shortest Path DAG, Dynamic Programming, Fast I/O
- **Complexity Summary**:
  - Time: $\mathcal{O}((n + m) \log n)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Shortest Routes I](https://cses.fi/problemset/task/1671) — Basic Dijkstra
  - [Flight Routes](https://cses.fi/problemset/task/1196) — $k$ shortest paths
  - [Game Routes](https://cses.fi/problemset/task/1681) — Counting paths on a DAG
