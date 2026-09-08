# High Score

- **Category**: Graph Algorithms
- **CSES Task ID**: `1673`
- **CSES Problem Link**: [High Score](https://cses.fi/problemset/task/1673)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You play a game consisting of $n$ rooms and $m$ directed tunnels. Each tunnel has a score change $x$, which may be positive or negative (or zero). You start in room $1$ with a score of $0$ and wish to reach room $n$.

Your goal is to find the maximum possible score you can achieve upon reaching room $n$. If you can achieve an arbitrarily large score (by cycling repeatedly through a positive score cycle that lies on a path from room $1$ to room $n$), print $-1$.

### Input Format
- The first line contains two integers $n$ and $m$: the number of rooms and tunnels.
- The next $m$ lines describe the tunnels. Each line contains three integers $a$, $b$, and $x$: a directed tunnel from room $a$ to room $b$ that increases your score by $x$.

### Output Format
- Print the maximum possible score upon reaching room $n$, or $-1$ if the score can be made arbitrarily large.

### Numerical Constraints
- $1 \le n \le 2500$
- $1 \le m \le 5000$
- $1 \le a, b \le n$
- $-10^9 \le x \le 10^9$

With $V = 2500$ and $E = 5000$, an $\mathcal{O}(V \cdot E) \approx 1.25 \cdot 10^7$ operations algorithm (Bellman-Ford) executes in $\approx 0.03\text{s}$.

---

## 2. Intuition & Pattern Recognition

Maximizing score in a graph with arbitrary edge weights can be converted into the **Single-Source Shortest Path (SSSP) problem with negative edges**:
- **Negating Weights**:
  If tunnel $(u, v)$ adds score $+x$, let its cost be $w = -x$.
  Maximizing total score $\sum x$ is mathematically identical to minimizing $\sum (-x)$.
- **Arbitrarily Large Score $\iff$ Negative Cycles on a $1 \to n$ Path**:
  A cycle with positive total score corresponds to a **negative weight cycle** in the negated graph.
  However, a negative cycle anywhere in the graph **only** allows an infinite score if:
  1. The cycle is **reachable from room 1** (you can get to the cycle), AND
  2. The cycle can **reach room $n$** (you can leave the cycle and finish at room $n$).
  If a negative cycle exists that cannot reach room $n$, cycling through it is useless because you can never finish the game.
- **Reachability Filtering (Two-Way BFS/DFS)**:
  1. Compute `from_1[u]`: whether room $u$ is reachable from room $1$ (forward BFS/DFS from $1$).
  2. Compute `to_n[u]`: whether room $u$ can reach room $n$ (backward BFS/DFS from $n$ on the transposed/reversed graph).
  3. A room $u$ is **relevant** if and only if `from_1[u] && to_n[u]`.
  4. Any edge $(u, v)$ where both $u$ and $v$ are relevant lies strictly on a valid route from $1$ to $n$.
  5. Running Bellman-Ford restricted to this relevant subgraph allows us to detect if a negative cycle lies on the path to $n$.

---

## 3. Approach 1 — Naive DFS / Longest Path Backtracking

Brute-force depth-first search tracking maximum score path to $n$, detecting cycles.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^n)$ in the worst case.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE for $n > 20$.

---

## 4. Approach 2 — Standard Bellman-Ford Without Reachability Filtering

Run standard Bellman-Ford for $n$ rounds. If any vertex updates in round $n$, declare $-1$.
- **Flaw**: A negative cycle may exist in a disconnected component or in a component that cannot reach room $n$. If room $n$ cannot be reached from the negative cycle, the true maximum score to room $n$ is still a finite well-defined number! Declaring $-1$ blindly produces Wrong Answer (WA).

---

## 5. Approach 3 — Optimal CSES Solution (Reachability-Pruned Bellman-Ford)

1. Build both the original graph `adj` and the reversed graph `rev_adj`.
2. Compute `from_1` via BFS from node $1$ on `adj`.
3. Compute `to_n` via BFS from node $n$ on `rev_adj`.
4. Filter the edge list: only keep edges $(u, v, -x)$ where both `from_1[u]` and `to_n[v]` are `true`.
   (Notice that if $u$ is reachable from $1$ and $v$ can reach $n$, edge $(u, v)$ connects a path from $1$ to $n$).
