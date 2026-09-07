# Subarray Sums I

- **Category**: Sorting and Searching
- **CSES Task ID**: `1660`
- **CSES Problem Link**: [Subarray Sums I](https://cses.fi/problemset/task/1660)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ **positive** integers $a_1, a_2, \dots, a_n$ and a target value $x$, count the total number of contiguous subarrays whose elements sum to exactly $x$.

### Input Format
- The first line contains two integers $n$ and $x$.
- The second line contains $n$ positive integers $a_1, a_2, \dots, a_n$.

### Output Format
- Print one integer: the number of subarrays with sum equal to $x$.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le x \le 10^9$
- $1 \le a_i \le 10^9$

Because $n = 2 \cdot 10^5$, an $\mathcal{O}(n^2)$ subarray check requires $2 \cdot 10^{10}$ operations, causing TLE. Furthermore, the sum of elements can reach $n \times 10^9 = 2 \cdot 10^{14}$, which exceeds signed 32-bit `int` and requires 64-bit integers (`long long`).

---

## 2. Intuition & Pattern Recognition

The critical structural property in Subarray Sums I is that **all array elements are strictly positive** ($a_i \ge 1$):
- Adding an element to the right of a subarray strictly increases its sum.
- Removing an element from the left strictly decreases its sum.

This strict monotonicity enables the classic **Two Pointers (Sliding Window)** technique:
- Maintain a window $[L, R]$ and its running sum.
- When expanding $R$, if the window sum exceeds $x$, advance $L$ to reduce the sum.
- Because both $L$ and $R$ advance monotonically from $0$ to $n-1$, the algorithm runs in $\mathcal{O}(n)$ time with $\mathcal{O}(1)$ auxiliary space.

---

## 3. Approach 1 — Naive / Baseline

Test all possible subarrays $(i, j)$ where $0 \le i \le j < n$, accumulating the sum.

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
                break; // Since all elements are positive, adding more will strictly exceed x
            }
            if (current_sum > x) {
                break;
            }
        }
    }

    cout << count << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2)$ in the worst case (e.g., when $x$ is very large and all elements are small).
- **Space Complexity**: $\mathcal{O}(n)$ to store the array.
- **CSES Verdict**: TLE for $n > 5000$.

---

## 4. Approach 2 — Intermediate / Prefix Sums with Binary Search

Because all $a_i \ge 1$, the prefix sums $P[k] = \sum_{j=0}^{k-1} a_j$ are strictly increasing. A subarray sum from $i$ to $j$ equals $P[j+1] - P[i]$. For each prefix sum $P[i]$, we can binary search for an index $k$ such that $P[k] = P[i] + x$ using `std::lower_bound`.

### C++17 Binary Search Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    long long x;
    if (!(cin >> n >> x)) return 0;

    vector<long long> pref(n + 1, 0);
    for (int i = 1; i <= n; ++i) {
        long long val;
        cin >> val;
        pref[i] = pref[i - 1] + val;
    }

    long long count = 0;
    for (int i = 0; i <= n; ++i) {
        long long target = pref[i] + x;
        if (binary_search(pref.begin() + i + 1, pref.end(), target)) {
            count++;
        }
    }

    cout << count << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n)$ due to $n$ binary searches over a sorted vector of size $n+1$.
- **Space Complexity**: $\mathcal{O}(n)$ to store prefix sums.
- **Verdict**: Passes CSES, but uses $\mathcal{O}(n)$ extra memory and logarithmic lookup time compared to the optimal two-pointer solution.

---

## 5. Approach 3 — Optimal CSES Solution (Two Pointers / Sliding Window)

We maintain two pointers $L$ and $R$ defining the current window $[L, R]$, along with `current_sum`:
1. Incrementally add $a[R]$ to `current_sum`.
2. While `current_sum > x` and $L \le R$, subtract $a[L]$ from `current_sum` and advance $L$.
3. If `current_sum == x`, increment the match count.
4. Advance $R$ until the end of the array is reached.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    // Fast I/O
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
    long long current_sum = 0;
    int left = 0;

    for (int right = 0; right < n; ++right) {
        current_sum += a[right];

        // Shrink window from the left while sum exceeds target
        while (current_sum > x && left <= right) {
            current_sum -= a[left];
            left++;
        }

        // If window sum exactly matches target, record it
        if (current_sum == x) {
            count++;
        }
    }

    cout << count << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n)$. Both `left` and `right` advance from $0$ to $n-1$. Each element is added to `current_sum` once and subtracted at most once. Hence, the `while` loop runs at most $n$ times across the entire algorithm.
- **Space Complexity**: $\mathcal{O}(n)$ to store the input array (or $\mathcal{O}(1)$ auxiliary space if reading on-the-fly with a queue/circular buffer).
- **Optimality Guarantee**: Every element must be read, establishing an $\Omega(n)$ lower bound. $\mathcal{O}(n)$ matches this bound.

---

## 6. Correctness Proof

