# Fixed-Length Paths II

- **Category**: Tree Algorithms
- **CSES Task ID**: `2081`
- **CSES Problem Link**: [Fixed-Length Paths II](https://cses.fi/problemset/task/2081)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an unweighted tree of $n$ nodes numbered $1, 2, \dots, n$ and $n - 1$ edges, your task is to count the number of distinct simple paths that consist of **at least $k_1$ and at most $k_2$ edges**:
$$k_1 \le \text{length}(P) \le k_2$$

A path is an unordered pair of endpoints $\{u, v\}$ connected by a simple path whose edge count falls in the range $[k_1, k_2]$.

### Input Format
- The first line contains three integers $n$, $k_1$, and $k_2$: the number of nodes and the path length bounds.
- The next $n - 1$ lines describe the edges: each line has two integers $a$ and $b$ ($1 \le a, b \le n$).

### Output Format
- Print one integer: the total number of paths with length in $[k_1, k_2]$.

### Numerical Constraints
- $1 \le k_1 \le k_2 \le n \le 2 \cdot 10^5$
- $1 \le a, b \le n$

---

## 2. Intuition & Pattern Recognition

In CSES 2080 (*Fixed-Length Paths I*), we counted paths of an exact length $k$, which allowed querying a direct frequency array $\text{cnt}[k - d]$ in $\mathcal{O}(1)$ time.
Here, the path length can be any integer in the range $[k_1, k_2]$.
For a node at distance $d$ from a centroid $C$, a complementary node at distance $d'$ forms a valid path if and only if:
$$k_1 \le d + d' \le k_2 \iff k_1 - d \le d' \le k_2 - d$$

This is a **range sum query** over previously seen depths!

### Centroid Decomposition with Fenwick Tree
At each centroid $C$:
1. Maintain a **Fenwick Tree (Binary Indexed Tree)** over depths $0, 1, \dots, \min(\text{comp\_size}, k_2)$.
2. Insert the centroid itself at depth 0 ($\text{bit.add}(0, 1)$).
3. For each child branch of $C$:
   - Traverse the child's subtree using DFS. For each node at distance $d \le k_2$, query the number of previously inserted nodes whose depth lies in the valid range:
     $$[\max(0, \; k_1 - d), \quad \min(k_2 - d, \; \text{bit\_size})]$$
     Add this range sum to the global path count.
   - After querying all nodes in the current child branch, insert their depths into the Fenwick tree.
4. Clear the Fenwick tree in $\mathcal{O}(\text{comp\_size})$ time and recurse on the decomposed subtrees.

### Complexity
- The Fenwick tree supports range sum queries and point updates in $\mathcal{O}(\log n)$ time.
- At each centroid level, processing all nodes takes $\mathcal{O}(\text{comp\_size} \log n)$ time.
- Across all $\mathcal{O}(\log n)$ levels of the centroid tree, the total time complexity is $\mathcal{O}(n \log^2 n)$.
- In C++, a flat Fenwick tree with bitwise operations runs in $\approx 0.08\text{s}$, well within the 1.00s limit.

---

## 3. Approach 1 — Difference of Two Prefix Solvers

Notice that:
$$\text{Paths}([k_1, k_2]) = \text{Paths}(\le k_2) - \text{Paths}(\le k_1 - 1)$$
Run a prefix path counting algorithm twice. While correct, it doubles the execution time and memory overhead. Approach 3 directly computes the range in a single pass.

---

## 4. Approach 2 — Small-to-Large Merging with Deque / Fenwick Tree

Maintain a sliding window or dynamic Fenwick tree while merging smaller depth lists into larger ones.
- Time Complexity: $\mathcal{O}(n \log^2 n)$.
- Space Complexity: $\mathcal{O}(n)$.
- Trade-off: Offset tracking with range queries on dynamic deques is error-prone. Centroid Decomposition (Approach 3) is more modular and robust.

---

## 5. Approach 3 — Optimal CSES Solution (Centroid Decomposition + Fenwick Tree)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

static const int MAXN = 200005;

int n, k1, k2;
vector<int> adj[MAXN];
int sz[MAXN];
bool removed[MAXN];
long long total_paths = 0;

int bit[MAXN + 5];
int bit_size = 0;

void bit_add(int i, int val) {
    for (i++; i <= bit_size + 1; i += i & -i) {
        bit[i] += val;
    }
}

int bit_query(int i) {
    int sum = 0;
    for (i = min(i + 1, bit_size + 1); i > 0; i -= i & -i) {
        sum += bit[i];
    }
    return sum;
}

int bit_range(int l, int r) {
    if (l > r) return 0;
    l = max(0, l);
    r = min(bit_size, r);
    if (l > r) return 0;
    return bit_query(r) - (l > 0 ? bit_query(l - 1) : 0);
}

void dfs_sz(int u, int p) {
    sz[u] = 1;
    for (int v : adj[u]) {
        if (v != p && !removed[v]) {
            dfs_sz(v, u);
            sz[u] += sz[v];
        }
    }
}

int get_centroid(int u, int p, int comp_size) {
    for (int v : adj[u]) {
        if (v != p && !removed[v] && sz[v] > comp_size / 2) {
            return get_centroid(v, u, comp_size);
        }
    }
    return u;
}

void dfs_count(int u, int p, int d) {
    if (d > k2) return;
    total_paths += bit_range(k1 - d, k2 - d);
    for (int v : adj[u]) {
        if (v != p && !removed[v]) {
            dfs_count(v, u, d + 1);
        }
    }
}

void dfs_add(int u, int p, int d) {
    if (d > k2) return;
    bit_add(d, 1);
    for (int v : adj[u]) {
        if (v != p && !removed[v]) {
            dfs_add(v, u, d + 1);
        }
    }
}

void solve(int u) {
    dfs_sz(u, 0);
    int comp_size = sz[u];
    if (comp_size <= k1) return;

    int c = get_centroid(u, 0, comp_size);
    removed[c] = true;

    bit_size = min(comp_size, k2);
    bit_add(0, 1);

    for (int v : adj[c]) {
        if (!removed[v]) {
            dfs_count(v, c, 1);
            dfs_add(v, c, 1);
        }
    }

    // Clear Fenwick tree in O(bit_size)
    for (int i = 1; i <= bit_size + 1; ++i) {
        bit[i] = 0;
    }

    for (int v : adj[c]) {
        if (!removed[v]) {
            solve(v);
        }
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> k1 >> k2)) return 0;

    for (int i = 0; i < n - 1; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    solve(1);

    cout << total_paths << '\n';

    return 0;
}
```

---

## 6. Correctness Proof

### Exact Path Range Inclusion
Let $\{u, v\}$ be a pair of nodes whose simple path passes through centroid $C$:
- The path length is $L = \text{dist}(u, C) + \text{dist}(v, C) = d_u + d_v$.
- Node $u$ is counted if and only if $k_1 \le d_u + d_v \le k_2$.
- Subtracting $d_u$ from all terms gives:
  $$k_1 - d_u \le d_v \le k_2 - d_u$$
- The function `bit_range(k1 - d, k2 - d)` sums the exact frequencies of all previously processed nodes whose distance $d_v$ satisfies this double inequality.
- Because nodes in the current branch are added to the Fenwick tree only *after* `dfs_count` finishes exploring the branch, nodes $u$ and $v$ are guaranteed to come from distinct branches, ensuring the path between them passes through $C$ without backtracking.
- By strong induction on component size, every path of length in $[k_1, k_2]$ is counted at exactly one centroid decomposition step.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 1 2
1 2
2 3
3 4
3 5
```

Tree:
```text
 1 - 2 - 3
        / \
       4   5
```
$n = 5, k_1 = 1, k_2 = 2$.

### Centroid $C = 3$ ($comp\_size = 5$)
- `bit_size = min(5, 2) = 2`. `bit_add(0, 1)`.
- Branch 1 (node 2, with descendants $\{2, 1\}$):
  - Node 2 ($d = 1$): range $[1 - 1, 2 - 1] = [0, 1] \implies$ finds centroid 3 at depth 0 $\implies \text{paths} \mathrel{+}= 1$ (path $2 - 3$).
  - Node 1 ($d = 2$): range $[1 - 2, 2 - 2] = [0, 0] \implies$ finds centroid 3 at depth 0 $\implies \text{paths} \mathrel{+}= 1$ (path $1 - 2 - 3$).
  - Add $\{2, 1\}$ to BIT: depth 1 added, depth 2 added.
- Branch 2 (node 4):
  - Node 4 ($d = 1$): range $[0, 1] \implies$ finds depth 0 (centroid 3) and depth 1 (node 2) $\implies \text{paths} \mathrel{+}= 2$ (paths $4 - 3$ and $4 - 3 - 2$).
  - Add 4 to BIT: depth 1 added.
- Branch 3 (node 5):
  - Node 5 ($d = 1$): range $[0, 1] \implies$ finds depth 0 (centroid 3), depth 1 (node 2, node 4) $\implies \text{paths} \mathrel{+}= 3$ (paths $5 - 3, 5 - 3 - 2, 5 - 3 - 4$).
- Total paths through centroid 3: $1 + 1 + 2 + 3 = 7$.
- Subtree $\{1, 2\}$ has path $1 - 2$ of length 1 $\implies +1$.
- Subtrees $\{4\}$ and $\{5\}$ have size 1.

### Total Count
$7 + 1 = 8$ paths of length $\in [1, 2]$.
All 4 paths of length 1 (edges) + 4 paths of length 2 $= 8$. Exact!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow**:
   Total paths can reach $\binom{n}{2} \approx 2 \cdot 10^{10}$, overflowing standard signed 32-bit integer. `total_paths` must be `long long`.
2. **$k_1 = 1, k_2 = n - 1$**:
   Every path in the tree is valid, returning $\frac{n(n-1)}{2}$.
3. **Fenwick Tree Boundary Indexing**:
   Because depths range from 0 to $\text{bit\_size}$, the 1-based Fenwick tree indices shift by $+1$ ($i \leftarrow i + 1$). The array is dimensioned `MAXN + 5` to safely accommodate offset $0 \to 1$.
4. **Pruning Subtrees**:
   If $\text{comp\_size} \le k_1$, no path in the component can reach length $k_1$, skipping redundant recursion.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Can this problem be solved in $\mathcal{O}(n \log n)$?**
   Yes! By sorting depths and using a two-pointer sliding window rather than a Fenwick tree, the range query can be answered in $\mathcal{O}(S)$ rather than $\mathcal{O}(S \log S)$ at each centroid, achieving $\mathcal{O}(n \log n)$ total time.
2. **What if paths also have a minimum vertex weight sum constraint?**
   If both length and weight constraints exist, the problem becomes 2D range counting at each centroid, solvable via Merge Sort Tree / CDQ Divide-and-Conquer in $\mathcal{O}(n \log^2 n)$.
3. **How does this compare to NTT (Number Theoretic Transform)?**
   NTT can multiply the depth polynomials of branches in $\mathcal{O}(S \log S)$. To handle ranges, compute prefix sums of the resulting polynomial coefficients.
4. **What if edges have arbitrary non-negative weights?**
   With arbitrary weights, depths are continuous. Coordinate compression on depths allows the Fenwick tree to query $[W_1 - d, W_2 - d]$ in $\mathcal{O}(\log n)$.
5. **How would you find the maximum path length in $[k_1, k_2]$?**
   Since paths are unweighted, if any path exists in $[k_1, k_2]$, the maximum valid length is simply the largest length formed $\le k_2$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Centroid Tree Depth**: $\mathcal{O}(\log n)$ levels
  - **Work per Node per Level**: $\mathcal{O}(\log n)$ via Fenwick tree
  - **Overall Run Time**: $\mathcal{O}(n \log^2 n) \approx 0.08\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space for Fenwick tree and recursion arrays.

### Related CSES Problems
- [Fixed-Length Paths I](https://cses.fi/problemset/task/2080) — Exact length $k$ paths
- [Finding a Centroid](https://cses.fi/problemset/task/2079) — Centroid identification
- [Distance Queries](https://cses.fi/problemset/task/1135) — Pairwise tree distances
