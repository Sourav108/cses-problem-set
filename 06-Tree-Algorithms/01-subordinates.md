# Subordinates

- **Category**: Tree Algorithms
- **CSES Task ID**: `1674`
- **CSES Problem Link**: [Subordinates](https://cses.fi/problemset/task/1674)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

A company has $n$ employees numbered $1, 2, \dots, n$, where employee 1 is the general director. Every employee $i \in [2, n]$ has a direct boss $p_i$ ($1 \le p_i < i$).

Your task is to calculate, for each employee $1, 2, \dots, n$, the total number of their **subordinates** (i.e., the total number of employees in their subtree in the corporate hierarchy, excluding the employee themselves).

### Input Format
- The first line contains an integer $n$: the number of employees.
- The second line contains $n - 1$ integers $p_2, p_3, \dots, p_n$: the direct boss of each employee from 2 to $n$.

### Output Format
- Print $n$ integers: for each employee $1, 2, \dots, n$, the number of subordinates.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le p_i \le n$ (and $p_i < i$ in the standard CSES generator, guaranteeing an acyclic tree hierarchy rooted at 1).

---

## 2. Intuition & Pattern Recognition

A corporate hierarchy where every employee except the director has exactly one boss is a **directed rooted tree** with root 1.
The number of subordinates of employee $u$ is the size of the subtree rooted at $u$ minus 1:
$$\text{sub}[u] = \text{size}(u) - 1$$

Because the subtree size satisfies the recursive relationship:
$$\text{size}(u) = 1 + \sum_{v \in \text{children}(u)} \text{size}(v)$$
we have:
$$\text{sub}[u] = \sum_{v \in \text{children}(u)} (\text{sub}[v] + 1)$$

This is the standard **Bottom-Up Subtree Aggregation**:
- Perform a single Depth-First Search (DFS) or post-order traversal starting at the root node 1.
- Alternatively, because $p_i < i$, employees can simply be processed in reverse topological order from $n$ down to 2 in $\mathcal{O}(n)$ time without recursion.

---

## 3. Approach 1 — Naive Traversal per Employee

For each employee $u \in [1, n]$, run a separate BFS/DFS from $u$ downward to count all reachable employees.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2) \approx (2 \cdot 10^5)^2 = 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Bottom-Up DP via Reverse Index Loop

Since the input guarantees $p_i < i$, the topological order is trivially $1, 2, \dots, n$.
- Initialize `sub[i] = 0` for all $i$.
- Loop $i$ from $n$ down to 2:
  $$\text{sub}[p_i] \mathrel{+}= (\text{sub}[i] + 1)$$
- **Time Complexity**: $\mathcal{O}(n)$.
- **Space Complexity**: $\mathcal{O}(n)$.
- Valid and optimal, but relies specifically on the condition $p_i < i$. Approach 3 implements general tree DFS, which works for arbitrary tree orientations.

---

## 5. Approach 3 — Optimal CSES Solution (Tree DFS Post-Order)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

int n;
vector<vector<int>> adj;
vector<int> sub;

void dfs(int u) {
    sub[u] = 0;
    for (int v : adj[u]) {
        dfs(v);
        sub[u] += sub[v] + 1;
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n)) return 0;

    adj.assign(n + 1, vector<int>());
    sub.assign(n + 1, 0);

    for (int i = 2; i <= n; ++i) {
        int boss;
        cin >> boss;
        adj[boss].push_back(i);
    }

    dfs(1);

    for (int i = 1; i <= n; ++i) {
        cout << sub[i] << (i == n ? "" : " ");
    }
    cout << '\n';

    return 0;
}
```

---

## 6. Correctness Proof

### Induction on Subtree Height
We prove by structural induction on the height $h(u)$ of the subtree rooted at $u$:
- **Base Case ($h(u) = 0$, leaf node)**:
  Node $u$ has no children (`adj[u]` is empty). The loop does not execute, leaving $\text{sub}[u] = 0$, which is exact since a leaf has 0 subordinates.
- **Inductive Step ($h(u) = k > 0$)**:
  Assume $\text{sub}[v]$ is correctly computed for all children $v \in \text{children}(u)$.
  By definition of a tree, the subtrees rooted at the children of $u$ are mutually disjoint and their union contains all descendants of $u$ except the children themselves.
  Each child $v$ contributes itself ($1$) plus all its subordinates ($\text{sub}[v]$).
  Summing $(\text{sub}[v] + 1)$ over all children $v$ counts every descendant in the subtree of $u$ exactly once.
  Thus, $\text{sub}[u]$ is exact for all nodes $u$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5
1 1 2 3
```
- Node 2 has boss 1
- Node 3 has boss 1
- Node 4 has boss 2
- Node 5 has boss 3

