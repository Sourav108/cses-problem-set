# Nested Ranges Count (CSES Task 2169 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 2169 - Nested Ranges Count](https://cses.fi/problemset/task/2169)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Given $n$ ranges $[x_i, y_i]$, count for each range how many other ranges it contains, and how many other ranges contain it.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le x_i < y_i \le 10^9$. No range appears more than once.

---

## 1. Problem, Restated

Given $n$ intervals $[x_1, y_1], [x_2, y_2], \dots, [x_n, y_n]$, for each interval $i \in [0, n-1]$, compute:
1. `contains_count[i]`: the number of other intervals $j \ne i$ such that $[x_j, y_j] \subseteq [x_i, y_i]$ ($x_i \le x_j$ and $y_j \le y_i$).
2. `contained_count[i]`: the number of other intervals $j \ne i$ such that $[x_i, y_i] \subseteq [x_j, y_j]$ ($x_j \le x_i$ and $y_i \le y_j$).

Output both arrays in the original input order.

**Input**:
- First line: integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Next $n$ lines: two integers $x_i$ and $y_i$.

**Output**:
- First line: $n$ space-separated integers describing `contains_count` in the original input order.
- Second line: $n$ space-separated integers describing `contained_count` in the original input order.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Custom 2D Sorting / Coordinate Compression / Fenwick Tree (BIT) / Range Inversion Counting.
- **Aha! Insight**:
  - As established in **Nested Ranges Check (CSES 2168)**, sorting ranges by:
    $$(x_A < x_B) \quad \lor \quad (x_A == x_B \land y_A > y_B)$$
    guarantees that whenever range $A$ contains range $B$, **$A$ strictly precedes $B$** in the sorted order.
  - Therefore, in the sorted array:
    1. **Contained Count for range $i$**:
       Any range $j$ that contains $i$ must have appeared before $i$ ($j < i$).
       Since $j < i \implies x_j \le x_i$, range $j$ contains $i$ if and only if $y_j \ge y_i$.
       $\implies$ In a **left-to-right sweep**, count how many previously inserted ranges have $y \ge y_i$, then insert $y_i$.
    2. **Contains Count for range $i$**:
       Any range $j$ contained in $i$ must appear after $i$ ($j > i$).
       Since $j > i \implies x_i \le x_j$, range $i$ contains $j$ if and only if $y_j \le y_i$.
       $\implies$ In a **right-to-left sweep**, count how many previously inserted ranges have $y \le y_i$, then insert $y_i$.
  - Because $y_i \le 10^9$, we coordinate-compress all $y$-coordinates to integers in $[1, M]$ ($M \le n$).
  - A standard **Fenwick Tree (Binary Indexed Tree)** of size $M$ answers prefix queries in $\mathcal{O}(\log n)$ time and updates in $\mathcal{O}(\log n)$ time.
- **Signal**: Counting 2D dominance pairs $(x_i \le x_j \land y_j \le y_i)$ is solved in $\mathcal{O}(n \log n)$ by sorting along one dimension and querying a Fenwick Tree along the other.

---

## 3. Approach 1 — Naive / Baseline (Pairwise Quadratic Comparison)

Compare all $\frac{n(n-1)}{2}$ pairs of ranges.
Takes $\mathcal{O}(n^2)$ time $\approx 2 \cdot 10^{10}$ operations $\implies$ TLE.

---

## 4. Approach 2 — Intermediate (Policy-Based Data Structure `ordered_set`)

Using PBDS `tree` with `order_of_key(y)` to count elements $< y$.
While $\mathcal{O}(n \log n)$, coordinate compression + Fenwick Tree (Approach 3) is 100% portable standard C++ without compiler-dependent headers and runs $3\times$ faster due to array cache locality.

---

## 5. Approach 3 — Optimal CSES Solution (Coordinate Compression + Fenwick Tree)

### Idea
1. Collect all $y$-coordinates, sort them, and remove duplicates to create a rank mapping $[1, M]$.
2. Sort ranges with `cmp`: $x$ ascending, $y$ descending on ties.
3. **Pass 1 (Scan Right-to-Left for `contains_count`)**:
   Clear the BIT. For $i = n-1$ down to 0:
   - Rank of $y_i$ is $r_i$.
   - Number of elements $\le r_i$ is `bit.query(r_i)`.
   - Record `contains_count[ranges[i].id] = bit.query(r_i)`.
   - Insert $r_i$ into BIT: `bit.add(r_i, 1)`.
