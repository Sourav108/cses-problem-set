# Tree Matching

- **Category**: Tree Algorithms
- **CSES Task ID**: `1130`
- **CSES Problem Link**: [Tree Matching](https://cses.fi/problemset/task/1130)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a tree consisting of $n$ nodes numbered $1, 2, \dots, n$ and $n - 1$ undirected edges.

A **matching** is a subset of edges such that no two edges share a common vertex. Your task is to determine the **maximum number of edges** in a matching (the maximum cardinality matching of the tree).

### Input Format
- The first line contains an integer $n$: the number of nodes.
- The next $n - 1$ lines describe the edges: each line has two integers $a$ and $b$ ($1 \le a, b \le n$).

### Output Format
- Print one integer: the maximum number of edges in a matching.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le a, b \le n$

---

## 2. Intuition & Pattern Recognition

While Maximum Matching in general graphs requires Edmonds' Blossom algorithm ($\mathcal{O}(V^2 E)$) or Hopcroft-Karp for bipartite graphs ($\mathcal{O}(E \sqrt{V})$), on a **tree**, the problem can be solved in linear $\mathcal{O}(n)$ time!

### Key Insight: The Greedy Leaf-First Property
Consider any leaf node $L$ attached to its parent $P$:
- The leaf $L$ is incident to only a single edge $(L, P)$.
- If $L$ is to be matched at all, it **must** be matched with $P$.
- Does matching $(L, P)$ ever hurt the global matching compared to matching $P$ with $P$'s parent or another child?
  - Matching $(L, P)$ consumes node $P$ and node $L$.
  - Matching $P$ with someone else also consumes node $P$, while leaving $L$ unused forever (since $L$ has no other neighbors).
  - Therefore, matching $L$ with $P$ is always at least as good as any alternative choice!

### Bottom-Up Greedy Strategy
Perform a post-order traversal (DFS):
- Visit all children of node $u$.
- If any child $v$ remains **unmatched**, and $u$ is currently **unmatched**, we greedily match edge $(u, v)$!
- Mark both $u$ and $v$ as matched, incrementing our matching count.
- Continue up to the root.

This greedy choice is guaranteed to produce a maximum matching in a single linear pass $\mathcal{O}(n)$.

---

## 3. Approach 1 — Maximum Bipartite Matching via Kuhn's Algorithm

Since every tree is bipartite (2-colorable), 2-color the vertices into $L$ and $R$ sets, orient edges $L \to R$, and run Kuhn's algorithm or Dinic's Max Flow.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(V \cdot E) = \mathcal{O}(n^2) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Tree Dynamic Programming

For each node $u$, define:
- $dp[u][0]$: maximum matching in the subtree of $u$ given that $u$ is **not matched** with any of its children.
  $$dp[u][0] = \sum_{v \in \text{children}(u)} \max(dp[v][0], dp[v][1])$$
- $dp[u][1]$: maximum matching in the subtree of $u$ given that $u$ is **matched** with some child $v^*$.
  $$dp[u][1] = 1 + dp[v^*][0] + \sum_{v \ne v^*} \max(dp[v][0], dp[v][1]) = dp[u][0] + \max_{v} \big(1 + dp[v][0] - \max(dp[v][0], dp[v][1])\big)$$

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n)$.
- **Space Complexity**: $\mathcal{O}(n)$.
- **Verdict**: Optimal and standard. However, the greedy post-order approach (Approach 3) accomplishes the exact same result with simpler code and smaller memory.

---

## 5. Approach 3 — Optimal CSES Solution (Greedy Post-Order DFS)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

int n;
vector<vector<int>> adj;
vector<bool> matched;
int matching_size = 0;

void dfs(int u, int p) {
    for (int v : adj[u]) {
        if (v == p) continue;
        dfs(v, u);
    }

    // After processing all children, if u is unmatched and p is valid and unmatched:
    if (p != 0 && !matched[u] && !matched[p]) {
        matched[u] = true;
        matched[p] = true;
        matching_size++;
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n)) return 0;

    adj.assign(n + 1, vector<int>());
    matched.assign(n + 1, false);

    for (int i = 0; i < n - 1; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    dfs(1, 0);

    cout << matching_size << '\n';

    return 0;
}
```

---

## 6. Correctness Proof

### Exchange Argument
Let $M_{\text{greedy}}$ be the matching produced by the greedy post-order algorithm, and let $M^*$ be an optimal matching that shares the maximum number of edges with $M_{\text{greedy}}$.

Suppose $M_{\text{greedy}} \ne M^*$.
Consider the first edge $e = (u, p)$ chosen by the greedy algorithm that is not in $M^*$:
1. In the bottom-up post-order order, when $e = (u, p)$ is chosen, all descendants in $u$'s subtree have already finalized their matching decisions.
2. Because $u$ is unmatched in $M_{\text{greedy}}$ prior to this step, $u$ has no edges to its children in $M_{\text{greedy}}$, and by induction on prior identical choices, $u$ cannot be matched with any child in $M^*$.
3. Thus, in $M^*$, node $u$ is either:
   - **Unmatched**: We can simply add edge $(u, p)$ to $M^*$. If $p$ was matched with some other node $w$ in $M^*$, replace $(p, w)$ with $(u, p)$. The size $|M^*|$ is preserved, but the number of shared edges with $M_{\text{greedy}}$ increases by 1, contradicting the maximality of shared edges.
   - **Matched with $p$**: Already shared!
4. Therefore, any optimal matching can be transformed into $M_{\text{greedy}}$ without ever decreasing the matching cardinality.
Hence, $|M_{\text{greedy}}| = |M^*|$, proving exact optimality.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5
1 2
1 3
3 4
3 5
```

