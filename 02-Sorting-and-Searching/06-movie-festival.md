# Movie Festival (CSES Task 1629 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1629 - Movie Festival](https://cses.fi/problemset/task/1629)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: In a movie festival, $n$ movies will be shown. You know the starting and ending time of each movie. Find the maximum number of movies you can watch entirely without overlapping.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le a_i < b_i \le 10^9$.

---

## 1. Problem, Restated

Given $n$ intervals $[a_i, b_i]$ representing movies starting at time $a_i$ and finishing at time $b_i$:
Select a subset of pairwise disjoint intervals $S \subseteq \{1, \dots, n\}$ such that for any two distinct chosen movies $i, j \in S$:
$$b_i \le a_j \quad \text{or} \quad b_j \le a_i$$
Maximize the cardinality $|S|$.

**Input**:
- First line: integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Next $n$ lines: two space-separated integers $a_i$ and $b_i$.

**Output**:
- Print a single integer: the maximum number of non-overlapping movies.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Interval Scheduling Maximization Problem (ISMP) / Greedy Strategy / Earliest Deadline First (EDF).
- **Aha! Insight**:
  - Suppose we are deciding which movie to watch first.
  - To maximize the remaining time available for future movies, we should pick the movie that **finishes as early as possible**!
  - By choosing the movie with the minimal ending time $b_i$, we leave the maximum possible timeline $[b_i, \infty)$ free to accommodate subsequent movies.
  - Any movie that ends later would only restrict future possibilities more (or equally).
  - **Greedy Strategy**:
    1. Sort all movies primarily by their **ending time** $b_i$ in ascending order.
    2. Maintain `last_end_time = 0`.
    3. Iterate through movies: if movie $i$ starts at or after `last_end_time` ($a_i \ge \text{last\_end\_time}$), select it and update `last_end_time = b_i`.
- **Signal**: Selecting the maximum number of non-overlapping intervals on a 1D line is the foundational earliest-finish-time greedy algorithm.

---

## 3. Approach 1 — Naive / Baseline (Dynamic Programming on Sorted Intervals)

### Idea
Sort movies by end time. Define $DP[i]$ as the maximum number of movies among the first $i$ movies.
$$DP[i] = \max(DP[i-1], 1 + DP[p(i)])$$
where $p(i)$ is the last non-conflicting movie with $b_{p(i)} \le a_i$, found via binary search.
While $\mathcal{O}(n \log n)$, dynamic programming is redundant because the greedy choice property guarantees that the local choice is globally optimal.

---

## 4. Approach 2 — Intermediate (Sorting by Start Time)

Sorting by start time $a_i$ and picking the earliest starting movie does **not** work.
*Counterexample*: A movie spanning $[1, 100]$ vs two movies $[2, 3]$ and $[4, 5]$. Picking the earliest start $[1, 100]$ yields 1 movie instead of 2.

---

## 5. Approach 3 — Optimal CSES Solution (Earliest End Time First)

### Idea
1. Store intervals as `pair<int, int>` with `(b_i, a_i)` (storing the finish time first so `std::sort` naturally orders by end time).
2. Sort the array.
3. Maintain `last_end = 0` and `count = 0`.
4. Iterate through movies: if `a_i >= last_end`, increment `count` and set `last_end = b_i`.

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

    // Store as (end_time, start_time) to sort primarily by end_time
    vector<pair<int, int>> movies(n);
    for (int i = 0; i < n; ++i) {
        cin >> movies[i].second >> movies[i].first;
    }

    sort(movies.begin(), movies.end());

    int count = 0;
    int last_end = 0;

    for (int i = 0; i < n; ++i) {
        if (movies[i].second >= last_end) {
            count++;
            last_end = movies[i].first;
        }
    }

    cout << count << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$ to sort the $n$ movies. The linear scan takes $\mathcal{O}(n)$. For $n = 2 \cdot 10^5$, total operations $\approx 3.6 \times 10^6$, executing in $\approx 0.05$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ for storing intervals. $\mathcal{O}(1)$ auxiliary space.

---

## 6. Correctness Proof

**Theorem**: The Earliest Finish Time (EFT) greedy algorithm produces a schedule of maximum possible cardinality.

