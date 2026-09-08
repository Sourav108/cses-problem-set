# Flight Routes

- **Category**: Graph Algorithms
- **CSES Task ID**: `1196`
- **CSES Problem Link**: [Flight Routes](https://cses.fi/problemset/task/1196)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ cities and $m$ flight connections between them. Each flight connects city $a$ to city $b$ with price $c$. Your task is to find the price of the **$k$ cheapest routes** from city 1 to city $n$.

A route may visit the same city or edge multiple times. Output the $k$ route prices in non-decreasing order.

### Input Format
- The first line contains three integers $n$, $m$, and $k$: the number of cities, flights, and requested routes.
- The next $m$ lines each contain three integers $a$, $b$, and $c$: a flight from city $a$ to city $b$ with price $c$.

### Output Format
- Print $k$ integers: the prices of the $k$ cheapest routes from city 1 to city $n$, sorted in non-decreasing order.

### Numerical Constraints
- $2 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le k \le 10$
- $1 \le a, b \le n$
- $1 \le c \le 10^9$

With $k \le 10$, a $k$-expanded Dijkstra priority queue processes at most $k \cdot m$ edge relaxations, finishing in $\approx 0.15\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the classic **$k$-Shortest Paths Problem** on a directed graph with non-negative edge weights:
- In standard Dijkstra's algorithm ($k = 1$), each vertex $u$ is finalized the first time it is popped from the min-priority queue.
- **Generalization to $k$ Shortest Paths**:
  Because all edge weights are positive ($c \ge 1$), any walk that reaches vertex $u$ can only be extended by positive costs.
  Therefore, the sequence of extraction times of vertex $u$ from a global min-priority queue generates the shortest paths to $u$ in **strictly non-decreasing order**:
  - The 1st time $u$ is popped: 1st shortest path to $u$.
  - The 2nd time $u$ is popped: 2nd shortest path to $u$.
  - $\dots$
  - The $k$-th time $u$ is popped: $k$-th shortest path to $u$.
- Any subsequent extractions ($> k$) for vertex $u$ can never contribute to any of the $k$ shortest paths to destination $n$, so they can be safely pruned.
- We maintain a counter `count[u]`: the number of times vertex $u$ has been popped from the priority queue.
- Whenever $u$ is popped:
  - If `count[u] >= k`, ignore it (`continue`).
  - Otherwise, increment `count[u]++`.
  - If $u == n$, append the distance to our results list. If we have collected $k$ results for $n$, we can stop early!
  - Relax all outgoing edges $(u \to v, w)$ and push `{d + w, v}` into the min-priority queue.

---

## 3. Approach 1 — Naive: Yen's Algorithm / Eppstein's Algorithm

Yen's algorithm finds loopless $k$-shortest paths in $\mathcal{O}(k \cdot V(E + V \log V))$.
- For $V = 10^5$, Yen's algorithm would take $\approx 10 \times 10^5 \times (2 \cdot 10^5) \approx 2 \cdot 10^{11}$ operations $\implies$ TLE.
- Furthermore, the CSES problem statement explicitly **allows repeated vertices and edges**, so Eppstein's or loopless Yen's is unnecessary.

---

## 4. Approach 2 — Max-Heap of Size $k$ per Vertex

Maintain a `priority_queue` (max-heap) of size up to $k$ for each vertex $u$, storing the $k$ best distances seen so far.
- When an edge relaxation yields distance $d'$ to $v$:
  - If $v$'s heap has $< k$ elements, insert $d'$.
  - If $v$'s heap has $k$ elements and $d' < \text{heap}[v].\text{top}()$, pop the worst and insert $d'$.
- **Verdict**: Valid and optimal, but requires managing $n$ separate priority queues. Approach 3 uses a single global min-priority queue with a simple pop counter array, which is faster and much simpler.

---

## 5. Approach 3 — Optimal CSES Solution (Generalized Min-Heap Dijkstra with Pop Counter)

1. Maintain `count[1...n] = 0` and a single min-priority queue `pq` of pairs `{distance, vertex}`.
2. Push `{0, 1}` into `pq`.
3. While `pq` is non-empty and we have found fewer than $k$ routes to city $n$:
   - Pop `{d, u}`.
   - If `count[u] >= k`, continue.
   - Increment `count[u]++`.
   - If $u == n$:
     - Append $d$ to our `results` vector.
     - If `results.size() == k`, break out of the loop.
   - For each outgoing edge $(u \to v, w)$:
     - If `count[v] < k`:
       - Push `{d + w, v}` into `pq`.
4. Output the $k$ recorded distances.

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m, k;
    if (!(cin >> n >> m >> k)) return 0;

    vector<vector<pair<int, int>>> adj(n + 1);
    for (int i = 0; i < m; ++i) {
        int u, v, w;
        cin >> u >> v >> w;
        adj[u].push_back({v, w});
    }

    priority_queue<pair<long long, int>, 
                   vector<pair<long long, int>>, 
                   greater<pair<long long, int>>> pq;

    vector<int> count(n + 1, 0);
    vector<long long> ans;
    ans.reserve(k);

    pq.push({0, 1});

    while (!pq.empty() && (int)ans.size() < k) {
        auto [d, u] = pq.top();
        pq.pop();

        if (count[u] >= k) continue;
        count[u]++;

        if (u == n) {
            ans.push_back(d);
        }

        for (const auto& edge : adj[u]) {
            int v = edge.first;
            long long w = edge.second;

            if (count[v] < k) {
                pq.push({d + w, v});
            }
        }
    }

    for (int i = 0; i < k; ++i) {
        cout << ans[i] << (i + 1 == k ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(k \cdot (n + m) \log(k \cdot n))$.
  - Each vertex is popped at most $k$ times.
  - Total edges explored: at most $k \cdot m$.
  - Priority queue contains at most $k \cdot m$ elements, so each push and pop takes $\mathcal{O}(\log(k \cdot m)) = \mathcal{O}(\log(n + m))$.
  - With $k \le 10$, total operations $\le 10 \times 2 \cdot 10^5 \log(2 \cdot 10^6) \approx 4 \cdot 10^7 \approx 0.15\text{s}$.
- **Space Complexity**: $\mathcal{O}(k \cdot (n + m))$ for the priority queue and adjacency list.

---

## 6. Correctness Proof

### Ordered Monotonicity of Min-Heap Traversal
- **Theorem**: For any vertex $u$, the $i$-th time ($1 \le i \le k$) that a pair $(d, u)$ is popped from `pq`, $d$ is the length of the $i$-th shortest route from $1$ to $u$.
- **Proof by Induction**:
  1. Let a walk $W = (e_1, e_2, \dots, e_p)$ from $1$ to $u$ have cost $\sum w(e_j)$. Since all edge weights $w(e) \ge 1 > 0$, any prefix subwalk has strictly smaller cost than the full walk.
  2. The min-heap always extracts the global minimum tentative distance among all unexplored path extensions across the entire graph.
  3. Consequently, no path of cost $C'$ can be extracted after a path of cost $C > C'$. Extractions from `pq` are strictly monotonic non-decreasing in path cost.
  4. Therefore, the first $k$ times $n$ is extracted from `pq` must correspond to the $k$ smallest total path costs from $1$ to $n$.
  5. Furthermore, any valid $k$-th shortest path to $n$ cannot require visiting any intermediate vertex $v$ along a path that is the $(k+1)$-th or worse shortest path to $v$, because combining a strictly worse prefix with non-negative edges produces at least $k$ strictly better candidate paths to $n$.
  6. Thus, discarding any $(k+1)$-th or subsequent extraction at any vertex $v$ does not eliminate any of the $k$ optimal routes to $n$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, m = 6, k = 3$:
- Edges: $(1, 2, 2)$, $(1, 3, 3)$, $(2, 3, 1)$, $(2, 4, 8)$, $(3, 4, 2)$, $(4, 2, 1)$

1. **Initial**: `pq = {(0, 1)}`, `ans = []`.
2. Pop `{0, 1}`: `count[1] = 1`.
   - Push `{2, 2}`, `{3, 3}`.
3. Pop `{2, 2}`: `count[2] = 1`.
   - Push `{2+1=3, 3}`, `{2+8=10, 4}`.
4. Pop `{3, 3}`: `count[3] = 1`.
   - Push `{3+2=5, 4}`.
5. Pop `{3, 3}` (from edge $2 \to 3$): `count[3] = 2`.
   - Push `{3+2=5, 4}`.
6. Pop `{5, 4}`: `count[4] = 1`. Destination $4$ reached! `ans.push_back(5)`.
   - Push `{5+1=6, 2}`.
7. Pop `{5, 4}`: `count[4] = 2`. Destination $4$ reached! `ans.push_back(5)`.
   - Push `{5+1=6, 2}`.
8. Pop `{6, 2}`: `count[2] = 2`.
   - Push `{6+1=7, 3}`, `{6+8=14, 4}`.
9. Continue until $n=4$ is popped a 3rd time with distance $7$ (via $1 \to 2 \to 3 \to 4 \to 2 \to 3 \dots$).
10. Final `ans` contains the 3 smallest route costs: `5 5 7`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Repeated Visits to Same Vertex / Edge**:
   Unlike simple path problems, routes may loop through cycles (e.g. cycle with positive weight $W$). The problem asks for the $k$ shortest **walks**, which standard priority queue traversal handles naturally.
2. **64-bit Overflow**:
   Route distances can easily exceed $2 \cdot 10^9$ when $n = 10^5$ and weights are $10^9$. Always store distances in `long long`.
3. **Early Exit**:
   Exiting immediately once `ans.size() == k` saves significant time and memory, avoiding unnecessary extractions of remaining elements in `pq`.
4. **$k$ Duplicate Distances**:
   Multiple distinct routes can have identical lengths. Each distinct route to $n$ counts towards the $k$ routes, which is handled correctly by counting extractions.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the problem required the $k$ shortest SIMPLE paths (no repeated vertices)?**
   This requires **Yen's Algorithm**, which repeatedly modifies edge weights or removes vertices to force new paths, with complexity $\mathcal{O}(k \cdot V(E + V \log V))$.
2. **How large can $k$ be for this approach to work?**
   For $k \le 100$, this min-heap approach runs in $< 0.5\text{s}$. For very large $k$ (e.g. $k = 10^5$), **Eppstein's Algorithm** finds $k$-shortest paths in $\mathcal{O}(m + n \log n + k \log k)$ by building a persistent shortest-path deviation tree.
3. **What if we also need to print the vertices for all $k$ paths?**
   Store parent state pointers `{prev_dist, prev_node}` in the heap items, or maintain a deviation tree.
4. **Can there be cycles of weight 0?**
   If zero-weight cycles existed, an infinite number of paths of the same distance could be generated, causing an infinite loop. CSES guarantees all weights $c \ge 1$.
5. **How does this compare to $A^*$ search?**
   If an admissible heuristic $h(u) \le \text{dist}(u, n)$ is available (e.g. reverse Dijkstra distances from $n$), $A^*$ can find $k$-shortest paths with significantly fewer node expansions.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Dijkstra, $k$-Shortest Paths, Priority Queue, Min-Heap
- **Complexity Summary**:
  - Time: $\mathcal{O}(k \cdot (n + m) \log(k \cdot n))$
  - Space: $\mathcal{O}(k \cdot (n + m))$
- **Related CSES Problems**:
  - [Shortest Routes I](https://cses.fi/problemset/task/1671) — Standard SSSP ($k=1$)
  - [Flight Discount](https://cses.fi/problemset/task/1195) — Shortest path with 1 discounted edge
  - [Investigation](https://cses.fi/problemset/task/1202) — Counting number of shortest paths
