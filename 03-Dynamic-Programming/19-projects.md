# Projects

- **Category**: Dynamic Programming
- **CSES Task ID**: `1140`
- **CSES Problem Link**: [Projects](https://cses.fi/problemset/task/1140)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ projects you can attend to. For each project $i$, you know its starting day $a_i$, its ending day $b_i$, and the reward money $p_i$ you will earn upon completion. You can work on at most one project at any given time. Two projects cannot overlap, and you cannot work on another project on a day a project ends (i.e., if a project ends on day $b$, the next project must start on day $a_{next} \ge b + 1$).

What is the **maximum amount of money** you can earn?

### Input Format
- The first line contains an integer $n$: the number of projects.
- The next $n$ lines each contain three integers $a_i$, $b_i$, and $p_i$: the starting day, ending day, and payment for each project.

### Output Format
- Print one integer: the maximum money you can earn.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le a_i \le b_i \le 10^9$
- $1 \le p_i \le 10^9$

With $n = 2 \cdot 10^5$ and reward up to $10^9$, total reward can reach $n \times 10^9 = 2 \cdot 10^{14}$, requiring 64-bit integers (`long long`). An $\mathcal{O}(n \log n)$ algorithm is required.

---

## 2. Intuition & Pattern Recognition

This is the standard **Weighted Interval Scheduling** problem:
- Unlike *Movie Festival I & II* where every interval had equal weight (solved with greedy earliest finish time), intervals here have **arbitrary weights $p_i$**, so greedy heuristics fail.
- **Dynamic Programming Formulation**:
  1. Sort all projects by **ending day $b$ ascending**.
  2. Let $dp[i]$ be the maximum money earnable considering a subset of the first $i$ sorted projects.
  3. For project $i$, we face a binary decision:
     - **Skip project $i$**: Earn $dp[i-1]$.
     - **Attend project $i$**: We earn $p_i$. To avoid schedule conflicts, any other attended projects must have finished strictly before day $a_i$ ($b_k < a_i$). To maximize earnings, we find the latest project $k < i$ with $b_k < a_i$ and add $dp[k]$.
     $$dp[i] = \max(dp[i - 1], \; p_i + dp[k])$$
  4. Since the projects are sorted by ending day $b$, finding $k$ is an $\mathcal{O}(\log n)$ **binary search** (`std::lower_bound`).

---

## 3. Approach 1 — Naive / Pure Recursion

Recursively explore taking or skipping each project.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Project {
    int a, b;
    long long p;
};

long long solve_brute(const vector<Project>& pr, int idx) {
    if (idx < 0) return 0;

    // Choice 1: Skip project idx
    long long res = solve_brute(pr, idx - 1);

    // Choice 2: Take project idx
    int prev_idx = -1;
    for (int j = idx - 1; j >= 0; --j) {
        if (pr[j].b < pr[idx].a) {
            prev_idx = j;
            break;
        }
    }
    res = max(res, pr[idx].p + (prev_idx != -1 ? solve_brute(pr, prev_idx) : 0));

    return res;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<Project> pr(n);
    for (int i = 0; i < n; ++i) cin >> pr[i].a >> pr[i].b >> pr[i].p;

    sort(pr.begin(), pr.end(), [](const Project& x, const Project& y) {
        return x.b < y.b;
    });

    cout << solve_brute(pr, n - 1) << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^n)$.
- **Space Complexity**: $\mathcal{O}(n)$ stack depth.
- **CSES Verdict**: TLE for $n > 25$.

---

## 4. Approach 2 — Intermediate / Coordinate Compression + Fenwick Tree

Compress all start and end coordinates $a_i, b_i$ into the range $[1, 2n]$. Maintain a Fenwick tree (or Segment Tree) of prefix maximums over time coordinates. As we sweep through sorted end days, query $\max_{t < a_i} dp[t]$ and update $dp[b_i]$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n)$.
- **Space Complexity**: $\mathcal{O}(n)$.
- **Verdict**: Accepted, but sorting projects and binary searching directly requires no auxiliary tree structures.

