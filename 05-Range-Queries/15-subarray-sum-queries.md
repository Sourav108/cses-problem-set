# Subarray Sum Queries

- **Category**: Range Queries
- **CSES Task ID**: `1190`
- **CSES Problem Link**: [Subarray Sum Queries](https://cses.fi/problemset/task/1190)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There is an array consisting of $n$ integers $x_1, x_2, \dots, x_n$. You must process $m$ updates.
In each update:
- The value at position $k$ becomes $x$ ($x_k \leftarrow x$).
- After each update, report the **maximum subarray sum** in the entire array.

An empty subarray (with sum $0$) is allowed, so the answer is always $\ge 0$.
Array indexing is 1-indexed.

### Input Format
- The first line contains two integers $n$ and $m$: the size of the array and the number of updates.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the initial array elements.
- The next $m$ lines describe the updates: each line has two integers $k$ and $x$.

### Output Format
- After each update, print the maximum subarray sum on a new line.

### Numerical Constraints
- $1 \le n, m \le 2 \cdot 10^5$
- $-10^9 \le x_i, x \le 10^9$
- $1 \le k \le n$

---

## 2. Intuition & Pattern Recognition

This is the dynamic version of Kadane's algorithm. In the static case, Kadane's algorithm computes the maximum subarray sum in $\mathcal{O}(n)$ time. Here, we must re-evaluate after each of $m$ point updates, requiring $\mathcal{O}(\log n)$ time per change.

### Segment Tree Node State
When combining two contiguous segments $L$ and $R$, a maximum sum subarray either:
1. Lies entirely within $L$ (giving $L.\text{ans}$).
2. Lies entirely within $R$ (giving $R.\text{ans}$).
3. Crosses the boundary between $L$ and $R$. The crossing subarray must consist of a suffix of $L$ combined with a prefix of $R$, giving $L.\text{suff} + R.\text{pref}$.

To compute these quantities recursively, each segment tree node must maintain four 64-bit values:
- `sum`: the total sum of the segment:
  $$\text{sum} = L.\text{sum} + R.\text{sum}$$
- `pref`: the maximum prefix sum of the segment ($\ge 0$):
  $$\text{pref} = \max(L.\text{pref}, \; L.\text{sum} + R.\text{pref})$$
- `suff`: the maximum suffix sum of the segment ($\ge 0$):
  $$\text{suff} = \max(R.\text{suff}, \; R.\text{sum} + L.\text{suff})$$
- `ans`: the maximum subarray sum in the segment ($\ge 0$):
  $$\text{ans} = \max\big(L.\text{ans}, \; R.\text{ans}, \; L.\text{suff} + R.\text{pref}\big)$$

### Leaf Base Case
For a leaf node representing a single value $v$:
- `sum = v`
- `pref = max(0LL, v)`
- `suff = max(0LL, v)`
- `ans = max(0LL, v)`

Because the entire array is queried after every update, the root of the segment tree (`tree[1].ans`) always contains the global answer! No range query traversal is needed—only point update and root inspection.

---

## 3. Approach 1 — Running Kadane's Algorithm per Update

Apply the update $x_k \leftarrow x$, then run standard linear Kadane's algorithm across $x_1, \dots, x_n$ in $\mathcal{O}(n)$ time.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(m \cdot n) \approx 2 \cdot 10^5 \times 2 \cdot 10^5 = 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Sqrt Decomposition (Block Kadane)

Divide the array into $\sqrt{n}$ blocks. Each block stores its internal Kadane result, prefix sums, suffix sums, and total sum. An update recalculates one block in $\mathcal{O}(\sqrt{n})$ time, and queries merge the $\sqrt{n}$ block states in $\mathcal{O}(\sqrt{n})$ time.
- Time per update: $\mathcal{O}(\sqrt{n})$.
- Total time: $\mathcal{O}(m \sqrt{n}) \approx 9 \cdot 10^7$ operations.
- Segment Tree (Approach 3) is strictly faster ($\mathcal{O}(\log n)$) and simpler to code.

---

## 5. Approach 3 — Optimal CSES Solution (Iterative Bottom-Up Segment Tree)

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

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    int size_pow = 1;
    while (size_pow <= n) size_pow <<= 1;

    vector<Node> tree(2 * size_pow);

    for (int i = 1; i <= n; ++i) {
        long long val;
        cin >> val;
        tree[size_pow + i - 1] = Node(val);
    }

    for (int i = size_pow - 1; i >= 1; --i) {
        tree[i] = merge(tree[2 * i], tree[2 * i + 1]);
    }

    while (m--) {
        int k;
        long long x;
        cin >> k >> x;

        int idx = size_pow + k - 1;
        tree[idx] = Node(x);
        idx /= 2;
        while (idx >= 1) {
            tree[idx] = merge(tree[2 * idx], tree[2 * idx + 1]);
            idx /= 2;
        }

        cout << tree[1].ans << '\n';
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Monoid and Associativity of Merge
To prove the correctness of the divide-and-conquer merge, we verify that `merge(Node l, Node r)` is strictly associative, meaning $(A \oplus B) \oplus C = A \oplus (B \oplus C)$.

1. **Total Sum**:
   $$(A.\text{sum} + B.\text{sum}) + C.\text{sum} = A.\text{sum} + (B.\text{sum} + C.\text{sum})$$
2. **Prefix Maximum**:
   $$\text{pref}(AB) = \max(A.\text{pref}, A.\text{sum} + B.\text{pref})$$
   Expanding for $ABC$:
   $$\max\big(\text{pref}(AB), \; (A.\text{sum} + B.\text{sum}) + C.\text{pref}\big) = \max\big(A.\text{pref}, \; A.\text{sum} + B.\text{pref}, \; A.\text{sum} + B.\text{sum} + C.\text{pref}\big)$$
   which is symmetric and independent of association.
3. **Suffix Maximum**:
   Analogously symmetric to prefix maximum.
4. **Maximum Subarray**:
   Any subarray of $A \cup B$ either:
   - Resides entirely in $A$: bounded by $A.\text{ans}$.
   - Resides entirely in $B$: bounded by $B.\text{ans}$.
   - Crosses the split: begins in $A$ and ends in $B$. Its sum is the sum of its $A$-part plus its $B$-part. Maximizing both independently yields $A.\text{suff} + B.\text{pref}$.
   Thus $\text{ans} = \max(A.\text{ans}, B.\text{ans}, A.\text{suff} + B.\text{pref})$ is complete and exact.

At each step, updating a leaf and bubbling up to the root computes the unique correct state for $[1, n]$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
1 2 -3 5 -1
2 6
3 1
2 -2
```

### Initial Array
$x = [1, 2, -3, 5, -1]$

### Update 1: `2 6` ($x_2 \leftarrow 6$)
- Array becomes: `[1, 6, -3, 5, -1]`
- Prefix sums: `[1, 7, 4, 9, 8]`
- Subarray `[1, 6, -3, 5]` has sum $1 + 6 - 3 + 5 = 9$.
- Output: `9`.

### Update 2: `3 1` ($x_3 \leftarrow 1$)
- Array becomes: `[1, 6, 1, 5, -1]`
- Subarray `[1, 6, 1, 5]` has sum $1 + 6 + 1 + 5 = 13$.
- Output: `13`.

### Update 3: `2 -2` ($x_2 \leftarrow -2$)
- Array becomes: `[1, -2, 1, 5, -1]`
- Best positive subarray is `[1, 5]` at indices 3..4, with sum $1 + 5 = 6$.
- Output: `6`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Required**:
   $n = 2 \cdot 10^5$ and $x_i = 10^9$. The maximum possible subarray sum is $2 \cdot 10^{14}$, which overflows 32-bit signed integer (`int`). All fields (`sum`, `pref`, `suff`, `ans`) must be `long long`.
2. **All Negative Elements**:
   If every element in the array is negative (e.g., $[-5, -2, -9]$), an empty subarray has sum 0. Since `ans = max(0LL, v)`, the segment tree correctly outputs `0`, as required by the problem statement.
3. **Power of Two Sizing**:
   The bottom-up segment tree requires $2^{\lceil \log_2 n \rceil + 1} \le 4 \cdot 10^5$ nodes. Initializing empty leaves beyond $n$ with default `Node(0)` guarantees correct boundary handling without branching.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if empty subarrays are not allowed (must pick at least one element)?**
   In that case, if all elements are negative, the answer is the single largest negative number.
   Change the base case to:
   - `pref = v`, `suff = v`, `ans = v` (no `max(0LL, v)`).
   - `merge`: `ans = max({l.ans, r.ans, l.suff + r.pref})`, `pref = max(l.pref, l.sum + r.pref)`.
2. **What if we also need to output the start and end indices of the optimal subarray?**
   Store index pairs `(l_idx, r_idx)` for `pref`, `suff`, and `ans` in each node.
3. **How does this structure handle range updates (adding $v$ to $[a, b]$)?**
   Range additions require lazy propagation. However, adding $v$ to all elements changes the maximum subarray non-trivially (it becomes a piecewise linear convex function over $v$), which requires Segment Tree Beats / Li Chao Trees in the general case.
4. **Can we answer range queries for maximum subarray sum in an arbitrary $[a, b]$?**
   Yes! This is precisely CSES Problem 3226 (Subarray Sum Queries II), where we query range $[a, b]$ by merging nodes visited during a top-down segment tree traversal.
5. **Can we maintain the maximum product subarray similarly?**
   Because signs flip negative numbers to positives, each node must maintain both the maximum and minimum prefix/suffix/subarray products.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Tree Build**: $\mathcal{O}(n)$
  - **Per Update**: $\mathcal{O}(\log n)$
  - **Query (Root Inspection)**: $\mathcal{O}(1)$
  - **Overall Run Time**: $\mathcal{O}(n + m \log n) \approx 0.08\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary memory for the iterative segment tree array.

### Related CSES Problems
- [Subarray Sum Queries II](https://cses.fi/problemset/task/3226) — Range query version of Kadane Segment Tree
- [Prefix Sum Queries](https://cses.fi/problemset/task/2166) — Segment tree prefix maximums
- [Maximum Subarray Sum](https://cses.fi/problemset/task/1643) — Static 1D Kadane's algorithm
