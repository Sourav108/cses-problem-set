# Company Queries II

- **Category**: Tree Algorithms
- **CSES Task ID**: `1688`
- **CSES Problem Link**: [Company Queries II](https://cses.fi/problemset/task/1688)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

A company has $n$ employees numbered $1, 2, \dots, n$, where employee 1 is the general director. Every employee $i \in [2, n]$ has a direct boss $e_i$.

You must process $q$ queries of the form:
- Given two employees $a$ and $b$, determine their **lowest common boss** (the Lowest Common Ancestor, LCA, in the corporate hierarchy tree).

### Input Format
- The first line contains two integers $n$ and $q$: the number of employees and queries.
- The second line contains $n - 1$ integers $e_2, e_3, \dots, e_n$: the direct boss of each employee from 2 to $n$.
- The next $q$ lines each contain two integers $a$ and $b$.

### Output Format
- For each query, print the employee ID of their lowest common boss on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le e_i \le n$
- $1 \le a, b \le n$

---

## 2. Intuition & Pattern Recognition

The lowest common boss of $a$ and $b$ is the deepest node in the tree that is an ancestor of both $a$ and $b$.
A naive approach would trace parent pointers upward from $a$ and mark all visited ancestors, then trace upward from $b$ until hitting the first marked ancestor. This takes $\mathcal{O}(n)$ time per query, which is too slow for $q = 2 \cdot 10^5$.

### Binary Lifting LCA Algorithm
Using the power-of-two jump table `up[u][j]` introduced in CSES 1687 (*Company Queries I*), we can find the LCA in $\mathcal{O}(\log n)$ time in two distinct phases:

1. **Phase 1: Depth Equalization**:
   Suppose without loss of generality that $\text{depth}[a] \ge \text{depth}[b]$.
   Lift node $a$ up by the exact difference $\Delta = \text{depth}[a] - \text{depth}[b]$ using binary lifting so that both nodes are at the same depth:
   $$\text{depth}[a'] = \text{depth}[b]$$
   If $a' = b$, then $b$ was already an ancestor of $a$, and $b$ is the LCA.

2. **Phase 2: Simultaneous Lifting**:
   With both nodes at the exact same depth ($a \ne b$), their LCA lies strictly above them.
   Test power-of-two jumps in descending order from $j = 18$ down to $0$:
   - If $\text{up}[a][j] \ne \text{up}[b][j]$:
     The jump of size $2^j$ has **not yet reached** a common ancestor (or is strictly below the LCA).
     Therefore, we safely jump both nodes upward:
     $$a \leftarrow \text{up}[a][j], \quad b \leftarrow \text{up}[b][j]$$
   - If $\text{up}[a][j] = \text{up}[b][j]$:
     The jump of size $2^j$ reached or exceeded the LCA. We do not jump, as we want to land immediately below the LCA.
3. **Termination**:
   After testing all bits down to $j = 0$, $a$ and $b$ are direct children of the lowest common ancestor.
   Therefore:
   $$\text{LCA}(a, b) = \text{up}[a][0]$$

---

## 3. Approach 1 — Naive Parent Tracing

Trace ancestors of $a$ into an `std::vector<bool> visited`, then step up from $b$ until finding a visited node.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Euler Tour + Sparse Table (RMQ LCA)

Flatten the tree into an Euler Tour recording node visits. The LCA of $a$ and $b$ corresponds to the node with minimum depth in the tour between the first occurrences of $a$ and $b$.
- Preprocessing: $\mathcal{O}(n \log n)$ via Sparse Table.
- Query Time: $\mathcal{O}(1)$ via static RMQ.
- While optimal for $\mathcal{O}(1)$ queries, Binary Lifting (Approach 3) is much simpler, uses less memory, and executes within $\approx 0.08\text{s}$.

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
        dfs(v, u, d + 1);
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

    for (int i = 2; i <= n; ++i) {
        int boss;
        cin >> boss;
        adj[boss].push_back(i);
    }

    dfs(1, 0, 0);

    while (q--) {
        int a, b;
        cin >> a >> b;
        cout << get_lca(a, b) << '\n';
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Phase 1: Depth Equalization
Let $w = \text{LCA}(u, v)$.
By definition of ancestors in a tree, $\text{depth}[w] \le \min(\text{depth}[u], \text{depth}[v])$.
Any ancestor of $u$ at depth $\ge \text{depth}[v]$ lies on the unique simple path between $u$ and $w$ (or equals $w$).
Thus, lifting $u$ by $\text{depth}[u] - \text{depth}[v]$ levels up to $u'$ ensures that $u'$ and $v$ have the identical lowest common ancestor:
$$\text{LCA}(u', v) = \text{LCA}(u, v)$$
If $u' = v$, then $v$ was an ancestor of $u$, and $v$ is returned immediately.

### Phase 2: Invariant of Simultaneous Binary Search
Suppose $u' \ne v$ with $\text{depth}[u'] = \text{depth}[v] = D$, and let $\text{depth}[\text{LCA}] = D_{\text{LCA}} < D$.
The distance to the LCA is $k^* = D - D_{\text{LCA}} \ge 1$.
- Any jump of length $2^j \ge k^*$ lands on a common ancestor ($\text{up}[u][j] = \text{up}[v][j]$).
- Any jump of length $2^j < k^*$ lands on two distinct nodes ($\text{up}[u][j] \ne \text{up}[v][j]$).
By greedily jumping whenever the ancestors differ, the algorithm constructs the unique binary representation of $k^* - 1$.
Consequently, upon termination at $j = 0$, the nodes $u$ and $v$ are at distance exactly 1 from the LCA.
Their immediate parent $\text{up}[u][0]$ is strictly the unique Lowest Common Ancestor. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
1 1 3 3
4 5
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

### Table Precomputation
- Depths: `depth = [0, 0, 1, 1, 2, 2]`
- `up[4][0] = 3, up[4][1] = 1`
- `up[5][0] = 3, up[5][1] = 1`
- `up[2][0] = 1, up[2][1] = 0`

### Query 1: `4 5`
- $\text{depth}[4] = 2, \text{depth}[5] = 2$ (already equal).
- Phase 2:
  - $j = 1$: $\text{up}[4][1] = 1, \text{up}[5][1] = 1$ (equal, don't jump).
  - $j = 0$: $\text{up}[4][0] = 3, \text{up}[5][0] = 3$ (equal, don't jump).
- Return $\text{up}[4][0] = 3$.
- Output: `3`.

### Query 2: `2 5`
- $\text{depth}[5] = 2, \text{depth}[2] = 1$. $\Delta = 1$.
- Lift 5 by 1 level: $5 \leftarrow \text{up}[5][0] = 3$.
- Now compare $2$ and $3$ (both at depth 1):
  - $j = 0$: $\text{up}[2][0] = 1, \text{up}[3][0] = 1$ (equal, don't jump).
- Return $\text{up}[2][0] = 1$.
- Output: `1`.

### Query 3: `1 4`
- $\text{depth}[4] = 2, \text{depth}[1] = 0$. $\Delta = 2$.
- Lift 4 by 2 levels ($2^1$): $4 \leftarrow \text{up}[4][1] = 1$.
- Now $4$ has become $1$. Since $u == v$, return $1$ immediately.
- Output: `1`.

Outputs: `3`, `1`, `1` — matches ground truth.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **One Node is Ancestor of the Other ($u = \text{LCA}(u, v)$)**:
   Equalizing depth moves $v$ directly to $u$. The condition `if (u == v) return u;` handles this immediately in $\mathcal{O}(\log n)$ without entering Phase 2.
2. **Querying the Same Node ($a = b$)**:
   $\Delta = 0$, $u = v$ immediately returns $a$.
3. **Querying the Root ($a = 1$)**:
   Depth is 0, correctly equalized and returns 1.
4. **Director Sentinel**:
   `up[1][j] = 0` for all $j$, preventing infinite loops or memory faults.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How do you calculate tree distance $\text{dist}(u, v)$ using LCA?**
   $$\text{dist}(u, v) = \text{depth}[u] + \text{depth}[v] - 2 \cdot \text{depth}[\text{LCA}(u, v)]$$
   This is the exact formula used in CSES 1135 (*Distance Queries*).
2. **How would you find the maximum edge weight on the path between $u$ and $v$?**
   Augment the binary lifting table: `max_edge[u][j]` stores the maximum edge weight along the $2^j$ ancestors. While lifting, accumulate $\max$.
3. **How does Farach-Colton and Bender's algorithm achieve $\langle \mathcal{O}(n), \mathcal{O}(1) \rangle$ LCA?**
   It reduces LCA to $\pm 1$ RMQ on the Euler tour depth array, divides the array into blocks of size $\frac{1}{2} \log_2 n$, and precomputes all $2^{B}$ possible block patterns in $\mathcal{O}(n)$ time.
4. **How would you find the LCA of three or more nodes $\{u, v, w\}$?**
   $\text{LCA}(u, v, w) = \text{LCA}(\text{LCA}(u, v), w)$.
5. **How does Tarjan's Offline LCA algorithm work?**
   Uses Disjoint Set Union (DSU) during a single DFS traversal. When finishing node $u$, any query $\{u, v\}$ where $v$ has already been visited has $\text{LCA} = \text{find}(v)$, answering all $q$ queries offline in $\mathcal{O}(n + q \alpha(n))$ time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Tree DFS & Doubling**: $\mathcal{O}(n \log n)$
  - **Per LCA Query**: $\mathcal{O}(\log n)$
  - **Overall Run Time**: $\mathcal{O}((n + q) \log n) \approx 0.08\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n \log n)$ auxiliary space ($\approx 15\text{ MB}$).

### Related CSES Problems
- [Company Queries I](https://cses.fi/problemset/task/1687) — $k$-th ancestor via binary lifting
- [Distance Queries](https://cses.fi/problemset/task/1135) — Path distance via LCA
- [Counting Paths](https://cses.fi/problemset/task/1136) — Prefix difference sums on tree paths
