# Dynamic Range Sum Queries

- **Category**: Range Queries
- **CSES Task ID**: `1648`
- **CSES Problem Link**: [Dynamic Range Sum Queries](https://cses.fi/problemset/task/1648)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers and $q$ queries, your task is to process two types of operations efficiently:
1. `1 k u`: **Update** the value at position $k$ to $u$.
2. `2 a b`: **Query** the sum of values in the range $[a, b]$ inclusive ($\sum_{i=a}^b x_i$).

Both array positions and query ranges are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the array size and number of queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the initial array values.
- The next $q$ lines each describe an operation in one of the two formats:
  - `1 k u`
  - `2 a b`

### Output Format
- For each type 2 query, print the sum of values on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le x_i, u \le 10^9$
- $1 \le k \le n$
- $1 \le a \le b \le n$

With $n, q \le 2 \cdot 10^5$, a Fenwick Tree (Binary Indexed Tree) processes both point updates and prefix sum queries in $\mathcal{O}(\log n)$ time, finishing in $\approx 0.08\text{s}$.

---

## 2. Intuition & Pattern Recognition

Because array elements can change dynamically, a static prefix sum array would require $\mathcal{O}(n)$ time per update ($\mathcal{O}(q \cdot n) \implies$ TLE).
- **Binary Indexed Tree (Fenwick Tree)**:
  A Fenwick tree stores partial prefix sums in a single flat array `tree[n + 1]`.
  Each index $i$ is responsible for the range $(i - \text{lsb}(i), \; i]$, where $\text{lsb}(i) = i \ \& \ (-i)$ is the least significant set bit of $i$.
- **Prefix Sum in $\mathcal{O}(\log n)$**:
  By repeatedly subtracting the least significant bit ($i \leftarrow i - (i \ \& \ -i)$), we sum disjoint dyadic intervals covering $[1, i]$ in at most $\lfloor \log_2 n \rfloor$ steps.
- **Point Update in $\mathcal{O}(\log n)$**:
  To update value $x_k$ to $u$, calculate the change $\Delta = u - x_k$.
  By repeatedly adding the least significant bit ($i \leftarrow i + (i \ \& \ -i)$), we update all intervals containing index $k$ in $\mathcal{O}(\log n)$ steps.
- **Range Query via Prefix Differences**:
  $$\sum_{i=a}^{b} x_i = \text{query}(b) - \text{query}(a - 1)$$
- Fenwick Tree requires zero pointer overhead, takes $\mathcal{O}(n)$ memory, and is significantly faster than a Segment Tree due to simple bitwise operations and tight cache locality.

---

## 3. Approach 1 — Naive Array with Direct Sum / Update

Store elements in a standard array. Updates take $\mathcal{O}(1)$, but queries take $\mathcal{O}(n)$ linear scan.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Segment Tree

Build a Segment Tree of size $4n$.
- **Complexity**: $\mathcal{O}(n)$ build, $\mathcal{O}(\log n)$ update, $\mathcal{O}(\log n)$ query.
- **Verdict**: Fully optimal. However, a Fenwick Tree (Approach 3) has less code, $4\times$ less memory, and is roughly $2\times$ faster in practice due to flat iterative loop structure.

---

## 5. Approach 3 — Optimal CSES Solution (Fenwick Tree / BIT)

1. Maintain `arr[n + 1]` storing current values and `tree[n + 1]` for the BIT (both `long long`).
2. Point update helper `add(i, delta)`:
   ```cpp
   while (i <= n) {
       tree[i] += delta;
       i += i & -i;
   }
   ```
3. Prefix query helper `query(i)`:
   ```cpp
   long long sum = 0;
   while (i > 0) {
       sum += tree[i];
       i -= i & -i;
   }
   return sum;
   ```
4. Linear $\mathcal{O}(n)$ initialization:
   Populate `arr[i] = val` and `add(i, val)` for $1 \le i \le n$.
5. Query processing:
   - For `1 k u`:
     $\Delta = u - \text{arr}[k]$
     $\text{arr}[k] = u$
     `add(k, delta)`
   - For `2 a b`:
     Print `query(b) - query(a - 1)`

```cpp
#include <iostream>
#include <vector>

using namespace std;

struct FenwickTree {
    int n;
    vector<long long> tree;

    FenwickTree(int n) : n(n), tree(n + 1, 0) {}

    void add(int i, long long delta) {
        while (i <= n) {
            tree[i] += delta;
            i += i & -i;
        }
    }

    long long query(int i) {
        long long sum = 0;
        while (i > 0) {
            sum += tree[i];
            i -= i & -i;
        }
        return sum;
    }

    long long range_query(int l, int r) {
        return query(r) - query(l - 1);
    }
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    FenwickTree bit(n);
    vector<long long> arr(n + 1);

    for (int i = 1; i <= n; ++i) {
        cin >> arr[i];
        bit.add(i, arr[i]);
    }

    while (q--) {
        int type;
        cin >> type;

        if (type == 1) {
            int k;
            long long u;
            cin >> k >> u;
            long long delta = u - arr[k];
            arr[k] = u;
            bit.add(k, delta);
        } else {
            int a, b;
            cin >> a >> b;
            cout << bit.range_query(a, b) << '\n';
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**:
  - Build: $\mathcal{O}(n \log n)$ (or $\mathcal{O}(n)$ linear).
  - Update: $\mathcal{O}(\log n)$ per update.
  - Query: $\mathcal{O}(\log n)$ per query.
  - Total Time: $\mathcal{O}(n \log n + q \log n) \approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ for `tree` and `arr` arrays ($\approx 3.2\text{ MB}$).

---

## 6. Correctness Proof

### Dyadic Interval Partitioning in Fenwick Trees
- **Theorem**: For any positive integer $i$, the sequence of indices visited by $i \leftarrow i - (i \ \& \ -i)$ uniquely partitions the range $[1, i]$ into at most $\lfloor \log_2 i \rfloor + 1$ disjoint intervals $(p - \text{lsb}(p), p]$.
- **Proof**:
  1. Let the binary representation of $i$ be $\sum_{j=1}^m 2^{b_j}$ with $b_1 < b_2 < \dots < b_m$.
  2. $\text{lsb}(i) = 2^{b_1}$.
  3. The index $i$ stores the sum over $(i - 2^{b_1}, i]$.
  4. Subtracting $\text{lsb}(i)$ clears bit $b_1$, yielding $i' = i - 2^{b_1}$.
  5. By induction, continuing this process extracts intervals $(i' - 2^{b_2}, i']$, and so on, until $i = 0$.
  6. The union of these intervals is exactly $[1, i]$, and their intersection is pairwise empty.
  7. Summing the values stored at these indices yields the exact prefix sum $\sum_{j=1}^i x_j$.
- **Update Symmetry**:
  Adding $\Delta$ to all indices $p \ge k$ that include index $k$ in their interval $(p - \text{lsb}(p), p]$ updates exactly the sequence of ancestors generated by $k \leftarrow k + (k \ \& \ -k)$.
  Thus, every subsequent prefix query incorporating index $k$ reflects the updated value. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 5$:
- Initial array: $x = [3, 2, 4, 5, 1]$
- BIT structure:
  - `tree[1]` covers $(0, 1] \implies x[1] = 3$
  - `tree[2]` covers $(0, 2] \implies x[1] + x[2] = 5$
  - `tree[3]` covers $(2, 3] \implies x[3] = 4$
  - `tree[4]` covers $(0, 4] \implies \sum_{i=1}^4 x[i] = 14$
  - `tree[5]` covers $(4, 5] \implies x[5] = 1$
- Query `2 2 4`:
  - `query(4)`: $4 \to 0$: reads `tree[4] = 14`.
  - `query(1)`: $1 \to 0$: reads `tree[1] = 3`.
  - Result: $14 - 3 = 11$ ($2 + 4 + 5 = 11$).
- Update `1 3 2`:
  - Position $3$: old value $4$, new value $2 \implies \Delta = 2 - 4 = -2$.
  - Update chain: $3 \to 4 \implies$ `tree[3] -= 2`, `tree[4] -= 2`.
  - `arr[3] = 2`.
- Query `2 2 4`:
  - `query(4) = 12`, `query(1) = 3` $\implies 12 - 3 = 9$ ($2 + 2 + 5 = 9$). Correct!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow**:
   Array elements up to $10^9$ with $2 \cdot 10^5$ elements mean prefix sums can reach $2 \cdot 10^{14}$. `long long` for `tree`, `arr`, `delta`, and query sums is mandatory.
2. **Updating with Difference**:
   The problem specifies setting position $k$ to $u$, NOT adding $u$. You must compute $\Delta = u - \text{arr}[k]$ and update $\text{arr}[k] = u$.
3. **1-Based Indexing**:
   Fenwick trees rely on bitwise properties of non-zero integers ($i \ \& \ -i$). Indexing from 1 to $n$ is strictly required; passing index 0 creates an infinite loop.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How do you build a Fenwick Tree in $\mathcal{O}(n)$ instead of $\mathcal{O}(n \log n)$?**
   Populate `tree[i] += arr[i]`, and for each $i \in [1, n]$, add `tree[i]` directly to its parent `parent = i + (i & -i)` if `parent <= n`.
2. **Can a Fenwick Tree support Range Updates and Range Queries?**
   Yes, using two Fenwick trees maintaining $D_1[i]$ and $D_2[i] = D_1[i] \times (i - 1)$ based on the identity $\sum_{i=1}^k \sum_{j=1}^i d_j = (k + 1) \sum_{j=1}^k d_j - \sum_{j=1}^k (j \times d_j)$.
3. **How do you find the smallest index with prefix sum $\ge S$ (Binary Lifting on Fenwick Tree)?**
   Instead of binary searching in $\mathcal{O}(\log^2 n)$, binary lift directly on the powers of 2 in the Fenwick tree in $\mathcal{O}(\log n)$ time.
4. **Why cannot Fenwick Trees directly support Range Minimum Query (RMQ) with arbitrary updates?**
   Fenwick tree prefix extraction relies on the invertibility of subtraction ($A \cup B - A = B$). The $\min$ operator is not invertible, so deleting/reducing a minimum requires a Segment Tree.
5. **How does Fenwick Tree compare to Treap / Splay Tree?**
   Treaps and Splay Trees support range insertions and deletions in $\mathcal{O}(\log n)$ but have high pointer overhead. For static arrays with point updates, Fenwick Trees are vastly faster.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Range Queries, Fenwick Tree, Binary Indexed Tree, Point Update, Range Sum
- **Complexity Summary**:
  - Time: $\mathcal{O}((n + q) \log n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - [Static Range Sum Queries](https://cses.fi/problemset/task/1646) — Static prefix sums
  - [Dynamic Range Minimum Queries](https://cses.fi/problemset/task/1649) — Dynamic RMQ via Segment Tree
  - [Range Update Queries](https://cses.fi/problemset/task/1651) — Range updates and point queries