5. Run Bellman-Ford on the filtered edge list:
   - Initialize `dist[1...n] = INF` ($10^{17}$), and $\text{dist}[1] = 0$.
   - Relax all filtered edges $n - 1$ times.
   - Run a final $n$-th relaxation pass:
     If any filtered edge $(u, v, w)$ can still be relaxed ($\text{dist}[u] < \text{INF}$ and $\text{dist}[u] + w < \text{dist}[v]$), then a negative cycle exists on an active path from $1$ to $n \implies$ print `-1`.
6. If no relaxation occurs on the $n$-th pass, output $-\text{dist}[n]$.

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>

using namespace std;

const long long INF = 1e17;

struct Edge {
    int u, v;
    long long w;
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<vector<int>> adj(n + 1);
    vector<vector<int>> rev_adj(n + 1);
    vector<Edge> all_edges;
    all_edges.reserve(m);

    for (int i = 0; i < m; ++i) {
        int u, v;
        long long x;
        cin >> u >> v >> x;
        adj[u].push_back(v);
        rev_adj[v].push_back(u);
        all_edges.push_back({u, v, -x}); // Negate to find shortest path
    }

    // Step 1: Forward BFS from 1
    vector<bool> from_1(n + 1, false);
    queue<int> q;
    from_1[1] = true;
    q.push(1);
    while (!q.empty()) {
        int u = q.front();
        q.pop();
        for (int v : adj[u]) {
            if (!from_1[v]) {
                from_1[v] = true;
                q.push(v);
            }
        }
    }

    // Step 2: Backward BFS from n
    vector<bool> to_n(n + 1, false);
    to_n[n] = true;
    q.push(n);
    while (!q.empty()) {
        int u = q.front();
        q.pop();
        for (int v : rev_adj[u]) {
            if (!to_n[v]) {
                to_n[v] = true;
                q.push(v);
            }
        }
    }

    // Step 3: Filter edges that lie on a path from 1 to n
    vector<Edge> relevant_edges;
    for (const auto& e : all_edges) {
        if (from_1[e.u] && to_n[e.v]) {
            relevant_edges.push_back(e);
        }
    }

    // Step 4: Bellman-Ford on relevant edges
    vector<long long> dist(n + 1, INF);
    dist[1] = 0;

    for (int i = 1; i <= n - 1; ++i) {
        for (const auto& e : relevant_edges) {
            if (dist[e.u] < INF && dist[e.u] + e.w < dist[e.v]) {
                dist[e.v] = dist[e.u] + e.w;
            }
        }
    }

    // Step 5: Check for negative cycle on pass n
    bool has_neg_cycle = false;
    for (const auto& e : relevant_edges) {
        if (dist[e.u] < INF && dist[e.u] + e.w < dist[e.v]) {
            has_neg_cycle = true;
            break;
        }
    }

