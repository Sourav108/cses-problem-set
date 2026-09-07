# Maximum Subarray Sum II

- **Category**: Sorting and Searching
- **CSES Task ID**: `1644`
- **CSES Problem Link**: [Maximum Subarray Sum II](https://cses.fi/problemset/task/1644)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers $x_1, x_2, \dots, x_n$ and two integers $a$ and $b$, find the **maximum contiguous subarray sum** among all subarrays whose length is between $a$ and $b$ inclusive ($a \le \text{length} \le b$).

### Input Format
- The first line contains three integers $n$, $a$, and $b$.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$.

### Output Format
- Print one integer: the maximum subarray sum with length in $[a, b]$.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le a \le b \le n$
- $-10^9 \le x_i \le 10^9$

Because $n = 2 \cdot 10^5$, checking all $\mathcal{O}(n(b - a + 1))$ possible subarrays takes up to $2 \cdot 10^{10}$ operations and will fail with TLE. Moreover, subarray sums can span from $-2 \cdot 10^{14}$ to $+2 \cdot 10^{14}$, requiring 64-bit integers (`long long`).

---

## 2. Intuition & Pattern Recognition

Let $P[k] = \sum_{m=1}^k x_m$ be the prefix sum array (with $P[0] = 0$).
A contiguous subarray $x[i \dots j]$ ($1 \le i \le j \le n$) has:
- Length: $L = j - i + 1$
- Sum: $P[j] - P[i-1]$

The length constraint requires $a \le j - i + 1 \le b$, which rearranges to:
$$j - b \le i - 1 \le j - a$$

For a fixed ending index $j \in [a, n]$:
$$\max_{i: a \le j-i+1 \le b} (P[j] - P[i-1]) = P[j] - \min_{k \in [\max(0, j-b), j-a]} P[k]$$

To maximize $P[j] - P[k]$, we need to **minimize $P[k]$** over the index window $k \in [j - b, j - a]$.
- As $j$ advances from $a$ to $n$, both boundaries of the interval $[j-b, j-a]$ slide forward by $1$ at each step.
- This is the classic **Sliding Window Minimum** problem!
- It can be solved either using `std::multiset` in $\mathcal{O}(n \log(b - a + 1))$ or optimally using a **Monotonic Deque** in pure $\mathcal{O}(n)$ time.

---

## 3. Approach 1 — Naive / Baseline

For each valid length $L \in [a, b]$, calculate the sum of all subarrays of length $L$.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, a, b;
    if (!(cin >> n >> a >> b)) return 0;

    vector<long long> pref(n + 1, 0);
    for (int i = 1; i <= n; ++i) {
        long long val;
        cin >> val;
        pref[i] = pref[i - 1] + val;
    }

    long long max_sum = -4e18; // Negative infinity

    for (int len = a; len <= b; ++len) {
        for (int j = len; j <= n; ++j) {
            long long cur = pref[j] - pref[j - len];
            max_sum = max(max_sum, cur);
        }
    }

    cout << max_sum << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot (b - a + 1))$. If $a = 1$ and $b = n$, this is $\mathcal{O}(n^2) \approx 2 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE for $n > 5000$.

---

## 4. Approach 2 — Intermediate / `std::multiset` Sliding Window

Maintain the active prefix sums $P[k]$ for $k \in [j-b, j-a]$ in a `std::multiset<long long>`. The smallest element is simply `*ms.begin()`.

### C++17 Multiset Code

