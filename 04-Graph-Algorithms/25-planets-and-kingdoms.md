# Planets and Kingdoms

- **Category**: Graph Algorithms
- **CSES Task ID**: `1683`
- **CSES Problem Link**: [Planets and Kingdoms](https://cses.fi/problemset/task/1683)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

A game has $n$ planets numbered $1, 2, \dots, n$ and $m$ teleporters between them. Each teleporter is directed from a planet $a$ to a planet $b$.

Two planets $a$ and $b$ belong to the same **kingdom** if and only if there is a route from planet $a$ to planet $b$ **and** a route from planet $b$ to planet $a$.

Your task is to divide the planets into kingdoms such that each kingdom is a maximal set of mutually reachable planets (i.e. a **Strongly Connected Component**, SCC).

### Input Format
- The first line contains two integers $n$ and $m$: the number of planets and teleporters.
- The next $m$ lines each contain two integers $a$ and $b$: a directed teleporter from planet $a$ to planet $b$.

### Output Format
- On the first line, print an integer $k$: the number of kingdoms.
- On the second line, print $n$ integers: for each planet $1, 2, \dots, n$, the kingdom identifier ($1, 2, \dots, k$).

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$

With $V = 10^5$ and $E = 2 \cdot 10^5$, an $\mathcal{O}(n + m)$ Strongly Connected Components algorithm (Kosaraju or Tarjan) executes in $\approx 0.08\text{s}$.

---

## 2. Intuition & Pattern Recognition

A kingdom is precisely a **Strongly Connected Component (SCC)** of a directed graph:
- In any directed graph, mutual reachability is an equivalence relation:
  - Reflexive: $u \rightsquigarrow u$.
  - Symmetric: $u \rightsquigarrow v \iff v \rightsquigarrow u$.
  - Transitive: $u \rightsquigarrow v$ and $v \rightsquigarrow w \implies u \rightsquigarrow w$.
- Equivalence classes under this relation partition the vertex set into disjoint SCCs.
- **Kosaraju-Sharir Two-Pass Algorithm**:
  1. **Pass 1 (Topological Exit Times on $G$)**:
     Run DFS on the original graph $G$. As vertices finish exploring their outgoing edges (post-order exit), push them onto a list `order`.
     *Key Property*: In the condensed DAG of SCCs, the component with the highest exit time is a **source component** (has no incoming edges from other components).
  2. **Pass 2 (Component Extraction on $G^R$)**:
     Reverse all edges to obtain the transposed graph $G^R$.
     In $G^R$, the source components of $G$ become **sink components** (they have no outgoing edges to other components).
     Pop vertices from `order` in reverse (highest exit time first).
     Launching a DFS on $G^R$ from this vertex will traverse its entire SCC and **cannot escape** to any other component because there are no outgoing edges in $G^R$!
     All vertices reached belong to the exact same kingdom.

---

## 3. Approach 1 — Naive All-Pairs Reachability

Compute transitive closure using Floyd-Warshall or $N$ BFS passes. Two nodes $u, v$ share a kingdom if $\text{reach}[u][v] \land \text{reach}[v][u]$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot (n + m)) \approx 10^5 \times 3 \cdot 10^5 \approx 3 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n^2)$ matrix.
- **CSES Verdict**: TLE and MLE immediately.

---

## 4. Approach 2 — Tarjan's SCC Algorithm

Maintain `discovery_time[u]`, `low_link[u]`, and a DFS stack. When `discovery_time[u] == low_link[u]`, pop the stack to extract the SCC.
- **Verdict**: Optimal $\mathcal{O}(n + m)$, runs in a single DFS pass.
- Both Tarjan's and Kosaraju's are optimal. Kosaraju's algorithm uses two simple DFS passes with standard post-order traversal and is exceptionally straightforward to implement without low-link pointers.

---

## 5. Approach 3 — Optimal CSES Solution (Kosaraju's Algorithm)

1. Build `adj` for $G$ and `rev_adj` for $G^R$.
2. Maintain boolean `visited1[n+1]` and vector `order`.
3. For $i = 1 \dots n$: if `!visited1[i]`, call `dfs1(i)`.
   In `dfs1(u)`:
   - Mark `visited1[u] = true`.
   - For $v \in \text{adj}[u]$: if `!visited1[v]`, `dfs1(v)`.
   - `order.push_back(u)`.
