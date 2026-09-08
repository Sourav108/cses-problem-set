# Range Update Queries

- **Category**: Range Queries
- **CSES Task ID**: `1651`
- **CSES Problem Link**: [Range Update Queries](https://cses.fi/problemset/task/1651)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers and $q$ queries, your task is to process two types of operations efficiently:
1. `1 a b u`: **Add** value $u$ to every element in the range $[a, b]$ inclusive ($x_i \leftarrow x_i + u$ for all $a \le i \le b$).
2. `2 k`: **Query** the current value at position $k$.

Both array positions and query ranges are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the array size and number of queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the initial array values.
- The next $q$ lines each describe an operation in one of the two formats:
  - `1 a b u`
  - `2 k`

### Output Format
- For each type 2 query, print the value of the element on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le x_i, u \le 10^9$
- $1 \le a \le b \le n$
- $1 \le k \le n$

With values and updates up to $10^9$, values can reach $10^9 + 2 \cdot 10^5 \times 10^9 \approx 2 \cdot 10^{14}$, requiring 64-bit integers (`long long`). A Difference Array implemented via a Fenwick Tree executes each operation in $\mathcal{O}(\log n)$ time, finishing in $\approx 0.08\text{s}$.

---

## 2. Intuition & Pattern Recognition

This problem requires **Range Updates** and **Point Queries**:
- In a static array, range updates can be performed in $\mathcal{O}(1)$ time using a **Difference Array** $D$:
  $$D[i] = x_i - x_{i-1}$$
  Adding $u$ to the range $[a, b]$ modifies only two endpoints:
  $$D[a] \leftarrow D[a] + u, \quad D[b + 1] \leftarrow D[b + 1] - u$$
  The current value at any position $k$ is the prefix sum of the difference array:
  $$x_k = \sum_{i=1}^k D[i]$$
- **Dynamic Difference Array via Fenwick Tree (BIT)**:
  Instead of using full Segment Tree with Lazy Propagation, we maintain the difference array $D$ inside a **Fenwick Tree**:
  - **Range update $[a, b]$ with $+u$**:
    Two point additions in the Fenwick tree:
    `bit.add(a, u)` and `bit.add(b + 1, -u)`.
  - **Point query at $k$**:
    One prefix sum query in the Fenwick tree:
    $$x_k = \text{initial\_val}[k] + \text{bit.query}(k)$$
- Both operations run in strictly $\mathcal{O}(\log n)$ time with under 40 lines of code, completely bypassing lazy propagation tags and tree recursion.

---

## 3. Approach 1 — Naive Linear Range Update

For each type 1 query, loop from $a$ to $b$ and increment elements.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Segment Tree with Lazy Propagation

Build a Segment Tree of size $4n$ with lazy tags.
- **Complexity**: $\mathcal{O}(\log n)$ update, $\mathcal{O}(\log n)$ query.
- **Verdict**: Optimal, but lazy propagation has higher constant factors, larger memory ($4n$ vs $n$), and requires careful tag pushing. Difference array on a Fenwick tree (Approach 3) is twice as fast and far simpler.

---

## 5. Approach 3 — Optimal CSES Solution (Difference Fenwick Tree)

1. Store initial values in `initial[n + 1]`.
2. Maintain a Fenwick tree `bit` of size $n + 2$ storing changes to the difference array.
3. For query `1 a b u`:
   - `bit.add(a, u)`
   - `bit.add(b + 1, -u)`
4. For query `2 k`:
   - Print `initial[k] + bit.query(k)`.

```cpp
#include <iostream>
#include <vector>

using namespace std;

struct FenwickTree {
    int n;
    vector<long long> tree;

    FenwickTree(int n) : n(n), tree(n + 2, 0) {}

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
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    vector<long long> initial(n + 1);
    for (int i = 1; i <= n; ++i) {
        cin >> initial[i];
    }

    FenwickTree bit(n + 1);

    while (q--) {
        int type;
        cin >> type;

        if (type == 1) {
            int a, b;
            long long u;
            cin >> a >> b >> u;
            bit.add(a, u);
            bit.add(b + 1, -u);
        } else {
            int k;
            cin >> k;
            cout << initial[k] + bit.query(k) << '\n';
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**:
  - Range update: two Fenwick additions: $2 \times \mathcal{O}(\log n) = \mathcal{O}(\log n)$.
  - Point query: one Fenwick prefix sum: $\mathcal{O}(\log n)$.
  - Total Time: $\mathcal{O}(n + q \log n) \approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ for initial array and Fenwick tree ($\approx 3.2\text{ MB}$).

---

## 6. Correctness Proof

### Equivalence of Prefix Sum of Differences to Point Values
- **Definition**: Let $\Delta_t(i)$ denote the delta added to index $i$ in the difference array by update operations up to time $t$.
- **Update Effect**:
  An update `1 a b u` adds $+u$ at index $a$ and $-u$ at index $b + 1$.
  For any index $k \in \{1, \dots, n\}$:
  - If $k < a$: neither $a$ nor $b + 1$ is $\le k$. Total contribution to prefix sum $\sum_{i=1}^k \Delta(i)$ is $0$.
  - If $a \le k \le b$: index $a \le k$ is included, but $b + 1 > k$ is not. Total contribution is $+u$.
  - If $k > b$: both $a \le k$ and $b + 1 \le k$ are included. Total contribution is $+u + (-u) = 0$.
- **Linearity of Summation**:
  Since summation is linear, the sum of contributions over all independent updates satisfies:
  $$\sum_{i=1}^k \Delta(i) = \sum_{\text{updates } [a_j, b_j] \ni k} u_j$$
  Adding this net change to the original value $\text{initial}[k]$ produces the exact current value at position $k$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider array $[3, 2, 4, 5, 1]$ ($n = 5$):
- Initial: `initial = [0, 3, 2, 4, 5, 1]`. `bit` is all zeros.
- Operation 1: `1 2 4 1` (add 1 to $[2, 4]$):
  - `bit.add(2, 1)`, `bit.add(5, -1)` ($b+1 = 4+1 = 5$).
- Operation 2: `2 3` (query position 3):
  - `bit.query(3)`: indices $\le 3$ include $2$ (value $+1$), but not $5$. Prefix sum $= 1$.
  - Value: $\text{initial}[3] + \text{query}(3) = 4 + 1 = 5$.
- Operation 3: `2 1` (query position 1):
  - `bit.query(1)`: index $1 < 2 \implies 0$.
  - Value: $\text{initial}[1] + 0 = 3$.
- Operation 4: `1 1 5 2` (add 2 to $[1, 5]$):
  - `bit.add(1, 2)`, `bit.add(6, -2)`.
- Operation 5: `2 3` (query position 3):
  - `bit.query(3)` includes $+2$ from 1, $+1$ from 2 $\implies 3$.
  - Value: $\text{initial}[3] + 3 = 4 + 3 = 7$.
  - (Original 4, +1 from op 1, +2 from op 4 = 7). Exact match!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Upper Bound Offset $b + 1 = n + 1$**:
   When $b = n$, the update calls `bit.add(n + 1, -u)`. Allocate the Fenwick tree of size at least $n + 2$ so index $n + 1$ does not cause out-of-bounds access.
2. **64-bit Integer Overflow**:
   Accumulated updates can exceed $2^{31} - 1$. All values in the Fenwick tree, `initial`, delta, and output must be `long long`.
3. **Single Element Range ($a == b$)**:
   `bit.add(a, u)` and `bit.add(a + 1, -u)` correctly updates only element $a$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does this compare to Lazy Segment Trees?**
   A Lazy Segment Tree supports both range updates AND range sum queries in $\mathcal{O}(\log n)$. When only point queries are required, the Difference Fenwick Tree is strictly superior (less memory, faster, shorter code).
2. **Can Fenwick Trees support Range Updates AND Range Queries?**
   Yes! Using two Fenwick trees tracking $D[i]$ and $D[i] \times (i - 1)$ based on algebraic prefix rearrangement.
3. **How do you extend this to 2D Range Updates and Point Queries?**
   Use a 2D Fenwick Tree over the 2D difference array: updating rectangle $[x_1, y_1]$ to $[x_2, y_2]$ updates 4 points: $(x_1, y_1), (x_1, y_2+1), (x_2+1, y_1), (x_2+1, y_2+1)$.
4. **What if updates are multiplications instead of additions?**
   If updates are non-zero modulo a prime $P$, use modular inverses: multiply by $u$ at $a$, multiply by $u^{-1}$ at $b + 1$.
5. **How does this connect to Sweep-Line Algorithms?**
   A difference array is equivalent to a 1D sweep-line where events are placed at $a$ (enter interval) and $b + 1$ (exit interval).

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Range Queries, Difference Array, Fenwick Tree, Range Update, Point Query
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + q \log n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - [Dynamic Range Sum Queries](https://cses.fi/problemset/task/1648) — Point update and range sum
  - [Range Updates and Sums](https://cses.fi/problemset/task/1735) — Range update and range sum with Lazy Propagation
  - [Polynomial Queries](https://cses.fi/problemset/task/1736) — Arithmetic progression range updates
