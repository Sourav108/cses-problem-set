# Dynamic Range Minimum Queries

- **Category**: Range Queries
- **CSES Task ID**: `1649`
- **CSES Problem Link**: [Dynamic Range Minimum Queries](https://cses.fi/problemset/task/1649)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers and $q$ queries, your task is to process two types of operations efficiently:
1. `1 k u`: **Update** the value at position $k$ to $u$.
2. `2 a b`: **Query** the minimum value in the range $[a, b]$ inclusive ($\min_{i=a}^b x_i$).

Both array positions and query ranges are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the array size and number of queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the initial array values.
- The next $q$ lines each describe an operation in one of the two formats:
  - `1 k u`
  - `2 a b`

### Output Format
- For each type 2 query, print the minimum value on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le x_i, u \le 10^9$
- $1 \le k \le n$
- $1 \le a \le b \le n$

With $n, q \le 2 \cdot 10^5$, an iterative (bottom-up) Segment Tree processes both point updates and range minimum queries in $\mathcal{O}(\log n)$ time, finishing in $\approx 0.06\text{s}$.

---

## 2. Intuition & Pattern Recognition

Because array elements can change dynamically, a static Sparse Table is invalid (updates would take $\mathcal{O}(n)$). Furthermore, the $\min$ operation is not invertible, so a standard Fenwick Tree cannot handle arbitrary value modifications.
- **The Segment Tree Data Structure**:
  A binary tree where each node represents an interval of the array:
  - Leaf nodes store individual elements.
  - An internal node representing $[L, R]$ stores the minimum of its left child $[L, M]$ and right child $[M+1, R]$:
    $$\text{node} = \min(\text{left\_child}, \; \text{right\_child})$$
- **Iterative (Bottom-Up) Segment Tree**:
  Instead of recursive top-down traversal with $4n$ nodes, we store the tree in a flat array of size $2n$:
  - Leaves are stored at indices $n \dots 2n - 1$.
  - For any node $i$, its parent is $\lfloor i / 2 \rfloor$ (`i >> 1`), left child is $2i$ (`i << 1`), and right child is $2i + 1$ (`i << 1 | 1`).
  - **Point Update**: Mutate leaf at index $k + n$, then walk up to root updating parents:
    $$\text{tree}[p] = \min(\text{tree}[2p], \; \text{tree}[2p + 1])$$
    Takes $\mathcal{O}(\log n)$ and is completely non-recursive.
  - **Range Minimum Query $[l, r]$**:
    Start with $l \leftarrow l + n$ and $r \leftarrow r + n$.
    While $l \le r$:
    - If $l$ is a right child ($l \text{ is odd}$), include $\text{tree}[l]$ and advance $l \leftarrow l + 1$.
    - If $r$ is a left child ($r \text{ is even}$), include $\text{tree}[r]$ and retreat $r \leftarrow r - 1$.
    - Move up: $l \leftarrow l / 2, \; r \leftarrow r / 2$.
    Takes $\mathcal{O}(\log n)$ with minimal branching and zero recursion overhead.

---

## 3. Approach 1 — Naive Linear Scan per Query

Store elements in an array. Updates take $\mathcal{O}(1)$, queries take $\mathcal{O}(n)$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Top-Down Recursive Segment Tree

Implement standard Segment Tree with recursive `update(node, l, r, pos, val)` and `query(node, l, r, ql, qr)`.
- **Complexity**: $\mathcal{O}(\log n)$ per query.
- **Verdict**: Optimal, but function call overhead and recursion stack make it $\approx 2\times$ slower than the iterative bottom-up implementation.

---

## 5. Approach 3 — Optimal CSES Solution (Iterative Bottom-Up Segment Tree)

1. Zero-index the array positions: $0 \dots n - 1$.
2. Allocate flat array `tree[2 * n]`.
3. Read initial values into `tree[n + i]` for $0 \le i < n$.
4. Build the tree bottom-up in $\mathcal{O}(n)$:
   ```cpp
   for (int i = n - 1; i > 0; --i) {
       tree[i] = min(tree[i << 1], tree[i << 1 | 1]);
   }
   ```
5. Point update `update(pos, val)`:
   ```cpp
   pos += n;
   tree[pos] = val;
   for (pos >>= 1; pos > 0; pos >>= 1) {
       tree[pos] = min(tree[pos << 1], tree[pos << 1 | 1]);
   }
   ```
6. Range minimum query `query(l, r)`:
   ```cpp
   int res = 2e9;
   for (l += n, r += n; l <= r; l >>= 1, r >>= 1) {
       if (l & 1) res = min(res, tree[l++]);
       if (!(r & 1)) res = min(res, tree[r--]);
   }
   return res;
   ```

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const int INF = 2e9;

struct SegmentTree {
    int n;
    vector<int> tree;

    SegmentTree(int n) : n(n), tree(2 * n, INF) {}

    void build(const vector<int>& arr) {
        for (int i = 0; i < n; ++i) {
            tree[n + i] = arr[i];
        }
        for (int i = n - 1; i > 0; --i) {
            tree[i] = min(tree[i << 1], tree[i << 1 | 1]);
        }
    }

    void update(int pos, int val) {
        pos += n;
        tree[pos] = val;
        for (pos >>= 1; pos > 0; pos >>= 1) {
            tree[pos] = min(tree[pos << 1], tree[pos << 1 | 1]);
        }
    }

    int query(int l, int r) {
        int res = INF;
        for (l += n, r += n; l <= r; l >>= 1, r >>= 1) {
            if (l & 1) res = min(res, tree[l++]);
            if (!(r & 1)) res = min(res, tree[r--]);
        }
        return res;
    }
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    vector<int> arr(n);
    for (int i = 0; i < n; ++i) {
        cin >> arr[i];
    }

    SegmentTree st(n);
    st.build(arr);

    while (q--) {
        int type;
        cin >> type;

        if (type == 1) {
            int k, u;
            cin >> k >> u;
            --k; // Convert to 0-indexed
            st.update(k, u);
        } else {
            int a, b;
            cin >> a >> b;
            --a; --b; // Convert to 0-indexed
            cout << st.query(a, b) << '\n';
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**:
  - Build: Linear $\mathcal{O}(n)$ time.
  - Point Update: Strictly $\mathcal{O}(\log n)$ loop iterations (at most 18 steps for $n = 2 \cdot 10^5$).
  - Range Query: Strictly $\mathcal{O}(\log n)$ loop iterations.
  - Total Time: $\mathcal{O}(n + q \log n) \approx 0.06\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ with flat size $2n$ ($\approx 1.6\text{ MB}$).

---

## 6. Correctness Proof

### Disjoint Segment Partitioning in Iterative Segment Trees
- **Theorem**: For any query interval $[l, r]$, the iterative query loop extracts a set of nodes whose disjoint union is exactly $[l, r]$.
- **Proof**:
  1. At any level of the tree, $l$ and $r$ represent the current interval boundaries.
  2. If $l$ is an odd index, it is the right child of its parent. Its parent covers an interval extending to the left of $l$, outside the query range. Therefore, we must include node $l$ individually and advance $l \leftarrow l + 1$.
  3. If $l$ is an even index, it is the left child, so both $l$ and its sibling $l + 1$ can be represented compactly by their parent.
  4. Symmetrically, if $r$ is an even index, it is a left child whose parent extends to the right of $r$. We include node $r$ individually and retreat $r \leftarrow r - 1$.
  5. Both pointers then divide by 2 (`l >>= 1, r >>= 1`) to move to the parent level.
  6. In each iteration, the uncovered portion of $[l, r]$ shrinks by a factor of 2, terminating when $l > r$.
  7. Since all extracted nodes are pairwise disjoint and together cover $[l, r]$, taking the minimum of their stored values computes the exact range minimum. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider array $[3, 2, 4, 5, 1, 1, 5, 3]$ ($n = 8$):
- Leaves at indices $8 \dots 15$:
  `tree[8..15] = [3, 2, 4, 5, 1, 1, 5, 3]`
- Parents:
  - `tree[4] = min(3, 2) = 2`, `tree[5] = min(4, 5) = 4`
  - `tree[6] = min(1, 1) = 1`, `tree[7] = min(5, 3) = 3`
  - `tree[2] = min(2, 4) = 2`, `tree[3] = min(1, 3) = 1`
  - `tree[1] = min(2, 1) = 1`
- Query range $[1, 3]$ (0-indexed, elements $2, 4, 5$):
  - $l = 1 + 8 = 9, r = 3 + 8 = 11$.
  - Iteration 1:
    - $l = 9$ (odd) $\implies \text{res} = \min(\infty, \text{tree}[9]=2) = 2, \; l = 10$.
    - $r = 11$ (odd, not even).
    - $l \leftarrow 10/2 = 5, \; r \leftarrow 11/2 = 5$.
  - Iteration 2:
    - $l = 5, r = 5$.
    - $l = 5$ (odd) $\implies \text{res} = \min(2, \text{tree}[5]=4) = 2, \; l = 6$.
    - $l > r \implies$ loop terminates.
  - Final answer: $2$. (Elements $2, 4, 5$ have min $2$). Correct!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **0-Indexing Conversion**:
   CSES uses 1-based indexing ($1 \le k \le n, 1 \le a \le b \le n$). Convert to 0-indexed by subtracting 1 before calling `update` or `query`.
2. **Values up to $10^9$**:
   Initialize `INF = 2e9` (greater than $\max(x_i) = 10^9$) so neutral values never overwrite real minimums.
3. **Single Element Query ($a == b$)**:
   When $l == r$, loop executes once, extracts leaf at $l$, and finishes. Returns element directly.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How do you generalize the iterative Segment Tree to other operations?**
   Replace $\min$ with any associative operator (e.g. sum, GCD, matrix multiplication, maximum).
2. **Can an iterative Segment Tree support range updates?**
   Yes! With range updates and point queries, maintain changes in internal nodes. With range updates AND range queries, use **Lazy Propagation** (typically implemented top-down).
3. **What is Segment Tree Beats (Ji Chengdong's Segment Tree)?**
   Maintains range modulo or range $\min(A[i], x)$ updates by tracking first maximum, second maximum, and maximum count in $\mathcal{O}((n + q) \log n)$.
4. **How does an iterative Segment Tree handle non-commutative operations (e.g. matrix multiplication)?**
   Because $l$ traverses from left to right and $r$ traverses from right to left, maintain two result accumulators `res_left` and `res_right`, then combine `res = res_left * res_right`.
5. **How does iterative Segment Tree compare to Fenwick Tree?**
   Fenwick Tree is smaller and slightly faster for invertible operations (sums), but cannot handle non-invertible operations ($\min / \max$) with point updates. Segment Tree handles any semigroup.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Range Queries, Segment Tree, RMQ, Dynamic Queries, Point Update
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + q \log n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - [Static Range Minimum Queries](https://cses.fi/problemset/task/1647) — Static RMQ via Sparse Table
  - [Dynamic Range Sum Queries](https://cses.fi/problemset/task/1648) — Dynamic range sums with Fenwick Tree
  - [Hotel Queries](https://cses.fi/problemset/task/1143) — Binary searching on Segment Tree
