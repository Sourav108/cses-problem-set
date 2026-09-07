# Maximum Subarray Sum (CSES Task 1643 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1643 - Maximum Subarray Sum](https://cses.fi/problemset/task/1643)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Given an array of $n$ integers, find the maximum sum of values in a contiguous, non-empty subarray.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $-10^9 \le x_i \le 10^9$.

---

## 1. Problem, Restated

Given an array of $n$ integers $x = [x_1, x_2, \dots, x_n]$, find:
$$\max_{1 \le i \le j \le n} \sum_{k=i}^j x_k$$
subject to the condition that the subarray must be non-empty ($j \ge i$).

**Input**:
- First line: an integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Second line: $n$ space-separated integers $x_1, \dots, x_n$ ($-10^9 \le x_i \le 10^9$).

**Output**:
- Print a single integer: the maximum non-empty subarray sum.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Kadane's Algorithm / Dynamic Programming / Prefix Sum Minimization.
- **Aha! Insight**:
  - Let $S[i]$ denote the maximum subarray sum ending strictly at index $i$.
  - When transitioning from index $i-1$ to index $i$:
    - We can either extend the best subarray ending at $i-1$: $S[i-1] + x_i$.
    - Or start a fresh new subarray starting at index $i$: $x_i$.
  - Therefore, the recurrence relation is:
    $$S[i] = \max(x_i, S[i-1] + x_i)$$
  - The overall answer is simply the maximum across all ending positions:
    $$\text{ans} = \max_{1 \le i \le n} S[i]$$
  - Notice that $S[i]$ depends only on $S[i-1]$. Hence, we can maintain the state using a single variable `current_sum`, taking $\mathcal{O}(1)$ auxiliary space and $\mathcal{O}(n)$ time.
  - **All-negative elements gotcha**: The subarray must be non-empty. If all numbers are negative, initializing `max_sum = 0` is incorrect! Initializing `max_sum = x[0]` correctly handles arrays consisting entirely of negative numbers (returning the least negative number).
- **Signal**: "Maximum sum contiguous subarray" is the foundational Kadane's Algorithm.

---

## 3. Approach 1 — Naive / Baseline ($\mathcal{O}(n^2)$ Prefix Sums)

Compute prefix sums $P[i] = \sum_{k=1}^i x_k$. For every pair $(i, j)$ with $i \le j$, evaluate $P[j] - P[i-1]$ and track the maximum.
Takes $\frac{n(n+1)}{2} \approx 2 \cdot 10^{10}$ operations for $n = 2 \cdot 10^5$, leading to Time Limit Exceeded.

---

## 4. Approach 2 — Intermediate (Divide and Conquer)

Recursively split the array into halves. The maximum subarray either lies entirely in the left half, entirely in the right half, or crosses the midpoint.
While $\mathcal{O}(n \log n)$ and useful for parallel implementations, Kadane's linear $\mathcal{O}(n)$ algorithm is asymptotically superior and simpler.

---

## 5. Approach 3 — Optimal CSES Solution (Kadane's Algorithm)

### Idea
1. Read $x_0$, initialize `current_sum = x[0]` and `max_sum = x[0]`.
2. For each subsequent number $x_i$:
   - `current_sum = max(x_i, current_sum + x_i)`
   - `max_sum = max(max_sum, current_sum)`
3. Output `max_sum`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    long long first_val;
    cin >> first_val;

    long long current_sum = first_val;
    long long max_sum = first_val;

    for (int i = 1; i < n; ++i) {
        long long x;
        cin >> x;
        current_sum = max(x, current_sum + x);
        max_sum = max(max_sum, current_sum);
    }

    cout << max_sum << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n)$. We process each element exactly once in a single streaming pass. For $n = 2 \cdot 10^5$, this executes in $\approx 0.02$ seconds.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary space beyond scalar variables (processes input in an online stream without storing the array).

---

## 6. Correctness Proof

1. **Inductive Invariant on $S[i]$**:
   Define $S[i]$ as the maximum sum among all non-empty subarrays ending at index $i$:
   $$S[i] = \max_{1 \le k \le i} \sum_{m=k}^i x_m$$
   - **Base Case ($i = 1$)**: The only non-empty subarray ending at index 1 is $[x_1]$, so $S[1] = x_1$.
   - **Inductive Step**: Any subarray ending at index $i$ either has length 1 (sum $x_i$) or length $> 1$ (sum $x_i + \sum_{m=k}^{i-1} x_m$ for some $1 \le k \le i-1$).
     To maximize the sum of a subarray of length $> 1$, we must maximize the sum of the prefix ending at $i-1$, which by definition is $S[i-1]$.
     Hence:
     $$S[i] = \max(x_i, x_i + S[i-1])$$
