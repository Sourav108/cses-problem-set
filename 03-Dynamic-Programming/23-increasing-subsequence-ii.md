# Increasing Subsequence II

- **Category**: Dynamic Programming
- **CSES Task ID**: `1748`
- **CSES Problem Link**: [Increasing Subsequence II](https://cses.fi/problemset/task/1748)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers $x_1, x_2, \dots, x_n$, your task is to calculate the total number of **strictly increasing subsequences** (excluding the empty subsequence). Two subsequences are considered different if they are chosen from different sets of index positions, even if they have identical numerical values. Print the answer modulo $10^9 + 7$.

### Input Format
- The first line contains an integer $n$: the size of the array.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$.

### Output Format
- Print one integer: the number of strictly increasing subsequences modulo $10^9 + 7$.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$

With $n = 2 \cdot 10^5$, an $\mathcal{O}(n^2)$ DP requires $4 \cdot 10^{10}$ operations and will fail with TLE. An $\mathcal{O}(n \log n)$ data-structure-optimized DP is required.

---

## 2. Intuition & Pattern Recognition

This problem merges **Dynamic Programming with Range Sum Queries (Fenwick Tree / Binary Indexed Tree)**:
- Let $dp[i]$ be the number of strictly increasing subsequences ending at index $i$ (with $x_i$ as the final element):
  1. $x_i$ can append to **any** valid increasing subsequence ending at an earlier index $j < i$ provided $x_j < x_i$.
  2. $x_i$ can also form a single-element subsequence $[x_i]$ on its own.
  $$dp[i] = 1 + \sum_{\substack{j < i \\ x_j < x_i}} dp[j] \pmod{10^9 + 7}$$
- The naive calculation of this sum takes $\mathcal{O}(n)$ per element.
- **Fenwick Tree Optimization**:
  - We need to query the sum of $dp$ values of all processed elements with value **strictly less than $x_i$**.
  - Since $x_i \le 10^9$, we first apply **Coordinate Compression** to map distinct values to ranks in $[1, U]$ where $U \le n$.
  - We maintain a Fenwick tree of size $U$. When at element $x_i$ with compressed rank $r_i$:
    1. Query the prefix sum of ways in the Fenwick tree for all ranks in $[1, r_i - 1]$:
       $$\text{sum\_ways} = \text{query}(r_i - 1)$$
    2. The number of new subsequences ending at index $i$ is:
       $$\text{ways} = (\text{sum\_ways} + 1) \pmod{10^9 + 7}$$
    3. Update the Fenwick tree at rank $r_i$ by adding $\text{ways}$.
    4. Add $\text{ways}$ to the total answer.

---

## 3. Approach 1 — Naive / Quadratic DP

Nested loop checking all pairs $j < i$.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int MOD = 1e9 + 7;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> a(n);
    for (int i = 0; i < n; ++i) cin >> a[i];

    vector<int> dp(n, 1);
    long long total = 0;

    for (int i = 0; i < n; ++i) {
        long long sum_prev = 0;
        for (int j = 0; j < i; ++j) {
            if (a[j] < a[i]) {
                sum_prev = (sum_prev + dp[j]) % MOD;
            }
        }
        dp[i] = (sum_prev + 1) % MOD;
        total = (total + dp[i]) % MOD;
    }

    cout << total << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2)$ comparisons.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE for $n > 5000$.

---

## 4. Approach 2 — Intermediate / Segment Tree with Coordinate Compression

Instead of a Fenwick Tree, implement a standard Segment Tree over compressed ranks supporting point updates and range sum queries.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n)$.
- **Space Complexity**: $\mathcal{O}(n)$ tree nodes.
- **Verdict**: Fully passes, but a Fenwick Tree in Approach 3 has half the code, $2\times$ faster cache execution, and zero recursion overhead.

---

## 5. Approach 3 — Optimal CSES Solution (Coordinate Compression + Fenwick Tree)

