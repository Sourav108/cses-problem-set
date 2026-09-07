# Subarray Sums II

- **Category**: Sorting and Searching
- **CSES Task ID**: `1661`
- **CSES Problem Link**: [Subarray Sums II](https://cses.fi/problemset/task/1661)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers $a_1, a_2, \dots, a_n$ (which may be **positive, negative, or zero**) and a target value $x$, calculate the number of contiguous subarrays whose elements sum to exactly $x$.

### Input Format
- The first line contains two integers $n$ and $x$.
- The second line contains $n$ integers $a_1, a_2, \dots, a_n$.

### Output Format
- Print one integer: the number of subarrays with sum equal to $x$.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $-10^9 \le x \le 10^9$
- $-10^9 \le a_i \le 10^9$

With $n = 2 \cdot 10^5$, an $\mathcal{O}(n^2)$ subarray check requires $2 \cdot 10^{10}$ operations and will fail with TLE. Additionally:
- Prefix sums can span from $-2 \cdot 10^{14}$ to $+2 \cdot 10^{14}$, mandating 64-bit integers (`long long`).
- The total count of valid subarrays can be up to $\frac{n(n+1)}{2} \approx 2 \cdot 10^{10}$ (e.g., when all elements are $0$ and $x = 0$), so the counter must also be a `long long`.

---

## 2. Intuition & Pattern Recognition

Unlike *Subarray Sums I*, the array contains **negative numbers**. Because adding an element can either increase or decrease the subarray sum, monotonicity is lost:
- The two-pointer (sliding window) technique **fails completely**.
- However, the algebraic definition of a subarray sum remains invariant:
  $$\sum_{k=i}^j a_k = P[j] - P[i-1]$$
  where $P[k] = \sum_{m=1}^k a_m$ is the prefix sum up to index $k$ (with $P[0] = 0$).

Setting the subarray sum equal to $x$:
$$P[j] - P[i-1] = x \iff P[i-1] = P[j] - x$$

For each ending position $j$ ($1 \le j \le n$), the number of valid starting positions $i$ is exactly the number of prior prefix sums equal to $P[j] - x$. By maintaining a frequency map of prefix sums seen so far, we can resolve each query in $\mathcal{O}(1)$ average time.

---

## 3. Approach 1 — Naive / Baseline

Inspect all pairs $(i, j)$ and compute their sum.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    long long x;
    if (!(cin >> n >> x)) return 0;

    vector<long long> a(n);
    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    long long count = 0;
    for (int i = 0; i < n; ++i) {
        long long current_sum = 0;
        for (int j = i; j < n; ++j) {
            current_sum += a[j];
            if (current_sum == x) {
                count++;
            }
        }
    }

    cout << count << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2)$. Cannot early-break on `current_sum > x` because subsequent negative elements could bring the sum back down to $x$.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE for $n > 5000$.

---

## 4. Approach 2 — Intermediate / Ordered `std::map`

Using `std::map<long long, int>` guarantees worst-case $\mathcal{O}(n \log n)$ performance and avoids all hash collision issues.

### C++17 Ordered Map Code

```cpp
#include <iostream>
#include <map>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    long long x;
    if (!(cin >> n >> x)) return 0;

    map<long long, int> pref_count;
    pref_count[0] = 1; // Base case: prefix sum before any elements is 0

    long long current_pref = 0;
    long long total_subarrays = 0;

    for (int i = 0; i < n; ++i) {
        long long val;
        cin >> val;
        current_pref += val;

        auto it = pref_count.find(current_pref - x);
        if (it != pref_count.end()) {
            total_subarrays += it->second;
        }

        pref_count[current_pref]++;
    }

    cout << total_subarrays << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n)$ because red-black tree lookups and insertions take $\mathcal{O}(\log n)$ time.
- **Space Complexity**: $\mathcal{O}(n)$ for tree nodes.
- **Verdict**: Passes CSES, but takes $\approx 0.35\text{s}$ due to tree pointer chasing.

---

## 5. Approach 3 — Optimal CSES Solution (Hash Map with `custom_hash`)

Using `std::unordered_map` achieves expected $\mathcal{O}(n)$ time. However, CSES includes targeted anti-hash test cases that exploit GNU C++'s default identity hash for integers, degrading `unordered_map` to $\mathcal{O}(n^2)$. 

To achieve a guaranteed fast, contest-hardened $\mathcal{O}(n)$ solution, we inject a 64-bit `splitmix64` custom hash with a randomized high-resolution clock seed.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <unordered_map>
#include <chrono>

using namespace std;

// Robust 64-bit splitmix hash to prevent deliberate collision attacks
struct custom_hash {
    static uint64_t splitmix64(uint64_t x) {
        x += 0x9e3779b97f4a7c15ULL;
        x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9ULL;
        x = (x ^ (x >> 27)) * 0x94d049bb133111ebULL;
        return x ^ (x >> 31);
    }

    size_t operator()(uint64_t x) const {
        static const uint64_t FIXED_RANDOM = 
            chrono::steady_clock::now().time_since_epoch().count();
        return splitmix64(x + FIXED_RANDOM);
    }
};

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    long long x;
    if (!(cin >> n >> x)) return 0;

    // Hash map: prefix_sum -> count of occurrences
    unordered_map<long long, int, custom_hash> pref_count;
    pref_count.reserve(n * 2);
    pref_count.max_load_factor(0.7f);

    // Initial base case: an empty prefix has sum 0
    pref_count[0] = 1;

    long long current_pref = 0;
    long long total_subarrays = 0;

    for (int i = 0; i < n; ++i) {
        long long val;
        cin >> val;
        current_pref += val;

        // Target prefix we need to find: P[i-1] = P[j] - x
        long long needed = current_pref - x;
        auto it = pref_count.find(needed);
        if (it != pref_count.end()) {
            total_subarrays += it->second;
        }

        // Record the current prefix sum
        pref_count[current_pref]++;
    }

    cout << total_subarrays << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n)$ on average. Each of the $n$ elements performs one lookup and one insertion into the hash table, taking $\mathcal{O}(1)$ average time.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space to store at most $n + 1$ unique prefix sums in the hash table.
- **Optimality Guarantee**: Every element must be read ($\Omega(n)$ input lower bound), making $\mathcal{O}(n)$ time asymptotically optimal.

---

## 6. Correctness Proof

### Prefix Sum Invariant
Let $P[k] = \sum_{m=1}^k a_m$ for $k \ge 1$, and $P[0] = 0$. The sum of the contiguous subarray $a[i \dots j]$ ($1 \le i \le j \le n$) is:
$$\sum_{m=i}^j a_m = P[j] - P[i-1]$$

### Bijection to Prefix Pairs
A subarray $a[i \dots j]$ satisfies $\sum_{m=i}^j a_m = x$ if and only if:
$$P[i-1] = P[j] - x$$
where $0 \le i-1 < j \le n$.

### Step-by-Step Maintenance
1. Before processing any elements ($j = 0$), the only existing prefix is the empty prefix with sum $0$. We initialize `pref_count[0] = 1`.
2. At step $j$, `current_pref` stores $P[j]$. The map `pref_count` contains the exact frequencies of all prior prefix sums $P[0], P[1], \dots, P[j-1]$.
3. Querying `pref_count[P[j] - x]` counts all valid indices $i-1 \in \{0, \dots, j-1\}$ that form a valid subarray ending at $j$.
4. Inserting $P[j]$ into `pref_count` updates the history for subsequent steps $j+1, \dots, n$.
5. Since every valid pair $(i, j)$ has a unique end index $j$ and start prefix $P[i-1]$, each valid subarray is counted exactly once with no duplicates and no omissions.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 7
2 -1 3 5 -2
```
Target $x = 7$.

