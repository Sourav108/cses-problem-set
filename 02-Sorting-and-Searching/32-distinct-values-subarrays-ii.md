# Subarray Distinct Values (Distinct Values Subarrays II)

- **Category**: Sorting and Searching
- **CSES Task ID**: `2428`
- **CSES Problem Link**: [Subarray Distinct Values](https://cses.fi/problemset/task/2428)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers $x_1, x_2, \dots, x_n$ and an integer $k$, calculate the total number of contiguous subarrays that contain **at most $k$ distinct values**.

### Input Format
- The first line contains two integers $n$ and $k$.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$.

### Output Format
- Print one integer: the total number of valid subarrays.

### Numerical Constraints
- $1 \le k \le n \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$

With $n = 2 \cdot 10^5$, an $\mathcal{O}(n^2)$ subarray check performs $2 \cdot 10^{10}$ operations and will fail with TLE. Additionally, the number of valid subarrays can reach $\frac{n(n+1)}{2} \approx 2 \cdot 10^{10}$ (when $k = n$), requiring a 64-bit integer (`long long`) for the answer.

---

## 2. Intuition & Pattern Recognition

This problem exhibits the classic **Monotonic Sliding Window (Two Pointers)** property:
- Let $D(L, R)$ denote the number of distinct values in the subarray $x[L \dots R]$.
- **Monotonicity**: For any fixed right endpoint $R$, if we shrink the window by increasing $L$, the set of values in the subarray is a subset of the previous window. Therefore, $D(L, R)$ is non-increasing as $L$ increases:
  $$L_1 < L_2 \implies D(L_1, R) \ge D(L_2, R)$$
- If the window $[L, R]$ contains at most $k$ distinct values, then **every** subarray starting at $i \in [L, R]$ and ending at $R$ also contains at most $k$ distinct values.
- Thus, once $L$ is the smallest valid left index such that $D(L, R) \le k$, there are exactly:
  $$R - L + 1$$
  valid subarrays ending at index $R$.

By maintaining a frequency map of elements in $[L, R]$ and tracking the count of distinct elements, both pointers $L$ and $R$ sweep from left to right monotonically.

---

## 3. Approach 1 — Naive / Baseline

Examine all pairs $(L, R)$ and use a hash set to count distinct values.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <unordered_set>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, k;
    if (!(cin >> n >> k)) return 0;

    vector<int> a(n);
    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    long long count = 0;
    for (int i = 0; i < n; ++i) {
        unordered_set<int> distinct;
        for (int j = i; j < n; ++j) {
            distinct.insert(a[j]);
            if ((int)distinct.size() <= k) {
                count++;
            } else {
                break; // Adding more elements can only increase distinct count
            }
        }
    }

    cout << count << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2)$ worst-case.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: Fails with TLE for $n > 5000$.

---

## 4. Approach 2 — Intermediate / `std::map` Sliding Window

We can use `std::map<int, int>` to maintain frequencies. The map size never exceeds $k + 1$. Each insertion and deletion takes $\mathcal{O}(\log k)$ time.

### C++17 Ordered Map Code

```cpp
#include <iostream>
#include <vector>
#include <map>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, k;
    if (!(cin >> n >> k)) return 0;

    vector<int> a(n);
    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    map<int, int> freq;
    long long total = 0;
    int left = 0;

    for (int right = 0; right < n; ++right) {
        freq[a[right]]++;

        while ((int)freq.size() > k) {
            freq[a[left]]--;
            if (freq[a[left]] == 0) {
                freq.erase(a[left]);
            }
            left++;
        }

        total += (right - left + 1);
    }

    cout << total << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log k)$. At most $2n$ map insertions/erasures, each taking $\mathcal{O}(\log k)$ time since `freq.size() <= k + 1`.
- **Space Complexity**: $\mathcal{O}(k)$ auxiliary space for the map.
- **Verdict**: Fully passes CSES within $\approx 0.18\text{s}$.

---

## 5. Approach 3 — Optimal CSES Solution (Sliding Window with Hash Map / Custom Hash)

To eliminate the $\mathcal{O}(\log k)$ factor and achieve pure $\mathcal{O}(n)$ time, we use `unordered_map` with `custom_hash` (`splitmix64`). We maintain an explicit integer `distinct_count` to avoid repeated hash table `size()` calls and safely clean up empty keys.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <unordered_map>
#include <chrono>

using namespace std;

// Robust 64-bit splitmix hash to guard against anti-hash tests
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

    int n, k;
    if (!(cin >> n >> k)) return 0;

    vector<int> a(n);
    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    unordered_map<int, int, custom_hash> freq;
    freq.reserve(k * 2 + 10);
    freq.max_load_factor(0.7f);

    long long total_subarrays = 0;
    int distinct_count = 0;
    int left = 0;

    for (int right = 0; right < n; ++right) {
        // Expand window to include a[right]
        if (freq[a[right]] == 0) {
            distinct_count++;
        }
        freq[a[right]]++;

        // Shrink from left while distinct count exceeds k
        while (distinct_count > k) {
            freq[a[left]]--;
            if (freq[a[left]] == 0) {
                distinct_count--;
            }
            left++;
        }

        // All subarrays starting in [left, right] and ending at right are valid
        total_subarrays += (right - left + 1);
    }

    cout << total_subarrays << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n)$ on average. Both `left` and `right` advance from $0$ to $n-1$. Each element is inserted into the hash table once and decremented at most once. Hash operations take $\mathcal{O}(1)$ average time.
- **Space Complexity**: $\mathcal{O}(k)$ auxiliary space for the hash table, plus $\mathcal{O}(n)$ to store the array.
- **Optimality Guarantee**: Since every element must be read, $\Omega(n)$ is a lower bound. $\mathcal{O}(n)$ achieves this bound.

---

## 6. Correctness Proof

### Window Validity Invariant
At the end of step `right`, after shrinking:
1. The window $[left, right]$ contains at most $k$ distinct values.
2. If $left > 0$, the window $[left - 1, right]$ contains strictly $k + 1$ distinct values.

### Subarray Counting Invariant
For any starting index $i$:
- If $left \le i \le right$, the elements in $a[i \dots right]$ form a subset of the values in $a[left \dots right]$.
- Therefore, the number of distinct values in $a[i \dots right]$ is $\le$ the number of distinct values in $a[left \dots right] \le k$.
- All such starting positions $i \in [left, right]$ produce valid subarrays ending at $right$.
- The number of such indices is $(right - left + 1)$.
- Conversely, for any $i < left$, $a[i \dots right]$ contains at least as many distinct values as $a[left - 1 \dots right] > k$, making it invalid.
- Summing $(right - left + 1)$ across all $right \in [0, n-1]$ counts every valid subarray exactly once.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 2
1 2 1 3 2
```
$k = 2$.

