# Towers (CSES Task 1073 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1073 - Towers](https://cses.fi/problemset/task/1073)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Given $n$ cubes in a fixed order, build towers. An upper cube must be strictly smaller than the lower cube ($k_{\text{upper}} < k_{\text{lower}}$). Process cubes in order. Minimize the total number of towers.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le k_i \le 10^9$.

---

## 1. Problem, Restated

Given a sequence of $n$ cube sizes $k_1, k_2, \dots, k_n$, process them online from left to right.
For each cube $x$:
- Either place $x$ on top of an existing tower whose current top cube is strictly larger than $x$ ($top > x$).
- Or start a new tower with $x$ as its base.

Determine the minimum number of towers needed to place all $n$ cubes.

**Input**:
- First line: integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Second line: $n$ space-separated integers $k_1, \dots, k_n$.

**Output**:
- Print a single integer: the minimum number of towers.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Patience Sorting / Dilworth's Theorem / Longest Non-Decreasing Subsequence / Binary Search.
- **Aha! Insight**:
  - Each tower represents a sequence of strictly decreasing cube sizes from bottom to top.
  - When placing cube $x$:
    - We want to place $x$ on top of a tower with top $> x$.
    - If multiple towers have top $> x$, **which one should we choose?**
    - **Greedy Rule (Patience Sorting)**: We should place $x$ on the tower whose top is the **smallest value strictly greater than $x$**!
      - Why? If we placed $x$ on a tower with a much larger top $Y \gg x$, we would replace $Y$ with $x$, reducing the capacity of that tower to accept future cubes. Keeping larger tops available preserves the greatest flexibility for future large cubes.
    - If no existing tower has top $> x$, we are forced to start a new tower with top $x$.
  - Notice the structure of tower tops:
    - If we maintain tower tops in a sorted `vector<int> towers`:
    - Finding the smallest top $> x$ is simply `std::upper_bound(towers.begin(), towers.end(), x)`.
    - If `upper_bound` returns `end()`, append $x$ via `towers.push_back(x)`.
    - Otherwise, update that tower's top: `*it = x`.
  - The vector `towers` remains sorted at all times!
  - By **Dilworth's Theorem**, the minimum number of strictly decreasing chains needed to partition a sequence equals the length of the **Longest Non-Decreasing Subsequence (LNDS)** of the input!
- **Signal**: Partitioning an online sequence into the minimum number of strictly decreasing chains is solved in $\mathcal{O}(n \log n)$ via Patience Sorting / `std::upper_bound`.

---

## 3. Approach 1 — Naive / Baseline (`std::multiset` Simulation)

Store the top element of each tower in a `std::multiset<int>`. For each cube $x$, call `auto it = ms.upper_bound(x)`. If `it != ms.end()`, erase `it` and insert $x$. Otherwise, insert $x$.
While $\mathcal{O}(n \log n)$, `multiset` involves heap node allocations and rebalancing.

---

## 4. Approach 2 — Intermediate (Linear Search over Tower Tops)

Maintain an unsorted array of tower tops. For each cube, scan all towers to find the minimal top $> x$.
Takes $\mathcal{O}(n^2)$ time in the worst case (e.g. non-decreasing cubes $[1, 2, \dots, n]$ each creating a new tower), resulting in $4 \cdot 10^{10}$ operations $\implies$ TLE.

---

## 5. Approach 3 — Optimal CSES Solution (Sorted Vector with `std::upper_bound`)

### Idea
Maintain a dynamic `vector<int> towers` storing the top cube of each active tower in non-decreasing order.
For each incoming cube $x$:
1. `it = upper_bound(towers.begin(), towers.end(), x)`
2. If `it == towers.end()`: `towers.push_back(x)`
3. Else: `*it = x`
At the end, output `towers.size()`.

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

    vector<int> towers;
    for (int i = 0; i < n; ++i) {
        int x;
        cin >> x;

        // Find smallest tower top strictly greater than x
        auto it = upper_bound(towers.begin(), towers.end(), x);

        if (it == towers.end()) {
            towers.push_back(x);
        } else {
            *it = x;
        }
    }

    cout << towers.size() << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$. For each of the $n$ cubes, `std::upper_bound` performs a binary search over at most $n$ elements in $\mathcal{O}(\log n)$ time. Total operations $\approx 2 \cdot 10^5 \times 18 \approx 3.6 \times 10^6$, executing in $\approx 0.03$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ contiguous memory for the `towers` vector.

---

## 6. Correctness Proof

