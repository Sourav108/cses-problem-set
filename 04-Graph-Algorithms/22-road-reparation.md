# Road Reparation

- **Category**: Graph Algorithms
- **CSES Task ID**: `1675`
- **CSES Problem Link**: [Road Reparation](https://cses.fi/problemset/task/1675)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ cities and $m$ bidirectional roads between them. Unfortunately, all roads are currently broken and unusable. Each road has an associated repair cost $c$.

Your task is to choose a subset of roads to repair such that there is a route between every pair of cities, while **minimizing the total repair cost**. If it is impossible to connect all cities together, print `IMPOSSIBLE`.

### Input Format
- The first line contains two integers $n$ and $m$: the number of cities and roads.
- The next $m$ lines each contain three integers $a$, $b$, and $c$: an undirected road connecting city $a$ and city $b$ with repair cost $c$.

### Output Format
- Print one integer: the minimum total repair cost, or `IMPOSSIBLE` if the cities cannot be connected.

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$
- $1 \le c \le 10^9$

With $V = 10^5, E = 2 \cdot 10^5$ and edge weights up to $10^9$, total cost can reach $10^{14}$ (requiring `long long`). Kruskal's algorithm with DSU executes in $\mathcal{O}(m \log m) \approx 0.08\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the quintessential **Minimum Spanning Tree (MST)** problem on an undirected weighted graph:
- We seek a connected subgraph connecting all $n$ vertices with minimum total edge weight.
- Any minimal connected subgraph on $n$ vertices is a tree with exactly $n - 1$ edges (a **Spanning Tree**).
- **Kruskal's Greedy Strategy**:
  1. Sort all $m$ edges in non-decreasing order of cost.
  2. Maintain a **Disjoint Set Union (DSU)** data structure tracking connected components.
  3. Iterate through edges in sorted order: for edge $(u, v, c)$:
     - If $\text{find}(u) \ne \text{find}(v)$, adding this edge does not create a cycle. Connect the components ($\text{union}(u, v)$), accumulate $c$ into total cost, and increment the edge count.
     - If $\text{find}(u) == \text{find}(v)$, this edge connects vertices already in the same component; adding it would create an unnecessary cycle with strictly higher cost, so discard it.
  4. If exactly $n - 1$ edges are accepted, all vertices are connected $\implies$ print total cost.
  5. If fewer than $n - 1$ edges were accepted, the graph was originally disconnected $\implies$ print `IMPOSSIBLE`.

---

## 3. Approach 1 — Naive Cycle Check per Edge

Sort edges by weight. For each edge, run a BFS/DFS to check if $u$ and $v$ are already connected before adding.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(m \cdot (n + m)) \approx 2 \cdot 10^5 \times 3 \cdot 10^5 \approx 6 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n + m)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Prim's Algorithm with Min-Heap

Start at vertex 1 and maintain a min-priority queue of cut edges. Repeatedly greedily extract the cheapest edge connecting an unvisited vertex to the growing MST.
- **Time Complexity**: $\mathcal{O}(m \log n)$.
- **Verdict**: Fully optimal. However, Kruskal's algorithm with DSU (Approach 3) is simpler to implement, faster due to flat array sorting, and handles connectivity checks directly.

---

## 5. Approach 3 — Optimal CSES Solution (Kruskal's Algorithm with DSU)

1. Store edges in `struct Edge { int u, v; long long w; }`.
2. Sort edges by weight in non-decreasing order using `std::sort`.
3. Implement DSU with:
   - **Path Compression**: `find(i)` recursively flattens the tree.
   - **Union by Rank/Size**: attach the smaller tree under the larger tree.
4. Iterate through the sorted edges:
   - If `dsu.unite(u, v)` succeeds:
     - `total_cost += w`
     - `edges_count++`
     - If `edges_count == n - 1`, break early.
5. If `edges_count == n - 1`, output `total_cost`.
6. Otherwise, output `IMPOSSIBLE`.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Edge {
    int u, v;
    long long w;

    bool operator<(const Edge& other) const {
        return w < other.w;
    }
};

struct DSU {
    vector<int> parent;
    vector<int> sz;

    DSU(int n) {
        parent.resize(n + 1);
        sz.assign(n + 1, 1);
        for (int i = 1; i <= n; ++i) {
            parent[i] = i;
        }
    }

    int find(int i) {
        if (parent[i] == i)
            return i;
        return parent[i] = find(parent[i]); // Path compression
    }

    bool unite(int i, int j) {
        int root_i = find(i);
        int root_j = find(j);
        if (root_i == root_j)
            return false;

        // Union by size
        if (sz[root_i] < sz[root_j])
            swap(root_i, root_j);

        parent[root_j] = root_i;
        sz[root_i] += sz[root_j];
        return true;
    }
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<Edge> edges(m);
    for (int i = 0; i < m; ++i) {
        cin >> edges[i].u >> edges[i].v >> edges[i].w;
    }

    sort(edges.begin(), edges.end());

    DSU dsu(n);
    long long total_cost = 0;
    int edges_count = 0;

    for (const auto& e : edges) {
        if (dsu.unite(e.u, e.v)) {
            total_cost += e.w;
            edges_count++;
            if (edges_count == n - 1) {
                break;
            }
        }
    }

