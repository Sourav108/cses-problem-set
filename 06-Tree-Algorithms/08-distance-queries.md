# Distance Queries

- **Category**: Tree Algorithms
- **CSES Task ID**: `1135`
- **CSES Problem Link**: [Distance Queries](https://cses.fi/problemset/task/1135)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an unweighted tree consisting of $n$ nodes numbered $1, 2, \dots, n$ and $n - 1$ edges.

You must process $q$ queries:
- For two given nodes $a$ and $b$, what is the **distance** (number of edges on the unique simple path) between $a$ and $b$?

### Input Format
- The first line contains two integers $n$ and $q$: the number of nodes and queries.
- The next $n - 1$ lines describe the edges: each line has two integers $u$ and $v$ ($1 \le u, v \le n$).
- The next $q$ lines describe the queries: each line has two integers $a$ and $b$.

### Output Format
- For each query, print the distance between nodes $a$ and $b$ on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le u, v \le n$
- $1 \le a, b \le n$

---

## 2. Intuition & Pattern Recognition

Running a BFS for each query takes $\mathcal{O}(n)$ time, yielding $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations, which exceeds the time limit.

### Path Decomposition via Lowest Common Ancestor (LCA)
Root the tree arbitrarily at node 1. For any two nodes $a$ and $b$:
- The unique simple path between $a$ and $b$ ascends from $a$ up to their Lowest Common Ancestor, $w = \text{LCA}(a, b)$, and then descends from $w$ down to $b$.
- The length of the upward segment from $a$ to $w$ is:
  $$\text{depth}[a] - \text{depth}[w]$$
- The length of the downward segment from $w$ to $b$ is:
  $$\text{depth}[b] - \text{depth}[w]$$
- Summing both segments gives the fundamental tree distance formula:
  $$\text{dist}(a, b) = (\text{depth}[a] - \text{depth}[w]) + (\text{depth}[b] - \text{depth}[w]) = \text{depth}[a] + \text{depth}[b] - 2 \cdot \text{depth}[\text{LCA}(a, b)]$$

### Binary Lifting
Using Binary Lifting (introduced in CSES 1688):
- Precompute depths and the doubling ancestor table $\text{up}[u][j]$ via a single DFS from root 1 in $\mathcal{O}(n \log n)$ time.
- For each query $(a, b)$, compute $\text{LCA}(a, b)$ in $\mathcal{O}(\log n)$ time and evaluate the formula in $\mathcal{O}(1)$.

---

## 3. Approach 1 — BFS per Query

For each query $(a, b)$, run an unweighted BFS starting at $a$ until node $b$ is reached.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot (V + E)) = \mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Euler Tour + Sparse Table (RMQ LCA)

Flatten the tree into an Euler Tour depth array. Query $\text{LCA}(a, b)$ in $\mathcal{O}(1)$ time using a Sparse Table.
- Precomputation: $\mathcal{O}(n \log n)$ time and space.
- Query Time: $\mathcal{O}(1)$ per query.
- Total Time: $\mathcal{O}(n \log n + q) \approx 0.05\text{s}$.
- Both Approach 2 and Binary Lifting (Approach 3) easily pass within the 1.00s limit. Binary Lifting is presented as Approach 3 due to its compact code and universal CP applicability.

---

## 5. Approach 3 — Optimal CSES Solution (Binary Lifting LCA)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

static const int MAX_LOG = 19; // 2^18 = 262144 > 200000

int n, q;
vector<vector<int>> adj;
vector<vector<int>> up;
vector<int> depth;

void dfs(int u, int p, int d) {
    depth[u] = d;
    up[u][0] = p;

    for (int j = 1; j < MAX_LOG; ++j) {
        up[u][j] = up[up[u][j - 1]][j - 1];
    }

    for (int v : adj[u]) {
        if (v != p) {
            dfs(v, u, d + 1);
        }
    }
}

