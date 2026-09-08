# Hotel Queries

- **Category**: Range Queries
- **CSES Task ID**: `1143`
- **CSES Problem Link**: [Hotel Queries](https://cses.fi/problemset/task/1143)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ hotels numbered $1, 2, \dots, n$, and initially hotel $i$ has $h_i$ free rooms. Then, $m$ groups of tourists arrive one by one, where group $j$ requires $r_j$ rooms.

Each group is assigned to the **first hotel** (the hotel with the smallest index) that has at least $r_j$ available rooms. When a hotel is assigned to a group, its available room count decreases by $r_j$. If no hotel has enough rooms for the group, the group is not assigned to any hotel and you should output $0$.

Your task is to print the assigned hotel index for each of the $m$ tourist groups.

### Input Format
- The first line contains two integers $n$ and $m$: the number of hotels and tourist groups.
- The second line contains $n$ integers $h_1, h_2, \dots, h_n$: the initial room counts.
- The third line contains $m$ integers $r_1, r_2, \dots, r_m$: the room requirements for each group.

### Output Format
- Print $m$ integers separated by spaces: the assigned hotel for each group (or $0$).

### Numerical Constraints
- $1 \le n, m \le 2 \cdot 10^5$
- $1 \le h_i, r_j \le 10^9$

With $n, m \le 2 \cdot 10^5$, walking on a Segment Tree finds the first valid hotel and updates its capacity in $\mathcal{O}(\log n)$ time per group, finishing in $\approx 0.08\text{s}$.

---

## 2. Intuition & Pattern Recognition

This problem requires finding the **first index** with $\text{value} \ge X$, followed by a **point update**:
- Answering queries naively by scanning from left to right takes $\mathcal{O}(n)$ per group, leading to $\mathcal{O}(n \cdot m) \approx 4 \cdot 10^{10}$ operations (TLE).
- **Segment Tree with Range Maximum**:
  A Segment Tree maintains the **maximum available rooms** in every interval $[L, R]$:
  $$\text{tree}[\text{node}] = \max(\text{tree}[\text{left\_child}], \; \text{tree}[\text{right\_child}])$$
- **Binary Search on Segment Tree (Walking the Tree)**:
  Instead of binary searching the index and performing $\mathcal{O}(\log n)$ range queries (which takes $\mathcal{O}(\log^2 n)$), we can navigate down the tree directly in **$\mathcal{O}(\log n)$ time**:
  1. Check the root: if $\text{tree}[1] < r_j$, no hotel has enough rooms $\implies$ return $0$.
  2. At internal node $u$:
     - Check the **left child**: if $\text{tree}[\text{left}] \ge r_j$, the first valid hotel is guaranteed to lie in the left subtree! Greedily descend to the left child.
     - Otherwise, the first valid hotel must lie in the right subtree. Descend to the right child.
  3. When reaching a leaf corresponding to hotel $k$:
     - Hotel $k$ is the uniquely earliest hotel with $\ge r_j$ rooms.
     - Decrement: $\text{tree}[\text{leaf}] \leftarrow \text{tree}[\text{leaf}] - r_j$.
     - Update maximums on the path back up to the root.
     - Output $k$.

---

## 3. Approach 1 — Naive Linear Scan per Group

Iterate $i$ from $1$ to $n$, finding the first $h_i \ge r_j$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot m) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Binary Search over Range Max Query ($\mathcal{O}(\log^2 n)$)

Binary search for the smallest index $mid$ such that $\text{query\_max}(1, mid) \ge r_j$.
- **Complexity**: $\mathcal{O}(m \log^2 n) \approx 2 \cdot 10^5 \times 18^2 \approx 6.5 \cdot 10^7$ operations.
- **Verdict**: Correct and passes, but walking directly down the Segment Tree (Approach 3) is twice as fast and mathematically cleaner in $\mathcal{O}(\log n)$.

---

## 5. Approach 3 — Optimal CSES Solution (Segment Tree Walk)

1. Pad $n$ to next power of 2 ($N$) or build standard $4n$ Segment Tree.
2. Build tree with range maximums:
   $$\text{tree}[\text{node}] = \max(\text{tree}[2 \cdot \text{node}], \; \text{tree}[2 \cdot \text{node} + 1])$$
3. Function `find_and_update(node, l, r, req)`:
   - If $\text{tree}[\text{node}] < \text{req}$, return $0$.
   - If $l == r$ (leaf reached):
     $\text{tree}[\text{node}] \mathrel{-}= \text{req}$.
     return $l$.
   - $mid = (l + r) / 2$.
   - If $\text{tree}[2 \cdot \text{node}] \ge \text{req}$:
     $\text{res} = \text{find\_and\_update}(2 \cdot \text{node}, l, mid, \text{req})$
   - Else:
     $\text{res} = \text{find\_and\_update}(2 \cdot \text{node} + 1, mid + 1, r, \text{req})$
   - Update: $\text{tree}[\text{node}] = \max(\text{tree}[2 \cdot \text{node}], \; \text{tree}[2 \cdot \text{node} + 1])$.
   - return $\text{res}$.
4. Output the results.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int n, m;
vector<int> tree_max;

void build(int node, int l, int r, const vector<int>& h) {
    if (l == r) {
        tree_max[node] = h[l];
        return;
    }
    int mid = (l + r) / 2;
    build(2 * node, l, mid, h);
    build(2 * node + 1, mid + 1, r, h);
    tree_max[node] = max(tree_max[2 * node], tree_max[2 * node + 1]);
}

