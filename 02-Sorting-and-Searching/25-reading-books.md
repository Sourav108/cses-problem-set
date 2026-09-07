# Reading Books (CSES Task 1631 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1631 - Reading Books](https://cses.fi/problemset/task/1631)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: There are $n$ books. Two people (Kotivalo and Justiina) must both read all $n$ books. Each book takes $t_i$ time to read. Both people read each book completely, and they cannot read the same book at the same time. Find the minimum total time required.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le t_i \le 10^9$.

---

## 1. Problem, Restated

Given $n$ books with reading durations $t_1, t_2, \dots, t_n$:
Two readers must each read every book.
Constraints:
1. Neither person can read more than one book simultaneously.
2. A book cannot be read by both people simultaneously (exclusive access).

Find the minimum total wall-clock time required for both readers to finish reading all $n$ books.

**Input**:
- First line: integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Second line: $n$ space-separated integers $t_1, \dots, t_n$.

**Output**:
- Print a single integer: the minimum total time.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Bottleneck Analysis / Two-Agent Scheduling / Invariant Lower Bounds / Open-Shop Scheduling.
- **Aha! Insight**:
  - Let $S = \sum_{i=1}^n t_i$ be the total reading time of all books.
  - Since there are two readers, each reader must read total duration $S$.
  - Because two people can work concurrently, the theoretical minimum time (assuming zero idle waiting) is:
    $$\text{Time} \ge S$$
  - However, consider the single longest book: $t_{\max} = \max_{i=1}^n t_i$.
    - Reader 1 must read it (taking $t_{\max}$).
    - Reader 2 must also read it (taking $t_{\max}$).
    - Since both cannot read it at the same time, their readings of this book must be **strictly disjoint in time**!
    - Therefore, the time can never be less than $2 \cdot t_{\max}$:
      $$\text{Time} \ge 2 \cdot t_{\max}$$
  - Combining both physical bounds gives the universal lower bound:
    $$\text{Time} \ge \max(S, 2 \cdot t_{\max})$$
  - **Can this lower bound always be achieved?**
    - **Case 1 ($t_{\max} > S - t_{\max}$)**:
      The longest book is longer than all other books combined.
      While Reader 1 reads the longest book (duration $t_{\max}$), Reader 2 reads all other books (taking $S - t_{\max} < t_{\max}$, then waits).
      Then Reader 2 reads the longest book (duration $t_{\max}$), while Reader 1 reads all other books.
      The schedule completes in exactly $2 \cdot t_{\max}$.
    - **Case 2 ($t_{\max} \le S - t_{\max}$)**:
      No single book takes more than half the total work.
      Reader 1 reads books in ascending order of index ($1 \dots n$), and Reader 2 reads books in descending order ($n \dots 1$).
      Because $t_{\max} \le S / 2$, both readers can be scheduled with **zero idle time**!
      The total time is exactly $S$.
  - Therefore, the exact answer is closed-form:
    $$\text{Answer} = \max(S, 2 \cdot t_{\max})$$
- **Signal**: Dual-worker exclusive job processing with sum $S$ and maximum $M$ achieves the optimal bound $\max(S, 2M)$ in $\mathcal{O}(n)$ time.

---

## 3. Approach 1 — Naive / Baseline (Simulated Queue Scheduling)

Simulating time minute-by-minute or event-by-event with dynamic job queues.
Because durations reach $t_i \le 10^9$, minute-by-minute simulation requires $10^{14}$ steps $\implies$ TLE.

---

## 4. Approach 2 — Intermediate (Sorting the Array)

Read the array into a vector, sort it using `std::sort`, extract $t_{\max} = t[n-1]$, and compute $\sum t_i$.
While $\mathcal{O}(n \log n)$ and runs in $\approx 0.05$s, sorting is unnecessary because $\max$ and $\sum$ can be tracked in a single linear pass.

---

## 5. Approach 3 — Optimal CSES Solution (Single-Pass $\mathcal{O}(n)$ Math Closed Form)

### Idea
Maintain `sum = 0LL` and `max_val = 0LL`.
Iterate through the input:
- `sum += x`
- `max_val = max(max_val, x)`
Output `max(sum, 2 * max_val)`.

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

    long long total_sum = 0;
    long long max_val = 0;

    for (int i = 0; i < n; ++i) {
        long long t;
        cin >> t;
        total_sum += t;
        max_val = max(max_val, t);
    }

    long long ans = max(total_sum, 2 * max_val);
    cout << ans << '\n';

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n)$ single linear streaming pass. For $n = 2 \cdot 10^5$, total operations $\approx 2 \cdot 10^5$, executing in $\approx 0.02$ seconds.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary space (processes inputs as a stream without storing an array).

---

## 6. Correctness Proof

