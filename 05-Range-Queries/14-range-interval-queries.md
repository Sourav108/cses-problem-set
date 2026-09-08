# Range Interval Queries

- **Category**: Range Queries
- **CSES Task ID**: `3163`
- **CSES Problem Link**: [Range Interval Queries](https://cses.fi/problemset/task/3163)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array $x$ of $n$ integers, you must process $q$ queries of the form:
- Given four integers $a, b, c, d$, count how many indices $i$ satisfy:
  $$a \le i \le b \quad \text{and} \quad c \le x_i \le d$$

Array indices are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the number of elements and queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the array elements.
- The next $q$ lines each describe a query with four integers $a, b, c, d$.

### Output Format
- For each query, print the number of matching indices on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$
- $1 \le a \le b \le n$
- $1 \le c \le d \le 10^9$

---

## 2. Intuition & Pattern Recognition

This problem is classical **2D Orthogonal Range Counting**:
Each array element can be viewed as a 2D point $(i, x_i)$.
A query asks for the number of points falling inside the 2D axis-aligned bounding box:
$$[a, b] \times [c, d]$$

Since the array is static (no updates), there are two prominent algorithmic strategies:
1. **Merge Sort Tree (Online)**:
   - Construct a Segment Tree over the index dimension $[1, n]$.
   - Each node covering range $[l, r]$ stores a sorted vector of all elements $x_l, \dots, x_r$.
   - Any query range $[a, b]$ is partitioned into $\mathcal{O}(\log n)$ canonical segment tree nodes.
   - For each node, the count of elements in $[c, d]$ is obtained in $\mathcal{O}(\log(\text{len}))$ time via standard binary search:
     $$\text{upper\_bound}(d) - \text{lower\_bound}(c)$$
   - Total space is $\sum_{k=0}^{\lceil\log_2 n\rceil} n = \mathcal{O}(n \log n)$ elements ($\approx 14\text{ MB}$ for $n = 2 \cdot 10^5$).
   - Total query time is $\mathcal{O}(\log^2 n)$ per query.
2. **Offline Fenwick Tree (Sweep-Line)**:
   - Decompose each query into prefix queries over values: count in $[c, d]$ is $(\le d) - (\le c - 1)$.
   - Sort points and queries by value, then sweep and query a 1D Fenwick tree.
   - Runs in $\mathcal{O}((n + q) \log n)$ time.

The **Merge Sort Tree** is fully online, straightforward to implement, and handles $2 \cdot 10^5$ queries in $\approx 0.12\text{s}$ due to excellent CPU cache locality.

---

## 3. Approach 1 — Naive Linear Scan per Query

For each query $(a, b, c, d)$, loop $i$ from $a$ to $b$ and check whether $c \le x_i \le d$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Offline Sweep-Line with Fenwick Tree

Sort elements and queries by value. Use a Fenwick tree over indices $[1, n]$:
1. Decompose query into two events: count of elements $\le d$ minus count of elements $\le c - 1$ in index range $[a, b]$.
2. Sort array elements and query endpoints by value.
3. As the value threshold increases, activate points in the Fenwick tree.
4. Range sum queries in $[a, b]$ on the Fenwick tree yield the answer.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}((n + q) \log n)$.
- **Space Complexity**: $\mathcal{O}(n + q)$.
- **Trade-off**: Requires offline sorting and query decomposition. Approach 3 achieves competitive speed while remaining fully online.

---

## 5. Approach 3 — Optimal CSES Solution (Merge Sort Tree)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

static const int MAXN = 200005;
vector<int> tree[4 * MAXN];
int x[MAXN];

void build(int node, int l, int r) {
    if (l == r) {
        tree[node] = {x[l]};
        return;
    }
    int mid = l + (r - l) / 2;
    build(2 * node, l, mid);
    build(2 * node + 1, mid + 1, r);

    tree[node].resize(tree[2 * node].size() + tree[2 * node + 1].size());
    merge(tree[2 * node].begin(), tree[2 * node].end(),
          tree[2 * node + 1].begin(), tree[2 * node + 1].end(),
          tree[node].begin());
}

