# Array Division

- **Category**: Sorting and Searching
- **CSES Task ID**: `1085`
- **CSES Problem Link**: [Array Division](https://cses.fi/problemset/task/1085)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an array of $n$ positive integers $x_1, x_2, \dots, x_n$ and an integer $k$. You must partition the array into $k$ non-empty contiguous subarrays such that the **maximum sum among all $k$ subarrays is minimized**.

### Input Format
- The first line contains two integers $n$ and $k$.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$.

### Output Format
- Print one integer: the minimum possible maximum subarray sum.

### Numerical Constraints
- $1 \le k \le n \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$

Because $n = 2 \cdot 10^5$ and $x_i \le 10^9$:
- The sum of all elements can reach $n \times 10^9 = 2 \cdot 10^{14}$, which overflows 32-bit signed integers and requires `long long`.
- Dynamic programming over partitions would take $\mathcal{O}(n^2 k)$ or $\mathcal{O}(n k)$ time, which is far too slow. We need an $\mathcal{O}(n \log(\sum x_i))$ algorithm.

---

## 2. Intuition & Pattern Recognition

This is the quintessential **Binary Search on the Answer** paradigm:
- Notice the **monotonicity of feasibility**:
  If it is possible to partition the array into at most $k$ subarrays such that no subarray sum exceeds a cap $S$, then it is also possible for any cap $S' > S$ (having a looser threshold never makes partitioning harder).
- The search space for the answer $S$ is well-bounded:
  - Lower bound: $L = \max_{1 \le i \le n} x_i$ (since every element must be in some subarray, no subarray sum can be smaller than the largest individual element).
  - Upper bound: $R = \sum_{i=1}^n x_i \le 2 \cdot 10^{14}$ (the entire array placed into a single subarray).
- **Greedy Verification in $\mathcal{O}(n)$**:
  Given a candidate cap $S$, can we partition the array into $\le k$ subarrays?
  Greedily pack elements into the current subarray as long as the sum does not exceed $S$. When the next element would breach $S$, close the current subarray and start a new one. Since packing as much as possible into earlier subarrays leaves the minimum possible remaining work for future subarrays, this greedy check minimizes the number of subarrays needed for cap $S$.

---

## 3. Approach 1 — Naive / Recursive Search

Try all $\binom{n-1}{k-1}$ ways to choose $k-1$ partition points in the array.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

long long best_max_sum = 1e18;

void partition_brute(const vector<long long>& a, int idx, int k_rem, long long cur_sum, long long cur_max) {
    int n = a.size();
    if (idx == n) {
        if (k_rem == 0) {
            best_max_sum = min(best_max_sum, max(cur_max, cur_sum));
        }
        return;
    }

    // Choice 1: Continue extending the current subarray
    partition_brute(a, idx + 1, k_rem, cur_sum + a[idx], cur_max);

    // Choice 2: End current subarray and start a new one (if subarrays remaining)
    if (k_rem > 0 && cur_sum > 0) {
        partition_brute(a, idx + 1, k_rem - 1, a[idx], max(cur_max, cur_sum));
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, k;
    if (!(cin >> n >> k)) return 0;

    vector<long long> a(n);
    for (int i = 0; i < n; ++i) cin >> a[i];

    partition_brute(a, 0, k - 1, 0, 0);
    cout << best_max_sum << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}\left(\binom{n-1}{k-1}\right)$, exponential.
- **Space Complexity**: $\mathcal{O}(n)$ recursion depth.
- **CSES Verdict**: TLE for $n > 20$.

---

## 4. Approach 2 — Intermediate / Dynamic Programming

Let $dp[i][j]$ be the minimum maximum subarray sum when partitioning the prefix $a[1 \dots i]$ into $j$ subarrays:
$$dp[i][j] = \min_{0 \le m < i} \max(dp[m][j-1], \sum_{r=m+1}^i a[r])$$

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2 k)$ naively, or $\mathcal{O}(n k \log n)$ with binary search on the optimal transition $m$.
- **Space Complexity**: $\mathcal{O}(n k)$.
- **Verdict**: Even with state-of-the-art D&C / Knuth optimization, $\mathcal{O}(n k) \approx 2 \cdot 10^5 \times 2 \cdot 10^5 = 4 \cdot 10^{10}$ operations, which severely exceeds the 1.00s time limit.

---

## 5. Approach 3 — Optimal CSES Solution (Binary Search on Answer)

Perform binary search for the minimal valid cap $S \in [\max(x_i), \sum x_i]$:
1. Midpoint $M = L + (R - L) / 2$.
2. Check feasibility: traverse the array. Add elements to `current_sum`. If `current_sum + x_i > M`, increment `subarrays_needed` and reset `current_sum = x_i`.
3. If `subarrays_needed <= k`, then $M$ is feasible $\implies$ record $M$ as a candidate and search the left half ($R = M - 1$).
4. Otherwise, $M$ is too small $\implies$ search the right half ($L = M + 1$).

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <numeric>
#include <algorithm>

using namespace std;

// Feasibility check: can we partition 'a' into <= k subarrays,
// such that every subarray sum is <= max_cap?
bool is_feasible(const vector<long long>& a, int k, long long max_cap) {
    int subarrays_count = 1;
    long long current_sum = 0;

    for (long long val : a) {
        if (current_sum + val <= max_cap) {
            current_sum += val;
        } else {
            // Start a new subarray
            subarrays_count++;
            current_sum = val;
        }
    }

    return subarrays_count <= k;
}

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, k;
    if (!(cin >> n >> k)) return 0;

    vector<long long> a(n);
    long long low = 0;
    long long high = 0;

    for (int i = 0; i < n; ++i) {
        cin >> a[i];
        low = max(low, a[i]); // Lower bound: at least the maximum single element
        high += a[i];         // Upper bound: sum of all elements
    }

    long long optimal_max_sum = high;

    // Binary search on the answer
    while (low <= high) {
        long long mid = low + (high - low) / 2;

        if (is_feasible(a, k, mid)) {
            optimal_max_sum = mid; // Feasible, attempt a tighter cap
            high = mid - 1;
        } else {
            low = mid + 1;         // Infeasible, cap must be larger
        }
    }

    cout << optimal_max_sum << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log(\sum x_i))$. The search interval is $[1, 2 \cdot 10^{14}]$, so the binary search executes $\lceil \log_2(2 \cdot 10^{14}) \rceil \approx 48$ iterations. Each iteration performs a single linear scan of $n$ elements in $\mathcal{O}(n)$ time. Total operations: $\approx 48 \times 2 \cdot 10^5 \approx 9.6 \cdot 10^6$, running in $< 0.05\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ to store the array (or $\mathcal{O}(1)$ auxiliary space).