int find_and_update(int node, int l, int r, int req) {
    if (tree_max[node] < req) {
        return 0;
    }

    if (l == r) {
        tree_max[node] -= req;
        return l;
    }

    int mid = (l + r) / 2;
    int res = 0;

    // Greedily check left child first to guarantee the smallest hotel index
    if (tree_max[2 * node] >= req) {
        res = find_and_update(2 * node, l, mid, req);
    } else {
        res = find_and_update(2 * node + 1, mid + 1, r, req);
    }

    tree_max[node] = max(tree_max[2 * node], tree_max[2 * node + 1]);
    return res;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> m)) return 0;

    vector<int> h(n + 1);
    for (int i = 1; i <= n; ++i) {
        cin >> h[i];
    }

    tree_max.assign(4 * n + 1, 0);
    build(1, 1, n, h);

    for (int j = 0; j < m; ++j) {
        int req;
        cin >> req;
        int hotel = find_and_update(1, 1, n, req);
        cout << hotel << (j + 1 == m ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**:
  - Build: $\mathcal{O}(n)$ linear tree build.
  - Per Group Query: Exactly $\mathcal{O}(\log n)$ steps down the tree (depth at most $\lceil \log_2 n \rceil = 18$).
  - Total Time: $\mathcal{O}(n + m \log n) \approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ for the tree of size $4n$ ($\approx 3.2\text{ MB}$).

---

## 6. Correctness Proof

### Left-First Tree Descent Invariant
- **Claim**: The procedure `find_and_update` always returns the smallest index $k \in [1, n]$ such that $h_k \ge \text{req}$, and correctly updates the tree.
- **Proof**:
  1. Base Case: At root, $\text{tree}[1] = \max_{1 \le i \le n} h_i$. If $\text{tree}[1] < \text{req}$, no hotel in $[1, n]$ has $\ge \text{req}$ rooms. The algorithm correctly returns $0$.
  2. Inductive Step: Assume at node $u$ covering $[L, R]$, $\max_{L \le i \le R} h_i \ge \text{req}$.
     - Case A: $\text{tree}[\text{left}] \ge \text{req}$.
       There exists at least one index in the left half $[L, M]$ with $h_i \ge \text{req}$.
       Since every index in $[L, M]$ is strictly smaller than any index in $[M+1, R]$, the smallest qualifying index must reside in $[L, M]$.
       Descending into the left child guarantees finding the minimum index.
     - Case B: $\text{tree}[\text{left}] < \text{req}$.
       No index in $[L, M]$ has enough rooms.
       Therefore, the smallest qualifying index must reside in the right half $[M+1, R]$.
       Descending into the right child is necessary and sufficient.
  3. Reaching Leaf: When $L = R = k$, hotel $k$ is reached. Decrementing $h_k$ by $\text{req}$ and recalculating parent maximums upward maintains the invariant for subsequent queries. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 8, m = 5$:
- Hotels: $h = [3, 2, 4, 1, 5, 5, 2, 6]$
- Group 1: `req = 4`
  - Root max is $6 \ge 4$.
  - Left child $[1..4]$ max is $4 \ge 4 \implies$ go left.
  - Left child $[1..2]$ max is $3 < 4 \implies$ go right to $[3..4]$.
  - Left child $[3..3]$ is $4 \ge 4 \implies$ hotel 3!
  - Hotel 3 rooms become $4 - 4 = 0$.
  - Output: `3`.
- Group 2: `req = 4`
  - Root max is 6.
  - Left child $[1..4]$ max is now $\max(3, 2, 0, 1) = 3 < 4 \implies$ go right to $[5..8]$!
  - Left child $[5..6]$ max is $5 \ge 4 \implies$ go left.
  - Left child $[5..5]$ is $5 \ge 4 \implies$ hotel 5!
  - Hotel 5 rooms become $5 - 4 = 1$.
  - Output: `5`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Group Requires More Rooms than Any Hotel**:
   If `req > tree_max[1]`, the root check triggers immediately and prints `0` without tree descent.
2. **Hotel Capacity Reduced to 0**:
   When hotel $k$ reaches 0 rooms, subsequent queries will naturally bypass it since `tree_max` reflects 0.
3. **Values up to $10^9$**:
   Comparisons are between `int` $\le 10^9$, which fits within standard 32-bit signed integer.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How is this technique used in memory management (First-Fit Allocation)?**
   Memory allocators use a Segment Tree over free memory blocks to find the first block with size $\ge \text{req}$ in $\mathcal{O}(\log N)$ time.
2. **What if the problem asked for the LAST hotel with $\ge \text{req}$ rooms (Best-Fit or Rightmost)?**
   Check the right child first: if `tree[right] >= req`, descend right; else descend left.
3. **What if the problem asked for the hotel with the MINIMUM rooms that still satisfies $\ge \text{req}$ (Best-Fit)?**
   Maintain a balanced BST (e.g. `std::multiset<pair<int, int>>` storing `{rooms, id}`) and query `lower_bound({req, 0})` in $\mathcal{O}(\log n)$.
4. **How do you find the first element $\ge X$ in a restricted subrange $[a, b]$?**
   Combine range maximum query with tree descent: only descend into subtrees that intersect $[a, b]$ and have maximum $\ge X$, running in $\mathcal{O}(\log n)$ time.
5. **Can this be implemented with an iterative segment tree?**
   Yes, but walking top-down requires finding the appropriate ancestor and descending, which is cleaner to express recursively.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Range Queries, Segment Tree, Binary Search on Segment Tree, Greedy, Point Update
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m \log n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - [Dynamic Range Minimum Queries](https://cses.fi/problemset/task/1649) — Standard Segment Tree
  - [List Removals](https://cses.fi/problemset/task/1749) — Finding $k$-th active element in Segment Tree
  - [Salary Queries](https://cses.fi/problemset/task/1144) — Coordinate compression with frequency tree
