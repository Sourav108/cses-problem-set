# Tree Distances II

- **Category**: Tree Algorithms
- **CSES Task ID**: `1133`
- **CSES Problem Link**: [Tree Distances II](https://cses.fi/problemset/task/1133)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a tree consisting of $n$ nodes numbered $1, 2, \dots, n$ and $n - 1$ edges.

Your task is to determine, for **every node** $x \in [1, n]$, the **sum of the distances** from node $x$ to all other nodes in the tree:
$$S(x) = \sum_{y=1}^n \text{dist}(x, y)$$

### Input Format
- The first line contains an integer $n$: the number of nodes.
- The next $n - 1$ lines describe the edges: each line has two integers $a$ and $b$ ($1 \le a, b \le n$).

### Output Format
- Print $n$ integers: the sum of distances for each node $1, 2, \dots, n$.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le a, b \le n$

---

## 2. Intuition & Pattern Recognition

Computing the distance sum for a single node takes $\mathcal{O}(n)$ via BFS. Doing so independently for all $n$ nodes would take $\mathcal{O}(n^2)$ time ($\approx 4 \cdot 10^{10}$ operations), which is far too slow.

Notice the fundamental relationship between the distance sums of two adjacent nodes $u$ and $v$ connected by an edge $(u, v)$:
- Deleting the edge $(u, v)$ partitions the tree into two disjoint components:
  1. The component containing $v$ (which corresponds to the subtree of $v$ when rooted at $u$). Let its size be $\text{sz}[v]$.
  2. The component containing $u$, consisting of all other $n - \text{sz}[v]$ nodes.
- When moving the perspective from $u$ to $v$:
  - Every node in $v$'s component is now **1 edge closer** to $v$ than it was to $u$.
    This decreases the total sum by $\text{sz}[v] \times 1$.
  - Every node outside $v$'s component is now **1 edge farther** from $v$ than it was to $u$.
    This increases the total sum by $(n - \text{sz}[v]) \times 1$.
- Consequently:
  $$S(v) = S(u) - \text{sz}[v] + (n - \text{sz}[v]) = S(u) + n - 2 \cdot \text{sz}[v]$$

This is the canonical textbook application of **Tree Rerooting Dynamic Programming (Up-Down Tree DP)**:
1. **Pass 1 (Bottom-Up DFS)**:
   Root the tree arbitrarily at node 1.
   Compute subtree size $\text{sz}[u]$ and the downward distance sum within $u$'s subtree:
   $$\text{dp}[u] = \sum_{v \in \text{children}(u)} (\text{dp}[v] + \text{sz}[v])$$
   The total answer for root 1 is $S(1) = \text{dp}[1]$.
2. **Pass 2 (Top-Down DFS / Rerooting)**:
   For each child $v$ of $u$, compute $S(v) = S(u) + n - 2 \cdot \text{sz}[v]$ in $\mathcal{O}(1)$ time and recurse.

Both passes take $\mathcal{O}(n)$ time and $\mathcal{O}(n)$ space.

---

## 3. Approach 1 — Naive BFS from Every Node

Run a BFS from each node $x \in [1, n]$ and sum its distances.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot (V + E)) = \mathcal{O}(n^2) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Centroid Decomposition with Distance Counting

Build a Centroid Tree. For each node, accumulate distances through its $\mathcal{O}(\log n)$ centroid ancestors.
- **Time Complexity**: $\mathcal{O}(n \log n)$.
- **Space Complexity**: $\mathcal{O}(n \log n)$.
- **Trade-off**: Useful when trees have dynamic path updates, but overly complex for static all-nodes distance sums. Approach 3 achieves optimal $\mathcal{O}(n)$ time in two simple DFS passes.

---

## 5. Approach 3 — Optimal CSES Solution (Tree Rerooting DP)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

int n;
vector<vector<int>> adj;
vector<long long> sz;
vector<long long> dp_down;
vector<long long> ans;