```cpp
#include <iostream>
#include <vector>
#include <set>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, a, b;
    if (!(cin >> n >> a >> b)) return 0;

    vector<long long> pref(n + 1, 0);
    for (int i = 1; i <= n; ++i) {
        long long val;
        cin >> val;
        pref[i] = pref[i - 1] + val;
    }

    multiset<long long> window;
    long long max_sum = -4e18;

    for (int j = a; j <= n; ++j) {
        // Insert newly eligible prefix sum P[j - a]
        window.insert(pref[j - a]);

        // Evict expired prefix sum P[j - b - 1] if it exited the window
        if (j - b - 1 >= 0) {
            window.erase(window.find(pref[j - b - 1]));
        }

        // Smallest prefix sum is at the beginning of the multiset
        max_sum = max(max_sum, pref[j] - *window.begin());
    }

    cout << max_sum << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log(b - a + 1))$. Each insert and erase in the multiset takes $\mathcal{O}(\log(b - a + 1))$ time. Runs in $\approx 0.25\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + (b - a))$.
- **Verdict**: Fully passes, but we can eliminate the $\mathcal{O}(\log(b - a))$ factor using a monotonic deque.

---

## 5. Approach 3 — Optimal CSES Solution (Monotonic Deque)

We maintain a `std::deque<int>` storing **indices** of prefix sums in strictly increasing order of their values:
1. For each end position $j \in [a, n]$:
   - The index `idx = j - a` enters the active window.
   - Maintain the strictly increasing monotonic property: while `!dq.empty() && pref[dq.back()] >= pref[idx]`, pop from the back.
   - Push `idx` to the back of the deque.
   - Remove indices that have expired from the left of the window: while `!dq.empty() && dq.front() < j - b`, pop from the front.
   - The minimum prefix sum in the active window is `pref[dq.front()]`.
   - Update `max_sum = max(max_sum, pref[j] - pref[dq.front()])`.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <deque>
#include <algorithm>

using namespace std;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, a, b;
    if (!(cin >> n >> a >> b)) return 0;

    // 1-based prefix sums
    vector<long long> pref(n + 1, 0);
    for (int i = 1; i <= n; ++i) {
        long long val;
        cin >> val;
        pref[i] = pref[i - 1] + val;
    }

    // Monotonic deque storing prefix sum indices k
    deque<int> dq;
    long long max_subarray_sum = -4e18; // Negative infinity for 64-bit

    for (int j = a; j <= n; ++j) {
        int enter_idx = j - a;

        // Maintain monotonic increasing order of prefix sums in deque
        while (!dq.empty() && pref[dq.back()] >= pref[enter_idx]) {
            dq.pop_back();
        }
        dq.push_back(enter_idx);

        // Discard indices that have fallen out of the window [j - b, j - a]
        while (!dq.empty() && dq.front() < j - b) {
            dq.pop_front();
        }

        // Front of deque is the minimum prefix sum in [j - b, j - a]
        max_subarray_sum = max(max_subarray_sum, pref[j] - pref[dq.front()]);
    }

    cout << max_subarray_sum << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n)$. Every prefix sum index $k \in [0, n - a]$ enters the deque exactly once and is popped at most once. Hence, all deque operations take amortized $\mathcal{O}(1)$ time per step. Total execution time is $\approx 0.05\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ to store prefix sums, and $\mathcal{O}(b - a + 1)$ auxiliary space for the deque.
- **Optimality Guarantee**: Since every input element must be inspected at least once, $\Omega(n)$ is a lower bound. $\mathcal{O}(n)$ matches this bound.

---

## 6. Correctness Proof

### Problem Equivalence
Every subarray $x[i \dots j]$ of length $L \in [a, b]$ has sum $P[j] - P[i-1]$ where $j \in [a, n]$ and $i - 1 \in [j - b, j - a]$.
Thus:
$$\max_{a \le L \le b} \text{Sum}(L) = \max_{j=a}^n \left( P[j] - \min_{k \in [\max(0, j-b), j-a]} P[k] \right)$$

### Deque Invariants
At each step $j$:
1. **Window Invariant**: All indices $k$ in `dq` satisfy $j - b \le k \le j - a$.
2. **Monotonicity Invariant**: Indices in `dq` are ordered such that $k_1 < k_2 < \dots < k_m$ and $P[k_1] < P[k_2] < \dots < P[k_m]$.
3. **Optimality of Front**:
   - Any index $k'$ discarded from the back because $P[k'] \ge P[enter\_idx]$ cannot be the minimum prefix sum for any future window: $enter\_idx$ is both smaller/equal in value and has a later index (so it expires strictly later than $k'$).
   - Therefore, $P[dq.front()]$ is guaranteed to be the minimum prefix sum in the active window $[j - b, j - a]$.
4. The maximum over all $j \in [a, n]$ correctly checks all valid subarray lengths and finds the global maximum.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
8 1 2
-1 3 -2 5 3 -5 2 2
```
$n = 8, a = 1, b = 2$.
Prefix sums $P$:
$P = [0, -1, 2, 0, 5, 8, 3, 5, 7]$