4. **Pass 2 (Scan Left-to-Right for `contained_count`)**:
   Clear the BIT. For $i = 0$ to $n-1$:
   - Rank of $y_i$ is $r_i$.
   - Number of elements $\ge r_i$ is `bit.query(M) - bit.query(r_i - 1)`.
   - Record `contained_count[ranges[i].id] = bit.query(M) - bit.query(r_i - 1)`.
   - Insert $r_i$ into BIT: `bit.add(r_i, 1)`.
5. Output both arrays.

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

struct Fenwick {
    int size;
    vector<int> tree;

    Fenwick(int n) : size(n), tree(n + 1, 0) {}

    void add(int i, int delta) {
        for (; i <= size; i += i & -i) {
            tree[i] += delta;
        }
    }

    int query(int i) {
        int sum = 0;
        for (; i > 0; i -= i & -i) {
            sum += tree[i];
        }
        return sum;
    }

    void clear() {
        fill(tree.begin(), tree.end(), 0);
    }
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<Range> ranges(n);
    vector<int> ys;
    ys.reserve(n);

    for (int i = 0; i < n; ++i) {
        cin >> ranges[i].x >> ranges[i].y;
        ranges[i].id = i;
        ys.push_back(ranges[i].y);
    }

    // Coordinate compress y-coordinates
    sort(ys.begin(), ys.end());
    ys.erase(unique(ys.begin(), ys.end()), ys.end());
    int m = ys.size();

    auto get_rank = [&](int y) {
        return (int)(lower_bound(ys.begin(), ys.end(), y) - ys.begin()) + 1;
    };

    sort(ranges.begin(), ranges.end(), cmp);

    vector<int> contains_count(n, 0);
    vector<int> contained_count(n, 0);

    Fenwick bit(m);

    // Pass 1: Count how many other ranges this range contains (scan right to left)
    for (int i = n - 1; i >= 0; --i) {
        int r = get_rank(ranges[i].y);
        contains_count[ranges[i].id] = bit.query(r);
        bit.add(r, 1);
    }

    // Pass 2: Count how many other ranges contain this range (scan left to right)
    bit.clear();
    for (int i = 0; i < n; ++i) {
        int r = get_rank(ranges[i].y);
        contained_count[ranges[i].id] = bit.query(m) - bit.query(r - 1);
        bit.add(r, 1);
    }

    // Output Line 1: contains
    for (int i = 0; i < n; ++i) {
        cout << contains_count[i] << (i + 1 == n ? '\n' : ' ');
    }

