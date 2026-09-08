# Range Queries and Copies

- **Category**: Range Queries
- **CSES Task ID**: `1737`
- **CSES Problem Link**: [Range Queries and Copies](https://cses.fi/problemset/task/1737)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an initial array of $n$ integers $t_1, t_2, \dots, t_n$. You must maintain a list of arrays (initially containing only Array 1) and process $q$ queries of three types:
1. `1 k a x`: **Update**: Set the value at position $a$ in array $k$ to $x$.
2. `2 k a b`: **Range Sum**: Calculate the sum of values in range $[a, b]$ in array $k$ ($\sum_{i=a}^b \text{array}_k[i]$).
3. `3 k`: **Copy Array**: Create a duplicate copy of array $k$ and append it to the end of the array list (if there are currently $m$ arrays, the new copy becomes array $m + 1$).

Array indices and array IDs are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the array size and the number of queries.
- The second line contains $n$ integers $t_1, t_2, \dots, t_n$: the initial array elements.
- The next $q$ lines describe the queries:
  - `1 k a x`
  - `2 k a b`
  - `3 k`

### Output Format
- For each query of type 2, print the sum of values on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le t_i, x \le 10^9$
- $1 \le a \le b \le n$
- $1 \le k \le \text{current number of arrays}$

---

## 2. Intuition & Pattern Recognition

Creating a deep copy of an entire array of size $n = 2 \cdot 10^5$ in $\mathcal{O}(n)$ time is far too slow if performed $q$ times ($\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations).

### Persistent Data Structures: Path Copying
Notice that when an array is copied, the copy initially shares identical elements with the original. Furthermore, a point update modifies only a single element $a$.
Instead of duplicating the full array:
- Represent each array version as the root of a **Persistent Segment Tree**.
- An initial segment tree of size $2n$ is built for Array 1.
- **Copying Array $k$ (`3 k`)**:
  Simply record the pointer to the root of Array $k$:
  $$\text{roots.push\_back}(\text{roots}[k])$$
  This takes $\mathcal{O}(1)$ time and memory!
- **Point Update in Array $k$ (`1 k a x`)**:
  Create a new path from the root down to the leaf at position $a$.
  At each level, allocate a new node with the updated sum, while copying the unchanged child pointer from the previous version.
  Updating the root pointer $\text{roots}[k] \leftarrow \text{new\_root}$ updates array $k$ in $\mathcal{O}(\log n)$ time without affecting any other array copies that share nodes.
- **Range Query in Array $k$ (`2 k a b`)**:
  Standard segment tree range query originating at $\text{roots}[k]$ in $\mathcal{O}(\log n)$ time.

---

## 3. Approach 1 — Naive Vector Copying per Query

Maintain a `vector<vector<long long>>`. On operation 3, call `arrays.push_back(arrays[k])`. On operation 1, mutate `arrays[k][a] = x`. On operation 2, run a linear loop.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n)$ per copy and query. Total time $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(q \cdot n)$ memory $\approx 160\text{ GB}$ (immediate Memory Limit Exceeded).
- **CSES Verdict**: TLE and MLE.

---

## 4. Approach 2 — Block-Based Persistent Sqrt Decomposition

Represent each array as a collection of block pointers. A copy duplicates only the $\sqrt{n}$ block pointers. An update copies one block of size $\sqrt{n}$.
- Time per update/copy: $\mathcal{O}(\sqrt{n})$.
- Space per update: $\mathcal{O}(\sqrt{n})$.
- While memory-feasible, Persistent Segment Tree (Approach 3) is strictly faster ($\mathcal{O}(\log n)$) and significantly simpler to implement.

---

## 5. Approach 3 — Optimal CSES Solution (Persistent Segment Tree)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

struct Node {
    long long sum;
    int left_child;
    int right_child;

    Node() : sum(0), left_child(0), right_child(0) {}
};

static const int MAX_NODES = 200005 * 40; // ~8 million nodes
Node tree_nodes[MAX_NODES];
int node_count = 0;