| $j$ | $x_j$ | $P[j]$ | Window $[j-b, j-a]$ | Enter `enter_idx` ($P$) | Deque State (Indices) | Min $P[k]$ (`dq.front()`) | $P[j] - P[k]$ | `max_sum` |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | -1 | -1 | $[-1, 0] \to [0, 0]$ | $0$ ($P[0]=0$) | `[0]` | $P[0] = 0$ | $-1 - 0 = -1$ | -1 |
| **2** | 3 | 2 | $[0, 1]$ | $1$ ($P[1]=-1$) | `[1]` (pops 0 since $-1 \le 0$) | $P[1] = -1$ | $2 - (-1) = \mathbf{3}$ | 3 |
| **3** | -2 | 0 | $[1, 2]$ | $2$ ($P[2]=2$) | `[1, 2]` | $P[1] = -1$ | $0 - (-1) = 1$ | 3 |
| **4** | 5 | 5 | $[2, 3]$ | $3$ ($P[3]=0$, pops 2) | `[3]` (idx 1 expired $< 2$) | $P[3] = 0$ | $5 - 0 = \mathbf{5}$ | 5 |
| **5** | 3 | 8 | $[3, 4]$ | $4$ ($P[4]=5$) | `[3, 4]` | $P[3] = 0$ | $8 - 0 = \mathbf{8}$ | **8** |
| **6** | -5 | 3 | $[4, 5]$ | $5$ ($P[5]=8$) | `[4, 5]` (idx 3 expired $< 4$) | $P[4] = 5$ | $3 - 5 = -2$ | 8 |
| **7** | 2 | 5 | $[5, 6]$ | $6$ ($P[6]=3$, pops 5) | `[6]` (idx 4 expired $< 5$) | $P[6] = 3$ | $5 - 3 = 2$ | 8 |
| **8** | 2 | 7 | $[6, 7]$ | $7$ ($P[7]=5$) | `[6, 7]` | $P[6] = 3$ | $7 - 3 = 4$ | 8 |

**Final Output**: `8` (Subarray $x[4 \dots 5] = [5, 3]$, length 2, sum $= 8$).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$a = b$**: Subarrays of fixed length $a$. The window degenerates to a single index $j - a$, and the deque runs in $\mathcal{O}(1)$ without popping.
- **$a = 1, b = n$**: Standard Kadane's maximum subarray sum (any positive length). Output matches Kadane's algorithm.
- **All Elements Negative**: `max_subarray_sum` must be initialized to a sufficiently small value (e.g., `-4e18`). Initializing to `0` would incorrectly return `0` when all valid subarray sums are negative.
- **64-bit Integer Overflow**: Prefix sums can range from $-2 \cdot 10^{14}$ to $+2 \cdot 10^{14}$. Using 32-bit integers results in integer overflow.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Circular Array Maximum Subarray Sum with Length Limit?**
   - Duplicate the array to length $2n$ and enforce window length constraint $a \le \text{length} \le \min(b, n)$ using the same monotonic deque technique.
2. **2D Grid Maximum Submatrix Sum with Area Limit?**
   - When bounded by rectangular dimensions $h \in [a_h, b_h]$ and $w \in [a_w, b_w]$, iterate over row pairs and apply the 1D sliding window deque over column sums.
3. **Maximum Average Subarray Sum of Length in $[a, b]$?**
   - Binary search on the answer average $X$. Subtract $X$ from each element: $x_i' = x_i - X$. Then check if the maximum subarray sum of length in $[a, b]$ is $\ge 0$ using this exact monotonic deque in $\mathcal{O}(n \log(\text{precision}))$.
4. **Dynamic Point Updates to Array?**
   - Monotonic deque cannot accommodate dynamic modifications. Use a Segment Tree over prefix sums with lazy propagation in $\mathcal{O}(\log n)$ per update/query.
5. **Memory Constraint: $\mathcal{O}(1)$ Extra Space?**
   - If allowed to modify the array, prefix sums can be computed in-place in $x$. The deque can be simulated using a ring buffer of fixed capacity $b - a + 1$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[monotonic-deque, sliding-window, prefix-sums, sorting-and-searching]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - `CSES 1643` — [Maximum Subarray Sum](https://cses.fi/problemset/task/1643) (Unconstrained length, solved with Kadane's algorithm).
  - `CSES 1645` — [Nearest Smaller Values](https://cses.fi/problemset/task/1645) (Monotonic stack for nearest smaller element).
  - `CSES 1141` — [Playlist](https://cses.fi/problemset/task/1141) (Sliding window unique elements).
