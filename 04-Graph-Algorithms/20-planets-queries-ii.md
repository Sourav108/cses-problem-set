# Planets Queries II

- **Category**: Graph Algorithms
- **CSES Task ID**: `1160`
- **CSES Problem Link**: [Planets Queries II](https://cses.fi/problemset/task/1160)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are in a galaxy with $n$ planets numbered $1, 2, \dots, n$. Each planet has a single directed teleporter to another planet: the teleporter on planet $x$ sends you to planet $t_x$.

You are given $q$ queries. In each query, you are given two planets $a$ and $b$, and you must determine the **minimum number of teleporter jumps** needed to travel from planet $a$ to planet $b$. If it is impossible to reach planet $b$ from planet $a$, output $-1$.

### Input Format
- The first line contains two integers $n$ and $q$: the number of planets and queries.
- The second line contains $n$ integers $t_1, t_2, \dots, t_n$: the teleporter destinations.
- The next $q$ lines each contain two integers $a$ and $b$: the start and target planets.

### Output Format
- For each query, print the minimum number of jumps, or $-1$ if unreachable.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le t_x, a, b \le n$

With $n, q \le 2 \cdot 10^5$, an $\mathcal{O}((n + q) \log n)$ functional graph decomposition with binary lifting executes in $\approx 0.20\text{s}$.

---

## 2. Intuition & Pattern Recognition

Every directed graph where every vertex has an out-degree of 1 is a **Functional Graph** (Successor Graph).
- **Structure of a Functional Graph**:
  Each weakly connected component consists of:
  1. Exactly **one directed cycle**.
  2. Zero or more **directed trees** rooted on the cycle, whose edges are directed inward toward the cycle.
- **Node Classification**:
  - **Cycle Nodes**: Have `depth = 0`. Each belongs to a specific cycle with an assigned `cycle_id`, `cycle_len`, and position `cycle_pos \in [0, \text{cycle\_len} - 1]`.
  - **Tree Nodes**: Directed towards a cycle. Each tree node has a `root` (the cycle node it enters), a `depth` (number of jumps to reach its root), and inherits `cycle_id`.
- **Reachability Analysis for Query $(a, b)$**:
  - If `cycle_id[a] != cycle_id[b]`, $a$ and $b$ are in disconnected components $\implies -1$.
  - **Case 1: Target $b$ is on a cycle**:
    - Any node in the component can reach the cycle!
    - Distance from $a$ to its cycle entry root is $\text{depth}[a]$.
    - Distance from $\text{root}[a]$ to $b$ along the cycle is:
      $$\text{cycle\_dist} = (\text{cycle\_pos}[b] - \text{cycle\_pos}[\text{root}[a]] + \text{cycle\_len}) \pmod{\text{cycle\_len}}$$
    - Total jumps: $\text{depth}[a] + \text{cycle\_dist}$.
  - **Case 2: Target $b$ is in a tree (not on a cycle)**:
    - A tree node $b$ can **only** be reached by nodes in the directed branch leading into $b$.
    - This requires three conditions:
      1. $\text{root}[a] == \text{root}[b]$ (same tree component).
      2. $\text{depth}[a] \ge \text{depth}[b]$ ($a$ must be further out in the tree than $b$).
      3. Jumping $\Delta = \text{depth}[a] - \text{depth}[b]$ steps from $a$ using binary lifting lands exactly on $b$:
         $$\text{lift}(a, \Delta) == b$$
      If all three hold, answer is $\Delta$; otherwise, impossible $\implies -1$.

---

## 3. Approach 1 — Naive Simulation per Query

From $a$, simulate teleporter jumps one step at a time, tracking visited planets, until $b$ is found or a cycle repeats.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 2 \cdot 10^5 \times 2 \cdot 10^5 = 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Heavy-Light Decomposition on Reversed Trees

Reverse all tree edges and apply Heavy-Light Decomposition (HLD) or LCA on trees.
- **Verdict**: Valid, but Binary Lifting achieves the exact same jump verification in $\mathcal{O}(\log n)$ time with significantly less code and overhead.

---

## 5. Approach 3 — Optimal CSES Solution (Decomposition + Binary Lifting)

1. **Step 1: Identify Cycles via Kahn's In-Degree Reduction**:
   - Compute in-degrees of all $n$ nodes.
   - Enqueue all nodes with `in_degree == 0`.
   - Decrement neighbor in-degrees: nodes that are never queued are part of cycles (`is_cycle[u] = true`).
2. **Step 2: Trace and Label Cycles**:
   - For each cycle node not yet visited, assign a new `cycle_id`.
   - Walk around the cycle, assigning `cycle_pos`, setting `depth[u] = 0`, `root[u] = u`.
3. **Step 3: BFS on Reversed Graph for Tree Depths**:
   - Push all cycle nodes into a BFS queue.
   - Using the reversed adjacency list `rev_adj`, traverse outward into the trees:
     $$\text{depth}[v] = \text{depth}[u] + 1, \quad \text{root}[v] = \text{root}[u], \quad \text{cycle\_id}[v] = \text{cycle\_id}[u]$$
4. **Step 4: Precompute Binary Lifting Table `up[n+1][30]`**:
   $$\text{up}[u][j] = \text{up}\big[ \text{up}[u][j - 1] \big][j - 1]$$
5. **Step 5: Answer Queries in $\mathcal{O}(\log n)$**:
   - Use the reachability rules from Section 2.

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

const int MAX_POW = 30;

int n, q;
vector<int> t;
vector<vector<int>> rev_adj;
vector<vector<int>> up_table;
vector<bool> is_cycle;
vector<int> cycle_id;
vector<int> cycle_pos;
vector<int> cycle_len;
vector<int> depth_val;
vector<int> root_node;

int lift(int u, int k) {
    for (int j = 0; j < MAX_POW; ++j) {
        if ((k >> j) & 1) {
            u = up_table[u][j];
        }
    }
    return u;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> q)) return 0;

    t.assign(n + 1, 0);
    rev_adj.assign(n + 1, vector<int>());
    vector<int> in_degree(n + 1, 0);

    for (int i = 1; i <= n; ++i) {
        cin >> t[i];
        rev_adj[t[i]].push_back(i);
        in_degree[t[i]]++;
    }

    // Binary Lifting Table
    up_table.assign(n + 1, vector<int>(MAX_POW));
    for (int i = 1; i <= n; ++i) {
        up_table[i][0] = t[i];
    }
    for (int j = 1; j < MAX_POW; ++j) {
        for (int i = 1; i <= n; ++i) {
            up_table[i][j] = up_table[up_table[i][j - 1]][j - 1];
        }
    }

    // Step 1: In-degree elimination to find cycle nodes
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

    is_cycle.assign(n + 1, false);
    for (int i = 1; i <= n; ++i) {
        if (in_degree[i] > 0) {
            is_cycle[i] = true;
        }
    }

    cycle_id.assign(n + 1, 0);
    cycle_pos.assign(n + 1, 0);
    cycle_len.assign(n + 1, 0);
    depth_val.assign(n + 1, 0);
    root_node.assign(n + 1, 0);

    int current_cid = 0;
    for (int i = 1; i <= n; ++i) {
        if (is_cycle[i] && cycle_id[i] == 0) {
            current_cid++;
            int curr = i;
            int pos = 0;
            while (cycle_id[curr] == 0) {
                cycle_id[curr] = current_cid;
                cycle_pos[curr] = pos++;
                root_node[curr] = curr;
                depth_val[curr] = 0;
                curr = t[curr];
            }
            cycle_len[current_cid] = pos;
        }
    }

    // Step 3: BFS on reversed edges for tree depths
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
                depth_val[v] = depth_val[u] + 1;
                root_node[v] = root_node[u];
                cycle_id[v] = cycle_id[u];
                q_bfs.push(v);
            }
        }
    }

    // Step 5: Process Queries
    while (q--) {
        int a, b;
        cin >> a >> b;

        if (cycle_id[a] != cycle_id[b]) {
            cout << -1 << '\n';
            continue;
        }

        int cid = cycle_id[a];
        int clen = cycle_len[cid];

        if (is_cycle[b]) {
            // b is on the cycle
            int d_a = depth_val[a];
            int root_a = root_node[a];
            int c_dist = (cycle_pos[b] - cycle_pos[root_a] + clen) % clen;
            cout << d_a + c_dist << '\n';
        } else {
            // b is in a tree branch
            if (root_node[a] != root_node[b] || depth_val[a] < depth_val[b]) {
                cout << -1 << '\n';
            } else {
                int diff = depth_val[a] - depth_val[b];
                if (lift(a, diff) == b) {
                    cout << diff << '\n';
                } else {
                    cout << -1 << '\n';
                }
            }
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**:
  - Precomputation (Kahn's in-degree + cycle labeling + reverse BFS): $\mathcal{O}(n)$.
  - Binary lifting table precomputation: $\mathcal{O}(n \log n) = 2 \cdot 10^5 \times 30 \approx 6 \cdot 10^6$ ops.
  - Answering $q$ queries: $\mathcal{O}(q \log n)$ in the worst case (when lifting by $\Delta$), taking $\approx 0.12\text{s}$.
  - Total Time: $\approx 0.18\text{s}$ to $0.22\text{s}$.
- **Space Complexity**: $\mathcal{O}(n \log n)$ for the binary lifting table ($\approx 24\text{ MB}$) and $\mathcal{O}(n)$ for auxiliary vectors.

---

## 6. Correctness Proof

### Exhaustive Case Completeness on Functional Graphs
- **Lemma**: In a functional graph component, every vertex $u$ has a unique path to its cycle root $\text{root}[u]$ of length $\text{depth}[u]$. Once on the cycle, teleporters move cyclically in one direction.
- **Proof**:
  1. Since each node has out-degree 1, the forward path starting at any node $u$ is unique.
  2. If target $b$ lies on the cycle:
     The path from $a$ must eventually enter the cycle at $\text{root}[a]$ after exactly $\text{depth}[a]$ steps.
     From $\text{root}[a]$, continuing around the cycle visits all cycle nodes in order of `cycle_pos`.
     The minimum steps from $\text{root}[a]$ to $b$ along the cycle is strictly $(\text{pos}[b] - \text{pos}[\text{root}[a]] + L) \bmod L$.
     Thus total distance is $\text{depth}[a] + \text{cycle\_dist}$.
  3. If target $b$ does not lie on the cycle:
     Because all edges in trees are directed toward the cycle, entering the cycle is irreversible (no edge points out of a cycle into a tree).
     Hence, to reach $b$, path from $a$ can never reach the cycle before visiting $b$.
     Both $a$ and $b$ must be in the same tree component directed into the same cycle root ($\text{root}[a] == \text{root}[b]$), with $\text{depth}[a] \ge \text{depth}[b]$.
     Because out-degree is 1, $b$ is reachable from $a$ if and only if jumping exactly $\text{depth}[a] - \text{depth}[b]$ steps from $a$ lands on $b$.
  4. All cases are mutually exclusive and collectively exhaustive. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 6, q = 3$:
- Teleporters: $t = [2, 3, 1, 3, 4, 2]$
  - Cycle: $1 \to 2 \to 3 \to 1$ (length 3).
  - Trees:
    - $4 \to 3$ (depth 1, root 3)
    - $5 \to 4$ (depth 2, root 3)
    - $6 \to 2$ (depth 1, root 2)
- Query 1: $a = 5, b = 1$
  - $b = 1$ is on cycle.
  - $\text{depth}[5] = 2$, $\text{root}[5] = 3$.
  - Cycle positions: $3 \to \text{pos } 2$, $1 \to \text{pos } 0$.
  - $\text{cycle\_dist} = (0 - 2 + 3) \bmod 3 = 1$.
  - Total: $2 + 1 = 3$ jumps ($5 \to 4 \to 3 \to 1$). Exact!
- Query 2: $a = 5, b = 4$
  - $b = 4$ is in tree. Same root (3). $\text{depth}[5] = 2 \ge \text{depth}[4] = 1$.
  - Difference: $2 - 1 = 1$. `lift(5, 1) = 4 == 4`. Distance: 1.
- Query 3: $a = 6, b = 4$
  - Different roots ($2 \ne 3$) and $b$ is in tree $\implies$ Output: $-1$.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Self-Loops ($t_x = x$)**:
   A self-loop forms a cycle of length 1. Handled naturally: `cycle_len = 1`, `c_dist = 0`.
2. **Query from a Planet to Itself ($a == b$)**:
   - If $a$ is on a cycle: $\text{depth}[a] = 0$, $\text{cycle\_dist} = 0 \implies 0$.
   - If $a$ is in a tree: $\text{diff} = 0$, `lift(a, 0) == a \implies 0$.
   Output is correctly 0.
3. **Target $b$ Unreachable**:
   When $a$ is on the cycle and $b$ is in a tree, $\text{depth}[a] = 0 < \text{depth}[b] > 0$, properly returning $-1$.
4. **Modulo Arithmetic for Cycle Distance**:
   Adding `+ clen` before `% clen` ensures non-negative results for negative position differences.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does this compare to LCA on standard trees?**
   A standard tree has out-degree $\ge 1$ (branches) and in-degree 1 directed to parents. A functional graph has out-degree strictly 1 and in-degree $\ge 0$. It is essentially an inverted forest feeding into directed cycles.
2. **What if the graph has multiple disjoint components?**
   Assigning a distinct `cycle_id` to each cycle and propagating it outward during the reverse BFS cleanly isolates components.
3. **Can this be solved using Tarjan's SCC algorithm?**
   Yes. Tarjan's algorithm will find all SCCs: each non-trivial SCC (size $\ge 2$, or size 1 with self-loop) is exactly a cycle!
4. **How do you find the cycle length for all vertices?**
   This is CSES Planets Cycles (`CSES 1751`): for cycle nodes, distance is `cycle_len`; for tree nodes, distance is `depth[u] + cycle_len[root[u]]`.
5. **What is the maximum depth a tree can have?**
   Up to $n - 1 \approx 2 \cdot 10^5$. 30 powers of two in binary lifting comfortably covers any depth up to $10^9$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Functional Graph, Successor Graph, Binary Lifting, Kahn's Algorithm, Reverse BFS
- **Complexity Summary**:
  - Time: $\mathcal{O}((n + q) \log n)$
  - Space: $\mathcal{O}(n \log n)$
- **Related CSES Problems**:
  - [Planets Queries I](https://cses.fi/problemset/task/1750) — $k$ steps jump on functional graphs
  - [Planets Cycles](https://cses.fi/problemset/task/1751) — Steps before entering cycle
  - [Company Queries II](https://cses.fi/problemset/task/1688) — LCA in tree via binary lifting
