# Round Trip II

- **Category**: Graph Algorithms
- **CSES Task ID**: `1678`
- **CSES Problem Link**: [Round Trip II](https://cses.fi/problemset/task/1678)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Byteland has $n$ cities and $m$ directed flight connections between them. Your task is to find a **round trip** (a directed cycle): a route that begins and ends in the same city and visits at least two distinct cities along the way. All intermediate cities on the cycle must be distinct.

If multiple valid round trips exist, you may output any of them. If no directed cycle exists in the graph, print `IMPOSSIBLE`.

### Input Format
- The first line contains two integers $n$ and $m$: the number of cities and flights.
- The next $m$ lines each contain two integers $a$ and $b$: a directed flight from city $a$ to city $b$.

### Output Format
- If a round trip exists:
  - First line: print an integer $k$, the number of cities on the round trip ($k \ge 3$, since start and end are identical).
  - Second line: print the $k$ cities in the order they are visited.
- If no round trip exists:
  - Print `IMPOSSIBLE`.

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$

With $V = 10^5$ and $E = 2 \cdot 10^5$, an $\mathcal{O}(n + m)$ 3-state DFS cycle detection algorithm runs in $\approx 0.05\text{s}$.

---

## 2. Intuition & Pattern Recognition

Unlike undirected graphs (where an edge to an already visited vertex other than the immediate parent indicates a cycle), in **directed graphs** edges fall into four distinct categories during Depth-First Search (DFS):
1. **Tree Edges**: Leading to an unvisited vertex (`state == 0`).
2. **Back-Edges**: Leading to an ancestor currently on the active recursion stack (`state == 1`).
3. **Forward Edges**: Leading to a previously visited descendant (`state == 2`).
4. **Cross Edges**: Leading to a previously completed vertex in another branch (`state == 2`).

Only a **back-edge** forms a directed cycle:
- If we are at vertex $u$ and observe an outgoing edge $u \to v$ where `state[v] == 1`, vertex $v$ is an active ancestor of $u$.
- There exists a directed path in the DFS tree from $v$ down to $u$:
  $$v \rightsquigarrow u$$
- The directed edge $u \to v$ closes the loop, creating a directed cycle:
  $$v \rightsquigarrow u \to v$$
- We can trace this directed cycle by walking backwards from $u$ to $v$ along stored parent pointers.

---

## 3. Approach 1 — Naive Path History / Brute Force

For each vertex $s \in \{1, \dots, n\}$, maintain a `visited` set for the current path and perform recursive backtracking to search for a loop back to $s$.

### Complexity Analysis
- **Time Complexity**: Exponential $\mathcal{O}(2^n)$ in the worst case.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Kahn's Algorithm (Topological Sort Pruning)

Compute the in-degree of all vertices. Repeatedly remove vertices with in-degree 0. The remaining vertices belong to directed cycles.
- **Drawback**: Kahn's algorithm isolates the set of vertices containing cycles, but does not directly reconstruct an individual simple cycle or its order.
- **Verdict**: 3-state DFS (Approach 3) both detects the cycle and provides immediate parent pointers for path extraction in a single pass.

---

## 5. Approach 3 — Optimal CSES Solution (3-Color DFS)

We color each vertex with one of three states:
- `0` (**WHITE**): Unvisited.
- `1` (**GRAY**): Visiting (currently on the active recursion stack).
- `2` (**BLACK**): Visited (all descendants fully explored).

Algorithm:
1. Initialize `state[1...n] = 0` and `parent[1...n] = 0`.
2. For each vertex $i \in \{1, \dots, n\}$, if `state[i] == 0`, invoke `dfs(i)`.
3. In `dfs(u)`:
   - Set `state[u] = 1`.
   - For each outgoing neighbor $v \in \text{adj}[u]$:
     - If `state[v] == 0`:
       - `parent[v] = u`
       - If `dfs(v)` returns `true`, return `true`.
     - Else if `state[v] == 1`:
       - **Back-edge found!**
       - Set `cycle_start = v`, `cycle_end = u`.
       - Return `true`.
   - Set `state[u] = 2` (mark finished).
   - Return `false`.
4. If a cycle is detected:
   - Reconstruct the cycle: start at `cycle_end` ($u$), follow `parent` pointers back to `cycle_start` ($v$).
   - Reverse the sequence and append `cycle_start` to close the loop.
   - Print cycle size and vertices.
5. If DFS finishes over all vertices without finding any back-edge, output `IMPOSSIBLE`.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int n, m;
vector<vector<int>> adj;
vector<int> state; // 0: unvisited, 1: visiting, 2: visited
vector<int> parent_node;
int cycle_start = -1;
int cycle_end = -1;

bool dfs(int u) {
    state[u] = 1;

    for (int v : adj[u]) {
        if (state[v] == 0) {
            parent_node[v] = u;
            if (dfs(v)) return true;
        } else if (state[v] == 1) {
            cycle_start = v;
            cycle_end = u;
            return true;
        }
    }

    state[u] = 2;
    return false;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> m)) return 0;

    adj.assign(n + 1, vector<int>());
    state.assign(n + 1, 0);
    parent_node.assign(n + 1, 0);

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
    }

    for (int i = 1; i <= n; ++i) {
        if (state[i] == 0) {
            if (dfs(i)) break;
        }
    }

    if (cycle_start == -1) {
        cout << "IMPOSSIBLE\n";
    } else {
        vector<int> cycle;
        cycle.push_back(cycle_start);
        for (int curr = cycle_end; curr != cycle_start; curr = parent_node[curr]) {
            cycle.push_back(curr);
        }
        cycle.push_back(cycle_start);
        reverse(cycle.begin(), cycle.end());

        cout << cycle.size() << '\n';
        for (size_t i = 0; i < cycle.size(); ++i) {
            cout << cycle[i] << (i + 1 == cycle.size() ? '\n' : ' ');
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$.
  Every vertex and edge is traversed at most once during DFS before cycle detection terminates early.
- **Space Complexity**: $\mathcal{O}(n + m)$ for the adjacency list, plus $\mathcal{O}(n)$ for `state`, `parent_node`, and recursion stack.

---

## 6. Correctness Proof

### The Directed Cycle Theorem
- **Theorem**: A directed graph $G = (V, E)$ contains a directed cycle if and only if a depth-first search of $G$ yields a back-edge.
- **Proof**:
  1. $(\impliedby)$ Suppose DFS discovers an edge $u \to v$ where `state[v] == 1`.
     By definition of the algorithm, `state[v] == 1` means $v$ is an ancestor of $u$ in the active DFS tree branch.
     Therefore, there is a tree path $v \rightsquigarrow u$.
     Adding the back-edge $u \to v$ forms a directed cycle $v \rightsquigarrow u \to v$.
  2. $(\implies)$ Suppose $G$ contains a directed cycle $C = (v_1, v_2, \dots, v_k, v_1)$.
     Let $v_i$ be the first vertex of $C$ discovered by DFS.
     At the time $v_i$ is discovered, `state[v_i]` becomes $1$.
     All other vertices in $C$ are reachable from $v_i$ via a white path (unvisited vertices in $C$).
     By the White-Path Theorem of DFS, all vertices in $C$ become descendants of $v_i$ in the DFS tree before $v_i$ finishes (`state[v_i]` becomes $2$).
     In particular, the predecessor of $v_i$ in $C$, say $v_{i-1}$, must be explored while $v_i$ is still in state $1$.
     When edge $v_{i-1} \to v_i$ is examined, $v_i$ is still in state $1$.
     Thus, edge $(v_{i-1}, v_i)$ is classified as a back-edge. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 5$:
- Edges: $(1, 3), (2, 1), (2, 4), (3, 2), (3, 4)$

1. Start DFS at node 1:
   - `state[1] = 1`
2. Explore neighbor 3:
   - `state[3] = 1`, `parent[3] = 1`
3. Explore neighbor 2 from 3:
   - `state[2] = 1`, `parent[2] = 3`
4. From 2, explore neighbor 1:
   - `state[1] == 1` $\implies$ **Back-edge $(2 \to 1)$ detected!**
   - `cycle_start = 1`, `cycle_end = 2`. Return `true`.
5. Reconstruct cycle:
   - Push `cycle_start` ($1$).
   - Trace backwards from `cycle_end` ($2$):
     - `curr = 2`, push $2$. Next `curr = parent[2] = 3`.
     - `curr = 3`, push $3$. Next `curr = parent[3] = 1 == cycle_start`. Stop loop.
   - Push `cycle_start` ($1$) to close.
   - Vector: $[1, 2, 3, 1]$.
   - Reverse: $[1, 3, 2, 1]$.
   - Check edges: $1 \to 3$, $3 \to 2$, $2 \to 1$. A valid directed cycle of length 4!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Cycle of Length 2 (Bidirectional Directed Edges)**:
   In directed graphs, $u \to v$ and $v \to u$ is a completely valid directed 2-cycle. Unlike Round Trip I (undirected), we do NOT ignore edges back to parent; if $v \to u$ exists and $u$ is in state 1, it forms a valid directed cycle of length 3 ($u \to v \to u$).
2. **Multiple Disconnected Components / Cross Edges**:
   A cross edge points to a node with `state == 2`. Treating `state == 2` as a cycle would cause false positives. The 3-state classification strictly avoids this.
3. **Directed Acyclic Graphs (DAG)**:
   If the graph is a DAG, all nodes transition to state 2 without encountering any back-edge. The code correctly outputs `IMPOSSIBLE`.
4. **Graph with Multiple Separate Cycles**:
   The problem allows returning any valid cycle. The early `return true` halts DFS immediately upon finding the first back-edge, optimizing runtime.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Why does 2-state (visited / unvisited) fail for directed cycle detection?**
   In a diamond DAG ($1 \to 2 \to 4$ and $1 \to 3 \to 4$), node 4 will be visited twice. A 2-state DFS would misclassify the cross edge $3 \to 4$ as a cycle. The third state (GRAY / currently on stack) distinguishes ancestors from previously finished subtrees.
2. **How does this connect to Topological Sort?**
   A directed graph has a topological sort if and only if it has no directed cycles. The vertices sorted in decreasing order of DFS exit times (when transitioning from state 1 to state 2) produce a topological sort if no back-edges exist.
3. **Can Tarjan's Strongly Connected Components (SCC) algorithm find cycles?**
   Yes. Any non-trivial SCC (with $> 1$ vertex, or 1 vertex with a self-loop) contains at least one directed cycle.
4. **How do we find the shortest directed cycle (minimum girth)?**
   Run unweighted BFS from every vertex $u \in V$. The first time a path returns to $u$, it forms the shortest simple cycle through $u$. Total time is $\mathcal{O}(V(V + E))$.
5. **What is the maximum recursion depth?**
   In the worst case (a single directed line of $10^5$ vertices), recursion depth is $10^5$. On CSES Linux with 512 MB stack limit, this uses $\approx 4\text{ MB}$, executing safely without stack overflow.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Directed Cycle, 3-State DFS, Back-Edge, Path Reconstruction
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Round Trip](https://cses.fi/problemset/task/1669) — Undirected cycle detection
  - [Course Schedule](https://cses.fi/problemset/task/1679) — Topological sort / DAG verification
  - [Flight Routes Check](https://cses.fi/problemset/task/1682) — Strongly Connected Components
