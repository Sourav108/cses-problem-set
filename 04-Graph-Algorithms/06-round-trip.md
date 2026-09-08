# Round Trip

- **Category**: Graph Algorithms
- **CSES Task ID**: `1669`
- **CSES Problem Link**: [Round Trip](https://cses.fi/problemset/task/1669)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Byteland has $n$ cities and $m$ roads between them. Your task is to find a **round trip** that begins and ends in the same city and visits at least two other distinct cities (i.e., a simple cycle of length $\ge 3$ containing at least $3$ distinct vertices). Every city on the circuit must be distinct, except for the starting and ending city which are the same.

If multiple valid round trips exist, you may output any of them. If no round trip exists, print `IMPOSSIBLE`.

### Input Format
- The first line contains two integers $n$ and $m$: the number of cities and roads.
- The next $m$ lines each contain two integers $a$ and $b$: a bidirectional road connecting city $a$ and city $b$.

### Output Format
- If a valid round trip exists:
  - On the first line, print an integer $k$: the number of cities on the round trip ($k \ge 4$, since the first and last city are the same).
  - On the second line, print the $k$ cities in the order they are visited.
- If no round trip exists, print `IMPOSSIBLE`.

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$ and $a \ne b$

With $V = 10^5$ and $E = 2 \cdot 10^5$, an $\mathcal{O}(n + m)$ cycle detection algorithm executes well under $0.05\text{s}$.

---

## 2. Intuition & Pattern Recognition

In an undirected graph, a round trip of length $\ge 3$ is precisely an **undirected simple cycle**:
- When traversing an undirected graph via Depth-First Search (DFS), edges are partitioned into:
  1. **Tree edges**: Edges leading to unvisited vertices, forming a DFS spanning forest.
  2. **Back-edges**: Edges leading to an ancestor currently on the recursion stack (other than the immediate parent).
- If DFS at node $u$ encounters an adjacent node $v$ that is already marked as visited, and $v \ne \text{parent}[u]$:
  - Vertex $v$ must be an ancestor of $u$ in the DFS tree.
  - The edge $(u, v)$ is a **back-edge**.
  - Since $v$ is an ancestor of $u$ and $v \ne \text{parent}[u]$, the path in the DFS tree from $v$ down to $u$ combined with the edge $(u, v)$ forms a simple cycle of length at least $3$!
- Once detected, we can immediately trace backwards from $u$ to $v$ using stored parent pointers:
  $$u \to \text{parent}[u] \to \text{parent}[\text{parent}[u]] \to \dots \to v$$
  Appending $v$ at both ends gives the closed tour: $v \to \dots \to \text{parent}[u] \to u \to v$.

---

## 3. Approach 1 — Naive / Pure Backtracking

Initiate a simple DFS path search from every vertex $s \in \{1, \dots, n\}$, maintaining a path history. At each step, if a neighbor matches $s$ and path length is $\ge 3$, output the cycle.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}((n + m) \cdot 2^n)$ in the worst case on dense graphs.
- **Space Complexity**: $\mathcal{O}(n)$ recursion depth.
- **CSES Verdict**: Time Limit Exceeded (TLE) on all but the smallest inputs.

---

## 4. Approach 2 — Disjoint Set Union (DSU)

We can also detect cycles during edge insertion using Kruskal's DSU:
- For each edge $(u, v)$:
  - If $\text{find}(u) \ne \text{find}(v)$, merge their sets ($\text{union}(u, v)$).
  - If $\text{find}(u) == \text{find}(v)$, adding $(u, v)$ forms a cycle!
- To reconstruct the cycle, run a BFS/DFS from $u$ to $v$ restricted only to previously added tree edges, then append $u$ to close the cycle.
- **Time Complexity**: $\mathcal{O}(m \alpha(n) + (n + m))$.
- **Verdict**: Fully optimal, but requires two passes (DSU + BFS path reconstruction). Approach 3 achieves the same in a single DFS pass with simpler code.

---

## 5. Approach 3 — Optimal CSES Solution (DFS Back-Edge Detection)

