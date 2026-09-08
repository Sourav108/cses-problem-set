# Subarray Sum Queries II

- **Category**: Range Queries
- **CSES Task ID**: `3226`
- **CSES Problem Link**: [Subarray Sum Queries II](https://cses.fi/problemset/task/3226)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an array of $n$ integers $x_1, x_2, \dots, x_n$ and $q$ queries.
In each query:
- Given a range $[a, b]$ with $1 \le a \le b \le n$, calculate the **maximum subarray sum** among all contiguous subarrays lying entirely within $[a, b]$.

Empty subarrays (with sum $0$) are allowed, so the answer is always $\ge 0$.
The array elements do not change (there are no updates).

### Input Format
- The first line contains two integers $n$ and $q$: the number of elements and queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the contents of the array.
- The next $q$ lines each contain two integers $a$ and $b$: the boundaries of the query range.

### Output Format
- For each query, print the maximum subarray sum in $[a, b]$ on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $-10^9 \le x_i \le 10^9$
- $1 \le a \le b \le n$

---

## 2. Intuition & Pattern Recognition

In CSES 1190 (*Subarray Sum Queries*), updates occurred dynamically and every query inspected the entire array $[1, n]$ from the root of the Segment Tree. Here, the challenge is reversed: the array is static, but each query restricts the search to an arbitrary subarray range $[a, b]$.

Because the monoid combination rule of Kadane's algorithm is strictly associative:
- Each node maintains:
  - `sum`: total sum of elements in the node's interval.
  - `pref`: maximum prefix sum in the interval ($\ge 0$).
  - `suff`: maximum suffix sum in the interval ($\ge 0$).
  - `ans`: maximum contiguous subarray sum in the interval ($\ge 0$).
- When querying an arbitrary range $[a, b]$, the segment tree decomposes $[a, b]$ into $\mathcal{O}(\log n)$ canonical subsegments from left to right.
- Merging these $\mathcal{O}(\log n)$ nodes sequentially in order yields the exact maximum subarray sum for $[a, b]$.

### Identity Node (Neutral Element)
For out-of-bounds recursive calls, the identity element of this monoid is:
$$\text{sum} = 0, \quad \text{pref} = 0, \quad \text{suff} = 0, \quad \text{ans} = 0$$
Merging any node $X$ with the identity node preserves $X$ unchanged.

---

## 3. Approach 1 — Naive Kadane Scan per Query

For each query $[a, b]$, run Kadane's linear algorithm across $x_a, \dots, x_b$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 2 \cdot 10^5 \times 2 \cdot 10^5 = 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Sqrt Decomposition

Decompose array into $\sqrt{n}$ blocks. Each block stores its precalculated Kadane node. A query merges complete blocks and individual boundary elements in $\mathcal{O}(\sqrt{n})$ time.
- Time per query: $\mathcal{O}(\sqrt{n})$.
- Total time: $\mathcal{O}(q \sqrt{n}) \approx 9 \cdot 10^7$ operations.
- Accepted, but Segment Tree (Approach 3) is strictly faster ($\mathcal{O}(\log n)$) and takes only $\approx 0.08\text{s}$.

---

## 5. Approach 3 — Optimal CSES Solution (Segment Tree Range Merging)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Node {
    long long sum;
    long long pref;
    long long suff;
    long long ans;

    Node() : sum(0), pref(0), suff(0), ans(0) {}
    Node(long long v) {
        sum = v;
        pref = max(0LL, v);
        suff = max(0LL, v);
        ans = max(0LL, v);
    }
};

Node merge(const Node& l, const Node& r) {
    Node res;
    res.sum = l.sum + r.sum;
    res.pref = max(l.pref, l.sum + r.pref);
    res.suff = max(r.suff, r.sum + l.suff);
    res.ans = max({l.ans, r.ans, l.suff + r.pref});
    return res;
}

static const int MAXN = 200005;
Node tree[4 * MAXN];
long long x[MAXN];

void build(int node, int l, int r) {
    if (l == r) {
        tree[node] = Node(x[l]);
        return;
    }
    int mid = l + (r - l) / 2;
    build(2 * node, l, mid);
    build(2 * node + 1, mid + 1, r);
    tree[node] = merge(tree[2 * node], tree[2 * node + 1]);
}

