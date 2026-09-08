# Coin Collector

- **Category**: Graph Algorithms
- **CSES Task ID**: `1686`
- **CSES Problem Link**: [Coin Collector](https://cses.fi/problemset/task/1686)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

A game consists of $n$ rooms and $m$ directed tunnels between them. Each room $i$ contains $k_i$ coins. You may start in **any** room of your choice, traverse the tunnels, and collect the coins from every room you visit. You can only collect the coins from each room at most once.

Your task is to find the **maximum total number of coins** you can collect on a single journey.

### Input Format
- The first line contains two integers $n$ and $m$: the number of rooms and tunnels.
- The second line contains $n$ integers $k_1, k_2, \dots, k_n$: the number of coins in each room.
- The next $m$ lines each contain two integers $a$ and $b$: a directed tunnel from room $a$ to room $b$.

### Output Format
- Print one integer: the maximum number of coins you can collect.

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le k_i \le 10^9$
- $1 \le a, b \le n$

With $V = 10^5, E = 2 \cdot 10^5$ and coins up to $10^9$, the total collected coins can reach $10^{14}$ (requiring `long long`). SCC condensation + DAG DP runs in linear time $\mathcal{O}(n + m) \approx 0.10\text{s}$.

---

## 2. Intuition & Pattern Recognition

This problem integrates **Strongly Connected Components (SCC)** with **Dynamic Programming on a DAG**:
- **Strongly Connected Component Property**:
  If a set of rooms forms an SCC, there exists a directed path between every pair of rooms in the set.
  Therefore, if you enter any room in an SCC, you can visit **all other rooms in that SCC** and exit through any chosen room, collecting **100% of the coins** in that entire component!
- **Condensation Graph**:
  Contract each SCC $C$ into a single super-vertex with weight equal to the sum of coins in all its member rooms:
  $$\text{scc\_coins}[C] = \sum_{u \in C} k_u$$
  All original tunnels between different components become directed edges in the condensation graph:
  $$\text{cond\_adj}[C_u] \to C_v \quad (\text{if } u \to v \text{ and } C_u \ne C_v)$$
- The resulting condensation graph is strictly a **Directed Acyclic Graph (DAG)**.
- **Maximum Path Weight on DAG**:
  The problem is now reduced to finding the path in this DAG that maximizes the sum of vertex weights:
  $$\text{dp}[C] = \text{scc\_coins}[C] + \max_{C' \in \text{cond\_adj}[C]} \text{dp}[C']$$
  The global answer is simply $\max_{C} \text{dp}[C]$.

---

## 3. Approach 1 — Naive DFS with Visited Mask

Perform recursive backtracking from every room, tracking visited rooms to maximize coins.

### Complexity Analysis
- **Time Complexity**: Exponential $\mathcal{O}(2^n)$.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Tarjan's SCC + Topological Sort

Find SCCs using Tarjan's algorithm, compute condensation graph, sort topologically using Kahn's algorithm, and perform DP.
- **Verdict**: Optimal $\mathcal{O}(n + m)$.
- Kosaraju's algorithm (Approach 3) is equally $\mathcal{O}(n + m)$ and pairs naturally with memoized DAG DP for compact, robust code.

---

## 5. Approach 3 — Optimal CSES Solution (Kosaraju SCC + Condensation DAG DP)

1. Read coins $k_i$ in 64-bit integers (`long long`).
2. Build original graph `adj` and transposed graph `rev_adj`.
3. Run Kosaraju's algorithm:
   - Pass 1: Forward DFS on `adj` to obtain finish order in `order`.
   - Pass 2: Backward DFS on `rev_adj` in reverse order, assigning `scc_id[u]`.
4. Aggregate coins for each component:
   $$\text{scc\_coins}[\text{scc\_id}[u]] += k_u$$
5. Construct condensation DAG `cond_adj`:
   - For each edge $u \to v$ in original graph:
     - If $\text{scc\_id}[u] \ne \text{scc\_id}[v]$:
       Add edge $\text{scc\_id}[u] \to \text{scc\_id}[v]$ into `cond_adj`.
6. Compute longest path on DAG using memoized DFS:
   - `dp[C]`: maximum coins obtainable starting at SCC $C$.
   - $\text{dp}[C] = \text{scc\_coins}[C] + \max_{C' \in \text{cond\_adj}[C]} \text{dp}[C']$.
7. Output $\max_{1 \le C \le \text{scc\_count}} \text{dp}[C]$.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int n, m;
vector<long long> coins;
vector<vector<int>> adj;
vector<vector<int>> rev_adj;
vector<bool> visited;
vector<int> order;
vector<int> scc_id;
int scc_count = 0;

vector<long long> scc_coins;
vector<vector<int>> cond_adj;
vector<long long> memo;

void dfs1(int u) {
    visited[u] = true;
    for (int v : adj[u]) {
        if (!visited[v]) {
            dfs1(v);
        }
    }
    order.push_back(u);
}

void dfs2(int u, int id) {
    visited[u] = true;
    scc_id[u] = id;
    scc_coins[id] += coins[u];
    for (int v : rev_adj[u]) {
        if (!visited[v]) {
            dfs2(v, id);
        }
    }
}

long long get_dp(int u) {
    if (memo[u] != -1) return memo[u];

    long long max_next = 0;
    for (int v : cond_adj[u]) {
        max_next = max(max_next, get_dp(v));
    }

    return memo[u] = scc_coins[u] + max_next;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> m)) return 0;

    coins.resize(n + 1);
    for (int i = 1; i <= n; ++i) {
        cin >> coins[i];
    }

    adj.assign(n + 1, vector<int>());
    rev_adj.assign(n + 1, vector<int>());

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        rev_adj[v].push_back(u);
    }

    // Pass 1: Forward DFS
    visited.assign(n + 1, false);
    for (int i = 1; i <= n; ++i) {
        if (!visited[i]) {
            dfs1(i);
        }
    }

    // Pass 2: Backward DFS
    visited.assign(n + 1, false);
    scc_id.assign(n + 1, 0);
    scc_coins.assign(n + 1, 0);

    for (int i = n - 1; i >= 0; --i) {
        int u = order[i];
        if (!visited[u]) {
            scc_count++;
            dfs2(u, scc_count);
        }
    }

    // Step 3: Build Condensation DAG
    cond_adj.assign(scc_count + 1, vector<int>());
    for (int u = 1; u <= n; ++u) {
        for (int v : adj[u]) {
            if (scc_id[u] != scc_id[v]) {
                cond_adj[scc_id[u]].push_back(scc_id[v]);
            }
        }
    }

    // Step 4: Longest Path on DAG via Memoized DP
    memo.assign(scc_count + 1, -1);
    long long ans = 0;

    for (int c = 1; c <= scc_count; ++c) {
        ans = max(ans, get_dp(c));
    }

    cout << ans << '\n';

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$.
  - Kosaraju's two DFS passes: $\mathcal{O}(n + m)$.
  - Condensation graph construction: $\mathcal{O}(n + m)$.
  - Memoized DFS on the condensed DAG visits each condensed node and edge at most once: $\mathcal{O}(n + m)$.
  - Total time: $\approx 0.10\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for graphs and DP memoization tables ($\approx 20\text{ MB}$).

