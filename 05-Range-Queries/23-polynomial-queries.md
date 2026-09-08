# Polynomial Queries

- **Category**: Range Queries
- **CSES Task ID**: `1736`
- **CSES Problem Link**: [Polynomial Queries](https://cses.fi/problemset/task/1736)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an array of $n$ integers $t_1, t_2, \dots, t_n$. You must maintain the array and process $q$ queries of two types:
1. `1 a b`: **Arithmetic Progression Update**: Increase the first value in range $[a, b]$ by $1$, the second value by $2$, the third by $3$, and so on up to the last value by $(b - a + 1)$. That is:
   $$t_i \leftarrow t_i + (i - a + 1) \quad \text{for all } a \le i \le b$$
2. `2 a b`: **Calculate Sum**: Compute the sum of values in the range $[a, b]$ ($\sum_{i=a}^b t_i$).

Array indices are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the array size and the number of queries.
- The second line contains $n$ integers $t_1, t_2, \dots, t_n$: the initial array elements.
- The next $q$ lines describe the queries:
  - `1 a b`
  - `2 a b`

### Output Format
- For each query of type 2, print the sum of values on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le t_i \le 10^6$
- $1 \le a \le b \le n$

---

## 2. Intuition & Pattern Recognition

In a standard lazy segment tree, updates add a constant value $X$ uniformly across an interval $[a, b]$. Here, the update adds an **Arithmetic Progression (AP)** with common difference $D = 1$.

### Arithmetic Progression Lazy Tag
Any AP added to an interval $[l, r]$ can be uniquely parameterized by:
- $A$: the value added at the left endpoint $l$ ($i = l$).
- $D$: the common difference added per step.

For any index $i \in [l, r]$, the value added is:
$$\Delta(i) = A + D \cdot (i - l)$$

### Interval Sum Contribution
For an interval $[l, r]$ of length $L = r - l + 1$, the sum of this AP is:
$$\sum_{k=0}^{L-1} (A + D \cdot k) = A \cdot L + D \cdot \frac{L(L - 1)}{2}$$

### Merging and Pushing Down Tags
1. **Associativity of APs**:
   Adding an AP $(A_1, D_1)$ and another AP $(A_2, D_2)$ to the same interval results in:
   $$(A_1 + A_2, \; D_1 + D_2)$$
2. **Pushdown to Children**:
   Let the interval $[l, r]$ split at $mid$:
   - Left child $[l, mid]$ has length $L_1 = mid - l + 1$. Its left endpoint is $l$, so it receives the tag:
     $$(A, \; D)$$
   - Right child $[mid + 1, r]$ has left endpoint $mid + 1$. The value of the progression at $mid + 1$ is $A + D \cdot (mid + 1 - l) = A + D \cdot L_1$.
     Therefore, the right child receives the tag:
     $$(A + D \cdot L_1, \; D)$$

### Canonical Range Update
When the query range $[ql, qr]$ completely covers node interval $[l, r]$:
- The starting value of the progression at index $l$ is:
  $$A = l - ql + 1$$
- The common difference is:
  $$D = 1$$
- Apply tag $(A, D)$ to the node in $\mathcal{O}(1)$ time.

---

## 3. Approach 1 — Naive Linear Scan per Query

Directly mutate the array in a `for` loop for updates, and compute range sums in a `for` loop.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Second Difference Array with Fenwick Trees

Notice that the second finite difference of an arithmetic progression is zero except at its boundaries:
- Adding $(i - a + 1)$ to $[a, b]$ means in the first difference array $D_1[i] = t_i - t_{i-1}$, we add $+1$ to $[a, b]$ and subtract $(b - a + 1)$ at $b + 1$.
- In the second difference array $D_2[i] = D_1[i] - D_1[i-1]$, this becomes point updates: $+1$ at $a$, $-1$ at $b + 1$, and $-(b - a + 1)$ at $b + 1$.
- By integrating twice, range sums can be maintained using two Fenwick trees.
- While fast, the algebraic coefficients in the double prefix sum are intricate. The Lazy Segment Tree (Approach 3) is much more intuitive and less error-prone.

---

## 5. Approach 3 — Optimal CSES Solution (AP Lazy Segment Tree)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

static const int MAXN = 200005;

struct Node {
    long long sum;
    long long lazy_A;
    long long lazy_D;

    Node() : sum(0), lazy_A(0), lazy_D(0) {}
};

Node tree[4 * MAXN];
long long initial_arr[MAXN];

void apply_tag(int node, int l, int r, long long A, long long D) {
    long long L = r - l + 1;
    tree[node].sum += A * L + D * (L * (L - 1) / 2);
    tree[node].lazy_A += A;
    tree[node].lazy_D += D;
}

void push_down(int node, int l, int r) {
    if (tree[node].lazy_A != 0 || tree[node].lazy_D != 0) {
        int mid = l + (r - l) / 2;
        long long L1 = mid - l + 1;
        apply_tag(2 * node, l, mid, tree[node].lazy_A, tree[node].lazy_D);
        apply_tag(2 * node + 1, mid + 1, r, tree[node].lazy_A + tree[node].lazy_D * L1, tree[node].lazy_D);
        tree[node].lazy_A = 0;
        tree[node].lazy_D = 0;
    }
}

void build(int node, int l, int r) {
    tree[node] = Node();
    if (l == r) {
        tree[node].sum = initial_arr[l];
        return;
    }
    int mid = l + (r - l) / 2;
    build(2 * node, l, mid);
    build(2 * node + 1, mid + 1, r);
    tree[node].sum = tree[2 * node].sum + tree[2 * node + 1].sum;
}

void update(int node, int l, int r, int ql, int qr) {
    if (ql <= l && r <= qr) {
        long long A = l - ql + 1;
        long long D = 1;
        apply_tag(node, l, r, A, D);
        return;
    }
    push_down(node, l, r);
    int mid = l + (r - l) / 2;
    if (ql <= mid) update(2 * node, l, mid, ql, qr);
    if (qr > mid) update(2 * node + 1, mid + 1, r, ql, qr);
    tree[node].sum = tree[2 * node].sum + tree[2 * node + 1].sum;
}

long long query(int node, int l, int r, int ql, int qr) {
    if (ql <= l && r <= qr) {
        return tree[node].sum;
    }
    push_down(node, l, r);
    int mid = l + (r - l) / 2;
    long long res = 0;
    if (ql <= mid) res += query(2 * node, l, mid, ql, qr);
    if (qr > mid) res += query(2 * node + 1, mid + 1, r, ql, qr);
    return res;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    for (int i = 1; i <= n; ++i) {
        cin >> initial_arr[i];
    }

    build(1, 1, n);

    while (q--) {
        int type, a, b;
        cin >> type >> a >> b;
        if (type == 1) {
            update(1, 1, n, a, b);
        } else {
            cout << query(1, 1, n, a, b) << '\n';
        }
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Linearity of Polynomial Additions
An arithmetic progression $\Delta(i) = A + D(i - l)$ is a degree-1 polynomial.
Because differentiation and summation are linear operators:
1. The sum of two degree-1 polynomials is another degree-1 polynomial:
   $$(A_1 + D_1 k) + (A_2 + D_2 k) = (A_1 + A_2) + (D_1 + D_2)k$$
   Thus, lazy tags compose additively: $(A_1 + A_2, D_1 + D_2)$.
2. When an interval $[l, r]$ is split at $mid$, for any index $i \in [mid + 1, r]$:
   $$i - l = (mid + 1 - l) + (i - (mid + 1)) = L_1 + k$$
   where $k = i - (mid + 1)$ is the 0-based offset in the right child.
   Substituting into the polynomial:
   $$A + D(i - l) = A + D(L_1 + k) = (A + D \cdot L_1) + D \cdot k$$
   which is an arithmetic progression with base value $A' = A + D \cdot L_1$ and identical difference $D$.
3. The sum formula $\sum_{k=0}^{L-1} (A + D k) = A L + D \frac{L(L-1)}{2}$ is Gauss's summation formula and exact.
Therefore, all pushdown and range evaluation operations preserve the true element values across the array.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
4 2 3 1 7
2 1 5
1 1 5
2 1 5
```

### Initial Array
$t = [4, 2, 3, 1, 7]$

### Query 1: `2 1 5`
- Sum of $t[1 \dots 5] = 4 + 2 + 3 + 1 + 7 = 17$.
- Output: `17`.

### Query 2: `1 1 5` ($a = 1, b = 5$)
- Added sequence: $[1, 2, 3, 4, 5]$.
- New array:
  - $t_1 = 4 + 1 = 5$
  - $t_2 = 2 + 2 = 4$
  - $t_3 = 3 + 3 = 6$
  - $t_4 = 1 + 4 = 5$
  - $t_5 = 7 + 5 = 12$
  Array becomes $[5, 4, 6, 5, 12]$.

### Query 3: `2 1 5`
- Sum of $t[1 \dots 5] = 5 + 4 + 6 + 5 + 12 = 32$.
- Formula check: $17 + \frac{5 \times 6}{2} = 17 + 15 = 32$.
- Output: `32`.

Both outputs match the sample: `17`, `32`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow**:
   $n = 2 \cdot 10^5, q = 2 \cdot 10^5$. Each query can add up to $2 \cdot 10^{10}$. Total array sum can reach $4 \cdot 10^{15}$, overflowing standard 32-bit signed integer. `sum`, `lazy_A`, and `lazy_D` must be `long long`.
2. **Gauss Formula Division**:
   In `L * (L - 1) / 2`, because $L$ and $L - 1$ have opposite parity, the product is always even, so integer division by 2 is exact.
3. **Single Element Update ($a = b$)**:
   $L = 1$, $A = 1, D = 1$. The sum added is $1 \cdot 1 + 1 \cdot (0 / 2) = 1$. Exactly increments position $a$ by 1.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the progression has general initial value $x$ and difference $d$?**
   Our `apply_tag(node, l, r, A, D)` formulation already accepts arbitrary $A$ and $D$.
2. **What if the update is quadratic (e.g., increase $i$-th element by $i^2$)?**
   A degree-2 polynomial requires three lazy tags: $(A, B, C)$ for $A + B k + C k^2$. The interval sum requires Gauss's sum of squares $\sum k^2 = \frac{k(k+1)(2k+1)}{6}$.
3. **Can we support general degree-$d$ polynomials?**
   Yes, maintaining $d+1$ lazy coefficients per node. Pushing down involves expanding $(k + L_1)^d$ via the Binomial Theorem, taking $\mathcal{O}(d^2)$ per pushdown.
4. **How would you answer range minimum queries with polynomial updates?**
   Because an arithmetic progression is monotonic (increasing or decreasing), the minimum on $[l, r]$ occurs at either endpoint ($l$ or $r$). However, combining historical minimums of overlapping APs produces complex envelopes, requiring Li Chao Trees or Segment Tree Beats.
5. **How does the Fenwick Tree approach compare in speed?**
   The two-Fenwick tree approach is slightly faster by a constant factor ($\approx 1.5\times$) because it avoids recursion, but requires deriving the double prefix sum formula:
   $\sum_{i=1}^k t_i = \sum (k - i + 1) D_1[i]$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Build**: $\mathcal{O}(n)$
  - **AP Range Update**: $\mathcal{O}(\log n)$
  - **Range Sum Query**: $\mathcal{O}(\log n)$
  - **Overall Run Time**: $\mathcal{O}(n + q \log n) \approx 0.09\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space ($4N \approx 8 \cdot 10^5$ nodes $\approx 32\text{ MB}$).

### Related CSES Problems
- [Range Updates and Sums](https://cses.fi/problemset/task/1735) — Dual lazy propagation
- [Prefix Sum Queries](https://cses.fi/problemset/task/2166) — Prefix operations on Segment Trees
- [Range Update Queries](https://cses.fi/problemset/task/1651) — Point query with difference array
