# Factory Machines (CSES Task 1620 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1620 - Factory Machines](https://cses.fi/problemset/task/1620)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: A factory has $n$ machines. Machine $i$ requires $k_i$ seconds to make a product. All machines can operate simultaneously. Find the minimum time required to produce at least $t$ products.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le t \le 10^9$, $1 \le k_i \le 10^9$.

---

## 1. Problem, Restated

Given $n$ machine production times $k_1, k_2, \dots, k_n$ and a target product count $t$:
Find the minimal non-negative integer time $T$ such that:
$$\sum_{i=1}^n \left\lfloor \frac{T}{k_i} \right\rfloor \ge t$$

**Input**:
- First line: two integers $n$ and $t$ ($1 \le n \le 2 \cdot 10^5$, $1 \le t \le 10^9$).
- Second line: $n$ space-separated integers $k_1, \dots, k_n$ ($1 \le k_i \le 10^9$).

**Output**:
- Print a single integer: the minimum time $T$.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Binary Search on Answer / Monotonic Predicate Function / Work Scheduling.
- **Aha! Insight**:
  - Finding the exact time directly is difficult because machine cycles interleave asynchronously.
  - However, the **decision problem** is trivial:
    *Given a fixed time $T$, can the machines produce at least $t$ products?*
  - In time $T$, machine $i$ produces exactly $\lfloor T / k_i \rfloor$ products independently.
  - The total products produced is simply:
    $$P(T) = \sum_{i=1}^n \left\lfloor \frac{T}{k_i} \right\rfloor$$
  - **Monotonicity**: $P(T)$ is a non-decreasing function of $T$. If $P(T) \ge t$, then for all $T' > T$, $P(T') \ge t$.
  - This monotonicity allows us to **binary search on the answer $T$**!
  - **Search Bounds**:
    - Low bound: $L = 1$.
    - High bound: If we only ran the fastest machine ($\min k_i$), it would take at most $t \cdot \min k_i \le 10^9 \times 10^9 = 10^{18}$ seconds.
    - Thus, $R = 10^{18}$.
  - The search space $[1, 10^{18}]$ requires only $\approx \log_2(10^{18}) \approx 60$ iterations, each taking $\mathcal{O}(n)$ operations!
- **Signal**: "Find the minimum time/resource to achieve a total output" where feasibility is monotonic is the definition of Binary Search on Answer.

---

## 3. Approach 1 — Naive / Baseline (Priority Queue Simulation)

Simulate event-by-event using a min-heap storing when each machine finishes its next product: `(finish_time, machine_rate)`.
Each product takes $\mathcal{O}(\log n)$ to extract and reschedule.
For $t = 10^9$, total operations $\approx 10^9 \times \log_2(2 \cdot 10^5) \approx 1.8 \cdot 10^{10} \implies$ massive TLE.

---

## 4. Approach 2 — Intermediate (Binary Search with Float Arithmetic)

Binary searching with double-precision floats or calculating an initial estimate $T \approx \frac{t}{\sum 1/k_i}$.
Floating-point precision limits (53 bits for standard IEEE 754 `double`) lose accuracy beyond $10^{15}$, causing precision errors. Integer binary search with `long long` is exact and avoids all float pitfalls.

---

## 5. Approach 3 — Optimal CSES Solution (Exact Integer Binary Search on Answer)

### Idea
1. Set search range: `low = 1`, `high = min_element(k) * t`.
2. While `low <= high`:
   - `mid = low + (high - low) / 2`
   - Compute products made: `products = 0`
   - For each $k_i$, add `mid / k_i`. If `products >= t`, break early to avoid overflow.
   - If `products >= t`: `ans = mid`, `high = mid - 1`.
   - Else: `low = mid + 1`.
3. Output `ans`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

bool can_produce(const vector<long long>& k, long long t, long long time_limit) {
    long long products = 0;
    for (long long rate : k) {
        products += time_limit / rate;
        if (products >= t) {
            return true; // Early exit prevents 64-bit sum overflow
        }
    }
    return products >= t;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    long long t;
    if (!(cin >> n >> t)) return 0;

    vector<long long> k(n);
    long long min_rate = 2e9;
    for (int i = 0; i < n; ++i) {
        cin >> k[i];
        min_rate = min(min_rate, k[i]);
    }

    long long low = 1;
    long long high = min_rate * t;
    long long ans = high;

    while (low <= high) {
        long long mid = low + (high - low) / 2;
        if (can_produce(k, t, mid)) {
            ans = mid;
            high = mid - 1; // Try to find a smaller valid time
        } else {
            low = mid + 1;  // Need more time
        }
    }

    cout << ans << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log(\min(k) \cdot t))$.
  - The binary search interval has size $\le 10^{18}$, requiring $\lceil \log_2(10^{18}) \rceil \le 60$ iterations.
  - Each check scans $n$ machines with early pruning.
  - Total operations $\le 60 \times 2 \cdot 10^5 = 1.2 \cdot 10^7$, executing in $\approx 0.03$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ storage for machine rates. $\mathcal{O}(1)$ auxiliary space.

---

## 6. Correctness Proof

