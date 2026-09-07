# Apple Division (CSES Task 1623 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1623 - Apple Division](https://cses.fi/problemset/task/1623)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: There are $n$ apples with known weights. Your task is to divide the apples into two groups so that the difference between the weights of the groups is minimal.
- **Constraints**: $1 \le n \le 20$, $1 \le p_i \le 10^9$.

---

## 1. Problem, Restated

Given an array of $n$ apple weights $p_1, p_2, \dots, p_n$, partition the apples into two disjoint subsets $S_1$ and $S_2$ ($S_1 \cup S_2 = \{1, \dots, n\}$, $S_1 \cap S_2 = \emptyset$) such that the absolute difference between their total weights:
$$\Delta = \left| \sum_{i \in S_1} p_i - \sum_{j \in S_2} p_j \right|$$
is minimized.

**Input**:
- First line: integer $n$ ($1 \le n \le 20$).
- Second line: $n$ space-separated integers $p_1, \dots, p_n$ ($1 \le p_i \le 10^9$).

**Output**:
- Print a single integer: the minimum achievable difference $\Delta$.

**Key Constraints**:
- $n \le 20$, which implies $2^n \le 2^{20} = 1,048,576$ possible subsets.
- Total sum $W = \sum p_i \le 20 \times 10^9 = 2 \times 10^{10}$, strictly exceeding 32-bit signed integer limits ($2^{31} - 1 \approx 2.14 \times 10^9$). Thus, 64-bit integer types (`long long`) are strictly required.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Subset Sum / Complete Search / Bitmask Enumeration / Divide and Conquer.
- **Aha! Insight**:
  - Notice the relation between subset sums: if the total weight of all apples is $W_{\text{total}} = \sum_{i=1}^n p_i$, and subset $S_1$ has weight $W_1$, then subset $S_2$ inevitably has weight $W_{\text{total}} - W_1$.
  - The difference simplifies to:
    $$\Delta = |W_1 - (W_{\text{total}} - W_1)| = |W_{\text{total}} - 2 W_1|$$
  - The problem is identical to choosing a subset $S_1$ whose weight $W_1$ is as close as possible to $W_{\text{total}} / 2$.
  - Because $n \le 20$, the entire state space of $2^{20} \approx 1.05 \times 10^6$ subsets can be exhaustively evaluated within 10–20 milliseconds in C++.
- **Signal**: When $n \le 20$ and weights are large ($10^9$), dynamic programming on weight $\mathcal{O}(n \cdot W)$ is impossible due to memory and time limits ($W \approx 2 \cdot 10^{10}$). Exponential exhaustive search $\mathcal{O}(2^n)$ is the exact right design pattern.

---

## 3. Approach 1 — Naive / Baseline (Recursive Binary Branching)

### Idea
A natural recursive depth-first search explores two choices for each apple: place it in group 1 or group 2. At index $n$, compute the absolute difference and update the global minimum.

