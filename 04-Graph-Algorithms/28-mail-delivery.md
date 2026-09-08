# Mail Delivery

- **Category**: Graph Algorithms
- **CSES Task ID**: `1691`
- **CSES Problem Link**: [Mail Delivery](https://cses.fi/problemset/task/1691)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

A postman delivers mail to a city with $n$ street crossings and $m$ streets connecting them. Each street is bidirectional and connects two crossings.

The postman starts at **crossing 1**, must traverse **every street exactly once**, and return to **crossing 1** at the end of the route. Multiple streets may connect the same pair of crossings (a multigraph).

Your task is to determine whether such a route (an **Eulerian Circuit**) exists. If it does, print the sequence of crossings on the route; otherwise, print `IMPOSSIBLE`.

### Input Format
- The first line contains two integers $n$ and $m$: the number of crossings and streets.
- The next $m$ lines each contain two integers $a$ and $b$: a street connecting crossing $a$ and crossing $b$.

### Output Format
- If an Eulerian circuit exists:
  - Print $m + 1$ integers: the crossings visited along the circuit, starting and ending at $1$.
- If no valid circuit exists:
  - Print `IMPOSSIBLE`.

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$

With $V = 10^5$ and $E = 2 \cdot 10^5$, Hierholzer's Algorithm with an edge-iterator array operates in linear time $\mathcal{O}(n + m) \approx 0.08\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the classic **Eulerian Circuit Problem** on an undirected multigraph:
- An **Eulerian circuit** is a closed walk that traverses every edge of the graph exactly once.
- **Euler's Theorem for Undirected Graphs (1736)**:
  An undirected graph contains an Eulerian circuit if and only if:
  1. Every vertex has an **even degree** ($\text{deg}(v) \equiv 0 \pmod 2$).
  2. All edges belong to the **same connected component** (which must contain the starting vertex 1).
- **Hierholzer's Algorithm (Iterative with Stack)**:
  1. If any vertex has an odd degree, an Eulerian circuit is impossible $\implies$ print `IMPOSSIBLE`.
  2. Start at crossing 1 using an explicit DFS stack.
  3. While the stack is non-empty:
     - Let $u$ be the top of the stack.
     - If $u$ has any unused incident edge $e = (u, v)$:
       - Mark edge $e$ as used.
       - Push $v$ onto the stack.
     - If all incident edges of $u$ have been exhausted:
       - Pop $u$ from the stack and append $u$ to the final path.
  4. If the resulting path has length $m + 1$, all edges were successfully traversed. Otherwise, the graph had disconnected components containing edges $\implies$ print `IMPOSSIBLE`.

---

## 3. Approach 1 — Naive Fleury's Algorithm

At each step, choose an edge that is not a bridge (unless no other edge exists).
- **Time Complexity**: $\mathcal{O}(E^2)$ because testing if an edge is a bridge requires BFS/DFS bridge detection at every step.
- **CSES Verdict**: TLE immediately ($m = 2 \cdot 10^5 \implies 4 \cdot 10^{10}$ ops).

---

## 4. Approach 2 — Recursive Hierholzer's Algorithm

Recursively find cycles and splice them together.
- **Drawback**: Recursion depth can reach $m = 2 \cdot 10^5$, which risks stack overflow on deep paths.
- **Verdict**: The iterative stack-based Hierholzer implementation (Approach 3) is strictly non-recursive, branch-free, and handles multigraphs cleanly.

---

## 5. Approach 3 — Optimal CSES Solution (Iterative Hierholzer with Edge Iterator)

1. Check that $\text{degree}[u] \pmod 2 == 0$ for all $1 \le u \le n$. If any vertex has odd degree, output `IMPOSSIBLE`.
2. Represent each undirected edge with a unique index $0 \le \text{id} < m$.
   Store `adj[u]` as pairs `{v, edge_id}`.
3. Maintain a boolean array `used_edge[m]` initialized to `false`.
4. Maintain an edge cursor array `head[n+1]` initialized to $0$:
   `head[u]` points to the next candidate edge in `adj[u]`, ensuring no edge is scanned more than once.
5. Maintain a stack `st` and vector `path`:
   - Push $1$ to `st`.
   - While `st` is not empty:
     - $u = \text{st.back}()$.
     - Advance `head[u]` past already used edges.
     - If `head[u] < adj[u].size()`:
       - Extract edge `{v, edge_id} = adj[u][head[u]++]`.
       - Mark `used_edge[edge_id] = true`.
       - Push $v$ onto `st`.
     - Else:
       - All incident edges of $u$ are consumed.
       - Pop $u$ from `st` and push $u$ to `path`.
6. If `path.size() != m + 1`, output `IMPOSSIBLE`.
7. Otherwise, print the vertices in `path`.

```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<vector<pair<int, int>>> adj(n + 1);
    vector<int> degree(n + 1, 0);

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back({v, i});
        adj[v].push_back({u, i});
        degree[u]++;
        degree[v]++;
    }

    // Condition 1: Every vertex must have an even degree
    for (int i = 1; i <= n; ++i) {
        if (degree[i] % 2 != 0) {
            cout << "IMPOSSIBLE\n";
            return 0;
        }
    }

    vector<bool> used(m, false);
    vector<int> head(n + 1, 0);
    vector<int> st;
    vector<int> path;

    st.push_back(1);

    while (!st.empty()) {
        int u = st.back();

        // Advance head pointer past used edges
        while (head[u] < (int)adj[u].size() && used[adj[u][head[u]].second]) {
            head[u]++;
        }

        if (head[u] < (int)adj[u].size()) {
            auto [v, edge_id] = adj[u][head[u]++];
            used[edge_id] = true;
            st.push_back(v);
        } else {
            path.push_back(u);
            st.pop_back();
        }
    }

    // Condition 2: All m edges must be traversed
    if ((int)path.size() != m + 1) {
        cout << "IMPOSSIBLE\n";
    } else {
        for (int i = 0; i < (int)path.size(); ++i) {
            cout << path[i] << (i + 1 == (int)path.size() ? '\n' : ' ');
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$.
  - Parity check: $\mathcal{O}(n)$.
  - Each edge index $0 \dots m - 1$ is examined at most twice (once from each endpoint) thanks to the monotonically increasing `head[u]` pointer.
  - Stack pushes and pops: each vertex enters the path once per incident edge.
  - Total time: $\approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for adjacency list, `used` flags, and `head` cursors.

---

## 6. Correctness Proof

### Euler's Theorem & Hierholzer's Invariant
- **Degree Parity Necessity**:
  Every time a trail enters an intermediate vertex $v$, it must leave via a different edge. Thus, each visit consumes 2 incident edges. To start and end at crossing 1 without leaving any edge unvisited, every vertex must have an even degree.
- **Hierholzer's Loop Invariant**:
  1. At each step, the stack represents a simple trail starting at 1 and ending at $u = \text{st.back}()$.
  2. Because all degrees are even, whenever the trail reaches a vertex $u \ne 1$, $u$ has an odd number of remaining unused edges, guaranteeing that an unused exit edge always exists.
  3. The trail can only get stuck when it returns to 1, completing a cycle.
  4. When vertex $u$ has exhausted all incident edges, it is appended to `path`. Any secondary cycles branching from $u$ have already been fully traversed and spliced into the path before $u$ was finalized.
  5. Thus, the sequence of popped vertices forms a continuous Eulerian circuit covering all edges in the connected component of 1.
  6. If $|\text{path}| = m + 1$, all $m$ edges were included. If $|\text{path}| < m + 1$, disconnected edges exist, correctly triggering `IMPOSSIBLE`. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 6, m = 8$:
- Edges: $(1, 2), (2, 3), (3, 1)$ (triangle 1-2-3) and $(1, 4), (4, 5), (5, 6), (6, 4), (4, 1)$
- Degrees: $1: 4, 2: 2, 3: 2, 4: 4, 5: 2, 6: 2$. All even!

1. Start at 1. `st = [1]`.
2. Follow $(1, 2) \to (2, 3) \to (3, 1)$: `st = [1, 2, 3, 1]`.
3. At 1, edge $(1, 4)$ is available $\implies \text{st} = [1, 2, 3, 1, 4]$.
4. Follow $(4, 5) \to (5, 6) \to (6, 4) \to (4, 1)$:
   `st = [1, 2, 3, 1, 4, 5, 6, 4, 1]`.
5. At 1, all incident edges used $\implies$ pop 1 into `path = [1]`.
6. At 4, all incident edges used $\implies$ pop 4 into `path = [1, 4]`.
7. Pop remaining: $6, 5, 4, 1, 3, 2, 1$.
8. `path` has length $8 + 1 = 9$ crossings.
- Circuit: `1 2 3 1 4 6 5 4 1`. Valid Eulerian circuit!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Disconnected Isolated Crossings with No Streets**:
   Crossings with degree 0 do not prevent an Eulerian circuit, as long as all streets belong to the component of crossing 1. The check `path.size() == m + 1` correctly ignores isolated crossings.
2. **Disconnected Streets**:
   If some streets form a separate cycle disjoint from crossing 1, degrees will be even, but the path size will be $< m + 1$, correctly outputting `IMPOSSIBLE`.
3. **Multiple Parallel Streets & Self-Loops**:
   - Each street has a distinct `edge_id \in [0, m-1]`.
   - Parallel streets are treated as distinct edges.
   - Self-loops $u \leftrightarrow u$ add 2 to degree and are processed naturally.
4. **Pointer Optimization**:
   Without the `head[u]` cursor, scanning `adj[u]` from the beginning on every pop takes $\mathcal{O}(m \cdot \text{deg}(u)) = \mathcal{O}(m^2)$ worst-case time (TLE). The `head[u]` pointer ensures each edge is examined only once per direction.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the problem asked for an Eulerian Trail (path starting and ending at different vertices)?**
   An Eulerian trail exists if and only if exactly two vertices have odd degree (the start and end vertices), and all edges are in a single component.
2. **How does Eulerian Path differ from Hamiltonian Path?**
   An Eulerian path visits every **edge** once (polynomial time $\mathcal{O}(V + E)$). A Hamiltonian path visits every **vertex** once (NP-complete).
3. **Can Hierholzer's algorithm work on directed graphs?**
   Yes! In directed graphs, the condition is $\text{in\_degree}[u] == \text{out\_degree}[u]$ for all vertices, solved via the exact same stack traversal.
4. **What is the Chinese Postman Problem (Route Inspection Problem)?**
   If some vertices have odd degrees, an Eulerian circuit does not exist. The Chinese Postman Problem finds the minimum total distance to traverse all edges by duplicating edges along shortest paths between odd-degree vertices using minimum-weight matching.
5. **How do we ensure the circuit is printed in lexicographically smallest order?**
   Sort `adj[u]` in ascending order of neighbor vertex ID before running Hierholzer's algorithm.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Eulerian Circuit, Hierholzer's Algorithm, Multigraph, Degree Parity
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Teleporters Path](https://cses.fi/problemset/task/1693) — Directed Eulerian path
  - [De Bruijn Sequence](https://cses.fi/problemset/task/1692) — Eulerian trail on De Bruijn graph
  - [Round Trip](https://cses.fi/problemset/task/1669) — Finding simple cycles
