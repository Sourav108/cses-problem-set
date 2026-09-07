# Stick Lengths (CSES Task 1074 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1074 - Stick Lengths](https://cses.fi/problemset/task/1074)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: There are $n$ sticks with given lengths. Your task is to modify the sticks so that each stick has the same length. Changing a stick length costs 1 per unit change. Find the minimum total cost.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le p_i \le 10^9$.

---

## 1. Problem, Restated

Given an array of $n$ stick lengths $p_1, p_2, \dots, p_n$, find an integer target length $X$ that minimizes the total $L_1$ deviation:
$$C(X) = \sum_{i=1}^n |p_i - X|$$
and output the minimum cost $C(X)$.

**Input**:
- First line: integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Second line: $n$ space-separated integers $p_1, \dots, p_n$.

**Output**:
- Print a single integer: the minimum total cost.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Median Minimization / $L_1$ Norm Optimization / Order Statistics / Convex Functions.
- **Aha! Insight**:
  - Many beginners mistakenly compute the **mean** (average) of the numbers.
    - The mean minimizes the sum of **squared differences** $\sum (p_i - X)^2$ ($L_2$ norm).
    - The **median** minimizes the sum of **absolute differences** $\sum |p_i - X|$ ($L_1$ norm)!
  - Why the median?
    - Consider moving the target value $X$ by a small amount $\epsilon > 0$.
    - For every stick $p_i < X$, the cost $|p_i - X|$ increases by $\epsilon$.
    - For every stick $p_i > X$, the cost $|p_i - X|$ decreases by $\epsilon$.
    - The net rate of change of cost with respect to $X$ is:
      $$\frac{dC}{dX} = |\{i : p_i < X\}| - |\{i : p_i > X\}|$$
    - To minimize cost, this derivative must equal zero: the number of elements to the left of $X$ must equal the number of elements to the right of $X$.
    - This balance is achieved precisely at the **median** of the dataset!
  - If $n$ is odd, the median is unique: $p_{\lfloor n/2 \rfloor}$ in sorted order.
  - If $n$ is even, any integer $X \in [p_{n/2 - 1}, p_{n/2}]$ achieves the exact same optimal cost.
  - Hence, simply picking $X = p_{n/2}$ after sorting (or via `std::nth_element`) is always optimal.
- **Signal**: Minimizing $\sum |x_i - C|$ is the universal mathematical property of the median.

---

## 3. Approach 1 — Naive / Baseline (Ternary Search on Target $X$)

Because $C(X) = \sum |p_i - X|$ is a convex function, one can ternary search over $X \in [\min p_i, \max p_i]$.
In each step, compute $\sum |p_i - X|$ in $\mathcal{O}(n)$.
While correct in $\mathcal{O}(n \log(\max p))$, it requires 60+ iterations of $\mathcal{O}(n)$ checks ($\approx 1.2 \times 10^7$ operations), which is unnecessary when the exact optimal $X$ is directly computable as the median.

---

## 4. Approach 2 — Intermediate (Sorting the Array)

Sort the entire array using `std::sort(p.begin(), p.end())`, pick $X = p[n / 2]$, and sum the deviations $\sum |p_i - X|$ in $\mathcal{O}(n \log n)$.
This is contest-ready, simple to code, and runs in $\approx 0.05$s.

---

## 5. Approach 3 — Optimal CSES Solution (Linear Time via `std::nth_element`)

### Idea
Instead of fully sorting the $n$ elements in $\mathcal{O}(n \log n)$, use the QuickSelect algorithm provided by `std::nth_element(p.begin(), p.begin() + n / 2, p.end())` to find the median in strictly $\mathcal{O}(n)$ average time. Then compute the total cost in a single linear pass.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <cmath>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<long long> p(n);
    for (int i = 0; i < n; ++i) {
        cin >> p[i];
    }

    // Find median in O(n) average time using QuickSelect
    nth_element(p.begin(), p.begin() + n / 2, p.end());
    long long median = p[n / 2];

    long long total_cost = 0;
    for (int i = 0; i < n; ++i) {
        total_cost += abs(p[i] - median);
    }

    cout << total_cost << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n)$ average time for `std::nth_element`, followed by $\mathcal{O}(n)$ to sum differences. For $n = 2 \cdot 10^5$, this executes in $\approx 0.03$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ array storage. $\mathcal{O}(1)$ auxiliary space.

---

## 6. Correctness Proof

**Theorem**: The function $C(X) = \sum_{i=1}^n |p_i - X|$ is minimized at the median of $p$.

