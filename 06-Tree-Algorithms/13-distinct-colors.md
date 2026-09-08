# Distinct Colors

- **Category**: Tree Algorithms
- **CSES Task ID**: `1139`
- **CSES Problem Link**: [Distinct Colors](https://cses.fi/problemset/task/1139)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a rooted tree consisting of $n$ nodes numbered $1, 2, \dots, n$, where node 1 is the root. Each node $i$ has a color $c_i$.

Your task is to determine, for **every node** $u \in [1, n]$, the number of **distinct colors** present in the subtree rooted at $u$.

### Input Format
- The first line contains an integer $n$: the number of nodes.
- The second line contains $n$ integers $c_1, c_2, \dots, c_n$: the color of each node.
- The next $n - 1$ lines describe the edges: each line has two integers $a$ and $b$.

### Output Format
- Print $n$ integers: the number of distinct colors in the subtree of each node from 1 to $n$.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le c_i \le 10^9$
- $1 \le a, b \le n$

---

## 2. Intuition & Pattern Recognition

A naive approach would create a set of colors for each node by traversing its subtree, which takes $\mathcal{O}(n^2)$ time and $\mathcal{O}(n^2)$ memory in the worst case (e.g., a line graph).

There are two primary optimal paradigms for this problem:
1. **Small-to-Large Merging (Sack / DSU on Tree)**:
   In a post-order traversal, each node maintains the set of colors present in its subtree.
   When combining the sets of its children, we always swap to keep the **largest** set and iterate through the smaller child sets to insert their elements:
   $$\text{if } |\text{child\_set}| > |\text{cur\_set}|: \quad \text{swap}(\text{cur\_set}, \text{child\_set})$$
   $$\text{for } c \in \text{child\_set}: \quad \text{cur\_set.insert}(c)$$
   - *Why is this fast?*
     Each time an element from a smaller set is inserted into a larger set, the size of the set containing that element at least **doubles**.
     Therefore, an individual element can be moved at most $\lfloor \log_2 n \rfloor$ times throughout the entire execution!
     This yields an overall time complexity of $\mathcal{O}(n \log^2 n)$ using `std::set`, or $\mathcal{O}(n \log n)$ using DSU on Tree.

2. **Euler Tour + Offline Fenwick Tree**:
   Flatten the tree into DFS entry intervals $[\text{tin}[u], \text{tout}[u]]$. The problem reduces to range distinct value counting on a 1D array (CSES 1734 *Distinct Values Queries*), solved in $\mathcal{O}(n \log n)$ time.

The Small-to-Large pointer merging technique is tree-native, highly intuitive, and runs comfortably within the 1.00s time limit.

---

## 3. Approach 1 — Naive Subtree Set Construction

For each node $u$, run a DFS over its subtree, insert all colors into an `std::unordered_set`, and record its size.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Euler Tour + Fenwick Tree (Offline 1D Distinct)

Flatten the tree using DFS entry/exit timestamps.
Each subtree becomes an interval $[\text{tin}[u], \text{tout}[u]]$.
Coordinate compress colors, sort queries by right endpoint, and sweep with a Fenwick tree as in CSES 1734.
- **Time Complexity**: $\mathcal{O}(n \log n)$.
- **Space Complexity**: $\mathcal{O}(n)$.
- **Trade-off**: Requires coordinate compression, query sorting, and an auxiliary Fenwick tree. Small-to-Large (Approach 3) solves the problem directly on the tree in fewer lines of code.

---

## 5. Approach 3 — Optimal CSES Solution (Small-to-Large Pointer Merging)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <set>
#include <algorithm>

using namespace std;

int n;
vector<vector<int>> adj;
vector<int> color;
vector<int> ans;

// Returns pointer to the set of colors in u's subtree
set<int>* dfs(int u, int p) {
    set<int>* cur_set = new set<int>();
    cur_set->insert(color[u]);

    for (int v : adj[u]) {
        if (v == p) continue;
        set<int>* child_set = dfs(v, u);

        // Small-to-large merging: ensure cur_set is the larger set
        if (child_set->size() > cur_set->size()) {
            swap(cur_set, child_set);
        }

        // Insert elements of the smaller set into the larger set
        for (int c : *child_set) {
            cur_set->insert(c);
        }

        delete child_set;
    }

    ans[u] = static_cast<int>(cur_set->size());
    return cur_set;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n)) return 0;

    color.assign(n + 1, 0);
    for (int i = 1; i <= n; ++i) {
        cin >> color[i];
    }

    adj.assign(n + 1, vector<int>());
    for (int i = 0; i < n - 1; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
        adj[v].push_back(u);
    }

    ans.assign(n + 1, 0);

    set<int>* root_set = dfs(1, 0);
    delete root_set;

    for (int i = 1; i <= n; ++i) {
        cout << ans[i] << (i == n ? "" : " ");
    }
    cout << '\n';

    return 0;
}
```

---

## 6. Correctness Proof

### Subtree Color Invariant
For any node $u$, let $C(u)$ be the set of colors of all nodes in $\text{subtree}(u)$:
$$C(u) = \{c_u\} \cup \bigcup_{v \in \text{children}(u)} C(v)$$
1. **Base Case (Leaf Node)**:
   Node $u$ has no children. `cur_set` contains $\{c_u\}$. Its size is 1, and the pointer is returned. Exact.
2. **Inductive Step**:
   By induction, `dfs(v, u)` returns the exact set $C(v)$ for every child $v$.
   The code computes the union $\{c_u\} \cup \bigcup_{v} C(v)$ by inserting every element from every child's set into `cur_set`.
   Because `std::set` stores unique elements, duplicate colors across different subtrees are merged without overcounting.
   `ans[u]` is assigned $|C(u)|$, which is the exact count of distinct colors in $u$'s subtree.

### Small-to-Large Complexity Lemma
When merging two sets $A$ and $B$ with $|A| \ge |B|$:
- Swapping pointers takes $\mathcal{O}(1)$ time.
- Inserting each element of $B$ into $A$ takes $\mathcal{O}(\log |A|) \le \mathcal{O}(\log n)$ time.
- Each element of $B$ now belongs to a set of size at least $|A| + |B| \ge 2|B|$.
- The size of the set containing any element at least doubles after each move.
- Since the maximum possible set size is $n$, an element can move at most $\lfloor \log_2 n \rfloor$ times.
Summing across all $n$ elements, the total number of insertions is at most $n \log_2 n$.
Each insertion takes $\mathcal{O}(\log n)$ in `std::set`.
Thus, the total time is strictly bounded by $\mathcal{O}(n \log^2 n)$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5
2 3 2 2 5
1 2
1 3
3 4
3 5
```