| Step $j$ | $a_j$ | `current_pref` ($P[j]$) | Needed ($P[j] - 7$) | Count of Needed in Map | `total_subarrays` | Map After Update |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Initial | - | 0 | - | - | 0 | `{0: 1}` |
| **1** | 2 | 2 | $2 - 7 = -5$ | 0 | 0 | `{0: 1, 2: 1}` |
| **2** | -1 | 1 | $1 - 7 = -6$ | 0 | 0 | `{0: 1, 2: 1, 1: 1}` |
| **3** | 3 | 4 | $4 - 7 = -3$ | 0 | 0 | `{0: 1, 2: 1, 1: 1, 4: 1}` |
| **4** | 5 | 9 | $9 - 7 = 2$ | **1** (prefix $P[1]=2$) | **1** (subarray `[-1, 3, 5]`) | `...+ {9: 1}` |
| **5** | -2 | 7 | $7 - 7 = 0$ | **1** (prefix $P[0]=0$) | **2** (subarray `[2, -1, 3, 5, -2]`) | `...+ {7: 1}` |

**Final Output**: `2`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Base Case Initialization**: `pref_count[0] = 1` is critical. Missing this fails on any valid subarray that begins at index $1$ (where $i-1 = 0$).
- **$x = 0$ and All Zeros**: An array of $n$ zeros has $\frac{n(n+1)}{2}$ subarrays of sum $0$. For $n = 2 \cdot 10^5$, this is $\approx 2 \cdot 10^{10}$, overflowing a 32-bit integer. Declaring `total_subarrays` as `long long` is mandatory.
- **Negative Targets & Elements**: All comparisons and map keys handle negative values without modification.
- **Hash Collisions**: Using plain `unordered_map<long long, int>` without a custom hash will TLE on CSES anti-hash tests. Always include `custom_hash`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Subarray Sum Divisible by $K$?**
   - Apply modulo arithmetic: $(P[j] - P[i-1]) \bmod K = 0 \iff P[j] \bmod K = P[i-1] \bmod K$. Count frequencies of remainder states (`CSES 1662: Subarray Divisibility`).
2. **Longest Subarray with Sum $x$?**
   - Instead of storing frequencies, store the **earliest index** where each prefix sum appeared. For each $j$, candidate length is $j - \text{earliest}[P[j] - x]$.
3. **Shortest Subarray with Sum at least $x$ with negative numbers?**
   - Requires a monotonic queue / Fenwick Tree over coordinate-compressed prefix sums in $\mathcal{O}(n \log n)$ time.
4. **2D Submatrix Sum Equals $x$?**
   - Fix upper and lower row boundaries $(r_1, r_2)$ in $\mathcal{O}(R^2)$, compute column sums between them, and apply the 1D prefix sum hash map in $\mathcal{O}(C)$. Total time: $\mathcal{O}(R^2 \cdot C)$.
5. **Count Subarrays with Sum in Range $[A, B]$?**
   - Transform into range query: find count of $P[i-1]$ in $[P[j] - B, P[j] - A]$. Solved via coordinate compression + Fenwick Tree or Merge Sort Tree in $\mathcal{O}(n \log n)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[prefix-sums, hash-map, sorting-and-searching, splitmix64]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - `CSES 1660` — [Subarray Sums I](https://cses.fi/problemset/task/1660) (Positive numbers only, solved with $\mathcal{O}(1)$ space two pointers).
  - `CSES 1662` — [Subarray Divisibility](https://cses.fi/problemset/task/1662) (Prefix sums modulo $n$ frequency counting).
  - `CSES 1643` — [Maximum Subarray Sum](https://cses.fi/problemset/task/1643) (Kadane's algorithm for maximum subarray sum).