We use DFS with a `parent` array and a boolean `visited` array across all connected components:
1. Initialize `visited[1...n] = false` and `parent[1...n] = 0`.
2. For each node $i \in \{1, \dots, n\}$, if `!visited[i]`, invoke `dfs(i, 0)`.
3. In `dfs(u, p)`:
   - Mark `visited[u] = true`, `parent[u] = p`.
   - For each neighbor $v \in \text{adj}[u]$:
     - If $v == p$, continue (skip the edge back to immediate parent).
     - If `visited[v] == true`:
       - We found a back-edge $(u, v)$!
       - Store cycle endpoints `cycle_start = v`, `cycle_end = u`, and return `true`.
     - Otherwise, if `dfs(v, u)` returns `true`, propagate return `true` immediately to stop further traversal.
4. If no cycle is detected in any component, print `IMPOSSIBLE`.
5. Otherwise, reconstruct the cycle:
   - Start with `cycle_start`.
   - Walk from `cycle_end` backwards up `parent` pointers until `cycle_start` is reached.
   - Push `cycle_start` again to close the loop.
   - Reverse the sequence (or print in order) and print its size and elements.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int n, m;
vector<vector<int>> adj;
vector<bool> visited;
vector<int> parent_node;
int cycle_start = -1;
int cycle_end = -1;

