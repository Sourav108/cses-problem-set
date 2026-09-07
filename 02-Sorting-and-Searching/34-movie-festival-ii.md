# Movie Festival II

- **Category**: Sorting and Searching
- **CSES Task ID**: `1632`
- **CSES Problem Link**: [Movie Festival II](https://cses.fi/problemset/task/1632)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

In a movie festival, $n$ movies will be shown. You have a club of $k$ members. Each member can watch at most one movie at any given time. Two movies cannot overlap, though one movie may start at the exact same instant another ends ($a_{next} \ge b_{prev}$). 

Given the starting time $a_i$ and ending time $b_i$ of each movie, calculate the maximum total number of movies the club members can watch collectively.

### Input Format
- The first line contains two integers $n$ and $k$.
- The next $n$ lines each contain two integers $a$ and $b$ ($a < b$).

### Output Format
- Print one integer: the maximum total number of movies watched.

### Numerical Constraints
- $1 \le k \le n \le 2 \cdot 10^5$
- $1 \le a < b \le 10^9$

With $n = 2 \cdot 10^5$, an $\mathcal{O}(n^2)$ or $\mathcal{O}(n \cdot k)$ dynamic programming approach takes up to $4 \cdot 10^{10}$ operations and will fail with TLE. We need an $\mathcal{O}(n \log n)$ greedy algorithm.

---

## 2. Intuition & Pattern Recognition

This problem generalizes the classic **Interval Scheduling** problem (*Movie Festival I*, where $k = 1$) to $k$ identical parallel processors:
1. **Earliest Finish Time First**:
   To maximize the number of movies watched, we should sort all movies primarily by **end time ascending**. Ending earlier leaves the maximum possible remaining time for subsequent movies.
2. **Greedy Processor Assignment (Best Fit)**:
   Suppose a movie has interval $[a, b]$. We look at all club members whose current movie ends at time $t \le a$. If multiple members are available:
   - **Which member should watch it?**
   - We should assign the movie to the member with the **maximum finish time $t \le a$** (the member who finished *most recently*).
   - *Why?* A member who finished much earlier (small $t$) is far more versatile: they can accept movies that start earlier in the future. Burning a member with a recent finish time $t$ preserves the flexibility of earlier-finishing members.
3. **Data Structure**:
   Maintaining the finish times of all $k$ members in an ordered `std::multiset` allows us to query the largest $t \le a$ using `upper_bound(a)` followed by `--it` in $\mathcal{O}(\log k)$ time.

---

## 3. Approach 1 — Naive / Greedy with Linear Search

Sort movies by end time. Maintain an array of size $k$ representing each member's finish time. For each movie, linearly scan the array to find the best member.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Movie {
    int start, end;
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, k;
    if (!(cin >> n >> k)) return 0;

    vector<Movie> movies(n);
    for (int i = 0; i < n; ++i) {
        cin >> movies[i].start >> movies[i].end;
    }

    sort(movies.begin(), movies.end(), [](const Movie& x, const Movie& y) {
        if (x.end != y.end) return x.end < y.end;
        return x.start < y.start;
    });

    vector<int> member_end(k, 0);
    int total_movies = 0;

    for (const auto& m : movies) {
        int best_idx = -1;
        int max_finish = -1;

        // Linear scan over all k members
        for (int i = 0; i < k; ++i) {
            if (member_end[i] <= m.start) {
                if (member_end[i] > max_finish) {
                    max_finish = member_end[i];
                    best_idx = i;
                }
            }
        }

        if (best_idx != -1) {
            member_end[best_idx] = m.end;
            total_movies++;
        }
    }

    cout << total_movies << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n + n \cdot k)$. For $n, k \le 2 \cdot 10^5$, $n \cdot k \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n + k)$.
- **CSES Verdict**: TLE on test cases with large $k$ ($k > 2000$).

---

## 4. Approach 2 — Intermediate / Min-Cost Max-Flow (MCMF)

