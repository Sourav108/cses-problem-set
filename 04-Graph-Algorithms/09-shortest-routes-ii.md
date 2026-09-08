# Shortest Routes II

- **Category**: Graph Algorithms
- **CSES Task ID**: `1672`
- **CSES Problem Link**: [Shortest Routes II](https://cses.fi/problemset/task/1672)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ cities and $m$ bidirectional roads between them. Each road connects city $a$ and city $b$ with length $c$. You are given $q$ queries: each query asks for the length of the shortest path between two cities $a$ and $b$. If there is no route between them, output $-1$.

### Input Format
- The first line contains three integers $n$, $m$, and $q$: the number of cities, roads, and queries.
- The next $m$ lines each contain three integers $a$, $b$, and $c$: an undirected road connecting $a$ and $b$ with length $c$.
- The next $q$ lines each contain two integers $a$ and $b$: a query asking for the shortest distance between $a$ and $b$.

### Output Format
- For each query, print the minimum distance between city $a$ and city $b$, or $-1$ if no path exists.

### Numerical Constraints
- $1 \le n \le 500$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le q \le 10^5$
- $1 \le a, b \le n$
- $1 \le c \le 10^9$

With $n \le 500$, an $\mathcal{O}(n^3)$ algorithm executes $\approx 1.25 \cdot 10^8$ basic operations, which runs well within the 1.00s limit when loop-optimized.

---

## 2. Intuition & Pattern Recognition

This is the standard **All-Pairs Shortest Paths (APSP)** problem:
- We have $q \le 10^5$ queries, so we cannot afford to run a full search per query during online answering. We must precompute all-pairs shortest paths.
- With $n \le 500$, the **Floyd-Warshall Algorithm** is the classic choice:
  - Let $D^{(k)}[i][j]$ denote the shortest path distance from vertex $i$ to vertex $j$ using only intermediate vertices from the set $\{1, 2, \dots, k\}$.
  - The dynamic programming transition is:
    $$D^{(k)}[i][j] = \min\left( D^{(k-1)}[i][j], \; D^{(k-1)}[i][k] + D^{(k-1)}[k][j] \right)$$
  - Because state $k$ depends only on state $k-1$ and values $D[i][k]$ and $D[k][j]$ do not change during phase $k$, the space can be compressed in-place into a single 2D array $D[n+1][n+1]$.
- After running Floyd-Warshall in $\mathcal{O}(n^3)$, each query is answered in $\mathcal{O}(1)$ time.

---

## 3. Approach 1 — Running Dijkstra per Query ($q$ times)

Run Dijkstra's algorithm online for each query on demand.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot (n + m) \log n) \approx 10^5 \times 2 \cdot 10^5 \log 500 \approx 1.8 \cdot 10^{11}$ operations.
- **Space Complexity**: $\mathcal{O}(n + m)$.
- **CSES Verdict**: TLE (Time Limit Exceeded).

---

## 4. Approach 2 — All-Pairs Dijkstra ($n$ times SSSP)

Since all edge weights are positive, run Dijkstra from each of the $n$ vertices once, storing the all-pairs distances in an $n \times n$ matrix.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot (m \log n + n \log n))$.
  For dense graphs where $m = 2 \cdot 10^5$ and $n = 500$, $500 \times 2 \cdot 10^5 \log 500 \approx 9 \cdot 10^8$ operations with heap overhead.
- **Verdict**: Floyd-Warshall has no heap overhead, is cache-friendly, vectorizes trivially, and has smaller constant factors.

---

## 5. Approach 3 — Optimal CSES Solution (Floyd-Warshall in $\mathcal{O}(n^3)$)

1. Initialize a 2D array `dist[n+1][n+1]` with $\text{INF} = 10^{18}$. Set `dist[i][i] = 0` for all $1 \le i \le n$.
2. For each input edge $(a, b, c)$:
   - Multiple roads may connect $a$ and $b$. Always keep the minimum:
     $$\text{dist}[a][b] = \text{dist}[b][a] = \min(\text{dist}[a][b], c)$$
3. Execute the 3 nested loops ($k$ outermost, then $i$, then $j$):
   - **Cache Optimization**: Check `if (dist[i][k] == INF) continue;` in the middle loop. This avoids inner loop iterations when no path exists from $i$ to intermediate node $k$.
