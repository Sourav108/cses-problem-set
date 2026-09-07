# Sum of Three Values (CSES Task 1641 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1641 - Sum of Three Values](https://cses.fi/problemset/task/1641)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: You are given an array of $n$ integers and a target sum $x$. Find three distinct positions whose values sum to $x$. If multiple solutions exist, print any. If no solution exists, print `IMPOSSIBLE`.
- **Constraints**: $1 \le n \le 5000$, $1 \le x, a_i \le 10^9$.

---

## 1. Problem, Restated

Given an array $a = [a_1, a_2, \dots, a_n]$ and a target sum $x$:
Find three distinct 1-based indices $i, j, k$ ($1 \le i < j < k \le n$) such that:
$$a_i + a_j + a_k = x$$
If a valid triplet exists, print the three indices. Otherwise, print `IMPOSSIBLE`.

**Input**:
- First line: two integers $n$ and $x$ ($1 \le n \le 5000$, $1 \le x \le 10^9$).
- Second line: $n$ space-separated integers $a_1, \dots, a_n$ ($1 \le a_i \le 10^9$).

**Output**:
- Print three distinct 1-based indices, or `IMPOSSIBLE`.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: 3-Sum / Outer Pivot Loop + Two Pointers / Index Preservation.
- **Aha! Insight**:
  - A brute-force check over all triplets takes $\mathcal{O}(n^3) \approx \frac{5000^3}{6} \approx 2 \cdot 10^{10}$ operations $\implies$ TLE.
  - Notice that if we fix the first element $a_i$, the problem reduces to finding two elements in the remaining suffix whose sum equals:
    $$\text{target} = x - a_i$$
  - This is the standard **2-Sum problem** on the remaining subarray!
  - If we sort the array of pairs `(value, original_index)` at the start:
    - For each fixed index $i \in [0, n-3]$:
    - Run the classic **Two Pointers** algorithm with $L = i + 1$ and $R = n - 1$.
    - While $L < R$:
      - $\text{cur\_sum} = a[L].\text{val} + a[R].\text{val}$
      - If $\text{cur\_sum} == \text{target}$: triplet found! Print `a[i].id`, `a[L].id`, `a[R].id` and terminate immediately.
      - If $\text{cur\_sum} < \text{target}$: increment $L++$.
      - If $\text{cur\_sum} > \text{target}$: decrement $R--$.
  - The outer loop runs $n$ times, and the two-pointer scan takes $\mathcal{O}(n)$ time.
  - Total time is $\mathcal{O}(n^2)$.
  - For $n = 5000$, $\frac{n^2}{2} \approx 1.25 \times 10^7$ operations, executing in $\approx 0.05$ seconds in C++!
- **Signal**: "Find 3 elements summing to $X$" with $N \le 5000$ is the classic Sort + Two Pointers 3-Sum algorithm.

---

## 3. Approach 1 — Naive / Baseline (Cubic Nested Loops)

Check all $\binom{n}{3}$ triplets.
For $n = 5000$, $\approx 2 \cdot 10^{10}$ operations $\implies$ massive TLE.

---

## 4. Approach 2 — Intermediate (Hash Map for Complement)

Iterate over all pairs $(i, j)$ in $\mathcal{O}(n^2)$, querying a hash map for $x - a_i - a_j$.
While $\mathcal{O}(n^2)$ average, hash tables suffer from cache misses and potential hash collision attacks. Sorting + Two Pointers (Approach 3) is cache-friendly, deterministic, and requires $\mathcal{O}(1)$ auxiliary memory.

---

## 5. Approach 3 — Optimal CSES Solution (Sorted Array + Two Pointers in $\mathcal{O}(n^2)$)

### Idea
1. Store elements as `vector<pair<int, int>> a` with `(value, 1-based_index)`.
2. Sort `a` by value in ascending order.
3. Outer loop: $i$ from $0$ to $n-3$.
   - If $a[i].\text{first} \ge x$, break (since all elements are positive, further elements are even larger).
   - Set target `rem = x - a[i].first`.
   - Set $L = i + 1, R = n - 1$.
   - While $L < R$:
     - `sum = a[L].first + a[R].first`
     - If `sum == rem`: print indices and exit.
     - Else if `sum < rem`: `L++`.
     - Else: `R--`.