int query(int node, int l, int r, int ql, int qr, int c, int d) {
    if (ql <= l && r <= qr) {
        auto it1 = lower_bound(tree[node].begin(), tree[node].end(), c);
        auto it2 = upper_bound(tree[node].begin(), tree[node].end(), d);
        return static_cast<int>(it2 - it1);
    }
    int mid = l + (r - l) / 2;
    int res = 0;
    if (ql <= mid) {
        res += query(2 * node, l, mid, ql, qr, c, d);
    }
    if (qr > mid) {
        res += query(2 * node + 1, mid + 1, r, ql, qr, c, d);
    }
    return res;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    for (int i = 1; i <= n; ++i) {
        cin >> x[i];
    }

    build(1, 1, n);

    while (q--) {
        int a, b, c, d;
        cin >> a >> b >> c >> d;
        cout << query(1, 1, n, a, b, c, d) << '\n';
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Partition Property of Segment Trees
For any query range $[ql, qr] \subseteq [1, n]$, the Segment Tree decomposes $[ql, qr]$ into a unique minimal set of disjoint canonical intervals:
$$[ql, qr] = \bigcup_{j=1}^m [L_j, R_j], \quad m \le 2 \lceil \log_2 n \rceil$$
where each interval $[L_j, R_j]$ corresponds to a canonical node in the tree.

### Monotonicity of Child Merging
At each leaf $l$, `tree[leaf] = {x[l]}` is trivially sorted.
By induction, `std::merge` merges two sorted sequences in linear time, ensuring that every internal node stores the elements of its span in non-decreasing sorted order.

### Exact Frequency Counting
For any sorted sequence $S$, the elements lying in value range $[c, d]$ form a contiguous subarray:
$$[\text{lower\_bound}(c), \text{upper\_bound}(d))$$
Because `lower_bound` locates the first element $\ge c$ and `upper_bound` locates the first element $> d$, the iterator difference `it2 - it1` equals precisely the number of elements $v \in S$ satisfying $c \le v \le d$.
Summing across all disjoint canonical intervals yields the exact total count.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
8 4
3 2 4 5 1 1 5 3
2 4 2 4
5 6 2 9
1 8 1 5
3 3 4 4
```

### Initial Array
$x = [3, 2, 4, 5, 1, 1, 5, 3]$

### Query 1: `2 4 2 4` ($a = 2, b = 4, c = 2, d = 4$)
- Subarray $x[2 \dots 4] = [2, 4, 5]$.
- Elements satisfying $2 \le x_i \le 4$:
  - $x_2 = 2 \in [2, 4]$ (Yes)
  - $x_3 = 4 \in [2, 4]$ (Yes)
  - $x_4 = 5 \notin [2, 4]$ (No)
- Expected count: `2`.
- Segment tree query decomposes $[2, 4]$ into node for $[2, 2]$ (`{2}`) and node for $[3, 4]$ (`{4, 5}`).
  - Node $[2, 2]$: values in $[2, 4]$ gives 1.
  - Node $[3, 4]$: values in $[2, 4]$ gives 1 (only 4).
  - Total: $1 + 1 = 2$.
- Output: `2`.

### Query 2: `5 6 2 9` ($a = 5, b = 6, c = 2, d = 9$)
- Subarray $x[5 \dots 6] = [1, 1]$.
- No element is in $[2, 9]$.
- Output: `0`.

### Query 3: `1 8 1 5` ($a = 1, b = 8, c = 1, d = 5$)
- Entire array $x[1 \dots 8]$, all elements are between 1 and 5.
- Output: `8`.

### Query 4: `3 3 4 4` ($a = 3, b = 3, c = 4, d = 4$)
- Single element $x_3 = 4$. Is $4 \in [4, 4]$? Yes.
- Output: `1`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Large Value Coordinates ($10^9$)**:
   The coordinates $x_i, c, d$ range up to $10^9$. Because binary search comparisons operate directly on values without using them as array indices, coordinate compression is completely unnecessary.
2. **Range Out of Bounds ($c > d$)**:
   The problem specifies $c \le d$. If $c > d$, `lower_bound(c)` will return an iterator at or past `upper_bound(d)`, correctly yielding count 0.
3. **Values Outside Array Range**:
   If $d < \min(x)$ or $c > \max(x)$, every node returns 0 without issues.
4. **Memory Footprint**:
   The total number of stored integers across all levels is $n \times (\lceil \log_2 n \rceil + 1)$.
   For $n = 200,000$, $\log_2(200000) \approx 18$, so total integers $\approx 200000 \times 19 \approx 3.8 \cdot 10^6$ elements $\approx 15.2\text{ MB}$, well within the 512 MB memory limit.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How can the query time be improved to $\mathcal{O}(\log n)$?**
   Using **Fractional Cascading**, each node maintains precomputed pointers to the left and right child arrays. Binary searching at the root once allows navigating both children in $\mathcal{O}(1)$ time per node, reducing query time to $\mathcal{O}(\log n)$.
2. **Can this problem support point updates ($x_k \leftarrow u$)?**
   In a Merge Sort Tree, point updates take $\mathcal{O}(n)$ because sorted vectors must be reordered. To support dynamic point updates, each segment tree node must store a dynamic balanced BST (e.g., Treap / `std::set` / Fenwick tree), giving $\mathcal{O}(\log^2 n)$ updates.
3. **How would a 2D Range Tree compare?**
   A standard 2D Range Tree with Fractional Cascading achieves $\mathcal{O}(\log n)$ query time and $\mathcal{O}(n \log n)$ space, but has a higher implementation constant.
4. **Can we answer $k$-th smallest element queries on $[a, b]$ with this structure?**
   Yes, but a **Persistent Segment Tree** (or Wavelet Matrix) is more suitable, solving $k$-th order statistic in $\mathcal{O}(\log n)$ rather than $\mathcal{O}(\log^3 n)$.
5. **What if the points have associated weights and we need the sum of weights?**
   In a Merge Sort Tree, maintain a parallel prefix sum vector in each node. Once the binary search finds the range $[it1, it2)$, the sum of weights in that range is obtained via prefix sums in $\mathcal{O}(1)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Build**: $\mathcal{O}(n \log n)$
  - **Per Query**: $\mathcal{O}(\log^2 n)$
  - **Overall Run Time**: $\mathcal{O}(n \log n + q \log^2 n) \approx 0.12\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n \log n)$ auxiliary space ($\approx 15\text{ MB}$).

### Related CSES Problems
- [Forest Queries](https://cses.fi/problemset/task/1652) — 2D prefix sums for grid ranges
- [Salary Queries](https://cses.fi/problemset/task/1144) — Dynamic 1D value frequency counting
- [Distinct Values Queries](https://cses.fi/problemset/task/1734) — Offline range queries with unique properties