4. For each of the $q$ queries $(a, b)$:
   - If $\text{dist}[a][b] == \text{INF}$, output `-1`.
   - Otherwise, output $\text{dist}[a][b]$.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const long long INF = 1e18;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m, q;
    if (!(cin >> n >> m >> q)) return 0;

    vector<vector<long long>> dist(n + 1, vector<long long>(n + 1, INF));

    for (int i = 1; i <= n; ++i) {
        dist[i][i] = 0;
    }

    for (int i = 0; i < m; ++i) {
        int u, v;
        long long w;
        cin >> u >> v >> w;
        if (w < dist[u][v]) {
            dist[u][v] = w;
            dist[v][u] = w;
        }
    }

    // Floyd-Warshall: k must be the outermost loop!
    for (int k = 1; k <= n; ++k) {
        for (int i = 1; i <= n; ++i) {
            if (dist[i][k] == INF) continue;
            for (int j = 1; j <= n; ++j) {
                if (dist[k][j] < INF) {
                    dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j]);
                }
            }
        }
    }

    for (int i = 0; i < q; ++i) {
        int a, b;
        cin >> a >> b;
        if (dist[a][b] >= INF) {
            cout << -1 << '\n';
        } else {
            cout << dist[a][b] << '\n';
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^3 + q)$.
  - Precomputation: $500^3 = 1.25 \cdot 10^8$ operations $\approx 0.12\text{s}$.
  - Answering $10^5$ queries: $\mathcal{O}(q) \approx 0.03\text{s}$.
- **Space Complexity**: $\mathcal{O}(n^2)$ to store the $500 \times 500$ distance matrix ($\approx 2\text{ MB}$).

---

## 6. Correctness Proof

### Mathematical Induction on Intermediate Node Set
- **Theorem**: After iteration $k$, $\text{dist}[i][j]$ stores the weight of the shortest path from $i$ to $j$ whose intermediate vertices are restricted to the set $\{1, 2, \dots, k\}$.
- **Base Case ($k = 0$)**:
  Before the loop starts, intermediate vertices are empty. The shortest path using no intermediate vertices is simply the direct edge $(i, j)$ if it exists, or $0$ if $i = j$, and $\infty$ otherwise. This matches the initialization.
- **Inductive Step**:
  Assume the theorem holds for $k - 1$. Consider iteration $k$.
  Let $P$ be a shortest path from $i$ to $j$ with intermediate vertices in $\{1, \dots, k\}$.
  - **Case 1: Path $P$ does not use vertex $k$ as an intermediate vertex.**
    Then all intermediate vertices are in $\{1, \dots, k-1\}$. By induction, its weight is already given by $\text{dist}^{(k-1)}[i][j]$.
  - **Case 2: Path $P$ uses vertex $k$ as an intermediate vertex.**
    Since all edge weights are non-negative, any shortest path is simple (contains no cycles), so vertex $k$ is visited at most once.
    We can decompose $P$ into $i \xrightarrow{P_1} k \xrightarrow{P_2} j$.
    Both subpaths $P_1$ and $P_2$ have intermediate vertices strictly in $\{1, \dots, k-1\}$.
    By the inductive hypothesis, the shortest such subpaths have lengths $\text{dist}^{(k-1)}[i][k]$ and $\text{dist}^{(k-1)}[k][j]$ respectively.
    The sum $\text{dist}^{(k-1)}[i][k] + \text{dist}^{(k-1)}[k][j]$ exactly equals the minimum cost when routing through $k$.
  Taking the minimum over both cases yields the exact shortest distance:
  $$\text{dist}^{(k)}[i][j] = \min(\text{dist}^{(k-1)}[i][j], \text{dist}^{(k-1)}[i][k] + \text{dist}^{(k-1)}[k][j])$$
  By induction, after $k = n$, all intermediate vertices $\{1, \dots, n\}$ are allowed, yielding the global shortest paths. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 3$:
- Roads: $(1, 2, 5)$, $(2, 3, 7)$, $(3, 4, 2)$
- Initial matrix ($i \to j$):
  ```
     1   2   3   4
  1 [0,  5,  ∞,  ∞]
  2 [5,  0,  7,  ∞]
  3 [∞,  7,  0,  2]
  4 [∞,  ∞,  2,  0]
  ```
- **$k = 1$**: relaxes paths via city 1. (No new routes improved).
- **$k = 2$**: relaxes paths via city 2.
  - $\text{dist}[1][3] = \min(\infty, \text{dist}[1][2] + \text{dist}[2][3]) = 5 + 7 = 12$.
  - Matrix updated: $\text{dist}[1][3] = \text{dist}[3][1] = 12$.
- **$k = 3$**: relaxes paths via city 3.
  - $\text{dist}[1][4] = \min(\infty, \text{dist}[1][3] + \text{dist}[3][4]) = 12 + 2 = 14$.
  - $\text{dist}[2][4] = \min(\infty, \text{dist}[2][3] + \text{dist}[3][4]) = 7 + 2 = 9$.
- **$k = 4$**: relaxes paths via city 4. (No new shorter paths).
- Final distance $\text{dist}[1][4] = 14$, $\text{dist}[1][3] = 12$, $\text{dist}[2][4] = 9$.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Parallel Roads (Multi-Edges)**:
   There may be multiple roads between the same two cities $u$ and $v$. Simply writing `dist[u][v] = w` will overwrite earlier cheaper roads if a later road has higher weight. You **must** take `dist[u][v] = min(dist[u][v], w)`.
2. **64-bit Integer Overflow**:
   Path weights can reach $500 \times 10^9 = 5 \cdot 10^{11}$, which exceeds 32-bit signed integer limits ($2 \cdot 10^9$). `long long` is mandatory.
   Furthermore, choose $\text{INF} = 10^{18}$ so that $\text{dist}[i][k] + \text{dist}[k][j]$ does not exceed $2 \cdot 10^{18}$, staying safely within the `long long` maximum ($\approx 9.22 \times 10^{18}$).
3. **Loop Ordering**:
   The loop over intermediate vertices $k$ **must** be the outermost loop. Placing $k$ as the innermost loop will result in wrong answers because earlier pairs will not have access to higher-indexed intermediate paths.
4. **Self-Queries**:
   If query asks for distance between $a$ and $a$, output is $0$. Setting `dist[i][i] = 0` correctly satisfies this.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Why must $k$ be the outermost loop in Floyd-Warshall?**
   Floyd-Warshall is a dynamic programming algorithm indexed by $k$ (the subset of allowed intermediate vertices). For step $k$ to have correct inputs, all pairs $(i, j)$ at step $k-1$ must already be computed.
2. **Can Floyd-Warshall detect negative weight cycles?**
   Yes. If after running Floyd-Warshall any diagonal element satisfies $\text{dist}[i][i] < 0$, a negative weight cycle exists through vertex $i$.
3. **How does Floyd-Warshall compare to Johnson's Algorithm for APSP?**
   Johnson's algorithm uses Bellman-Ford once to reweight edges to be non-negative, then runs Dijkstra $V$ times. Johnson's complexity is $\mathcal{O}(V^2 \log V + VE)$, which is faster on sparse graphs ($E \ll V^2$). For $V \le 500$, Floyd-Warshall's simplicity and cache efficiency make it preferable.
4. **How do we reconstruct the shortest path between $u$ and $v$?**
   Maintain a `next_node[i][j]` table: initially `next_node[i][j] = j`. Whenever $\text{dist}[i][k] + \text{dist}[k][j] < \text{dist}[i][j]$, update $\text{next_node}[i][j] = \text{next_node}[i][k]$. Then walk from $u$ to $v$.
5. **How can Floyd-Warshall be parallelized or accelerated?**
   By blocking matrix tiles (Blocked Floyd-Warshall) into $B \times B$ blocks matching CPU L1/L2 cache lines, or using AVX2 SIMD instructions to relax 4 64-bit integers simultaneously.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, APSP, Floyd-Warshall, Dynamic Programming, Fast I/O
- **Complexity Summary**:
  - Time: $\mathcal{O}(n^3 + q)$
  - Space: $\mathcal{O}(n^2)$
- **Related CSES Problems**:
  - [Shortest Routes I](https://cses.fi/problemset/task/1671) — SSSP on directed graphs via Dijkstra
  - [Flight Discount](https://cses.fi/problemset/task/1195) — Shortest path with discounted edge
  - [Investigation](https://cses.fi/problemset/task/1202) — Counting and min/max hops on shortest paths