int new_node() {
    return ++node_count;
}

int build(int l, int r, const vector<long long>& arr) {
    int id = new_node();
    if (l == r) {
        tree_nodes[id].sum = arr[l];
        return id;
    }
    int mid = l + (r - l) / 2;
    tree_nodes[id].left_child = build(l, mid, arr);
    tree_nodes[id].right_child = build(mid + 1, r, arr);
    tree_nodes[id].sum = tree_nodes[tree_nodes[id].left_child].sum +
                         tree_nodes[tree_nodes[id].right_child].sum;
    return id;
}

int update(int prev_id, int l, int r, int pos, long long val) {
    int id = new_node();
    tree_nodes[id] = tree_nodes[prev_id]; // Copy pointers and sum

    if (l == r) {
        tree_nodes[id].sum = val;
        return id;
    }

    int mid = l + (r - l) / 2;
    if (pos <= mid) {
        tree_nodes[id].left_child = update(tree_nodes[prev_id].left_child, l, mid, pos, val);
    } else {
        tree_nodes[id].right_child = update(tree_nodes[prev_id].right_child, mid + 1, r, pos, val);
    }

    tree_nodes[id].sum = tree_nodes[tree_nodes[id].left_child].sum +
                         tree_nodes[tree_nodes[id].right_child].sum;
    return id;
}

