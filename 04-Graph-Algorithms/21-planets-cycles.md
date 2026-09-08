# Planets Cycles

- **Category**: Graph Algorithms
- **CSES Task ID**: `1751`
- **CSES Problem Link**: [Planets Cycles](https://cses.fi/problemset/task/1751)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are in a galaxy with $n$ planets numbered $1, 2, \dots, n$. Each planet has a single directed teleporter to another planet: teleporter on planet $x$ sends you to planet $t_x$.

For every planet $i \in \{1, 2, \dots, n\}$, calculate how many teleporters you will use if you start at planet $i$ and continue jumping until you reach a planet you have already visited during your journey (the length of the trajectory before a repeat occurs).

### Input Format
- The first line contains an integer $n$: the number of planets.
- The second line contains $n$ integers $t_1, t_2, \dots, t_n$: the teleporter destinations.

### Output Format
- Print $n$ integers: for each planet $1, 2, \dots, n$, the number of jumps made before reaching an already visited planet.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le t_i \le n$

With $n = 2 \cdot 10^5$, an $\mathcal{O}(n)$ linear functional graph traversal solves all $n$ queries in $\approx 0.06\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is a problem on a **Functional Graph** (Successor Graph):
- Every vertex has an out-degree of exactly 1.
- Every connected component consists of:
  1. A unique directed cycle of length $L$.
  2. Directed trees branching into the cycle.
- **Cycle Nodes**:
  If a planet $u$ is on a cycle of length $L$, starting at $u$ will loop back to $u$ after exactly $L$ steps.
  $$\text{ans}[u] = L$$
- **Tree Nodes**:
  If a planet $u$ is not on a cycle, it is in a tree directed towards a cycle entry node $r$.
  The trajectory from $u$ takes $\text{depth}[u]$ steps to reach $r$, and from $r$ it takes $L$ steps to traverse the cycle and return to $r$.
  Because $r$ is the first repeated planet, the total number of teleporters used is:
  $$\text{ans}[u] = \text{depth}[u] + L$$
- We can determine this for all $n$ vertices simultaneously in $\mathcal{O}(n)$ time using:
  1. Kahn's in-degree reduction to identify cycle nodes.
  2. Cycle tracing to compute $L$ for each cycle.
  3. Reverse BFS from cycle nodes into the trees to compute $\text{ans}[v] = \text{ans}[u] + 1$.

---

## 3. Approach 1 — Naive Simulation from Each Planet

For each planet $i \in \{1, \dots, n\}$, simulate step-by-step using a hash set or timestamp array until a node repeats.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2) \approx (2 \cdot 10^5)^2 = 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Memoized DFS

Run DFS with path history. When a cycle is detected, backpropagate cycle length to cycle members, then accumulate depths backwards.
- **Drawback**: Recursion depth can reach $2 \cdot 10^5$. While stack memory on CSES is large, cyclic bookkeeping in recursive DFS requires careful 3-state tracking.
- **Verdict**: Kahn's in-degree elimination followed by reverse BFS (Approach 3) is completely non-recursive, branch-free, and cache-friendly.

---

## 5. Approach 3 — Optimal CSES Solution (Kahn's Reduction + Reverse BFS)

1. Compute in-degrees: `in_degree[t[i]]++`.
2. Push all nodes with `in_degree == 0` into a queue.
3. Eliminate non-cycle nodes via Kahn's algorithm: `in_degree[t[u]]--`.
4. Nodes with `in_degree > 0` are precisely the cycle nodes.
5. For each unvisited cycle node, trace around the cycle:
   - Collect vertices in `cycle_nodes`.
   - Cycle length is $L = |\text{cycle\_nodes}|$.
   - Assign $\text{ans}[u] = L$ for all $u \in \text{cycle\_nodes}$.
6. Run BFS on the reversed graph starting from all cycle nodes:
   - For each neighbor $v$ in `rev_adj[u]` that is not on a cycle:
     $$\text{ans}[v] = \text{ans}[u] + 1$$
     Enqueue $v$.