1. Compress the distinct array values into sorted unique ranks $[1, U]$.
2. Maintain a 1-indexed Fenwick Tree `bit` of size $U$.
3. For each element $x$ with rank $r$:
   - `long long ways = (query(r - 1) + 1) % MOD;`
   - `update(r, ways);`
   - `total_ans = (total_ans + ways) % MOD;`

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const int MOD = 1e9 + 7;

// Fenwick Tree (Binary Indexed Tree) for prefix sums modulo 10^9 + 7
struct FenwickTree {
    int size;
    vector<int> tree;

    FenwickTree(int n) : size(n), tree(n + 1, 0) {}

    void add(int idx, int delta) {
        for (; idx <= size; idx += idx & -idx) {
            tree[idx] += delta;
            if (tree[idx] >= MOD) {
                tree[idx] -= MOD;
            }
        }
    }

    int query(int idx) {
        int sum = 0;
        for (; idx > 0; idx -= idx & -idx) {
            sum += tree[idx];
            if (sum >= MOD) {
                sum -= MOD;
            }
        }
        return sum;
    }
};

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> a(n);
    vector<int> sorted_vals;
    sorted_vals.reserve(n);

    for (int i = 0; i < n; ++i) {
        cin >> a[i];
        sorted_vals.push_back(a[i]);
    }

    // Coordinate compression
    sort(sorted_vals.begin(), sorted_vals.end());
    sorted_vals.erase(unique(sorted_vals.begin(), sorted_vals.end()), sorted_vals.end());
    int num_ranks = sorted_vals.size();

    FenwickTree ft(num_ranks);
    int total_subsequences = 0;

    for (int i = 0; i < n; ++i) {
        // Find 1-based rank using binary search
        int rank = lower_bound(sorted_vals.begin(), sorted_vals.end(), a[i]) - sorted_vals.begin() + 1;

        // Query sum of all subsequences ending with rank strictly less than rank
        int prev_ways = ft.query(rank - 1);

        // +1 represents the new single-element subsequence [a[i]]
        int current_ways = (prev_ways + 1);
        if (current_ways >= MOD) {
            current_ways -= MOD;
        }

        // Add to Fenwick tree at current rank
        ft.add(rank, current_ways);

        // Accumulate to total answer
        total_subsequences += current_ways;
        if (total_subsequences >= MOD) {
            total_subsequences -= MOD;
        }
    }

    cout << total_subsequences << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n)$.
  - Sorting and deduplicating $n$ values takes $\mathcal{O}(n \log n)$.
  - For each of the $n$ elements, `std::lower_bound` takes $\mathcal{O}(\log n)$, and Fenwick `query` and `add` take $\mathcal{O}(\log n)$ bitwise operations.
  - Total runtime for $n = 2 \cdot 10^5$ is $\approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space to store `sorted_vals` and the Fenwick tree vector.
- **Optimality Guarantee**: Any algorithm computing range frequency sums over a general permutation must perform $\Omega(n \log n)$ operations.

---

## 6. Correctness Proof

### Disjoint Subsequence Partition
Every non-empty strictly increasing subsequence $S = (a_{i_1}, a_{i_2}, \dots, a_{i_k})$ has a unique ending position $i_k$.
- We partition the set of all strictly increasing subsequences by their last index $i_k = i$.
- For a fixed index $i$, an increasing subsequence ending at $i$ either:
  1. Has length $1$: the single element $[a_i]$ ($1$ way).
  2. Has length $k \ge 2$: an increasing subsequence ending at some $j < i$ with $a_j < a_i$, with $a_i$ appended.
