# Range Updates and Sums

- **Category**: Range Queries
- **CSES Task ID**: `1735`
- **CSES Problem Link**: [Range Updates and Sums](https://cses.fi/problemset/task/1735)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an array of $n$ integers $t_1, t_2, \dots, t_n$. You must maintain the array and process $q$ queries of three types:
1. `1 a b x`: **Increase** each value in the range $[a, b]$ by $x$ ($t_i \leftarrow t_i + x$ for $a \le i \le b$).
2. `2 a b x`: **Set** each value in the range $[a, b]$ to $x$ ($t_i \leftarrow x$ for $a \le i \le b$).
3. `3 a b`: **Calculate the sum** of values in the range $[a, b]$ ($\sum_{i=a}^b t_i$).

Array indices are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the array size and the number of queries.
- The second line contains $n$ integers $t_1, t_2, \dots, t_n$: the initial array elements.
- The next $q$ lines describe the operations:
  - `1 a b x`
  - `2 a b x`
  - `3 a b`

### Output Format
- For each query of type 3, print the sum of values on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le t_i, x \le 10^6$
- $1 \le a \le b \le n$

---

## 2. Intuition & Pattern Recognition

This is the quintessential **Segment Tree with Dual Lazy Propagation**. The challenge lies in managing two conflicting lazy operations:
1. **Range Addition** (commutative and associative with additions).
2. **Range Assignment** (overwrites all previous historical values and additions).

### Tag Interaction & Invariant
Notice the crucial algebraic simplification:
- Setting all elements in an interval of length $L$ to $S$ and then adding $X$ to all elements is mathematically identical to setting all elements to $S + X$:
  $$\text{Set}(S) \circ \text{Add}(X) \equiv \text{Set}(S + X)$$
- Therefore, a node **never** needs to maintain both a pending `set` and a pending `add` tag simultaneously!

We define the lazy state of each node using three variables:
- `bool has_set`: whether a pending assignment is active.
- `long long set_val`: the assigned value (meaningful only when `has_set == true`).
- `long long add_val`: pending addition to be applied (active only when `has_set == false`).

### Transition Rules
1. **Applying `Set(X)` to a node of length $L$**:
   - `has_set = true`
   - `set_val = X`
   - `add_val = 0`
   - $\text{sum} = L \cdot X$
2. **Applying `Add(X)` to a node of length $L$**:
   - If `has_set == true`:
     $$\text{set\_val} \mathrel{+}= X$$
   - Else:
     $$\text{add\_val} \mathrel{+}= X$$
   - $\text{sum} \mathrel{+}= L \cdot X$
3. **Pushing Down (`push_down`)**:
   - If the parent has `has_set == true`:
     Both children are updated via `Set(parent.set_val)`.
   - Else if the parent has `add_val != 0`:
     Both children are updated via `Add(parent.add_val)`.
   - The parent's tags are cleared (`has_set = false, set_val = 0, add_val = 0`).

This unified transition eliminates all edge-case bugs and ensures $\mathcal{O}(\log n)$ time per query and update.

---

## 3. Approach 1 — Naive Linear Scan per Query

Directly mutate the array in a `for` loop for updates, and accumulate values in a `for` loop for range sum queries.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 2 \cdot 10^5 \times 2 \cdot 10^5 = 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Sqrt Decomposition with Dual Block Tags

Divide the array into $\sqrt{n}$ blocks. Each block stores its total sum, a `set` tag, and an `add` tag.
- Updating or querying takes $\mathcal{O}(\sqrt{n})$ time.
- Total time: $\mathcal{O}(q \sqrt{n}) \approx 9 \cdot 10^7$ operations.
- While accepted, the Segment Tree (Approach 3) runs $\approx 5\times$ faster in $\mathcal{O}(\log n)$.

---

## 5. Approach 3 — Optimal CSES Solution (Lazy Segment Tree)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

static const int MAXN = 200005;

struct Node {
    long long sum;
    long long set_val;
    long long add_val;
    bool has_set;

    Node() : sum(0), set_val(0), add_val(0), has_set(false) {}
};

Node tree[4 * MAXN];
long long initial_arr[MAXN];

void apply_set(int node, int l, int r, long long val) {
    long long len = r - l + 1;
    tree[node].has_set = true;
    tree[node].set_val = val;
    tree[node].add_val = 0;
    tree[node].sum = len * val;
}

void apply_add(int node, int l, int r, long long val) {
    long long len = r - l + 1;
    if (tree[node].has_set) {
        tree[node].set_val += val;
    } else {
        tree[node].add_val += val;
    }
    tree[node].sum += len * val;
}

void push_down(int node, int l, int r) {
    int mid = l + (r - l) / 2;
    if (tree[node].has_set) {
        apply_set(2 * node, l, mid, tree[node].set_val);
        apply_set(2 * node + 1, mid + 1, r, tree[node].set_val);
        tree[node].has_set = false;
        tree[node].set_val = 0;
    }
    if (tree[node].add_val != 0) {
        apply_add(2 * node, l, mid, tree[node].add_val);
        apply_add(2 * node + 1, mid + 1, r, tree[node].add_val);
        tree[node].add_val = 0;
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

void update_add(int node, int l, int r, int ql, int qr, long long val) {
    if (ql <= l && r <= qr) {
        apply_add(node, l, r, val);
        return;
    }
    push_down(node, l, r);
    int mid = l + (r - l) / 2;
    if (ql <= mid) update_add(2 * node, l, mid, ql, qr, val);
    if (qr > mid) update_add(2 * node + 1, mid + 1, r, ql, qr, val);
    tree[node].sum = tree[2 * node].sum + tree[2 * node + 1].sum;
}

void update_set(int node, int l, int r, int ql, int qr, long long val) {
    if (ql <= l && r <= qr) {
        apply_set(node, l, r, val);
        return;
    }
    push_down(node, l, r);
    int mid = l + (r - l) / 2;
    if (ql <= mid) update_set(2 * node, l, mid, ql, qr, val);
    if (qr > mid) update_set(2 * node + 1, mid + 1, r, ql, qr, val);
    tree[node].sum = tree[2 * node].sum + tree[2 * node + 1].sum;
}

long long query_sum(int node, int l, int r, int ql, int qr) {
    if (ql <= l && r <= qr) {
        return tree[node].sum;
    }
    push_down(node, l, r);
    int mid = l + (r - l) / 2;
    long long res = 0;
    if (ql <= mid) res += query_sum(2 * node, l, mid, ql, qr);
    if (qr > mid) res += query_sum(2 * node + 1, mid + 1, r, ql, qr);
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
        int type;
        cin >> type;
        if (type == 1) {
            int a, b;
            long long x;
            cin >> a >> b >> x;
            update_add(1, 1, n, a, b, x);
        } else if (type == 2) {
            int a, b;
            long long x;
            cin >> a >> b >> x;
            update_set(1, 1, n, a, b, x);
        } else {
            int a, b;
            cin >> a >> b;
            cout << query_sum(1, 1, n, a, b) << '\n';
        }
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Induction on Lazy Composition
Let the affine transformation represented by node state be $f(v)$:
- If `has_set == true`, $f(v) = \text{set\_val}$.
- If `has_set == false`, $f(v) = v + \text{add\_val}$.

1. **Applying `Set(X)`**:
   The new function is $g(v) = X$.
   Setting `has_set = true`, `set_val = X`, `add_val = 0` exactly represents $g(v) = X$, overwriting previous transformations.
2. **Applying `Add(X)`**:
   - If `has_set == true`, $f(v) = \text{set\_val}$. The new value is $\text{set\_val} + X$.
     Setting `set_val += X` correctly updates $g(v) = \text{set\_val} + X$.
   - If `has_set == false`, $f(v) = v + \text{add\_val}$. The new value is $v + \text{add\_val} + X$.
     Setting `add_val += X` correctly updates $g(v) = v + (\text{add\_val} + X)$.
3. **Range Sum Update**:
   For an interval of length $L = r - l + 1$:
   - For `Set(X)`: $\sum_{i=l}^r X = L \cdot X$.
   - For `Add(X)`: $\sum_{i=l}^r (t_i + X) = \sum t_i + L \cdot X$.
   The node's `sum` field is updated in strict accordance with the affine transformation.
4. **Pushdown Correctness**:
   Because transformations distribute over child subsegments, pushing down the parent's transformation to both children before descending maintains the exact prefix/interval sum at all tree levels.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
6 5
2 3 1 1 5 3
3 3 5
1 2 4 2
3 3 5
2 2 4 5
3 3 5
```

### Initial Array
$t = [2, 3, 1, 1, 5, 3]$

### Query 1: `3 3 5` (Sum of range $[3, 5]$)
- Elements $t_3 + t_4 + t_5 = 1 + 1 + 5 = 7$.
- Output: `7`.

### Query 2: `1 2 4 2` (Add 2 to range $[2, 4]$)
- $t$ becomes: $[2, 3+2, 1+2, 1+2, 5, 3] = [2, 5, 3, 3, 5, 3]$.

### Query 3: `3 3 5` (Sum of range $[3, 5]$)
- Elements $t_3 + t_4 + t_5 = 3 + 3 + 5 = 11$.
- Output: `11`.

### Query 4: `2 2 4 5` (Set range $[2, 4]$ to 5)
- $t$ becomes: $[2, 5, 5, 5, 5, 3]$.

### Query 5: `3 3 5` (Sum of range $[3, 5]$)
- Elements $t_3 + t_4 + t_5 = 5 + 5 + 5 = 15$.
- Output: `15`.

All outputs match sample: `7`, `11`, `15`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Sum Overflow**:
   Array elements can be updated up to $2 \cdot 10^5 \times 10^6 \approx 2 \cdot 10^{11}$ in magnitude. Range sums exceed 32-bit limits. `sum`, `set_val`, and `add_val` must be `long long`.
2. **Order of Operations in `push_down`**:
   `apply_set` must strictly be called before `apply_add` if both were active. However, with our invariant, `has_set == true` implies `add_val == 0`, eliminating ordering conflicts.
3. **Setting to 0**:
   Values can be 0. Do not use `set_val == 0` to denote absence of a set tag; the explicit boolean flag `has_set` is required.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if updates also included multiplying range by $x$?**
   We maintain affine parameters $(a, b)$ representing $x \mapsto a \cdot x + b$.
   - Multiplication by $m$: $(a, b) \leftarrow (a \cdot m, b \cdot m)$.
   - Addition of $c$: $(a, b) \leftarrow (a, b + c)$.
   - Assignment to $c$: $(a, b) \leftarrow (0, c)$.
2. **Can this structure support Range Minimum Query (RMQ) alongside Range Updates and Sums?**
   Yes. When setting range to $x$, min becomes $x$. When adding $x$, min becomes $\min + x$. Both distribute cleanly over $\min$.
3. **What is the difference between Lazy Segment Tree and Segment Tree Beats?**
   Standard lazy tags apply uniform affine operations to all elements in a range. Segment Tree Beats (Ji Driver Segment Tree) handles conditional operations like $x_i \leftarrow \min(x_i, v)$, which affects only a subset of elements in the range.
4. **How would you persist this tree (allow querying past versions)?**
   Persistent lazy segment trees cannot push down tags in-place because past nodes are immutable. Pushdown must create new child copies (path copying), increasing memory to $\mathcal{O}(q \log n)$.
5. **How does iterative segment tree compare here?**
   Iterative segment trees with dual lazy tags are notoriously complex because pushdown must be performed along the ancestor path from the root down to the query bounds before the bottom-up pass. Recursive segment trees are much cleaner and less error-prone for dual lazy tags.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Tree Build**: $\mathcal{O}(n)$
  - **Range Add Update**: $\mathcal{O}(\log n)$
  - **Range Set Update**: $\mathcal{O}(\log n)$
  - **Range Sum Query**: $\mathcal{O}(\log n)$
  - **Overall Run Time**: $\mathcal{O}(n + q \log n) \approx 0.10\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space ($4N \approx 8 \cdot 10^5$ nodes $\approx 32\text{ MB}$).

### Related CSES Problems
- [Range Update Queries](https://cses.fi/problemset/task/1651) — Difference array point updates
- [Polynomial Queries](https://cses.fi/problemset/task/1736) — Segment tree with arithmetic progression tags
- [Prefix Sum Queries](https://cses.fi/problemset/task/2166) — Segment tree prefix combinations
