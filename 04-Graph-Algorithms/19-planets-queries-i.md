# Planets Queries I

- **Category**: Graph Algorithms
- **CSES Task ID**: `1750`
- **CSES Problem Link**: [Planets Queries I](https://cses.fi/problemset/task/1750)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are in a galaxy with $n$ planets numbered $1, 2, \dots, n$. Each planet has a single directed teleporter that transports you to another planet. Specifically, teleporter on planet $x$ sends you to planet $t_x$.

You are given $q$ queries. In each query, you start at planet $x$ and make exactly $k$ teleporter jumps. You need to determine which planet you will end up on.

### Input Format
- The first line contains two integers $n$ and $q$: the number of planets and queries.
- The second line contains $n$ integers $t_1, t_2, \dots, t_n$: the destination of the teleporter on each planet.
- The next $q$ lines each contain two integers $x$ and $k$: the starting planet and number of teleporter jumps.

### Output Format
- For each query, print the planet reached after $k$ jumps.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le t_x, x \le n$
- $1 \le k \le 10^9$

With $k \le 10^9$, binary lifting with $30$ powers of two ($2^{29} \approx 5.36 \cdot 10^8, 2^{30} \approx 1.07 \cdot 10^9$) answers each query in $\mathcal{O}(\log k)$ time, requiring $\approx 0.10\text{s}$ in total.

---

## 2. Intuition & Pattern Recognition

This is the standard **Binary Lifting on Successor / Functional Graphs**:
- A graph where every vertex has an out-degree of exactly $1$ is known as a **Functional Graph** (or **Successor Graph**).
- Simulating $k$ jumps step-by-step takes $\mathcal{O}(k)$ time, which for $k = 10^9$ and $q = 2 \cdot 10^5$ would require $\approx 2 \cdot 10^{14}$ operations $\implies$ TLE.
- **Binary Lifting / Successor Doubling Principle**:
  Any integer $k$ can be represented uniquely as a sum of powers of two (its binary representation):
  $$k = \sum_{j=0}^{29} b_j \cdot 2^j, \quad b_j \in \{0, 1\}$$
- We define a 2D table `up[node][j]`:
  $$\text{up}[u][j] = \text{the planet reached from planet } u \text{ after } 2^j \text{ jumps}$$
- Base case ($j = 0$):
  $$\text{up}[u][0] = t_u \quad (2^0 = 1 \text{ jump})$$
- Recurrence ($j > 0$):
  Jumping $2^j$ steps is equivalent to making two consecutive jumps of $2^{j-1}$ steps:
  $$\text{up}[u][j] = \text{up}\big[ \text{up}[u][j - 1] \big][j - 1]$$
- For any query $(x, k)$, we examine the binary bits of $k$. If the $j$-th bit is set, we jump $x \leftarrow \text{up}[x][j]$.

---

## 3. Approach 1 — Naive Simulation

Simulate $k$ steps one by one for each query: $x \leftarrow t_x$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot k) \approx 2 \cdot 10^5 \times 10^9 = 2 \cdot 10^{14}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Cycle Decomposition

Decompose the functional graph into trees rooted on disjoint cycles.
- For each query $(x, k)$, determine whether $x$ enters a cycle in $< k$ steps, then jump into the cycle and take $k' \pmod{\text{cycle\_len}}$ steps along the cycle.
- **Verdict**: Requires finding cycles, tree depths, and component IDs. While $\mathcal{O}(n)$ precomputation and $\mathcal{O}(1)$ query, it is far more complex to implement than Binary Lifting. Binary Lifting takes only 10 lines of precomputation and easily passes well under the time limit.

---

## 5. Approach 3 — Optimal CSES Solution (Binary Lifting)

1. Set $\text{MAX\_POW} = 30$ ($2^{29} \approx 5.37 \times 10^8 < 10^9 < 2^{30} \approx 1.07 \times 10^9$).
2. Initialize table `up[n + 1][30]`.
3. Read $t_1, \dots, t_n$ and set `up[i][0] = t[i]`.
4. Precompute doubling table:
   ```cpp
   for (int j = 1; j < 30; ++j) {
       for (int i = 1; i <= n; ++i) {
           up[i][j] = up[up[i][j - 1]][j - 1];
       }
   }
   ```