### C++17 Code
```cpp
#include <iostream>
#include <vector>
#include <numeric>
#include <cmath>
#include <algorithm>

using namespace std;

long long best_diff = -1;

void solve(int idx, int n, const vector<long long>& p, long long sum1, long long sum2) {
    if (idx == n) {
        long long cur = abs(sum1 - sum2);
        if (best_diff == -1 || cur < best_diff) {
            best_diff = cur;
        }
        return;
    }
    // Choice 1: Add apple idx to group 1
    solve(idx + 1, n, p, sum1 + p[idx], sum2);
    // Choice 2: Add apple idx to group 2
    solve(idx + 1, n, p, sum1, sum2 + p[idx]);
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<long long> p(n);
    for (int i = 0; i < n; ++i) {
        cin >> p[i];
    }

    solve(0, n, p, 0, 0);

    cout << best_diff << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(2^n)$ recursive calls. For $n = 20$, $2^{21} - 1 \approx 2.1 \times 10^6$ function frames.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary stack space for recursion depth.
- **Bottleneck**: Recursion overhead and duplicate symmetric states (swapping group 1 and group 2 explores identical partitions twice).

---

## 4. Approach 2 — Intermediate (Symmetry Pruning via Fixating Element 0)

To eliminate half the search space, observe that the two groups are symmetric. We can arbitrarily assign the first apple $p_0$ to group 1 without loss of generality. This reduces the search space from $2^n$ to $2^{n-1} \le 2^{19} = 524,288$ evaluations.

```cpp
// Start recursion at index 1 with sum1 = p[0], sum2 = 0
solve(1, n, p, p[0], 0);
```

While this halves runtime, we can implement the search iteratively without any function-call overhead using bitmasks.

---

## 5. Approach 3 — Optimal CSES Solution (Iterative Bitmask Enumeration)

### Idea
Each subset of indices corresponds to an integer mask in the range $[0, 2^{n-1})$. By restricting the highest bit (fixing the last apple to group 2 or first apple to group 1), we inspect exactly $2^{n-1}$ states with zero redundant symmetry.
Alternatively, iterating all $2^n$ bitmasks in a simple tight loop takes $< 0.02$ seconds.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <numeric>
#include <cmath>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<long long> p(n);
    long long total_sum = 0;
    for (int i = 0; i < n; ++i) {
        cin >> p[i];
        total_sum += p[i];
    }

    long long min_diff = total_sum;
    int total_masks = 1 << n;

    // Iterate through all 2^n subsets
    for (int mask = 0; mask < total_masks; ++mask) {
        long long current_subset_sum = 0;
        for (int i = 0; i < n; ++i) {
            if ((mask >> i) & 1) {
                current_subset_sum += p[i];
            }
        }
        long long diff = abs(total_sum - 2 * current_subset_sum);
        if (diff < min_diff) {
            min_diff = diff;
        }
    }

    cout << min_diff << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \cdot 2^n)$. For $n = 20$, $20 \times 1,048,576 \approx 2.1 \times 10^7$ bit operations, executing in ~0.04s, well below the 1.00s limit.
- **Space Complexity**: $\mathcal{O}(n)$ to store input weights. $\mathcal{O}(1)$ auxiliary space.

---

## 6. Correctness Proof

Let $U = \{p_0, p_1, \dots, p_{n-1}\}$ be the multiset of apple weights.
1. **Bijection to Subsets**: Any valid 2-partition $(S_1, S_2)$ with $S_2 = U \setminus S_1$ is uniquely identified by the subset $S_1 \subseteq U$.
2. **Exhaustive Coverage**: The integers $\{0, 1, \dots, 2^n - 1\}$ represent all $2^n$ distinct characteristic vectors over $U$. By testing all $2^n$ bitmasks, every possible partition $(S_1, S_2)$ is evaluated.
3. **Optimality**: Because the minimum difference is chosen over all valid subsets in the finite domain $\mathcal{P}(U)$, the returned minimum is globally optimal.

---

## 7. Dry Run & Visual State Trace

Input: $n = 5$, weights = `[3, 2, 7, 4, 1]`, `total_sum` = 17.

| Mask (Binary) | Included Apples | Subset Sum $W_1$ | Difference $|17 - 2 W_1|$ | Current Min Diff |
| :--- | :--- | :--- | :--- | :--- |
| `00000` | None | 0 | $|17 - 0| = 17$ | 17 |
| `00001` | $p_0 = 3$ | 3 | $|17 - 6| = 11$ | 11 |
| `00011` | $p_0, p_1 = 3 + 2 = 5$ | 5 | $|17 - 10| = 7$ | 7 |
| `01011` | $p_0, p_1, p_3 = 3 + 2 + 4 = 9$ | 9 | $|17 - 18| = 1$ | 1 |
| `10100` | $p_2, p_4 = 7 + 1 = 8$ | 8 | $|17 - 16| = 1$ | 1 |

Minimum difference found is **1**.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1$**: With a single apple, one group has $p_0$ and the other group has $0$. Difference is $p_0$. Formula $|p_0 - 2(0)| = p_0$ correctly handles this.
- **32-Bit Overflow**: Total sum can reach $20 \times 10^9 = 2 \times 10^{10} > 2^{31} - 1$. Accumulating in standard 32-bit `int` wraps around into negative numbers, corrupting `abs()` comparisons. `long long` is mandatory for weights and sums.
- **Shift Overflow**: Using `1 << 20` is safe in standard 32-bit `int` (since $2^{20} < 2^{31} - 1$), but for $n \ge 31$ one must use `1LL << n`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if $n$ is up to 40?**
   - $2^{40} \approx 1.1 \times 10^{12}$ is too large for complete search. We apply **Meet-in-the-Middle**: split the 40 elements into two halves of 20, compute all $2^{20}$ subset sums for each half, sort one half, and use binary search (`std::lower_bound`) to find pairs nearest to $W_{\text{total}} / 2$ in $\mathcal{O}(n \cdot 2^{n/2})$.
2. **What if $n$ is up to 500 but weights $p_i \le 100$?**
   - Total sum $W \le 50,000$. We can use **0/1 Knapsack Dynamic Programming** with `std::bitset<50001>` in $\mathcal{O}(n \cdot W / 64)$, easily running in ~5ms.
3. **How to optimize bitmask traversal to $\mathcal{O}(2^n)$ without the inner loop?**
   - By using **Gray Code order** ($g(i) = i \oplus (i \gg 1)$), only a single bit changes between successive states. The subset sum can be updated in $\mathcal{O}(1)$ time per mask.
4. **How do we reconstruct the actual partition of apples?**
   - Record the `best_mask` that produced `min_diff`. For each bit $i \in [0, n-1]$, if `(best_mask >> i) & 1`, assign apple $i$ to group 1; otherwise to group 2.
5. **Can this problem be solved in polynomial time?**
   - No, Partition is a known NP-complete decision problem (Karp's 21 NP-complete problems). Finding the minimum difference is NP-hard in general.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Complete Search, Bitmask, Recursion, Meet in the Middle, Knapsack.
- **Time Complexity**: $\mathcal{O}(n \cdot 2^n)$ worst-case; optimal for $n \le 20$.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space.

### Related CSES Tasks
- [CSES 1622 - Creating Strings](https://cses.fi/problemset/task/1622): Permutation generation via exhaustive search.
- [CSES 1628 - Meet in the Middle](https://cses.fi/problemset/task/1628): Extended subset sum with $n \le 40$.
- [CSES 1093 - Two Sets II](https://cses.fi/problemset/task/1093): Counting equal-sum partitions using dynamic programming.
