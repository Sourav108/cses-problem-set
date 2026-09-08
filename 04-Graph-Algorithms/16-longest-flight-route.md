# Longest Flight Route

- **Category**: Graph Algorithms
- **CSES Task ID**: `1680`
- **CSES Problem Link**: [Longest Flight Route](https://cses.fi/problemset/task/1680)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Uolevi has won a contest and can fly around the world for free. There are $n$ cities and $m$ flight connections between them. Uolevi wants to fly from **city 1** to **city $n$**, visiting as many cities as possible.

The flight network is guaranteed to contain no directed cycles on any path from city 1 to city $n$ (it is a Directed Acyclic Graph, DAG).

Your task is to find the maximum number of cities on a valid route from city 1 to city $n$, and print the cities on the route in order. If no route exists from city 1 to city $n$, print `IMPOSSIBLE`.

### Input Format
- The first line contains two integers $n$ and $m$: the number of cities and flights.
- The next $m$ lines each contain two integers $a$ and $b$: a directed flight from city $a$ to city $b$.

### Output Format
- If a route exists:
  - First line: Print $k$, the maximum number of cities on the route.
  - Second line: Print the $k$ cities in the order they are visited.
- If no route exists:
  - Print `IMPOSSIBLE`.

### Numerical Constraints
- $2 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$

With $V = 10^5$ and $E = 2 \cdot 10^5$, DAG Dynamic Programming over Topological Order operates in strictly linear time $\mathcal{O}(n + m) \approx 0.05\text{s}$.

---

## 2. Intuition & Pattern Recognition

While the **Longest Simple Path** problem is NP-hard on general graphs, on a **Directed Acyclic Graph (DAG)** it is solvable in linear time using **Dynamic Programming**:
- Because the graph has no directed cycles, we can find a **topological ordering** of the vertices.
- Let $\text{dist}[u]$ be the maximum number of cities on a route starting at city $1$ and ending at city $u$.
- Base case:
  $$\text{dist}[1] = 1, \quad \text{dist}[u] = -\infty \text{ for all } u \ne 1$$
- Recurrence:
  For any directed edge $u \to v$:
  $$\text{dist}[v] = \max(\text{dist}[v], \; \text{dist}[u] + 1) \quad (\text{if } \text{dist}[u] \ne -\infty)$$
- To reconstruct the optimal route, maintain a `parent[v] = u` pointer whenever $\text{dist}[v]$ is strictly improved.
- If $\text{dist}[n] == -\infty$, no path connects 1 to $n \implies$ print `IMPOSSIBLE`. Otherwise, backtrack from $n$ to $1$ using `parent` pointers.

---

## 3. Approach 1 — Naive DFS Backtracking

Recursively explore every path from 1 to $n$ and record the maximum length.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^n)$ in the worst case on dense DAGs.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Memoized DFS (Top-Down DP)

Compute $\text{dp}(u)$: the length of the longest path from $u$ to $n$.
- Base case: $\text{dp}(n) = 1$, all others $-\infty$.
- Recurrence: $\text{dp}(u) = 1 + \max_{v \in \text{adj}[u]} \text{dp}(v)$.
- **Verdict**: Optimal $\mathcal{O}(n + m)$, but recursive calls on $10^5$ nodes consume stack frames. Bottom-up topological sort with Kahn's algorithm is iteration-safe and cache-friendly.

---

## 5. Approach 3 — Optimal CSES Solution (Kahn's Topological DP)

1. Compute `in_degree` for all vertices.
2. Push all vertices with `in_degree == 0` into a BFS queue.
3. Extract topological order into an array `topo`.
4. Initialize `dist[1...n] = -INF` and `parent[1...n] = 0`. Set $\text{dist}[1] = 1$.
5. Process vertices $u$ in topological order:
   - If $\text{dist}[u] == -\text{INF}$, skip (node $u$ cannot be reached from city 1).
   - For each outgoing edge $u \to v$:
     - If $\text{dist}[u] + 1 > \text{dist}[v]$:
       - Update $\text{dist}[v] = \text{dist}[u] + 1$.
       - Set $\text{parent}[v] = u$.
6. If $\text{dist}[n] \le 0$, print `IMPOSSIBLE`.
7. Otherwise, reconstruct the path from $n$ to $1$ using `parent`, reverse it, and print.

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>

using namespace std;

