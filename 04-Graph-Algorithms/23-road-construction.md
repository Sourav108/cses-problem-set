# Road Construction

- **Category**: Graph Algorithms
- **CSES Task ID**: `1676`
- **CSES Problem Link**: [Road Construction](https://cses.fi/problemset/task/1676)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ cities and initially no roads between them. There are $m$ roads constructed one by one. Each road connects two cities $a$ and $b$ bidirectionally.

Your task is to process the road constructions sequentially. After **each** road is added, print:
1. The **number of connected components** currently in the graph.
2. The **size of the largest connected component** currently in the graph.

### Input Format
- The first line contains two integers $n$ and $m$: the number of cities and roads.
- The next $m$ lines each contain two integers $a$ and $b$: a road between city $a$ and city $b$.

### Output Format
- After each road is added, print the number of components and the size of the largest component separated by a space.

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$

With $V = 10^5$ and $E = 2 \cdot 10^5$, Disjoint Set Union (DSU) with path compression and union by size processes each road in nearly constant time $\mathcal{O}(\alpha(n))$, finishing all queries in $\approx 0.05\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is an online **Dynamic Connectivity** problem:
- We start with $n$ isolated vertices:
  - Number of components: $\text{components} = n$
  - Size of largest component: $\text{max\_size} = 1$
- When an edge $(u, v)$ is added:
  - Find the set representatives: $r_u = \text{find}(u)$ and $r_v = \text{find}(v)$.
  - If $r_u == r_v$, the vertices are already in the same component. The number of components and maximum component size remain unchanged.
  - If $r_u \ne r_v$, two distinct components merge:
    1. The number of components strictly decreases by 1:
       $$\text{components} \leftarrow \text{components} - 1$$
    2. The merged component has size:
       $$\text{size}[r_u] \leftarrow \text{size}[r_u] + \text{size}[r_v]$$
    3. The size of the largest component can only increase or stay the same:
       $$\text{max\_size} \leftarrow \max(\text{max\_size}, \; \text{size}[r_u])$$
- The **Disjoint Set Union (DSU)** data structure supports both `find` and `unite` in amortized $\mathcal{O}(\alpha(n))$ time, providing instantaneous updates after each road.

---

## 3. Approach 1 — Naive BFS / DFS Traversal per Road

After adding each edge, re-run full BFS/DFS over all connected components to count components and measure their sizes.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(m \cdot (n + m)) \approx 2 \cdot 10^5 \times 3 \cdot 10^5 \approx 6 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n + m)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Standard DSU with Full Size Scan

Use DSU to merge sets, but after every merger, iterate over all roots to compute the maximum component size.
- **Time Complexity**: $\mathcal{O}(m \cdot n) \approx 2 \cdot 10^{10}$ operations.
- **CSES Verdict**: TLE.
- **Fix**: The maximum size only ever changes when two components merge, and its new candidate is simply the newly merged component's size! Tracking `max_size` globally reduces the update to $\mathcal{O}(1)$.

---

## 5. Approach 3 — Optimal CSES Solution (DSU with Size Tracking)

1. Initialize DSU for $n$ elements:
   - `parent[i] = i`
   - `sz[i] = 1`
2. Maintain global variables:
   - `components = n`
   - `max_size = 1`
