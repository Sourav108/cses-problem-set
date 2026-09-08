# Finding a Centroid

- **Category**: Tree Algorithms
- **CSES Task ID**: `2079`
- **CSES Problem Link**: [Finding a Centroid](https://cses.fi/problemset/task/2079)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given a tree of $n$ nodes numbered $1, 2, \dots, n$ and $n - 1$ edges, your task is to find a **centroid** of the tree.

A node $C$ is a centroid if, when $C$ is chosen as the root of the tree, each of its resulting subtrees has at most $\lfloor n / 2 \rfloor$ nodes:
$$\text{size}(v) \le \lfloor n / 2 \rfloor \quad \text{for all children } v \text{ of } C$$

Equivalently, removing node $C$ partitions the tree into connected components, each containing at most $\lfloor n / 2 \rfloor$ nodes.
If there are multiple centroids, printing any one of them is acceptable.

### Input Format
- The first line contains an integer $n$: the number of nodes.
- The next $n - 1$ lines describe the edges: each line has two integers $a$ and $b$ ($1 \le a, b \le n$).

### Output Format
- Print one integer: the index of a centroid.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le a, b \le n$

---

## 2. Intuition & Pattern Recognition

The centroid of a tree is the structural center of mass:
- By **Jordan's 1869 Centroid Theorem**, every tree has at least one and at most two centroids. If two centroids exist, they are directly adjacent.
- The centroid is the foundation of **Centroid Decomposition** (divide-and-conquer on trees), which guarantees logarithmic recursion depth $\mathcal{O}(\log n)$ because every subtree size is halved at each decomposition step.

### Greedy Descent Algorithm
1. Root the tree arbitrarily at node 1 and compute all subtree sizes $\text{sz}[u]$ via a bottom-up DFS in $\mathcal{O}(n)$ time.
2. Start at the current candidate node $u = 1$.
3. Inspect all neighbors $v$ of $u$ (excluding $u$'s parent):
   - If there exists a child $v$ with:
     $$\text{sz}[v] > \frac{n}{2}$$
     then node $u$ cannot be a centroid (its child's subtree is too large).
     Furthermore, because $\text{sz}[v] > n/2$, the sum of sizes of all other branches is $< n/2$.
     Therefore, the centroid **must lie strictly inside the subtree of $v$**!
     Step down into $v$ ($u \leftarrow v$) and repeat.
   - If **no child** of $u$ has $\text{sz}[v] > n/2$:
     - Every child subtree has size $\le n/2$.
     - The component containing $u$'s parent has size $n - \text{sz}[u]$.
       Because we stepped into $u$ from a parent where $\text{sz}[u] > n/2$, we have $n - \text{sz}[u] < n - n/2 \le n/2$.
     - Therefore, **all** components connected to $u$ have size $\le n/2$!
     - Node $u$ is a valid centroid. Terminate and return $u$.

Because $\text{sz}[u]$ strictly decreases at each step, this greedy walk terminates in at most tree depth steps, taking $\mathcal{O}(n)$ total time.

---

## 3. Approach 1 — Subtree Evaluation from Every Node

For each node $u \in [1, n]$, run a separate DFS rooting the tree at $u$ and check whether all branch sizes are $\le \lfloor n / 2 \rfloor$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Finding Minimizer of Distance Sum

Recall from CSES 1133 (*Tree Distances II*) that the centroid of a tree is the vertex that minimizes the sum of distances to all other nodes:
$$C = \arg\min_{x \in V} \sum_{y=1}^n \text{dist}(x, y)$$
- Run the Tree Rerooting DP from CSES 1133 in $\mathcal{O}(n)$ time to find the node with minimum total distance.
- While mathematically correct, the greedy descent (Approach 3) is more direct, simpler to implement, and requires only subtree sizes rather than distance sums.

---

## 5. Approach 3 — Optimal CSES Solution (Subtree Sizes + Greedy Walk)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

int n;
vector<vector<int>> adj;
vector<int> sz;

void dfs_sz(int u, int p) {
    sz[u] = 1;
    for (int v : adj[u]) {
        if (v != p) {
            dfs_sz(v, u);
            sz[u] += sz[v];
        }
    }
}

int find_centroid(int u, int p) {
    for (int v : adj[u]) {
        if (v != p && sz[v] > n / 2) {
            return find_centroid(v, u);
        }
    }
    return u;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n)) return 0;

    adj.assign(n + 1, vector<int>());
    sz.assign(n + 1, 0);

    for (int i = 0; i < n - 1; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    dfs_sz(1, 0);

    int centroid = find_centroid(1, 0);

    cout << centroid << '\n';

    return 0;
}
```

---

## 6. Correctness Proof

### Existence and Uniqueness Properties
Let $T$ be a tree with $n$ nodes rooted at node 1.
1. **At Most One Child with $\text{sz}[v] > n / 2$**:
   Suppose for contradiction that node $u$ had two distinct children $v_1$ and $v_2$ such that $\text{sz}[v_1] > n / 2$ and $\text{sz}[v_2] > n / 2$.
   Because the subtrees of distinct children are disjoint, the total size would be:
   $$n \ge \text{sz}[u] \ge 1 + \text{sz}[v_1] + \text{sz}[v_2] > 1 + \frac{n}{2} + \frac{n}{2} = n + 1$$
   which is a contradiction.
   Therefore, at any node $u$, there is **at most one** child $v$ satisfying $\text{sz}[v] > n / 2$.

2. **Necessity of Stepping Down**:
   If child $v$ has $\text{sz}[v] > n / 2$, then any node $x$ outside the subtree of $v$ leaves the component containing $v$ with size $\ge \text{sz}[v] > n / 2$.
   Thus, no node outside $\text{subtree}(v)$ can ever be a centroid. The search must move into $v$.

3. **Sufficiency of the Termination Condition**:
   When the algorithm stops at $u$ because no child has $\text{sz}[v] > n / 2$:
   - Every child component has size $\le \lfloor n / 2 \rfloor$.
   - The upward parent component has size:
     $$n - \text{sz}[u]$$
     If $u$ is the root (node 1), $n - \text{sz}[1] = 0 \le n/2$.
     If $u \ne 1$, the algorithm only stepped into $u$ from its parent $p$ because $\text{sz}[u] > n / 2$.
     Hence $n - \text{sz}[u] < n - n/2 \le n/2$.
   Therefore, all components connected to $u$ have size $\le \lfloor n / 2 \rfloor$.
   Node $u$ satisfies the centroid definition. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5
1 2
2 3
3 4
3 5
```

Tree Structure:
```text
 1 - 2 - 3
        / \
       4   5
```

Root at 1:
- Subtree sizes:
  - $\text{sz}[4] = 1$
  - $\text{sz}[5] = 1$
  - $\text{sz}[3] = 1 + 1 + 1 = 3$
  - $\text{sz}[2] = 1 + 3 = 4$
  - $\text{sz}[1] = 1 + 4 = 5$

Threshold: $n / 2 = 5 / 2 = 2$.
Need all components $\le 2$.

### Greedy Descent
1. Start at `find_centroid(1, 0)`:
   - Child 2 has $\text{sz}[2] = 4 > 2$.
   - Move to 2: call `find_centroid(2, 1)`.
2. At node 2:
   - Child 3 has $\text{sz}[3] = 3 > 2$.
   - Move to 3: call `find_centroid(3, 2)`.
3. At node 3:
   - Child 4 has $\text{sz}[4] = 1 \le 2$.
   - Child 5 has $\text{sz}[5] = 1 \le 2$.
   - No child has size $> 2$.
   - Check parent branch: $n - \text{sz}[3] = 5 - 3 = 2 \le 2$.
   - Node 3 is a centroid!

### Output
`3` — Removing node 3 partitions the tree into components $\{1, 2\}$ (size 2), $\{4\}$ (size 1), $\{5\}$ (size 1), all $\le 2$.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Even $n$ with Two Centroids**:
   For a path $1 - 2 - 3 - 4$ ($n = 4$):
   Both node 2 and node 3 are valid centroids (removing either leaves components of size $\le 2$). The algorithm outputs the first valid centroid encountered (node 2 or 3), which CSES accepts.
2. **Star Graph**:
   Center node has $n - 1$ children of size 1. Since $1 \le n / 2$ for $n \ge 2$, center node is immediately identified as the centroid.
3. **Single Node ($n = 1$)**:
   $n / 2 = 0$. $\text{sz}[1] = 1$. The loop finds no children, outputs `1`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How is the centroid used in Centroid Decomposition?**
   Find the centroid $C$, remove it, and recursively decompose the remaining subtrees. Because each subtree has size $\le n / 2$, the recursion depth is strictly bounded by $\mathcal{O}(\log n)$.
2. **What if edge weights are added? Does the centroid change?**
   The definition of the topological centroid depends only on node counts (unweighted sizes). If nodes have weights (population), the weighted centroid condition is $\text{weight}(v) \le W / 2$, which is found with identical greedy descent.
3. **Can a tree have 3 centroids?**
   No, at most 2. If two centroids exist, their distance is exactly 1 (they are connected by an edge), and $n$ must be even.
4. **How would you find both centroids if two exist?**
   If $n$ is even and the centroid $C$ has a neighbor $v$ such that the component containing $v$ has size exactly $n / 2$, then $v$ is the second centroid.
5. **How does the centroid relate to the tree center?**
   The tree **center** minimizes maximum distance (eccentricity) and lies on the diameter. The tree **centroid** minimizes the sum of distances and balances subtree sizes. In general, the center and centroid can be different vertices!

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Subtree Size DFS**: $\mathcal{O}(n)$
  - **Centroid Walk**: $\mathcal{O}(\text{depth}) \le \mathcal{O}(n)$
  - **Overall Run Time**: $\mathcal{O}(n) \approx 0.03\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary memory for adjacency list and size array.

### Related CSES Problems
- [Subordinates](https://cses.fi/problemset/task/1674) — Subtree sizes
- [Tree Distances II](https://cses.fi/problemset/task/1133) — Minimizing sum of distances
- [Fixed-Length Paths I](https://cses.fi/problemset/task/2080) — Path counting via Centroid Decomposition
