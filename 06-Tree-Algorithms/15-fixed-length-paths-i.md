# Fixed-Length Paths I

- **Category**: Tree Algorithms
- **CSES Task ID**: `2080`
- **CSES Problem Link**: [Fixed-Length Paths I](https://cses.fi/problemset/task/2080)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an unweighted tree of $n$ nodes numbered $1, 2, \dots, n$ and $n - 1$ edges, your task is to count the number of distinct simple paths that consist of **exactly $k$ edges**.

A path is an unordered pair of endpoints $\{u, v\}$ such that the simple path between them contains exactly $k$ edges.

### Input Format
- The first line contains two integers $n$ and $k$: the number of nodes and the path length.
- The next $n - 1$ lines describe the edges: each line has two integers $a$ and $b$ ($1 \le a, b \le n$).

### Output Format
- Print one integer: the total number of paths of length $k$.

### Numerical Constraints
- $1 \le k \le n \le 2 \cdot 10^5$
- $1 \le a, b \le n$

---

## 2. Intuition & Pattern Recognition

Checking all $\binom{n}{2}$ pairs of nodes takes $\mathcal{O}(n^2)$ time.
Because we need to count global paths satisfying a distance property, the standard paradigm is **Centroid Decomposition** (divide-and-conquer on trees):

### Divide-and-Conquer Principle
At each recursive step:
1. Find the **centroid** $C$ of the current tree component.
2. Every path in the component either:
   - **Passes through $C$** (with $C$ as an endpoint or internal vertex).
   - **Does not pass through $C$**, meaning it lies entirely within one of the subtrees formed by removing $C$.
3. Count all paths of length $k$ that pass through $C$ in linear time $\mathcal{O}(\text{component size})$.
4. Remove $C$ and recurse on each of the remaining subtrees.
5. Because removing the centroid leaves subtrees of size at most $\lfloor \text{size} / 2 \rfloor$, the recursion tree has depth at most $\mathcal{O}(\log n)$.
   The overall time complexity is $\mathcal{O}(n \log n)$.

### Counting Paths Passing Through Centroid $C$
Maintain a frequency array `cnt[d]`: the number of nodes at distance $d$ from $C$ in the subtrees processed so far.
- Initialize `cnt[0] = 1` (representing centroid $C$ itself).
- For each child branch of $C$:
  1. Traverse the child's subtree using DFS to collect the distance $d$ of each node from $C$.
  2. For each node at distance $d \le k$, any previously visited node at distance $k - d$ forms a valid path of length $k$ passing through $C$:
     $$\text{ans} \mathrel{+}= \text{cnt}[k - d]$$
  3. After querying all nodes in the current child branch, add them to `cnt`:
     $$\text{cnt}[d] \mathrel{+}= 1$$
- Clearing `cnt` up to `max_depth` takes $\mathcal{O}(\text{component size})$ time, preserving the $\mathcal{O}(n \log n)$ overall runtime.

---

## 3. Approach 1 — Naive All-Pairs BFS

Run a BFS from every node $u$ up to depth $k$ and count nodes at distance $k$, dividing by 2 at the end.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot \min(n, k)) \approx \mathcal{O}(n^2) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Small-to-Large Merging on Depths (DSU on Tree)

For each node, maintain a `std::vector<int>` or `std::deque<int>` of depths. When merging child depth arrays, add to answer and merge smaller arrays into the larger array.
- **Time Complexity**: $\mathcal{O}(n \log n)$ or $\mathcal{O}(n)$ with pointer swap.
- **Space Complexity**: $\mathcal{O}(n)$.
- **Verdict**: Optimal, but requires delicate offset tracking. Centroid Decomposition (Approach 3) is the gold standard for tree path counting and generalizes directly to range bounds $[k_1, k_2]$ in Fixed-Length Paths II.

---

## 5. Approach 3 — Optimal CSES Solution (Centroid Decomposition)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int n, k;
vector<vector<int>> adj;
vector<int> sz;
vector<bool> removed;
vector<int> cnt;
long long total_paths = 0;
int max_depth_recorded = 0;