const int INF = 1e9;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<vector<int>> adj(n + 1);
    vector<int> in_degree(n + 1, 0);

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        in_degree[v]++;
    }

    queue<int> q;
    for (int i = 1; i <= n; ++i) {
        if (in_degree[i] == 0) {
            q.push(i);
        }
    }

    vector<int> topo;
    topo.reserve(n);

    while (!q.empty()) {
        int u = q.front();
        q.pop();
        topo.push_back(u);

        for (int v : adj[u]) {
            in_degree[v]--;
            if (in_degree[v] == 0) {
                q.push(v);
            }
        }
    }

    vector<int> dist(n + 1, -INF);
    vector<int> parent(n + 1, 0);

    dist[1] = 1;

    for (int u : topo) {
        if (dist[u] == -INF) continue;

        for (int v : adj[u]) {
            if (dist[u] + 1 > dist[v]) {
                dist[v] = dist[u] + 1;
                parent[v] = u;
            }
        }
    }

    if (dist[n] <= 0) {
        cout << "IMPOSSIBLE\n";
    } else {
        vector<int> path;
        for (int curr = n; curr != 0; curr = parent[curr]) {
            path.push_back(curr);
        }
        reverse(path.begin(), path.end());

        cout << dist[n] << '\n';
        for (size_t i = 0; i < path.size(); ++i) {
            cout << path[i] << (i + 1 == path.size() ? '\n' : ' ');
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$.
  - Kahn's topological sort: $\mathcal{O}(n + m)$.
  - Dynamic programming relaxation: each edge examined once, taking $\mathcal{O}(n + m) \approx 0.05\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for adjacency list, in-degrees, distance, and parent arrays.

---

## 6. Correctness Proof

### Optimal Substructure on DAGs
- **Induction on Topological Order**:
  Let $u_1, u_2, \dots, u_n$ be the topological order.
  - Base case: For $u_1$, if $u_1 = 1$, $\text{dist}[1] = 1$ is trivially the maximum length. If $u_1 \ne 1$, it has no incoming edges, so it cannot be reached from $1$, and $\text{dist}[u_1] = -\infty$.
  - Inductive step: Assume for all $j < i$, $\text{dist}[u_j]$ holds the exact maximum path length from $1$ to $u_j$.
  - In a DAG, all incoming edges to $u_i$ must originate from vertices $u_j$ with $j < i$.
  - Any path from $1$ to $u_i$ must have a last edge $u_j \to u_i$.
  - The longest path from $1$ to $u_i$ is therefore $\max_{j < i, (u_j, u_i) \in E} (\text{dist}[u_j] + 1)$.
  - Because all $u_j$ preceding $u_i$ have already been processed, $\text{dist}[u_i]$ has considered all possible incoming edges and achieves the global maximum. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 5, m = 5$:
- Edges: $(1, 2), (2, 4), (1, 3), (3, 4), (4, 5)$
- In-degrees: $1: 0, 2: 1, 3: 1, 4: 2, 5: 1$.
- Topo sort order: $[1, 2, 3, 4, 5]$.
- `dist[1] = 1`, all others $-\infty$.
- Process $1$:
  - $1 \to 2$: `dist[2] = 2`, `parent[2] = 1`
  - $1 \to 3$: `dist[3] = 2`, `parent[3] = 1`
- Process $2$:
  - $2 \to 4$: `dist[4] = 3`, `parent[4] = 2`
- Process $3$:
  - $3 \to 4$: $\text{dist}[3] + 1 = 3 \not> \text{dist}[4]$ ($3$).
- Process $4$:
  - $4 \to 5$: `dist[5] = 4`, `parent[5] = 4`
- Process $5$: destination.
- Reconstruct: $5 \to 4 \to 2 \to 1 \implies [1, 2, 4, 5]$ (length 4).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Unreachable Destination $n$**:
   If no directed path exists from 1 to $n$, $\text{dist}[n]$ remains $-\text{INF}$, outputting `IMPOSSIBLE`.
2. **Nodes Preceding Source 1 in Topological Order**:
   Nodes that appear before 1 in topological order have `dist == -INF`. The check `if (dist[u] == -INF) continue;` correctly prevents them from propagating false paths to downstream nodes.
3. **Number of Cities vs Number of Flights**:
   The problem defines route length as the number of **cities** on the route (which equals the number of flights $+ 1$). Initializing `dist[1] = 1` correctly tracks city count.
4. **Multiple Paths of Same Maximum Length**:
   Any valid longest path can be output. The `>` condition picks the first discovered optimal path.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Why is longest path polynomial on DAGs but NP-hard on general graphs?**
   On general graphs, a longest path problem is equivalent to the Hamiltonian Path problem (checking if a path of length $n$ exists). On DAGs, cycles cannot exist, so no path can loop indefinitely, ensuring optimal substructure.
2. **Can we negate edge weights and use Bellman-Ford?**
   If the entire graph is a DAG, yes. However, Bellman-Ford takes $\mathcal{O}(V \cdot E) \approx 2 \cdot 10^{10}$ operations, which would TLE. Topological DP is $\mathcal{O}(V + E)$.
3. **How do we count the number of longest paths?**
   Maintain a `ways[v]` array: if a strictly longer path is found, reset `ways[v] = ways[u]`; if an equally long path is found, add `ways[v] = (ways[v] + ways[u]) % MOD`.
4. **What if edge weights are general positive integers?**
   The exact same DP applies: $\text{dist}[v] = \max(\text{dist}[v], \text{dist}[u] + w)$.
5. **How does this relate to Critical Path Method (CPM) in project management?**
   CPM models tasks as nodes in a DAG with durations as weights. The longest path in the DAG determines the minimum total time required to complete the project (the "critical path").

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, DAG, Dynamic Programming, Topological Sort, Kahn's Algorithm
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Course Schedule](https://cses.fi/problemset/task/1679) — Topological sorting on DAGs
  - [Game Routes](https://cses.fi/problemset/task/1681) — Counting paths in a DAG
  - [Investigation](https://cses.fi/problemset/task/1202) — Shortest path DAG with path counting and min/max hops