bool dfs(int u, int p) {
    visited[u] = true;
    parent_node[u] = p;

    for (int v : adj[u]) {
        if (v == p) continue; // Skip edge to immediate parent
        if (visited[v]) {
            cycle_start = v;
            cycle_end = u;
            return true;
        }
        if (dfs(v, u)) return true;
    }
    return false;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> m)) return 0;

    adj.assign(n + 1, vector<int>());
    visited.assign(n + 1, false);
    parent_node.assign(n + 1, 0);

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    for (int i = 1; i <= n; ++i) {
        if (!visited[i]) {
            if (dfs(i, 0)) break;
        }
    }

    if (cycle_start == -1) {
        cout << "IMPOSSIBLE\n";
    } else {
        vector<int> cycle;
        cycle.push_back(cycle_start);
        for (int curr = cycle_end; curr != cycle_start; curr = parent_node[curr]) {
            cycle.push_back(curr);
        }
        cycle.push_back(cycle_start);

        cout << cycle.size() << '\n';
        for (size_t i = 0; i < cycle.size(); ++i) {
            cout << cycle[i] << (i + 1 == cycle.size() ? '\n' : ' ');
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$. Each vertex and edge is examined at most once before a cycle is found and DFS terminates.
- **Space Complexity**: $\mathcal{O}(n + m)$ for the adjacency list, plus $\mathcal{O}(n)$ for `visited`, `parent_node`, and recursion stack.

---

## 6. Correctness Proof

### Invariant & Cycle Existence
- **Claim**: If during DFS from $u$, an adjacent node $v$ is already visited and $v \ne \text{parent}[u]$, then $v$ is an ancestor of $u$ in the DFS tree, and the tree path between $v$ and $u$ together with edge $(u, v)$ constitutes a simple cycle of length $\ge 3$.
- **Proof**:
  1. In an undirected graph, every edge is either a **tree edge** or a **back-edge** (cross edges cannot exist because an undirected edge between two unrelated subtrees would have been traversed by whichever subtree was explored first).
  2. Because $v$ is already visited when we explore from $u$, and $v$ is not $u$'s direct parent, $v$ must be an ancestor of $u$ in the active DFS tree branch.
  3. The path in the DFS tree from $v$ to $u$ consists of at least two edges (since $v \ne \text{parent}[u]$).
  4. Adding the undirected edge $(u, v)$ creates a simple cycle of length $\ge 3$.
  5. By tracing $parent\_node$ from $u$ back to $v$, we trace exactly this tree path in reverse. Each intermediate vertex is visited exactly once, yielding a strictly simple cycle. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider the graph:
- $n = 5, m = 6$
- Edges: $(1, 3), (1, 2), (5, 3), (1, 5), (2, 4), (4, 5)$

```
   1 --- 2
  / \     \
 3---5 --- 4
```

1. Start DFS at node $1$ with parent $0$:
   - `visited[1] = true`, `parent[1] = 0`.
2. From $1$, visit neighbor $3$:
   - `visited[3] = true`, `parent[3] = 1`.
3. From $3$, check neighbors:
   - $1$: parent, skip.
   - $5$: unvisited $\implies$ visit $5$:
     - `visited[5] = true`, `parent[5] = 3`.
4. From $5$, check neighbors:
   - $3$: parent, skip.
   - $1$: already visited, and $1 \ne 3$!
   - Back-edge $(5, 1)$ detected!
   - `cycle_start = 1`, `cycle_end = 5`. Return `true`.
5. Reconstruct cycle:
   - Push `cycle_start` ($1$).
   - Trace backwards from `cycle_end` ($5$):
     - `curr = 5`, push $5$. `curr = parent[5] = 3`.
     - `curr = 3`, push $3$. `curr = parent[3] = 1 == cycle_start`. Stop loop.
   - Push `cycle_start` ($1$) to close.
   - Cycle: $[1, 5, 3, 1]$.
   - Output length: $4$.
   - Output tour: `1 5 3 1` (or equivalently `1 3 5 1`). Length is $4 \ge 4$. Valid!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Disconnected Components**:
   The graph may be a disconnected forest. We must loop $i$ from $1$ to $n$ to search every component.
2. **Multiple Parallel Edges & Self-Loops**:
   - The problem statement specifies simple graphs ($a \ne b$, at most one road between any two cities).
   - If parallel edges existed, skipping $v == p$ by vertex ID would ignore a second parallel edge. CSES guarantees no multiple edges.
3. **Cycles of Length 2 Disallowed**:
   A 2-cycle $u \leftrightarrow v$ consists of an edge and its trivial reverse. The condition `v == p` strictly ignores this reverse edge, guaranteeing all detected cycles have length $\ge 3$.
4. **Recursion Limit**:
   In C++17 on Linux (CSES), the default stack limit is 512 MB (equal to the total memory limit), so a recursion depth of $10^5$ consumes $\approx 5\text{ MB}$ and will not stack overflow.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does cycle detection differ between undirected and directed graphs?**
   In undirected graphs, a 2-color (`visited`) array and parent check suffice because non-tree edges can only be back-edges. In directed graphs, cross-edges and forward-edges exist; we must use 3-coloring (0 = unvisited, 1 = visiting/on recursion stack, 2 = visited/finished) to detect cycles (back-edges point to nodes in state 1).
2. **Can this problem be solved using Disjoint Set Union (DSU)?**
   Yes. When an edge $(u, v)$ connects two nodes already in the same connected component, a cycle is created. However, finding the cycle path requires running a BFS/DFS on the existing tree spanning the component, so DFS directly solves both detection and path extraction in one pass.
3. **What if we need to find the shortest cycle (girth of the graph)?**
   Run unweighted BFS from every vertex $s \in V$. When a cross-edge between two nodes in the BFS frontier is reached, a minimum cycle through $s$ is found. Total time is $\mathcal{O}(V(V + E))$, which is feasible for $V \le 2500$.
4. **What if edge weights are present and we want the minimum weight cycle?**
   If weights are positive, Floyd-Warshall can find the minimum weight cycle in $\mathcal{O}(V^3)$ by considering $\min_{k} (\text{dist}[i][j] + w(i, k) + w(k, j))$ before relaxing with $k$.
5. **How can we count the total number of fundamental cycles in the graph?**
   In any connected undirected graph with $V$ vertices and $E$ edges, any spanning tree contains $V - 1$ edges. The remaining $E - (V - 1)$ edges are non-tree edges, each inducing exactly one fundamental cycle. The cycle space has dimension $E - V + C$, where $C$ is the number of connected components.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, DFS, Cycle Detection, Back-Edge, Path Reconstruction
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Round Trip II](https://cses.fi/problemset/task/1678) — Cycle detection in directed graphs (3-state DFS)
  - [Course Schedule](https://cses.fi/problemset/task/1679) — Topological sorting and DAG verification
  - [Building Roads](https://cses.fi/problemset/task/1666) — Connected components in undirected graphs
