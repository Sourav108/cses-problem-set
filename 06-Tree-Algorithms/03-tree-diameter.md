# Tree Diameter

- **Category**: Tree Algorithms
- **CSES Task ID**: `1131`
- **CSES Problem Link**: [Tree Diameter](https://cses.fi/problemset/task/1131)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an unweighted tree consisting of $n$ nodes numbered $1, 2, \dots, n$ and $n - 1$ edges.

The **diameter** of a tree is defined as the maximum distance (number of edges) between any pair of nodes in the tree:
$$\text{Diameter} = \max_{1 \le u, v \le n} \text{dist}(u, v)$$

Your task is to determine the diameter of the tree.

### Input Format
- The first line contains an integer $n$: the number of nodes.
- The next $n - 1$ lines describe the edges: each line has two integers $a$ and $b$ ($1 \le a, b \le n$).

### Output Format
- Print one integer: the diameter of the tree.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le a, b \le n$

---

## 2. Intuition & Pattern Recognition

Computing all-pairs shortest paths on a tree with $n = 2 \cdot 10^5$ would require $\mathcal{O}(n^2)$ time, which is impossible.
Fortunately, trees possess a fundamental geometric property:

### The Two-BFS / Two-DFS Theorem
1. Start at **any arbitrary node** $s \in [1, n]$ (for example, node 1).
2. Find the node $u$ that is **farthest** from $s$:
   $$u = \arg\max_{x \in V} \text{dist}(s, x)$$
   Node $u$ is guaranteed to be one of the endpoints of an optimal diameter path!
3. Run a second traversal starting from $u$ to find the node $v$ that is **farthest** from $u$:
   $$v = \arg\max_{y \in V} \text{dist}(u, y)$$
4. The distance $\text{dist}(u, v)$ is the exact diameter of the tree!

This reduces the all-pairs problem to exactly **two linear Breadth-First Searches (BFS)**, running in $\mathcal{O}(n)$ time.

---

## 3. Approach 1 — BFS from Every Node

Run a BFS from every node $i \in [1, n]$ to find its eccentricity, taking the maximum over all nodes.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot (V + E)) = \mathcal{O}(n^2) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Single-Pass Tree Dynamic Programming

Root the tree arbitrarily at 1. For each node $u$, compute its depth height:
$$h[u] = 1 + \max_{v \in \text{children}(u)} h[v]$$
The longest path whose highest point (LCA) is node $u$ is formed by concatenating the paths down its two deepest distinct child branches:
$$\text{path}(u) = \text{deepest}_1 + \text{deepest}_2$$
The tree diameter is $\max_{u \in V} \text{path}(u)$.
- **Time Complexity**: $\mathcal{O}(n)$ in a single DFS.
- **Space Complexity**: $\mathcal{O}(n)$.
- **Trade-off**: Requires recursive DFS. Approach 3 (Two BFS passes) uses iterative queues, avoiding stack overflow risk.

---

## 5. Approach 3 — Optimal CSES Solution (Two-BFS Algorithm)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

int n;
vector<vector<int>> adj;

