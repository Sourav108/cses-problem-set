# Tasks and Deadlines (CSES Task 1630 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1630 - Tasks and Deadlines](https://cses.fi/problemset/task/1630)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: You have to process $n$ tasks. Each task has a duration $a_i$ and deadline $d_i$. You process tasks sequentially starting at time 0. The reward for a task is $d_i - f_i$, where $f_i$ is its finishing time. Maximize the total reward across all tasks.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le a_i, d_i \le 10^6$.

---

## 1. Problem, Restated

Given $n$ jobs, where each job $i$ requires processing time $a_i$ and has deadline $d_i$:
Choose a permutation $\pi$ of the jobs to execute them one after another on a single machine starting at $t = 0$.
The completion time of the $k$-th job in the schedule is:
$$f_{\pi_k} = \sum_{j=1}^k a_{\pi_j}$$
The reward earned from job $i$ is $d_i - f_i$ (which may be negative if completed past the deadline).
Find the maximum possible total reward:
$$\text{Reward}(\pi) = \sum_{i=1}^n (d_i - f_i)$$

**Input**:
- First line: integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Next $n$ lines: two integers $a_i$ (duration) and $d_i$ (deadline).

**Output**:
- Print a single integer: the maximum achievable total reward.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Greedy Scheduling / Shortest Processing Time (SPT) / Rearrangement Inequality / Completion Time Minimization.
- **Aha! Insight**:
  - Rewrite the objective function:
    $$\sum_{i=1}^n (d_i - f_i) = \sum_{i=1}^n d_i - \sum_{i=1}^n f_i$$
  - Notice something extraordinary:
    $\sum_{i=1}^n d_i$ is **completely independent** of the execution order! It is a fixed constant determined solely by the input.
  - Therefore, maximizing the total reward is mathematically identical to **minimizing the sum of completion times $\sum_{i=1}^n f_i$**!
  - What is $\sum_{i=1}^n f_i$ for a permutation $(a_1, a_2, \dots, a_n)$?
    - Job 1 finishes at $a_1$.
    - Job 2 finishes at $a_1 + a_2$.
    - Job 3 finishes at $a_1 + a_2 + a_3$.
    - ...
    - Job $n$ finishes at $a_1 + a_2 + \dots + a_n$.
  - Summing them up:
    $$\sum_{i=1}^n f_i = n \cdot a_1 + (n - 1) \cdot a_2 + (n - 2) \cdot a_3 + \dots + 1 \cdot a_n$$
  - By the **Rearrangement Inequality**, to minimize the dot product between $[n, n-1, \dots, 1]$ and $[a_1, a_2, \dots, a_n]$, the durations must be sorted in **strictly non-decreasing order**:
    $$a_1 \le a_2 \le \dots \le a_n$$
  - The deadlines $d_i$ do **NOT** affect the optimal ordering at all! We simply sort all tasks by duration $a_i$ ascending (Shortest Processing Time first).
- **Signal**: When an objective simplifies to $\text{constant} - \sum f_i$, the problem reduces unconditionally to Shortest Processing Time (SPT) sorting.

---

## 3. Approach 1 — Naive / Baseline (Backtracking Permutations)

Generate all $n!$ job schedules and evaluate total rewards.
For $n = 2 \cdot 10^5$, $n! \implies$ TLE.

---

## 4. Approach 2 — Intermediate (Sorting by Deadlines First)

Sorting by deadlines $d_i$ (Earliest Due Date).
While Earliest Due Date minimizes maximum lateness $\max(f_i - d_i)$, it does **not** minimize the *sum* of completion times $\sum f_i$.
*Counterexample*: Duration 10, deadline 1 vs Duration 1, deadline 10. Scheduling the first task finishes at 10 and 11, sum = 21. Scheduling duration 1 first finishes at 1 and 11, sum = 12.

---

## 5. Approach 3 — Optimal CSES Solution (Shortest Processing Time First)

### Idea
1. Store tasks as pairs `(duration, deadline)`.
2. Sort tasks by duration ascending using `std::sort`.
3. Initialize `current_time = 0LL` and `total_reward = 0LL`.
4. For each task $(a, d)$:
   - `current_time += a`
   - `total_reward += (d - current_time)`
