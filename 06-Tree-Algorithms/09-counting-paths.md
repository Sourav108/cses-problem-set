# Counting Paths

- **Category**: Tree Algorithms
- **CSES Task ID**: `1136`
- **CSES Problem Link**: [Counting Paths](https://cses.fi/problemset/task/1136)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a tree consisting of $n$ nodes numbered $1, 2, \dots, n$ and $m$ paths on the tree. Each path is defined by its endpoints $a_i$ and $b_i$, and consists of all nodes along the unique simple path between $a_i$ and $b_i$.

Your task is to calculate, for **every node** $1, 2, \dots, n$, the number of paths that contain that node.

### Input Format
- The first line contains two integers $n$ and $m$: the number of nodes and paths.
- The next $n - 1$ lines describe the tree edges: each line has two integers $u$ and $v$.
- The next $m$ lines describe the paths: each line has two integers $a$ and $b$.

### Output Format
- Print $n$ integers: the number of paths containing each node from 1 to $n$.

### Numerical Constraints
- $1 \le n, m \le 2 \cdot 10^5$
- $1 \le u, v \le n$
- $1 \le a, b \le n$

---

## 2. Intuition & Pattern Recognition

Incrementing node counts along each path one node at a time takes $\mathcal{O}(m \cdot n)$ time, which is too slow.
In an ordinary 1D array, adding $+1$ to all elements in range $[L, R]$ is done in $\mathcal{O}(1)$ time using a **Difference Array** ($\text{diff}[L] \mathrel{+}= 1$, $\text{diff}[R + 1] \mathrel{-}= 1$) followed by a prefix sum pass.

### Tree Difference Array (Prefix Sums on Trees)
We can generalize the difference array technique to trees rooted at node 1:
- The path between $u$ and $v$ consists of two upward segments converging at their Lowest Common Ancestor, $w = \text{LCA}(u, v)$:
  $$\text{Path}(u, v) = (u \to w) \cup (v \to w)$$
- In a bottom-up subtree accumulation, the value assigned to node $x$ is:
  $$\text{ans}[x] = \text{diff}[x] + \sum_{c \in \text{children}(x)} \text{ans}[c]$$
- Notice that a value $+1$ placed at $u$ propagates up to $u$'s parent, grandparent, and all ancestors until cancelled.
- To cover exactly the nodes on the path from $u$ to $v$:
  1. Add $+1$ at $u$: propagates along the path $u \to w$ and beyond.
  2. Add $+1$ at $v$: propagates along the path $v \to w$ and beyond.
  3. At $w$, both $+1$ values meet, giving a sum of $+2$. Because $w$ should be counted only once, subtract $1$ at $w$ ($\text{diff}[w] \mathrel{-}= 1$).
  4. Above $w$, the path terminates. Neither ancestor of $w$ should be affected.
     Since the net sum at $w$ is $+1$, subtract $1$ at the parent of $w$ ($\text{diff}[\text{parent}[w]] \mathrel{-}= 1$).

### Summary of Differences
For each path $(u, v)$ with $w = \text{LCA}(u, v)$:
$$\text{diff}[u] \mathrel{+}= 1$$
$$\text{diff}[v] \mathrel{+}= 1$$
$$\text{diff}[w] \mathrel{-}= 1$$
$$\text{diff}[\text{up}[w][0]] \mathrel{-}= 1 \quad (\text{if } w \ne \text{root})$$

After recording all $m$ path updates, a single post-order DFS accumulates the values in $\mathcal{O}(n)$ time.

---

## 3. Approach 1 — Naive Path Traversal per Query

For each of the $m$ paths, find $\text{LCA}(u, v)$ and walk nodes from $u \to w$ and $v \to w$, incrementing a frequency counter.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(m \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Heavy-Light Decomposition + Segment Tree

Decompose paths into $\mathcal{O}(\log n)$ heavy chain segments. Perform range additions on a Segment Tree with lazy propagation.
- Preprocessing: $\mathcal{O}(n)$.
- Updates: $\mathcal{O}(m \log^2 n)$.
- Queries: $\mathcal{O}(n \log n)$.
- While correct, HLD is designed for dynamic/online path updates. Since all paths are given upfront, the Tree Difference Array (Approach 3) runs in $\mathcal{O}(n + m \log n)$ time with drastically smaller code.

---

## 5. Approach 3 — Optimal CSES Solution (Tree Difference Array + Binary Lifting)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

static const int MAX_LOG = 19;

int n, m;
vector<vector<int>> adj;
vector<vector<int>> up;
vector<int> depth;
vector<int> diff_arr;
vector<int> ans;

void dfs_lca(int u, int p, int d) {
    depth[u] = d;
    up[u][0] = p;

    for (int j = 1; j < MAX_LOG; ++j) {
        up[u][j] = up[up[u][j - 1]][j - 1];
    }

    for (int v : adj[u]) {
        if (v != p) {
            dfs_lca(v, u, d + 1);
        }
    }
}

int get_lca(int u, int v) {
    if (depth[u] < depth[v]) {
        swap(u, v);
    }

    int diff = depth[u] - depth[v];
    for (int j = 0; j < MAX_LOG; ++j) {
        if (diff & (1 << j)) {
            u = up[u][j];
        }
    }

    if (u == v) return u;

    for (int j = MAX_LOG - 1; j >= 0; --j) {
        if (up[u][j] != up[v][j]) {
            u = up[u][j];
            v = up[v][j];
        }
    }

    return up[u][0];
}

void dfs_accumulate(int u, int p) {
    ans[u] = diff_arr[u];

    for (int v : adj[u]) {
        if (v != p) {
            dfs_accumulate(v, u);
            ans[u] += ans[v];
        }
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> m)) return 0;

    adj.assign(n + 1, vector<int>());
    up.assign(n + 1, vector<int>(MAX_LOG, 0));
    depth.assign(n + 1, 0);
    diff_arr.assign(n + 1, 0);
    ans.assign(n + 1, 0);

    for (int i = 0; i < n - 1; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    dfs_lca(1, 0, 0);

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        int w = get_lca(u, v);

        diff_arr[u] += 1;
        diff_arr[v] += 1;
        diff_arr[w] -= 1;
        int parent_w = up[w][0];
        if (parent_w != 0) {
            diff_arr[parent_w] -= 1;
        }
    }

    dfs_accumulate(1, 0);

    for (int i = 1; i <= n; ++i) {
        cout << ans[i] << (i == n ? "" : " ");
    }
    cout << '\n';

    return 0;
}
```

---

## 6. Correctness Proof

### Linearity of Tree Prefix Sums
By definition, the accumulated value at node $x$ is:
$$\text{ans}[x] = \sum_{y \in \text{subtree}(x)} \text{diff}[y]$$
Consider the contribution of a single path between $u$ and $v$ with $w = \text{LCA}(u, v)$:
- **Case 1: Node $x$ lies on the path between $u$ and $w$ (excluding $w$)**:
  Then $u \in \text{subtree}(x)$, but $v \notin \text{subtree}(x)$, $w \notin \text{subtree}(x)$, and $\text{parent}[w] \notin \text{subtree}(x)$.
  The sum in $\text{subtree}(x)$ includes only the $+1$ at $u$, giving $+1$.
- **Case 2: Node $x$ lies on the path between $v$ and $w$ (excluding $w$)**:
  Symmetric to Case 1. The sum includes only the $+1$ at $v$, giving $+1$.
- **Case 3: Node $x = w$**:
  The subtree of $w$ contains both $u$, $v$, and $w$, but does not contain $\text{parent}[w]$.
  The sum in $\text{subtree}(w)$ is:
  $$\text{diff}[u] + \text{diff}[v] + \text{diff}[w] = 1 + 1 - 1 = 1$$
- **Case 4: Node $x$ is a strict ancestor of $w$**:
  The subtree of $x$ contains $u, v, w$, and $\text{parent}[w]$.
  The sum in $\text{subtree}(x)$ is:
  $$1 + 1 - 1 - 1 = 0$$
- **Case 5: Node $x$ is outside the path entirely**:
  None of $\{u, v, w, \text{parent}[w]\}$ belong to $\text{subtree}(x)$ (or they cancel out), giving net 0.

By linearity of summation, the total accumulated sum $\text{ans}[x]$ counts each path containing $x$ exactly once. $\blacksquare$

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

Tree:
```text
      1
    /   \
   2     3
       /   \
      4     5
```

### Paths
1. Path $(1, 3)$: $w = 1$. Parent of $w$ is $0$.
   `diff[1] += 1, diff[3] += 1, diff[1] -= 1` $\implies \text{diff}[3] += 1$.
2. Path $(2, 5)$: $w = 1$. Parent of $w$ is $0$.
   `diff[2] += 1, diff[5] += 1, diff[1] -= 1`.
3. Path $(1, 4)$: $w = 1$. Parent of $w$ is $0$.
   `diff[1] += 1, diff[4] += 1, diff[1] -= 1` $\implies \text{diff}[4] += 1$.

Net `diff` array:
- `diff[1] = 0`
- `diff[2] = 1`
- `diff[3] = 1`
- `diff[4] = 1`
- `diff[5] = 1`

### Bottom-Up Accumulation
- Leaf 4: `ans[4] = diff[4] = 1`.
- Leaf 5: `ans[5] = diff[5] = 1`.
- Leaf 2: `ans[2] = diff[2] = 1`.
- Node 3: `ans[3] = diff[3] + ans[4] + ans[5] = 1 + 1 + 1 = 3`.
- Root 1: `ans[1] = diff[1] + ans[2] + ans[3] = 0 + 1 + 3 = 4`.

### Output
`4 1 3 1 1`

Node 1 is on all 3 paths plus endpoint?
- Path (1, 3): nodes {1, 3}
- Path (2, 5): nodes {2, 1, 3, 5}
- Path (1, 4): nodes {1, 3, 4}
Counts:
- Node 1: appears in all 3 paths $\implies 3$.
Wait, in sample input:
Let's check why `ans[1]` was 4 in our trace:
For path (1, 3): $u = 1, v = 3, w = 1$.
`diff[1] += 1, diff[3] += 1, diff[1] -= 1` $\implies$ net: `diff[1] = 0, diff[3] = 1`.
For path (2, 5): $u = 2, v = 5, w = 1$.
`diff[2] += 1, diff[5] += 1, diff[1] -= 1` $\implies$ net: `diff[1] = -1, diff[2] = 1, diff[5] = 1`.
For path (1, 4): $u = 1, v = 4, w = 1$.
`diff[1] += 1, diff[4] += 1, diff[1] -= 1` $\implies$ net: `diff[1] = 0, diff[4] = 1`.
Sum of `diff[1]`:
Path 1: $1 - 1 = 0$.
Path 2: $-1$.
Path 3: $1 - 1 = 0$.
Total `diff[1] = -1`!
Then `ans[1] = diff[1] + ans[2] + ans[3] = -1 + 1 + 3 = 3`!
Counts:
Node 1: 3
Node 2: 1
Node 3: 3
Node 4: 1
Node 5: 1
Exact output: `3 1 3 1 1`!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Path of Length 0 ($u = v$)**:
   $w = u$.
   $\text{diff}[u] \mathrel{+}= 1 + 1 - 1 = +1$.
   $\text{diff}[\text{parent}[u]] \mathrel{-}= 1$.
   Exactly marks node $u$ with $+1$ and cancels it above $u$.
2. **LCA is the Root ($w = 1$)**:
   The parent of 1 is 0. The check `if (parent_w != 0)` prevents negative or out-of-bounds indexing.
3. **One Endpoint is Ancestor of Other**:
   $w = u$. Handled identically without special-casing.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How would you count paths passing through edges instead of vertices?**
   For edge difference arrays, assign edge $(u, v)$ to the deeper node (child). For path $(u, v)$, set $\text{diff}[u] \mathrel{+}= 1$, $\text{diff}[v] \mathrel{+}= 1$, $\text{diff}[w] \mathrel{-}= 2$. (No subtraction at $\text{parent}[w]$!).
2. **What if paths have weights $W_i$ and we need total weight on each node?**
   Replace $+1/-1$ with $+W_i/-W_i$. The linearity of tree prefix sums holds for arbitrary weights.
3. **How does this compare to Euler Tour range updates?**
   Euler Tour flattening maps paths to $O(\log n)$ intervals or requires 2D range updates. The tree difference array is strictly faster: $\mathcal{O}(1)$ updates and a single $\mathcal{O}(n)$ sweep.
4. **Can we answer path count queries online if paths and queries interleave?**
   Yes, using Heavy-Light Decomposition + Lazy Segment Tree in $\mathcal{O}(\log^2 n)$ per operation.
5. **How does Tarjan's Offline LCA pair with this?**
   By computing all $m$ LCAs using Tarjan's DSU-based offline algorithm, the entire solution runs in $\mathcal{O}(n + m \alpha(n))$ time, eliminating the $\log n$ factor entirely!

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **LCA Precomputation**: $\mathcal{O}(n \log n)$
  - **$m$ Path Updates**: $\mathcal{O}(m \log n)$
  - **Accumulation DFS**: $\mathcal{O}(n)$
  - **Overall Run Time**: $\mathcal{O}((n + m) \log n) \approx 0.10\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n \log n)$ auxiliary space for binary lifting table.

### Related CSES Problems
- [Company Queries II](https://cses.fi/problemset/task/1688) — Binary lifting LCA
- [Distance Queries](https://cses.fi/problemset/task/1135) — Path distance via LCA
- [Subtree Queries](https://cses.fi/problemset/task/1137) — Subtree updates via Euler Tour
