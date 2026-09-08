# Tree Distances I

- **Category**: Tree Algorithms
- **CSES Task ID**: `1132`
- **CSES Problem Link**: [Tree Distances I](https://cses.fi/problemset/task/1132)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a tree consisting of $n$ nodes numbered $1, 2, \dots, n$ and $n - 1$ edges.

Your task is to determine, for **every node** $x \in [1, n]$, the maximum distance (in number of edges) to any other node in the tree:
$$f(x) = \max_{y \in V} \text{dist}(x, y)$$

### Input Format
- The first line contains an integer $n$: the number of nodes.
- The next $n - 1$ lines describe the edges: each line has two integers $a$ and $b$ ($1 \le a, b \le n$).

### Output Format
- Print $n$ integers: the maximum distance for each node $1, 2, \dots, n$.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le a, b \le n$

---

## 2. Intuition & Pattern Recognition

A naive BFS from every node takes $\mathcal{O}(n^2)$ time, which is too slow.
Instead, we leverage a fundamental geometric property of trees:

### Diameter Extremity Theorem
> **Theorem**: For any node $x$ in a tree, the farthest node from $x$ is always **one of the endpoints of the tree's diameter**.

Let $u$ and $v$ be the two endpoints of a diameter path in the tree.
Then for any node $x \in [1, n]$:
$$\max_{y \in V} \text{dist}(x, y) = \max\big(\text{dist}(x, u), \; \text{dist}(x, v)\big)$$

### Algorithmic Pipeline (3-BFS Method)
1. **BFS 1 (from arbitrary node 1)**:
   Find the farthest node from 1. Let this be diameter endpoint $u$.
2. **BFS 2 (from $u$)**:
   Compute distances $\text{dist}_u[x]$ for all $x \in [1, n]$.
   The node maximizing distance from $u$ is the other diameter endpoint $v$.
3. **BFS 3 (from $v$)**:
   Compute distances $\text{dist}_v[x]$ for all $x \in [1, n]$.
4. **Answer for each node $x$**:
   $$\text{ans}[x] = \max(\text{dist}_u[x], \; \text{dist}_v[x])$$

This resolves all $n$ queries simultaneously in three simple BFS passes, requiring only $\mathcal{O}(n)$ time and memory.

---

## 3. Approach 1 — Naive All-Pairs BFS

Run an unweighted BFS from every node $x \in [1, n]$ to find its eccentricity.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Tree Rerooting DP (Up-Down Dynamic Programming)

1. **Pass 1 (Bottom-Up DFS)**:
   Root tree at 1. For each node $u$, find the top two largest depths in its subtree, and which child branch achieved them:
   $$h_1[u] = \text{max depth down subtree}, \quad c_1[u] = \text{child achieving } h_1[u]$$
   $$h_2[u] = \text{second max depth down subtree}$$
2. **Pass 2 (Top-Down DFS / Rerooting)**:
   Propagate distances from parents to children:
   If child $v = c_1[u]$, the best path going upward through parent $u$ is $1 + \max(up[u], h_2[u])$.
   Otherwise, it is $1 + \max(up[u], h_1[u])$.
- **Complexity**: $\mathcal{O}(n)$ time and space.
- **Trade-off**: Requires careful handling of parent branches. The 3-BFS Diameter method (Approach 3) is simpler, cleaner, and avoids recursion entirely.

---

## 5. Approach 3 — Optimal CSES Solution (3-BFS Diameter Extremities)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>

using namespace std;

int n;
vector<vector<int>> adj;

// Returns distance array from start_node and the farthest node found
pair<vector<int>, int> bfs(int start_node) {
    vector<int> dist(n + 1, -1);
    queue<int> q;

    dist[start_node] = 0;
    q.push(start_node);

    int farthest_node = start_node;

    while (!q.empty()) {
        int u = q.front();
        q.pop();

        if (dist[u] > dist[farthest_node]) {
            farthest_node = u;
        }

        for (int v : adj[u]) {
            if (dist[v] == -1) {
                dist[v] = dist[u] + 1;
                q.push(v);
            }
        }
    }

    return {dist, farthest_node};
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n)) return 0;

    adj.assign(n + 1, vector<int>());

    for (int i = 0; i < n - 1; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    // Step 1: Find one diameter endpoint 'u' starting from node 1
    auto [_, u] = bfs(1);

    // Step 2: Compute dist_u from 'u' and find other diameter endpoint 'v'
    auto [dist_u, v] = bfs(u);

    // Step 3: Compute dist_v from 'v'
    auto [dist_v, _unused] = bfs(v);

    // Step 4: Output max(dist_u[x], dist_v[x]) for every node x
    for (int x = 1; x <= n; ++x) {
        cout << max(dist_u[x], dist_v[x]) << (x == n ? "" : " ");
    }
    cout << '\n';

    return 0;
}
```

---

## 6. Correctness Proof

### Theorem
Let $u$ and $v$ be the endpoints of a diameter path in tree $T$. For any vertex $x \in V$:
$$\max_{y \in V} \text{dist}(x, y) = \max(\text{dist}(x, u), \text{dist}(x, v))$$

*Proof*:
Let $y^*$ be a vertex that achieves the maximum distance from $x$: $\text{dist}(x, y^*) = \max_{y \in V} \text{dist}(x, y)$.
By the Two-BFS Theorem proved in CSES 1131, running a traversal from any vertex $x$ to find its farthest node always yields an endpoint of some diameter of the tree.
Thus, $y^*$ is an endpoint of a diameter $D'$.
Since all diameters of a tree share the same central vertices and have identical length $D$:
- The distance from $x$ to $y^*$ is maximized when $y^*$ is an extremity of the diameter path that passes nearest to $x$.
- Furthermore, for any two diameters $u-v$ and $u'-v'$, the distances satisfy:
  $$\max(\text{dist}(x, u), \text{dist}(x, v)) = \max(\text{dist}(x, u'), \text{dist}(x, v'))$$
Therefore, fixing any arbitrary diameter $u-v$ and taking $\max(\text{dist}(x, u), \text{dist}(x, v))$ achieves the exact maximum eccentricity for all $x \in V$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5
1 2
1 3
3 4
3 5
```

