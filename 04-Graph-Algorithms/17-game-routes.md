# Game Routes

- **Category**: Graph Algorithms
- **CSES Task ID**: `1681`
- **CSES Problem Link**: [Game Routes](https://cses.fi/problemset/task/1681)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

A game has $n$ levels numbered $1, 2, \dots, n$ and $m$ teleporters between them. Each teleporter connects level $a$ to level $b$. The game is guaranteed to contain no directed cycles (it is a DAG).

You start at level 1 and want to reach level $n$. Your task is to calculate the **number of distinct ways** you can reach level $n$ from level 1. Since the answer may be large, print it modulo $10^9 + 7$.

### Input Format
- The first line contains two integers $n$ and $m$: the number of levels and teleporters.
- The next $m$ lines each contain two integers $a$ and $b$: a teleporter from level $a$ to level $b$.

### Output Format
- Print one integer: the number of distinct ways to reach level $n$ modulo $10^9 + 7$.

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$

With $V = 10^5$ and $E = 2 \cdot 10^5$, counting paths on a DAG via topological sort runs in linear time $\mathcal{O}(n + m) \approx 0.04\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the canonical **Path Counting on a DAG** problem:
- In any Directed Acyclic Graph, paths can be counted without risk of infinite cycling.
- Let $\text{dp}[u]$ denote the number of distinct directed paths from level $1$ to level $u$.
- Base Case:
  $$\text{dp}[1] = 1, \quad \text{dp}[u] = 0 \text{ for all } u \ne 1$$
- Recurrence Relation:
  For any vertex $v$, its total paths from $1$ is the sum of paths from all its incoming predecessors $u \in \text{pred}(v)$:
  $$\text{dp}[v] = \sum_{u \to v \in E} \text{dp}[u] \pmod{10^9 + 7}$$
- Equivalently, in push-based DP: whenever vertex $u$ is processed in topological order, for each outgoing edge $u \to v$:
  $$\text{dp}[v] = (\text{dp}[v] + \text{dp}[u]) \pmod{10^9 + 7}$$
- By traversing vertices in **topological order**, we ensure that all incoming edges to $v$ have been fully processed before $v$ pushes its value downstream.

---

## 3. Approach 1 — Naive DFS Path Enumeration

Explore all paths from 1 to $n$ recursively, incrementing a counter upon reaching $n$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^n)$ in the worst case (e.g. complete DAG).
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Memoized DFS (Top-Down DP)

Compute $\text{count\_paths}(u)$ returning paths from $u$ to $n$:
- Base case: $\text{count\_paths}(n) = 1$.
- Recurrence: $\sum_{v \in \text{adj}[u]} \text{count\_paths}(v) \pmod{10^9 + 7}$.
- **Verdict**: Optimal $\mathcal{O}(n + m)$, but recursive calls on $10^5$ nodes consume stack memory and risk stack overflow. Bottom-up Kahn's algorithm is iterative and cache-friendly.

---

## 5. Approach 3 — Optimal CSES Solution (Kahn's Topological DP)

1. Compute `in_degree` for all vertices.
2. Initialize `dp[1...n] = 0` and set `dp[1] = 1`.
3. Push all vertices with `in_degree == 0` into a BFS queue.
4. While the queue is not empty:
   - Pop $u$.
   - For each outgoing neighbor $v \in \text{adj}[u]$:
     - Push DP value: $\text{dp}[v] = (\text{dp}[v] + \text{dp}[u]) \pmod{10^9 + 7}$.
     - Decrement $\text{in\_degree}[v]--$.
     - If $\text{in\_degree}[v] == 0$, push $v$ into the queue.
5. Print `dp[n]`.

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

const int MOD = 1e9 + 7;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<vector<int>> adj(n + 1);
    vector<int> in_degree(n + 1, 0);

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        in_degree[v]++;
    }

    queue<int> q;
    for (int i = 1; i <= n; ++i) {
        if (in_degree[i] == 0) {
            q.push(i);
        }
    }

    vector<int> dp(n + 1, 0);
    dp[1] = 1;

    while (!q.empty()) {
        int u = q.front();
        q.pop();

        for (int v : adj[u]) {
            dp[v] = (dp[v] + dp[u]) % MOD;
            in_degree[v]--;
            if (in_degree[v] == 0) {
                q.push(v);
            }
        }
    }

    cout << dp[n] << '\n';

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$.
  - In-degree setup and queue processing: each vertex is queued once.
  - Each directed edge is traversed exactly once for the DP addition.
  - Total time: $\approx 0.04\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for adjacency list, in-degree array, and DP table.

---

## 6. Correctness Proof