---

## 5. Approach 3 — Optimal CSES Solution (Sorting + Binary Search DP)

1. Store projects in a `vector<Project>` and sort them by $b$ ascending.
2. Maintain `dp[i]` (for $1 \le i \le n$) storing the maximum reward using a subset of the first $i$ projects.
3. For project $i$ (with start day $a_i$):
   - Find the largest index $k < i$ such that $b_k < a_i$. In C++, use custom comparator with `lower_bound` searching for $a_i$:
     ```cpp
     // First project with ending day >= a_i
     auto it = lower_bound(pr.begin(), pr.begin() + i - 1, a_i, 
         [](const Project& proj, int val) { return proj.b < val; });
     int k = distance(pr.begin(), it); // 0-based index of k
     ```
   - Transition:
     $$dp[i] = \max(dp[i - 1], \; p_i + (k > 0 ? dp[k] : 0))$$

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Project {
    int a;
    int b;
    long long p;
};

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<Project> pr(n);
    for (int i = 0; i < n; ++i) {
        cin >> pr[i].a >> pr[i].b >> pr[i].p;
    }

    // Sort projects primarily by ending day b
    sort(pr.begin(), pr.end(), [](const Project& x, const Project& y) {
        if (x.b != y.b) return x.b < y.b;
        return x.a < y.a;
    });

    // dp[i] stores the max money from a valid subset of the first i projects (1-based)
    vector<long long> dp(n + 1, 0);

    for (int i = 1; i <= n; ++i) {
        long long skip_reward = dp[i - 1];

        // Find the last project k (1 <= k < i) such that pr[k - 1].b < pr[i - 1].a
        // lower_bound finds the first project with ending day >= pr[i - 1].a
        auto it = lower_bound(pr.begin(), pr.begin() + (i - 1), pr[i - 1].a,
            [](const Project& p, int val) {
                return p.b < val;
            });

        int k = distance(pr.begin(), it); // Number of projects strictly ending before a_i

        long long take_reward = pr[i - 1].p + dp[k];

        dp[i] = max(skip_reward, take_reward);
    }

    cout << dp[n] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n)$.
  - Sorting $n$ projects takes $\mathcal{O}(n \log n)$.
  - For each of the $n$ projects, `std::lower_bound` takes $\mathcal{O}(\log n)$ time.
  - Overall runtime for $n = 2 \cdot 10^5$ is $\approx 0.07\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space for `dp` and `pr` vectors.
- **Optimality Guarantee**: Sorting by finish time matches the theoretical optimal bound for interval scheduling.

---

## 6. Correctness Proof

### Optimal Substructure
Let $\mathcal{O}_i$ be an optimal valid subset of the first $i$ sorted projects:
1. **Case 1: Project $i \notin \mathcal{O}_i$**:
   The subset $\mathcal{O}_i$ is entirely chosen from the first $i-1$ projects, so its maximum value is $dp[i-1]$.
2. **Case 2: Project $i \in \mathcal{O}_i$**:
   Since project $i$ spans $[a_i, b_i]$, no other project in $\mathcal{O}_i$ can end on or after day $a_i$. All other projects in $\mathcal{O}_i$ must have ending days strictly before $a_i$.
   - Let $k$ be the index of the latest project among the first $i-1$ sorted projects satisfying $b_k < a_i$.
   - Since projects are sorted by ending day, every project with index $\le k$ ends strictly before $a_i$, and every project with index $> k$ ends on or after $a_i$.
   - Therefore, the remaining projects in $\mathcal{O}_i$ must form a valid subset of $\{1, \dots, k\}$.
   - By the induction hypothesis, the optimal reward using a subset of $\{1, \dots, k\}$ is $dp[k]$.
   - Thus, the maximum reward when including project $i$ is $p_i + dp[k]$.
