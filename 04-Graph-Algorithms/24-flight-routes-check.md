# Flight Routes Check

- **Category**: Graph Algorithms
- **CSES Task ID**: `1682`
- **CSES Problem Link**: [Flight Routes Check](https://cses.fi/problemset/task/1682)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ cities and $m$ directed flight connections between them. Your task is to check whether it is possible to travel between **any pair of cities** (i.e. for every pair of cities $a$ and $b$, there is a directed route from $a$ to $b$).

If it is possible to travel between any pair of cities, print `YES`. If it is not possible, print `NO` and two cities $a$ and $b$ such that there is no route from city $a$ to city $b$.

### Input Format
- The first line contains two integers $n$ and $m$: the number of cities and flights.
- The next $m$ lines each contain two integers $a$ and $b$: a directed flight from city $a$ to city $b$.

### Output Format
- If the graph is strongly connected, print `YES`.
- If not, print `NO` on the first line, and two cities $a$ and $b$ on the second line such that city $b$ cannot be reached from city $a$.

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$

With $V = 10^5$ and $E = 2 \cdot 10^5$, two linear BFS/DFS passes operate in $\mathcal{O}(n + m) \approx 0.04\text{s}$.

---

## 2. Intuition & Pattern Recognition

A directed graph where every vertex can reach every other vertex is called **Strongly Connected**:
- **Strong Connectivity Hub Lemma**:
  Let $s$ be any arbitrary fixed vertex (say, city $1$).
  The graph $G$ is strongly connected **if and only if**:
  1. City $1$ can reach every city $v \in \{1, \dots, n\}$ in $G$.
  2. Every city $u \in \{1, \dots, n\}$ can reach city $1$ in $G$.
- **Proof of Hub Lemma**:
  - $(\implies)$ If $G$ is strongly connected, every pair can reach each other, so conditions 1 and 2 trivially hold.
  - $(\impliedby)$ Suppose conditions 1 and 2 hold. Let $a$ and $b$ be any arbitrary pair of cities.
    By condition 2, $a$ can reach $1$: $a \rightsquigarrow 1$.
    By condition 1, $1$ can reach $b$: $1 \rightsquigarrow b$.
    Concatenating these two paths gives:
    $$a \rightsquigarrow 1 \rightsquigarrow b$$
    Thus, $a$ can reach $b$ for all $a, b \in V$. Hence $G$ is strongly connected!
- **Constructing the Counterexample**:
  - **Test 1**: Run BFS from city $1$ on the original graph.
    If some city $v$ is not reached, then city $1$ cannot reach $v$. Output `NO` with pair `1 v`.
  - **Test 2**: Run BFS from city $1$ on the **reversed graph** $G^R$ (transposed graph where every edge $u \to v$ is reversed to $v \to u$).
    Reaching $u$ from $1$ in $G^R$ is equivalent to $u$ reaching $1$ in $G$.
    If some city $u$ is not reached in $G^R$, then $u$ cannot reach city $1$ in $G$. Output `NO` with pair `u 1`.
  - If both tests reach all $n$ cities, output `YES`.

---

## 3. Approach 1 — Naive All-Pairs Reachability

Run BFS from all $n$ cities to verify if every city can reach every other city.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot (n + m)) \approx 10^5 \times 3 \cdot 10^5 \approx 3 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n + m)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Tarjan's or Kosaraju's Full SCC Algorithm

Run Kosaraju's or Tarjan's algorithm to partition the graph into Strongly Connected Components (SCCs).
- If number of SCCs is 1, output `YES`.
- If number of SCCs is $> 1$, condense the SCC DAG and find two components $C_1$ and $C_2$ such that $C_1$ cannot reach $C_2$.
- **Verdict**: Optimal $\mathcal{O}(n + m)$, but condensing the SCC DAG to extract an unreachable pair requires extra logic. The Two-Pass BFS Hub method (Approach 3) directly identifies a concrete invalid pair in under 40 lines of clean code.

---

## 5. Approach 3 — Optimal CSES Solution (Two-Pass BFS Hub)

1. Build original graph `adj` and reversed graph `rev_adj`.
2. **Pass 1 (Forward Reachability from 1)**:
   - Run BFS from vertex 1 on `adj`.
   - Check if any vertex $i \in \{1, \dots, n\}$ is unvisited.
   - If an unvisited vertex $v$ is found:
     - Print `NO`
     - Print `1 v`
     - Exit immediately.
3. **Pass 2 (Backward Reachability to 1)**:
   - Run BFS from vertex 1 on `rev_adj`.
   - Check if any vertex $i \in \{1, \dots, n\}$ is unvisited.
   - If an unvisited vertex $u$ is found:
     - Print `NO`
     - Print `u 1`
     - Exit immediately.
4. If both passes visited all $n$ vertices, print `YES`.

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