1. **Lower Bound Proof**:
   - Total workload: Both readers must read all books, requiring a total CPU time of $2 \sum_{i=1}^n t_i = 2S$. With 2 readers, the maximum concurrent processing rate is 2. By work conservation:
     $$T \ge \frac{2S}{2} = S$$
   - Bottleneck book: For book $m = \text{argmax}_i t_i$, Reader 1 requires $t_{\max}$ and Reader 2 requires $t_{\max}$. Because the book cannot be read concurrently:
     $$T \ge t_{\max} + t_{\max} = 2 t_{\max}$$
   - Thus, $T \ge \max(S, 2 t_{\max})$ is an unyielding theoretical lower bound.
2. **Constructive Feasibility Proof**:
   - If $2 t_{\max} > S$:
     Let the longest book be $B$. The sum of all other books is $S - t_{\max} < t_{\max}$.
     Schedule Reader 1 on $B$ for $[0, t_{\max}]$ and on all other books for $[t_{\max}, 2 t_{\max}]$.
     Schedule Reader 2 on all other books for $[0, S - t_{\max}]$ (idle until $t_{\max}$), and on $B$ for $[t_{\max}, 2 t_{\max}]$.
     Both readers read all books without overlap, completing in $2 t_{\max}$.
   - If $2 t_{\max} \le S$:
     By the Gonzalez-Sahni theorem for 2-machine open shop scheduling (1976), whenever no single job's machine requirement exceeds the total makespan on any machine, an open shop schedule with zero idle time and makespan $\max(S, \max_i(a_i + b_i)) = S$ is guaranteed to exist.
3. Therefore, the lower bound $\max(S, 2 t_{\max})$ is always achievable. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 3$, books: `[2, 8, 3]`.

Calculations:
- `total_sum = 2 + 8 + 3 = 13`
- `max_val = 8`
- `2 * max_val = 16`
- `ans = max(13, 16) = 16`

Visualization of optimal schedule (Duration = 16):
- Timeline:
  - Time $[0, 8]$:
    - Reader 1 reads book 2 (length 8).
    - Reader 2 reads book 1 (length 2), then book 3 (length 3), finishes other books at time 5, rests until 8.
  - Time $[8, 16]$:
    - Reader 2 reads book 2 (length 8).
    - Reader 1 reads book 1 (length 2), then book 3 (length 3).

Both readers finish all books at time 16.
Output: **16**.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **CRITICAL: 64-bit Integer Overflow**:
  $n = 2 \cdot 10^5$, $t_i \le 10^9$.
  `total_sum` can reach $2 \cdot 10^5 \times 10^9 = 2 \cdot 10^{14}$.
  $2 \times t_{\max}$ can reach $2 \cdot 10^9$.
  Using 32-bit `int` wraps around into negative numbers. `long long` is strictly required.
- **$n = 1$**: Single book of length $t_1$.
  `total_sum = t_1`, `max_val = t_1`.
  `max(t_1, 2 * t_1) = 2 * t_1`. Both readers must read it sequentially, taking $2 t_1$. Handled correctly.
- **All books of equal size**: `2 * max_val <= total_sum` for $n \ge 2$, returning `total_sum`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if there are $m > 2$ readers?**
   - The problem generalizes to open-shop scheduling on $m$ machines, which is NP-hard for $m \ge 3$!
2. **What if books have precedence constraints (DAG dependencies)?**
   - Generalizes to job shop scheduling with DAG precedence, solvable via dynamic programming or branch-and-bound.
3. **How would you reconstruct the exact reading schedule timestamps for both readers?**
   - For Case 1, assign the big book to Reader 1 then Reader 2. For Case 2, schedule Reader 1 in forward order and Reader 2 in reverse order, wrapping around the circular timeline of length $S$.
4. **Why does sorting by duration not change the answer?**
   - The formula $\max(S, 2 t_{\max})$ depends solely on the sum and the maximum value, which are symmetric functions invariant under any permutation.
5. **How does this relate to the Two-Machine Open Shop problem?**
   - CSES 1631 is a symmetric instance of $O2 || C_{\max}$, which Gonzalez and Sahni showed is solvable in $\mathcal{O}(n)$ linear time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Math, Greedy, Invariants, Open Shop Scheduling, Bottleneck Analysis.
- **Time Complexity**: $\mathcal{O}(n)$ optimal single-pass time.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary space.

### Related CSES Tasks
- [CSES 1630 - Tasks and Deadlines](https://cses.fi/problemset/task/1630): Single-machine reward maximization.
- [CSES 1620 - Factory Machines](https://cses.fi/problemset/task/1620): Parallel machine workload binary search.
- [CSES 1090 - Ferris Wheel](https://cses.fi/problemset/task/1090): Greedy 2-person pairing.