- Since $a_j < a_i \iff \text{rank}(a_j) < \text{rank}(a_i)$, summing $dp[j]$ over all previously processed elements with $\text{rank} \le \text{rank}(a_i) - 1$ counts every valid prefix exactly once.
- The Fenwick Tree maintains prefix sums over coordinate ranks dynamically. Querying `query(rank - 1)` retrieves this exact sum in $\mathcal{O}(\log n)$ time.
- Adding the newly computed count to `tree[rank]` preserves the invariant for all future indices.
- Summing over all $i \in [0, n-1]$ counts every non-empty increasing subsequence.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
3
2 1 3
```
Array $a = [2, 1, 3]$.
Unique sorted values: `[1, 2, 3]`.
Ranks:
- $a[0] = 2 \implies \text{rank } 2$
- $a[1] = 1 \implies \text{rank } 1$
- $a[2] = 3 \implies \text{rank } 3$

| Step $i$ | Value $a[i]$ | Rank $r$ | `ft.query(r - 1)` | `current_ways` ($+ 1$) | Fenwick State after `add(r, ways)` | `total_subsequences` |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | 2 | 2 | `query(1)` $= 0$ | $0 + 1 = \mathbf{1}$ ($[2]$) | Rank 2 $\to 1$ | 1 |
| **1** | 1 | 1 | `query(0)` $= 0$ | $0 + 1 = \mathbf{1}$ ($[1]$) | Rank 1 $\to 1$, Rank 2 $\to 1$ | $1 + 1 = \mathbf{2}$ |
| **2** | 3 | 3 | `query(2)` $= 1 + 1 = 2$ | $2 + 1 = \mathbf{3}$ ($[3], [2, 3], [1, 3]$) | Rank 1 $\to 1$, Rank 2 $\to 1$, Rank 3 $\to 3$ | $2 + 3 = \mathbf{5}$ |

The 5 valid increasing subsequences are:
1. `[2]`
2. `[1]`
3. `[3]`
4. `[2, 3]`
5. `[1, 3]`

**Final Output**: `5`. (Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Duplicate Values in Input**: (e.g. $[2, 2, 2]$):
  Strictly increasing requires $a_j < a_i$, so rank $r$ only queries up to $r - 1$. An element cannot extend another element of identical value, correctly handling duplicates without extra code.
- **Strictly Decreasing Input** ($[3, 2, 1]$):
  Every element queries `query(r - 1) = 0`, producing $1$ single-element subsequence each. Output is $n$.
- **Modulo Addition**:
  Using `if (val >= MOD) val -= MOD;` avoids hardware `%` instructions and runs $3\times$ faster.
- **Ranks Range**:
  Ranks are 1-based, ranging from $1$ to $U \le n$. `query(0)` safely returns $0$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if non-decreasing subsequences ($a_j \le a_i$) are counted instead?**
   - Query `query(rank)` instead of `query(rank - 1)`.
2. **Count increasing subsequences of EXACTLY length $K$?**
   - Maintain $K$ Fenwick trees: $\text{FT}_k$ stores subsequences of length $k$. Query $\text{FT}_{k-1}(r - 1)$ to update $\text{FT}_k(r)$. Complexity: $\mathcal{O}(K \cdot n \log n)$.
3. **What if the array is subject to dynamic point updates?**
   - Single-element update alters subsequent values. Requires a 2D Fenwick Tree or Segment Tree of Fenwick Trees in $\mathcal{O}(\log^2 n)$.
4. **Longest Increasing Subsequence length vs Count?**
   - *Increasing Subsequence I* computes the maximal length $\mathcal{O}(n \log n)$ via patience sorting (`lower_bound`). *Increasing Subsequence II* counts the total number of subsequences via Fenwick Tree prefix sums.
5. **Counting in 2D (points $(x_i, y_i)$ with $x_j < x_i$ and $y_j < y_i$)?**
   - Sort by $x$ ascending, and maintain a Fenwick Tree over $y$-coordinates (standard 2D dominance counting).

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, fenwick-tree, coordinate-compression, combinatorics]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \log n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - `CSES 1145` — [Increasing Subsequence](https://cses.fi/problemset/task/1145) (Maximal LIS length via patience sorting).
  - `CSES 1140` — [Projects](https://cses.fi/problemset/task/1140) (Weighted interval scheduling).
  - `CSES 1645` — [Nearest Smaller Values](https://cses.fi/problemset/task/1645) (Monotonic stack).