### Monotonicity Invariant
Because $a_i > 0$ for all $1 \le i \le n$:
$$\sum_{k=l_1}^{r} a_k > \sum_{k=l_2}^{r} a_k \quad \text{for all } l_1 < l_2$$
Thus, for any fixed right endpoint $R$, there is **at most one** left endpoint $L \le R$ such that $\sum_{k=L}^R a_k = x$.

### Algorithm Invariants
1. For any given $R$, advancing $L$ until $\sum_{k=L}^R a_k \le x$ ensures that no valid left endpoint $L' < L$ satisfies $\sum_{k=L'}^R a_k = x$, because $\sum_{k=L'}^R a_k > \sum_{k=L}^R a_k \ge x$.
2. When the while-loop terminates, either $\sum_{k=L}^R a_k = x$ (which we count) or $\sum_{k=L}^R a_k < x$. If $< x$, then any $L'' > L$ would yield an even smaller sum $< x$.
3. Thus, for each $R$, the unique $L$ that can possibly satisfy the target sum is checked.
4. Summing over all $R \in [0, n-1]$ counts each valid subarray exactly once.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 7
2 4 1 2 7
```

| Step ($R$) | $a[R]$ | `current_sum` before shrink | Shrink actions | Final `current_sum` | $L$ | `current_sum == x`? | Total Count |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | 2 | 2 | None ($2 \le 7$) | 2 | 0 | No | 0 |
| **1** | 4 | $2 + 4 = 6$ | None ($6 \le 7$) | 6 | 0 | No | 0 |
| **2** | 1 | $6 + 1 = 7$ | None ($7 \le 7$) | 7 | 0 | **Yes ($[2, 4, 1]$)** | **1** |
| **3** | 2 | $7 + 2 = 9$ | Sub $a[0]=2 \implies 7$ | 7 | 1 | **Yes ($[4, 1, 2]$)** | **2** |
| **4** | 7 | $7 + 7 = 14$ | Sub $a[1]=4 \implies 10$<br>Sub $a[2]=1 \implies 9$<br>Sub $a[3]=2 \implies 7$ | 7 | 4 | **Yes ($[7]$)** | **3** |

**Final Output**: `3` (Subarrays: `[2, 4, 1]`, `[4, 1, 2]`, `[7]`).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$a_i > x$**: When an element alone exceeds $x$, the while-loop shrinks $L$ until $L = R + 1$ and `current_sum = 0`, gracefully handling elements larger than the target.
- **Single Element Array**: $n = 1$: If $a_0 = x$, outputs `1`; otherwise `0`.
- **64-bit Integer Overflow**: The sum of values can exceed $2^{31} - 1$ ($2 \cdot 10^5 \times 10^9 = 2 \cdot 10^{14}$). Both $x$ and `current_sum` must be declared as `long long`.
- **Contrast with Negative Numbers**: The sliding window works **only** because $a_i > 0$. If $a_i \le 0$ were allowed, the sum would not be monotonic, requiring the prefix-sum hash map approach used in *Subarray Sums II*.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the array contains zero or negative numbers?**
   - Monotonicity breaks. Use a hash map of prefix sums (`CSES 1661: Subarray Sums II`) in $\mathcal{O}(n)$ time and $\mathcal{O}(n)$ space.
2. **Shortest subarray with sum $\ge x$?**
   - Maintain sliding window. Whenever `current_sum >= x`, update `min_len = min(min_len, R - L + 1)` and shrink $L$ to find the minimal window.
3. **Number of subarrays with sum $\le x$?**
   - When $[L, R]$ has sum $\le x$, all subarrays ending at $R$ with start index in $[L, R]$ also have sum $\le x$ (since $a_i > 0$). Thus, add $(R - L + 1)$ to the total count.
4. **Online / Streaming processing?**
   - Can stream elements using a queue for window $[L, R]$: push incoming elements and pop from front when sum exceeds $x$, maintaining $\mathcal{O}(1)$ auxiliary space.
5. **2D Subarray (Submatrix) Sums?**
   - For a 2D matrix, compress pairs of rows $(r_1, r_2)$ into a 1D column-sum array and apply two pointers if all matrix entries are positive, giving $\mathcal{O}(R^2 \cdot C)$ time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[two-pointers, sliding-window, prefix-sums, sorting-and-searching]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n)$
  - Space: $\mathcal{O}(1)$ auxiliary ($\mathcal{O}(n)$ to store input)
- **Related CSES Problems**:
  - `CSES 1661` — [Subarray Sums II](https://cses.fi/problemset/task/1661) (General case with negative numbers, solved via hash maps).
  - `CSES 1662` — [Subarray Divisibility](https://cses.fi/problemset/task/1662) (Subarray sums divisible by $n$, solved via prefix modulo counts).
  - `CSES 2428` — [Subarray Distinct Values](https://cses.fi/problemset/task/2428) (Two-pointer sliding window with at most $k$ distinct values).