- **Optimality Guarantee**: With an exponentially large monotonic search space, binary search achieves the theoretical minimum number of predicate evaluations.

---

## 6. Correctness Proof

### Monotonicity Property
Let $P(S)$ be the boolean predicate: "Is it possible to partition the array into at most $k$ subarrays such that no subarray sum exceeds $S$?"
- If $P(S) = \text{true}$, then for any $S' > S$, any valid partition for $S$ trivially satisfies the looser bound $S'$, so $P(S') = \text{true}$.
- If $P(S) = \text{false}$, then for any $S' < S$, if $S'$ were feasible, $S$ would also be feasible (a contradiction). Hence $P(S') = \text{false}$.
Thus, $P(S)$ is monotonic, guaranteeing that binary search finds the unique minimum $S$ where $P(S)$ turns true.

### Greedy Choice Property
For a fixed target cap $S \ge \max(x_i)$, the greedy strategy puts as many elements into each subarray as possible before starting a new one.
- *Exchange Argument*: Suppose an optimal partition places boundary earlier than the greedy choice, say ending at index $p$ instead of greedy choice $q > p$. Moving the boundary from $p$ to $q$ only reduces the elements that subsequent subarrays must cover, without violating the bound $S$ on the current subarray (since $\sum_{i=1}^q x_i \le S$).
- Inductively, the greedy partition uses the minimum possible number of subarrays for any given cap $S$.
- Therefore, if greedy partitioning uses $\le k$ subarrays, $P(S) = \text{true}$; otherwise, no partition into $\le k$ subarrays exists and $P(S) = \text{false}$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
2 4 7 3 5
```
$n = 5, k = 3$. Elements: `[2, 4, 7, 3, 5]`.
- $L = \max(a_i) = 7$
- $R = \sum a_i = 21$

| Iteration | $L$ | $R$ | $M = (L+R)/2$ | Greedy Partition with Cap $M$ | Subarrays Needed | $\le 3$? | Action |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | 7 | 21 | 14 | `[2, 4, 7]` (sum 13), `[3, 5]` (sum 8) | 2 | **Yes** ($\le 3$) | Ans $= 14$, $R = 13$ |
| **2** | 7 | 13 | 10 | `[2, 4]` (sum 6), `[7, 3]` (sum 10), `[5]` (sum 5) | 3 | **Yes** ($\le 3$) | Ans $= 10$, $R = 9$ |
| **3** | 7 | 9 | 8 | `[2, 4]` (sum 6), `[7]` (sum 7), `[3, 5]` (sum 8) | 3 | **Yes** ($\le 3$) | Ans $= 8$, $R = 7$ |
| **4** | 7 | 7 | 7 | `[2, 4]` (sum 6), `[7]` (sum 7), `[3]` (sum 3), `[5]` (sum 5) | 4 | **No** ($4 > 3$) | $L = 8$ |

Terminates with $L = 8 > R = 7$.
**Final Output**: `8` (Subarrays: `[2, 4]`, `[7]`, `[3, 5]`).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$k = 1$**: Output is the sum of the entire array.
- **$k = n$**: Output is $\max(x_i)$, each element in its own subarray.
- **Large Sums**: Total array sum reaches $2 \cdot 10^{14}$. Using signed 32-bit integer for `high`, `mid`, or `current_sum` will overflow and cause infinite loops or wrong answers. Declare them as `long long`.
- **Lower Bound initialization**: `low` **must** be set to $\max_{1 \le i \le n} x_i$. If $M < \max(x_i)$, an individual element cannot fit into any subarray.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if we want to minimize the sum of squared subarray sums?**
   - Binary search fails because sums are not capped individually. Use Dynamic Programming with Convex Hull Trick / Alien's Trick (WQS binary search on the Lagrangian multiplier $\lambda$) in $\mathcal{O}(n \log(\text{Range}))$.
2. **Recover the actual partition boundaries?**
   - Run the greedy pass one final time with the optimal cap $S^*$ and output the split indices whenever adding an element would exceed $S^*$.
3. **Array Division into at most $k$ subarrays minimizing the difference between max and min subarray sum?**
   - Harder problem. Requires iterating over possible minimum sums or two-pointer sweep on bounds, checking feasibility.
4. **Online / Streaming Version?**
   - If elements arrive dynamically, offline binary search cannot re-evaluate. Competitive streaming algorithms provide $\approx (2 - \epsilon)$ approximation bounds.
5. **Tree Division instead of Array Division?**
   - Partitioning a tree of size $n$ into $k$ connected components minimizing maximum component sum: binary search on cap $S$ + post-order greedy tree DP in $\mathcal{O}(n \log(\sum x_i))$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[binary-search, greedy, sorting-and-searching, optimization]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \log(\sum x_i))$
  - Space: $\mathcal{O}(1)$ auxiliary ($\mathcal{O}(n)$ to store input)
- **Related CSES Problems**:
  - `CSES 1620` — [Factory Machines](https://cses.fi/problemset/task/1620) (Binary search on completion time).
  - `CSES 1630` — [Tasks and Deadlines](https://cses.fi/problemset/task/1630) (Greedy scheduling).
  - `CSES 1643` — [Maximum Subarray Sum](https://cses.fi/problemset/task/1643) (Kadane's algorithm).