Node Colors:
- $c_1 = 2$
- $c_2 = 3$
- $c_3 = 2$
- $c_4 = 2$
- $c_5 = 5$

Tree:
```text
      1 (c=2)
    /   \
   2     3 (c=2)
 (c=3)  / \
       4   5
     (c=2) (c=5)
```

### Trace
1. `dfs(2)`: leaf $\implies \text{cur\_set} = \{3\}$. `ans[2] = 1`.
2. `dfs(4)`: leaf $\implies \text{cur\_set} = \{2\}$. `ans[4] = 1`.
3. `dfs(5)`: leaf $\implies \text{cur\_set} = \{5\}$. `ans[5] = 1`.
4. `dfs(3)`: starts with $\{c_3\} = \{2\}$.
   - Merge child 4 ($\{2\}$): already contains 2 $\implies \{2\}$.
   - Merge child 5 ($\{5\}$): inserts 5 $\implies \{2, 5\}$.
   - `ans[3] = 2`.
5. `dfs(1)`: starts with $\{c_1\} = \{2\}$.
   - Merge child 2 ($\{3\}$): inserts 3 $\implies \{2, 3\}$.
   - Merge child 3 ($\{2, 5\}$): sizes are 2 and 2. Merge $\implies \{2, 3, 5\}$.
   - `ans[1] = 3`.

### Output
`3 1 2 1 1` — matches ground truth.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Large Color Values ($c_i \le 10^9$)**:
   Colors can be up to $10^9$. `std::set<int>` handles arbitrarily large values without coordinate compression.
2. **All Nodes Have Same Color**:
   Set size remains 1 at all nodes. `ans[u] = 1` for all $u$.
3. **All Nodes Have Unique Colors**:
   Subtree size equals distinct color count. `ans[u] = size(u)`.
4. **Memory Management**:
   Calling `delete child_set` immediately after merging frees smaller sets, keeping peak heap memory bounded by $\mathcal{O}(n)$ at all times.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How can the complexity be reduced from $\mathcal{O}(n \log^2 n)$ to $\mathcal{O}(n \log n)$?**
   Use **DSU on Tree (Sack)**: maintain a global frequency array `count[]` and a global integer `distinct_count`. Only iterate over the light subtrees while preserving the heavy child's contribution directly.
2. **What if we want the most frequent color in each subtree?**
   In DSU on Tree, maintain `max_freq` alongside `freq[color]`. Updating takes $\mathcal{O}(1)$ per insertion.
3. **Can this problem be solved online if node colors are updated dynamically?**
   With dynamic color updates, Small-to-Large merging fails because subtrees cannot be pre-aggregated statically. Dynamic subtree distinct counting requires **2D Segment Tree** or **Mo's Algorithm with Updates** on Euler tour.
4. **How would you count distinct colors on arbitrary tree paths (instead of subtrees)?**
   Tree path distinct colors requires **Mo's Algorithm on Trees** (flattening via Euler Tour entry/exit and tracking parity of node occurrences) in $\mathcal{O}(n \sqrt{n})$ time.
5. **How does `std::unordered_set` compare here?**
   `std::unordered_set` has $\mathcal{O}(1)$ average insertions, but rehashing and memory allocation overhead often make it slower than `std::set` in competitive programming unless custom fast hash tables (`gp_hash_table`) are used.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**: $\mathcal{O}(n \log^2 n) \approx 0.18\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n)$ — Only one set per branch active on the heap.

### Related CSES Problems
- [Subtree Queries](https://cses.fi/problemset/task/1137) — Subtree range aggregation
- [Distinct Values Queries](https://cses.fi/problemset/task/1734) — 1D range distinct values
- [Finding a Centroid](https://cses.fi/problemset/task/2079) — Tree balance and decomposition