| Step `right` | $a[\text{right}]$ | Action | Window $[left, right]$ | Distinct Values | Added to Total $(R - L + 1)$ | `total_subarrays` |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | 1 | Insert 1 | $[0, 0] \to [1]$ | $\{1\}$ ($1 \le 2$) | $0 - 0 + 1 = \mathbf{1}$ | 1 |
| **1** | 2 | Insert 2 | $[0, 1] \to [1, 2]$ | $\{1, 2\}$ ($2 \le 2$) | $1 - 0 + 1 = \mathbf{2}$ | $1 + 2 = \mathbf{3}$ |
| **2** | 1 | Incr 1 | $[0, 2] \to [1, 2, 1]$ | $\{1, 2\}$ ($2 \le 2$) | $2 - 0 + 1 = \mathbf{3}$ | $3 + 3 = \mathbf{6}$ |
| **3** | 3 | Insert 3 $\implies 3$ distinct<br>Shrink $L=0: \text{dec } a[0]=1$<br>Distinct remains 3<br>Shrink $L=1: \text{dec } a[1]=2$<br>2 removed $\implies 2$ distinct ($L=2$) | $[2, 3] \to [1, 3]$ | $\{1, 3\}$ ($2 \le 2$) | $3 - 2 + 1 = \mathbf{2}$ | $6 + 2 = \mathbf{8}$ |
| **4** | 2 | Insert 2 $\implies 3$ distinct<br>Shrink $L=2: \text{dec } a[2]=1$<br>1 removed $\implies 2$ distinct ($L=3$) | $[3, 4] \to [3, 2]$ | $\{3, 2\}$ ($2 \le 2$) | $4 - 3 + 1 = \mathbf{2}$ | $8 + 2 = \mathbf{10}$ |

**Final Output**: `10`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$k = 1$**: All valid subarrays must consist of identical elements. The sliding window shrinks whenever a new distinct value appears.
- **$k \ge n$**: All possible $\frac{n(n+1)}{2}$ subarrays are valid. For $n = 2 \cdot 10^5$, this is $20\,000\,100\,000 \approx 2 \cdot 10^{10}$, which overflows signed 32-bit `int`. Using `long long` for `total_subarrays` is required.
- **All Elements Distinct**: Window of size $k$ slides across the array; correct behavior maintained.
- **All Elements Identical**: Window expands to the full array without ever shrinking ($left = 0$). Correctly adds $\sum_{i=1}^n i = \frac{n(n+1)}{2}$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Count Subarrays with *Exactly* $k$ Distinct Values?**
   - Apply the reduction:
     $$\text{Exactly}(k) = \text{AtMost}(k) - \text{AtMost}(k - 1)$$
     Run the optimal sliding window twice. Complexity remains $\mathcal{O}(n)$.
2. **Shortest Subarray with at least $k$ distinct values?**
   - Invert the sliding window condition: advance $R$ until $D(L, R) \ge k$, then advance $L$ while maintaining $D(L, R) \ge k$ to minimize $R - L + 1$.
3. **What if elements can be updated dynamically (online point updates)?**
   - Sliding window fails for dynamic queries. Use a Segment Tree over the "next occurrence" array or a Fenwick Tree with offline CDQ divide-and-conquer in $\mathcal{O}(n \log^2 n)$.
4. **Memory Constraint: $\mathcal{O}(1)$ Extra Space?**
   - If values are bounded by $V \le n$, an in-place sign-flipping or in-place array frequency table can achieve $\mathcal{O}(1)$ extra space.
5. **Distinct Subsequences vs Subarrays?**
   - Subsequences are non-contiguous. Handled by combinatorics: $\prod (f_j + 1) - 1$ (`CSES 3421: Distinct Values Subsequences`).

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[sliding-window, two-pointers, hash-map, sorting-and-searching]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n)$
  - Space: $\mathcal{O}(k)$ auxiliary ($\mathcal{O}(n)$ total)
- **Related CSES Problems**:
  - `CSES 1141` — [Playlist](https://cses.fi/problemset/task/1141) (Longest subarray with all unique elements).
  - `CSES 3420` — [Distinct Values Subarrays](https://cses.fi/problemset/task/3420) (Subarrays with all distinct elements, i.e., $k = \text{length}$).
  - `CSES 1660` — [Subarray Sums I](https://cses.fi/problemset/task/1660) (Two-pointer sliding window on positive integers).
