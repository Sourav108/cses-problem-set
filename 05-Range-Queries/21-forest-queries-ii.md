# Forest Queries II

- **Category**: Range Queries
- **CSES Task ID**: `1739`
- **CSES Problem Link**: [Forest Queries II](https://cses.fi/problemset/task/1739)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an $n \times n$ grid representing a forest map. Each square $(y, x)$ is either empty (`.`) or contains a tree (`*`).

You must process $q$ queries of two types:
1. `1 y x`: Toggle the state of square $(y, x)$ (if it has a tree, remove it; if it is empty, place a tree).
2. `2 y1 x1 y2 x2`: Count the number of trees inside the subgrid rectangle with upper-left corner $(y_1, x_1)$ and lower-right corner $(y_2, x_2)$ ($y_1 \le y_2$ and $x_1 \le x_2$).

Both row ($y$) and column ($x$) indices are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the forest size and the number of queries.
- The next $n$ lines describe the forest: each line has $n$ characters (`.` or `*`).
- The next $q$ lines describe the queries:
  - `1 y x`
  - `2 y1 x1 y2 x2`

### Output Format
- For each query of type 2, print the number of trees in the queried rectangle on a new line.

### Numerical Constraints
- $1 \le n \le 1000$
- $1 \le q \le 2 \cdot 10^5$
- $1 \le y, x \le n$
- $1 \le y_1 \le y_2 \le n$
- $1 \le x_1 \le x_2 \le n$

---

## 2. Intuition & Pattern Recognition

In CSES *Forest Queries* (Task 1652), the grid was static, allowing $\mathcal{O}(1)$ rectangle queries using a 2D prefix sum array. Here, trees are dynamically toggled between queries, which would invalidate the prefix sum array.

Because $n \le 1000$, a 2D data structure can be allocated directly:
- A **2D Fenwick Tree (Binary Indexed Tree)** maintains 2D prefix sums:
  $$\text{query}(y, x) = \sum_{i=1}^y \sum_{j=1}^x \text{grid}[i][j]$$
- Updating cell $(y, x)$ by $\Delta \in \{+1, -1\}$ takes $\mathcal{O}(\log n \times \log n)$ time.
- Querying the 2D prefix sum $[1 \dots y] \times [1 \dots x]$ also takes $\mathcal{O}(\log n \times \log n)$ time.
- By the Principle of Inclusion-Exclusion, any arbitrary rectangular sum is computed via 4 prefix queries:
  $$\text{Rect}(y_1, x_1, y_2, x_2) = \text{query}(y_2, x_2) - \text{query}(y_1 - 1, x_2) - \text{query}(y_2, x_1 - 1) + \text{query}(y_1 - 1, x_1 - 1)$$

For $n \le 1000$, $\log_2(1000) \approx 10$, so each query executes at most $4 \times 10 \times 10 = 400$ additions, easily processing $2 \cdot 10^5$ queries in $\approx 0.05\text{s}$.

---

## 3. Approach 1 — 2D Array with Linear Row Sums

Maintain the grid. For each query 2, iterate over all rows from $y_1$ to $y_2$ and sum across columns $x_1$ to $x_2$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n^2)$ worst-case. Total operations $\approx 2 \cdot 10^5 \times 10^6 = 2 \cdot 10^{11}$.
- **Space Complexity**: $\mathcal{O}(n^2)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — 2D Segment Tree (Quadtree / Segment Tree of Segment Trees)

Maintain a 1D segment tree over rows, where each node is another segment tree over columns.
- While asymptotically $\mathcal{O}(\log^2 n)$, a 2D Segment Tree requires $4n \times 4n \approx 1.6 \cdot 10^7$ nodes ($\approx 64\text{ MB}$) with complex recursion overhead.
- A 2D Fenwick Tree (Approach 3) accomplishes the exact same complexity with flat arrays, zero pointer indirection, and minimal code.

---

## 5. Approach 3 — Optimal CSES Solution (2D Fenwick Tree)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <string>

using namespace std;

static const int MAXN = 1005;
int tree[MAXN][MAXN];
int grid[MAXN][MAXN];
int n, q;

void add(int y, int x, int delta) {
    for (int i = y; i <= n; i += i & -i) {
        for (int j = x; j <= n; j += j & -j) {
            tree[i][j] += delta;
        }
    }
}

int query_pref(int y, int x) {
    int sum = 0;
    for (int i = y; i > 0; i -= i & -i) {
        for (int j = x; j > 0; j -= j & -j) {
            sum += tree[i][j];
        }
    }
    return sum;
}