### Path Disjointness & Topological Induction
- **Theorem**: Upon termination, $\text{dp}[v]$ equals the number of distinct directed paths from $1$ to $v$ modulo $10^9 + 7$.
- **Proof by Induction**:
  1. Base case: The only path from $1$ to $1$ with length $0$ is the trivial path $(1)$. Thus $\text{dp}[1] = 1$. Any node with no incoming edges other than $1$ has $\text{dp}[u] = 0$.
  2. Inductive step: In a DAG, any path from $1$ to $v$ of length $> 0$ must end with an edge $u \to v$.
  3. Every such path can be uniquely decomposed into a path from $1$ to $u$ followed by the single edge $u \to v$.
  4. Because two paths differing in their penultimate vertex or prefix are distinct, the sets of paths entering $v$ from different predecessors $u$ are completely pairwise disjoint.
  5. By the Sum Rule of combinatorics:
     $$\text{Paths}(1 \rightsquigarrow v) = \sum_{u \in \text{pred}(v)} \text{Paths}(1 \rightsquigarrow u)$$
  6. By topological ordering, every predecessor $u$ of $v$ appears before $v$ in the queue, meaning its final value $\text{dp}[u]$ is fully accumulated and added into $\text{dp}[v]$ before $v$ is ever processed.
  7. Modular arithmetic preserves addition at each step. Thus $\text{dp}[n]$ is exact. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 5$:
- Edges: $(1, 2), (1, 3), (2, 3), (2, 4), (3, 4)$
- In-degrees: $1: 0, 2: 1, 3: 2, 4: 2$.
- Initial queue: $\{1\}$. `dp[1] = 1`, all others 0.
- **Pop 1**:
  - Edge $1 \to 2$: `dp[2] = 0 + 1 = 1`. `in_degree[2]` becomes 0 $\implies$ push 2.
  - Edge $1 \to 3$: `dp[3] = 0 + 1 = 1`. `in_degree[3]` becomes 1.
- **Pop 2**:
  - Edge $2 \to 3$: `dp[3] = 1 + 1 = 2`. `in_degree[3]` becomes 0 $\implies$ push 3.
  - Edge $2 \to 4$: `dp[4] = 0 + 1 = 1`. `in_degree[4]` becomes 1.
- **Pop 3**:
  - Edge $3 \to 4$: `dp[4] = 1 + 2 = 3`. `in_degree[4]` becomes 0 $\implies$ push 4.
- **Pop 4**: (Destination reached).
- Final `dp[4] = 3` (Paths: $1 \to 2 \to 4$, $1 \to 3 \to 4$, $1 \to 2 \to 3 \to 4$).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Unreachable Destination $n$**:
   If level $n$ cannot be reached from level 1, `dp[n]` remains 0. Correct!
2. **Components Unreachable from 1**:
   Nodes preceding 1 or in disconnected subgraphs enter the queue with `dp = 0`. Adding 0 to downstream nodes does not corrupt any valid path counts.
3. **Modulo Arithmetic**:
   The sum `(dp[v] + dp[u])` can reach $2 \cdot 10^9$, which fits within signed 32-bit `int` (up to $2.14 \times 10^9$), but using standard `% MOD` ensures values remain in $[0, 10^9 + 6]$.
4. **Graph is Guaranteed to be a DAG**:
   The problem statement guarantees no directed cycles. If cycles were present, Kahn's algorithm would simply omit cycle nodes without infinite looping.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How would you count paths on a general directed graph with cycles?**
   If cycles exist, the number of paths can be infinite (if a cycle lies on a path from 1 to $n$). In finite cases without negative cycles, shortest paths can be counted via Dijkstra's algorithm.
2. **What if we want to count paths of an exact length $K$?**
   Use adjacency matrix exponentiation: $(A^K)_{1, n}$ modulo $10^9 + 7$ computes the number of paths of length $K$ in $\mathcal{O}(n^3 \log K)$.
3. **Can we count the number of paths between all pairs of vertices?**
   Yes, on a DAG by running this topological DP from each source in $\mathcal{O}(V(V + E))$, or using matrix inversion $(I - A)^{-1}$ over a ring if acyclic.
4. **How does this connect to Markov Chains and Absorbing States?**
   Transition probabilities on an absorbing Markov chain can be computed using the fundamental matrix $(I - Q)^{-1}$, analogous to path accumulation on DAGs.
5. **How does push DP compare to pull DP?**
   Push DP updates children from the current node: `dp[v] += dp[u]`. Pull DP updates the current node from all its parents: `dp[u] = sum(dp[parent])`. Both are $\mathcal{O}(n + m)$ and yield identical results.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, DAG, Path Counting, Dynamic Programming, Topological Sort, Kahn's Algorithm
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Course Schedule](https://cses.fi/problemset/task/1679) — Topological sorting on DAGs
  - [Longest Flight Route](https://cses.fi/problemset/task/1680) — Longest path on a DAG
  - [Investigation](https://cses.fi/problemset/task/1202) — Counting shortest paths on general graphs
