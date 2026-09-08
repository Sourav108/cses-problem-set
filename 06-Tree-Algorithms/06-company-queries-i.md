# Company Queries I

- **Category**: Tree Algorithms
- **CSES Task ID**: `1687`
- **CSES Problem Link**: [Company Queries I](https://cses.fi/problemset/task/1687)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

A company has $n$ employees numbered $1, 2, \dots, n$, where employee 1 is the general director. Every employee $i \in [2, n]$ has a direct boss $e_i$.

You must process $q$ queries of the form:
- Given an employee $x$ and an integer $k$, who is employee $x$'s boss **$k$ levels higher up** in the corporate hierarchy? If no such boss exists (i.e., $k$ levels up exceeds the director), output `-1`.

### Input Format
- The first line contains two integers $n$ and $q$: the number of employees and queries.
- The second line contains $n - 1$ integers $e_2, e_3, \dots, e_n$: the direct boss of each employee from 2 to $n$.
- The next $q$ lines each contain two integers $x$ and $k$.

### Output Format
- For each query, print the employee ID of the $k$-th ancestor, or `-1` if no such ancestor exists.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le e_i \le n$
- $1 \le x \le n$
- $1 \le k \le n$

---

## 2. Intuition & Pattern Recognition

Tracing $k$ parent pointers one step at a time ($x \leftarrow \text{boss}[x]$) takes $\mathcal{O}(k) = \mathcal{O}(n)$ per query, resulting in $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations, which exceeds the 1.00s time limit.

### Binary Lifting (Doubling)
Because any positive integer $k$ can be uniquely expressed as a sum of powers of two:
$$k = \sum_{j=0}^{\lfloor \log_2 k \rfloor} b_j \cdot 2^j, \quad b_j \in \{0, 1\}$$
we can replace $k$ single-step transitions with at most $\approx \log_2 n$ power-of-two jumps!

### Dynamic Programming Formulation
Define:
$$\text{up}[u][j] = \text{the } 2^j\text{-th ancestor of employee } u$$
- **Base Case ($j = 0$, jump of $2^0 = 1$)**:
  $$\text{up}[u][0] = e_u \quad (e_1 = 0 \text{ representing no boss})$$
- **Recurrence Step ($j > 0$, jump of $2^j = 2^{j-1} + 2^{j-1}$)**:
  Jumping $2^j$ levels up is equivalent to jumping $2^{j-1}$ levels up, and from that ancestor, jumping another $2^{j-1}$ levels up:
  $$\text{up}[u][j] = \text{up}\big[\text{up}[u][j-1]\big][j-1]$$
  If $\text{up}[u][j-1] = 0$, then $\text{up}[u][j] = 0$.

### Query Answering in $\mathcal{O}(\log n)$
To find the $k$-th ancestor of $x$:
- Iterate $j$ from $0$ up to $\approx 18$:
  - If the $j$-th bit of $k$ is set ($k \mathbin{\&} (1 \ll j)$):
    $$x \leftarrow \text{up}[x][j]$$
    If at any point $x = 0$, terminate and return `-1`.
- If $x \ne 0$, return $x$.

---

## 3. Approach 1 — Naive Linear Parent Hopping

For each query $(x, k)$, run a `while` loop $k$ times: $x \leftarrow \text{boss}[x]$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot k) \approx \mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Heavy-Light Decomposition (HLD)

Decompose tree paths into heavy chains. Jump across chain heads to locate the $k$-th ancestor in $\mathcal{O}(\log n)$ time.
- **Time Complexity**: $\mathcal{O}(n)$ build, $\mathcal{O}(\log n)$ query.
- **Space Complexity**: $\mathcal{O}(n)$.
- **Trade-off**: While HLD uses only $\mathcal{O}(n)$ memory compared to $\mathcal{O}(n \log n)$ for binary lifting, Binary Lifting (Approach 3) is much simpler (under 20 lines) and well within the 512 MB memory limit.

---

## 5. Approach 3 — Optimal CSES Solution (Binary Lifting)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

