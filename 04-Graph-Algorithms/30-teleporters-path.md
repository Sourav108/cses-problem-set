# Teleporters Path

- **Category**: Graph Algorithms
- **CSES Task ID**: `1693`
- **CSES Problem Link**: [Teleporters Path](https://cses.fi/problemset/task/1693)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

A game has $n$ levels numbered $1, 2, \dots, n$ and $m$ directed teleporters between them. Each teleporter connects level $a$ to level $b$.

Your task is to find a route that begins at **level 1**, ends at **level $n$**, and uses **every teleporter exactly once**. Multiple teleporters may connect the same pair of levels (a directed multigraph).

If such a route (a **Directed Eulerian Trail**) exists, print the sequence of levels visited. Otherwise, print `IMPOSSIBLE`.

### Input Format
- The first line contains two integers $n$ and $m$: the number of levels and teleporters.
- The next $m$ lines each contain two integers $a$ and $b$: a directed teleporter from level $a$ to level $b$.

### Output Format
- If a valid route exists:
  - Print $m + 1$ integers: the sequence of levels visited, starting with $1$ and ending with $n$.
- If no valid route exists:
  - Print `IMPOSSIBLE`.

### Numerical Constraints
- $2 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$

With $V = 10^5$ and $E = 2 \cdot 10^5$, Hierholzer's Algorithm on a directed graph runs in linear time $\mathcal{O}(n + m) \approx 0.08\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the classic **Directed Eulerian Trail Problem** from a designated source $1$ to destination $n$:
- An **Eulerian trail** in a directed graph is a directed walk that visits every directed edge exactly once.
- **Euler's Theorem for Directed Trails (from $s$ to $t$ with $s \ne t$)**:
  A directed multigraph admits an Eulerian trail from $s$ to $t$ if and only if:
  1. The start vertex $s = 1$ has exactly one more outgoing edge than incoming:
     $$\text{out\_degree}[1] - \text{in\_degree}[1] == 1$$
  2. The end vertex $t = n$ has exactly one more incoming edge than outgoing:
     $$\text{in\_degree}[n] - \text{out\_degree}[n] == 1$$
  3. Every other vertex $v \notin \{1, n\}$ has balanced in-degree and out-degree:
     $$\text{in\_degree}[v] == \text{out\_degree}[v]$$
  4. All edges belong to the same connected component reachable from vertex $1$.
- **Hierholzer's Algorithm**:
  Using an edge cursor `head[u]` for each vertex $u$, we push vertices onto a DFS stack. When a vertex has exhausted all its outgoing edges, we pop it into the result list. Reversing the list gives the Eulerian trail from $1$ to $n$.

---

## 3. Approach 1 — Naive Backtracking / DFS Path Search

Explore all $m!$ edge orderings using recursive backtracking.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(m!)$ worst case.
- **Space Complexity**: $\mathcal{O}(m)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Adding a Virtual Edge $(n \to 1)$ to form an Eulerian Circuit

Add a temporary directed edge $n \to 1$, making all degrees balanced ($\text{in} == \text{out}$ everywhere). Then run standard Eulerian circuit detection and cut the circuit at edge $n \to 1$.
- **Verdict**: Valid, but running Hierholzer directly from $1$ without adding virtual edges is simpler and avoids post-processing edge cuts.

---

## 5. Approach 3 — Optimal CSES Solution (Directed Hierholzer's Algorithm)

1. Compute `in_degree` and `out_degree` for all vertices.
2. Verify Eulerian trail degree conditions:
   - $\text{out\_degree}[1] - \text{in\_degree}[1] == 1$
   - $\text{in\_degree}[n] - \text{out\_degree}[n] == 1$
   - For all $i \in \{2, \dots, n-1\}$: $\text{in\_degree}[i] == \text{out\_degree}[i]$
   - If any condition fails, print `IMPOSSIBLE` and exit.
3. Maintain cursor array `head[n+1]` initialized to 0.
4. Run stack-based Hierholzer:
   - Push $1$ to `st`.
   - While `st` is non-empty:
     - $u = \text{st.back}()$.
     - If `head[u] < adj[u].size()`:
       - $v = \text{adj}[u][\text{head}[u]++]$.
       - Push $v$ to `st`.
     - Else:
       - Pop $u$ from `st` and push $u$ to `path`.
5. Verify that all edges were visited:
   - `path.size() == m + 1`
   - Reversal of `path` starts at $1$ and ends at $n$.
   - If conditions not met, print `IMPOSSIBLE`.
6. Output the reversed `path`.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<vector<int>> adj(n + 1);
    vector<int> in_degree(n + 1, 0);
    vector<int> out_degree(n + 1, 0);

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        out_degree[u]++;
        in_degree[v]++;
    }

    // Check degree balance conditions for an Eulerian path from 1 to n
    if (out_degree[1] - in_degree[1] != 1 || in_degree[n] - out_degree[n] != 1) {
        cout << "IMPOSSIBLE\n";
        return 0;
    }

    for (int i = 2; i < n; ++i) {
        if (in_degree[i] != out_degree[i]) {
            cout << "IMPOSSIBLE\n";
            return 0;
        }
    }

    // Hierholzer's Algorithm for directed graph
    vector<int> head(n + 1, 0);
    vector<int> st;
    vector<int> path;

    st.push_back(1);

    while (!st.empty()) {
        int u = st.back();

        if (head[u] < (int)adj[u].size()) {
            int v = adj[u][head[u]++];
            st.push_back(v);
        } else {
            path.push_back(u);
            st.pop_back();
        }
    }

    if ((int)path.size() != m + 1) {
        cout << "IMPOSSIBLE\n";
        return 0;
    }

    reverse(path.begin(), path.end());

    if (path.front() != 1 || path.back() != n) {
        cout << "IMPOSSIBLE\n";
        return 0;
    }

    for (int i = 0; i < (int)path.size(); ++i) {
        cout << path[i] << (i + 1 == (int)path.size() ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$.
  - Degree checks: $\mathcal{O}(n)$.
  - Hierholzer's algorithm: each directed edge is extracted exactly once via `head[u]++`.
  - Path reversal: $\mathcal{O}(m)$.
  - Total time: $\approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for adjacency list, degrees, stack, and path vector.

---

## 6. Correctness Proof

### Directed Eulerian Trail Characterization
- **Necessity**:
  Every time the trail enters an intermediate vertex $v \in \{2, \dots, n-1\}$, it must leave via a different directed edge. Thus, $\text{in}(v) = \text{out}(v)$.
  The start vertex 1 is departed once more than it is entered, so $\text{out}(1) - \text{in}(1) = 1$.
  The end vertex $n$ is entered once more than it is departed, so $\text{in}(n) - \text{out}(n) = 1$.
- **Sufficiency & Hierholzer's Invariant**:
  1. Adding a dummy directed edge $n \to 1$ satisfies $\text{in}(v) = \text{out}(v)$ everywhere, making the graph Eulerian.
  2. Because all non-sink vertices have available outgoing edges whenever they are entered, a greedy traversal starting at 1 cannot get stuck at any vertex other than $n$.
  3. When $n$ is reached, all remaining edges form directed Eulerian circuits attached to the primary trail.
  4. The post-order stack unwind automatically splices these sub-circuits into the main path in reverse.
  5. Reversing the finalized list yields a valid continuous trail starting at 1 and ending at $n$.
  6. The size check $|\text{path}| = m + 1$ verifies that no disconnected edge components were left unvisited. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 5, m = 6$:
- Teleporters: $(1, 2), (2, 3), (3, 4), (4, 2), (2, 5), (5, 5)$? No, $(1, 2), (2, 3), (3, 1), (1, 4), (4, 5)$
- Degrees:
  - $1$: in 1, out 2 $\implies \text{out} - \text{in} = 1$.
  - $5$: in 1, out 0 $\implies \text{in} - \text{out} = 1$.
  - $2$: in 1, out 1.
  - $3$: in 1, out 1.
  - $4$: in 1, out 1.
- All degree conditions satisfied!
- Start at 1. `st = [1]`.
  - Follow $1 \to 2 \to 3 \to 1$: `st = [1, 2, 3, 1]`.
  - Follow $1 \to 4 \to 5$: `st = [1, 2, 3, 1, 4, 5]`.
  - At 5: out-degree exhausted $\implies$ pop 5 to `path = [5]`.
  - At 4: out-degree exhausted $\implies$ pop 4 to `path = [5, 4]`.
  - At 1: out-degree exhausted $\implies$ pop 1 to `path = [5, 4, 1]`.
  - Continue popping: $3, 2, 1$.
  - `path = [5, 4, 1, 3, 2, 1]`.
- Reverse `path`: $[1, 2, 3, 1, 4, 5]$.
- Length: $6 = m + 1$. Starts at 1, ends at 5. Valid!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Disconnected Components with Teleporters**:
   If some teleporters form a closed cycle disconnected from vertex 1, the degree check might still pass, but `path.size() != m + 1`. The size check correctly rejects this with `IMPOSSIBLE`.
2. **$1$ Cannot Reach $n$**:
   If level $n$ is in an unreachable component, degree checks will fail or the trail will get stuck before reaching $n$.
3. **Self-Loops ($u \to u$)**:
   A teleporter from $u$ to $u$ contributes $+1$ to both `in_degree[u]` and `out_degree[u]`. Handled seamlessly.
4. **Multiple Teleporters between Same Pair**:
   `adj[u]` stores duplicate destinations naturally; `head[u]++` consumes them one by one.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the problem asked for an Eulerian Circuit instead of Trail?**
   In an Eulerian circuit, start and end are identical, requiring $\text{in\_degree}[u] == \text{out\_degree}[u]$ for ALL vertices, as in CSES Mail Delivery.
2. **How does Directed Eulerian Path compare to Directed Hamiltonian Path?**
   Eulerian path visits all edges (polynomial $\mathcal{O}(V + E)$). Hamiltonian path visits all vertices (NP-complete).
3. **What is BEST Theorem?**
   The BEST theorem gives the exact number of Eulerian circuits in a directed graph: $N = t_w(G) \cdot \prod_{v \in V} (\text{deg}_{in}(v) - 1)!$, where $t_w(G)$ is the number of directed spanning trees rooted at an arbitrary vertex $w$, computable via the Matrix Tree Theorem.
4. **How do we find an Eulerian path in a mixed graph (having both directed and undirected edges)?**
   Direct the undirected edges such that degree balance is achieved at every vertex, solvable via **Max Flow** with lower and upper capacity bounds.
5. **How do we reconstruct the path in lexicographically smallest order?**
   Sort `adj[u]` in ascending order of neighbor IDs before running Hierholzer's algorithm.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Eulerian Trail, Hierholzer's Algorithm, Directed Graph, In/Out-Degree
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Mail Delivery](https://cses.fi/problemset/task/1691) — Undirected Eulerian circuit
  - [De Bruijn Sequence](https://cses.fi/problemset/task/1692) — Eulerian trail in De Bruijn graph
  - [Flight Routes](https://cses.fi/problemset/task/1196) — $k$ shortest paths
