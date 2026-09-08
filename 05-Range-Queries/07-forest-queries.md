# Forest Queries

- **Category**: Range Queries
- **CSES Task ID**: `1652`
- **CSES Problem Link**: [Forest Queries](https://cses.fi/problemset/task/1652)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an $n \times n$ grid representing a forest. Each square is either empty (`.`) or contains a tree (`*`).

Your task is to process $q$ queries. Each query gives the coordinates of a rectangular subgrid: upper-left corner $(y_1, x_1)$ and lower-right corner $(y_2, x_2)$, where $y$ is the row and $x$ is the column ($1$-indexed). For each query, calculate the **number of trees** inside the specified rectangle:
$$\sum_{r=y_1}^{y_2} \sum_{c=x_1}^{x_2} [\text{square } (r, c) \text{ contains a tree}]$$

### Input Format
- The first line contains two integers $n$ and $q$: the forest size and the number of queries.
- The next $n$ lines each contain $n$ characters describing the forest (`.` or `*`).
- The next $q$ lines each contain four integers $y_1, x_1, y_2, x_2$: the corners of the rectangle.

### Output Format
- For each query, print the number of trees inside the rectangle on a new line.

### Numerical Constraints
- $1 \le n \le 1000$
- $1 \le q \le 2 \cdot 10^5$
- $1 \le y_1 \le y_2 \le n$
- $1 \le x_1 \le x_2 \le n$

With $n \le 1000$ and $q \le 2 \cdot 10^5$, 2D prefix sums answer each query in strictly $\mathcal{O}(1)$ time, taking $\approx 0.05\text{s}$ total.

---

## 2. Intuition & Pattern Recognition

This is the standard **2D Prefix Sum (Summed-Area Table)** problem:
- Computing the number of trees by iterating over the rectangle takes $\mathcal{O}((y_2 - y_1 + 1)(x_2 - x_1 + 1)) \le \mathcal{O}(n^2) \approx 10^6$ operations per query, leading to $\mathcal{O}(q \cdot n^2) \approx 2 \cdot 10^{11}$ operations (TLE).
- **2D Prefix Sum Formulation**:
  Let $\text{pref}[r][c]$ denote the total number of trees in the subgrid from top-left $(1, 1)$ to bottom-right $(r, c)$.
- **Precomputation (Inclusion-Exclusion)**:
  To compute $\text{pref}[r][c]$:
  $$\text{pref}[r][c] = \text{pref}[r - 1][c] + \text{pref}[r][c - 1] - \text{pref}[r - 1][c - 1] + \text{is\_tree}[r][c]$$
  We add the top rectangle and left rectangle, subtract their double-counted intersection, and add the current cell $(r, c)$.
- **Rectangle Query (Inclusion-Exclusion)**:
  To query the rectangle from $(y_1, x_1)$ to $(y_2, x_2)$:
  $$\text{Ans} = \text{pref}[y_2][x_2] - \text{pref}[y_1 - 1][x_2] - \text{pref}[y_2][x_1 - 1] + \text{pref}[y_1 - 1][x_1 - 1]$$
  We take the full rectangle up to $(y_2, x_2)$, remove the region above $y_1$, remove the region left of $x_1$, and add back the doubly subtracted top-left corner.
  This runs in strictly $\mathcal{O}(1)$ time.

---

## 3. Approach 1 — Naive Subgrid Scan per Query

Iterate through all rows $r \in [y_1, y_2]$ and columns $c \in [x_1, x_2]$ per query.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n^2) \approx 2 \cdot 10^{11}$ operations.
- **Space Complexity**: $\mathcal{O}(n^2)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — 1D Prefix Sums on Each Row

Precompute 1D prefix sums for each row, querying each row in $\mathcal{O}(1)$.
- **Complexity**: $\mathcal{O}(n^2)$ precomputation, $\mathcal{O}(y_2 - y_1 + 1) = \mathcal{O}(n)$ per query $\implies \mathcal{O}(q \cdot n) \approx 2 \cdot 10^8$ operations.
- **Verdict**: Marginal or TLE. 2D Prefix Sums (Approach 3) achieve $\mathcal{O}(1)$ query time.

---

## 5. Approach 3 — Optimal CSES Solution (2D Prefix Sums)

1. Maintain 2D array `pref[n + 1][n + 1]` initialized to 0.
2. Read grid row by row:
   ```cpp
   pref[r][c] = pref[r - 1][c] + pref[r][c - 1] - pref[r - 1][c - 1] + (ch == '*' ? 1 : 0);
   ```
3. For each query $(y_1, x_1, y_2, x_2)$:
   ```cpp
   int ans = pref[y2][x2] - pref[y1 - 1][x2] - pref[y2][x1 - 1] + pref[y1 - 1][x1 - 1];
   cout << ans << '\n';
   ```

