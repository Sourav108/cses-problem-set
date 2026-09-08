# Increasing Subsequence

- **Category**: Dynamic Programming
- **CSES Task ID**: `1145`
- **CSES Problem Link**: [Increasing Subsequence](https://cses.fi/problemset/task/1145)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an array of $n$ integers $x_1, x_2, \dots, x_n$. Your task is to determine the length of the **longest strictly increasing subsequence** (LIS). A subsequence is formed by deleting zero or more elements from the array without changing the order of the remaining elements.

### Input Format
- The first line contains an integer $n$.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$.

### Output Format
- Print one integer: the length of the longest strictly increasing subsequence.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$

With $n = 2 \cdot 10^5$, the textbook $\mathcal{O}(n^2)$ dynamic programming algorithm performs $4 \cdot 10^{10}$ operations and will fail with TLE. An $\mathcal{O}(n \log n)$ algorithm is required.

---

## 2. Intuition & Pattern Recognition

This is the standard **Longest Increasing Subsequence (Patience Sorting)** problem:
- In the naive approach, $dp[i]$ stores the LIS ending at index $i$, requiring an $\mathcal{O}(n)$ search over all prior indices $j < i$.
- **The Greedy Invariant (Patience Sorting)**:
  Instead of indexing by array position, index by subsequence length $L$:
  Let `tails[L]` be the **smallest possible tail (ending element)** of an increasing subsequence of length $L + 1$ found so far.
  - *Why smallest tail?* A subsequence ending with a smaller value is strictly more versatile: any future element $x$ has an easier time extending it ($x > \text{tail}$).
  - Crucial Property: The array `tails` is **strictly increasing** at all times:
    $$\text{tails}[0] < \text{tails}[1] < \dots < \text{tails}[k-1]$$
  - Because `tails` is sorted, when considering a new element $x$:
    1. We can use **binary search** (`std::lower_bound`) to find the smallest tail that is $\ge x$.
    2. If $x$ is greater than all existing tails, it extends the longest subsequence found so far, so we append $x$ to `tails`.
    3. If $x \le \text{tails}[idx]$, we replace $\text{tails}[idx]$ with $x$. This lowers the tail for that length, strictly improving future opportunities without reducing any existing subsequence length.
  - The final answer is simply `tails.size()`.

---

## 3. Approach 1 — Naive / Quadratic DP

Check all previous indices $j < i$ for each $i$.

### C++17 Baseline Code

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
    for (int i = 0; i < n; ++i) cin >> a[i];

    vector<int> dp(n, 1);
    int ans = 1;

    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < i; ++j) {
            if (a[j] < a[i]) {
                dp[i] = max(dp[i], dp[j] + 1);
            }
        }
        ans = max(ans, dp[i]);
    }

    cout << ans << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2)$ comparisons.
- **Space Complexity**: $\mathcal{O}(n)$ memory.
- **CSES Verdict**: TLE for $n > 5000$.

---

## 4. Approach 2 — Intermediate / Coordinate Compression + Fenwick Tree

Compress the $n$ distinct values of $x_i$ into the range $[1, n]$. Maintain a Fenwick Tree (or Segment Tree) storing the maximum DP value for each coordinate. For each $x_i$, query the range $[1, \text{rank}(x_i) - 1]$ in $\mathcal{O}(\log n)$ time, and update $\text{rank}(x_i)$ with $\text{max\_val} + 1$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n)$ due to sorting and tree queries.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space.
- **Verdict**: Accepted, but patience sorting in Approach 3 is shorter, faster, and uses fewer lines of code.

---

## 5. Approach 3 — Optimal CSES Solution (Patience Sorting with `lower_bound`)

Maintain a dynamically growing array `tails`. For each element $x$:
- `auto it = lower_bound(tails.begin(), tails.end(), x);`
- If `it == tails.end()`, push $x$.
- Otherwise, `*it = x`.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    // tails[i] stores the minimum ending value of an increasing subsequence of length (i + 1)
    vector<int> tails;
    tails.reserve(n);

    for (int i = 0; i < n; ++i) {
        int x;
        cin >> x;

        // Binary search for the first tail >= x
        // (Use lower_bound for strictly increasing, upper_bound for non-decreasing)
        auto it = lower_bound(tails.begin(), tails.end(), x);

        if (it == tails.end()) {
            // x is strictly greater than all current tails -> extends the maximum LIS
            tails.push_back(x);
        } else {
            // Lower the tail for this length to create a better extension opportunity
            *it = x;
        }
    }

    cout << (int)tails.size() << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n)$. There are $n$ elements. Each element triggers one `std::lower_bound` on `tails`, whose size is at most $n$, taking $\mathcal{O}(\log n)$ time. Total runtime: $\approx 0.04\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space to store the `tails` vector.
- **Optimality Guarantee**: A comparison-based LIS can be reduced to sorting, proving an $\Omega(n \log n)$ information-theoretic lower bound.

---

## 6. Correctness Proof

### Invariant
At the end of processing element $x_k$:
1. `tails[L]` contains the minimum tail value of any valid strictly increasing subsequence of length $L + 1$ chosen from the prefix $x_1 \dots x_k$.
2. `tails` is strictly increasing: $\text{tails}[0] < \text{tails}[1] < \dots < \text{tails}[m-1]$.

