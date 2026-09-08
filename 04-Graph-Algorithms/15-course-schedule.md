# Course Schedule

- **Category**: Graph Algorithms
- **CSES Task ID**: `1679`
- **CSES Problem Link**: [Course Schedule](https://cses.fi/problemset/task/1679)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ courses numbered $1, 2, \dots, n$ and $m$ prerequisite requirements between them. Each requirement is specified by two courses $a$ and $b$, meaning course $a$ must be completed before course $b$ can be taken ($a \to b$).

Your task is to determine an order in which you can take all $n$ courses such that every prerequisite requirement is satisfied. If multiple valid course schedules exist, you may output any of them. If it is impossible to complete all courses (e.g. due to cyclic dependencies), print `IMPOSSIBLE`.

### Input Format
- The first line contains two integers $n$ and $m$: the number of courses and requirements.
- The next $m$ lines each contain two integers $a$ and $b$: course $a$ must be taken before course $b$.

### Output Format
- If a valid schedule exists:
  - Print $n$ integers: the courses in the order they should be taken.
- If no valid schedule exists:
  - Print `IMPOSSIBLE`.

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le m \le 2 \cdot 10^5$
- $1 \le a, b \le n$

With $V = 10^5$ and $E = 2 \cdot 10^5$, Kahn's Algorithm / DFS Topological Sort operates in linear time $\mathcal{O}(n + m) \approx 0.04\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the standard **Topological Sorting** problem on a Directed Graph:
- A **topological sort** of a directed graph is a linear ordering of its vertices such that for every directed edge $u \to v$, vertex $u$ appears before vertex $v$ in the ordering.
- **Fundamental Theorem of Topological Sorting**:
  A directed graph admits a topological sort **if and only if it contains no directed cycles** (i.e. it is a **DAG** — Directed Acyclic Graph).
- **Kahn's Algorithm (BFS with In-Degrees)**:
  1. Any course with **in-degree 0** has no unsatisfied prerequisites and can be taken immediately.
  2. Maintain a queue of all courses with in-degree 0.
  3. Whenever a course $u$ is taken (popped from queue):
     - Append $u$ to the final schedule.
     - For each course $v$ that requires $u$ ($u \to v$):
       - "Remove" the prerequisite edge by decrementing $\text{in\_degree}[v]--$.
       - If $\text{in\_degree}[v]$ reaches $0$, all of $v$'s prerequisites have been satisfied $\implies$ push $v$ into the queue.
  4. If the resulting schedule contains all $n$ courses, it is valid!
  5. If fewer than $n$ courses were scheduled, the remaining courses are trapped in one or more directed cycles $\implies$ print `IMPOSSIBLE`.

---

## 3. Approach 1 — Naive Recursive Dependency Resolution

For each course, repeatedly check if all its prerequisites are satisfied. If so, take it and repeat until all courses are taken.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot (n + m)) \approx 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n + m)$.
- **CSES Verdict**: TLE for $n = 10^5$.

---

## 4. Approach 2 — DFS Post-Order Topological Sort

Run DFS on the graph. When a vertex finishes (all descendants visited), push it to a list. Finally, reverse the list.
- **Cycle Detection in DFS**: Requires 3-state coloring (`0 = unvisited`, `1 = visiting`, `2 = visited`). If a back-edge (`state == 1`) is seen, a cycle exists.
- **Verdict**: Fully optimal $\mathcal{O}(n + m)$. However, Kahn's algorithm (Approach 3) is non-recursive, uses standard BFS, and handles both sorting and cycle detection simultaneously without call-stack overhead.

---

## 5. Approach 3 — Optimal CSES Solution (Kahn's Algorithm)

1. Maintain an adjacency list `adj` and an array `in_degree[1...n]`.
2. For each requirement $a \to b$:
   - Add $b$ to `adj[a]`.
   - Increment `in_degree[b]++`.
3. Push all vertices with `in_degree[i] == 0` into a `queue<int> q`.
4. While `q` is non-empty:
   - Pop $u$, push $u$ to `order`.
   - For each $v \in \text{adj}[u]$:
     - Decrement `in_degree[v]--`.
     - If `in_degree[v] == 0`, push $v$ into `q`.
5. If `order.size() == n`:
   - Print the elements of `order` separated by spaces.