Tree Structure:
```text
      1
    /   \
   2     3
       /   \
      4     5
```

### Execution Trace
- Root call: `dfs(1, 0)`.
- Visit child 2: `dfs(2, 1)`.
  - Node 2 is a leaf.
  - Check condition for node 2: $p = 1$, `!matched[2]` (true), `!matched[1]` (true).
  - Match edge `(2, 1)`. `matched[2] = true`, `matched[1] = true`, `matching_size = 1`.
- Visit child 3: `dfs(3, 1)`.
  - Visit child 4: `dfs(4, 3)`.
    - Node 4 is a leaf.
    - Check condition for 4: $p = 3$, `!matched[4]` (true), `!matched[3]` (true).
    - Match edge `(4, 3)`. `matched[4] = true`, `matched[3] = true`, `matching_size = 2`.
  - Visit child 5: `dfs(5, 3)`.
    - Node 5 is a leaf.
    - Check condition for 5: $p = 3$, `!matched[5]` (true), but `matched[3]` is already **true**!
    - Cannot match 5 with 3.
- Return to 3: $p = 1$, but both 3 and 1 are already matched.
- Return to 1: $p = 0$.

### Final Matching
Edges: `(1, 2)` and `(3, 4)`.
Total size: `2`.
Output: `2` (matches ground truth).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Star Graph**:
   Center node 1 connected to $n - 1$ leaves. The first leaf processed matches with 1. All other leaves find 1 already matched and remain single. Output: `1`.
2. **Path Graph ($P_n$)**:
   A chain of length $n$. The greedy post-order matches alternate edges from the deepest leaf up to the root, achieving $\lfloor n / 2 \rfloor$ matching edges.
3. **Single Node ($n = 1$)**:
   The loop for edges does not run. $p = 0$, so no matching is made. Output: `0`.
4. **Stack Depth**:
   For $n = 2 \cdot 10^5$, linear recursion depth uses $\approx 6.4\text{ MB}$, well within standard stack allocations.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How would you find the Minimum Vertex Cover of the tree?**
   By König's Theorem on bipartite graphs (which trees are), the size of the Minimum Vertex Cover equals the size of the Maximum Matching: $|\text{MVC}| = |\text{MaxMatching}|$.
2. **How would you find the Maximum Independent Set of the tree?**
   By Gallai's Identity, $|\text{MIS}| = n - |\text{MVC}| = n - |\text{MaxMatching}|$.
3. **What if edges have arbitrary real weights (Maximum Weight Matching on Trees)?**
   Greedy matching does not work for weighted trees. However, Tree DP generalises straightforwardly:
   $dp[u][1] = \max_v (w(u, v) + dp[v][0] + \sum_{k \ne v} \max(dp[k][0], dp[k][1]))$.
4. **How would you reconstruct the actual matched edges?**
   Keep a list of pairs `vector<pair<int, int>> edges` and whenever `matched[u] = matched[p] = true`, append `{u, p}`.
5. **Can this be solved using Hopcroft-Karp?**
   Yes, Hopcroft-Karp runs in $\mathcal{O}(E \sqrt{V}) = \mathcal{O}(n \sqrt{n}) \approx 9 \cdot 10^7$ operations, but is much more complex to implement than the 15-line greedy DFS.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**: $\mathcal{O}(n)$ — Single DFS visiting each node and edge once.
- **Space Complexity**: $\mathcal{O}(n)$ — Adjacency list and visited flags.

### Related CSES Problems
- [Subordinates](https://cses.fi/problemset/task/1674) — Tree post-order traversal
- [Tree Diameter](https://cses.fi/problemset/task/1131) — Extremal path on trees
- [School Dance](https://cses.fi/problemset/task/1696) — General bipartite matching via Kuhn's algorithm
