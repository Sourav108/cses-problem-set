# Nested Ranges Check (CSES Task 2168 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 2168 - Nested Ranges Check](https://cses.fi/problemset/task/2168)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Given $n$ ranges $[x_i, y_i]$, determine for each range if it contains some other range, and if some other range contains it. Range $[a, b]$ contains range $[c, d]$ if $a \le c$ and $d \le b$.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le x_i < y_i \le 10^9$. No range appears more than once.

---

## 1. Problem, Restated

Given $n$ intervals $[x_1, y_1], [x_2, y_2], \dots, [x_n, y_n]$:
For each interval $i \in [0, n-1]$, compute two boolean answers:
1. `contains[i] = 1` if there exists another interval $j \ne i$ such that $[x_j, y_j] \subseteq [x_i, y_i]$ ($x_i \le x_j$ and $y_j \le y_i$). Otherwise `0`.
2. `contained[i] = 1` if there exists another interval $j \ne i$ such that $[x_i, y_i] \subseteq [x_j, y_j]$ ($x_j \le x_i$ and $y_i \le y_j$). Otherwise `0`.

**Input**:
- First line: integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Next $n$ lines: two integers $x_i$ and $y_i$.

**Output**:
- First line: $n$ space-separated integers describing `contains` in the original input order.
- Second line: $n$ space-separated integers describing `contained` in the original input order.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Custom 2D Sorting / Sweep-Line / Running Min-Max Optimization / Dominance Counting.
- **Aha! Insight**:
  - The condition that range $A = [x_A, y_A]$ contains range $B = [x_B, y_B]$ is:
    $$x_A \le x_B \quad \text{AND} \quad y_A \ge y_B$$
  - How can we eliminate one of the two dimensions?
  - **The Sorting Trick**:
    Sort all ranges primarily by **$x$ in ascending order**.
    If two ranges have identical $x$, sort by **$y$ in descending order**:
    $$(x_A < x_B) \quad \text{or} \quad (x_A == x_B \land y_A > y_B)$$
  - **Why does this specific tie-breaker work?**
    - If range $A$ contains range $B$, then $x_A \le x_B$ and $y_A \ge y_B$.
    - If $x_A < x_B$, $A$ precedes $B$.
    - If $x_A == x_B$, then $y_A > y_B$ (since all ranges are distinct), so $A$ ALSO precedes $B$!
    - **Conclusion**: If range $A$ contains range $B$, then **$A$ is guaranteed to appear before $B$ in our sorted sequence!**
  - Consequently:
    1. **Does some earlier range contain range $i$?**
       Since all preceding ranges $j < i$ satisfy $x_j \le x_i$, range $j$ contains range $i$ if and only if $y_j \ge y_i$.
       This requires:
       $$\max_{j < i} y_j \ge y_i$$
       A single **left-to-right sweep** maintaining the running maximum of $y$ solves this!
    2. **Does range $i$ contain some later range?**
       Since all succeeding ranges $j > i$ satisfy $x_i \le x_j$, range $i$ contains range $j$ if and only if $y_j \le y_i$.
       This requires:
       $$\min_{j > i} y_j \le y_i$$
       A single **right-to-left sweep** maintaining the running minimum of $y$ solves this!
  - No complex trees or advanced 2D data structures are needed—just sort and run two linear scans!
- **Signal**: 2D range containment $(x_i \le x_j \land y_j \le y_i)$ is simplified to 1D prefix/suffix extrema by sorting by $(x \uparrow, y \downarrow)$.

---

## 3. Approach 1 — Naive / Baseline (Pairwise Quadratic Comparison)

Compare every pair of ranges $(i, j)$ in $\mathcal{O}(n^2)$ time.
For $n = 2 \cdot 10^5$, $\frac{n^2}{2} = 2 \cdot 10^{10}$ operations $\implies$ TLE.

---

## 4. Approach 2 — Intermediate (Fenwick Tree / Segment Tree on Compressed $y$)

Coordinate-compress the $y$-coordinates and query a Fenwick Tree.
While $\mathcal{O}(n \log n)$, Fenwick Trees are only necessary when *counting* the number of containing ranges (CSES 2169). For boolean existence checks, running extrema (Approach 3) is strictly simpler and faster.

---