6. If `order.size() < n`:
   - Print `IMPOSSIBLE`.

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<vector<int>> adj(n + 1);
    vector<int> in_degree(n + 1, 0);

    for (int i = 0; i < m; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        in_degree[v]++;
    }

    queue<int> q;
    for (int i = 1; i <= n; ++i) {
        if (in_degree[i] == 0) {
            q.push(i);
        }
    }

    vector<int> order;
    order.reserve(n);

    while (!q.empty()) {
        int u = q.front();
        q.pop();
        order.push_back(u);

        for (int v : adj[u]) {
            in_degree[v]--;
            if (in_degree[v] == 0) {
                q.push(v);
            }
        }
    }

    if ((int)order.size() == n) {
        for (int i = 0; i < n; ++i) {
            cout << order[i] << (i + 1 == n ? '\n' : ' ');
        }
    } else {
        cout << "IMPOSSIBLE\n";
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$.
  - In-degree computation: $\mathcal{O}(n + m)$.
  - Each vertex enters and leaves the queue exactly once.
  - Each directed edge is traversed exactly once.
  - Total time is strictly linear: $\approx 0.04\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for the adjacency list, in-degree array, queue, and order buffer.

---

## 6. Correctness Proof

### Invariant & Induction on Remaining Vertices
- **Claim**:
  1. If the graph is a DAG, Kahn's algorithm outputs a valid topological sort of all $n$ vertices.
  2. If the graph contains a directed cycle, Kahn's algorithm terminates with $|\text{order}| < n$.
- **Proof**:
  1. In any finite DAG, there exists at least one vertex with in-degree 0. (Suppose not: starting at any vertex and following incoming edges indefinitely would, by the Pigeonhole Principle on $n$ vertices, revisit a vertex, creating a cycle — contradicting the DAG property).
  2. When a vertex $u$ with in-degree 0 is appended to `order`, none of the remaining unplaced vertices have an edge directed into $u$. Thus, all prerequisites for $u$ are already satisfied.
  3. Removing $u$ and its outgoing edges yields a smaller DAG with $|V| - 1$ vertices. By induction, each successive choice maintains the topological ordering condition.
  4. Conversely, suppose $G$ contains a cycle $C = (c_1 \to c_2 \to \dots \to c_k \to c_1)$. Every vertex in $C$ has at least one prerequisite inside $C$. Thus, no vertex in $C$ can ever have its in-degree reach $0$ unless another vertex in $C$ has already been processed. Therefore, no vertex in $C$ can ever enter the queue.
  5. Hence, $|\text{order}| \le n - |C| < n$, correctly triggering `IMPOSSIBLE`. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 5, m = 3$:
- Prerequisites: $(1, 2)$, $(3, 2)$, $(2, 4)$
- In-degrees:
  - `in_degree[1] = 0`
  - `in_degree[2] = 2` (edges from 1, 3)
  - `in_degree[3] = 0`
  - `in_degree[4] = 1` (edge from 2)
  - `in_degree[5] = 0`
- Initial queue: $\{1, 3, 5\}$
- **Step 1**: Pop 1 $\to$ `order = [1]`. Decrement `in_degree[2]` to 1.
- **Step 2**: Pop 3 $\to$ `order = [1, 3]`. Decrement `in_degree[2]` to 0 $\implies$ push 2.
- **Step 3**: Pop 5 $\to$ `order = [1, 3, 5]`. (No outgoing edges).
- **Step 4**: Pop 2 $\to$ `order = [1, 3, 5, 2]`. Decrement `in_degree[4]` to 0 $\implies$ push 4.
- **Step 5**: Pop 4 $\to$ `order = [1, 3, 5, 2, 4]`.
- Queue empty. $|\text{order}| = 5 == n$. Valid schedule output!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Disconnected DAG (Multiple Valid Orders)**:
   Courses with no dependencies can be scheduled in arbitrary order (or interleaved). Kahn's algorithm naturally handles multiple components.
2. **Mutual Dependency (Cycle of Length 2)**:
   If course 1 requires 2 and 2 requires 1, both have in-degree 1. Neither enters the queue. Output is `IMPOSSIBLE`.
3. **Self-Loop (Course requires itself)**:
   If edge $u \to u$ exists, `in_degree[u]` is at least 1, so $u$ never enters the queue.
4. **Lexicographically Smallest Order**:
   If the problem requested the lexicographically smallest topological sort, replace `std::queue` with `std::priority_queue<int, vector<int>, greater<int>>`. (CSES Course Schedule accepts any valid order).

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How can you find the lexicographically smallest topological sort?**
   Use a min-heap (`std::priority_queue` with `greater<int>`) instead of a FIFO queue. At each step, choose the smallest available vertex with in-degree 0 in $\mathcal{O}((n + m) \log n)$ time.
2. **Can a graph have multiple topological sorts? When is it unique?**
   A DAG has a **unique** topological sort if and only if there is a directed Hamiltonian path (an edge between every consecutive pair of vertices in the topological order). In Kahn's algorithm, this occurs if and only if the queue size is never greater than 1 at any moment.
3. **How does topological sort enable Dynamic Programming on DAGs?**
   In a DAG, processing vertices in topological order guarantees that when computing DP values for vertex $u$, all predecessors of $u$ have already been finalized.
4. **How do we count the number of distinct topological sorts of a DAG?**
   Counting topological sorts is \#P-complete in general. For $n \le 20$, it can be solved in $\mathcal{O}(2^n \cdot n)$ using bitmask DP: $dp[\text{mask}] = \sum_{u \in \text{valid}} dp[\text{mask} \setminus \{u\}]$.
5. **What is the difference between Kahn's algorithm and DFS topological sort?**
   Kahn's algorithm processes vertices from sources (in-degree 0) to sinks. DFS processes vertices from sinks (out-degree 0) backwards by recording exit timestamps. Kahn's is non-recursive and naturally detects cycles via queue depletion.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Topological Sort, Kahn's Algorithm, DAG, In-Degree, BFS
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Round Trip II](https://cses.fi/problemset/task/1678) — Directed cycle detection
  - [Longest Flight Route](https://cses.fi/problemset/task/1680) — Longest path on a DAG via topological DP
  - [Game Routes](https://cses.fi/problemset/task/1681) — Counting paths on a DAG via topological DP