Tree Structure:
```text
      1
    /   \
   2     3
       /   \
      4     5
```

### 3-BFS Execution
1. **BFS 1 from node 1**:
   - Finds farthest node $u = 4$ (or 5).
2. **BFS 2 from node 4**:
   - `dist_u = [-, 2, 3, 1, 0, 2]`
   - Farthest node from 4 is $v = 2$ (`dist_u[2] = 3`).
3. **BFS 3 from node 2**:
   - `dist_v = [-, 1, 0, 2, 3, 3]`

### Combining Distances
| Node $x$ | $\text{dist}_u[x]$ (from 4) | $\text{dist}_v[x]$ (from 2) | $\max(\text{dist}_u, \text{dist}_v)$ |
|:---:|:---:|:---:|:---:|
| 1 | 2 | 1 | **2** |
| 2 | 3 | 0 | **3** |
| 3 | 1 | 2 | **2** |
| 4 | 0 | 3 | **3** |
| 5 | 2 | 3 | **3** |

### Output
`2 3 2 3 3` — exactly matches ground truth.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Single Node Tree ($n = 1$)**:
   $u = 1, v = 1$. $\text{dist}[1] = 0$. Outputs `0`.
2. **Path Graph ($P_n$)**:
   $u = 1, v = n$. Node $x$ has $\max(x - 1, n - x)$, correctly reflecting distances to the two ends of the line.
3. **Star Graph**:
   Center node has distance 1. All leaves have distance 2 (to another leaf).
4. **Memory Allocation**:
   Each BFS creates a `vector<int>` of size $n + 1$. Reusing vectors or storing two vectors consumes $< 8\text{ MB}$, well within 512 MB.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does this problem generalize to weighted trees?**
   If edge weights are positive, replace the BFS queue with Dijkstra / DFS. The diameter extremity theorem still holds, and $\max(\text{dist}(x, u), \text{dist}(x, v))$ remains optimal.
2. **How does Tree Distances I relate to Tree Distances II?**
   Tree Distances I asks for the *maximum* distance from each node (extreme value, solvable via diameter endpoints). Tree Distances II asks for the *sum* of distances to all nodes (aggregate, requiring tree rerooting DP).
3. **Can we find the $k$-th farthest node from each node efficiently?**
   Finding the $k$-th farthest node requires Centroid Decomposition or Heavy-Light Decomposition combined with persistent segment trees.
4. **What is the set of all nodes that achieve the minimum eccentricity $\min_x f(x)$?**
   These nodes form the **center** of the tree (at most two adjacent vertices on any tree diameter).
5. **How would you answer dynamic edge weight update queries?**
   With dynamic edge weights, the tree diameter can shift. Maintaining the diameter and node eccentricities dynamically requires a **Top Tree** or **Link-Cut Tree**.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**: $\mathcal{O}(n)$ — Exactly three linear BFS traversals ($\approx 3 \times 2 \cdot 10^5 \approx 6 \cdot 10^5$ operations $\approx 0.04\text{s}$).
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary memory for distance vectors.

### Related CSES Problems
- [Tree Diameter](https://cses.fi/problemset/task/1131) — Two-BFS diameter calculation
- [Tree Distances II](https://cses.fi/problemset/task/1133) — Sum of distances using rerooting DP
- [Distance Queries](https://cses.fi/problemset/task/1135) — Pairwise tree distances via LCA