**Proof by Greedy Exchange Argument**:
1. Let $G = (g_1, g_2, \dots, g_k)$ be the sequence of movies selected by the greedy algorithm, ordered by finish time.
2. Let $O = (o_1, o_2, \dots, o_m)$ be an optimal solution, also ordered by finish time. We wish to prove $k = m$.
3. We prove by induction on $r$ that for all $1 \le r \le \min(k, m)$, there exists an optimal solution whose first $r$ movies are identical to $g_1, \dots, g_r$:
   - **Base Step ($r = 1$)**:
     By definition of the greedy algorithm, $g_1$ has the minimum finish time among all movies in the input. Therefore, $\text{end}(g_1) \le \text{end}(o_1)$.
     Replacing $o_1$ with $g_1$ in $O$ preserves disjointness with all subsequent movies $o_2, \dots, o_m$ because:
     $$\text{end}(g_1) \le \text{end}(o_1) \le \text{start}(o_2)$$
     Thus $O' = (g_1, o_2, \dots, o_m)$ is another valid optimal solution.
   - **Inductive Step**:
     Assume an optimal solution exists starting with $(g_1, \dots, g_{r-1}, o_r, \dots, o_m)$.
     Among all movies compatible with $g_{r-1}$ (starting at or after $\text{end}(g_{r-1})$), the greedy algorithm chooses $g_r$ to have the earliest finish time.
     Hence $\text{end}(g_r) \le \text{end}(o_r) \le \text{start}(o_{r+1})$.
     Replacing $o_r$ with $g_r$ maintains validity.
4. Hence, an optimal schedule exists containing all of $G$.
   If $m > k$, then after selecting $g_k$, the optimal schedule contains another movie $o_{k+1}$ that starts at or after $\text{end}(g_k)$. But the greedy algorithm only stops when no compatible movie remains. Contradiction!
   Therefore, $k = m$, and the greedy schedule is globally optimal. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 3$.
Movies: $(3, 5), (4, 9), (5, 8)$.

Sorted by end time:
1. $(3, 5) \implies \text{start} = 3, \text{end} = 5$
2. $(5, 8) \implies \text{start} = 5, \text{end} = 8$
3. $(4, 9) \implies \text{start} = 4, \text{end} = 9$

Iteration trace:
- Movie 1: $\text{start} = 3 \ge \text{last\_end} (0)$ $\implies$ Pick movie!
  `count = 1`, `last_end = 5`.
- Movie 2: $\text{start} = 5 \ge \text{last\_end} (5)$ $\implies$ Pick movie!
  `count = 2`, `last_end = 8`.
- Movie 3: $\text{start} = 4 < \text{last\_end} (8)$ $\implies$ Overlap! Skip.

Final Output: `2`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Contiguous Boundaries ($b_i = a_{i+1}$)**: The problem statement allows watching a movie starting at the exact finish time of the previous movie. Condition `start >= last_end` correctly handles boundary contact.
- **$n = 1$**: Output is `1`.
- **Identical Intervals**: All sorted together; the first is picked, and duplicate copies are skipped.
- **Pair Storage**: By placing `finish` as `.first` and `start` as `.second`, standard C++ `sort` automatically orders by end time with zero custom comparator overhead.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if each movie had a weight $w_i$ and we wanted to maximize the total weight?**
   - This is the **Weighted Interval Scheduling Problem**, which CANNOT be solved greedily! It is solved using Dynamic Programming + Binary Search in $\mathcal{O}(n \log n)$:
     $$DP[i] = \max(DP[i-1], w_i + DP[p(i)])$$
2. **What if we have $k$ people who can watch movies simultaneously?**
   - This is **Movie Festival II (CSES 1632)**! Solved using a greedy approach with a `std::multiset` of member availability times in $\mathcal{O}(n \log k)$.
3. **What if we want to find the minimum number of rooms needed to show all movies?**
   - That is the **Restaurant Customers (CSES 1619)** / Meeting Rooms II problem, solved using sweep-line or min-heaps.
4. **Why does sorting by duration $b_i - a_i$ fail?**
   - Counterexample: A short movie $[10, 12]$ conflicts with $[1, 11]$ and $[11, 20]$. Picking $[10, 12]$ gives 1 movie; picking the other two gives 2.
5. **How would you reconstruct the exact list of chosen movies?**
   - Store original movie indices in the tuple and print the indices of selected movies.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Greedy, Sorting, Interval Scheduling, Two Pointers.
- **Time Complexity**: $\mathcal{O}(n \log n)$ optimal comparison time.
- **Space Complexity**: $\mathcal{O}(n)$ storage for intervals.

### Related CSES Tasks
- [CSES 1632 - Movie Festival II](https://cses.fi/problemset/task/1632): Generalized interval scheduling for $k$ viewers.
- [CSES 1619 - Restaurant Customers](https://cses.fi/problemset/task/1619): Concurrent interval overlap sweep-line.
- [CSES 1630 - Tasks and Deadlines](https://cses.fi/problemset/task/1630): Greedy scheduling by duration.