static const int MAX_LOG = 19; // 2^18 = 262144 > 200000

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    vector<vector<int>> up(n + 1, vector<int>(MAX_LOG, 0));

    // Employee 1 is the director (boss is 0 / null)
    up[1][0] = 0;

    for (int i = 2; i <= n; ++i) {
        cin >> up[i][0];
    }

    // Precompute binary lifting table
    for (int j = 1; j < MAX_LOG; ++j) {
        for (int i = 1; i <= n; ++i) {
            int ancestor = up[i][j - 1];
            if (ancestor != 0) {
                up[i][j] = up[ancestor][j - 1];
            } else {
                up[i][j] = 0;
            }
        }
    }

    // Process queries
    while (q--) {
        int x, k;
        cin >> x >> k;

        for (int j = 0; j < MAX_LOG; ++j) {
            if (k & (1 << j)) {
                x = up[x][j];
                if (x == 0) break;
            }
        }

        cout << (x == 0 ? -1 : x) << '\n';
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Binary Representation Decomposition
Every non-negative integer $k$ has a unique binary representation:
$$k = \sum_{j \in B} 2^j, \quad \text{where } B = \{ j \mid (k \mathbin{\&} (1 \ll j)) \ne 0 \}$$
Let $f(u) = e_u$ be the parent mapping, with $f(0) = 0$.
The $k$-th ancestor is the $k$-fold composition $f^k(x)$.
Because function composition is associative:
$$f^k(x) = f^{\sum_{j \in B} 2^j}(x) = \bigcirc_{j \in B} f^{2^j}(x)$$
By the doubling recurrence:
$$\text{up}[u][j] = f^{2^j}(u) = f^{2^{j-1}}\big(f^{2^{j-1}}(u)\big) = \text{up}\big[\text{up}[u][j-1]\big][j-1]$$
Each power-of-two jump correctly applies $f^{2^j}$.
Applying these jumps in sequence computes $f^k(x)$ exactly in $|B| \le \lceil \log_2 n \rceil$ steps.
If the sequence of ancestors leaves the tree before completing all jumps, the sentinel value 0 propagates through all subsequent jumps, correctly identifying that $k$ exceeds the node's depth.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
1 1 3 3
4 1
4 2
4 3
```

Hierarchy:
- Boss of 2 is 1
- Boss of 3 is 1
- Boss of 4 is 3
- Boss of 5 is 3

```text
      1
    /   \
   2     3
       /   \
      4     5
```

### Binary Lifting Table (`up[u][j]`)
| Node $u$ | $j = 0$ ($2^0=1$) | $j = 1$ ($2^1=2$) | $j = 2$ ($2^2=4$) |
|:---:|:---:|:---:|:---:|
| 1 | 0 | 0 | 0 |
| 2 | 1 | 0 | 0 |
| 3 | 1 | 0 | 0 |
| 4 | 3 | $\text{up}[3][0] = 1$ | $\text{up}[1][1] = 0$ |
| 5 | 3 | $\text{up}[3][0] = 1$ | $\text{up}[1][1] = 0$ |

### Query 1: `4 1` ($x = 4, k = 1$)
- $k = 1 = (001)_2 \implies$ jump $j = 0$.
- $x = \text{up}[4][0] = 3$.
- Output: `3`.

### Query 2: `4 2` ($x = 4, k = 2$)
- $k = 2 = (010)_2 \implies$ jump $j = 1$.
- $x = \text{up}[4][1] = 1$.
- Output: `1`.

### Query 3: `4 3` ($x = 4, k = 3$)
- $k = 3 = (011)_2 \implies$ jump $j = 0$, then $j = 1$.
- Step 1 ($j = 0$): $x = \text{up}[4][0] = 3$.
- Step 2 ($j = 1$): $x = \text{up}[3][1] = 0$.
- $x = 0 \implies$ Sentinel reached.
- Output: `-1`.

Outputs: `3`, `1`, `-1` — matches ground truth.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Jumping from the Root ($x = 1, k \ge 1$)**:
   $\text{up}[1][0] = 0$. The first bit tested immediately sets $x = 0$ and returns `-1`.
2. **Jump Exceeding Depth ($k > \text{depth}[x]$)**:
   Sentinel 0 absorbs all further jumps ($\text{up}[0][j] = 0$), avoiding out-of-bounds array access.
3. **Memory Consumption**:
   Table size: $(2 \cdot 10^5 + 1) \times 19 \times 4\text{ B} \approx 15.2\text{ MB}$, well within the 512 MB limit.
4. **$k = 0$**:
   The problem specifies $1 \le k \le n$. If $k = 0$ were queried, no bits would be set, returning $x$ itself.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Can this be solved in $\mathcal{O}(1)$ query time?**
   Yes! Using the **Level Ancestor Problem (LAP)** algorithm: combining Euler Tour flattening, Macro-Micro tree decomposition (Ladder decomposition), and Long Path Decomposition allows $\mathcal{O}(1)$ query time after $\mathcal{O}(n)$ preprocessing.
2. **How does Company Queries I extend to find the Lowest Common Ancestor (LCA)?**
   This is CSES Company Queries II: first equalize depths using binary lifting jumps, then jump both nodes together as high as possible while their ancestors differ.
3. **What if the tree structure changes dynamically (edges added/cut)?**
   Binary lifting is static. Dynamic trees require **Link-Cut Trees** (Splay-tree based) to find $k$-th ancestors in $\mathcal{O}(\log n)$ amortized time.
4. **How would you answer $k$-th descendant queries?**
   $k$-th descendant is not unique (a node can have multiple descendants at depth $+k$). However, the first/any descendant at depth $d$ can be queried via Euler Tour entry intervals combined with depth buckets.
5. **How does this connect to binary lifting on functional graphs?**
   CSES *Planets Queries I* uses the exact same `up[u][j]` doubling structure on a general functional graph where every node has out-degree 1.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Preprocessing**: $\mathcal{O}(n \log n)$ — Filling the $n \times \log_2 n$ table.
  - **Per Query**: $\mathcal{O}(\log n)$ — At most $\approx 18$ bit tests.
  - **Overall Run Time**: $\mathcal{O}((n + q) \log n) \approx 0.07\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n \log n)$ auxiliary memory ($\approx 15\text{ MB}$).

### Related CSES Problems
- [Company Queries II](https://cses.fi/problemset/task/1688) — LCA via binary lifting
- [Distance Queries](https://cses.fi/problemset/task/1135) — Pairwise distances via LCA
- [Planets Queries I](https://cses.fi/problemset/task/1750) — Binary lifting on functional graphs