2. **Global Maximization**:
   Every non-empty subarray in the entire array ends at some index $i \in [1, n]$.
   Therefore, the maximum over all non-empty subarrays is identically:
   $$\max_{1 \le i \le j \le n} \sum_{k=i}^j x_k = \max_{1 \le j \le n} \left( \max_{1 \le i \le j} \sum_{k=i}^j x_k \right) = \max_{1 \le j \le n} S[j]$$
   Kadane's algorithm evaluates this exact maximum. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 8$, array = `[-1, 3, -2, 5, 3, -5, 2, 2]`.

| Step $i$ | Value $x_i$ | `current_sum = max(x, cur + x)` | `max_sum = max(max, cur)` | Active Subarray Range |
| :--- | :--- | :--- | :--- | :--- |
| 0 | -1 | -1 | -1 | `[-1]` |
| 1 | 3 | $\max(3, -1 + 3) = 3$ | $\max(-1, 3) = 3$ | `[3]` |
| 2 | -2 | $\max(-2, 3 - 2) = 1$ | 3 | `[3, -2]` |
| 3 | 5 | $\max(5, 1 + 5) = 6$ | $\max(3, 6) = 6$ | `[3, -2, 5]` |
| 4 | 3 | $\max(3, 6 + 3) = 9$ | $\max(6, 9) = 9$ | `[3, -2, 5, 3]` |
| 5 | -5 | $\max(-5, 9 - 5) = 4$ | 9 | `[3, -2, 5, 3, -5]` |
| 6 | 2 | $\max(2, 4 + 2) = 6$ | 9 | `[3, -2, 5, 3, -5, 2]` |
| 7 | 2 | $\max(2, 6 + 2) = 8$ | 9 | `[3, -2, 5, 3, -5, 2, 2]` |

Final Output: **9** (corresponding to subarray `[3, -2, 5, 3]`).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **CRITICAL: 64-bit Integer Overflow**:
  $n = 2 \cdot 10^5$, and each element can be up to $10^9$.
  The maximum subarray sum can reach $2 \cdot 10^5 \times 10^9 = 2 \cdot 10^{14}$, which far exceeds 32-bit signed integer capacity ($2^{31} - 1 \approx 2.14 \times 10^9$).
  Using `long long` for `current_sum` and `max_sum` is strictly required.
- **All Negative Numbers (e.g. `[-5, -3, -9]`)**:
  Initializing `max_sum = 0` would falsely output 0.
  Initializing `current_sum` and `max_sum` with $x_0$ guarantees that the least negative element (`-3`) is correctly returned.
- **Single Element Array ($n = 1$)**: Correctly returns $x_0$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How to find the start and end indices of the maximum subarray?**
   - Track `start_idx` and `end_idx`: whenever `x > current_sum + x`, reset `temp_start = i`. Whenever `current_sum > max_sum`, update `best_start = temp_start` and `best_end = i`.
2. **What if the array is circular (Circular Subarray Sum)?**
   - The maximum circular subarray is either the standard maximum subarray sum OR the total array sum minus the minimum subarray sum:
     $$\max(\text{KadaneMax}(A), \text{TotalSum} - \text{KadaneMin}(A))$$
     (with the corner case that if all numbers are negative, return `KadaneMax(A)`).
3. **What if subarray length must be between $a$ and $b$?**
   - This is **Maximum Subarray Sum II (CSES 1644)**! Solved using prefix sums and a sliding window monotonic queue (or `std::multiset`) in $\mathcal{O}(n)$.
4. **How to support point updates and range maximum subarray queries?**
   - Use a Segment Tree where each node maintains four values: `total_sum`, `max_prefix`, `max_suffix`, and `max_subarray`. Nodes merge in $\mathcal{O}(1)$.
5. **How does Kadane's algorithm relate to prefix sums?**
   - Subarray sum $x[i \dots j] = P[j] - P[i-1]$. Maximizing $P[j] - P[i-1]$ for fixed $j$ is equivalent to minimizing the prefix sum $P[i-1]$ over all $0 \le i-1 < j$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Dynamic Programming, Kadane's Algorithm, Greedy, Prefix Sums.
- **Time Complexity**: $\mathcal{O}(n)$ single-pass linear time.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary space.

### Related CSES Tasks
- [CSES 1644 - Maximum Subarray Sum II](https://cses.fi/problemset/task/1644): Constrained length subarray sum via monotonic deque.
- [CSES 1660 - Subarray Sums I](https://cses.fi/problemset/task/1660): Counting subarrays with sum equal to $x$.
- [CSES 1661 - Subarray Sums II](https://cses.fi/problemset/task/1661): Subarray sum count with negative values via prefix hash maps.
