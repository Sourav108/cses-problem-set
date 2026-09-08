# Subtree Queries

- **Category**: Tree Algorithms
- **CSES Task ID**: `1137`
- **CSES Problem Link**: [Subtree Queries](https://cses.fi/problemset/task/1137)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a rooted tree consisting of $n$ nodes numbered $1, 2, \dots, n$, with node 1 as the root. Each node $i$ has an initial integer value $v_i$.

You must process $q$ queries of two types:
1. `1 s x`: **Update**: Change the value of node $s$ to $x$ ($v_s \leftarrow x$).
2. `2 s`: **Subtree Sum**: Calculate the sum of values of all nodes in the subtree of node $s$.

Array values and nodes are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the number of nodes and queries.
- The second line contains $n$ integers $v_1, v_2, \dots, v_n$: the initial values of the nodes.
- The next $n - 1$ lines describe the tree edges: each line has two integers $a$ and $b$.
- The next $q$ lines describe the queries:
  - `1 s x`
  - `2 s`

### Output Format
- For each query of type 2, print the subtree sum on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le v_i, x \le 10^9$
- $1 \le a, b \le n$
- $1 \le s \le n$

---

## 2. Intuition & Pattern Recognition

Running a subtree DFS for each query 2 takes $\mathcal{O}(n)$ time, which results in $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations and TLE.

### Key Insight: Euler Tour Flattening
In a tree rooted at 1, a DFS traversal visits a node $u$ and then recursively visits all of its descendants before backtracking out of $u$.
If we record the DFS entry and exit timestamps:
- `tin[u]`: the timestamp when DFS enters node $u$.
- `tout[u]`: the timestamp when DFS finishes exploring all descendants of $u$.

Because the DFS traversal visits all descendants of $u$ between `tin[u]` and `tout[u]` without interruption:
$$\text{subtree}(u) = \{ v \in V \mid \text{tin}[u] \le \text{tin}[v] \le \text{tout}[u] \}$$

The subtree of any node $u$ maps to a single **contiguous 1D interval**:
$$[\text{tin}[u], \; \text{tout}[u]]$$

### Reduction to 1D Dynamic Range Sum
Place each node $u$'s value at position $\text{tin}[u]$ in a 1D array of size $n$:
1. **Update `1 s x`**:
   Point update at index $\text{tin}[s]$ with $\Delta = x - v_s$.
2. **Query `2 s`**:
   Range sum query over the interval $[\text{tin}[s], \text{tout}[s]]$.

Both operations are solved in $\mathcal{O}(\log n)$ time using a **Fenwick Tree (Binary Indexed Tree)**.

---

## 3. Approach 1 — Naive Subtree Traversal per Query

Apply point updates directly in an array, and run a BFS/DFS from $s$ to sum all descendant values for each query 2.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(1)$ per update, $\mathcal{O}(n)$ per query. Total time $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Segment Tree on Euler Tour

Instead of a Fenwick tree, maintain the flattened interval array inside a standard Segment Tree.
- Build time: $\mathcal{O}(n)$.
- Point update: $\mathcal{O}(\log n)$.
- Range sum: $\mathcal{O}(\log n)$.
- While asymptotically identical, a Fenwick Tree (Approach 3) has lower constant factors, uses $4\times$ less memory, and requires significantly fewer lines of code.

---

## 5. Approach 3 — Optimal CSES Solution (Euler Tour + Fenwick Tree)

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
    Fenwick(int n) : n(n), tree(n + 1, 0) {}

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

    long long query(int l, int r) const {
        if (l > r) return 0;
        return query(r) - query(l - 1);
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
    for (int i = 1; i <= n; ++i) {
        bit.add(tin[i], val[i]);
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
        } else {
            int s;
            cin >> s;
            cout << bit.query(tin[s], tout[s]) << '\n';
        }
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Interval Contiguity of DFS Tree Traversal
In a rooted tree, the descendants of node $u$ form a connected induced subgraph.
During DFS, after entering node $u$ at timestamp `tin[u]`:
1. All recursive DFS calls for nodes in $\text{subtree}(u)$ are executed and completed before returning from `dfs(u)`.
2. The timer variable strictly increments by 1 for each newly visited node.
3. No node outside $\text{subtree}(u)$ can be visited while `dfs(u)` is active.
Therefore, the set of timestamps assigned to nodes in $\text{subtree}(u)$ is precisely the set of integers in the closed interval:
$$[\text{tin}[u], \; \text{tout}[u]]$$
Every node in $\text{subtree}(u)$ receives exactly one distinct timestamp in this range, and no other node receives a timestamp in this range.
By placing each node's weight at index $\text{tin}[u]$ in the Fenwick tree, the range sum $\sum_{i=\text{tin}[u]}^{\text{tout}[u]} A[i]$ equals $\sum_{v \in \text{subtree}(u)} \text{val}[v]$ exactly. Point updates modify position $\text{tin}[s]$, maintaining the invariant under mutations.

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
2 3
1 2 8
2 1
```

Initial Values: $v = [-, 4, 2, 5, 2, 1]$

Tree Hierarchy:
```text
      1 (val 4)
    /   \
   2     3 (val 5)
 (val 2)/ \
       4   5
 (val 2)   (val 1)
```

### DFS Euler Tour Timestamps
- `dfs(1)`: `tin[1] = 1`
  - `dfs(2)`: `tin[2] = 2, tout[2] = 2`
  - `dfs(3)`: `tin[3] = 3`
    - `dfs(4)`: `tin[4] = 4, tout[4] = 4`
    - `dfs(5)`: `tin[5] = 5, tout[5] = 5`
  - `tout[3] = 5`
- `tout[1] = 5`

Flattened positions:
- `tin[1]=1 (val 4)`
- `tin[2]=2 (val 2)`
- `tin[3]=3 (val 5)`
- `tin[4]=4 (val 2)`
- `tin[5]=5 (val 1)`

### Query 1: `2 3` (Subtree of node 3)
- Interval: $[\text{tin}[3], \text{tout}[3]] = [3, 5]$.
- Nodes with `tin` in $[3, 5]$ are $\{3, 4, 5\}$.
- Sum: $v_3 + v_4 + v_5 = 5 + 2 + 1 = 8$.
- Output: `8`.

### Query 2: `1 2 8` (Set $v_2 \leftarrow 8$)
- $\Delta = 8 - 2 = +6$.
- Update Fenwick tree at position $\text{tin}[2] = 2$ with $+6$.

### Query 3: `2 1` (Subtree of node 1)
- Interval: $[\text{tin}[1], \text{tout}[1]] = [1, 5]$.
- Entire tree sum: $4 + 8 + 5 + 2 + 1 = 20$.
- Output: `20`.

Outputs: `8`, `20` — matches ground truth.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow**:
   $n = 2 \cdot 10^5$ and $v_i = 10^9$. The total subtree sum can reach $2 \cdot 10^{14}$, which exceeds 32-bit integer limits. The Fenwick tree array and return values must be `long long`.
2. **Leaf Node Query ($s$ is a leaf)**:
   $\text{tin}[s] = \text{tout}[s]$. The range query interval $[k, k]$ has length 1, returning $v_s$ correctly.
3. **Root Query ($s = 1$)**:
   $\text{tin}[1] = 1, \text{tout}[1] = n$. The range query spans $[1, n]$, returning the sum of all node values in the tree.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if updates are applied to an entire subtree (range update on subtree)?**
   In the flattened array, a subtree update is a range addition on $[\text{tin}[s], \text{tout}[s]]$.
   If queries are point queries, use a difference Fenwick tree. If queries are also subtree sums, use a Lazy Segment Tree.
2. **How does this connect to Path Queries (CSES 1138)?**
   In Path Queries, we query root-to-node paths. A point update at $s$ affects all descendants of $s$, turning point updates into subtree range additions on the Euler tour!
3. **Can we count distinct values in a subtree with this representation?**
   Yes! By mapping subtrees to intervals $[\text{tin}[s], \text{tout}[s]]$, subtree distinct counting reduces directly to the 1D *Distinct Values Queries* problem (CSES 1734).
4. **How would you answer subtree minimum / maximum queries?**
   Replace the Fenwick Tree with a Segment Tree over $[\text{tin}[u], \text{tout}[u]]$. Subtree RMQ takes $\mathcal{O}(\log n)$.
5. **How does this compare to Heavy-Light Decomposition?**
   Euler Tour flattening handles subtree operations in $\mathcal{O}(\log n)$ with trivial code, whereas HLD is required for path operations across arbitrary pairs of nodes.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Euler Tour DFS**: $\mathcal{O}(n)$
  - **Fenwick Tree Initialization**: $\mathcal{O}(n \log n)$ or $\mathcal{O}(n)$
  - **Per Update**: $\mathcal{O}(\log n)$
  - **Per Subtree Query**: $\mathcal{O}(\log n)$
  - **Overall Run Time**: $\mathcal{O}((n + q) \log n) \approx 0.08\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space for Euler tour arrays and Fenwick tree.

### Related CSES Problems
- [Subordinates](https://cses.fi/problemset/task/1674) — Static subtree sizes
- [Path Queries](https://cses.fi/problemset/task/1138) — Root-to-node path queries
- [Distinct Colors](https://cses.fi/problemset/task/1139) — Subtree distinct value counting