## 5. Approach 3 — Optimal CSES Solution (Custom Sort + Prefix/Suffix Extrema)

### Idea
1. Represent each range as a struct containing `x`, `y`, and `id` (original 0-based index).
2. Sort with comparator: `a.x != b.x ? a.x < b.x : a.y > b.y`.
3. Left-to-right pass for `contained`: maintain `max_y`. If `max_y >= current.y`, set `contained[current.id] = 1`. Update `max_y = max(max_y, current.y)`.
4. Right-to-left pass for `contains`: maintain `min_y`. If `min_y <= current.y`, set `contains[current.id] = 1`. Update `min_y = min(min_y, current.y)`.
5. Output both boolean vectors.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Range {
    int x, y, id;
};

bool cmp(const Range& a, const Range& b) {
    if (a.x != b.x) return a.x < b.x;
    return a.y > b.y; // Tie-breaker: larger y comes first
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<Range> ranges(n);
    for (int i = 0; i < n; ++i) {
        cin >> ranges[i].x >> ranges[i].y;
        ranges[i].id = i;
    }

    sort(ranges.begin(), ranges.end(), cmp);

    vector<int> contains(n, 0);
    vector<int> contained(n, 0);

    // Pass 1: Check if range contains some other range (scan right to left)
    int min_y = 2e9 + 7;
    for (int i = n - 1; i >= 0; --i) {
        if (min_y <= ranges[i].y) {
            contains[ranges[i].id] = 1;
        }
        min_y = min(min_y, ranges[i].y);
    }

    // Pass 2: Check if some other range contains this range (scan left to right)
    int max_y = 0;
    for (int i = 0; i < n; ++i) {
        if (max_y >= ranges[i].y) {
            contained[ranges[i].id] = 1;
        }
        max_y = max(max_y, ranges[i].y);
    }

    // Output Line 1: contains
    for (int i = 0; i < n; ++i) {
        cout << contains[i] << (i + 1 == n ? '\n' : ' ');
    }

    // Output Line 2: contained
    for (int i = 0; i < n; ++i) {
        cout << contained[i] << (i + 1 == n ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$ to sort the $n$ ranges. The two linear sweeps take $\mathcal{O}(n)$ time. For $n = 2 \cdot 10^5$, total operations $\approx 3.6 \times 10^6$, executing in $\approx 0.08$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ memory for `ranges`, `contains`, and `contained` arrays.

---

## 6. Correctness Proof

1. **Ordering Invariant**:
   Let the sorted sequence of ranges be $R_0, R_1, \dots, R_{n-1}$.
   Suppose range $A$ contains range $B$ ($x_A \le x_B$ and $y_B \le y_A$).
   - If $x_A < x_B$, $A$ strictly precedes $B$ by primary key.
   - If $x_A = x_B$, since all intervals are distinct, $y_A > y_B$. By our secondary key, $A$ strictly precedes $B$.
   - In all cases, $A$ appears before $B$ in the sorted sequence: $\text{pos}(A) < \text{pos}(B)$.
2. **Left-to-Right Contained Check**:
   For any index $i$, all ranges $j < i$ satisfy $x_j \le x_i$.
   Range $j$ contains $i$ if and only if $y_j \ge y_i$.
   The existence of such a range is equivalent to $\max_{j < i} y_j \ge y_i$.
   Because `max_y` maintains $\max_{j < i} y_j$, testing `max_y >= ranges[i].y` is an exact, necessary and sufficient condition.
3. **Right-to-Left Contains Check**:
   For any index $i$, any range contained in $i$ must have $j > i$.
   Since $j > i$, $x_i \le x_j$ automatically holds.
   Range $i$ contains $j$ if and only if $y_j \le y_i$.
   The existence of such a range is equivalent to $\min_{j > i} y_j \le y_i$.
   Because `min_y` maintains $\min_{j > i} y_j$, testing `min_y <= ranges[i].y` is an exact, necessary and sufficient condition. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input:
`[1, 6] (id 0)`, `[2, 4] (id 1)`, `[4, 8] (id 2)`, `[3, 6] (id 3)`.

Sorted by $(x \uparrow, y \downarrow)$:
- $i = 0$: `[1, 6]` (id 0)
- $i = 1$: `[2, 4]` (id 1)
- $i = 2$: `[3, 6]` (id 3)
- $i = 3$: `[4, 8]` (id 2)

**Pass 1 (`contains`, scan $i = 3 \to 0$ with `min_y`):**
- $i = 3$ (`[4, 8]`, id 2): $\text{min\_y} = \infty \implies$ `contains[2] = 0`. $\text{min\_y} \to 8$.
- $i = 2$ (`[3, 6]`, id 3): $8 \le 6$ (False) $\implies$ `contains[3] = 0`. $\text{min\_y} \to \min(8, 6) = 6$.
- $i = 1$ (`[2, 4]`, id 1): $6 \le 4$ (False) $\implies$ `contains[1] = 0`. $\text{min\_y} \to \min(6, 4) = 4$.
- $i = 0$ (`[1, 6]`, id 0): $4 \le 6$ (True!) $\implies$ `contains[0] = 1`.
Line 1: `1 0 0 0`.

**Pass 2 (`contained`, scan $i = 0 \to 3$ with `max_y`):**
- $i = 0$ (`[1, 6]`, id 0): $\text{max\_y} = 0 \ge 6$ (False) $\implies$ `contained[0] = 0`. $\text{max\_y} \to 6$.
- $i = 1$ (`[2, 4]`, id 1): $6 \ge 4$ (True!) $\implies$ `contained[1] = 1`. $\text{max\_y} \to \max(6, 4) = 6$.
- $i = 2$ (`[3, 6]`, id 3): $6 \ge 6$ (True!) $\implies$ `contained[3] = 1`. $\text{max\_y} \to 6$.
- $i = 3$ (`[4, 8]`, id 2): $6 \ge 8$ (False) $\implies$ `contained[2] = 0`. $\text{max\_y} \to 8$.
Line 2: `0 1 0 1`.

Matches the example output identically!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **CRITICAL: Secondary Sort on $y$**:
  - If $x$ is equal, $y$ MUST be sorted in descending order!
  - If $y$ were sorted ascending on equal $x$, a larger range would come after a smaller range, breaking the single-directional containment invariant.
- **Initialization of `min_y` and `max_y`**:
  `min_y` must be initialized to a value strictly larger than $10^9$ (e.g. $2 \cdot 10^9 + 7$).
  `max_y` must be initialized to $0$.
- **Fast I/O**: Outputting $4 \cdot 10^5$ integers requires fast I/O.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How to COUNT the number of containing/contained ranges (Nested Ranges Count)?**
   - This is **CSES 2169**! Instead of tracking `min_y` and `max_y`, we maintain the seen $y$-coordinates in a Fenwick Tree or PBDS `ordered_set` to count elements in $\mathcal{O}(\log n)$ time per range.
2. **What if duplicate ranges were allowed?**
   - We would adjust the strictly greater condition or treat identical intervals as mutually containing each other.
3. **How does this compare to finding the maximum number of mutually nested intervals?**
   - That transforms into the **Longest Decreasing Subsequence (LDS)** on the sorted $y$-coordinates, solvable in $\mathcal{O}(n \log n)$ via patience sorting.
4. **Can this problem be generalized to 3D boxes?**
   - 3D box nesting $(x_1 \le x_2 \land y_1 \le y_2 \land z_1 \le z_2)$ is solved using CDQ Divide and Conquer or 2D Segment Trees in $\mathcal{O}(n \log^2 n)$.
5. **How does this relate to Pareto Frontier / Skyline queries?**
   - Identifying non-dominated points in 2D is the foundation of Pareto frontier computations in computational geometry.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Sweep-Line, Custom Sorting, Extremum Tracking, Geometry, Intervals.
- **Time Complexity**: $\mathcal{O}(n \log n)$ sorting time.
- **Space Complexity**: $\mathcal{O}(n)$ storage for ranges and results.

### Related CSES Tasks
- [CSES 2169 - Nested Ranges Count](https://cses.fi/problemset/task/2169): Counting nested ranges with Fenwick / PBDS.
- [CSES 1619 - Restaurant Customers](https://cses.fi/problemset/task/1619): Sweep-line on intervals.
- [CSES 1629 - Movie Festival](https://cses.fi/problemset/task/1629): Greedy interval scheduling.