int query_rect(int y1, int x1, int y2, int x2) {
    return query_pref(y2, x2)
         - query_pref(y1 - 1, x2)
         - query_pref(y2, x1 - 1)
         + query_pref(y1 - 1, x1 - 1);
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> q)) return 0;

    for (int i = 1; i <= n; ++i) {
        string s;
        cin >> s;
        for (int j = 1; j <= n; ++j) {
            if (s[j - 1] == '*') {
                grid[i][j] = 1;
                add(i, j, 1);
            } else {
                grid[i][j] = 0;
            }
        }
    }

    while (q--) {
        int type;
        cin >> type;
        if (type == 1) {
            int y, x;
            cin >> y >> x;
            if (grid[y][x] == 1) {
                grid[y][x] = 0;
                add(y, x, -1);
            } else {
                grid[y][x] = 1;
                add(y, x, 1);
            }
        } else {
            int y1, x1, y2, x2;
            cin >> y1 >> x1 >> y2 >> x2;
            cout << query_rect(y1, x1, y2, x2) << '\n';
        }
    }

    return 0;
}
```

---

## 6. Correctness Proof

### 2D Binary Indexed Tree Property
Let $P(i)$ denote the interval of indices responsible for index $i$ in a 1D Fenwick tree: $(i - (i \mathbin{\&} -i), i]$.
By tensor product of two independent 1D Fenwick trees along the row and column dimensions, the cell `tree[i][j]` stores the sum of values inside the 2D bounding box:
$$\big(i - (i \mathbin{\&} -i), i\big] \times \big(j - (j \mathbin{\&} -j), j\big]$$
1. **Query Correctness**: Summing `tree[i][j]` over all ancestor indices generated by $i \leftarrow i - (i \mathbin{\&} -i)$ and $j \leftarrow j - (j \mathbin{\&} -j)$ forms a disjoint partition of the prefix rectangle $[1, y] \times [1, x]$.
2. **Update Correctness**: Any cell $(y, x)$ belongs to the responsibility box of $(i, j)$ if and only if $i$ is reached by $y \leftarrow y + (y \mathbin{\&} -y)$ and $j$ is reached by $x \leftarrow x + (x \mathbin{\&} -x)$. Updating all such coordinates maintains the prefix invariant everywhere.
3. **Inclusion-Exclusion**:
   $$\text{Area}([y_1, y_2] \times [x_1, x_2]) = [1, y_2] \times [1, x_2] - [1, y_1 - 1] \times [1, x_2] - [1, y_2] \times [1, x_1 - 1] + [1, y_1 - 1] \times [1, x_1 - 1]$$
   Every cell inside the rectangle is counted with net weight $+1 - 0 - 0 + 0 = 1$. Cells outside receive net weight 0. Thus, queries are exact.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
4 3
.*..
*.**
**..
****
2 2 2 3 4
1 3 3
2 2 2 3 4
```

### Initial Grid ($4 \times 4$)
```text
. * . .
* . * *
* * . .
* * * *
```

### Query 1: `2 2 2 3 4`
- Rectangle covers rows $2 \dots 3$, cols $2 \dots 4$:
  - Row 2: cols 2..4 are `. * *` $\implies 2$ trees.
  - Row 3: cols 2..4 are `* . .` $\implies 1$ tree.
- Total trees $= 2 + 1 = 3$.
- Output: `3`.

### Query 2: `1 3 3`
- Cell $(3, 3)$ is toggled: was `.` (0), becomes `*` (1).
- Call `add(3, 3, +1)`. Grid updated.

### Query 3: `2 2 2 3 4`
- Same rectangle:
  - Row 2: 2 trees.
  - Row 3: cols 2..4 are `* * .` $\implies 2$ trees.
- Total trees $= 2 + 2 = 4$.
- Output: `4`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **1x1 Rectangle ($y_1 = y_2$ and $x_1 = x_2$)**:
   The inclusion-exclusion formula simplifies to checking single cell $(y_1, x_1)$, returning 0 or 1 correctly.
2. **Boundary Indices ($y_1 = 1$ or $x_1 = 1$)**:
   When $y_1 = 1$, $y_1 - 1 = 0$. The function `query_pref(0, x)` immediately exits the loop and returns 0, avoiding invalid array indexing.
3. **Memory Consumption**:
   `tree[1005][1005]` uses $1005 \times 1005 \times 4\text{ B} \approx 4\text{ MB}$, perfectly bounded.
4. **Fast I/O**:
   With $q = 2 \cdot 10^5$, reading input and printing answers with `ios_base::sync_with_stdio(false); cin.tie(nullptr);` is crucial to complete within the 1.00s limit.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the grid dimension $n$ was up to $10^5$ instead of $1000$?**
   An explicit $10^5 \times 10^5$ array would consume $40\text{ GB}$. If the number of trees is sparse ($K \le 2 \cdot 10^5$), we must use a **Dynamic 2D Segment Tree** (Segment Tree with Treaps / Dynamic Fenwick), using $\mathcal{O}(K \log^2 n)$ memory.
2. **Can this structure support 2D range updates (e.g., toggle all cells in a rectangle)?**
   2D range updates with point queries use a difference 2D Fenwick tree. 2D range updates with 2D range queries require maintaining 4 separate 2D Fenwick trees.
3. **What if queries ask for the closest tree to a point $(y, x)$?**
   2D Fenwick trees only support algebraic abelian group operations (sums/counts), not nearest neighbor queries. Nearest neighbor requires 2D Kd-Trees or Voronoi diagrams.
4. **How would you find the total number of connected tree components dynamically?**
   Counting connected components under dynamic vertex additions and removals requires Dynamic Connectivity (Euler Tour Trees / Link-Cut Trees), which cannot be done with Fenwick trees.
5. **Can 2D Fenwick tree be extended to 3D?**
   Yes, a 3D Fenwick tree uses 3 nested loops with $\mathcal{O}(\log^3 n)$ per query and 8-term inclusion-exclusion.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Grid Loading**: $\mathcal{O}(n^2 \log^2 n)$ or $\mathcal{O}(n^2)$
  - **Per Point Update**: $\mathcal{O}(\log^2 n) \approx 100$ operations
  - **Per Rectangle Query**: $\mathcal{O}(\log^2 n) \approx 400$ operations
  - **Overall Run Time**: $\mathcal{O}(n^2 + q \log^2 n) \approx 0.05\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n^2)$ flat memory ($\approx 4\text{ MB}$).

### Related CSES Problems
- [Forest Queries](https://cses.fi/problemset/task/1652) — Static 2D prefix sums
- [Range Update Queries](https://cses.fi/problemset/task/1651) — 1D Fenwick Tree
- [Dynamic Range Sum Queries](https://cses.fi/problemset/task/1648) — 1D Point Update Range Sum