// Returns {farthest_node, max_distance} from start_node
pair<int, int> bfs(int start_node) {
    vector<int> dist(n + 1, -1);
    queue<int> q;

    dist[start_node] = 0;
    q.push(start_node);

    int farthest = start_node;
    int max_d = 0;

    while (!q.empty()) {
        int u = q.front();
        q.pop();

        if (dist[u] > max_d) {
            max_d = dist[u];
            farthest = u;
        }

        for (int v : adj[u]) {
            if (dist[v] == -1) {
                dist[v] = dist[u] + 1;
                q.push(v);
            }
        }
    }

    return {farthest, max_d};
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n)) return 0;

    adj.assign(n + 1, vector<int>());

    for (int i = 0; i < n - 1; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    // Step 1: Find the farthest node 'u' from arbitrary node 1
    auto [u, _] = bfs(1);

    // Step 2: Find the farthest node 'v' from 'u'
    auto [v, diameter] = bfs(u);

    cout << diameter << '\n';

    return 0;
}
```

---

## 6. Correctness Proof

### Theorem (Farthest Node is an Extremity of the Diameter)
Let $T$ be a tree, and let $s$ be an arbitrary vertex. Let $u$ be any vertex maximizing $\text{dist}(s, u)$. Then $u$ is an endpoint of some diameter of $T$.

*Proof*:
Let $A - B$ be a diameter path in $T$ of maximum length $D = \text{dist}(A, B)$.
Consider the simple path from $s$ to $u$:
- **Case 1: The path from $s$ to $u$ intersects path $A - B$ at some node $X$**.
  Then:
  $$\text{dist}(s, u) = \text{dist}(s, X) + \text{dist}(X, u)$$
  $$\text{dist}(s, A) = \text{dist}(s, X) + \text{dist}(X, A)$$
  $$\text{dist}(s, B) = \text{dist}(s, X) + \text{dist}(X, B)$$
  Because $u$ maximizes distance from $s$, $\text{dist}(s, u) \ge \max(\text{dist}(s, A), \text{dist}(s, B))$.
  Subtracting $\text{dist}(s, X)$ yields:
  $$\text{dist}(X, u) \ge \max(\text{dist}(X, A), \text{dist}(X, B))$$
  Without loss of generality, assume $\text{dist}(X, A) \ge \text{dist}(X, B)$. Then:
  $$\text{dist}(u, A) = \text{dist}(X, u) + \text{dist}(X, A) \ge \text{dist}(X, B) + \text{dist}(X, A) = \text{dist}(A, B) = D$$
  Since $D$ is the maximum distance in the tree, $\text{dist}(u, A)$ must equal $D$.
  Thus, $u - A$ is also a diameter, and $u$ is an endpoint.

- **Case 2: The path from $s$ to $u$ does not intersect path $A - B$**.
  Let $X$ be the node on $A - B$ closest to $s$, and let $Y$ be the junction node where the path from $s$ to $u$ branches off.
  By triangle inequality and tree uniqueness of paths, replacing an endpoint with $u$ cannot decrease the length, yielding $\text{dist}(u, A) \ge D$ or $\text{dist}(u, B) \ge D$.
  Hence $u$ is always a diameter endpoint.

Running the second BFS from $u$ explores all distances from $u$ and finds $\max_y \text{dist}(u, y) = D$. $\blacksquare$

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

Tree:
```text
      1
    /   \
   2     3
       /   \
      4     5
```

### BFS Pass 1 (from node 1)
- Queue initialization: `q = [1]`, `dist[1] = 0`.
- Visit 2: `dist[2] = 1`.
- Visit 3: `dist[3] = 1`.
- Visit 4: `dist[4] = 2`.
- Visit 5: `dist[5] = 2`.
- Max distance is 2, attained at node 4 (or 5). Let $u = 4$.

### BFS Pass 2 (from node 4)
- Queue initialization: `q = [4]`, `dist[4] = 0`.
- Visit 3: `dist[3] = 1`.
- Visit 1: `dist[1] = 2`.
- Visit 5: `dist[5] = 2`.
- Visit 2: `dist[2] = 3`.
- Max distance is 3, attained at node 2 ($v = 2$).
- Diameter $= 3$ (path: $4 - 3 - 1 - 2$).

### Output
`3` — matches ground truth.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Single Node Tree ($n = 1$)**:
   $n = 1$, no edges. BFS from 1 returns distance 0. Output: `0`.
2. **Two Nodes ($n = 2$)**:
   $1 - 2$. Diameter is 1.
3. **Star Graph**:
   All leaves are at distance 1 from the center. Diameter is 2.
4. **Line Graph ($P_n$)**:
   Diameter is $n - 1$.
5. **No Recursion Overhead**:
   Iterative BFS avoids stack overflow on deep trees of depth $2 \cdot 10^5$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How would you find the center of the tree (Jordan Center)?**
   Trace the diameter path $u \to v$ using a `parent` array during the second BFS. The center is the middle vertex (or two vertices) along this path at distance $\lfloor D / 2 \rfloor$.
2. **What if edge weights are arbitrary positive numbers?**
   The two-BFS / two-Dijkstra algorithm works identically for trees with non-negative edge weights (replacing BFS queue with Dijkstra priority queue or weighted DFS).
3. **Does two-BFS work if edges have negative weights?**
   No! Negative edge weights invalidate the property that the farthest node from any starting node is a diameter endpoint.
4. **How would you count the total number of diameter paths?**
   From the tree center(s), run a DFS to compute the number of leaves achieving maximum distance $\lfloor D / 2 \rfloor$ across each branch.
5. **How does diameter relate to tree radius?**
   The radius $R$ of a tree satisfies $R = \lceil D / 2 \rceil$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**: $\mathcal{O}(V + E) = \mathcal{O}(n)$ — Two BFS traversals, each visiting every node and edge once.
- **Space Complexity**: $\mathcal{O}(n)$ — Adjacency list, queue, and distance vector.

### Related CSES Problems
- [Tree Distances I](https://cses.fi/problemset/task/1132) — Maximum distance from every node
- [Tree Distances II](https://cses.fi/problemset/task/1133) — Sum of distances from every node
- [Finding a Centroid](https://cses.fi/problemset/task/2079) — Centroid computation on trees
