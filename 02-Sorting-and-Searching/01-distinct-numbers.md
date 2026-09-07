# Distinct Numbers (CSES Task 1621 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1621 - Distinct Numbers](https://cses.fi/problemset/task/1621)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Given an array of $n$ integers, calculate the number of distinct values in the array.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le x_i \le 10^9$.

---

## 1. Problem, Restated

Given a list of $n$ integers $x_1, x_2, \dots, x_n$, find the cardinality of the underlying set of unique values $|\{x_1, x_2, \dots, x_n\}|$.

**Input**:
- First line: integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Second line: $n$ space-separated integers $x_i$ ($1 \le x_i \le 10^9$).

**Output**:
- Print a single integer: the number of distinct values in the array.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Sorting / Deduplication / Coordinate Compression / Hash Set.
- **Aha! Insight**:
  - The values $x_i \le 10^9$ cannot be used directly as indices in a boolean frequency array.
  - If we sort the array in non-decreasing order:
    $$x_{(1)} \le x_{(2)} \le \dots \le x_{(n)}$$
    all identical values become contiguous.
  - A value $x_{(i)}$ is the first occurrence of a distinct number if and only if $i = 0$ or $x_{(i)} \ne x_{(i-1)}$.
  - Alternatively, C++ STL provides `std::unique`, which clusters duplicate adjacent elements and returns an iterator to the end of the unique range in a single linear scan $\mathcal{O}(n)$.
  - Total time is dominated by `std::sort`, requiring $\mathcal{O}(n \log n)$, which completes in $\approx 0.04$s for $n = 2 \cdot 10^5$.
- **Signal**: Counting unique elements over arbitrary large 32-bit values without order requirements is solved optimally by sorting.

---

## 3. Approach 1 — Naive / Baseline (`std::set<int>`)

### Idea
Insert all $n$ elements into a red-black tree (`std::set<int>`). The size of the set at the end is the number of distinct elements.

### C++17 Code
```cpp
#include <iostream>
#include <set>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    set<int> s;
    for (int i = 0; i < n; ++i) {
        int x;
        cin >> x;
        s.insert(x);
    }

    cout << s.size() << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$. While asymptotically acceptable, dynamic memory allocation for $2 \cdot 10^5$ separate tree nodes incurs high constant factors and cache misses (~0.18s).
- **Space Complexity**: $\mathcal{O}(n)$ tree pointers (3 pointers + 1 color byte per node $\approx 32-48$ bytes per element).

---

## 4. Approach 2 — Intermediate (`std::unordered_set<int>` with Anti-Hash-Collision)

Using a hash set achieves $\mathcal{O}(n)$ average time. However, standard `std::unordered_set` has $\mathcal{O}(n^2)$ worst-case due to deliberate anti-hash collision attacks on Codeforces/CSES unless paired with a custom splitmix64 hash functor. Sorting (Approach 3) is deterministic, faster, and cache-friendly.

---

## 5. Approach 3 — Optimal CSES Solution (In-Place Sort + `std::unique`)

### Idea
1. Read all $n$ integers into a contiguous `vector<int> a(n)`.
2. Sort the vector using `std::sort(a.begin(), a.end())`.
3. Erase adjacent duplicates using the erase-unique idiom:
   `a.erase(unique(a.begin(), a.end()), a.end())`.
4. Output `a.size()`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> a(n);
    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    sort(a.begin(), a.end());
    int distinct_count = unique(a.begin(), a.end()) - a.begin();

    cout << distinct_count << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$ for IntroSort (`std::sort`), followed by $\mathcal{O}(n)$ linear comparisons in `std::unique`. For $n = 2 \cdot 10^5$, $n \log_2 n \approx 3.6 \times 10^6$ operations, executing in $\approx 0.04$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ contiguous array storage ($800$ KB for $2 \cdot 10^5$ integers). $\mathcal{O}(\log n)$ stack space for quicksort partitioning.

---

## 6. Correctness Proof

1. **Equivalence of Global Uniqueness to Contiguous Uniqueness**:
   Let $A = (x_1, \dots, x_n)$ be sorted non-decreasingly: $x_1 \le x_2 \le \dots \le x_n$.
   Suppose $x_i = x_j$ with $i < j$.
   Since the array is sorted, $x_i \le x_k \le x_j$ for all $i \le k \le j$.
   Because $x_i = x_j$, by the squeeze theorem $x_k = x_i$ for all intermediate indices $k$.
   Therefore, all identical elements form a single contiguous interval.
2. **Action of `std::unique`**:
   `std::unique` iterates through the contiguous intervals of equal elements, copying the first element of each run to the front.
   The number of such runs is identically equal to the number of distinct equivalence classes under equality.
   Hence, `distinct_count = unique(...) - begin` is strictly correct. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 5$, `a = [2, 3, 2, 2, 3]`.

1. Read into vector: `[2, 3, 2, 2, 3]`.
2. `std::sort`: `[2, 2, 2, 3, 3]`.
3. Contiguous runs:
   - Run 1: `2, 2, 2` $\implies$ keeps first `2`.
   - Run 2: `3, 3` $\implies$ keeps first `3`.
4. Unique range: `[2, 3]`.
5. `unique(...) - a.begin()` evaluates to `2`.
Output: `2`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1$**: Output is always `1`. Handled correctly.
- **All elements identical ($x_1 = \dots = x_n$)**: Run-length is $n$, output is `1`.
- **All elements distinct**: Output is $n$.
- **Integer Size**: $x_i \le 10^9$ fits inside signed 32-bit `int` ($2 \cdot 10^9$). No 64-bit overflow occurs.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How to count distinct elements in $\mathcal{O}(n)$ without comparison-based sorting?**
   - Radix Sort on 32-bit integers runs in $\mathcal{O}(n \cdot \frac{32}{b})$ with base $2^b$ (e.g. 4 passes of 8 bits), achieving strictly linear time.
2. **What if the array is an infinite stream and we only have $\mathcal{O}(1)$ or $\mathcal{O}(\log \log N)$ memory?**
   - Use the **HyperLogLog** probabilistic cardinality estimation algorithm, which estimates distinct elements within a standard error of $\approx 1.04 / \sqrt{m}$ using tiny registers.
3. **How do we answer distinct element queries on subarrays $[L, R]$?**
   - This is the classic **Range Distinct Queries** problem, solvable offline with a Fenwick Tree (BIT) in $\mathcal{O}((n + q) \log n)$, or online with a Persistent Segment Tree in $\mathcal{O}((n + q) \log n)$.
4. **Why is `std::sort` + `std::unique` faster than `std::set`?**
   - Cache locality: contiguous arrays utilize CPU cache lines (64 bytes loads 16 integers simultaneously), whereas tree nodes in `std::set` cause random memory pointer chasing.
5. **How would you return the distinct values in order?**
   - Resize `a.resize(distinct_count)` and print `a[i]`.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Sorting, Deduplication, Two Pointers, C++ STL, Binary Search.
- **Time Complexity**: $\mathcal{O}(n \log n)$ optimal comparison time.
- **Space Complexity**: $\mathcal{O}(n)$ space.

### Related CSES Tasks
- [CSES 1084 - Apartments](https://cses.fi/problemset/task/1084): Sorting two lists with greedy matching.
- [CSES 1090 - Ferris Wheel](https://cses.fi/problemset/task/1090): Sorting with two-pointer greedy pairing.
- [CSES 1640 - Sum of Two Values](https://cses.fi/problemset/task/1640): Two-pointer search on sorted pairs.