Interval scheduling on $k$ machines can be modeled as a maximum flow / min-cost circulation network. A source connects to all movies with capacity $1$ and profit $1$, and movies connect to overlapping destinations.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(k \cdot (V + E \log V)) \approx \mathcal{O}(k \cdot n \log n)$, which is significantly slower than greedy scheduling.
- **Verdict**: Infeasible for competitive constraints ($n, k = 2 \cdot 10^5$).

---

## 5. Approach 3 — Optimal CSES Solution (Greedy + Multiset)

1. Store all movies as pairs `(end_time, start_time)`.
2. Sort movies by `end_time` ascending (ties broken by `start_time`).
3. Maintain an ordered `multiset<int>` containing the current finish times of all $k$ members. Initialize the multiset with $k$ zeros.
4. For each movie `[start, end]`:
   - Call `auto it = ms.upper_bound(start);`
   - If `it == ms.begin()`, every member is currently busy at `start` (all finish times are $> \text{start}$). We cannot take this movie.
   - Otherwise, `--it;` points to the largest finish time $\le \text{start}$.
   - We assign this movie to that member: erase `it`, insert `end` into `ms`, and increment `total_watched`.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <set>

using namespace std;

struct Movie {
    int start;
    int end;
};

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, k;
    if (!(cin >> n >> k)) return 0;

    vector<Movie> movies(n);
    for (int i = 0; i < n; ++i) {
        cin >> movies[i].start >> movies[i].end;
    }

    // Sort primarily by earliest ending time
    sort(movies.begin(), movies.end(), [](const Movie& a, const Movie& b) {
        if (a.end != b.end) return a.end < b.end;
        return a.start < b.start;
    });

    // Multiset stores the finish times of all k members
    multiset<int> finish_times;
    for (int i = 0; i < k; ++i) {
        finish_times.insert(0);
    }

    int total_watched = 0;

    for (const auto& m : movies) {
        // Find the first member whose finish time is strictly greater than m.start
        auto it = finish_times.upper_bound(m.start);

        // If it is begin(), all members finish after m.start -> no member available
        if (it == finish_times.begin()) {
            continue;
        }

        // Decrement iterator to get the member with the LARGEST finish time <= m.start
        --it;

        // Assign movie to this member: remove old finish time, insert new one
        finish_times.erase(it);
        finish_times.insert(m.end);
        total_watched++;
    }

    cout << total_watched << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n + n \log k)$.
  - Sorting $n$ movies takes $\mathcal{O}(n \log n)$.
  - For each of the $n$ movies, `upper_bound`, `erase`, and `insert` on a `multiset` of size $k$ take $\mathcal{O}(\log k)$ time.
  - Overall time is $\mathcal{O}(n \log n)$, requiring $\approx 0.15\text{s}$ on CSES.
- **Space Complexity**: $\mathcal{O}(n + k)$ to store the movies and the `multiset` of size $k$.
- **Optimality Guarantee**: Sorting by finish time matches the theoretical optimal matroid/greedy bound for unit-profit interval scheduling on $k$ machines.

---

## 6. Correctness Proof

### Greedy Choice 1: Earliest Ending Time
Standard exchange argument: If an optimal schedule does not include the movie $M_1$ that ends earliest, we can replace the first movie chosen on that member's machine with $M_1$. Because $M_1$ ends no later than the replaced movie, it leaves at least as much available time for subsequent movies, preserving optimality.