1. **Monotonicity of Production**:
   For any positive integer $k_i$, the floor function $f(T) = \lfloor T / k_i \rfloor$ is non-decreasing in $T$.
   As a sum of non-decreasing functions, $P(T) = \sum_{i=1}^n \lfloor T / k_i \rfloor$ is non-decreasing.
2. **Existence of Threshold**:
   - $P(0) = 0 < t$.
   - For $T_{\max} = t \cdot \min_i k_i$, machine $\text{argmin}_i k_i$ alone produces $\lfloor (t \cdot \min k_i) / \min k_i \rfloor = t$ products. Thus $P(T_{\max}) \ge t$.
   - By the Discrete Intermediate Value property of monotonic integer functions, there exists a unique minimum integer $T^* \in [1, T_{\max}]$ such that $P(T) \ge t \iff T \ge T^*$.
3. **Binary Search Convergence**:
   At each step, if $P(\text{mid}) \ge t$, the optimum satisfies $T^* \le \text{mid}$, so `ans = mid` and `high = mid - 1` shrinks the search space while preserving $T^*$.
   If $P(\text{mid}) < t$, $T^* > \text{mid}$, so `low = mid + 1` preserves $T^*$.
   The interval $[low, high]$ strictly halves in each iteration until empty, at which point `ans` contains precisely $T^*$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 3, t = 7$, rates: `[3, 2, 5]`.
$\min(k) = 2 \implies \text{high} = 2 \times 7 = 14$. $\text{low} = 1$.

- Iteration 1: $\text{mid} = (1 + 14) / 2 = 7$.
  Products: $\lfloor 7/3 \rfloor + \lfloor 7/2 \rfloor + \lfloor 7/5 \rfloor = 2 + 3 + 1 = 6 < 7$.
  Not enough. $\text{low} \to 8$.
- Iteration 2: $\text{mid} = (8 + 14) / 2 = 11$.
  Products: $\lfloor 11/3 \rfloor + \lfloor 11/2 \rfloor + \lfloor 11/5 \rfloor = 3 + 5 + 2 = 10 \ge 7$.
  Valid! $\text{ans} = 11$, $\text{high} \to 10$.
- Iteration 3: $\text{mid} = (8 + 10) / 2 = 9$.
  Products: $\lfloor 9/3 \rfloor + \lfloor 9/2 \rfloor + \lfloor 9/5 \rfloor = 3 + 4 + 1 = 8 \ge 7$.
  Valid! $\text{ans} = 9$, $\text{high} \to 8$.
- Iteration 4: $\text{mid} = (8 + 8) / 2 = 8$.
  Products: $\lfloor 8/3 \rfloor + \lfloor 8/2 \rfloor + \lfloor 8/5 \rfloor = 2 + 4 + 1 = 7 \ge 7$.
  Valid! $\text{ans} = 8$, $\text{high} \to 7$.
- Loop terminates ($\text{low} > \text{high}$).

Final Output: **8**. Matches the CSES example!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **CRITICAL: 64-bit Integer Overflow During Product Accumulation**:
  If $T = 10^{18}$ and machines have rate $k_i = 1$, summing $\sum \lfloor T / k_i \rfloor$ without early exit produces $n \times 10^{18} = 2 \cdot 10^{23}$, which overflows standard 64-bit signed integer max ($9.22 \times 10^{18}$).
  Checking `if (products >= t) return true;` inside the loop prevents overflow.
- **Midpoint Calculation**: `mid = low + (high - low) / 2` avoids potential overflow from `(low + high)`.
- **$t = 1$**: Output is $\min k_i$.
- **$n = 1$**: Handled properly; returns $k_0 \cdot t$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if each machine has a setup time before it can start?**
   - If machine $i$ requires setup time $s_i$, it produces $\max(0LL, \lfloor (T - s_i) / k_i \rfloor)$ products. The function remains monotonic, so binary search still applies.
2. **How to find which specific machine made the $t$-th product?**
   - Let $T^*$ be the answer. The machine that finished a product exactly at second $T^*$ satisfies $T^* \bmod k_i == 0$.
3. **What if machines degrade and take longer after each product?**
   - If production times increase linearly $k_i, 2k_i, 3k_i, \dots$, solving the quadratic $m(m+1)/2 \cdot k_i \le T$ computes products per machine in $\mathcal{O}(1)$, maintaining binary search.
4. **How does this problem compare to LeetCode 875 (Koko Eating Bananas)?**
   - LeetCode 875 is the inverse: binary search on the rate $K$ to finish within time $H$, whereas CSES 1620 searches for time $T$ to finish $t$ items.
5. **Can this be solved with Ternary Search?**
   - No, ternary search is for unimodal functions (finding local extrema). Binary search is for monotonic step/predicate functions.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Binary Search, Binary Search on Answer, Monotonicity, Math.
- **Time Complexity**: $\mathcal{O}(n \log(\min(k) \cdot t))$ optimal time.
- **Space Complexity**: $\mathcal{O}(n)$ memory for machines array.

### Related CSES Tasks
- [CSES 1085 - Array Division](https://cses.fi/problemset/task/1085): Binary search on maximum subarray sum.
- [CSES 1630 - Tasks and Deadlines](https://cses.fi/problemset/task/1630): Greedy task scheduling by duration.
- [CSES 1631 - Reading Books](https://cses.fi/problemset/task/1631): Two-agent greedy reading schedule.