3. Since these two cases are exhaustive and disjoint, $dp[i] = \max(dp[i-1], p_i + dp[k])$ is strictly optimal.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
4
2 4 4
3 6 6
6 8 2
5 7 3
```
Sorted by ending day $b$:
1. Project 1: $[2, 4]$, reward $4$
2. Project 2: $[3, 6]$, reward $6$
3. Project 3: $[5, 7]$, reward $3$
4. Project 4: $[6, 8]$, reward $2$

| Project $i$ | Interval $[a, b]$, Reward $p$ | `lower_bound` search for $a_i$ | Compatible $k$ ($b_k < a_i$) | `take_reward` ($p_i + dp[k]$) | `skip_reward` ($dp[i-1]$) | $dp[i]$ |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | $[2, 4]$, $p=4$ | None ($a=2$) | $k = 0$ | $4 + 0 = 4$ | $dp[0] = 0$ | **4** |
| **2** | $[3, 6]$, $p=6$ | $b_1 = 4 \ge 3 \implies$ none | $k = 0$ | $6 + 0 = 6$ | $dp[1] = 4$ | **6** |
| **3** | $[5, 7]$, $p=3$ | $b_1 = 4 < 5, b_2 = 6 \ge 5$ | $k = 1$ (Project 1) | $3 + dp[1] = 3 + 4 = \mathbf{7}$ | $dp[2] = 6$ | **7** |
| **4** | $[6, 8]$, $p=2$ | $b_1 = 4 < 6, b_2 = 6 \ge 6$ | $k = 1$ (Project 1) | $2 + dp[1] = 2 + 4 = 6$ | $dp[3] = 7$ | **7** |

**Final Output**: `7` (Projects 1 and 3: $[2, 4]$ and $[5, 7]$, reward $= 4 + 3 = 7$).  
(Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Touching Endpoints**: $a_{next} = b_{prev}$ is forbidden (a project ending on day 6 conflicts with a project starting on day 6). Handled by strictly searching for $b_k < a_i$.
- **Large Rewards**: Rewards can sum to $2 \cdot 10^{14}$, which overflows 32-bit signed integers. `dp` and `p` must be declared as `long long`.
- **Coordinates up to $10^9$**: Handled natively by binary search on the array without requiring large arrays or memory-heavy coordinate hashing.
- **$n = 1$**: Handled properly, prints $p_1$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Reconstruct the optimal subset of projects?**
   - Store a boolean flag `took[i] = (take_reward > skip_reward)`. Backtrack from $n$ to $1$: if `took[i]` is true, print project $i$ and jump to $k$; else decrement $i$.
2. **What if you can attend up to $K$ overlapping projects at the same time?**
   - Generalizes to Min-Cost Max-Flow or Segment Tree DP over coordinate-compressed endpoints in $\mathcal{O}(n \log n)$.
3. **What if projects have preparation/commute times $c(i, j)$ between them?**
   - Condition becomes $b_i + c(i, j) < a_j$. If commute is constant, adjust start times; if pairwise distance-dependent, use DAG longest path.
4. **Online / Streaming Projects?**
   - If projects arrive as a stream sorted by start time, maintain a dynamic Segment Tree over end times to answer range maximum queries in $\mathcal{O}(\log n)$ per arrival.
5. **Weighted Interval Scheduling with Room Constraints (Multiple Rooms)?**
   - Solvable via MCMF (Minimum Cost Maximum Flow) or polynomial-time column generation.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, binary-search, interval-scheduling, sorting]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \log n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - `CSES 1629` — [Movie Festival](https://cses.fi/problemset/task/1629) (Unweighted interval scheduling, greedy $\mathcal{O}(n \log n)$).
  - `CSES 1632` — [Movie Festival II](https://cses.fi/problemset/task/1632) ($k$ members interval scheduling).
  - `CSES 1145` — [Increasing Subsequence](https://cses.fi/problemset/task/1145) (Patience sorting LIS).