1. **Monotonicity Invariant of `towers`**:
   We claim `towers` is always non-decreasing: $T_0 \le T_1 \le \dots \le T_{m-1}$.
   - **Base Case**: Empty vector is trivially sorted.
   - **Inductive Step**:
     - If $x \ge T_{m-1}$, `upper_bound` returns `end()`, and $x$ is appended. Since $x \ge T_{m-1}$, the vector remains sorted.
     - If `upper_bound` finds index $j$, then $T_j > x$ and (if $j > 0$) $T_{j-1} \le x$.
       Replacing $T_j$ with $x$ maintains $T_{j-1} \le x < T_{j+1}$ (since $x < T_j \le T_{j+1}$).
       Hence `towers` remains sorted after replacement.
2. **Greedy Exchange Argument**:
   Let $x$ be placed on tower $T_j$ (the smallest top $> x$).
   Suppose an alternative optimal strategy placed $x$ on a different tower $T_k$ with $T_k > T_j > x$.
   Then after placement, the tops would be $(T_j, x)$ instead of $(x, T_k)$.
   Because $x < T_j < T_k$, the multiset $\{x, T_k\}$ dominates $\{x, T_j\}$ (since $T_k > T_j$, tower $k$ is capable of receiving strictly more future cube values than tower $j$).
   Thus, placing $x$ on $T_j$ leaves a set of tower tops that is component-wise at least as capable of accepting future elements.
3. **Equivalence via Dilworth's Theorem**:
   Each tower is a chain in the poset of decreasing subsequences.
   By Dilworth's Theorem, the minimum chain cover equals the size of the maximum antichain, which corresponds to the Longest Non-Decreasing Subsequence. The patience sorting algorithm computes this exact maximum. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 5$, cubes: `[3, 8, 2, 1, 5]`.
Initial: `towers = []`.

- Cube 1 ($x = 3$):
  - `upper_bound(3)` on `[]` $\implies$ not found.
  - `towers = [3]`. (Tower 1: top 3)
- Cube 2 ($x = 8$):
  - `upper_bound(8)` on `[3]` $\implies$ not found ($8 > 3$).
  - `towers = [3, 8]`. (Tower 1: top 3, Tower 2: top 8)
- Cube 3 ($x = 2$):
  - `upper_bound(2)` on `[3, 8]` $\implies$ finds 3 (index 0).
  - Replace: `towers[0] = 2`.
  - `towers = [2, 8]`. (Tower 1: top 2, Tower 2: top 8)
- Cube 4 ($x = 1$):
  - `upper_bound(1)` on `[2, 8]` $\implies$ finds 2 (index 0).
  - Replace: `towers[0] = 1`.
  - `towers = [1, 8]`. (Tower 1: top 1, Tower 2: top 8)
- Cube 5 ($x = 5$):
  - `upper_bound(5)` on `[1, 8]` $\implies$ finds 8 (index 1).
  - Replace: `towers[1] = 5`.
  - `towers = [1, 5]`. (Tower 1: top 1, Tower 2: top 5)

Final Output: `towers.size() = 2`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Strict Inequality Requirement**: An upper cube must be *strictly* smaller than the lower cube ($k_{\text{upper}} < k_{\text{lower}}$).
  - Thus, we MUST use `std::upper_bound` (which searches for $> x$).
  - Using `std::lower_bound` ($\ge x$) would erroneously allow placing a cube on top of an identical cube!
- **Sorted Array ($[1, 2, \dots, n]$)**: Every cube is larger than all preceding towers; creates $n$ towers.
- **Reverse Sorted Array ($[n, n-1, \dots, 1]$)**: Every cube stacks on top of the first tower; creates 1 tower.
- **$n = 1$**: Handled correctly; output is 1.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if an upper cube could be $\le$ the lower cube (non-strict)?**
   - We would search for $\ge x$ using `std::lower_bound`, which corresponds to the Longest Strictly Increasing Subsequence (LIS).
2. **How to reconstruct the actual contents of each tower?**
   - Maintain a `vector<vector<int>>` or store parent pointers in each placement.
3. **What is the relation to Patience Sorting in card games?**
   - This is the exact algorithm used in Patience sorting to sort a deck of cards by dealing into piles.
4. **Why is `std::vector` + `upper_bound` faster than `std::multiset`?**
   - A contiguous array has zero pointer dereferences and fits in L1 cache, running up to $5\times$ faster than red-black tree nodes.
5. **How does this connect to Mirsky's Theorem?**
   - Dual to Dilworth's theorem: the size of the longest chain equals the minimum number of antichains needed to cover the poset.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Greedy, Binary Search, LIS, Patience Sorting, Dilworth's Theorem.
- **Time Complexity**: $\mathcal{O}(n \log n)$ optimal time.
- **Space Complexity**: $\mathcal{O}(n)$ storage for tower tops.

### Related CSES Tasks
- [CSES 1141 - Playlist](https://cses.fi/problemset/task/1141): Sliding window distinct elements.
- [CSES 1091 - Concert Tickets](https://cses.fi/problemset/task/1091): Dynamic upper bound predecessor queries.
- [CSES 1629 - Movie Festival](https://cses.fi/problemset/task/1629): Greedy interval scheduling.