**Proof**:
1. Sort the stick lengths: $p_{(1)} \le p_{(2)} \le \dots \le p_{(n)}$.
2. Group the sum into symmetric pairs of outermost elements:
   $$C(X) = \sum_{i=1}^{\lfloor n/2 \rfloor} \Big( |p_{(i)} - X| + |p_{(n - i + 1)} - X| \Big) + \Big( \text{if } n \text{ is odd: } |p_{(\lceil n/2 \rceil)} - X| \Big)$$
3. By the triangle inequality on the real line:
   $$|p_{(i)} - X| + |p_{(n - i + 1)} - X| = |X - p_{(i)}| + |p_{(n - i + 1)} - X| \ge |p_{(n - i + 1)} - p_{(i)}|$$
   Equality holds if and only if $X$ lies within the interval $[p_{(i)}, p_{(n - i + 1)}]$.
4. To minimize the overall sum $C(X)$, we must simultaneously achieve equality for every pair $i \in \{1, 2, \dots, \lfloor n/2 \rfloor\}$.
   This requires:
   $$X \in \bigcap_{i=1}^{\lfloor n/2 \rfloor} [p_{(i)}, p_{(n - i + 1)}] = [p_{(\lfloor n/2 \rfloor)}, p_{(\lceil n/2 \rceil)}]$$
5. If $n$ is odd, the intersection collapses to the single point $X = p_{(\lceil n/2 \rceil)}$, and $|X - X| = 0$.
   If $n$ is even, the intersection is the non-empty interval $[p_{(n/2)}, p_{(n/2 + 1)}]$.
   Every point in this median interval achieves the exact mathematical minimum cost.
   Hence, choosing $X = p_{\lfloor n/2 \rfloor}$ guarantees the absolute minimum. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 5$, $p = [2, 3, 1, 5, 2]$.
Sorted: $p = [1, 2, 2, 3, 5]$.
Median ($n/2 = 2$): $p[2] = 2$.

Deviation calculations:
- $|1 - 2| = 1$
- $|2 - 2| = 0$
- $|2 - 2| = 0$
- $|3 - 2| = 1$
- $|5 - 2| = 3$

Total cost: $1 + 0 + 0 + 1 + 3 = 5$.
Output: **5**.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **CRITICAL 64-bit Integer Overflow**:
  $n = 2 \cdot 10^5$, and $p_i \le 10^9$.
  If half the sticks are $1$ and the other half are $10^9$, the total cost is:
  $$\approx 10^5 \times 10^9 = 10^{14}$$
  This far exceeds 32-bit signed integer limits ($2.14 \times 10^9$).
  Accumulating `total_cost` in a 32-bit `int` causes silent integer overflow and incorrect negative answers. `long long` is strictly required.
- **$n = 1$**: Cost is trivially `0`.
- **All sticks already identical**: Cost is `0`.
- **Even $n$**: Choosing index $n/2$ or $n/2 - 1$ yields the exact same total cost.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if changes could only increase stick lengths (cannot shorten)?**
   - Then all sticks must be increased to at least $\max(p_i)$. The optimal length is $X = \max(p_i)$, and cost is $\sum (\max(p_i) - p_i) = n \max(p_i) - \sum p_i$.
2. **What if the cost to change stick $i$ is $w_i \cdot |p_i - X|$ (Weighted Median)?**
   - Sort sticks by $p_i$, then find the **weighted median**: the smallest $p_k$ such that the prefix weight $\sum_{i=1}^k w_i \ge \frac{1}{2} \sum_{i=1}^n w_i$.
3. **What if the cost was quadratic $(p_i - X)^2$?**
   - The optimal $X$ is the **mean** (average) $\mu = \frac{1}{n} \sum p_i$. Test $\lfloor \mu \rfloor$ and $\lceil \mu \rceil$ to pick the best integer.
4. **How would you answer this dynamically with stick insertions/deletions?**
   - Maintain two balanced heaps (`max_heap` for lower half, `min_heap` for upper half) to track the running median in $\mathcal{O}(\log n)$, as in LeetCode 295.
5. **How does `std::nth_element` achieve linear average time?**
   - It implements Hoare's QuickSelect algorithm: partitioning around a pivot and recursing only into the single half containing index $n/2$, summing the geometric series $n + n/2 + n/4 + \dots = \mathcal{O}(n)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Math, Median, QuickSelect, Sorting, Greedy.
- **Time Complexity**: $\mathcal{O}(n)$ using `nth_element`, or $\mathcal{O}(n \log n)$ via `std::sort`.
- **Space Complexity**: $\mathcal{O}(n)$ storage for elements.

### Related CSES Tasks
- [CSES 1643 - Maximum Subarray Sum](https://cses.fi/problemset/task/1643): Linear scan optimization.
- [CSES 2183 - Missing Coin Sum](https://cses.fi/problemset/task/2183): Greedy prefix reachability on sorted values.
- [CSES 1084 - Apartments](https://cses.fi/problemset/task/1084): Greedy matching on sorted inputs.
