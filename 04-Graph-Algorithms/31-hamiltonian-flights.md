# Hamiltonian Flights

- **Category**: Graph Algorithms
- **CSES Task ID**: `1690`
- **CSES Problem Link**: [Hamiltonian Flights](https://cses.fi/problemset/task/1690)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ cities and $m$ directed flight connections between them. You want to travel from **city 1** to **city $n$** visiting **every city exactly once**.

Your task is to calculate the **number of distinct valid routes** (directed Hamiltonian paths from city 1 to city $n$). Since the answer may be large, print it modulo $10^9 + 7$.

### Input Format
- The first line contains two integers $n$ and $m$: the number of cities and flights.
- The next $m$ lines each contain two integers $a$ and $b$: a directed flight from city $a$ to city $b$.

### Output Format
- Print one integer: the number of Hamiltonian flights modulo $10^9 + 7$.

### Numerical Constraints
- $2 \le n \le 20$
- $1 \le m \le n^2$
- $1 \le a, b \le n$

With $n \le 20$, $2^n = 1048576$. A bitmask dynamic programming approach (Held-Karp) runs in $\mathcal{O}(2^n \cdot n) \approx 2 \cdot 10^7$ operations, taking $\approx 0.15\text{s}$.

---

## 2. Intuition & Pattern Recognition

Finding a path that visits every vertex of a graph exactly once is the **Hamiltonian Path Problem** (NP-hard in general):
- Because $n \le 20$ is small, we can use **Bitmask Dynamic Programming** (the Held-Karp algorithm):
- **Bitmask State Representation**:
  - An integer `mask` $\in [0, 2^n - 1]$ represents the subset of cities visited so far.
  - The $i$-th bit of `mask` is 1 if city $i$ has been visited, and 0 otherwise.
  - Let $\text{dp}[\text{mask}][u]$ be the number of valid routes starting at city $0$ (city 1 in 1-based indexing), having visited the subset of cities represented by `mask`, and currently ending at city $u$.
- **Base Case**:
  Only city $0$ visited, ending at city $0$:
  $$\text{dp}[1 \ll 0][0] = 1, \quad \text{all other } \text{dp} = 0$$
- **Pruning Optimization (Crucial for $n = 20$)**:
  - The journey must **end** at city $n - 1$.
  - Therefore, if a `mask` contains city $n - 1$, but does NOT yet contain all other cities ($\text{mask} \ne (1 \ll n) - 1$), city $n - 1$ was visited prematurely!
  - We must prune these states: **never transition out of city $n - 1$ unless it is the final full mask**.
- **Transitions (Pull or Push)**:
  For each vertex $u$ currently in `mask`, and for each incoming edge $v \to u$:
  $$\text{dp}[\text{mask}][u] = \sum_{v \to u \in E, \; v \in (\text{mask} \setminus \{u\})} \text{dp}[\text{mask} \setminus \{u\}][v] \pmod{10^9 + 7}$$
- Final answer is $\text{dp}[(1 \ll n) - 1][n - 1]$.

---

## 3. Approach 1 — Naive Backtracking / DFS

Explore all $n!$ permutations of cities, verifying if consecutive cities have valid directed flights.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n!) \approx 20! \approx 2.43 \times 10^{18}$ operations.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Inclusion-Exclusion Principle

Count walks of length $n - 1$ using matrix powers and apply the principle of inclusion-exclusion across subsets of omitted vertices.
- **Time Complexity**: $\mathcal{O}(2^n \cdot n^3)$.
- **Verdict**: $\mathcal{O}(2^n \cdot n)$ Bitmask DP (Approach 3) is an order of magnitude faster and far simpler to write.

---

## 5. Approach 3 — Optimal CSES Solution (Pull-Based Bitmask DP)

