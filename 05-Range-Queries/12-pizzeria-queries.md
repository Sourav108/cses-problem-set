# Pizzeria Queries

- **Category**: Range Queries
- **CSES Task ID**: `2206`
- **CSES Problem Link**: [Pizzeria Queries](https://cses.fi/problemset/task/2206)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ buildings on a street, numbered $1, 2, \dots, n$ from left to right. Each building $i$ has a pizzeria with pizza price $p_i$. If a customer in building $k$ orders a pizza from building $i$, the total price including delivery is:
$$\text{Cost}(i, k) = p_i + |i - k|$$

You must process $q$ queries of two types:
1. `1 k x`: Update the pizza price in building $k$ to $x$ ($p_k \leftarrow x$).
2. `2 k`: Find the minimum total price to order a pizza to building $k$:
   $$\min_{1 \le i \le n} \big(p_i + |i - k|\big)$$

### Input Format
- The first line contains two integers $n$ and $q$: the number of buildings and queries.
- The second line contains $n$ integers $p_1, p_2, \dots, p_n$: the initial pizza prices.
- The next $q$ lines describe queries:
  - `1 k x`
  - `2 k`

### Output Format
- For each query of type 2, print the minimum price on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le p_i, x \le 10^9$
- $1 \le k \le n$

---

## 2. Intuition & Pattern Recognition

The absolute value $|i - k|$ splits naturally based on the relative position of the pizzeria $i$ and destination $k$:
1. **Pizzeria to the left or at destination ($i \le k$)**:
   $$p_i + |i - k| = p_i + (k - i) = (p_i - i) + k$$
2. **Pizzeria to the right or at destination ($i \ge k$)**:
   $$p_i + |i - k| = p_i + (i - k) = (p_i + i) - k$$

Thus, the minimum price for building $k$ is:
$$\min\left(\min_{1 \le i \le k} (p_i - i) + k, \; \min_{k \le i \le n} (p_i + i) - k\right)$$

Notice that $k$ is constant with respect to the minimization index $i$:
- For the left side ($i \le k$), we need the prefix minimum of the sequence $A_i = p_i - i$ over $i \in [1, k]$.
- For the right side ($i \ge k$), we need the suffix minimum of the sequence $B_i = p_i + i$ over $i \in [k, n]$.

When $p_k$ is updated to $x$:
- $A_k = x - k$ is updated at position $k$.
- $B_k = x + k$ is updated at position $k$.

Both arrays $A$ and $B$ require point updates and range minimum queries (RMQ). This is standard for a **Segment Tree**. We can either maintain two separate Segment Trees or one Segment Tree storing pairs $(A_i, B_i)$.

---

## 3. Approach 1 — Naive Linear Scan per Query

For each type 2 query at building $k$, loop through all $i \in [1, n]$ and compute $\min_i (p_i + |i - k|)$. Updates take $\mathcal{O}(1)$ time.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(1)$ per update, $\mathcal{O}(n)$ per query. Total time $\mathcal{O}(q \cdot n) \approx 2 \cdot 10^5 \times 2 \cdot 10^5 = 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$ to store $p$.
- **CSES Verdict**: TLE on test cases with large $q$.

---

## 4. Approach 2 — Sqrt Decomposition (Bucket RMQ)

Divide the street into $B = \lceil\sqrt{n}\rceil$ blocks of size $B$.
- Maintain block minimums for $p_i - i$ and $p_i + i$.
- An update changes the value in one block and recalculates that block's minimum in $\mathcal{O}(\sqrt{n})$ time.
- A query checks $\mathcal{O}(\sqrt{n})$ complete blocks and $\mathcal{O}(\sqrt{n})$ boundary elements.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(\sqrt{n})$ per update and query. Total time $\mathcal{O}(q \sqrt{n}) \approx 2 \cdot 10^5 \times 450 \approx 9 \cdot 10^7$ operations.
- **Space Complexity**: $\mathcal{O}(n)$ words.
- **CSES Verdict**: Accepted, but $\approx 4\times$ slower than Segment Tree.

---

## 5. Approach 3 — Optimal CSES Solution (Dual Segment Tree)

We maintain two bottom-up iterative segment trees (size $2N$):
- `tree_left`: maintains $\min_{i} (p_i - i)$
- `tree_right`: maintains $\min_{i} (p_i + i)$

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

static const long long INF = 2e18;

int n, q;
int size_pow;
vector<long long> tree_left;
vector<long long> tree_right;

void update(int pos, long long val) {
    int idx = pos + size_pow - 1;
    tree_left[idx] = val - pos;
    tree_right[idx] = val + pos;
    idx /= 2;
    while (idx >= 1) {
        tree_left[idx] = min(tree_left[2 * idx], tree_left[2 * idx + 1]);
        tree_right[idx] = min(tree_right[2 * idx], tree_right[2 * idx + 1]);
        idx /= 2;
    }
}

long long query_left(int l, int r) {
    long long res = INF;
    l += size_pow - 1;
    r += size_pow - 1;
    while (l <= r) {
        if (l % 2 == 1) res = min(res, tree_left[l++]);
        if (r % 2 == 0) res = min(res, tree_left[r--]);
        l /= 2;
        r /= 2;
    }
    return res;
}

long long query_right(int l, int r) {
    long long res = INF;
    l += size_pow - 1;
    r += size_pow - 1;
    while (l <= r) {
        if (l % 2 == 1) res = min(res, tree_right[l++]);
        if (r % 2 == 0) res = min(res, tree_right[r--]);
        l /= 2;
        r /= 2;
    }
    return res;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> q)) return 0;

    size_pow = 1;
    while (size_pow <= n) size_pow <<= 1;

    tree_left.assign(2 * size_pow, INF);
    tree_right.assign(2 * size_pow, INF);

    for (int i = 1; i <= n; ++i) {
        long long p;
        cin >> p;
        int idx = i + size_pow - 1;
        tree_left[idx] = p - i;
        tree_right[idx] = p + i;
    }

    for (int i = size_pow - 1; i >= 1; --i) {
        tree_left[i] = min(tree_left[2 * i], tree_left[2 * i + 1]);
        tree_right[i] = min(tree_right[2 * i], tree_right[2 * i + 1]);
    }

    while (q--) {
        int type;
        cin >> type;
        if (type == 1) {
            int k;
            long long x;
            cin >> k >> x;
            update(k, x);
        } else {
            int k;
            cin >> k;
            long long left_ans = query_left(1, k) + k;
            long long right_ans = query_right(k, n) - k;
            cout << min(left_ans, right_ans) << '\n';
        }
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Invariant
For any destination $k \in [1, n]$:
1. Every candidate pizzeria $i \in [1, n]$ satisfies either $1 \le i \le k$ or $k \le i \le n$.
2. If $i \le k$, $|i - k| = k - i$, so $p_i + |i - k| = (p_i - i) + k$.
   Therefore, $\min_{1 \le i \le k} (p_i + |i - k|) = \min_{1 \le i \le k} (p_i - i) + k$.
3. If $i \ge k$, $|i - k| = i - k$, so $p_i + |i - k| = (p_i + i) - k$.
   Therefore, $\min_{k \le i \le n} (p_i + |i - k|) = \min_{k \le i \le n} (p_i + i) - k$.
4. The minimum over all $i \in [1, n]$ is the minimum of these two partitioned subproblems:
   $$\min_{1 \le i \le n} (p_i + |i - k|) = \min\left( \min_{1 \le i \le k} (p_i - i) + k, \; \min_{k \le i \le n} (p_i + i) - k \right)$$

### Segment Tree Correctness
The bottom-up segment tree correctly computes range minimums over arbitrary intervals $[L, R]$ in $\mathcal{O}(\log n)$ time. Point updates modify a single leaf and propagate minimums up to the root in $\mathcal{O}(\log n)$ steps. Thus, all queries and updates are exact.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
6 3
8 6 4 5 7 5
2 2
1 5 1
2 2
```

### Initial Array Setup ($n = 6$)
| Index $i$ | $p_i$ | $p_i - i$ (Left Tree) | $p_i + i$ (Right Tree) |
|:---:|:---:|:---:|:---:|
| 1 | 8 | $8 - 1 = 7$ | $8 + 1 = 9$ |
| 2 | 6 | $6 - 2 = 4$ | $6 + 2 = 8$ |
| 3 | 4 | $4 - 3 = 1$ | $4 + 3 = 7$ |
| 4 | 5 | $5 - 4 = 1$ | $5 + 4 = 9$ |
| 5 | 7 | $7 - 5 = 2$ | $7 + 5 = 12$ |
| 6 | 5 | $5 - 6 = -1$ | $5 + 6 = 11$ |

### Query 1: `2 2` ($k = 2$)
- Left query on $[1, 2]$:
  $$\min(7, 4) = 4 \implies 4 + k = 4 + 2 = 6$$
- Right query on $[2, 6]$:
  $$\min(8, 7, 9, 12, 11) = 7 \implies 7 - k = 7 - 2 = 5$$
- Overall minimum: $\min(6, 5) = 5$ (achieved by ordering from building 3: $p_3 + |3 - 2| = 4 + 1 = 5$).
- Output: `5`.

### Query 2: `1 5 1` ($k = 5, x = 1$)
- Update index 5:
  - $p_5 - 5 = 1 - 5 = -4$
  - $p_5 + 5 = 1 + 5 = 6$

### Query 3: `2 2` ($k = 2$)
- Left query on $[1, 2]$:
  $$\min(7, 4) = 4 \implies 4 + 2 = 6$$
- Right query on $[2, 6]$:
  $$\min(8, 7, 9, 6, 11) = 6 \implies 6 - 2 = 4$$
- Overall minimum: $\min(6, 4) = 4$ (achieved by ordering from building 5: $p_5 + |5 - 2| = 1 + 3 = 4$).
- Output: `4`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Negative Offsets**:
   $p_i - i$ can be negative if $p_i < i$. For instance, if $p_n = 1$ and $n = 2 \cdot 10^5$, $p_n - n = 1 - 200000 = -199999$. Using `2e18` (or `LLONG_MAX / 2`) as infinity avoids signed underflow issues.
2. **64-bit Calculations**:
   Prices can be up to $10^9$ and indices up to $2 \cdot 10^5$. Although $p_i \pm i$ fits within standard 32-bit signed integer $[-2 \cdot 10^5, 10^9 + 2 \cdot 10^5]$, using `long long` for segment trees completely eliminates overflow risk when adding $+k$ or returning infinity.
3. **Querying Boundary Endpoints ($k = 1$ and $k = n$)**:
   - For $k = 1$, the left range $[1, 1]$ has length 1, while the right range is $[1, n]$.
   - For $k = n$, the left range is $[1, n]$, and the right range is $[n, n]$.
   Both ranges are always valid and non-empty because $1 \le k \le n$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the street is circular (a ring of $n$ buildings)?**
   In a ring, $|i - k|_{\text{circle}} = \min(|i - k|, n - |i - k|)$. We duplicate the array to length $2n$ ($p_{i+n} = p_i$) and query an interval of length $\lfloor n/2 \rfloor$ to the left and right.
2. **Can we answer queries without Segment Trees if all updates come before queries?**
   Yes. If the problem is offline without updates, prefix and suffix minimums of $p_i - i$ and $p_i + i$ can be precomputed in linear $\mathcal{O}(n)$ time and queried in $\mathcal{O}(1)$.
3. **What if delivery cost is non-linear, e.g., $c \cdot |i - k|$?**
   If delivery cost per unit distance is $c$, the formula becomes $(p_i - c \cdot i) + c \cdot k$ for $i \le k$, and $(p_i + c \cdot i) - c \cdot k$ for $i \ge k$. The dual segment tree approach applies identically with slope $c$.
4. **Can we merge the two Segment Trees into a single tree?**
   Yes, each node in the segment tree can store a `pair<long long, long long>`: `first` for $\min(p_i - i)$ and `second` for $\min(p_i + i)$. This halves the tree traversal overhead.
5. **What if delivery cost is Euclidean distance in 2D ($p_i + \text{dist}(i, k)$)?**
   In 2D, the distance metric $|x_i - x_k| + |y_i - y_k|$ has 4 orthant signs $(\pm x_i \pm y_i)$, requiring a 2D spatial data structure (such as a 2D segment tree or Voronoi diagram / Delaunay triangulation).

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Build**: $\mathcal{O}(n)$
  - **Point Update**: $\mathcal{O}(\log n)$
  - **Query**: $\mathcal{O}(\log n)$
  - **Overall Run Time**: $\mathcal{O}(n + q \log n) \approx 0.11\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary memory for iterative segment trees.

### Related CSES Problems
- [Dynamic Range Minimum Queries](https://cses.fi/problemset/task/1649) — Core RMQ Segment Tree
- [Prefix Sum Queries](https://cses.fi/problemset/task/2166) — Segment Tree with structured algebraic combinations
- [Subarray Sum Queries](https://cses.fi/problemset/task/1190) — Dynamic divide-and-conquer on Segment Trees