4. If loop completes, print `IMPOSSIBLE`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Element {
    long long val;
    int id;
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    long long x;
    if (!(cin >> n >> x)) return 0;

    vector<Element> a(n);
    for (int i = 0; i < n; ++i) {
        cin >> a[i].val;
        a[i].id = i + 1; // 1-based index
    }

    sort(a.begin(), a.end(), [](const Element& u, const Element& v) {
        return u.val < v.val;
    });

    for (int i = 0; i < n - 2; ++i) {
        long long target = x - a[i].val;
        if (target <= 0) break; // All remaining elements are positive

        int l = i + 1;
        int r = n - 1;

        while (l < r) {
            long long cur_sum = a[l].val + a[r].val;
            if (cur_sum == target) {
                cout << a[i].id << ' ' << a[l].id << ' ' << a[r].id << '\n';
                return 0;
            } else if (cur_sum < target) {
                l++;
            } else {
                r--;
            }
        }
    }

    cout << "IMPOSSIBLE\n";
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$ to sort the array. The outer loop runs at most $n - 2$ times. Each inner two-pointer search takes $\mathcal{O}(n)$ steps. Total operations $\approx \frac{n^2}{2} \le 1.25 \times 10^7$, executing in $\approx 0.05$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ storage for elements with indices ($5000 \times 16$ bytes $\approx 80$ KB).

---

## 6. Correctness Proof

1. **Exhaustive Partition of Triplets**:
   Any valid triplet of distinct indices can be represented in the sorted array by $(i, L^*, R^*)$ with $i < L^* < R^*$.
   The outer loop iterates through all possible smallest indices $i \in [0, n-3]$.
2. **Optimality of Two-Pointer Subroutine**:
   For a fixed $i$, we seek a pair $(L^*, R^*)$ in $[i+1, n-1]$ with $a[L^*].\text{val} + a[R^*].\text{val} = x - a[i].\text{val}$.
   By the Two-Pointer invariant proved in **Sum of Two Values (CSES 1640)**:
   - Initial state $L = i + 1 \le L^*$ and $R = n - 1 \ge R^*$.
   - When the sum is too small, incrementing $L$ is safe because $R$ is already at the largest available element.
   - When the sum is too large, decrementing $R$ is safe because $L$ is at the smallest available element.
   - Therefore, the window $[L, R]$ always contains $(L^*, R^*)$ until they converge.
3. If any valid triplet exists, it will be discovered. If all $i$ finish without a match, no valid triplet exists in the array. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 4, x = 8$, array = `[2, 7, 5, 1]`.
Elements with 1-based IDs: `[(2, 1), (7, 2), (5, 3), (1, 4)]`.

Sorted by value:
- `a[0] = {val: 1, id: 4}`
- `a[1] = {val: 2, id: 1}`
- `a[2] = {val: 5, id: 3}`
- `a[3] = {val: 7, id: 2}`

- **Outer loop $i = 0$** ($a[0] = 1$, id 4):
  `target = 8 - 1 = 7`.
  $L = 1 (val 2), R = 3 (val 7)$.
  - Check $2 + 7 = 9 > 7 \implies R \to 2$.
  - Check $L = 1 (val 2), R = 2 (val 5)$:
    $2 + 5 = 7 == 7$! **Match found!**
  - Triplet: `a[0].id = 4`, `a[1].id = 1`, `a[2].id = 3`.
  - Output: `4 1 3` (or `1 3 4`).

Any permutation of the 3 IDs is valid. Matches the example!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n < 3$**: Loop condition $i < n - 2$ fails immediately, correctly outputs `IMPOSSIBLE`.
- **Target $x$ smaller than sum of three smallest elements**: Handled correctly; loop finishes and prints `IMPOSSIBLE`.
- **Target $x$ exceeds maximum possible sum ($x > 3 \cdot 10^9$)**: Handled correctly without overflow using `long long`.
- **Duplicate values**: Handled correctly because IDs preserve original positions.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How to extend this to Sum of Four Values (CSES 1642)?**
   - We cannot use an $\mathcal{O}(n^3)$ loop because $n = 1000 \implies n^3 = 10^9$ TLE. Instead, store all $\binom{n}{2}$ pairwise sums in a hash table or sorted array to solve in $\mathcal{O}(n^2)$ time.
2. **What if we needed to count the total number of distinct triplets?**
   - Skip duplicate values in the outer and inner loops, accumulating combination counts when $a[L] == a[R]$.
3. **What if the target sum had a tolerance $|a_i + a_j + a_k - x| \le \epsilon$ (3-Sum Closest)?**
   - Maintain `best_diff = min(best_diff, abs(sum - x))` in the two-pointer loop.
4. **Why is $N = 5000$ the standard competitive programming bound for 3-Sum?**
   - Because $5000^2 / 2 \approx 1.25 \times 10^7$ operations, perfectly calibrated to run in $\approx 0.05$s under a 1.00s time limit.
5. **Can 3-Sum be solved in strictly sub-quadratic time $\mathcal{O}(n^{2 - \epsilon})$?**
   - The **3-Sum Conjecture** states that no algorithm can solve 3-Sum in $\mathcal{O}(n^{2 - \epsilon})$ time for any $\epsilon > 0$. It is a foundational hardness assumption in fine-grained complexity theory.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Two Pointers, Sorting, 3-Sum, Binary Search.
- **Time Complexity**: $\mathcal{O}(n^2)$ optimal time.
- **Space Complexity**: $\mathcal{O}(n)$ storage for elements.

### Related CSES Tasks
- [CSES 1640 - Sum of Two Values](https://cses.fi/problemset/task/1640): 2-Sum two pointers.
- [CSES 1642 - Sum of Four Values](https://cses.fi/problemset/task/1642): 4-Sum via pair decomposition.
- [CSES 1645 - Nearest Smaller Values](https://cses.fi/problemset/task/1645): Monotonic stack.