5. Output `total_reward`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Task {
    long long a, d;
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<Task> tasks(n);
    for (int i = 0; i < n; ++i) {
        cin >> tasks[i].a >> tasks[i].d;
    }

    // Sort primarily by duration ascending
    sort(tasks.begin(), tasks.end(), [](const Task& x, const Task& y) {
        if (x.a != y.a) return x.a < y.a;
        return x.d < y.d;
    });

    long long current_time = 0;
    long long total_reward = 0;

    for (int i = 0; i < n; ++i) {
        current_time += tasks[i].a;
        total_reward += (tasks[i].d - current_time);
    }

    cout << total_reward << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$ to sort the tasks. The simulation loop runs in $\mathcal{O}(n)$. For $n = 2 \cdot 10^5$, $n \log_2 n \approx 3.6 \times 10^6$ operations, executing in $\approx 0.04$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ memory for storing tasks ($2 \cdot 10^5 \times 16$ bytes $\approx 3.2$ MB).

---

## 6. Correctness Proof

**Theorem**: Sorting tasks in non-decreasing order of duration ($a_1 \le a_2 \le \dots \le a_n$) maximizes the total reward $\sum (d_i - f_i)$.

**Proof by Exchange Argument**:
1. Let $\sum_{i=1}^n d_i = D$. The total reward is $D - \sum_{i=1}^n f_i$.
   Since $D$ is constant for any permutation, maximizing reward is identical to minimizing $\sum_{i=1}^n f_i$.
2. Suppose there exists an optimal schedule where two adjacent tasks $i$ and $j$ appear out of order, meaning task $i$ is processed immediately before task $j$, but $a_i > a_j$.
3. Let $T$ be the time when task $i$ begins.
   - In the current schedule:
     - Task $i$ finishes at $f_i = T + a_i$.
     - Task $j$ finishes at $f_j = T + a_i + a_j$.
     - Contribution of the pair to $\sum f$ is:
       $$C_1 = f_i + f_j = 2T + 2a_i + a_j$$
   - Swap tasks $i$ and $j$ so task $j$ runs first:
     - Task $j$ finishes at $f_j' = T + a_j$.
     - Task $i$ finishes at $f_i' = T + a_j + a_i$.
     - Contribution of the pair to $\sum f$ is:
       $$C_2 = f_j' + f_i' = 2T + 2a_j + a_i$$
4. Compute the difference:
   $$C_1 - C_2 = (2a_i + a_j) - (2a_j + a_i) = a_i - a_j > 0$$
   Because $a_i > a_j$, swapping the tasks strictly reduces the sum of completion times by $a_i - a_j$!
5. Furthermore, the finish time of the second task $T + a_i + a_j$ is identical in both orders, so all subsequent tasks $k > j$ experience zero change in their completion times.
6. Thus, any inversion $a_i > a_{i+1}$ can be eliminated to strictly improve (or maintain) the total reward. By Bubble Sort termination, the globally optimal schedule must have no inversions: $a_1 \le a_2 \le \dots \le a_n$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 3$.
Tasks: $(6, 10), (8, 15), (5, 12)$.

Sorted by duration:
1. Task 3: $a = 5, d = 12$
2. Task 1: $a = 6, d = 10$
3. Task 2: $a = 8, d = 15$

Simulation:
- Task 3:
  `current_time = 0 + 5 = 5`.
  Reward: $12 - 5 = +7$. `total_reward = 7`.
- Task 1:
  `current_time = 5 + 6 = 11`.
  Reward: $10 - 11 = -1$. `total_reward = 7 + (-1) = 6`.
- Task 2:
  `current_time = 11 + 8 = 19`.
  Reward: $15 - 19 = -4$. `total_reward = 6 + (-4) = 2`.

Final Output: **2**. Exactly matches the CSES example!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **CRITICAL: 64-bit Integer Overflow**:
  $n = 2 \cdot 10^5$, $a_i \le 10^6$, $d_i \le 10^6$.
  Total completion time can reach $n \times a_{\max} = 2 \cdot 10^{11}$.
  The sum of completion times can reach:
  $$\approx \frac{n^2}{2} \cdot a_{\text{avg}} \approx \frac{4 \cdot 10^{10}}{2} \times 10^6 = 2 \cdot 10^{16}$$
  This vastly exceeds 32-bit signed integer limits ($2.14 \times 10^9$).
  Both `current_time` and `total_reward` MUST be declared as `long long`.
- **Negative Total Rewards**: The problem states you must process all tasks even if rewards are negative. Negative total rewards are handled seamlessly by signed `long long`.
- **Identical Durations ($a_i = a_j$)**: Ties can be broken arbitrarily; they contribute identically to $\sum f$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if tasks had individual weights $w_i$ and the objective was to maximize $\sum w_i(d_i - f_i)$?**
   - Maximizing $\sum w_i d_i - \sum w_i f_i$ reduces to minimizing $\sum w_i f_i$. By Smith's Rule, sort tasks in descending order of the ratio $\frac{w_i}{a_i}$ (or $w_i \cdot a_j > w_j \cdot a_i$).
2. **What if we want to minimize the number of late tasks ($f_i > d_i$)?**
   - That is Hodgson-Moore's Algorithm: process tasks in EDD order, and whenever a task is late, remove the task with the largest processing time from the accepted set using a max-heap in $\mathcal{O}(n \log n)$.
3. **What if there are $m$ identical parallel processors?**
   - Minimizing $\sum f_i$ on $m$ parallel machines sorts by duration ascending and assigns jobs in round-robin fashion to machines.
4. **Why didn't the deadline values affect the sorting order?**
   - Because all tasks must be executed, the sum of deadlines $\sum d_i$ is a fixed invariant. Only the completion times $f_i$ depend on the ordering.
5. **How does this relate to customer queueing systems?**
   - In queueing theory, Shortest Processing Time (SPT) / Shortest Job First (SJF) minimizes average wait time and average system latency.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Greedy, Sorting, Exchange Argument, Rearrangement Inequality, Scheduling.
- **Time Complexity**: $\mathcal{O}(n \log n)$ sorting time.
- **Space Complexity**: $\mathcal{O}(n)$ storage for tasks.

### Related CSES Tasks
- [CSES 1629 - Movie Festival](https://cses.fi/problemset/task/1629): Non-overlapping interval scheduling.
- [CSES 1631 - Reading Books](https://cses.fi/problemset/task/1631): Dual-agent reading schedule.
- [CSES 1620 - Factory Machines](https://cses.fi/problemset/task/1620): Binary search on parallel machine production.
