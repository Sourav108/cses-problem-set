# Static Range Sum Queries

- **Category**: Range Queries
- **CSES Task ID**: `1646`
- **CSES Problem Link**: [Static Range Sum Queries](https://cses.fi/problemset/task/1646)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers and $q$ queries, your task is to process the queries efficiently. Each query is defined by a 1-indexed range $[a, b]$, and asks for the **sum of values** in the subarray from position $a$ to position $b$ inclusive:
$$\sum_{i=a}^{b} x_i$$
The array is static (no updates occur).

### Input Format
- The first line contains two integers $n$ and $q$: the array size and number of queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the array values.
- The next $q$ lines each contain two integers $a$ and $b$: the range bounds.

### Output Format
- For each query, print the sum of values on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$
- $1 \le a \le b \le n$

With $n, q \le 2 \cdot 10^5$ and values up to $10^9$, range sums can reach $2 \cdot 10^5 \times 10^9 = 2 \cdot 10^{14}$ (requiring `long long`). Using a prefix sum array answers each query in $\mathcal{O}(1)$ time, taking $\approx 0.05\text{s}$ total.

---

## 2. Intuition & Pattern Recognition

This is the canonical **1D Prefix Sum** problem:
- Computing the sum of a subarray naively by iterating from $a$ to $b$ requires $\mathcal{O}(b - a + 1) = \mathcal{O}(n)$ time per query, totaling $\mathcal{O}(n \cdot q) \approx 4 \cdot 10^{10}$ operations (TLE).
- **Prefix Sum Decomposition**:
  Define a 1-indexed prefix sum array $\text{pref}$ of length $n + 1$, where $\text{pref}[i]$ stores the sum of the first $i$ elements:
  $$\text{pref}[0] = 0$$
  $$\text{pref}[i] = \text{pref}[i - 1] + x_i \quad (1 \le i \le n)$$
- Any arbitrary range sum can be expressed as the difference of two prefix sums:
  $$\sum_{i=a}^{b} x_i = \left(\sum_{i=1}^{b} x_i\right) - \left(\sum_{i=1}^{a-1} x_i\right) = \text{pref}[b] - \text{pref}[a - 1]$$
- Precomputation requires a single linear scan $\mathcal{O}(n)$, after which every query is evaluated in strictly $\mathcal{O}(1)$ time.

---

## 3. Approach 1 — Naive Linear Scan per Query

Iterate from $a$ to $b$ and sum values directly.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Segment Tree / Fenwick Tree

Maintain array in a Segment Tree or Fenwick Tree, querying range $[a, b]$ in $\mathcal{O}(\log n)$.
- **Complexity**: $\mathcal{O}(n + q \log n) \approx 4 \cdot 10^6$ operations.
- **Verdict**: Correct and passes, but unnecessary overhead. Since the array is completely static, Prefix Sums (Approach 3) achieve $\mathcal{O}(1)$ query time with zero tree overhead.

---

## 5. Approach 3 — Optimal CSES Solution (Prefix Sum Array)

1. Read $n$ and $q$.
2. Maintain array `pref[n + 1]` of type `long long` with `pref[0] = 0`.
3. For $i = 1 \dots n$:
   $$\text{pref}[i] = \text{pref}[i - 1] + x_i$$
4. For each query $(a, b)$:
   $$\text{cout} \ll (\text{pref}[b] - \text{pref}[a - 1]) \ll '\backslash n'$$

```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    vector<long long> pref(n + 1, 0);
    for (int i = 1; i <= n; ++i) {
        long long val;
        cin >> val;
        pref[i] = pref[i - 1] + val;
    }

    while (q--) {
        int a, b;
        cin >> a >> b;
        cout << pref[b] - pref[a - 1] << '\n';
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**:
  - Precomputation: $\mathcal{O}(n)$ to compute prefix sums.
  - Query: $\mathcal{O}(1)$ per query $\implies \mathcal{O}(q)$ for all queries.
  - Total Time: $\mathcal{O}(n + q) \approx 0.05\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ to store the `pref` array ($\approx 1.6\text{ MB}$).

---

## 6. Correctness Proof

### Mathematical Induction on Prefix Sums
- **Claim**: For all $k \in \{0, 1, \dots, n\}$, $\text{pref}[k] = \sum_{i=1}^k x_i$ (with empty sum $= 0$).
- **Proof**:
  - Base case: $\text{pref}[0] = 0$, which matches the empty sum.
  - Inductive step: Assume $\text{pref}[k - 1] = \sum_{i=1}^{k-1} x_i$.
    By definition: $\text{pref}[k] = \text{pref}[k - 1] + x_k = \left(\sum_{i=1}^{k-1} x_i\right) + x_k = \sum_{i=1}^k x_i$.
- **Range Query Evaluation**:
  $$\text{pref}[b] - \text{pref}[a - 1] = \sum_{i=1}^b x_i - \sum_{i=1}^{a-1} x_i = \sum_{i=a}^b x_i$$
  Because addition and subtraction over integers form an abelian group, the cancellation is exact. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider array $x = [3, 2, 4, 5, 1, 1, 5, 3]$ ($n = 8$):
- Prefix array:
  $$\text{pref} = [0, 3, 5, 9, 14, 15, 16, 21, 24]$$
- Query $1$: $[a = 2, b = 4]$:
  $$\text{pref}[4] - \text{pref}[1] = 14 - 3 = 11$$
  Elements: $x[2] + x[3] + x[4] = 2 + 4 + 5 = 11$. Correct!
- Query $2$: $[a = 5, b = 6]$:
  $$\text{pref}[6] - \text{pref}[4] = 16 - 14 = 2$$
  Elements: $1 + 1 = 2$. Correct!
- Query $3$: $[a = 1, b = 8]$:
  $$\text{pref}[8] - \text{pref}[0] = 24 - 0 = 24$. Correct!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow**:
   With $n = 2 \cdot 10^5$ and $x_i = 10^9$, total sum is $2 \cdot 10^{14} > 2^{31} - 1$. Storing `pref` values as `long long` is strictly required.
2. **1-Indexed Boundaries ($a = 1$)**:
   When $a = 1$, the formula requires $\text{pref}[a - 1] = \text{pref}[0] = 0$. Allocating `pref` with size $n + 1$ and indexing from $1$ avoids special-casing $a = 1$.
3. **Single Element Query ($a == b$)**:
   $\text{pref}[a] - \text{pref}[a - 1] = x_a$, correctly returning the single element.
4. **Fast I/O**:
   With $2 \cdot 10^5$ outputs, use `\n` instead of `endl` to prevent stream flushing timeouts.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How do prefix sums generalize to 2D matrices?**
   2D prefix sums: $\text{pref}[r][c] = \text{pref}[r-1][c] + \text{pref}[r][c-1] - \text{pref}[r-1][c-1] + \text{grid}[r][c]$. A 2D subgrid sum $[r_1, c_1]$ to $[r_2, c_2]$ is computed in $\mathcal{O}(1)$ via 4 terms (see CSES Forest Queries).
2. **What if the array elements can be updated dynamically?**
   Prefix sums degrade to $\mathcal{O}(n)$ per update. Use a **Binary Indexed Tree (Fenwick Tree)** or **Segment Tree** to support both updates and range sum queries in $\mathcal{O}(\log n)$ (see CSES Dynamic Range Sum Queries).
3. **Can prefix sums compute products?**
   Yes, if operations are modulo a prime $P$ and elements are non-zero, using modular inverses: $\text{prod}(a, b) = \text{pref\_prod}[b] \times (\text{pref\_prod}[a-1])^{-1} \pmod P$.
4. **How do difference arrays connect to prefix sums?**
   Difference arrays are the inverse of prefix sums. Adding $v$ to range $[l, r]$ updates $D[l] \mathrel{+}= v$ and $D[r+1] \mathrel{-}= v$ in $\mathcal{O}(1)$. Taking the prefix sum of $D$ reconstructs the modified array in $\mathcal{O}(n)$.
5. **Can prefix sums be used with XOR?**
   Yes! Because $x \oplus x = 0$, XOR has its own inverse ($A^{-1} = A$). Range XOR is simply $\text{pref\_xor}[b] \oplus \text{pref\_xor}[a-1]$ (see CSES Range Xor Queries).

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Range Queries, Prefix Sums, Static Arrays, $\mathcal{O}(1)$ Query, Fast I/O
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + q)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - [Static Range Minimum Queries](https://cses.fi/problemset/task/1647) — Static RMQ via Sparse Table
  - [Dynamic Range Sum Queries](https://cses.fi/problemset/task/1648) — Dynamic range sum with Fenwick Tree
  - [Forest Queries](https://cses.fi/problemset/task/1652) — 2D prefix sums
