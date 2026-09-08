# Flight Discount

- **Category**: Graph Algorithms
- **CSES Task ID**: `1195`
- **CSES Problem Link**: [Flight Discount](https://cses.fi/problemset/task/1195)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ cities and $m$ directed flight connections between them. Each flight connection from city $a$ to city $b$ has a price $c$.

You have a special discount coupon that allows you to **halve the price of exactly one flight** along your route. The discounted price of a flight with original price $c$ becomes $\lfloor c / 2 \rfloor$.

Your task is to find the minimum total price to travel from **city 1** to **city $n$** using the discount coupon at most once.

### Input Format
- The first line contains two integers $n$ and $m$: the number of cities and flights.
- The next $m$ lines each contain three integers $a$, $b$, and $c$: a flight from city $a$ to city $b$ with price $c$.

### Output Format
- Print one integer: the minimum total price from city 1 to city $n$.

### Numerical Constraints
- $2 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$
- $1 \le c \le 10^9$

With $V = 10^5, E = 2 \cdot 10^5$ and edge weights up to $10^9$, paths exceed 32-bit limits. State-expanded Dijkstra executes in $\mathcal{O}((n + m) \log n) \approx 0.12\text{s}$.

---

## 2. Intuition & Pattern Recognition

This problem is a classic application of **State-Space Expansion (Layered Graph / Multilevel Dijkstra)**:
- Normally, the state in Dijkstra is just the current vertex $u$.
- Here, we have a binary state: have we used our single discount coupon yet?
  - State $(u, 0)$: Currently at vertex $u$, discount coupon has **not** been used.
  - State $(u, 1)$: Currently at vertex $u$, discount coupon **has** been used.
- For each directed flight $(u \to v, c)$, there are three possible state transitions:
  1. **Move without using coupon**:
     $$(u, 0) \xrightarrow{c} (v, 0)$$
  2. **Move using the coupon on this flight**:
     $$(u, 0) \xrightarrow{\lfloor c / 2 \rfloor} (v, 1)$$
  3. **Move when coupon was already used previously**:
     $$(u, 1) \xrightarrow{c} (v, 1)$$
- We start at $(1, 0)$ with cost $0$, and our target is the minimum cost to reach $(n, 1)$ (or $(n, 0)$ if free flights existed, though $(n, 1)$ is always $\le (n, 0)$).
- Because all edge weights (including $\lfloor c / 2 \rfloor$) are non-negative, standard Dijkstra on the expanded $2n$-vertex graph finds the exact shortest distance.

---

## 3. Approach 1 — Naive: Run Dijkstra for Every Possible Discounted Edge

For each edge $e = (u, v, c) \in E$, temporarily replace its weight with $\lfloor c / 2 \rfloor$ and run full Dijkstra from $1$ to $n$. Take the minimum across all $m$ runs.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(m \cdot (n + m) \log n) \approx 2 \cdot 10^5 \times (3 \cdot 10^5 \times 17) \approx 10^{12}$ operations.
- **CSES Verdict**: TLE (Time Limit Exceeded).

---

## 4. Approach 2 — Bidirectional Dijkstra with Two Distance Arrays

Run two independent Dijkstra runs:
1. `dist_from_1[u]`: shortest distance from city 1 to all cities $u$ on the original graph.
2. `dist_to_n[v]`: shortest distance from all cities $v$ to city $n$ on the **reversed graph**.
3. For each edge $(u, v, c)$, compute:
   $$\text{ans} = \min_{(u, v, c)} \left( \text{dist\_from\_1}[u] + \lfloor c / 2 \rfloor + \text{dist\_to\_n}[v] \right)$$
- **Complexity**: $\mathcal{O}((n + m) \log n)$ using two separate Dijkstra passes.
- **Verdict**: Fully optimal. However, Approach 3 solves the problem in a single unified state-space Dijkstra pass with simpler code.

---

## 5. Approach 3 — Optimal CSES Solution (State-Space Dijkstra)

We define a 2D distance array `dist[n+1][2]` initialized to $\text{INF} = 10^{18}$.
- Priority queue stores tuples: `{distance, vertex, coupon_used}`.
- Start with `dist[1][0] = 0` and push `{0, 1, 0}`.
- When popping `{d, u, used}`:
  - If $d > \text{dist}[u][used]$, discard as stale.
  - For each outgoing edge $(u \to v, c)$:
    - If `used == 0`:
      - **Option A (Don't use coupon)**: relax edge $(u, 0) \to (v, 0)$ with weight $c$.
      - **Option B (Use coupon now)**: relax edge $(u, 0) \to (v, 1)$ with weight $c / 2$.
    - If `used == 1`:
      - Relax edge $(u, 1) \to (v, 1)$ with weight $c$.
- Final answer is $\text{dist}[n][1]$.

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <tuple>

using namespace std;

const long long INF = 1e18;

struct State {
    long long dist;
    int u;
    int used; // 0 = coupon available, 1 = coupon used

    bool operator>(const State& other) const {
        return dist > other.dist;
    }
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<vector<pair<int, int>>> adj(n + 1);
    for (int i = 0; i < m; ++i) {
        int u, v, w;
        cin >> u >> v >> w;
        adj[u].push_back({v, w});
    }

    vector<vector<long long>> dist(n + 1, vector<long long>(2, INF));
    priority_queue<State, vector<State>, greater<State>> pq;

    dist[1][0] = 0;
    pq.push({0, 1, 0});

    while (!pq.empty()) {
        auto [d, u, used] = pq.top();
        pq.pop();

        if (d > dist[u][used]) continue;

        for (auto& edge : adj[u]) {
            int v = edge.first;
            long long w = edge.second;

            if (used == 0) {
                // Option 1: Continue without using coupon
                if (dist[u][0] + w < dist[v][0]) {
                    dist[v][0] = dist[u][0] + w;
                    pq.push({dist[v][0], v, 0});
                }
                // Option 2: Use coupon on this flight
                if (dist[u][0] + w / 2 < dist[v][1]) {
                    dist[v][1] = dist[u][0] + w / 2;
                    pq.push({dist[v][1], v, 1});
                }
            } else {
                // Coupon already used, must pay full price
                if (dist[u][1] + w < dist[v][1]) {
                    dist[v][1] = dist[u][1] + w;
                    pq.push({dist[v][1], v, 1});
                }
            }
        }
    }

    cout << dist[n][1] << '\n';

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}((V' + E') \log V')$ where $V' = 2n$ and $E' = 3m$.
  Total operations: $\mathcal{O}((2n + 3m) \log(2n)) \approx 8 \cdot 10^5 \log(2 \cdot 10^5) \approx 1.4 \cdot 10^7$ instructions, completing in $\approx 0.12\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for adjacency list and 2-layer distance table.

---

## 6. Correctness Proof

### Equivalence to Shortest Path on a Layered DAG
- **Construction**:
  Consider a 2-layered graph $G' = (V', E')$ where $V' = \{ (u, 0), (u, 1) \mid u \in V \}$.
  - Layer 0 represents cities before coupon usage.
  - Layer 1 represents cities after coupon usage.
  - Edges within Layer 0 have original weights $c$.
  - Edges within Layer 1 have original weights $c$.
  - Downward directed edges from $(u, 0)$ to $(v, 1)$ have weight $\lfloor c / 2 \rfloor$.
- **No Upward Transitions**:
  There are no edges from Layer 1 back to Layer 0. Hence, any path in $G'$ from $(1, 0)$ to $(n, 1)$ can cross between layers at most once (using the coupon exactly once).
- **Non-Negative Weights**:
  Since original weights $c \ge 1$, all edges in $G'$ have weight $\ge 0$.
  By Dijkstra's optimality theorem on non-negative weighted graphs, the minimum distance computed to $(n, 1)$ is the exact minimum path cost over all possible routes using at most one discount coupon. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 3, m = 4$:
- Edges: $(1, 2, 3)$, $(2, 3, 1)$, $(1, 3, 7)$, $(2, 1, 5)$

1. **Start**:
   `dist[1][0] = 0`, push `{0, 1, 0}`.
2. **Pop {0, 1, 0}**:
   - Edge $(1, 2, 3)$:
     - Don't use coupon: `dist[2][0] = 0 + 3 = 3`, push `{3, 2, 0}`.
     - Use coupon: `dist[2][1] = 0 + 3/2 = 1`, push `{1, 2, 1}`.
   - Edge $(1, 3, 7)$:
     - Don't use coupon: `dist[3][0] = 0 + 7 = 7`, push `{7, 3, 0}`.
     - Use coupon: `dist[3][1] = 0 + 7/2 = 3`, push `{3, 3, 1}`.
3. **Pop {1, 2, 1}** (smallest in heap):
   - Edge $(2, 3, 1)$ (coupon already used):
     - `dist[3][1] = min(3, 1 + 1) = 2`, push `{2, 3, 1}`.
4. **Pop {2, 3, 1}**:
   - Reached city $3$ in layer 1 with distance $2$.
5. Final answer: `dist[3][1] = 2` (path: $1 \xrightarrow{\text{discount 3/2=1}} 2 \xrightarrow{1} 3$, total cost $1 + 1 = 2$).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Integer Division Truncation**:
   The problem specifies $\lfloor c / 2 \rfloor$, which matches C++ integer division `w / 2`. No floating-point operations needed.
2. **64-bit Overflow**:
   Edge costs up to $10^9$ and $n = 10^5$ mean path costs can reach $10^{14}$. Use `long long` everywhere for distances.
3. **Coupon Usage is Strictly Optional**:
   Since all edge weights $w \ge 1$, $\lfloor w / 2 \rfloor \le w$. Therefore, using the coupon can never increase the total cost, so $\text{dist}[n][1] \le \text{dist}[n][0]$ always holds.
4. **Direct Route from 1 to $n$**:
   If a single direct flight $(1 \to n, c)$ exists, using the coupon on it yields cost $\lfloor c / 2 \rfloor$, which is correctly considered via $(1, 0) \to (n, 1)$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if we have $K$ discount coupons instead of 1?**
   Expand the state space to $K + 1$ layers: $(u, k)$ for $0 \le k \le K$. Total vertices $(K + 1)n$, running in $\mathcal{O}(K(n + m) \log(Kn))$.
2. **What if the coupon can be applied to ANY edge for free ($c = 0$)?**
   Same layered graph transition with weight 0 for the cross-layer edge $(u, 0) \to (v, 1)$.
3. **Can this be solved if edge weights can be negative?**
   If negative weights exist, Dijkstra fails; we would run Bellman-Ford or SPFA across the 2 layers in $\mathcal{O}(V \cdot E)$.
4. **How do we reconstruct the route and identify WHICH edge received the coupon?**
   Store `parent[u][used]` as a pair `{prev_u, prev_used}`. When backtracking from $(n, 1)$ to $(1, 0)$, the step where `prev_used == 0` and `curr_used == 1` is the discounted edge.
5. **Why is layered Dijkstra faster than running Dijkstra $K$ times?**
   Layered Dijkstra explores the combined state space in a single priority queue, allowing branch pruning and avoiding repeated edge relaxations.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Dijkstra, Layered Graph, State-Space SSSP, Greedy
- **Complexity Summary**:
  - Time: $\mathcal{O}((n + m) \log n)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Shortest Routes I](https://cses.fi/problemset/task/1671) — Standard Dijkstra on directed graphs
  - [Flight Routes](https://cses.fi/problemset/task/1196) — Finding $k$-shortest paths
  - [Investigation](https://cses.fi/problemset/task/1202) — Shortest path DAG counting and properties