5. For each query $(x, k)$:
   ```cpp
   for (int j = 0; j < 30; ++j) {
       if ((k >> j) & 1) {
           x = up[x][j];
       }
   }
   cout << x << '\n';
   ```

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int MAX_POW = 30;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    vector<vector<int>> up(n + 1, vector<int>(MAX_POW));

    for (int i = 1; i <= n; ++i) {
        cin >> up[i][0];
    }

    // Binary lifting table precomputation
    for (int j = 1; j < MAX_POW; ++j) {
        for (int i = 1; i <= n; ++i) {
            up[i][j] = up[up[i][j - 1]][j - 1];
        }
    }

    while (q--) {
        int x;
        long long k;
        cin >> x >> k;

        for (int j = 0; j < MAX_POW; ++j) {
            if ((k >> j) & 1) {
                x = up[x][j];
            }
        }

        cout << x << '\n';
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**:
  - Precomputation: $\mathcal{O}(n \log (\max k)) = 2 \cdot 10^5 \times 30 = 6 \cdot 10^6$ operations $\approx 0.03\text{s}$.
  - Answering $q$ queries: $\mathcal{O}(q \log (\max k)) = 2 \cdot 10^5 \times 30 = 6 \cdot 10^6$ operations $\approx 0.05\text{s}$.
  - Total Time: $\approx 0.08\text{s}$ to $0.12\text{s}$.
- **Space Complexity**: $\mathcal{O}(n \log (\max k)) = 2 \cdot 10^5 \times 30 \times 4 \text{ bytes} \approx 24\text{ MB}$.

---

## 6. Correctness Proof

### Associativity of Function Composition
- Let $f: \{1, \dots, n\} \to \{1, \dots, n\}$ be the teleporter transition function $f(u) = t_u$.
- The planet reached after $k$ steps is the $k$-fold composition $f^k(x) = \underbrace{f(f(\dots f}_{k \text{ times}}(x)\dots))$.
- **Power-of-Two Invariant**:
  By induction on $j$:
  - Base case: $\text{up}[u][0] = f^1(u) = f^{2^0}(u)$.
  - Inductive step: Assume $\text{up}[u][j - 1] = f^{2^{j-1}}(u)$.
    Then:
    $$\text{up}[u][j] = \text{up}\big[ \text{up}[u][j-1] \big][j-1] = f^{2^{j-1}}\big( f^{2^{j-1}}(u) \big) = f^{2^{j-1} + 2^{j-1}}(u) = f^{2^j}(u)$$
- **Binary Expansion Composition**:
  Any integer $k \ge 1$ has a unique binary representation $k = \sum_{j=0}^{B-1} b_j 2^j$.
  Because function composition is associative:
  $$f^k = f^{\sum b_j 2^j} = \prod_{b_j = 1} f^{2^j}$$
  Applying each power-of-two jump corresponding to the set bits in $k$ computes $f^k(x)$ correctly. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, q = 1$:
- $t = [2, 1, 1, 4]$
- Query: $x = 3, k = 5$
  - Binary representation: $5 = 2^0 + 2^2$ (bits 0 and 2 are set).
- Precomputed table:
  - $j=0$ ($2^0=1$): `up[3][0] = 1`, `up[1][0] = 2`, `up[2][0] = 1`.
  - $j=1$ ($2^1=2$): `up[3][1] = up[1][0] = 2`, `up[1][1] = up[2][0] = 1`.
  - $j=2$ ($2^2=4$): `up[3][2] = up[2][1] = 2`, `up[1][2] = up[1][1] = 1`.
- Answering query:
  - Bit $0$ is set ($2^0 = 1$): $x \leftarrow \text{up}[3][0] = 1$.
  - Bit $1$ is 0: skip.
  - Bit $2$ is set ($2^2 = 4$): $x \leftarrow \text{up}[1][2] = 1$.
- Final answer: $1$.
- Trace: $3 \xrightarrow{1} 1 \xrightarrow{2} 2 \xrightarrow{3} 1 \xrightarrow{4} 2 \xrightarrow{5} 1$. Exact match!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Self-Loops**:
   If planet $u$ points to itself ($t_u = u$), $\text{up}[u][j] = u$ for all $j$. Binary lifting remains at $u$ correctly.
2. **Disconnected Cycles & Trees**:
   Every planet in a functional graph has exactly one outgoing edge. The function $f$ is total, meaning $\text{up}[u][j]$ is always well-defined and within $[1, n]$ for any power $j$.
3. **Memory Layout (Cache Efficiency)**:
   Notice the indexing `up[node][j]`: inside the query loop, `x` is updated jump-by-jump. Keeping the inner dimension as `j` or using flat 1D indexing `up[node * 30 + j]` is L1 cache friendly.
4. **$k = 10^9$ Maximum Bit**:
   $2^{29} = 536,870,912 < 10^9 < 2^{30} = 1,073,741,824$. Thus 30 levels ($j \in [0, 29]$) strictly covers all $k \le 10^9$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does this connect to Lowest Common Ancestor (LCA)?**
   Binary lifting is the exact same algorithmic technique used to find ancestors in trees for LCA queries in $\mathcal{O}(\log n)$ time.
2. **What if $k$ can be up to $10^{18}$?**
   Increase `MAX_POW` to 62 ($2^{60} > 10^{18}$). The table size grows from 30 to 62, and each query takes 60 iterations ($\approx 0.15\text{s}$).
3. **Can we achieve $\mathcal{O}(1)$ query time?**
   Yes, using cycle decomposition: find the trees and cycles in $\mathcal{O}(n)$, label tree depths and cycle offsets. Answering $k$ jumps requires checking if $k < \text{depth}$; if so, binary lift within tree; if not, cycle index is $(pos + k - \text{depth}) \pmod L$. For general queries, binary lifting is preferred for simplicity.
4. **How do we detect if two planets are in the same component?**
   Use Floyd's cycle-finding (tortoise and hare) or DFS to label each weakly connected component.
5. **What if edge weights are associated with each jump?**
   Maintain a parallel table `sum_weight[u][j]`: the total weight accumulated during $2^j$ steps: `sum_weight[u][j] = sum_weight[u][j-1] + sum_weight[up[u][j-1]][j-1]`.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Functional Graph, Binary Lifting, Successor Doubling, Fast I/O
- **Complexity Summary**:
  - Time: $\mathcal{O}((n + q) \log k)$
  - Space: $\mathcal{O}(n \log k)$
- **Related CSES Problems**:
  - [Planets Queries II](https://cses.fi/problemset/task/1160) — Finding distance between two planets in functional graph
  - [Planets Cycles](https://cses.fi/problemset/task/1751) — Number of steps before entering a cycle
  - [Company Queries I](https://cses.fi/problemset/task/1687) — Tree ancestor queries via binary lifting
