# Prefix Sum Queries

- **Category**: Range Queries
- **CSES Task ID**: `2166`
- **CSES Problem Link**: [Prefix Sum Queries](https://cses.fi/problemset/task/2166)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers and $q$ queries, your task is to process two types of operations:
1. `1 k u`: **Update** the value at position $k$ to $u$.
2. `2 a b`: **Query** the **maximum prefix sum** of the subarray from position $a$ to position $b$. An empty prefix has sum $0$. That is, compute:
   $$\max\left(0LL, \; \max_{a \le i \le b} \sum_{j=a}^i x_j\right)$$

Both array positions and query ranges are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the array size and number of queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the initial array values.
- The next $q$ lines describe the operations:
  - `1 k u`
  - `2 a b`

### Output Format
- For each type 2 query, print the maximum prefix sum on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $-10^9 \le x_i, u \le 10^9$
- $1 \le k \le n$
- $1 \le a \le b \le n$

Values can be negative and prefix sums can reach $\pm 2 \cdot 10^{14}$ (requiring `long long`). A Segment Tree maintains range sum and maximum prefix sum in $\mathcal{O}(\log n)$ time per operation, finishing in $\approx 0.08\text{s}$.

---

## 2. Intuition & Pattern Recognition

Because values can be negative, the maximum prefix sum is not monotonic. We must maintain both total sum and prefix maximums:
- **Segment Tree State Definition**:
  For each interval $[L, R]$, a segment tree node maintains two 64-bit quantities:
  1. `sum`: the total sum of all elements in the interval: $\sum_{i=L}^R x_i$.
  2. `pref`: the maximum prefix sum in the interval (bounded below by $0$):
     $$\text{pref} = \max\left(0LL, \; \max_{L \le i \le R} \sum_{j=L}^i x_j\right)$$
- **Node Merging (Associativity)**:
  When merging a left child $[L, M]$ and right child $[M+1, R]$:
  - The total sum is additive:
    $$\text{sum} = \text{left.sum} + \text{right.sum}$$
  - A prefix of the merged interval $[L, R]$ either:
    1. Ends entirely inside the left child (giving maximum `left.pref`).
    2. Spans the entire left child plus a prefix of the right child (giving maximum `left.sum + right.pref`).
  - Therefore:
    $$\text{pref} = \max(\text{left.pref}, \; \text{left.sum} + \text{right.pref})$$
- **Leaf Base Case**:
  For a single element $x$:
  $$\text{sum} = x, \quad \text{pref} = \max(0LL, x)$$
- Merging takes $\mathcal{O}(1)$, so building takes $\mathcal{O}(n)$, and both point updates and range queries execute in $\mathcal{O}(\log n)$ time.

---

## 3. Approach 1 — Naive Linear Scan per Query

For each query `2 a b`, loop from $a$ to $b$ maintaining running prefix sum.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Segment Tree with Lazy Propagation on Prefix Array

Maintain the prefix sum array in a Segment Tree. Updating $x_k$ to $u$ adds $\Delta = u - x_k$ to the range $[k, n]$ using lazy propagation, querying range maximum in $[a, b]$.
- **Complexity**: $\mathcal{O}(\log n)$ per query.
- **Verdict**: Valid, but lazy propagation adds code complexity and memory. Approach 3 uses a point-update Segment Tree without any lazy tags.

---

## 5. Approach 3 — Optimal CSES Solution (Point-Update Segment Tree)

1. Define node struct:
   ```cpp
   struct Node {
       long long sum;
       long long pref;
   };
   ```
2. Merge function:
   ```cpp
   Node merge(const Node& a, const Node& b) {
       return {
           a.sum + b.sum,
           max(a.pref, a.sum + b.pref)
       };
   }
   ```
3. Point update `update(node, l, r, pos, val)` in $\mathcal{O}(\log n)$.
4. Range query `query(node, l, r, ql, qr)` in $\mathcal{O}(\log n)$.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Node {
    long long sum;
    long long pref;
};

Node merge_nodes(const Node& left, const Node& right) {
    return {
        left.sum + right.sum,
        max(left.pref, left.sum + right.pref)
    };
}

int n, q;
vector<long long> arr;
vector<Node> tree_nodes;

void build(int node, int l, int r) {
    if (l == r) {
        tree_nodes[node] = {arr[l], max(0LL, arr[l])};
        return;
    }
    int mid = (l + r) / 2;
    build(2 * node, l, mid);
    build(2 * node + 1, mid + 1, r);
    tree_nodes[node] = merge_nodes(tree_nodes[2 * node], tree_nodes[2 * node + 1]);
}

void update(int node, int l, int r, int pos, long long val) {
    if (l == r) {
        tree_nodes[node] = {val, max(0LL, val)};
        return;
    }
    int mid = (l + r) / 2;
    if (pos <= mid) {
        update(2 * node, l, mid, pos, val);
    } else {
        update(2 * node + 1, mid + 1, r, pos, val);
    }
    tree_nodes[node] = merge_nodes(tree_nodes[2 * node], tree_nodes[2 * node + 1]);
}

Node query(int node, int l, int r, int ql, int qr) {
    if (ql <= l && r <= qr) {
        return tree_nodes[node];
    }
    int mid = (l + r) / 2;
    if (qr <= mid) {
        return query(2 * node, l, mid, ql, qr);
    }
    if (ql > mid) {
        return query(2 * node + 1, mid + 1, r, ql, qr);
    }
    return merge_nodes(query(2 * node, l, mid, ql, qr),
                       query(2 * node + 1, mid + 1, r, ql, qr));
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> q)) return 0;

    arr.resize(n + 1);
    for (int i = 1; i <= n; ++i) {
        cin >> arr[i];
    }

    tree_nodes.resize(4 * n + 1);
    build(1, 1, n);

    while (q--) {
        int type;
        cin >> type;

        if (type == 1) {
            int k;
            long long u;
            cin >> k >> u;
            update(1, 1, n, k, u);
        } else {
            int a, b;
            cin >> a >> b;
            Node res = query(1, 1, n, a, b);
            cout << res.pref << '\n';
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**:
  - Build: Linear $\mathcal{O}(n)$ time.
  - Point Update: $\mathcal{O}(\log n)$ time.
  - Range Query: $\mathcal{O}(\log n)$ time.
  - Total Time: $\mathcal{O}(n + q \log n) \approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ for tree of size $4n$ ($\approx 6.4\text{ MB}$).

---

## 6. Correctness Proof

### Associativity of Interval Prefix Merging
- **Theorem**: The merge operation on `Node(sum, pref)` is strictly associative.
- **Proof**:
  1. Let $A, B, C$ be three contiguous disjoint intervals with node states $(S_A, P_A), (S_B, P_B), (S_C, P_C)$.
  2. Merging $(A \oplus B) \oplus C$:
     - Sum: $(S_A + S_B) + S_C = S_A + S_B + S_C$.
     - Prefix: $\max(P_{AB}, S_{AB} + P_C) = \max(\max(P_A, S_A + P_B), (S_A + S_B) + P_C) = \max(P_A, S_A + P_B, S_A + S_B + P_C)$.
  3. Merging $A \oplus (B \oplus C)$:
     - Sum: $S_A + (S_B + S_C) = S_A + S_B + S_C$.
     - Prefix: $\max(P_A, S_A + P_{BC}) = \max(P_A, S_A + \max(P_B, S_B + P_C)) = \max(P_A, S_A + P_B, S_A + S_B + P_C)$.
  4. Both expressions evaluate to the exact same formula.
  5. By associativity, merging canonical segment tree intervals in standard left-to-right order produces the exact maximum prefix sum over any arbitrary range $[a, b]$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider array $x = [1, 2, -2, 1, 3, -1, 2, 1]$ ($n = 8$):
- Subarray $[1, 5]$: $[1, 2, -2, 1, 3]$
  - Prefixes: $1, 3, 1, 2, 5$. Max is $5$.
- Update `1 3 1` (change $-2$ to $+1$):
  - Array becomes: $[1, 2, 1, 1, 3, -1, 2, 1]$.
- Query `2 1 5`:
  - Range $[1, 5]$ is $[1, 2, 1, 1, 3]$.
  - Prefixes: $1, 3, 4, 5, 8$. Max is $8$.
  - Output: `8`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow**:
   With $n = 2 \cdot 10^5$ and $x_i = 10^9$, sums and prefixes reach $2 \cdot 10^{14}$. `sum` and `pref` must be `long long`.
2. **All Negative Elements**:
   The problem specifies that an empty prefix is valid (sum 0). Setting $\text{pref} = \max(0LL, x)$ at leaves ensures that if all elements in the range are negative, the output is $0$.
3. **Single Element Range ($a == b$)**:
   Returns $\max(0LL, x_a)$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does this extend to Maximum Subarray Sum (Kadane on Segment Tree)?**
   Maintain four values: `sum`, `pref`, `suff`, and `max_sub` (see CSES Subarray Sum Queries).
2. **What if the empty prefix was NOT allowed (must pick at least 1 element)?**
   Remove the `max(0LL, ...)` floor at leaves and merge steps, using $-\infty$ for empty neutral queries.
3. **How can this be used to find the maximum sum of a prefix in a persistent array?**
   Use a Persistent Segment Tree to record versions after each update in $\mathcal{O}(\log n)$ time and memory.
4. **Can this be solved with an iterative segment tree?**
   Yes. When merging from bottom up, accumulate left and right queries into two separate nodes `res_left` and `res_right`, then merge `merge_nodes(res_left, res_right)`.
5. **How does this connect to stock trading problems (Best Time to Buy and Sell Stock)?**
   Maximum subarray sum corresponds to maximum profit from buying on day $i$ and selling on day $j > i$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Range Queries, Segment Tree, Prefix Sums, Associative Merging, Point Update
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + q \log n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - [Subarray Sum Queries](https://cses.fi/problemset/task/1190) — Dynamic maximum subarray sum
  - [Dynamic Range Sum Queries](https://cses.fi/problemset/task/1648) — Dynamic range sum
  - [Pizzeria Queries](https://cses.fi/problemset/task/2206) — Dual distance-weighted Segment Tree