void dfs_sz(int u, int p) {
    sz[u] = 1;
    for (int v : adj[u]) {
        if (v != p && !removed[v]) {
            dfs_sz(v, u);
            sz[u] += sz[v];
        }
    }
}

int get_centroid(int u, int p, int comp_size) {
    for (int v : adj[u]) {
        if (v != p && !removed[v] && sz[v] > comp_size / 2) {
            return get_centroid(v, u, comp_size);
        }
    }
    return u;
}

// Collects depths and counts matching paths
void dfs_count(int u, int p, int d) {
    if (d > k) return;
    total_paths += cnt[k - d];
    for (int v : adj[u]) {
        if (v != p && !removed[v]) {
            dfs_count(v, u, d + 1);
        }
    }
}

// Inserts depths into the frequency array
void dfs_add(int u, int p, int d) {
    if (d > k) return;
    cnt[d]++;
    max_depth_recorded = max(max_depth_recorded, d);
    for (int v : adj[u]) {
        if (v != p && !removed[v]) {
            dfs_add(v, u, d + 1);
        }
    }
}

void solve(int u) {
    dfs_sz(u, 0);
    int comp_size = sz[u];
    if (comp_size <= k) return;

    int c = get_centroid(u, 0, comp_size);
    removed[c] = true;

    cnt[0] = 1;
    max_depth_recorded = 0;

    for (int v : adj[c]) {
        if (!removed[v]) {
            dfs_count(v, c, 1);
            dfs_add(v, c, 1);
        }
    }

    // Reset cnt table efficiently in O(max_depth)
    for (int d = 0; d <= max_depth_recorded; ++d) {
        cnt[d] = 0;
    }

    for (int v : adj[c]) {
        if (!removed[v]) {
            solve(v);
        }
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> k)) return 0;

    adj.assign(n + 1, vector<int>());
    sz.assign(n + 1, 0);
    removed.assign(n + 1, false);
    cnt.assign(n + 1, 0);

    for (int i = 0; i < n - 1; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    solve(1);

    cout << total_paths << '\n';

    return 0;
}
```

---

## 6. Correctness Proof

### Path Partitioning Invariant
Let $\mathcal{P}_k$ be the set of all distinct simple paths in tree $T$ of length $k$.
At centroid $C$:
1. A path $P \in \mathcal{P}_k$ passes through $C$ iff $C \in P$.
2. Because $T$ is a tree, any path passing through $C$ is uniquely formed by either:
   - Centroid $C$ and a single node at distance $k$ in some child subtree.
   - Two nodes $u$ and $v$ belonging to **distinct child subtrees** of $C$, with $\text{dist}(u, C) + \text{dist}(v, C) = k$.
3. By checking `dfs_count` on child $v$ **before** adding $v$'s nodes via `dfs_add`, paths whose endpoints lie in the *same* child subtree are never formed through $C$, strictly preventing invalid self-intersecting paths.
4. Setting `removed[C] = true` disconnects the tree into smaller subcomponents. Any remaining path does not contain $C$ and must lie entirely inside one subcomponent.
By strong induction on component size, every path of length $k$ is counted at the unique centroid step where it first passes through the selected centroid, exactly once.

### Recurrence and Time Complexity
At each recursion level, finding the centroid and traversing child subtrees takes $\mathcal{O}(S)$, where $S$ is the component size.
Since each subcomponent has size at most $S / 2$:
$$T(n) = \sum_{i} T(S_i) + \mathcal{O}(n), \quad \text{where } \sum S_i \le n \text{ and } S_i \le n / 2$$
By the Master Theorem, the recurrence tree has depth $\lceil \log_2 n \rceil$, yielding total time $\mathcal{O}(n \log n)$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 2
1 2
2 3
3 4
3 5
```

Tree:
```text
 1 - 2 - 3
        / \
       4   5
```
$n = 5, k = 2$.