// Pass 1: Compute subtree sizes and downward distance sums
void dfs1(int u, int p) {
    sz[u] = 1;
    dp_down[u] = 0;

    for (int v : adj[u]) {
        if (v == p) continue;
        dfs1(v, u);
        sz[u] += sz[v];
        dp_down[u] += dp_down[v] + sz[v];
    }
}

// Pass 2: Rerooting top-down pass
void dfs2(int u, int p) {
    for (int v : adj[u]) {
        if (v == p) continue;
        // ans[v] = ans[u] - sz[v] + (n - sz[v])
        ans[v] = ans[u] + n - 2 * sz[v];
        dfs2(v, u);
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n)) return 0;

    adj.assign(n + 1, vector<int>());
    sz.assign(n + 1, 0);
    dp_down.assign(n + 1, 0);
    ans.assign(n + 1, 0);

    for (int i = 0; i < n - 1; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    dfs1(1, 0);
    ans[1] = dp_down[1];
    dfs2(1, 0);

    for (int i = 1; i <= n; ++i) {
        cout << ans[i] << (i == n ? "" : " ");
    }
    cout << '\n';

    return 0;
}
```

---

## 6. Correctness Proof

### Pass 1 Invariant (Downward Distances)
For any node $u$:
$$\text{dp\_down}[u] = \sum_{x \in \text{subtree}(u)} \text{dist}(u, x)$$
- If $u$ is a leaf, $\text{subtree}(u) = \{u\}$, giving $\text{dp\_down}[u] = 0$ and $\text{sz}[u] = 1$.
- For an internal node $u$, any descendant $x \in \text{subtree}(v)$ passes through child $v$:
  $$\text{dist}(u, x) = 1 + \text{dist}(v, x)$$
  Summing over all $x \in \text{subtree}(v)$:
  $$\sum_{x \in \text{subtree}(v)} (1 + \text{dist}(v, x)) = \text{sz}[v] + \text{dp\_down}[v]$$
  Summing across all children $v$ yields the exact sum of downward distances.
  For root node 1, $\text{subtree}(1) = V$, so $\text{ans}[1] = \text{dp\_down}[1] = S(1)$.

### Pass 2 Invariant (Rerooting Transition)
Let $u$ be the parent of $v$.
The tree nodes partition into two sets: $A = \text{subtree}(v)$ and $B = V \setminus \text{subtree}(v)$.
- $|A| = \text{sz}[v]$ and $|B| = n - \text{sz}[v]$.
- For every $x \in A$, the unique path from $v$ to $x$ does not use edge $(u, v)$, while the path from $u$ to $x$ uses edge $(u, v)$. Thus $\text{dist}(v, x) = \text{dist}(u, x) - 1$.
- For every $y \in B$, the unique path from $v$ to $y$ uses edge $(u, v)$. Thus $\text{dist}(v, y) = \text{dist}(u, y) + 1$.
- Summing over all vertices:
  $$S(v) = \sum_{x \in A} (\text{dist}(u, x) - 1) + \sum_{y \in B} (\text{dist}(u, y) + 1) = S(u) - |A| + |B| = S(u) + n - 2 \cdot \text{sz}[v]$$
By induction on tree depth, $\text{ans}[v]$ is exact for all nodes $v \in V$.

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

### Pass 1: Bottom-Up DFS from 1
- Leaves:
  - `sz[2] = 1, dp_down[2] = 0`
  - `sz[4] = 1, dp_down[4] = 0`
  - `sz[5] = 1, dp_down[5] = 0`
- Node 3:
  - `sz[3] = 1 + sz[4] + sz[5] = 1 + 1 + 1 = 3`
  - `dp_down[3] = (0 + 1) + (0 + 1) = 2`
- Root 1:
  - `sz[1] = 1 + sz[2] + sz[3] = 1 + 1 + 3 = 5`
  - `dp_down[1] = (dp_down[2] + sz[2]) + (dp_down[3] + sz[3]) = (0 + 1) + (2 + 3) = 6`
- Total answer for node 1: `ans[1] = 6`.
  (Verification: distances from 1: to 2 is 1, to 3 is 1, to 4 is 2, to 5 is 2. Sum $= 1 + 1 + 2 + 2 = 6$).

### Pass 2: Top-Down Rerooting ($n = 5$)
- Child 2 of 1:
  `ans[2] = ans[1] + n - 2 * sz[2] = 6 + 5 - 2(1) = 9`.
  (Distances from 2: to 1: 1, to 3: 2, to 4: 3, to 5: 3. Sum $= 1 + 2 + 3 + 3 = 9$).
- Child 3 of 1:
  `ans[3] = ans[1] + n - 2 * sz[3] = 6 + 5 - 2(3) = 5`.
  (Distances from 3: to 1: 1, to 2: 2, to 4: 1, to 5: 1. Sum $= 1 + 2 + 1 + 1 = 5$).
- Child 4 of 3:
  `ans[4] = ans[3] + n - 2 * sz[4] = 5 + 5 - 2(1) = 8`.
- Child 5 of 3:
  `ans[5] = ans[3] + n - 2 * sz[5] = 5 + 5 - 2(1) = 8`.

### Final Answers
`6 9 5 8 8` — exactly matches ground truth.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow**:
   For a line graph $P_n$ with $n = 2 \cdot 10^5$, distance sum for an endpoint is $\sum_{i=1}^{n-1} i = \frac{n(n-1)}{2} \approx \frac{4 \cdot 10^{10}}{2} = 2 \cdot 10^{10}$, which overflows 32-bit signed integer (`int` max $\approx 2.14 \cdot 10^9$). `ans`, `dp_down`, and `sz` must be `long long`.
2. **Single Node ($n = 1$)**:
   $n = 1$. Both loops do not execute. Outputs `0`.
3. **Star Graph**:
   Center has distance sum $n - 1$. Each leaf has distance sum $1 + 2(n - 2) = 2n - 3$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Which node minimizes the sum of distances $\sum_y \text{dist}(x, y)$?**
   The vertex that minimizes the total distance sum is precisely the **centroid** of the tree (CSES 2079)!
2. **What if edges have arbitrary non-negative weights $w_e$?**
   The formula generalizes to:
   $$S(v) = S(u) + w(u, v) \cdot (n - 2 \cdot \text{sz}[v])$$
3. **What if each node $y$ has a population weight $p_y$, and we want $\sum_y p_y \text{dist}(x, y)$?**
   Replace subtree size $\text{sz}[u]$ with subtree population weight $\text{weight}[u] = \sum_{x \in \text{subtree}(u)} p_x$. The formula becomes $S(v) = S(u) + (W - 2 \cdot \text{weight}[v])$ where $W = \sum_{y} p_y$.
4. **How does this connect to the Wiener Index of a tree?**
   The Wiener Index $W(T) = \sum_{u < v} \text{dist}(u, v)$ is half the sum of all distance sums:
   $$W(T) = \frac{1}{2} \sum_{x=1}^n S(x) = \sum_{e = (u, v)} \text{sz}[v] \cdot (n - \text{sz}[v])$$
5. **How would you maintain distance sums under dynamic tree link/cut operations?**
   Use a **Centroid Tree** or **Link-Cut Tree** with aggregated subtree sizes, supporting dynamic rerooting in $\mathcal{O}(\log^2 n)$ or $\mathcal{O}(\log n)$ time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**: $\mathcal{O}(n)$ — Exactly two DFS traversals visiting each edge twice.
- **Space Complexity**: $\mathcal{O}(n)$ — Adjacency list and DP vectors.

### Related CSES Problems
- [Tree Distances I](https://cses.fi/problemset/task/1132) — Maximum distance from every node
- [Finding a Centroid](https://cses.fi/problemset/task/2079) — Minimizer of the distance sum
- [Distance Queries](https://cses.fi/problemset/task/1135) — Pairwise distances via LCA