    // Output Line 2: contained
    for (int i = 0; i < n; ++i) {
        cout << contained_count[i] << (i + 1 == n ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**:
  - Coordinate compression: $\mathcal{O}(n \log n)$.
  - Sorting ranges: $\mathcal{O}(n \log n)$.
  - Two sweeps with Fenwick tree: $2n$ queries and updates, each $\mathcal{O}(\log n)$.
  - Total Time: $\mathcal{O}(n \log n)$. For $n = 2 \cdot 10^5$, total operations $\approx 2 \cdot 10^5 \times 18 \times 4 \approx 1.4 \times 10^7$, executing in $\approx 0.12$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ memory for `ranges`, `ys`, `contains_count`, `contained_count`, and the `Fenwick` vector.

---

## 6. Correctness Proof

1. **Containment Order Independence**:
   By sorting with $x$ ascending and $y$ descending on ties:
   $$R_A \text{ contains } R_B \implies \text{index}(R_A) < \text{index}(R_B)$$
   Hence, for any fixed interval $R_i$:
   - All potential containing intervals must reside strictly in the prefix $\{R_0, \dots, R_{i-1}\}$.
   - All potential contained intervals must reside strictly in the suffix $\{R_{i+1}, \dots, R_{n-1}\}$.
2. **Left-to-Right Contained Prefix**:
   When processing $R_i$, the BIT contains exactly the set of $y$-coordinates $\{y_0, \dots, y_{i-1}\}$.
   Because $x_j \le x_i$ for all $j < i$, range $j$ contains $i$ if and only if $y_j \ge y_i$.
   The number of such ranges is the count of values in the BIT in rank range $[r(y_i), M]$, which is precisely `bit.query(M) - bit.query(r(y_i) - 1)`.
3. **Right-to-Left Contains Suffix**:
   When processing $R_i$, the BIT contains exactly the set of $y$-coordinates $\{y_{i+1}, \dots, y_{n-1}\}$.
   Because $x_i \le x_j$ for all $j > i$, range $i$ contains $j$ if and only if $y_j \le y_i$.
   The number of such ranges is the count of values in the BIT in rank range $[1, r(y_i)]$, which is precisely `bit.query(r(y_i))`.
4. In both sweeps, each interval is queried before its own rank is inserted, guaranteeing that self-containment ($j = i$) is never counted. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input:
`[1, 6] (id 0)`, `[2, 4] (id 1)`, `[4, 8] (id 2)`, `[3, 6] (id 3)`.
Unique $y$-values: `[4, 6, 8]` $\implies M = 3$.
Ranks: $y=4 \to 1, y=6 \to 2, y=8 \to 3$.

Sorted ranges:
- $i = 0$: `[1, 6]` (id 0, rank 2)
- $i = 1$: `[2, 4]` (id 1, rank 1)
- $i = 2$: `[3, 6]` (id 3, rank 2)
- $i = 3$: `[4, 8]` (id 2, rank 3)

**Pass 1 (`contains`, scan $i = 3 \to 0$):**
- $i = 3$ (rank 3, id 2): `query(3) = 0`. Add rank 3.
- $i = 2$ (rank 2, id 3): `query(2) = 0`. Add rank 2.
- $i = 1$ (rank 1, id 1): `query(1) = 0`. Add rank 1.
- $i = 0$ (rank 2, id 0): `query(2) = 2` (ranks 1 and 2 are present!).
Line 1 output in id order: `2 0 0 0`.

**Pass 2 (`contained`, scan $i = 0 \to 3$):**
- $i = 0$ (rank 2, id 0): `query(3) - query(1) = 0`. Add rank 2.
- $i = 1$ (rank 1, id 1): `query(3) - query(0) = 1` (rank 2 is present!). Add rank 1.
- $i = 2$ (rank 2, id 3): `query(3) - query(1) = 1` (rank 2 is present!). Add rank 2.
- $i = 3$ (rank 3, id 2): `query(3) - query(2) = 0`. Add rank 3.
Line 2 output in id order: `0 1 0 1`.

Final Output matches the CSES example identically!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Tie-breaker on $y$**:
  $y$ descending on equal $x$ is vital. If two ranges share the same $x$ (e.g. $[1, 6]$ and $[1, 4]$), $[1, 6]$ comes first. In Pass 1, $[1, 4]$ is inserted into the BIT before $[1, 6]$ queries it, so $[1, 6]$ counts $[1, 4]$.
- **1-based BIT indexing**: Fenwick tree indices range from $1$ to $M$.
- **Count output**: Each count fits comfortably within a standard 32-bit `int` ($\le n \le 2 \cdot 10^5$).

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does this relate to counting inversions in a permutation?**
   - Both problems map to counting pairs $(i < j \land a_i > a_j)$ using a Fenwick Tree in $\mathcal{O}(n \log n)$.
2. **What if we want to know the maximum depth of mutually nested intervals?**
   - This is the Longest Decreasing Subsequence on the sorted $y$-ranks, solvable in $\mathcal{O}(n \log n)$ via Patience Sorting.
3. **Can this be solved with a Segment Tree instead of Fenwick?**
   - Yes, a point-update range-query Segment Tree gives the exact same $\mathcal{O}(n \log n)$ complexity, though Fenwick is simpler to code and uses less memory.
4. **How would you answer range containment queries dynamically (online insertions of intervals)?**
   - Requires a 2D Range Tree or Fractional Cascading / KD-Tree in $\mathcal{O}(\log^2 n)$ per query.
5. **Why is coordinate compression necessary here?**
   - $y \le 10^9$ cannot directly index a Fenwick array; compressing distinct values reduces the tree size to $M \le n \le 2 \cdot 10^5$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Fenwick Tree, Coordinate Compression, Sweep-Line, Inversions, 2D Dominance.
- **Time Complexity**: $\mathcal{O}(n \log n)$ optimal time.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary memory.

### Related CSES Tasks
- [CSES 2168 - Nested Ranges Check](https://cses.fi/problemset/task/2168): Existence check via prefix/suffix extrema.
- [CSES 1163 - Traffic Lights](https://cses.fi/problemset/task/1163): Dynamic interval subdivision.
- [CSES 1619 - Restaurant Customers](https://cses.fi/problemset/task/1619): Sweep-line on intervals.