### Proof of Maintenance
- Suppose `tails` satisfies the invariant before processing $x$.
- **Case 1: $x > \text{tails}[m-1]$**:
  There exists a valid subsequence of length $m$ ending at $\text{tails}[m-1]$. Appending $x$ forms a valid subsequence of length $m + 1$ with tail $x$. Since no length $m + 1$ subsequence existed previously, $x$ is the minimal tail for length $m + 1$. Pushing $x$ maintains monotonicity because $x > \text{tails}[m-1]$.
- **Case 2: $x \le \text{tails}[idx]$ for some minimal $idx$**:
  - If $idx = 0$, $x \le \text{tails}[0]$. A single element $x$ is a valid subsequence of length $1$ with a smaller (or equal) tail. Setting $\text{tails}[0] = x$ strictly improves or maintains the bound.
  - If $idx > 0$, by definition of `lower_bound`, $\text{tails}[idx-1] < x \le \text{tails}[idx]$.
  - Since $\text{tails}[idx-1] < x$, we can append $x$ to the subsequence of length $idx$ ending at $\text{tails}[idx-1]$, producing a valid subsequence of length $idx + 1$ ending at $x$.
  - Since $x \le \text{tails}[idx]$, setting $\text{tails}[idx] = x$ lowers the tail of length $idx + 1$.
  - Since $\text{tails}[idx-1] < x < \text{tails}[idx+1]$, the strictly increasing property of `tails` is preserved.
- The length of `tails` at the end equals the maximal subsequence length.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
8
7 3 5 3 6 2 9 8
```

| Step $i$ | Value $x$ | `lower_bound` Result | Action on `tails` | `tails` Array State | Current LIS Length |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | 7 | `end()` | Push 7 | `[7]` | 1 |
| **1** | 3 | Points to 7 ($idx=0$) | Replace 7 $\to$ 3 | `[3]` | 1 |
| **2** | 5 | `end()` | Push 5 | `[3, 5]` | 2 |
| **3** | 3 | Points to 3 ($idx=0$) | Replace 3 $\to$ 3 | `[3, 5]` | 2 |
| **4** | 6 | `end()` | Push 6 | `[3, 5, 6]` | 3 |
| **5** | 2 | Points to 3 ($idx=0$) | Replace 3 $\to$ 2 | `[2, 5, 6]` | 3 |
| **6** | 9 | `end()` | Push 9 | `[2, 5, 6, 9]` | 4 |
| **7** | 8 | Points to 9 ($idx=3$) | Replace 9 $\to$ 8 | `[2, 5, 6, 8]` | 4 |

**Final Length**: `tails.size() = 4` (A valid LIS is `[3, 5, 6, 8]`).  
Output: `4`. Matches CSES example!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Non-Decreasing Subsequence (Weakly Increasing)**:
  If the problem allowed $x_j \le x_i$, replace `std::lower_bound` with `std::upper_bound`.
- **Strictly Decreasing Input** ($[5, 4, 3, 2, 1]$): Each element replaces `tails[0]`. `tails` remains size 1. Outputs `1`.
- **All Elements Equal** ($[5, 5, 5, 5]$): Each element replaces `tails[0]`. Outputs `1`.
- **$n = 1$**: Outputs `1`.
- **Important Gotcha**: Note that `tails` does **not** represent the actual LIS sequence! (In step 5 above, `tails` had `[2, 5, 6]`, but `2` appeared after `5` and `6`). `tails` only maintains the optimal tail values per length.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Reconstruct the actual LIS elements?**
   - Store parent pointers: let `parent[i]` store the index in the array of the element that preceded $x_i$ in its subsequence, and `tails_idx[L]` store the array index of $\text{tails}[L]$. Backtrack from `tails_idx.back()`.
2. **Number of distinct Longest Increasing Subsequences?**
   - Use a Segment Tree / Fenwick Tree storing `{max_length, count_of_ways}` over compressed coordinate ranks.
3. **Russian Doll Envelopes (2D LIS)?**
   - Envelopes $(w_i, h_i)$: sort by width ascending, and for equal widths, sort height **descending**. Then find 1D LIS on heights. The descending order prevents choosing two envelopes with equal widths.
4. **Longest Bitonic Subsequence?**
   - Compute LIS from left to right, and LDS (Longest Decreasing Subsequence) from right to left using the same patience sorting. Maximize $LIS[i] + LDS[i] - 1$.
5. **Dynamic Updates (Point Updates and LIS queries)?**
   - Dynamic LIS under modifications is a classic hard problem: solvable via Segment Tree over coordinate domains in $\mathcal{O}(\log^2 n)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, longest-increasing-subsequence, binary-search, patience-sorting]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \log n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - `CSES 1748` — [Increasing Subsequence II](https://cses.fi/problemset/task/1748) (Count number of increasing subsequences modulo $10^9+7$).
  - `CSES 1140` — [Projects](https://cses.fi/problemset/task/1140) (Interval scheduling with binary search).
  - `CSES 1073` — [Towers](https://cses.fi/problemset/task/1073) (Dilworth's theorem and greedy patience sorting).