### Execution
1. Centroid of entire tree ($n = 5$) is $C = 3$.
   - `cnt[0] = 1`.
   - Branch 1: node 2 (contains $\{2, 1\}$):
     - Node 2 at depth 1: `ans += cnt[2 - 1] = cnt[1] = 0`.
     - Node 1 at depth 2: `ans += cnt[2 - 2] = cnt[0] = 1` (path $1 - 2 - 3$).
     - Add $\{2, 1\}$: `cnt[1] = 1, cnt[2] = 1`.
   - Branch 2: node 4:
     - Node 4 at depth 1: `ans += cnt[2 - 1] = cnt[1] = 1` (path $4 - 3 - 2$).
     - Add 4: `cnt[1] = 2`.
   - Branch 3: node 5:
     - Node 5 at depth 1: `ans += cnt[2 - 1] = cnt[1] = 2` (paths $5 - 3 - 2$ and $5 - 3 - 4$).
     - Add 5: `cnt[1] = 3`.
   - Total paths through centroid 3: $1 + 1 + 2 = 4$.
2. Decompose subtrees:
   - Component $\{1, 2\}$: length is 1, size $\le k=2 \implies$ no paths of length 2.
   - Components $\{4\}$ and $\{5\}$: size $1 \le 2$.

### Total Result
Paths of length 2:
- $1 - 2 - 3$
- $4 - 3 - 2$
- $5 - 3 - 2$
- $4 - 3 - 5$
Total: `4`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow for Total Paths**:
   A star graph with $n = 2 \cdot 10^5$ and $k = 2$ has $\binom{n-1}{2} \approx \frac{(2 \cdot 10^5)^2}{2} \approx 2 \cdot 10^{10}$ paths. `total_paths` must be `long long`.
2. **Component Size Smaller than $k$ ($comp\_size \le k$)**:
   The check `if (comp_size <= k) return;` prunes subtrees that are too small to contain a path of length $k$, providing a significant real-world speedup.
3. **Resetting the Frequency Array**:
   Never use `memset(cnt, 0, sizeof(cnt))` or `cnt.assign(...)` inside recursion, as this takes $\mathcal{O}(n)$ per node, degrading complexity to $\mathcal{O}(n^2)$. Only reset up to `max_depth_recorded`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How do you extend this to path lengths in range $[k_1, k_2]$?**
   This is CSES 2081 (*Fixed-Length Paths II*): replace the direct array `cnt[k - d]` with a Fenwick tree supporting range sum queries on $[k_1 - d, k_2 - d]$ in $\mathcal{O}(\log n)$.
2. **What if edges have positive weights and we want paths of total weight $W$?**
   Use a hash table or coordinate-compressed Fenwick tree at each centroid to query `cnt[W - d]`.
3. **Can we count paths of length $k$ using generating functions and FFT?**
   Yes! The depth frequencies of each branch form a polynomial. Multiplying branch polynomials via NTT computes all pairwise path lengths simultaneously in $\mathcal{O}(n \log^2 n)$.
4. **How would you return the path with maximum node weight of length $k$?**
   In `dfs_count`, query the maximum weight at distance $k - d$ rather than summing frequencies.
5. **What is the maximum recursion depth of Centroid Decomposition?**
   Because component sizes strictly satisfy $S_{\text{child}} \le \lfloor S / 2 \rfloor$, the depth is at most $\lfloor \log_2 n \rfloor + 1 \le 18$ for $n = 200,000$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**: $\mathcal{O}(n \log n)$ — Centroid tree has depth $\mathcal{O}(\log n)$, with each level taking $\mathcal{O}(n)$ work ($\approx 0.11\text{s}$).
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary memory for recursion stack and `cnt` table.

### Related CSES Problems
- [Fixed-Length Paths II](https://cses.fi/problemset/task/2081) — Paths with length in range $[k_1, k_2]$
- [Finding a Centroid](https://cses.fi/problemset/task/2079) — Core centroid computation
- [Tree Diameter](https://cses.fi/problemset/task/1131) — Maximum path length in tree