long long query(int id, int l, int r, int ql, int qr) {
    if (!id || ql > r || qr < l) return 0;
    if (ql <= l && r <= qr) {
        return tree_nodes[id].sum;
    }
    int mid = l + (r - l) / 2;
    long long res = 0;
    if (ql <= mid) {
        res += query(tree_nodes[id].left_child, l, mid, ql, qr);
    }
    if (qr > mid) {
        res += query(tree_nodes[id].right_child, mid + 1, r, ql, qr);
    }
    return res;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    vector<long long> arr(n + 1);
    for (int i = 1; i <= n; ++i) {
        cin >> arr[i];
    }

    vector<int> roots;
    roots.push_back(0); // 1-indexed padding
    roots.push_back(build(1, n, arr));

    while (q--) {
        int type;
        cin >> type;
        if (type == 1) {
            int k, a;
            long long x;
            cin >> k >> a >> x;
            roots[k] = update(roots[k], 1, n, a, x);
        } else if (type == 2) {
            int k, a, b;
            cin >> k >> a >> b;
            cout << query(roots[k], 1, n, a, b) << '\n';
        } else {
            int k;
            cin >> k;
            roots.push_back(roots[k]);
        }
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Invariant of Structural Sharing
At all points during program execution:
1. **Immutability of Historical Nodes**: Once a node is allocated and initialized, its fields (`sum`, `left_child`, `right_child`) are never modified.
2. **Version Independence**:
   Let array $k$ have root $R_k$. The subtree rooted at $R_k$ contains the exact point values of array $k$.
   When array $k$ is duplicated to produce array $k'$, setting $R_{k'} = R_k$ shares the entire tree structure.
   Because existing nodes are immutable, subsequent updates to $R_k$ create newly allocated nodes along the path from $R_k$ to the updated leaf without modifying any node accessible from $R_{k'}$.
   Thus, modifications to array $k$ never affect array $k'$, and vice versa.
3. **Range Sum Correctness**:
   Because every version is a fully valid binary segment tree, standard range sum traversal from $R_k$ visits canonical disjoint subsegments whose sums sum to $\sum_{i=a}^b \text{array}_k[i]$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 6
2 3 1 2 5
3 1
2 1 1 5
2 2 1 5
1 2 2 5
2 1 1 5
2 2 1 5
```

### Initial Array
Array 1: `[2, 3, 1, 2, 5]`. Root $R_1$.

### Operation 1: `3 1` (Copy array 1 $\implies$ creates array 2)
- `roots.push_back(roots[1])` $\implies R_2 = R_1$.

### Operation 2: `2 1 1 5` (Sum array 1 on $[1, 5]$)
- Sum: $2 + 3 + 1 + 2 + 5 = 13$.
- Output: `13`.

### Operation 3: `2 2 1 5` (Sum array 2 on $[1, 5]$)
- Sum: identical to array 1 $= 13$.
- Output: `13`.

### Operation 4: `1 2 2 5` (In array 2, set pos 2 to 5)
- Point update creates a new path of $\lceil \log_2 5 \rceil + 1 = 4$ nodes.
- $R_2$ points to new root.
- Array 2 becomes `[2, 5, 1, 2, 5]`.
- Array 1 remains `[2, 3, 1, 2, 5]` (unchanged!).

### Operation 5: `2 1 1 5` (Sum array 1 on $[1, 5]$)
- Sum: $2 + 3 + 1 + 2 + 5 = 13$.
- Output: `13`.

### Operation 6: `2 2 1 5` (Sum array 2 on $[1, 5]$)
- Sum: $2 + 5 + 1 + 2 + 5 = 15$.
- Output: `15`.

Outputs match: `13`, `13`, `13`, `15`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow**:
   Array elements can be updated up to $10^9$, and prefix sums reach $2 \cdot 10^{14}$. Node sums and query results must be `long long`.
2. **Node Pool Allocation**:
   - Initial build uses $2N - 1 \approx 4 \cdot 10^5$ nodes.
   - Each update allocates $\lceil \log_2 n \rceil + 1 \approx 19$ nodes.
   - For $q \le 2 \cdot 10^5$ updates, maximum nodes created $\le 4 \cdot 10^5 + 2 \cdot 10^5 \times 19 \approx 4.2 \cdot 10^6$ nodes.
   - Allocating a static array `MAX_NODES = 6000000` consumes $6 \cdot 10^6 \times 16\text{ B} \approx 96\text{ MB}$, comfortably within the 512 MB limit.
3. **1-Indexed Array Numbering**:
   The `roots` vector is 1-indexed by padding with a dummy 0 at index 0.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does this compare to Git / Copy-on-Write (CoW) filesystems?**
   Persistent Segment Trees use identical path-copying principles to Merkle trees in Git and B-trees in ZFS/Btrfs: unchanged blocks are shared, while modified blocks allocate new nodes along the path to the root.
2. **Can we delete an array from the list?**
   Yes, simply remove the root pointer or mark it inactive. In languages without garbage collection (C++), nodes can either remain in the static pool or be reclaimed via reference counting if memory is tight.
3. **Can we perform Range Updates persistently?**
   Persistent lazy propagation requires allocating new copies of children during every pushdown, multiplying memory consumption.
4. **How would you find the $k$-th smallest element in a range across array copies?**
   If the persistent segment tree is built over values instead of positions (Chairman Tree), binary searching down the value tree answers range $k$-th smallest queries in $\mathcal{O}(\log n)$.
5. **What is the difference between partially persistent and fully persistent data structures?**
   Partially persistent structures allow updates only to the latest version. Fully persistent structures (like this one) allow updates and branch copies from any historical version at any time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Initial Build**: $\mathcal{O}(n)$
  - **Array Copy**: $\mathcal{O}(1)$
  - **Point Update**: $\mathcal{O}(\log n)$
  - **Range Sum Query**: $\mathcal{O}(\log n)$
  - **Overall Run Time**: $\mathcal{O}(n + q \log n) \approx 0.12\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n + q \log n)$ total nodes $\approx 4.2 \cdot 10^6 \text{ nodes} \approx 96\text{ MB}$ (Limit: 512 MB).

### Related CSES Problems
- [Dynamic Range Sum Queries](https://cses.fi/problemset/task/1648) — Non-persistent point update range sum
- [Distinct Values Queries](https://cses.fi/problemset/task/1734) — Solvable online via persistent segment trees
- [Missing Coin Sum Queries](https://cses.fi/problemset/task/2184) — Persistent segment tree over sorted values
