# Static Range Minimum Queries

- **Category**: Range Queries
- **CSES Task ID**: `1647`
- **CSES Problem Link**: [Static Range Minimum Queries](https://cses.fi/problemset/task/1647)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers and $q$ queries, your task is to process each query efficiently. Each query is defined by a 1-indexed range $[a, b]$, and asks for the **minimum value** in the subarray from position $a$ to position $b$ inclusive:
$$\min_{i=a}^{b} x_i$$
The array is static (no updates occur).

### Input Format
- The first line contains two integers $n$ and $q$: the array size and number of queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the array values.
- The next $q$ lines each contain two integers $a$ and $b$: the range bounds.

### Output Format
- For each query, print the minimum value on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$
- $1 \le a \le b \le n$

With $n, q \le 2 \cdot 10^5$, Sparse Table precomputation takes $\mathcal{O}(n \log n) \approx 3.6 \cdot 10^6$ operations, answering each query in $\mathcal{O}(1)$ time in $\approx 0.08\text{s}$ total.

---

## 2. Intuition & Pattern Recognition

Unlike range sums (which have an invertible operation $-$), the $\min$ operation is **not invertible** (knowing $\min(A \cup B)$ and $\min(A)$ does not reveal $\min(B)$).
- However, the $\min$ operation has a crucial property: **Idempotence**:
  $$\min(x, x) = x$$
  For any two overlapping subsegments that together cover the range $[a, b]$:
  $$\min(S_1 \cup S_2) = \min(\min(S_1), \; \min(S_2))$$
- **The Sparse Table Data Structure**:
  We precompute the minimums of all intervals whose lengths are powers of two:
  $$\text{st}[k][i] = \min \text{ in range } [i, \; i + 2^k - 1]$$
  - Base Case ($k = 0$, length $2^0 = 1$):
    $$\text{st}[0][i] = x_i$$
  - Recurrence ($k > 0$, length $2^k$):
    An interval of length $2^k$ decomposes into two overlapping intervals of length $2^{k-1}$:
    $$\text{st}[k][i] = \min\big(\text{st}[k-1][i], \; \text{st}[k-1][i + 2^{k-1}]\big)$$
- **$\mathcal{O}(1)$ Range Minimum Query**:
  For any range $[a, b]$ of length $L = b - a + 1$:
  - Let $k = \lfloor \log_2 L \rfloor$ (the largest power of 2 such that $2^k \le L$).
  - Two intervals of length $2^k$ starting at $a$ and ending at $b$ completely cover $[a, b]$:
    $$I_1 = [a, \; a + 2^k - 1], \quad I_2 = [b - 2^k + 1, \; b]$$
  - Therefore:
    $$\min_{i=a}^{b} x_i = \min\big(\text{st}[k][a], \; \text{st}[k][b - 2^k + 1]\big)$$
  - This evaluates in strictly $\mathcal{O}(1)$ time with just two table lookups!

---

## 3. Approach 1 — Naive Linear Scan per Query

For each query, iterate from $a$ to $b$ and find the minimum.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Segment Tree

Build a segment tree over the array.
- **Time Complexity**: $\mathcal{O}(n)$ build, $\mathcal{O}(\log n)$ per query $\implies \mathcal{O}(n + q \log n) \approx 4 \cdot 10^6$ operations.
- **Verdict**: Correct and passes, but each query incurs recursive tree traversal and branches. Sparse Table (Approach 3) answers each query in strictly $\mathcal{O}(1)$ time with zero branching.

---

## 5. Approach 3 — Optimal CSES Solution (Sparse Table)

1. Precompute logs using GCC intrinsic `31 - __builtin_clz(L)` for instant $\lfloor \log_2 L \rfloor$ computation.
2. Allocate table `st[18][n + 1]`, since $2^{17} = 131072 < 2 \cdot 10^5 < 2^{18} = 262144$.
3. Populate `st[0][i] = x[i]` for $1 \le i \le n$.
4. Compute powers $k = 1 \dots 17$:
   $$\text{st}[k][i] = \min(\text{st}[k-1][i], \; \text{st}[k-1][i + (1 \ll (k - 1))])$$
5. For each query $(a, b)$:
   - $L = b - a + 1$
   - $k = 31 - \text{\_\_builtin\_clz}(L)$
   - $\text{ans} = \min(\text{st}[k][a], \; \text{st}[k][b - (1 \ll k) + 1])$

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const int MAX_K = 18;

int st[MAX_K][200005];

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    for (int i = 1; i <= n; ++i) {
        cin >> st[0][i];
    }

    // Precompute Sparse Table
    for (int k = 1; k < MAX_K; ++k) {
        int half = 1 << (k - 1);
        for (int i = 1; i + (1 << k) - 1 <= n; ++i) {
            st[k][i] = min(st[k - 1][i], st[k - 1][i + half]);
        }
    }

    while (q--) {
        int a, b;
        cin >> a >> b;

        int len = b - a + 1;
        int k = 31 - __builtin_clz(len); // Fast floor(log2(len))

        int ans = min(st[k][a], st[k][b - (1 << k) + 1]);
        cout << ans << '\n';
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**:
  - Precomputation: $\mathcal{O}(n \log n) = 2 \cdot 10^5 \times 18 \approx 3.6 \cdot 10^6$ operations $\approx 0.03\text{s}$.
  - Query: $\mathcal{O}(1)$ time per query $\implies \mathcal{O}(q) \approx 0.05\text{s}$.
  - Total Time: $\approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(n \log n) = 18 \times 200005 \times 4 \text{ bytes} \approx 14.4\text{ MB}$.

---

## 6. Correctness Proof

### Idempotence and Complete Interval Coverage
- **Theorem**: For any range $[a, b]$, the two intervals $I_1 = [a, a + 2^k - 1]$ and $I_2 = [b - 2^k + 1, b]$ with $k = \lfloor \log_2(b - a + 1) \rfloor$ cover $[a, b]$ completely: $I_1 \cup I_2 = [a, b]$.
- **Proof**:
  1. Let $L = b - a + 1$. By definition of $k = \lfloor \log_2 L \rfloor$:
     $$2^k \le L < 2^{k+1}$$
  2. Because $2^k \le L$, interval $I_1$ starts at $a$ and ends at $a + 2^k - 1 \le a + L - 1 = b$.
  3. Interval $I_2$ ends at $b$ and starts at $b - 2^k + 1 \ge b - L + 1 = a$.
  4. The union $I_1 \cup I_2$ covers $[a, b]$ without gaps if and only if the start of $I_2$ is $\le$ the end of $I_1 + 1$:
     $$b - 2^k + 1 \le a + 2^k$$
     $$\iff (b - a + 1) \le 2 \cdot 2^k = 2^{k+1}$$
     $$\iff L < 2^{k+1}$$
     which is precisely the definition of $k = \lfloor \log_2 L \rfloor$!
  5. By idempotence of $\min$:
     $$\min_{i=a}^{b} x_i = \min\left(\min_{i \in I_1} x_i, \; \min_{i \in I_2} x_i\right) = \min(\text{st}[k][a], \; \text{st}[k][b - 2^k + 1])$$
  6. Hence, the query result is exact for all possible intervals. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider array $x = [3, 2, 4, 5, 1, 1, 5, 3]$ ($n = 8$):
- $k = 0$ (len 1): `[3, 2, 4, 5, 1, 1, 5, 3]`
- $k = 1$ (len 2):
  - $\min(3, 2)=2, \min(2, 4)=2, \min(4, 5)=4, \min(5, 1)=1, \min(1, 1)=1, \min(1, 5)=1, \min(5, 3)=3$
- $k = 2$ (len 4):
  - $\min(x[1..4]) = 2, \min(x[2..5]) = 1, \min(x[3..6]) = 1, \min(x[4..7]) = 1, \min(x[5..8]) = 1$
- Query: $[a = 2, b = 4]$:
  - $L = 4 - 2 + 1 = 3$.
  - $k = \lfloor \log_2 3 \rfloor = 1$ ($2^1 = 2$).
  - $I_1 = [2, 3] \implies \text{st}[1][2] = \min(2, 4) = 2$.
  - $I_2 = [4 - 2 + 1, 4] = [3, 4] \implies \text{st}[1][3] = \min(4, 5) = 4$.
  - $\min(2, 4) = 2$. Subarray $[2, 4, 5]$ has min $2$. Correct!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Single-Element Query ($a == b$)**:
   $L = 1 \implies k = 0$. $\min(\text{st}[0][a], \text{st}[0][a]) = x_a$. Correct!
2. **Fast Log2 Computation**:
   Using `31 - __builtin_clz(len)` executes a single hardware instruction (`BSR` / `CLZ`), avoiding expensive `log2()` floating-point calls.
3. **Memory Layout (Cache Efficiency)**:
   Indexing as `st[k][i]` puts elements of the same power $k$ contiguously in memory. Since queries access different $i$ with fixed $k$, this achieves superior cache line utilization.
4. **No Integer Overflow**:
   Query returns element values directly $\le 10^9$, fitting within standard 32-bit signed `int`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Which other operations can be solved in $\mathcal{O}(1)$ with a Sparse Table?**
   Any idempotent associative operator: **Range Maximum Query (RMQ)**, **Range GCD**, **Range Bitwise AND**, and **Range Bitwise OR**.
2. **Can a Sparse Table handle dynamic point updates?**
   No. Updating an element in a Sparse Table requires updating $\mathcal{O}(n)$ entries across all levels $k > 0$, taking $\mathcal{O}(n)$. For dynamic updates, use a **Segment Tree** in $\mathcal{O}(\log n)$.
3. **How does RMQ connect to Lowest Common Ancestor (LCA)?**
   By constructing the Euler tour of a tree with node depths, the LCA of two nodes corresponds to the node with minimum depth in the tour interval between them. This reduces LCA to RMQ, solvable in $\mathcal{O}(1)$ query time (the Farach-Colton & Bender algorithm).
4. **What is the Fischer-Heun $\pm 1$ RMQ (Cartesian Tree RMQ)?**
   Achieves true $\mathcal{O}(n)$ precomputation and $\mathcal{O}(1)$ query time by blocking elements into blocks of size $\frac{1}{2} \log_2 n$ and precomputing canonical Cartesian tree types.
5. **How does Sparse Table compare to Disjoint Sparse Table?**
   A Disjoint Sparse Table supports non-idempotent operations (such as modular multiplication or matrix multiplication) in $\mathcal{O}(1)$ query time with $\mathcal{O}(n \log n)$ precomputation.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Range Queries, RMQ, Sparse Table, Idempotence, Binary Lifting, $\mathcal{O}(1)$ Query
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \log n)$ precomputation, $\mathcal{O}(1)$ query
  - Space: $\mathcal{O}(n \log n)$
- **Related CSES Problems**:
  - [Static Range Sum Queries](https://cses.fi/problemset/task/1646) — Static range sum via prefix sums
  - [Dynamic Range Minimum Queries](https://cses.fi/problemset/task/1649) — Dynamic RMQ via Segment Tree
  - [Company Queries II](https://cses.fi/problemset/task/1688) — LCA in tree via binary lifting