Hierarchy:
```text
      1
    /   \
   2     3
  /       \
 4         5
```

### DFS Trace
1. `dfs(1)` visits child 2.
2. `dfs(2)` visits child 4.
3. `dfs(4)`: leaf $\implies \text{sub}[4] = 0$. Return to 2.
4. `sub[2] += sub[4] + 1 = 0 + 1 = 1`.
5. `dfs(1)` visits child 3.
6. `dfs(3)` visits child 5.
7. `dfs(5)`: leaf $\implies \text{sub}[5] = 0$. Return to 3.
8. `sub[3] += sub[5] + 1 = 0 + 1 = 1`.
9. `sub[1] = (sub[2] + 1) + (sub[3] + 1) = 2 + 2 = 4`.

### Output
`4 1 1 0 0` — matches ground truth.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Star Graph (Director directly manages all $n - 1$ employees)**:
   Node 1 has $n - 1$ subordinates, while all other nodes have 0. DFS runs in $\mathcal{O}(n)$ time and recursion depth is 2.
2. **Line Graph (Degenerate chain of depth $n$)**:
   Recursion depth is $n = 2 \cdot 10^5$. On Linux/macOS, $2 \cdot 10^5$ stack frames easily fit within standard 512 MB memory limit (typical stack size limit $\ge 8\text{ MB}$, with each frame consuming $\approx 32$ bytes $\approx 6.4\text{ MB}$).
3. **Single Employee ($n = 1$)**:
   Outputs `0`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How would you solve this without recursion to prevent stack overflow on platforms with strict stack limits?**
   Use Kahn's algorithm / out-degree queue processing, or reverse topological iteration using `vector<int> order`.
2. **What if employees can have multiple managers (a general DAG)?**
   In a DAG, subtrees can overlap, making subtree size counting equivalent to counting reachable nodes (Transitive Closure / Reachability), which is $\mathcal{O}(V \cdot E / 64)$ via bitsets.
3. **How does subtree size relate to Heavy-Light Decomposition (HLD)?**
   HLD partitions edges into "heavy" (child with largest $\text{sub}[v]$) and "light" based directly on these precalculated subtree sizes.
4. **How would you maintain subtree sizes under dynamic edge additions/deletions?**
   Dynamic subtree sizes are maintained using **Link-Cut Trees** (with subtree aggregates) or **Euler Tour Trees** in $\mathcal{O}(\log n)$ time per operation.
5. **Can this be solved using Euler Tour flattening?**
   Yes. On an Euler tour where node $u$ enters at time $in[u]$ and exits at $out[u]$, the number of subordinates is simply $\frac{out[u] - in[u]}{2}$ or $out[u] - in[u]$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**: $\mathcal{O}(n)$ — Each vertex and edge is visited exactly once.
- **Space Complexity**: $\mathcal{O}(n)$ — Adjacency list and DFS recursion stack.

### Related CSES Problems
- [Tree Matching](https://cses.fi/problemset/task/1130) — Bottom-up greedy matching
- [Tree Diameter](https://cses.fi/problemset/task/1131) — Bottom-up height aggregation
- [Subtree Queries](https://cses.fi/problemset/task/1137) — Dynamic subtree updates using Euler tour flattening