```cpp
#include <iostream>
#include <vector>
#include <string>

using namespace std;

int pref[1005][1005];

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    for (int r = 1; r <= n; ++r) {
        string row;
        cin >> row;
        for (int c = 1; c <= n; ++c) {
            int is_tree = (row[c - 1] == '*') ? 1 : 0;
            pref[r][c] = pref[r - 1][c] + pref[r][c - 1] - pref[r - 1][c - 1] + is_tree;
        }
    }

    while (q--) {
        int y1, x1, y2, x2;
        cin >> y1 >> x1 >> y2 >> x2;

        int ans = pref[y2][x2] - pref[y1 - 1][x2] - pref[y2][x1 - 1] + pref[y1 - 1][x1 - 1];
        cout << ans << '\n';
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**:
  - Precomputation: $\mathcal{O}(n^2) = 1000 \times 1000 = 10^6$ operations $\approx 0.01\text{s}$.
  - Answering $q$ queries: $2 \cdot 10^5 \times \mathcal{O}(1) \approx 0.04\text{s}$.
  - Total Time: $\mathcal{O}(n^2 + q) \approx 0.05\text{s}$.
- **Space Complexity**: $\mathcal{O}(n^2)$ to store the 2D prefix array ($\approx 4\text{ MB}$).

---

## 6. Correctness Proof

### The 2D Principle of Inclusion-Exclusion
- **Geometric Dissection**:
  Let $R(y, x)$ denote the rectangle $[1, y] \times [1, x]$, and let $|R(y, x)| = \text{pref}[y][x]$ be the number of trees in $R(y, x)$.
  The query rectangle is $Q = [y_1, y_2] \times [x_1, x_2]$.
  Notice that:
  $$R(y_2, x_2) = Q \cup R(y_1 - 1, x_2) \cup R(y_2, x_1 - 1)$$
  The union of the two excluded regions is:
  $$R(y_1 - 1, x_2) \cup R(y_2, x_1 - 1)$$
  Their intersection is the region $[1, y_1 - 1] \times [1, x_1 - 1] = R(y_1 - 1, x_1 - 1)$.
  By the Principle of Inclusion-Exclusion for measures:
  $$|R(y_1 - 1, x_2) \cup R(y_2, x_1 - 1)| = |R(y_1 - 1, x_2)| + |R(y_2, x_1 - 1)| - |R(y_1 - 1, x_1 - 1)|$$
  Subtracting this from $|R(y_2, x_2)|$ yields:
  $$|Q| = |R(y_2, x_2)| - |R(y_1 - 1, x_2)| - |R(y_2, x_1 - 1)| + |R(y_1 - 1, x_1 - 1)|$$
  This matches the query formula identically. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 4, q = 1$:
```
.*..
*.**
**..
****
```
- Query: $y_1 = 2, x_1 = 2, y_2 = 3, x_2 = 4$ (middle $2 \times 3$ subgrid):
  - Row 2, cols 2-4: `. * *` (2 trees)
  - Row 3, cols 2-4: `* . .` (1 tree)
  - Expected: $2 + 1 = 3$ trees.
- Prefix table calculation:
  - $\text{pref}[3][4] = 6$ (total trees in rows 1..3, cols 1..4)
  - $\text{pref}[1][4] = 1$ (trees in row 1, cols 1..4)
  - $\text{pref}[3][1] = 2$ (trees in rows 1..3, col 1)
  - $\text{pref}[1][1] = 0$ (trees in (1, 1))
- Evaluation:
  $$\text{ans} = 6 - 1 - 2 + 0 = 3$$
- Output: `3`. Exact match!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Upper/Left Boundaries ($y_1 = 1$ or $x_1 = 1$)**:
   When $y_1 = 1$, $y_1 - 1 = 0$. The prefix table is initialized with zeros along row 0 and column 0, so $\text{pref}[0][c] = 0$ and $\text{pref}[r][0] = 0$, requiring no conditional branching.
2. **Full Grid Query ($y_1=1, x_1=1, y_2=n, x_2=n$)**:
   Evaluates to $\text{pref}[n][n] - 0 - 0 + 0 = \text{pref}[n][n]$.
3. **Single Cell Query ($y_1 = y_2, x_1 = x_2$)**:
   Computes the presence of a tree in that exact cell (0 or 1).
4. **Range Bounds**:
   Max trees in $1000 \times 1000$ grid is $10^6$, fitting comfortably in 32-bit signed `int`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the grid supports dynamic cell updates (Forest Queries II)?**
   Prefix sums degrade to $\mathcal{O}(n^2)$ per update. Use a **2D Fenwick Tree (2D BIT)** or **2D Segment Tree** to support $\mathcal{O}(\log^2 n)$ updates and queries (see CSES Forest Queries II).
2. **How does this generalize to $D$-dimensional hypercubes?**
   $D$-dimensional prefix sums use $2^D$ terms in the inclusion-exclusion query formula:
   $\sum_{b \in \{0, 1\}^D} (-1)^{D - \sum b_i} \text{pref}[p_1 - (1 - b_1), \dots, p_D - (1 - b_D)]$.
3. **What is a Summed-Area Table in Computer Vision?**
   Crow (1984) introduced 2D prefix sums under the name "Summed-Area Table" to compute box filters and image convolutions in $\mathcal{O}(1)$ time per pixel regardless of filter kernel size.
4. **How do 2D difference arrays work?**
   To add $v$ to a subgrid $[y_1, x_1]$ to $[y_2, x_2]$: modify 4 cells: $+v$ at $(y_1, x_1)$, $-v$ at $(y_1, x_2+1)$, $-v$ at $(y_2+1, x_1)$, and $+v$ at $(y_2+1, x_2+1)$.
5. **How do you find the maximum sum subgrid in an $n \times m$ matrix?**
   Kadane's algorithm across pairs of rows in $\mathcal{O}(n^2 m)$ time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Range Queries, 2D Prefix Sums, Summed-Area Table, Inclusion-Exclusion, $\mathcal{O}(1)$ Query
- **Complexity Summary**:
  - Time: $\mathcal{O}(n^2 + q)$
  - Space: $\mathcal{O}(n^2)$
- **Related CSES Problems**:
  - [Static Range Sum Queries](https://cses.fi/problemset/task/1646) — 1D prefix sums
  - [Forest Queries II](https://cses.fi/problemset/task/1739) — Dynamic 2D range sums with 2D Fenwick Tree
  - [Counting Rooms](https://cses.fi/problemset/task/1192) — Grid component traversal
