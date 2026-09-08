# Path Queries II

- **Category**: Tree Algorithms
- **CSES Task ID**: `2134`
- **CSES Problem Link**: [Path Queries II](https://cses.fi/problemset/task/2134)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a tree consisting of $n$ nodes numbered $1, 2, \dots, n$. Each node $i$ has an integer value $v_i$.

You must process $q$ queries of two types:
1. `1 s x`: **Update**: Change the value of node $s$ to $x$ ($v_s \leftarrow x$).
2. `2 a b`: **Path Maximum**: Find the maximum node value along the unique simple path between nodes $a$ and $b$:
   $$\max_{u \in \text{Path}(a, b)} v_u$$

Array values and node indices are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the number of nodes and queries.
- The second line contains $n$ integers $v_1, v_2, \dots, v_n$: the initial node values.
- The next $n - 1$ lines describe the tree edges: each line has two integers $u$ and $v$.
- The next $q$ lines describe the queries:
  - `1 s x`
  - `2 a b`

### Output Format
- For each query of type 2, print the maximum value on the path on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le v_i, x \le 10^9$
- $1 \le u, v \le n$
- $1 \le a, b \le n$
- $1 \le s \le n$

---

## 2. Intuition & Pattern Recognition

In CSES 1138 (*Path Queries*), path sums were solved via Euler Tour difference arrays because addition is invertible (we can subtract the shared ancestor prefix).
The $\max$ operator is **non-invertible** ($\max(A, B) = M$ does not allow retrieving $A$ when given $M$ and $B$). Therefore, ancestor prefix subtraction fails completely, and Euler Tour difference arrays cannot be used.

### Heavy-Light Decomposition (HLD)
To support arbitrary path queries with point updates under any associative binary operator, we employ **Heavy-Light Decomposition**:
1. **Edge Classification**:
   For each node $u$, classify its child with the maximum subtree size as the **heavy child**. All other children are **light children**.
   - An edge to a heavy child is a **heavy edge**.
   - Connected components of heavy edges form disjoint paths called **heavy chains**.
2. **Key Property of Light Edges**:
   Because any light child $v$ has $\text{size}[v] \le \frac{1}{2} \text{size}[u]$, traversing a light edge to a parent at least doubles the subtree size.
   Consequently, the simple path from any node to the root contains at most $\lfloor \log_2 n \rfloor$ light edges and at most $\lfloor \log_2 n \rfloor$ distinct heavy chains!
3. **Linear Flattening**:
   By assigning 1D segment tree indices (`pos[u]`) visiting heavy children first during DFS, **every heavy chain forms a contiguous 1D subsegment** in the segment tree array!
4. **Path Query Traversal**:
   To query the path between $a$ and $b$:
   - While $a$ and $b$ do not belong to the same heavy chain:
     - Take the node whose chain head is deeper.
     - Query the contiguous range $[\text{pos}[\text{head}], \text{pos}[\text{node}]]$ on the Segment Tree.
     - Jump the node up to the parent of its chain head: $\text{node} \leftarrow \text{parent}[\text{head}]$.
   - When both nodes belong to the same heavy chain:
     - Query the single remaining contiguous segment between their positions: $[\min(\text{pos}[a], \text{pos}[b]), \; \max(\text{pos}[a], \text{pos}[b])]$.

Each path query decomposes into at most $\mathcal{O}(\log n)$ segment tree range queries, giving $\mathcal{O}(\log^2 n)$ worst-case time per query. Point updates take $\mathcal{O}(\log n)$.

---

## 3. Approach 1 — Naive BFS / DFS per Query

For each query `2 a b`, run a search to find the simple path from $a$ to $b$ and compute the maximum along the path in $\mathcal{O}(n)$ time.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Link-Cut Tree (Splay Tree of Trees)

Maintain dynamic preferred paths using a Link-Cut Tree.
- Point update: $\mathcal{O}(\log n)$ amortized.
- Path query: $\mathcal{O}(\log n)$ amortized.
- While asymptotically $\mathcal{O}(\log n)$ per query, Link-Cut Trees have large constant factors from splay tree pointer rotations and heavy recursion overhead.
- Heavy-Light Decomposition (Approach 3) runs significantly faster in practice on static tree structures and is much easier to debug.

---

## 5. Approach 3 — Optimal CSES Solution (Heavy-Light Decomposition + Segment Tree)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int n, q;
vector<vector<int>> adj;
vector<int> val;
vector<int> parent_node, depth_arr, sz, heavy, head, pos;
int cur_pos = 0;

// Bottom-up iterative Segment Tree for RMQ
int size_pow;
vector<int> tree;

void update_tree(int p, int value) {
    p += size_pow - 1;
    tree[p] = value;
    for (p /= 2; p >= 1; p /= 2) {
        tree[p] = max(tree[2 * p], tree[2 * p + 1]);
    }
}

int query_tree(int l, int r) {
    int res = 0;
    l += size_pow - 1;
    r += size_pow - 1;
    while (l <= r) {
        if (l % 2 == 1) res = max(res, tree[l++]);
        if (r % 2 == 0) res = max(res, tree[r--]);
        l /= 2;
        r /= 2;
    }
    return res;
}

// DFS 1: Compute depths, parents, subtree sizes, and heavy children
void dfs1(int u, int p, int d) {
    parent_node[u] = p;
    depth_arr[u] = d;
    sz[u] = 1;
    heavy[u] = 0;
    int max_child_sz = 0;

    for (int v : adj[u]) {
        if (v != p) {
            dfs1(v, u, d + 1);
            sz[u] += sz[v];
            if (sz[v] > max_child_sz) {
                max_child_sz = sz[v];
                heavy[u] = v;
            }
        }
    }
}

// DFS 2: Decompose into heavy chains and assign segment tree positions
void dfs2(int u, int h) {
    head[u] = h;
    pos[u] = ++cur_pos;

    // Visit heavy child first to keep chain contiguous in pos
    if (heavy[u] != 0) {
        dfs2(heavy[u], h);
    }

    for (int v : adj[u]) {
        if (v != parent_node[u] && v != heavy[u]) {
            dfs2(v, v); // New chain starts at v
        }
    }
}

int query_path(int a, int b) {
    int res = 0;
    while (head[a] != head[b]) {
        if (depth_arr[head[a]] < depth_arr[head[b]]) {
            swap(a, b);
        }
        res = max(res, query_tree(pos[head[a]], pos[a]));
        a = parent_node[head[a]];
    }

    if (depth_arr[a] > depth_arr[b]) {
        swap(a, b);
    }
    res = max(res, query_tree(pos[a], pos[b]));
    return res;
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

    parent_node.assign(n + 1, 0);
    depth_arr.assign(n + 1, 0);
    sz.assign(n + 1, 0);
    heavy.assign(n + 1, 0);
    head.assign(n + 1, 0);
    pos.assign(n + 1, 0);

    dfs1(1, 0, 0);
    dfs2(1, 1);

    size_pow = 1;
    while (size_pow <= n) size_pow <<= 1;
    tree.assign(2 * size_pow, 0);

    for (int i = 1; i <= n; ++i) {
        tree[size_pow + pos[i] - 1] = val[i];
    }
    for (int i = size_pow - 1; i >= 1; --i) {
        tree[i] = max(tree[2 * i], tree[2 * i + 1]);
    }

    while (q--) {
        int type;
        cin >> type;
        if (type == 1) {
            int s, x;
            cin >> s >> x;
            val[s] = x;
            update_tree(pos[s], x);
        } else {
            int a, b;
            cin >> a >> b;
            cout << query_path(a, b) << '\n';
        }
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Heavy Chain Decomposition Invariant
1. **Chain Contiguity**: Because `dfs2` always recurses on `heavy[u]` before any other child and passes `h` as the chain head, all nodes on a heavy chain receive contiguous positions in `pos`:
   $$\text{pos}[u] = \text{pos}[\text{head}[u]] + \text{depth}[u] - \text{depth}[\text{head}[u]]$$
   Thus, any subsegment of a heavy chain from $u$ to $\text{head}[u]$ maps to the single 1D interval $[\text{pos}[\text{head}[u]], \text{pos}[u]]$.
2. **Logarithmic Chains on Paths**:
   For any light edge $(u, v)$ where $v$ is a child of $u$, $\text{sz}[v] \le \frac{1}{2} \text{sz}[u]$.
   Therefore, moving from any node to the root encounters at most $\lfloor \log_2 n \rfloor$ light edges and transitions between at most $\lfloor \log_2 n \rfloor$ heavy chains.
3. **Path Coverage Completeness**:
   The `while (head[a] != head[b])` loop repeatedly shifts the chain of the deeper head upward.
   When `head[a] == head[b]`, both nodes reside on the same heavy chain.
   Because the heavy chain is an ancestor-descendant path, the interval between $\text{pos}[a]$ and $\text{pos}[b]$ exactly covers the remaining portion of the path between $a$ and $b$.
   The union of all queried 1D intervals constitutes a partition of the unique tree path between $a$ and $b$, without skipping or duplicating any vertex.
   Taking the maximum over all partitioned intervals yields the exact path maximum.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
2 4 1 3 3
1 2
1 3
2 4
2 5
2 2 3
1 1 5
2 4 5
```

Initial Values: $v = [-, 2, 4, 1, 3, 3]$

Tree:
```text
        1 (val 2)
      /   \
(val 4) 2   3 (val 1)
       / \
(val 3)4   5 (val 3)
```

Subtree Sizes:
- $\text{sz}[4] = 1, \text{sz}[5] = 1$
- $\text{sz}[2] = 1 + 1 + 1 = 3 \implies$ heavy child of 1 is 2!
- $\text{sz}[3] = 1$
- $\text{sz}[1] = 5$

Heavy Chains:
- Chain 1: $1 \to 2 \to 4$ (head = 1)
- Chain 2: $5$ (head = 5)
- Chain 3: $3$ (head = 3)

### Query 1: `2 2 3` (Max value on path $2 - 1 - 3$)
- $\text{head}[2] = 1, \text{head}[3] = 3$. Different chains!
- Deeper head is $\text{head}[3] = 3$ ($\text{depth} = 1$).
  - Query chain segment for 3: $[\text{pos}[3], \text{pos}[3]] \implies v_3 = 1$.
  - Jump $3 \to \text{parent}[\text{head}[3]] = 1$.
- Now comparing $2$ and $1$: $\text{head}[2] = 1, \text{head}[1] = 1$. Same chain!
  - Query segment between $\text{pos}[1]$ and $\text{pos}[2]$: $\max(v_1, v_2) = \max(2, 4) = 4$.
- Overall max: $\max(1, 4) = 4$.
- Output: `4`.

### Query 2: `1 1 5` (Update $v_1 \leftarrow 5$)
- `update_tree(pos[1], 5)`.

### Query 3: `2 4 5` (Max on path $4 - 2 - 5$)
- Values on path: $v_4=3, v_2=4, v_5=3$.
- Maximum is 4.
- Output: `4`.

Outputs: `4`, `4` — matches ground truth.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Path Between Same Node ($a = b$)**:
   The loop `head[a] != head[b]` does not execute. It queries single point interval $[\text{pos}[a], \text{pos}[a]]$, returning $v_a$.
2. **Values Fit in 32-bit**:
   $v_i, x \le 10^9$. Node values fit in standard `int`.
3. **Linear Chain ($P_n$)**:
   Entire tree forms a single heavy chain of length $n$. Each query executes in $\mathcal{O}(\log n)$ time (a single segment tree query).
4. **Star Graph**:
   Center is root 1. One leaf is heavy, $n - 2$ leaves are light. Path between two light leaves takes 2 chain jumps $\implies \mathcal{O}(\log n)$ time.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How would you adapt this for Path Sum queries?**
   Change the segment tree from RMQ (`max`) to range sum (`+`). The HLD traversal logic remains identical.
2. **Can HLD handle range updates on paths (e.g., add $x$ to all nodes on path $a - b$)?**
   Yes. Replace the point-update segment tree with a **Lazy Segment Tree**. Applying range additions to the $\mathcal{O}(\log n)$ chain segments takes $\mathcal{O}(\log^2 n)$ time.
3. **What if edge weights are queried instead of node weights?**
   Push each edge's weight to its deeper endpoint (the child node). During the final same-chain query between $a$ and $b$ (with $\text{depth}[a] \le \text{depth}[b]$), query the interval $[\text{pos}[\text{heavy\_child}[a]], \text{pos}[b]]$ or $[\text{pos}[a] + 1, \text{pos}[b]]$ to exclude node $a$ (which represents the edge to $a$'s parent).
4. **Why is iterative segment tree preferred over recursive in HLD?**
   A path query makes up to $2 \log n \approx 36$ range query calls. An iterative segment tree has zero function call overhead and executes $\approx 3\times$ faster than recursive segment trees.
5. **How does HLD compare to Centroid Decomposition?**
   HLD supports dynamic updates and path queries between *any* arbitrary pair of nodes. Centroid Decomposition is suited for counting paths of specific length or static global tree path properties.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **HLD DFS Passes**: $\mathcal{O}(n)$
  - **Segment Tree Build**: $\mathcal{O}(n)$
  - **Point Update**: $\mathcal{O}(\log n)$
  - **Path Query**: $\mathcal{O}(\log^2 n)$
  - **Overall Run Time**: $\mathcal{O}(n + q \log^2 n) \approx 0.12\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space for HLD vectors and segment tree.

### Related CSES Problems
- [Path Queries](https://cses.fi/problemset/task/1138) — Root-to-node path sums via Euler Tour
- [Subtree Queries](https://cses.fi/problemset/task/1137) — Subtree updates and range sums
- [Company Queries II](https://cses.fi/problemset/task/1688) — LCA on trees