1. Convert cities to 0-indexed: $0, 1, \dots, n-1$. Source is $0$, target is $n - 1$.
2. Precompute the incoming edges for each vertex: `in_adj[u]` stores all $v$ such that $v \to u \in E$.
3. Allocate 2D array `dp[1 << n][n]` initialized to 0.
4. Set $\text{dp}[1][0] = 1$.
5. Iterate `mask` from $1$ to $(1 \ll n) - 1$:
   - If bit 0 is not set (`!(mask & 1)`), continue (source 0 must be included).
   - If bit $n - 1$ is set and $\text{mask} \ne (1 \ll n) - 1$, continue (pruning: target cannot be visited prematurely).
   - For each city $u \in \{1, \dots, n-1\}$ such that the $u$-th bit of `mask` is 1:
     - Sum over all incoming edges $v \to u$:
       If the $v$-th bit is also in `mask`:
       $$\text{dp}[\text{mask}][u] = (\text{dp}[\text{mask}][u] + \text{dp}[\text{mask} \setminus \{u\}][v]) \pmod{10^9 + 7}$$
6. Output $\text{dp}[(1 \ll n) - 1][n - 1]$.

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int MOD = 1e9 + 7;

int dp[1 << 20][20];

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<vector<int>> in_adj(n);
    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        --u; --v;
        in_adj[v].push_back(u); // Directed edge u -> v
    }

    dp[1][0] = 1; // Base case: mask containing only city 0

    int full_mask = (1 << n) - 1;

    for (int mask = 1; mask <= full_mask; ++mask) {
        // Must contain start city 0
        if (!(mask & 1)) continue;

        // Pruning: if target city (n - 1) is visited before all cities are visited, skip
        if ((mask & (1 << (n - 1))) && mask != full_mask) continue;

        for (int u = 1; u < n; ++u) {
            if (!(mask & (1 << u))) continue;

            int prev_mask = mask ^ (1 << u);
            long long ways = 0;

            for (int v : in_adj[u]) {
                if (prev_mask & (1 << v)) {
                    ways += dp[prev_mask][v];
                }
            }

            dp[mask][u] = ways % MOD;
        }
    }

    cout << dp[full_mask][n - 1] << '\n';

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^n \cdot (n + m))$.
  - Number of masks: $2^n = 1048576$.
  - For each mask, we iterate over vertices $u$ and their incoming edges.
  - With the premature target pruning, masks with bit $n - 1$ set are bypassed, cutting the state space almost in half ($2^{n-1}$ active masks).
  - Total operations: $\approx 2^{19} \times 20 \approx 10^7$ operations $\approx 0.15\text{s}$.
- **Space Complexity**: $\mathcal{O}(2^n \cdot n \times 4 \text{ bytes}) \approx 1048576 \times 20 \times 4 \approx 80\text{ MB}$, well within the 512 MB limit.

---

## 6. Correctness Proof

### Induction on Mask Cardinality
- **Definition**: Let $\text{dp}[\text{mask}][u]$ be the number of directed Hamiltonian paths on the vertex subset $S(\text{mask})$ that start at $0$ and end at $u$.
- **Base Case ($|S| = 1$)**:
  The only 1-vertex path starting at $0$ is $(0)$, which ends at $0$. Thus $\text{dp}[1][0] = 1$, and all others are $0$.
- **Inductive Step**:
  Assume $\text{dp}[\text{prev\_mask}][v]$ is correct for all subsets of size $k - 1$.
  Consider a subset of size $k$ with mask $\text{mask}$, ending at $u \in S(\text{mask})$.
  Any path of length $k$ visiting $S(\text{mask})$ and ending at $u$ must have its penultimate vertex $v \in S(\text{mask}) \setminus \{u\}$ connected to $u$ via a directed edge $v \to u$.
  The prefix path of length $k - 1$ visits exactly the subset $S(\text{prev\_mask}) = S(\text{mask}) \setminus \{u\}$ and ends at $v$.
  Because paths with different penultimate vertices or distinct prefix trajectories are mutually exclusive, by the addition rule:
  $$\text{dp}[\text{mask}][u] = \sum_{v \in \text{in\_adj}[u], \; v \in S(\text{mask}) \setminus \{u\}} \text{dp}[\text{prev\_mask}][v]$$
  By induction on subset size $k = 1, 2, \dots, n$, the DP values are exact. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 6$:
- Cities: $0, 1, 2, 3$
- Edges: $0 \to 1, 0 \to 2, 1 \to 2, 1 \to 3, 2 \to 1, 2 \to 3$
- Masks:
  - `mask = 0b0001` (1): `dp[1][0] = 1`
  - `mask = 0b0011` (3, cities 0, 1):
    - $u = 1$: edge from $0 \to 1$. `dp[3][1] = dp[1][0] = 1`.
  - `mask = 0b0101` (5, cities 0, 2):
    - $u = 2$: edge from $0 \to 2$. `dp[5][2] = dp[1][0] = 1`.
  - `mask = 0b0111` (7, cities 0, 1, 2):
    - $u = 1$: edge from $2 \to 1$. `dp[7][1] = dp[5][2] = 1`.
    - $u = 2$: edge from $1 \to 2$. `dp[7][2] = dp[3][1] = 1`.
  - `mask = 0b1111` (15, all cities):
    - $u = 3$: incoming edges from 1 and 2.
    - `dp[15][3] = dp[7][1] + dp[7][2] = 1 + 1 = 2`.
- Output: `2`. (Paths: $0 \to 1 \to 2 \to 3$ and $0 \to 2 \to 1 \to 3$).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Premature Visit to Target $n - 1$**:
   If city $n - 1$ is visited before all cities are covered, it is not a valid route (a Hamiltonian path must finish at $n - 1$). Skipping masks that contain $n - 1$ when $\text{mask} \ne (1 \ll n) - 1$ prevents invalid extensions and halves the computation time.
2. **Multiple Parallel Flights**:
   Multiple flights between the same pair of cities $u \to v$ provide multiple distinct paths. Storing each edge in `in_adj[v]` correctly counts each parallel flight.
3. **Memory Limits & Cache Optimization**:
   Notice the 2D array order: `dp[1 << 20][20]`. In the inner loop, `mask` is fixed and $u$ iterates through $0 \dots 19$, ensuring contiguous memory access across cache lines.
4. **Modulo Addition**:
   Accumulate into a 64-bit `ways` integer and take `% MOD` once per vertex $u$ to reduce expensive modular division operations.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does this connect to the Travelling Salesperson Problem (TSP)?**
   TSP is the minimization counterpart of Held-Karp: $\text{dp}[\text{mask}][u] = \min_{v} (\text{dp}[\text{prev\_mask}][v] + \text{cost}(v, u))$.
2. **What if $n = 30$?**
   Bitmask DP takes $\mathcal{O}(2^n \cdot n)$, which is impossible for $n = 30$ ($2^{30} \approx 10^9$). For general graphs, Hamiltonian path remains intractable. For special graph classes (e.g. bounded treewidth or interval graphs), polynomial algorithms exist.
3. **Can we find the exact number of Hamiltonian paths in undirected graphs faster?**
   Using fast subset convolution or the **Bax–Franklin polynomial interpolation / determinants of adjacency matrices**, Hamiltonian paths can be computed in $\mathcal{O}^*(2^n)$ with $\mathcal{O}(\text{poly}(n))$ space.
4. **What is Dirac's Theorem for Hamiltonian Cycles?**
   If every vertex in an undirected graph with $n \ge 3$ vertices has degree $\ge n / 2$, the graph is guaranteed to contain a Hamiltonian cycle.
5. **How can we reconstruct one of the valid Hamiltonian paths?**
   Trace backwards from $\text{full\_mask}$ and $n - 1$: find any incoming neighbor $v$ such that $\text{dp}[\text{prev\_mask}][v] > 0$, set $\text{curr} = v, \text{mask} = \text{prev\_mask}$, and repeat until reaching $0$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Hamiltonian Path, Bitmask DP, Held-Karp, Permutations
- **Complexity Summary**:
  - Time: $\mathcal{O}(2^n \cdot (n + m))$
  - Space: $\mathcal{O}(2^n \cdot n)$
- **Related CSES Problems**:
  - [Game Routes](https://cses.fi/problemset/task/1681) — Path counting on a DAG
  - [Elevator Rides](https://cses.fi/problemset/task/1653) — Bitmask DP optimization
  - [Knight's Tour](https://cses.fi/problemset/task/1689) — Hamiltonian path on chessboard