3. For each of the $m$ roads $(u, v)$:
   - `root_u = dsu.find(u)`
   - `root_v = dsu.find(v)`
   - If `root_u != root_v`:
     - Merge smaller tree into larger tree.
     - `components--`
     - Update `max_size = max(max_size, sz[root_u])`
   - Print `components` and `max_size`.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct DSU {
    vector<int> parent;
    vector<int> sz;
    int components;
    int max_size;

    DSU(int n) : components(n), max_size(1) {
        parent.resize(n + 1);
        sz.assign(n + 1, 1);
        for (int i = 1; i <= n; ++i) {
            parent[i] = i;
        }
    }

    int find(int i) {
        if (parent[i] == i)
            return i;
        return parent[i] = find(parent[i]); // Path compression
    }

    void unite(int i, int j) {
        int root_i = find(i);
        int root_j = find(j);

        if (root_i != root_j) {
            // Union by size
            if (sz[root_i] < sz[root_j])
                swap(root_i, root_j);

            parent[root_j] = root_i;
            sz[root_i] += sz[root_j];

            components--;
            max_size = max(max_size, sz[root_i]);
        }
    }
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    DSU dsu(n);

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        dsu.unite(u, v);
        cout << dsu.components << ' ' << dsu.max_size << '\n';
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(m \cdot \alpha(n))$.
  Each edge triggers at most two `find` operations and one `unite` operation.
  With path compression and union by size, the amortized cost per operation is $\mathcal{O}(\alpha(n)) \le 4$.
  Total operations: $\approx 2 \cdot 10^5 \times 4 \approx 8 \cdot 10^5$, running in $\approx 0.05\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ for the `parent` and `sz` arrays ($\approx 800\text{ KB}$).

---

## 6. Correctness Proof

### Invariants Maintained by DSU
- **Invariant 1 (Component Count)**:
  Initially, there are $n$ singleton components. Whenever an edge $(u, v)$ is added between two vertices with $\text{find}(u) \ne \text{find}(v)$, two previously disjoint components are merged into one. Hence, the number of components decreases by exactly 1. If $\text{find}(u) == \text{find}(v)$, the edge connects two vertices in the same component, so the number of components is unchanged.
- **Invariant 2 (Maximum Component Size)**:
  Initially, all components have size 1, so $\text{max\_size} = 1$. When two components with sizes $S_1$ and $S_2$ merge, the new component has size $S_1 + S_2$. Since sizes are non-negative and no component shrinks, the maximum size either remains unchanged or increases to $S_1 + S_2$. Updating $\text{max\_size} \leftarrow \max(\text{max\_size}, S_1 + S_2)$ maintains the global maximum accurately at all times. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 5, m = 3$:
- Initial: `components = 5`, `max_size = 1`.
- **Road 1: (1, 2)**
  - $\text{find}(1) = 1, \text{find}(2) = 2 \implies$ Merge!
  - `sz[1] = 1 + 1 = 2`.
  - `components = 5 - 1 = 4`.
  - `max_size = max(1, 2) = 2`.
  - Output: `4 2`.
- **Road 2: (1, 3)**
  - $\text{find}(1) = 1, \text{find}(3) = 3 \implies$ Merge!
  - `sz[1] = 2 + 1 = 3`.
  - `components = 4 - 1 = 3`.
  - `max_size = max(2, 3) = 3`.
  - Output: `3 3`.
- **Road 3: (4, 5)**
  - $\text{find}(4) = 4, \text{find}(5) = 5 \implies$ Merge!
  - `sz[4] = 1 + 1 = 2`.
  - `components = 3 - 1 = 2`.
  - `max_size = max(3, 2) = 3`.
  - Output: `2 3`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Redundant Roads (Cycle Formation)**:
   If a road connects two cities that are already connected, $\text{find}(u) == \text{find}(v)$. The condition `root_i != root_j` evaluates to false, correctly printing the previous `components` and `max_size` without modification.
2. **Parallel Roads & Self-Loops**:
   - Self-loops: $u == v \implies \text{find}(u) == \text{find}(v)$, handled automatically.
   - Parallel roads: second copy connects already united nodes, handled automatically.
3. **Graph Fully Connected Early**:
   When `components` reaches 1, subsequent edge additions leave `components = 1` and `max_size = n`.
4. **Fast I/O**:
   $2 \cdot 10^5$ lines of output require Fast I/O (`\n` instead of `endl`) to avoid I/O bottlenecks.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if we also need to support edge deletions (Fully Dynamic Connectivity)?**
   Standard DSU cannot handle edge removals. Fully dynamic connectivity requires **Euler Tour Trees (ETT)** or **Link-Cut Trees**, or randomized cut-edge sampling running in $\mathcal{O}(\log^2 n)$ per operation.
2. **What if we only need to query connectivity between specific pairs offline?**
   Use standard DSU. If edge additions and deletions occur offline in a known sequence, use **CDQ Divide and Conquer / Segment Tree over Time with DSU with Rollback** in $\mathcal{O}(m \log^2 n)$.
3. **Why does DSU with Rollback avoid path compression?**
   Path compression mutates multiple parent pointers irreversibly during `find`. DSU with rollback uses only union by size/rank and records changes on an undo stack, achieving $\mathcal{O}(\log n)$ per operation with $\mathcal{O}(1)$ rollback.
4. **Can this be solved using BFS/DFS if edge weights exist?**
   No, BFS/DFS would re-traverse the graph on each query, resulting in $\mathcal{O}(m(n + m)) \approx 10^{10}$ operations (TLE). DSU is strictly required.
5. **How does Inverse Ackermann $\alpha(n)$ behave asymptotically?**
   For all practical values of $n \le 10^{80}$ (atoms in the observable universe), $\alpha(n) \le 4$. Hence, DSU operations run in effectively constant $\mathcal{O}(1)$ time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, DSU, Disjoint Set Union, Dynamic Connectivity, Connected Components
- **Complexity Summary**:
  - Time: $\mathcal{O}(m \cdot \alpha(n))$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - [Road Reparation](https://cses.fi/problemset/task/1675) — Minimum Spanning Tree with DSU
  - [Building Roads](https://cses.fi/problemset/task/1666) — Static connected components
  - [Planets and Kingdoms](https://cses.fi/problemset/task/1683) — Strongly connected components