7. Print $\text{ans}[1], \dots, \text{ans}[n]$.

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> t(n + 1);
    vector<vector<int>> rev_adj(n + 1);
    vector<int> in_degree(n + 1, 0);

    for (int i = 1; i <= n; ++i) {
        cin >> t[i];
        rev_adj[t[i]].push_back(i);
        in_degree[t[i]]++;
    }

    // Step 1: Kahn's algorithm to eliminate tree nodes
    queue<int> q_deg;
    for (int i = 1; i <= n; ++i) {
        if (in_degree[i] == 0) {
            q_deg.push(i);
        }
    }

    while (!q_deg.empty()) {
        int u = q_deg.front();
        q_deg.pop();
        int v = t[u];
        in_degree[v]--;
        if (in_degree[v] == 0) {
            q_deg.push(v);
        }
    }

    vector<bool> is_cycle(n + 1, false);
    for (int i = 1; i <= n; ++i) {
        if (in_degree[i] > 0) {
            is_cycle[i] = true;
        }
    }

    vector<int> ans(n + 1, 0);
    vector<bool> visited_cycle(n + 1, false);

    // Step 2: Trace cycles and assign cycle length
    for (int i = 1; i <= n; ++i) {
        if (is_cycle[i] && !visited_cycle[i]) {
            vector<int> cycle_nodes;
            int curr = i;
            while (!visited_cycle[curr]) {
                visited_cycle[curr] = true;
                cycle_nodes.push_back(curr);
                curr = t[curr];
            }

            int cycle_len = cycle_nodes.size();
            for (int node : cycle_nodes) {
                ans[node] = cycle_len;
            }
        }
    }

    // Step 3: BFS on reversed graph to propagate answers into trees
    queue<int> q_bfs;
    for (int i = 1; i <= n; ++i) {
        if (is_cycle[i]) {
            q_bfs.push(i);
        }
    }

    while (!q_bfs.empty()) {
        int u = q_bfs.front();
        q_bfs.pop();

        for (int v : rev_adj[u]) {
            if (!is_cycle[v]) {
                ans[v] = ans[u] + 1;
                q_bfs.push(v);
            }
        }
    }

    // Step 4: Output answers
    for (int i = 1; i <= n; ++i) {
        cout << ans[i] << (i == n ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n)$.
  - In-degree reduction: $\mathcal{O}(n)$.
  - Cycle extraction: each cycle vertex visited once $\mathcal{O}(n)$.
  - Reverse BFS: each tree vertex and edge visited once $\mathcal{O}(n)$.
  - Total time: $\approx 0.06\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ for adjacency lists and status arrays ($\approx 12\text{ MB}$).

---

## 6. Correctness Proof

### Path Uniqueness & Trajectory Length
- **Theorem**: For any vertex $u$ in a functional graph, the trajectory $u, t_u, t_{t_u}, \dots$ visits exactly $\text{ans}[u]$ distinct edges before repeating a vertex.
- **Proof**:
  1. Because out-degree is 1, the forward trajectory from any vertex $u$ is unique and deterministic.
  2. Since $V$ is finite ($n$ vertices), by the Pigeonhole Principle, the trajectory must eventually repeat a vertex.
  3. Let $r$ be the first vertex repeated along the path. Then the trajectory has the form:
     $$u = v_0 \to v_1 \to \dots \to v_d = r \to c_1 \to c_2 \to \dots \to c_{L-1} \to r$$
     where $v_0, \dots, v_d$ are distinct, and $c_1, \dots, c_{L-1}$ are distinct from each other and from the prefix.
  4. The first repeated vertex is $r$, and the number of steps taken from $u$ until $r$ is revisited is $d + L$.
  5. If $u$ is on the cycle ($u = r$), $d = 0$, and the trajectory visits the cycle of length $L$, so $\text{ans}[u] = L$.
  6. If $u$ is in a tree, $u \to t_u$ is a step towards $r$. By induction on tree depth, the trajectory from $u$ takes 1 step to reach $t_u$, from which it takes $\text{ans}[t_u]$ steps until repeat.
  7. Therefore $\text{ans}[u] = \text{ans}[t_u] + 1$.
  8. Reverse BFS propagates this relation outward from the cycle roots, guaranteeing that every vertex receives its exact trajectory length. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 5$:
- $t = [2, 4, 3, 1, 4]$
  - $3 \to 3$ (self-loop, cycle length 1).
  - $1 \to 2 \to 4 \to 1$ (cycle of length 3).
  - $5 \to 4$ (tree node entering cycle at 4).

1. In-degrees: $1: 1, 2: 1, 3: 1, 4: 2, 5: 0$.
2. Kahn queue pops $5$: decrements $4$'s in-degree to 1.
3. Cycle nodes: $\{1, 2, 3, 4\}$.
4. Cycle tracing:
   - Cycle $\{3\}$: length 1 $\implies \text{ans}[3] = 1$.
   - Cycle $\{1, 2, 4\}$: length 3 $\implies \text{ans}[1] = 3, \text{ans}[2] = 3, \text{ans}[4] = 3$.
5. Reverse BFS from cycle nodes:
   - From node 4, explore reversed edge $4 \leftarrow 5$:
     $\text{ans}[5] = \text{ans}[4] + 1 = 3 + 1 = 4$.
6. Final output: `3 3 1 3 4`.
   - Trace for 5: $5 \to 4 \to 1 \to 2 \to 4$ (4 jumps until 4 is revisited). Exact match!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Self-Loops**:
   If planet $u$ points to itself ($t_u = u$), cycle length is 1. Output is 1.
2. **Disconnected Components**:
   Multiple disjoint cycles and components are handled cleanly since Kahn's reduction leaves all cycles marked.
3. **Entire Graph is a Pure Cycle**:
   If $t = [2, 3, \dots, n, 1]$, in-degrees are all 1. Kahn queue is empty. Step 2 labels all nodes with length $n$.
4. **Entire Graph is a Single Tree into a Self-Loop**:
   Handled identically; depths propagate from the self-loop outward to all leaves.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does this connect to Floyd's Cycle-Finding Algorithm (Tortoise and Hare)?**
   Floyd's algorithm finds cycles in $\mathcal{O}(n)$ time and $\mathcal{O}(1)$ space for a single node. Our batch Kahn's reduction finds all cycles and component sizes for all $n$ nodes simultaneously in $\mathcal{O}(n)$ time and space.
2. **Can this be solved using Tarjan's SCC Algorithm?**
   Yes. In a functional graph, every SCC with $> 1$ node (or 1 node with self-loop) is a cycle. Condensed components form trees.
3. **What if we only want the length of the cycle for each node, excluding the tree prefix?**
   For cycle nodes, it's $L$. For tree nodes, it's $L$ (the length of the cycle they eventually enter). That would just be `cycle_len[root[u]]`.
4. **What if we want to know the FIRST repeated planet for each node?**
   For cycle nodes, it is the planet itself. For tree nodes, it is $\text{root}[u]$ (the entry node into the cycle).
5. **How does this relate to Pollard's rho integer factorization algorithm?**
   Pollard's rho generates pseudo-random sequences $x_{i+1} = (x_i^2 + c) \bmod N$, which forms a functional graph on $\mathbb{Z}_N$. Cycle finding discovers non-trivial factors in expected $\mathcal{O}(N^{1/4})$ time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Functional Graph, Successor Graph, Kahn's Algorithm, Reverse BFS, Cycle Detection
- **Complexity Summary**:
  - Time: $\mathcal{O}(n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - [Planets Queries I](https://cses.fi/problemset/task/1750) — Successor doubling with binary lifting
  - [Planets Queries II](https://cses.fi/problemset/task/1160) — Path distances in functional graphs
  - [Round Trip II](https://cses.fi/problemset/task/1678) — Directed cycle detection