void bfs(int start, const vector<vector<int>>& graph, vector<bool>& visited) {
    queue<int> q;
    visited[start] = true;
    q.push(start);

    while (!q.empty()) {
        int u = q.front();
        q.pop();

        for (int v : graph[u]) {
            if (!visited[v]) {
                visited[v] = true;
                q.push(v);
            }
        }
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<vector<int>> adj(n + 1);
    vector<vector<int>> rev_adj(n + 1);

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        rev_adj[v].push_back(u);
    }

    // Pass 1: Can city 1 reach all other cities?
    vector<bool> visited1(n + 1, false);
    bfs(1, adj, visited1);

    for (int i = 1; i <= n; ++i) {
        if (!visited1[i]) {
            cout << "NO\n";
            cout << 1 << ' ' << i << '\n';
            return 0;
        }
    }

    // Pass 2: Can all other cities reach city 1?
    vector<bool> visited2(n + 1, false);
    bfs(1, rev_adj, visited2);

    for (int i = 1; i <= n; ++i) {
        if (!visited2[i]) {
            cout << "NO\n";
            cout << i << ' ' << 1 << '\n';
            return 0;
        }
    }

    cout << "YES\n";

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$.
  - Pass 1 BFS: visits each vertex and edge at most once: $\mathcal{O}(n + m)$.
  - Pass 2 BFS: visits each vertex and reversed edge at most once: $\mathcal{O}(n + m)$.
  - Total time: $\approx 0.04\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for the two adjacency lists and visited flags.

---

## 6. Correctness Proof

### The Hub Lemma Equivalence
- **Theorem**: A directed graph $G = (V, E)$ is strongly connected if and only if for an arbitrary fixed vertex $s \in V$:
  $$\forall v \in V, \; s \rightsquigarrow v \quad \text{and} \quad \forall u \in V, \; u \rightsquigarrow s$$
- **Proof**:
  1. *Necessity*: If $G$ is strongly connected, then by definition, for every pair $x, y \in V$, there exists a path $x \rightsquigarrow y$. Setting $x = s$ gives $s \rightsquigarrow v$, and setting $y = s$ gives $u \rightsquigarrow s$.
  2. *Sufficiency*: Suppose $s \rightsquigarrow v$ for all $v \in V$ and $u \rightsquigarrow s$ for all $u \in V$.
     Let $a, b \in V$ be any two vertices.
     Since $a \rightsquigarrow s$ exists and $s \rightsquigarrow b$ exists, concatenating the two paths yields a walk from $a$ to $b$.
     Since this holds for every choice of $a$ and $b$, $G$ is strongly connected.
  3. *Reversed Graph Equivalence*: A path from $u$ to $s$ in $G$ exists if and only if a path from $s$ to $u$ exists in $G^R$, which is precisely what Pass 2 computes.
  4. *Counterexample Validity*:
     If Pass 1 fails at $v$, then no path from $1$ to $v$ exists in $G$, so $(1, v)$ is an invalid pair.
     If Pass 2 fails at $u$, then no path from $u$ to $1$ exists in $G$, so $(u, 1)$ is an invalid pair. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 3$:
- Flights: $(1, 2), (2, 3), (3, 1)$ (cycle $1 \to 2 \to 3 \to 1$) and $(4, 1)$ (node 4 points into 1, but has no incoming flights).

1. **Pass 1 (Forward from 1)**:
   - BFS from 1 on `adj`:
     - $1 \to 2 \to 3 \to 1$.
     - `visited1 = [F, T, T, T, F]`.
   - Node 4 is unvisited (`!visited1[4]`).
   - City 1 cannot reach city 4!
   - Output: `NO`, followed by `1 4`.
   - Terminate early. Correct!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Disconnected Isolated Vertex**:
   If city $k$ has degree 0, it will not be reached in Pass 1 (if $k \ne 1$) or Pass 2 (if $k = 1$), immediately outputting `NO`.
2. **Sink Vertex (Out-degree 0)**:
   A sink vertex $v$ can be reached from 1, but cannot reach 1. Pass 1 succeeds, Pass 2 fails at $v$, outputting `v 1`.
3. **Source Vertex (In-degree 0)**:
   A source vertex $u$ cannot be reached from 1. Pass 1 fails at $u$, outputting `1 u`.
4. **Graph is a Simple Directed Cycle**:
   Both Pass 1 and Pass 2 visit all vertices, correctly outputting `YES`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Why is BFS preferred over DFS here?**
   Both work, but BFS is iterative and immune to stack overflow on long directed paths (e.g. depth $10^5$).
2. **How does this relate to Kosaraju's Algorithm?**
   Kosaraju's algorithm uses the exact same pair of graphs ($G$ and $G^R$) to find all SCCs by running DFS on $G$ to obtain a finishing order, then DFS on $G^R$.
3. **What is the minimum number of edges needed to make any directed graph strongly connected?**
   Condense the graph into its DAG of SCCs. Let $S$ be the number of source components (in-degree 0) and $T$ be the number of sink components (out-degree 0). The minimum number of directed edges to add is $\max(S, T)$ (if $|SCC| > 1$).
4. **How do we check if an UNDIRECTED graph is 2-edge-connected (biconnected)?**
   An undirected graph has a strongly connected orientation if and only if it is 2-edge-connected (contains no bridges), by **Robbins' Theorem**.
5. **Can this algorithm choose any vertex other than 1 as the hub?**
   Yes! Any vertex $s \in \{1, \dots, n\}$ serves as a valid hub. If the chosen hub cannot reach all nodes or cannot be reached by all nodes, the graph is not strongly connected.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Strong Connectivity, BFS, Kosaraju's Principle, Transposed Graph
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Planets and Kingdoms](https://cses.fi/problemset/task/1683) — Full Strongly Connected Components
  - [Giant Pizza](https://cses.fi/problemset/task/1684) — 2-SAT using SCCs
  - [Coin Collector](https://cses.fi/problemset/task/1686) — Condensation DAG and DP