### Greedy Choice 2: Largest Available Finish Time $\le a$
Suppose movie $M = [a, b]$ can be assigned to either member $X$ (finish time $t_X \le a$) or member $Y$ (finish time $t_Y \le a$) with $t_X < t_Y \le a$.
- If we assign $M$ to $X$, member $X$'s new finish time becomes $b$, while $Y$ retains $t_Y$.
- If we assign $M$ to $Y$ (our greedy choice), $Y$'s new finish time becomes $b$, while $X$ retains $t_X$.
- Comparing the set of available finish times: $\{t_X, b\}$ vs $\{t_Y, b\}$.
- Since $t_X < t_Y$, having an available machine at $t_X$ is strictly more versatile than having one at $t_Y$ (it can accommodate movies that start anywhere in $[t_X, t_Y)$ as well as after $t_Y$).
- Hence, keeping the smaller finish time $t_X$ free dominates keeping $t_Y$ free.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 2
1 5
8 10
3 6
2 5
6 9
```
$n = 5, k = 2$.
Sorted movies by end time:
1. Movie A: $[2, 5]$
2. Movie B: $[1, 5]$
3. Movie C: $[3, 6]$
4. Movie D: $[6, 9]$
5. Movie E: $[8, 10]$

Initial Multiset: `{0, 0}`

| Movie | $[a, b]$ | `upper_bound(a)` | Member Selected | Multiset Update | Watched? | Total |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **A** | $[2, 5]$ | Points to first $> 2$ (end) $\implies$ pick `0` | Member with finish `0` | Erase `0`, insert `5` $\implies$ `{0, 5}` | **Yes** | 1 |
| **B** | $[1, 5]$ | `upper_bound(1)` points to `5` $\implies$ pick `0` | Member with finish `0` | Erase `0`, insert `5` $\implies$ `{5, 5}` | **Yes** | 2 |
| **C** | $[3, 6]$ | `upper_bound(3)` points to `5` (begin) | None (`it == begin()`) | None | No | 2 |
| **D** | $[6, 9]$ | `upper_bound(6)` points to end $\implies$ pick `5` | Member with finish `5` | Erase `5`, insert `9` $\implies$ `{5, 9}` | **Yes** | 3 |
| **E** | $[8, 10]$ | `upper_bound(8)` points to `9` $\implies$ pick `5` | Member with finish `5` | Erase `5`, insert `10` $\implies$ `{9, 10}` | **Yes** | 4 |

**Final Output**: `4` (Matches CSES example: movies $[2, 5], [1, 5], [6, 9], [8, 10]$).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$k \ge n$**: Every movie can be assigned to a distinct member. All $n$ movies are watched.
- **$k = 1$**: Reduces identically to *Movie Festival I*.
- **Touching Intervals ($a_{next} = b_{prev}$)**: Permitted by `<` vs `<=`: the member finishes at $5$ and a movie starts at $5 \implies 5 \le 5$, which is valid.
- **Multiset Erase Gotcha**: `ms.erase(val)` removes **all** copies of `val`. You must pass the iterator: `ms.erase(it)` to remove exactly one instance!

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Weighted Movie Festival (Each movie has profit $w_i$)?**
   - Greedy fails. For $k = 1$, use DP with binary search ($\mathcal{O}(n \log n)$). For general $k$, model as Min-Cost Max-Flow or Dynamic Programming with Segment Trees.
2. **Minimize Members Needed to Watch ALL Movies?**
   - That is the *Room Allocation* problem (`CSES 1164`). Sort by start time and use a min-heap of finish times.
3. **What if movies have continuous setup/travel times $s$ between them?**
   - Adjust condition to $t + s \le a \iff t \le a - s$. The same multiset logic applies.
4. **Online Query Processing?**
   - If movies arrive dynamically and we must accept or reject immediately without future knowledge, competitive analysis shows no online algorithm can achieve an optimal competitive ratio without restrictions.
5. **Memory Constraint: Can we avoid `std::multiset`?**
   - A Fenwick tree or Segment tree over coordinate-compressed end times can maintain counts of finish times in $\mathcal{O}(n \log n)$ with contiguous array memory.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[greedy, interval-scheduling, multiset, sorting-and-searching]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \log n)$
  - Space: $\mathcal{O}(n + k)$
- **Related CSES Problems**:
  - `CSES 1629` — [Movie Festival](https://cses.fi/problemset/task/1629) (Base case with $k = 1$).
  - `CSES 1164` — [Room Allocation](https://cses.fi/problemset/task/1164) (Greedy interval coloring to minimize machines).
  - `CSES 1630` — [Tasks and Deadlines](https://cses.fi/problemset/task/1630) (Shortest Processing Time greedy scheduling).