---

## 6. Correctness Proof

### The Condensation Principle & Optimal Substructure
- **Lemma 1**: Any walk starting at a vertex in SCC $C$ can visit all vertices in $C$ before moving to an outgoing component.
  - *Proof*: By definition of an SCC, for any two vertices $x, y \in C$, there exists a path $x \rightsquigarrow y$. If an optimal walk leaves $C$ through some edge $u \to v$ ($u \in C, v \notin C$), the walk can first traverse an Eulerian-like or simple cycle visiting every vertex in $C$, ending at $u$, and then take the edge $u \to v$. Since each room's coins are collected upon first visit, contracting $C$ into a single node with total weight $\sum_{w \in C} k_w$ captures the exact maximum reward obtainable from $C$.
- **Lemma 2**: The condensation graph $G_{SCC}$ is strictly acyclic (a DAG).
  - *Proof*: Suppose $G_{SCC}$ contained a cycle $C_1 \to C_2 \to \dots \to C_k \to C_1$. Then every vertex in $C_1$ could reach every vertex in $C_k$, and vice versa. By definition of maximal SCCs, $C_1 \cup \dots \cup C_k$ would form a single larger SCC, contradicting maximality. Thus $G_{SCC}$ has no cycles.
- **Optimality of DAG DP**:
  Because $G_{SCC}$ is a finite DAG, every directed path has finite length. The recurrence $\text{dp}[C] = \text{weight}(C) + \max_{C' \in \text{succ}(C)} \text{dp}[C']$ satisfies Bellman's principle of optimality, guaranteeing that the maximum over all starting components is globally optimal. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 4$:
- Coins: `[4, 5, 2, 7]`
- Tunnels: $(1, 2), (2, 3), (3, 1)$ (forming an SCC of $\{1, 2, 3\}$), and $(2, 4)$ (pointing to isolated node 4).

1. **Kosaraju SCC**:
   - Component $C_1 = \{1, 2, 3\}$: $\text{scc\_coins}[C_1] = 4 + 5 + 2 = 11$.
   - Component $C_2 = \{4\}$: $\text{scc\_coins}[C_2] = 7$.
2. **Condensation DAG**:
   - Edge $2 \to 4$ connects $C_1 \to C_2$.
3. **DP Memoization**:
   - $\text{dp}[C_2] = \text{scc\_coins}[C_2] = 7$.
   - $\text{dp}[C_1] = \text{scc\_coins}[C_1] + \text{dp}[C_2] = 11 + 7 = 18$.
4. $\max(\text{dp}[C_1], \text{dp}[C_2]) = \max(18, 7) = 18$.
- Output: `18`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow**:
   With $n = 10^5$ rooms and $k_i = 10^9$, the total coins collected can reach $10^{14}$. Storing coins and DP values in `long long` is mandatory.
2. **Disconnected Components**:
   The player can start in **any** room. Looping $c$ from $1$ to $\text{scc\_count}$ ensures every component is considered as a potential starting point.
3. **Duplicate Condensation Edges**:
   Multiple edges between the same pair of SCCs do not affect the DAG DP, as $\max$ is idempotent: $\max(x, x) = x$.
4. **Graph is a Single Massive Cycle**:
   If the whole graph is 1 SCC, $\text{scc\_count} = 1$, and answer is the sum of all coins in the graph.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if edge weights also had costs that subtract from coins?**
   If edge costs exist, intra-SCC traversals must find the maximum weight circuit, which is NP-hard. In this problem, traversing edges is completely free, making full collection of each SCC trivial.
2. **How do we reconstruct the sequence of rooms that achieves the maximum coins?**
   Store `best_next_scc[C]`. After finding the optimal starting component, trace the DAG path. Within each SCC, find a Hamiltonian walk or use DFS to visit all vertices of the SCC.
3. **What if we can only start at room 1?**
   Instead of taking the maximum over all components $c \in [1, \text{scc\_count}]$, the answer would simply be $\text{get\_dp}(\text{scc\_id}[1])$.
4. **How does this compare to finding the longest path in general graphs?**
   Longest path on general graphs is NP-hard. By condensing all cycles into SCCs, the cyclical freedom is absorbed into scalar component sums, leaving a DAG where longest path is linear $\mathcal{O}(V + E)$.
5. **Can Tarjan's algorithm compute the component coin sum on the fly?**
   Yes. When Tarjan pops vertices from the stack to form an SCC, it can directly sum their coins, eliminating the need for a second pass.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Strongly Connected Components, Kosaraju's Algorithm, Condensation Graph, DAG DP
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Planets and Kingdoms](https://cses.fi/problemset/task/1683) — General SCC extraction
  - [Longest Flight Route](https://cses.fi/problemset/task/1680) — Longest path on a DAG
  - [Giant Pizza](https://cses.fi/problemset/task/1684) — 2-SAT via SCC