int get_lca(int u, int v) {
    if (depth[u] < depth[v]) {
        swap(u, v);
    }

    // Step 1: Lift u to the same depth as v
    int diff = depth[u] - depth[v];
    for (int j = 0; j < MAX_LOG; ++j) {
        if (diff & (1 << j)) {
            u = up[u][j];
        }
    }

    if (u == v) return u;

    // Step 2: Lift both nodes simultaneously
    for (int j = MAX_LOG - 1; j >= 0; --j) {
        if (up[u][j] != up[v][j]) {
            u = up[u][j];
            v = up[v][j];
        }
    }

    return up[u][0];
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> q)) return 0;

    adj.assign(n + 1, vector<int>());
    up.assign(n + 1, vector<int>(MAX_LOG, 0));
    depth.assign(n + 1, 0);

    for (int i = 0; i < n - 1; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    dfs(1, 0, 0);

    while (q--) {
        int a, b;
        cin >> a >> b;
        int lca = get_lca(a, b);
        int dist = depth[a] + depth[b] - 2 * depth[lca];
        cout << dist << '\n';
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Path Uniqueness in Trees
In any tree, there exists a unique simple path between any pair of vertices $a$ and $b$.
Let $r$ be the designated root (node 1).
For any node $x$, let $P(r, x)$ denote the unique simple path from $r$ to $x$.
The length of $P(r, x)$ is by definition $\text{depth}[x]$.
The Lowest Common Ancestor $w = \text{LCA}(a, b)$ is the vertex with maximum depth belonging to both $P(r, a)$ and $P(r, b)$.
The path intersection satisfies:
$$P(r, a) \cap P(r, b) = P(r, w)$$
Therefore, the symmetric difference of the paths:
$$(P(r, a) \cup P(r, b)) \setminus P(r, w)$$
consists of the path from $a$ up to $w$ and the path from $w$ down to $b$.
Because $P(r, a)$ and $P(r, b)$ share the prefix $P(r, w)$ of length $\text{depth}[w]$ twice in $\text{depth}[a] + \text{depth}[b]$, subtracting $2 \cdot \text{depth}[w]$ cancels the shared ancestor path exactly:
$$\text{dist}(a, b) = \text{depth}[a] + \text{depth}[b] - 2 \cdot \text{depth}[w]$$
This holds for all pairs $(a, b)$, including $a = b$ ($\text{dist} = 0$) and when one node is an ancestor of the other.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
1 2
1 3
3 4
3 5
1 3
2 5
1 4
```

Hierarchy:
```text
      1 (depth 0)
    /   \
   2     3 (depth 1)
       /   \
      4     5 (depth 2)
```

Depths:
- $\text{depth}[1] = 0$
- $\text{depth}[2] = 1$
- $\text{depth}[3] = 1$
- $\text{depth}[4] = 2$
- $\text{depth}[5] = 2$

### Query 1: `1 3`
- $\text{LCA}(1, 3) = 1$
- $\text{dist} = \text{depth}[1] + \text{depth}[3] - 2 \cdot \text{depth}[1] = 0 + 1 - 2(0) = 1$.
- Output: `1`.

### Query 2: `2 5`
- $\text{LCA}(2, 5) = 1$
- $\text{dist} = \text{depth}[2] + \text{depth}[5] - 2 \cdot \text{depth}[1] = 1 + 2 - 2(0) = 3$ (path: $2 - 1 - 3 - 5$).
- Output: `3`.

### Query 3: `1 4`
- $\text{LCA}(1, 4) = 1$
- $\text{dist} = \text{depth}[1] + \text{depth}[4] - 2 \cdot \text{depth}[1] = 0 + 2 - 2(0) = 2$ (path: $1 - 3 - 4$).
- Output: `2`.

Outputs: `1`, `3`, `2` — matches ground truth.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Same Node Query ($a = b$)**:
   $\text{LCA}(a, a) = a \implies \text{dist} = \text{depth}[a] + \text{depth}[a] - 2 \cdot \text{depth}[a] = 0$.
2. **Adjacent Nodes (Edge $(a, b)$ exists)**:
   One is the parent of the other. $\text{LCA} = \text{parent}$, $\text{dist} = (\text{depth} + 1) + \text{depth} - 2 \cdot \text{depth} = 1$.
3. **Linear Chain ($P_n$)**:
   $\text{dist}(u, v) = |u - v|$, correctly handles trees with maximum depth $2 \cdot 10^5$.
4. **Fast I/O Requirement**:
   $q = 2 \cdot 10^5$ requires fast I/O (`cin.tie(nullptr)`) to finish well under the 1.00s time limit.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if edges have positive weights $w(u, v)$?**
   Maintain weighted distances from the root: $\text{dist\_root}[u]$.
   The weighted distance is:
   $$\text{dist}(u, v) = \text{dist\_root}[u] + \text{dist\_root}[v] - 2 \cdot \text{dist\_root}[\text{LCA}(u, v)]$$
2. **How can we check whether a node $x$ lies on the simple path between $a$ and $b$?**
   Node $x$ lies on path $a - b$ if and only if:
   $$\text{dist}(a, x) + \text{dist}(x, b) = \text{dist}(a, b)$$
3. **How do you find the $k$-th node along the path from $a$ to $b$?**
   Find $w = \text{LCA}(a, b)$.
   - If $k \le \text{dist}(a, w)$, the $k$-th node is the $k$-th ancestor of $a$ (via Company Queries I).
   - If $k > \text{dist}(a, w)$, it is the $(\text{dist}(a, b) - k)$-th ancestor of $b$.
4. **How would you answer distance queries in an undirected general graph?**
   In general graphs, distance queries require Single-Source Shortest Path (Dijkstra/BFS) or All-Pairs Shortest Paths (Floyd-Warshall), as simple tree ancestor formulas do not apply.
5. **How does Tarjan's Offline LCA compare for distance queries?**
   Tarjan's algorithm answers all $q$ queries offline in $\mathcal{O}(n + q \alpha(n))$ time, which is strictly faster by a factor of $\log n$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Preprocessing**: $\mathcal{O}(n \log n)$
  - **Per Query**: $\mathcal{O}(\log n)$
  - **Overall Run Time**: $\mathcal{O}((n + q) \log n) \approx 0.08\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n \log n)$ auxiliary space ($\approx 15\text{ MB}$).

### Related CSES Problems
- [Company Queries II](https://cses.fi/problemset/task/1688) — Core LCA computation
- [Tree Diameter](https://cses.fi/problemset/task/1131) — Maximum pairwise tree distance
- [Tree Distances I](https://cses.fi/problemset/task/1132) — Eccentricity of every node