Node query(int node, int l, int r, int ql, int qr) {
    if (ql <= l && r <= qr) {
        return tree[node];
    }
    int mid = l + (r - l) / 2;
    if (qr <= mid) {
        return query(2 * node, l, mid, ql, qr);
    }
    if (ql > mid) {
        return query(2 * node + 1, mid + 1, r, ql, qr);
    }
    return merge(query(2 * node, l, mid, ql, qr),
                 query(2 * node + 1, mid + 1, r, ql, qr));
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
        int a, b;
        cin >> a >> b;
        cout << query(1, 1, n, a, b).ans << '\n';
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Homomorphism and Interval Decomposition
The Kadane structure $(\mathcal{S}, \text{merge})$ forms a mathematical monoid:
1. **Associativity**: Proved in CSES 1190. For any disjoint contiguous subintervals $A, B, C$, $(A \oplus B) \oplus C = A \oplus (B \oplus C)$.
2. **Identity Element**: $I = (0, 0, 0, 0)$. For any interval $A$, $A \oplus I = I \oplus A = A$ since:
   - $A.\text{sum} + 0 = A.\text{sum}$
   - $\max(A.\text{pref}, A.\text{sum} + 0) = \max(A.\text{pref}, 0) = A.\text{pref}$ (since $A.\text{pref} \ge 0$)
   - $\max(A.\text{suff}, 0 + A.\text{suff}) = A.\text{suff}$
   - $\max(A.\text{ans}, 0, A.\text{suff} + 0) = A.\text{ans}$.

Because the segment tree recursively decomposes query interval $[a, b]$ into disjoint subsegments $[L_1, R_1], [L_2, R_2], \dots, [L_m, R_m]$ in exact left-to-right order, the returned node is:
$$\text{Node}([a, b]) = \bigoplus_{k=1}^m \text{Node}([L_k, R_k])$$
By associativity, this equals the Kadane state of the entire concatenated interval $[a, b]$. Its `ans` field is therefore the exact maximum subarray sum in $[a, b]$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
8 4
2 5 1 -2 3 -1 -7 1
2 4
2 5
6 7
4 8
```

### Initial Array
$x = [2, 5, 1, -2, 3, -1, -7, 1]$

### Query 1: `2 4` ($a = 2, b = 4$)
- Subarray $x[2 \dots 4] = [5, 1, -2]$.
- Contiguous subarrays: $[5], [5, 1] = 6, [5, 1, -2] = 4, [1] = 1, [1, -2] = -1, [-2] = -2$, empty $= 0$.
- Maximum subarray sum: $5 + 1 = 6$.
- Output: `6`.

### Query 2: `2 5` ($a = 2, b = 5$)
- Subarray $x[2 \dots 5] = [5, 1, -2, 3]$.
- Subarray sum of all four elements: $5 + 1 - 2 + 3 = 7$.
- Output: `7`.

### Query 3: `6 7` ($a = 6, b = 7$)
- Subarray $x[6 \dots 7] = [-1, -7]$.
- Both elements are negative. The best subarray is empty with sum 0.
- Output: `0`.

### Query 4: `4 8` ($a = 4, b = 8$)
- Subarray $x[4 \dots 8] = [-2, 3, -1, -7, 1]$.
- Best positive subarray is $[3]$ (sum 3).
- Output: `3`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **All Negative Elements within $[a, b]$**:
   When all elements in the queried range are negative, `Node(v)` sets `pref = suff = ans = 0`. The merged result correctly outputs `0` for empty subarray.
2. **Single Element Query ($a = b$)**:
   The segment tree navigates directly to leaf node $a$, returning $\max(0LL, x_a)$ in $\mathcal{O}(\log n)$ time.
3. **64-bit Values**:
   Sum of elements can reach $\pm 2 \cdot 10^{14}$. All intermediate values (`sum`, `pref`, `suff`, `ans`) are declared as `long long`.
4. **Range Query Decomposition Order**:
   In `query`, the left child result must strictly be merged on the left (`merge(query(left), query(right))`), because the Kadane operation is non-commutative ($A \oplus B \ne B \oplus A$).

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does this compare to Sparse Table for RMQ?**
   Sparse Table cannot be used directly for arbitrary range Kadane because the Kadane merge is not idempotent ($A \oplus A \ne A$), so overlapping intervals cannot be queried in $\mathcal{O}(1)$.
2. **Can we achieve $\mathcal{O}(1)$ query time without updates?**
   No general $\mathcal{O}(1)$ query time algorithm is known for maximum subarray sum with $\mathcal{O}(n)$ preprocessing. However, with $\mathcal{O}(n \log n)$ preprocessing and Disjoint Sparse Table (DST), queries can be answered in $\mathcal{O}(1)$ time!
3. **What if we require non-empty subarrays?**
   Initialize leaves with `sum = v, pref = v, suff = v, ans = v` (no clipping at 0).
   The identity node must use $-\infty$ (`-2e18`) for `pref`, `suff`, and `ans`, and $0$ for `sum`.
4. **How would you return the exact indices $[l^*, r^*]$ of the optimal subarray?**
   Store coordinate bounds along with each field in `Node`. During `merge`, assign coordinates corresponding to whichever term achieved the maximum.
5. **Can this be combined with persistent segment trees?**
   Yes. If the array has version history or branch copies, queries on any past version can be performed by routing the query through that version's root.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Build**: $\mathcal{O}(n)$
  - **Per Query**: $\mathcal{O}(\log n)$
  - **Overall Run Time**: $\mathcal{O}(n + q \log n) \approx 0.08\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space for the segment tree array ($4N \approx 8 \cdot 10^5$ nodes $\approx 25\text{ MB}$).

### Related CSES Problems
- [Subarray Sum Queries](https://cses.fi/problemset/task/1190) — Dynamic point-update version
- [Static Range Minimum Queries](https://cses.fi/problemset/task/1647) — Static RMQ on intervals
- [Prefix Sum Queries](https://cses.fi/problemset/task/2166) — Range prefix maximum queries