    if (has_neg_cycle) {
        cout << -1 << '\n';
    } else {
        cout << -dist[n] << '\n';
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot m)$.
  - Reachability BFS (forward and backward): $\mathcal{O}(n + m)$.
  - Bellman-Ford: $n$ relaxation rounds over $\le m$ edges: $\mathcal{O}(n \cdot m) \approx 2500 \times 5000 = 1.25 \cdot 10^7$ operations $\approx 0.03\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for graphs and edge list.

---

## 6. Correctness Proof

### Path Reduction & Cycle Detection
- **Lemma 1**: Any edge $e = (u, v)$ where $\text{from\_1}[u] = \text{true}$ and $\text{to\_n}[v] = \text{true}$ belongs to at least one valid walk from $1$ to $n$.
  - *Proof*: By definition, there exists a path $1 \rightsquigarrow u$ and a path $v \rightsquigarrow n$. Concatenating $1 \rightsquigarrow u \to v \rightsquigarrow n$ produces a walk from $1$ to $n$.
- **Lemma 2**: If the relevant edge set contains a negative cycle, the distance to $n$ can be made arbitrarily small (i.e. score arbitrarily large).
  - *Proof*: Let $C$ be a negative cycle in the relevant subgraph. Since every vertex in $C$ is reachable from $1$ and can reach $n$, a walk can go from $1 \to C$, traverse $C$ arbitrarily many ($k$) times, and then follow the path from $C \to n$. Each traversal of $C$ decreases total distance by $|\text{weight}(C)| > 0$. As $k \to \infty$, total cost $\to -\infty$, meaning maximum score $\to +\infty$.
- **Lemma 3**: If no negative cycle exists in the relevant subgraph, any shortest path is simple and has at most $n - 1$ edges.
  - *Proof*: Standard Bellman-Ford theorem: after $k$ iterations, $\text{dist}[v]$ represents the minimum cost of a walk from $1$ to $v$ with at most $k$ edges. Without negative cycles, an optimal walk is a simple path with $\le n-1$ edges. Thus, round $n$ cannot relax any edge. If an edge can be relaxed at round $n$, a negative cycle exists. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 5$:
- Tunnels:
  - $(1, 2, 3)$, $(2, 4, -1)$, $(1, 3, -2)$, $(3, 4, 7)$, $(2, 2, 5)$ (self-loop on 2 with $+5$)
- Negated weights:
  - $(1, 2, -3)$, $(2, 4, 1)$, $(1, 3, 2)$, $(3, 4, -7)$, $(2, 2, -5)$
- Reachability:
  - Node 2 is reachable from 1 (`from_1[2] = true`) and can reach 4 (`to_n[2] = true`).
  - Edge $(2, 2, -5)$ is a negative cycle reachable from 1 and can reach 4!
- Bellman-Ford relaxation:
  - At round $n$, edge $(2, 2, -5)$ relaxes: $\text{dist}[2] - 5 < \text{dist}[2]$.
  - `has_neg_cycle = true` $\implies$ Output `-1`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Negative Cycle Irrelevant to Target $n$**:
   Suppose there is a negative cycle involving nodes $5$ and $6$, but neither node can reach room $n$. The backward BFS from $n$ will mark `to_n[5] = false` and `to_n[6] = false`. This cycle will be completely excluded from the relaxation step, preventing false `-1` reports.
2. **Negative Cycle Unreachable from Source $1$**:
   If a negative cycle exists that can reach $n$ but cannot be reached from $1$, forward BFS from $1$ marks `from_1` as false, correctly excluding it.
3. **64-bit Integer Overflow**:
   With edge weights up to $10^9$ and $n = 2500$, valid path distances can reach $2500 \times 10^9 = 2.5 \cdot 10^{12}$. Standard 32-bit `int` overflows. Use `long long` for all distance calculations.
4. **Infinity Constant Choice**:
   Set `INF = 1e17`. During relaxation, `dist[u] + e.w` can add a negative value to `INF`. Always check `dist[e.u] < INF` before relaxing to prevent underflow.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Why not just run Floyd-Warshall?**
   $n \le 2500$. Floyd-Warshall takes $\mathcal{O}(n^3) \approx 1.56 \cdot 10^{10}$ operations, which exceeds the 1.00s time limit by two orders of magnitude. Bellman-Ford takes $\mathcal{O}(V \cdot E) \approx 1.25 \cdot 10^7$ operations.
2. **Can SPFA (Shortest Path Faster Algorithm) be used here?**
   SPFA can detect negative cycles by counting the number of times a vertex enters the queue (if $> n$ times, cycle exists). However, SPFA worst-case is $\mathcal{O}(V \cdot E)$ and is vulnerable to specifically crafted grids that TLE. Bellman-Ford has guaranteed uniform performance.
3. **What if we want to print the actual negative cycle?**
   Store `parent[v]`. On round $n$, if an edge $(u, v)$ relaxes, trace backwards $n$ steps from $v$ to guarantee entering the cycle, then trace the cycle until the starting vertex repeats.
4. **Why is reachability filtering better than running BFS from updated nodes on round $n$?**
   Both work. However, precomputing `from_1` and `to_n` before Bellman-Ford discards irrelevant edges upfront, speeding up all $n$ iterations of Bellman-Ford and eliminating any need for post-processing DFS.
5. **How does this relate to Arbitrage in currency exchange?**
   Currency arbitrage seeks cycles where $\prod r_i > 1$. Taking negative logarithms $-\ln(r_i)$ converts product maximization into negative cycle detection, solvable via this exact technique.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, SSSP, Bellman-Ford, Negative Cycle Detection, Reachability BFS
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Cycle Finding](https://cses.fi/problemset/task/1197) — Finding and printing an explicit negative cycle
  - [Flight Discount](https://cses.fi/problemset/task/1195) — State-space shortest path
  - [Longest Flight Route](https://cses.fi/problemset/task/1680) — Longest path in a DAG
