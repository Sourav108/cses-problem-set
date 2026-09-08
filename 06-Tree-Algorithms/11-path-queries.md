# Path Queries

- **Category**: Tree Algorithms
- **CSES Task ID**: `1138`
- **CSES Problem Link**: [Path Queries](https://cses.fi/problemset/task/1138)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a rooted tree consisting of $n$ nodes numbered $1, 2, \dots, n$, where node 1 is the root. Each node $i$ has an integer value $v_i$.

You must process $q$ queries of two types:
1. `1 s x`: **Update**: Change the value of node $s$ to $x$ ($v_s \leftarrow x$).
2. `2 s`: **Path Sum**: Calculate the sum of values on the path from the root (node 1) to node $s$.

All indices and node numbers are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the number of nodes and queries.
- The second line contains $n$ integers $v_1, v_2, \dots, v_n$: the initial node values.
- The next $n - 1$ lines describe the tree edges: each line has two integers $u$ and $v$.
- The next $q$ lines describe the queries:
  - `1 s x`
  - `2 s`

### Output Format
- For each query of type 2, print the path sum on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le v_i, x \le 10^9$
- $1 \le u, v \le n$
- $1 \le s \le n$

---

## 2. Intuition & Pattern Recognition

In CSES 1137 (*Subtree Queries*), updates were point modifications and queries were subtree range sums.
Here, the situation is reversed:
- We want to query the sum of values on the path from root 1 down to node $s$:
  $$\text{path\_sum}(s) = \sum_{u \in \text{Ancestors}(s) \cup \{s\}} v_u$$

### The Dual Perspective
Ask: *When the value of node $s$ increases by $\Delta = x - v_s$, which nodes have their root-to-node path sum affected?*
- Node $s$ belongs to the path from root 1 to node $u$ **if and only if** $s$ is an ancestor of $u$.
- In other words, $u$ must belong to the **subtree of $s$**!
- Therefore, changing $v_s$ by $\Delta$ increases $\text{path\_sum}(u)$ by $\Delta$ for **all** nodes $u \in \text{subtree}(s)$.

### Euler Tour Reduction
By flattening the tree via DFS entry and exit timestamps:
$$\text{subtree}(s) = [\text{tin}[s], \; \text{tout}[s]]$$
Thus:
1. **Update `1 s x`**:
   Add $\Delta = x - v_s$ to every element in the contiguous range $[\text{tin}[s], \text{tout}[s]]$.
2. **Query `2 s`**:
   Query the single point value at position $\text{tin}[s]$.

### Difference Array via Fenwick Tree
Range updates with point queries on a 1D array is the classic application of a **Difference Fenwick Tree**:
- To add $\Delta$ to range $[L, R]$:
  $$\text{bit.add}(L, \Delta), \quad \text{bit.add}(R + 1, -\Delta)$$
- To query the value at position $p$:
  $$\text{value}(p) = \text{bit.query}(p) = \sum_{i=1}^p \text{diff}[i]$$

This requires only a standard point-update prefix-sum Fenwick Tree of size $n + 1$, executing each update and query in $\mathcal{O}(\log n)$ time with zero recursion overhead during queries.

---

## 3. Approach 1 — Naive Parent Walking per Query

For each type 2 query, walk upward from $s$ to root 1, summing node values.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Heavy-Light Decomposition (HLD) + Segment Tree

Decompose root-to-$s$ paths into $\mathcal{O}(\log n)$ heavy chain intervals and query range sums on a Segment Tree. Point updates take $\mathcal{O}(\log n)$, and path queries take $\mathcal{O}(\log^2 n)$.
- While HLD works for general path queries between arbitrary pairs of nodes $(a, b)$, for root-to-node paths, the Euler Tour Difference Fenwick tree (Approach 3) is strictly faster ($\mathcal{O}(\log n)$ vs $\mathcal{O}(\log^2 n)$) and significantly simpler to implement.

---

## 5. Approach 3 — Optimal CSES Solution (Euler Tour + Difference Fenwick Tree)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

int n, q;
vector<vector<int>> adj;
vector<long long> val;
vector<int> tin, tout;
int timer = 0;

struct Fenwick {
    int n;
    vector<long long> tree;
    Fenwick(int n) : n(n), tree(n + 2, 0) {}

    void add(int i, long long delta) {
        for (; i <= n; i += i & -i) {
            tree[i] += delta;
        }
    }

    long long query(int i) const {
        long long sum = 0;
        for (; i > 0; i -= i & -i) {
            sum += tree[i];
        }
        return sum;
    }
};

void dfs(int u, int p) {
    tin[u] = ++timer;
    for (int v : adj[u]) {
        if (v != p) {
            dfs(v, u);
        }
    }
    tout[u] = timer;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> q)) return 0;

    val.assign(n + 1, 0);
    for (int i = 1; i <= n; ++i) {
        cin >> val[i];
    }

    adj.assign(n + 1, vector<int>());
    for (int i = 0; i < n - 1; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    tin.assign(n + 1, 0);
    tout.assign(n + 1, 0);
    dfs(1, 0);

    Fenwick bit(n);

    // Initial values: each node s contributes val[s] to its entire subtree [tin[s], tout[s]]
    for (int i = 1; i <= n; ++i) {
        bit.add(tin[i], val[i]);
        bit.add(tout[i] + 1, -val[i]);
    }

    while (q--) {
        int type;
        cin >> type;
        if (type == 1) {
            int s;
            long long x;
            cin >> s >> x;
            long long delta = x - val[s];
            val[s] = x;
            bit.add(tin[s], delta);
            bit.add(tout[s] + 1, -delta);
        } else {
            int s;
            cin >> s;
            cout << bit.query(tin[s]) << '\n';
        }
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Ancestor-Subtree Duality
Let $P(1, u)$ denote the set of vertices on the unique simple path from root 1 to node $u$.
By definition:
$$s \in P(1, u) \iff s \text{ is an ancestor of } u \iff u \in \text{subtree}(s)$$
From the Euler tour property proved in CSES 1137, $u \in \text{subtree}(s) \iff \text{tin}[s] \le \text{tin}[u] \le \text{tout}[s]$.
Therefore:
$$\text{path\_sum}(s) = \sum_{u \in P(1, s)} v_u = \sum_{u \in V} v_u \cdot [\text{tin}[u] \le \text{tin}[s] \le \text{tout}[u]]$$

### Difference Array Evaluation
In the difference array $D$, each node $u$ with weight $v_u$ adds $+v_u$ at index $\text{tin}[u]$ and $-v_u$ at index $\text{tout}[u] + 1$.
The prefix sum $\sum_{i=1}^{\text{tin}[s]} D[i]$ evaluates to:
$$\sum_{u \in V} v_u \cdot \Big([\text{tin}[u] \le \text{tin}[s]] - [\text{tout}[u] + 1 \le \text{tin}[s]]\Big) = \sum_{u \in V} v_u \cdot [\text{tin}[u] \le \text{tin}[s] \le \text{tout}[u]]$$
which equals $\text{path\_sum}(s)$ exactly.
Because the Fenwick tree implements prefix sums over difference array updates, every point query returns the exact sum of weights along the path from root 1 to node $s$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
4 2 5 2 1
1 2
1 3
3 4
3 5
2 4
1 3 2
2 4
```

Tree:
```text
      1 (val 4)
    /   \
   2     3 (val 5)
       /   \
      4     5
    (val 2) (val 1)
```

### DFS Timestamps
- `tin[1] = 1, tout[1] = 5`
- `tin[2] = 2, tout[2] = 2`
- `tin[3] = 3, tout[3] = 5`
- `tin[4] = 4, tout[4] = 4`
- `tin[5] = 5, tout[5] = 5`

### Query 1: `2 4` (Path sum from 1 to 4)
- Path consists of nodes: $1 \to 3 \to 4$.
- Values: $v_1 + v_3 + v_4 = 4 + 5 + 2 = 11$.
- In difference array:
  - Node 1 interval $[1, 5]$ covers index 4 ($\text{tin}[4] = 4 \in [1, 5]$) $\implies +4$.
  - Node 2 interval $[2, 2]$ does not cover 4 $\implies 0$.
  - Node 3 interval $[3, 5]$ covers 4 $\implies +5$.
  - Node 4 interval $[4, 4]$ covers 4 $\implies +2$.
  - Node 5 interval $[5, 5]$ does not cover 4 $\implies 0$.
- `bit.query(4) = 4 + 5 + 2 = 11`.
- Output: `11`.

### Query 2: `1 3 2` (Update $v_3 \leftarrow 2$)
- $\Delta = 2 - 5 = -3$.
- Apply difference update on $[\text{tin}[3], \text{tout}[3]] = [3, 5]$:
  `bit.add(3, -3)`, `bit.add(6, +3)`.

### Query 3: `2 4` (Path sum from 1 to 4)
- Path values: $v_1 + v_3 + v_4 = 4 + 2 + 2 = 8$.
- `bit.query(4) = 11 - 3 = 8`.
- Output: `8`.

Outputs: `11`, `8` — matches ground truth.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Values**:
   Path sums can reach $2 \cdot 10^5 \times 10^9 = 2 \cdot 10^{14}$. The Fenwick tree elements, `delta`, and query returns must be `long long`.
2. **Boundary Index in Difference Array**:
   `tout[u] + 1` can be $n + 1$. The Fenwick tree size must be at least $n + 2$ to prevent buffer overflow.
3. **Querying Root ($s = 1$)**:
   $\text{tin}[1] = 1$. Returns $v_1$ correctly.
4. **Fast I/O**:
   With $q = 2 \cdot 10^5$, Fast I/O is required to run in $\approx 0.07\text{s}$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How do you query the path sum between two arbitrary nodes $a$ and $b$?**
   $$\text{path\_sum}(a, b) = \text{path\_sum}(1, a) + \text{path\_sum}(1, b) - \text{path\_sum}(1, \text{LCA}(a, b)) - \text{path\_sum}(1, \text{parent}[\text{LCA}(a, b)])$$
   Because path sum to root is computed in $\mathcal{O}(\log n)$, arbitrary path sums are answered in $\mathcal{O}(\log n)$ without Heavy-Light Decomposition!
2. **Can this technique support path maximum queries?**
   No! The ancestor-subtree duality relies on subtraction (invertibility in an abelian group), which exists for addition but not for $\max$. For path maximums, Heavy-Light Decomposition (CSES 2134) is required.
3. **What if edge weights are updated instead of vertex weights?**
   Associate each edge with its deeper endpoint (the child). Path sums to root correspond directly to vertex sums.
4. **How would you answer path queries in $\mathcal{O}(1)$ without updates?**
   Without updates, precompute $\text{dist\_root}[u]$ in $\mathcal{O}(n)$ using a single DFS; arbitrary path sums take $\mathcal{O}(1)$ with an $\mathcal{O}(1)$ RMQ LCA.
5. **How does this compare to Euler Tour double-occurrence brackets?**
   Recording $+v_u$ at entry and $-v_u$ at exit in a prefix Fenwick tree also yields path sums, but requires $2n$ nodes. The difference array approach uses only $n$ nodes.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **DFS Traversal**: $\mathcal{O}(n)$
  - **Initial Array Setup**: $\mathcal{O}(n \log n)$
  - **Per Update**: $\mathcal{O}(\log n)$
  - **Per Path Sum Query**: $\mathcal{O}(\log n)$
  - **Overall Run Time**: $\mathcal{O}((n + q) \log n) \approx 0.07\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space for Fenwick tree and Euler tour arrays.

### Related CSES Problems
- [Subtree Queries](https://cses.fi/problemset/task/1137) — Subtree sums and point updates
- [Path Queries II](https://cses.fi/problemset/task/2134) — Path maximum queries via Heavy-Light Decomposition
- [Distance Queries](https://cses.fi/problemset/task/1135) — Static distance queries via LCA