4. Maintain `visited2[n+1]` and `kingdom[n+1]`.
5. Reverse iterate `order` from back to front:
   - For node $u$: if `!visited2[u]`:
     - `k++`
     - Call `dfs2(u, k)`.
   In `dfs2(u, comp_id)`:
   - Mark `visited2[u] = true`.
   - `kingdom[u] = comp_id`.
   - For $v \in \text{rev\_adj}[u]$: if `!visited2[v]`, `dfs2(v, comp_id)`.
6. Output $k$, then `kingdom[1], ..., kingdom[n]`.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int n, m;
vector<vector<int>> adj;
vector<vector<int>> rev_adj;
vector<bool> visited;
vector<int> order;
vector<int> kingdom;
int k = 0;

void dfs1(int u) {
    visited[u] = true;
    for (int v : adj[u]) {
        if (!visited[v]) {
            dfs1(v);
        }
    }
    order.push_back(u);
}

void dfs2(int u, int comp_id) {
    visited[u] = true;
    kingdom[u] = comp_id;
    for (int v : rev_adj[u]) {
        if (!visited[v]) {
            dfs2(v, comp_id);
        }
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> m)) return 0;

    adj.assign(n + 1, vector<int>());
    rev_adj.assign(n + 1, vector<int>());

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        rev_adj[v].push_back(u);
    }

    // Step 1: Forward DFS to record exit order
    visited.assign(n + 1, false);
    for (int i = 1; i <= n; ++i) {
        if (!visited[i]) {
            dfs1(i);
        }
    }

    // Step 2: Backward DFS in reverse exit order
    visited.assign(n + 1, false);
    kingdom.assign(n + 1, 0);

    for (int i = n - 1; i >= 0; --i) {
        int u = order[i];
        if (!visited[u]) {
            k++;
            dfs2(u, k);
        }
    }

    // Step 3: Print result
    cout << k << '\n';
    for (int i = 1; i <= n; ++i) {
        cout << kingdom[i] << (i == n ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$.
  - Pass 1 DFS traverses every vertex and edge once: $\mathcal{O}(n + m)$.
  - Pass 2 DFS on transposed graph traverses every vertex and reversed edge once: $\mathcal{O}(n + m)$.
  - Total time: $\approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for the two adjacency lists, `order` stack, and `kingdom` labels.

---

## 6. Correctness Proof

### The Topological Component Invariant of Kosaraju's Algorithm
- **Lemma 1**: Let $C$ and $C'$ be two distinct strongly connected components in $G$. If there is a directed edge from a vertex in $C$ to a vertex in $C'$, then the maximum DFS finish time in $C$ is strictly greater than the maximum DFS finish time in $C'$:
  $$\max_{u \in C} f[u] > \max_{v \in C'} f[v]$$
  - *Proof*:
    - Case 1: If DFS reaches $C$ before $C'$, DFS will reach $C$ and then follow the edge to $C'$. All vertices in $C'$ will be visited and finished before the call to the first vertex in $C$ completes. Thus $\max f[C] > \max f[C']$.
    - Case 2: If DFS reaches $C'$ before $C'$, because the condensation graph is a DAG, there is no path from $C'$ back to $C$. Thus the DFS in $C'$ will finish completely without visiting $C$. Later, DFS will visit $C$, so $f[C] > f[C']$.
- **Lemma 2**: When processing vertices in descending order of finish time in $G^R$, the DFS from a vertex in component $C$ visits exactly component $C$.
  - *Proof*: In $G^R$, edges between components are reversed: any edge between $C$ and $C'$ now points from $C'$ to $C$. Since $C$ has the highest finish time among all remaining unvisited components, there are no outgoing edges in $G^R$ from $C$ to any unvisited component. Therefore, the DFS on $G^R$ starting in $C$ cannot escape $C$, extracting precisely the vertices of $C$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 5, m = 6$:
- Edges: $(1, 2), (2, 3), (3, 1)$ (cycle 1), $(3, 4)$, $(4, 5), (5, 4)$ (cycle 2).
- Condensed graph: $C_1 = \{1, 2, 3\} \to C_2 = \{4, 5\}$.

1. **Pass 1 (DFS on $G$)**:
   - Start DFS at 1: $1 \to 2 \to 3 \to 4 \to 5$.
   - $5$ finishes $\implies \text{order} = [5]$.
   - $4$ finishes $\implies \text{order} = [5, 4]$.
   - $3$ finishes $\implies \text{order} = [5, 4, 3]$.
   - $2$ finishes $\implies \text{order} = [5, 4, 3, 2]$.
   - $1$ finishes $\implies \text{order} = [5, 4, 3, 2, 1]$.
2. **Pass 2 (Reverse order on $G^R$)**:
   - Reverse `order`: $[1, 2, 3, 4, 5]$.
   - First unvisited: $1$.
     - Increment $k = 1$.
     - `dfs2(1, 1)` on $G^R$: traverses $1 \leftarrow 3 \leftarrow 2 \leftarrow 1$.
     - Visits $\{1, 2, 3\}$, sets `kingdom = 1`.
     - Edge $4 \to 3$ in $G$ becomes $3 \to 4$ reversed? No, $3 \to 4$ in $G$ becomes $4 \to 3$ in $G^R$. From 3, there is no outgoing edge to 4 in $G^R$! DFS terminates.
   - Next unvisited: $4$.
     - Increment $k = 2$.
     - `dfs2(4, 2)` on $G^R$: traverses $4 \leftrightarrow 5$.
     - Visits $\{4, 5\}$, sets `kingdom = 2`.
3. Total kingdoms: $k = 2$.
   `kingdom = [1, 1, 1, 2, 2]`. Correct!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **DAG (All Kingdoms are Singletons)**:
   If the graph contains no cycles, every planet is its own kingdom. $k = n$, each with a unique ID.
2. **Entire Graph is One Single SCC**:
   If the entire graph is strongly connected, $k = 1$, and all planets receive ID 1.
3. **Disconnected Components**:
   Handled automatically: the outer loops iterate through all $i \in \{1, \dots, n\}$, ensuring all disconnected subgraphs are explored.
4. **Valid Kingdom Identifiers**:
   The problem accepts any numbering from $1$ to $k$. Kosaraju sequentially assigns $1, 2, \dots, k$, strictly satisfying the requirements.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How do we build the Condensation Graph (SCC DAG)?**
   After finding all SCCs, iterate through every original edge $(u, v) \in E$. If $\text{kingdom}[u] \ne \text{kingdom}[v]$, add a directed edge $\text{kingdom}[u] \to \text{kingdom}[v]$ into the condensed graph (removing duplicates with `std::sort` or `std::set`).
2. **How does SCC solve the 2-SAT problem?**
   Convert 2-SAT clauses $(x \lor y)$ into implication edges $(\neg x \to y)$ and $(\neg y \to x)$. A 2-SAT instance is satisfiable if and only if no variable $x$ and its negation $\neg x$ belong to the same SCC.
3. **What is the difference between Tarjan's and Kosaraju's algorithms?**
   Tarjan's algorithm uses 1 DFS pass and an explicit stack, using `discovery_time` and `low_link` arrays. Kosaraju's algorithm uses 2 DFS passes and a transposed graph. Both are $\mathcal{O}(V + E)$.
4. **How do we find SCCs in a dynamic graph with edge additions?**
   Incremental SCC maintenance can be solved using Italian et al.'s algorithm in $\mathcal{O}(m \sqrt{n})$ or randomized algorithms.
5. **How does this connect to maximum revenue collection on graphs?**
   CSES Coin Collector (`CSES 1686`) condenses SCCs and sums all coins inside each component into a single condensed node, reducing the problem to finding the longest path on a DAG.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Strongly Connected Components, Kosaraju's Algorithm, DFS, Transposed Graph
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Flight Routes Check](https://cses.fi/problemset/task/1682) — Checking if graph has 1 SCC
  - [Giant Pizza](https://cses.fi/problemset/task/1684) — 2-SAT using SCC decomposition
  - [Coin Collector](https://cses.fi/problemset/task/1686) — DAG Dynamic Programming on condensed SCCs