    if (edges_count == n - 1) {
        cout << total_cost << '\n';
    } else {
        cout << "IMPOSSIBLE\n";
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(m \log m)$.
  - Sorting $m$ edges: $\mathcal{O}(m \log m) \approx 2 \cdot 10^5 \times 18 \approx 3.6 \cdot 10^6$ ops.
  - DSU operations: $\mathcal{O}(m \alpha(n))$, where $\alpha$ is the Inverse Ackermann function ($\alpha(n) \le 4$).
  - Total time is dominated by edge sorting: $\approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for the edge list and DSU arrays.

---

## 6. Correctness Proof

### The Cut Property of Minimum Spanning Trees
- **The Cut Property**:
  Let $S \subset V$ be any proper, non-empty subset of vertices, and let $(S, V \setminus S)$ be the cut separating $S$ from the remaining vertices. If an edge $e = (u, v)$ is a minimum-weight edge crossing this cut, then there exists a Minimum Spanning Tree of $G$ containing $e$.
- **Proof of Kruskal's Correctness**:
  1. Consider the moment Kruskal's algorithm considers edge $e = (u, v)$ where $\text{find}(u) \ne \text{find}(v)$.
  2. Let $C_u$ be the connected component of $u$ in the forest formed by previously accepted edges.
  3. Define the cut $(C_u, V \setminus C_u)$.
  4. Any edge crossing this cut connects a vertex in $C_u$ to a vertex outside $C_u$.
  5. Because Kruskal examines edges in strictly non-decreasing order of weight, and no previously examined edge connected $C_u$ to $V \setminus C_u$, edge $e$ is the **minimum-weight edge** among all edges crossing this cut in the entire graph.
  6. By the Cut Property, edge $e$ must belong to some Minimum Spanning Tree.
  7. Repeating this argument inductively for each of the $n - 1$ accepted edges guarantees that the resulting spanning tree has minimum total weight. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 5, m = 6$:
- Edges: $(1, 2, 3)$, $(2, 3, 5)$, $(2, 4, 2)$, $(3, 4, 8)$, $(1, 3, 7)$, $(4, 5, 4)$
- Sorted edges:
  1. $(2, 4, 2)$ $\to$ $\text{find}(2) \ne \text{find}(4) \implies$ Unite. Cost: 2, Count: 1.
  2. $(1, 2, 3)$ $\to$ $\text{find}(1) \ne \text{find}(2) \implies$ Unite. Cost: $2+3=5$, Count: 2.
  3. $(4, 5, 4)$ $\to$ $\text{find}(4) \ne \text{find}(5) \implies$ Unite. Cost: $5+4=9$, Count: 3.
  4. $(2, 3, 5)$ $\to$ $\text{find}(2) \ne \text{find}(3) \implies$ Unite. Cost: $9+5=14$, Count: 4.
  - Count reached $n - 1 = 4$. Break!
- Output: `14`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Disconnected Graph**:
   If the original graph is not connected, the DSU will finish with `edges_count < n - 1`. Correctly output `IMPOSSIBLE`.
2. **64-bit Integer Overflow**:
   With $n = 10^5$ and max edge cost $10^9$, total cost can reach $10^{14}$. Use `long long` for `total_cost`.
3. **Multi-Edges and Self-Loops**:
   - Self-loops: $u == v \implies \text{find}(u) == \text{find}(v)$, naturally ignored.
   - Multi-edges: the cheapest edge is examined first; any duplicate edges will connect already united vertices and will be safely skipped.
4. **Early Exit**:
   Breaking the loop as soon as `edges_count == n - 1` avoids unnecessary DSU operations over remaining high-cost edges.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **When is Prim's algorithm preferred over Kruskal's?**
   On dense graphs where $E \approx V^2$, Prim's algorithm with an adjacency matrix runs in $\mathcal{O}(V^2)$, whereas Kruskal runs in $\mathcal{O}(E \log E) = \mathcal{O}(V^2 \log V)$. On sparse graphs ($E \ll V^2$), Kruskal is faster and simpler.
2. **How can we find the Maximum Spanning Tree?**
   Sort edges in descending order instead of ascending order.
3. **How do you find the Second Minimum Spanning Tree?**
   Build the MST, then for every non-tree edge $(u, v, w)$, find the maximum weight edge on the MST path between $u$ and $v$ using binary lifting / LCA. The replacement cost is $w - \text{max\_edge}$. Take the minimum positive replacement cost.
4. **What is Borůvka's Algorithm?**
   Borůvka's algorithm finds MST by having every component simultaneously find and add its cheapest incident edge in $\mathcal{O}(\log V)$ rounds, running in $\mathcal{O}(E \log V)$. It is highly parallelizable.
5. **Is the MST always unique?**
   If all edge weights in the graph are distinct, the MST is provably unique. If duplicate edge weights exist, multiple MSTs may share the exact same minimum total weight.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, MST, Kruskal's Algorithm, DSU, Disjoint Set Union, Greedy
- **Complexity Summary**:
  - Time: $\mathcal{O}(m \log m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Road Construction](https://cses.fi/problemset/task/1676) — Dynamic connectivity with DSU
  - [Building Roads](https://cses.fi/problemset/task/1666) — Connected components
  - [Flight Routes Check](https://cses.fi/problemset/task/1682) — Strong connectivity check
