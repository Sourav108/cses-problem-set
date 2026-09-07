# Increasing Array (CSES Task 1094 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1094 - Increasing Array](https://cses.fi/problemset/task/1094)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: You are given an array of $n$ integers. You want to modify the array so that it is increasing, i.e., every element is at least as large as the previous element ($x_{i} \ge x_{i-1}$ for all $i \ge 1$). On each move, you may increase the value of any element by one. What is the minimum number of moves required?
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le x_i \le 10^9$.

---

## 1. Problem, Restated

Make an array non-decreasing ($x_0 \le x_1 \le x_2 \le \dots \le x_{n-1}$) by only *increasing* elements. Find the minimum total additions needed.

**Input**: First line contains $n$. Second line contains $n$ integers $x_1, x_2, \dots, x_n$ via `cin`.  
**Output**: Print the minimum number of moves on `cout` ending with `\n`.  
**Critical Constraint**: $n \le 2 \cdot 10^5$ and $x_i \le 10^9$. If $x_0 = 10^9$ and all remaining $2 \cdot 10^5 - 1$ elements are $1$, the required moves are $\approx 2 \cdot 10^5 \times 10^9 = 2 \cdot 10^{14}$, which drastically overflows a 32-bit signed integer. The accumulator **must** be 64-bit `long long`.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Greedy Optimization / Running Prefix Maximum.
- **Aha! Insight**: We process elements strictly from left to right. Because we can only *increase* elements (never decrease), element $x_i$ can never force an earlier element $x_{i-1}$ to change. Thus, to minimize total moves:
  - If $x_i < x_{i-1}$, the optimal choice is to raise $x_i$ to exactly $x_{i-1}$. Raising it higher than $x_{i-1}$ would only make subsequent elements harder to satisfy without providing any benefit to $x_i$.
  - Number of moves added at step $i$: $\max(0LL, x_{i-1} - x_i)$.
  - Effectively, each modified element becomes $\max(x_0, x_1, \dots, x_i)$.
- **Signal**: "Only increases allowed" + "Non-decreasing target" + "Minimize cost" $\implies$ Local greedy decisions are globally optimal.

---

## 3. Approach 1 — Naive / Baseline (Step-by-Step Increment Simulation)

### Idea
Iterate through the array and use a `while (x[i] < x[i - 1])` loop, incrementing `x[i]` by 1 on each step.

### C++17 Code
```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    int n;
    if (!(cin >> n)) return 0;
    vector<long long> x(n);
    for (int i = 0; i < n; i++) cin >> x[i];

    long long moves = 0;
    for (int i = 1; i < n; i++) {
        while (x[i] < x[i - 1]) { // Severe TLE!
            x[i]++;
            moves++;
        }
    }

    cout << moves << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(\sum \Delta) = \mathcal{O}(n \cdot \max(x_i)) \approx 2 \cdot 10^{14}$ operations in the worst case.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: Extreme TLE.

---

## 4. Approach 2 — Intermediate (Storing Full Array in Memory)

### Idea
Read the entire array into a `vector<long long>` and compute differences in $\mathcal{O}(1)$ per element:
```cpp
if (x[i] < x[i - 1]) {
    moves += (x[i - 1] - x[i]);
    x[i] = x[i - 1];
}
```
This requires $\mathcal{O}(n)$ time and $\mathcal{O}(n)$ auxiliary memory.

---

## 5. Approach 3 — Optimal CSES Solution (Online Streaming with $\mathcal{O}(1)$ Memory)

### Idea
Maintain `prev_val` (representing the running maximum of all elements seen so far). For each incoming number `curr`:
- If `curr < prev_val`, add `prev_val - curr` to `moves`.
- Otherwise, update `prev_val = curr`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>

using namespace std;

int main() {
    // Standardized Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    long long prev_val;
    cin >> prev_val;

    long long moves = 0;

    for (int i = 1; i < n; i++) {
        long long curr;
        cin >> curr;

        if (curr < prev_val) {
            moves += (prev_val - curr);
        } else {
            prev_val = curr;
        }
    }

    cout << moves << '\n';

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n)$ — exactly $n - 1$ scalar comparisons and subtractions, running in $\approx 2$ ms for $n = 2 \cdot 10^5$.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary space — only two scalar variables (`prev_val` and `curr`).
- **Optimality Guarantee**: Matches the best known/asymptotically optimal complexity for the problem ($\Omega(n)$ lower bound to read the input) and comfortably satisfies the CSES limits.

---

## 6. Correctness Proof

- **Invariant**: After processing element $i$, the modified prefix $x'[0 \dots i]$ satisfies $x'[0] \le x'[1] \le \dots \le x'[i]$, where $x'[i] = \max_{0 \le k \le i} x_k$.
- **Greedy-Choice Property & Exchange Argument**:
  - We require $x'[i] \ge x_i$ (since only increases are allowed) and $x'[i] \ge x'[i-1]$.
  - Therefore, $x'[i] \ge \max(x_i, x'[i-1])$.
  - Suppose an alternative valid solution $S$ sets $x^*[i] > \max(x_i, x'[i-1])$. Reducing $x^*[i]$ to $\max(x_i, x'[i-1])$ strictly decreases the moves spent on index $i$ by $x^*[i] - \max(x_i, x'[i-1])$ without violating the requirement $x^*[i] \ge x'[i-1]$ or making subsequent elements harder to satisfy (since smaller values of $x'[i]$ loosen the constraint $x'[i+1] \ge x'[i]$).
  - Thus, setting $x'[i] = \max(x_i, x'[i-1])$ is globally optimal.
- **Termination**: The stream loop executes exactly $n - 1$ times and terminates deterministically.

---

## 7. Dry Run & Visual State Trace

Input: `n = 5`, array: `[3, 2, 5, 1, 7]`

| Step `i` | `curr` | `prev_val` (before) | `curr < prev_val`? | Moves Added | Cumulative `moves` | Updated `prev_val` |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 0 | 3 | - | - | 0 | 0 | 3 |
| 1 | 2 | 3 | Yes | $3 - 2 = 1$ | 1 | 3 |
| 2 | 5 | 3 | No | 0 | 1 | 5 |
| 3 | 1 | 5 | Yes | $5 - 1 = 4$ | 5 | 5 |
| 4 | 7 | 5 | No | 0 | 5 | 7 |

Final Output: `5` moves ✅

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Integer Overflow**: Accumulator `moves` can reach $2 \cdot 10^{14}$. Storing `moves` in a standard 32-bit `int` will overflow to a negative number, causing a Wrong Answer on CSES test cases. Always use `long long`.
- **Already Non-decreasing Array** (e.g. `[1, 2, 3, 4, 5]`): `curr < prev_val` is never true; outputs `0`.
- **Decreasing Array** (e.g. `[10, 9, 8, 7]`): Demonstrates maximal delta accumulation.
- **$n = 1$**: Loop does not execute; outputs `0`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Q1: What if we can both increment AND decrement elements by 1, and want to make the array strictly increasing with minimum moves?**
   - **A**: Transform to non-decreasing by defining $b[i] = a[i] - i$. The problem reduces to finding a non-decreasing sequence $b$ minimizing $\sum |a[i] - b[i]|$, which is solved using Slope Trick / Priority Queue in $\mathcal{O}(n \log n)$ (CF 713C / LeetCode 1187).
2. **Q2: What if we want the array to be strictly increasing ($x_i > x_{i-1}$) by only incrementing?**
   - **A**: The condition becomes $x_i \ge x_{i-1} + 1$. Replace condition with `target = prev_val + 1`. If `curr < target`, add `target - curr` and set `prev_val = target`.
3. **Q3: What if increments have non-uniform costs $c_i$ per unit increase?**
   - **A**: This becomes a Linear Programming / convex optimization problem solvable with dynamic programming or prefix min-cost flows.
4. **Q4: What if we can perform a range addition $[l, r]$ by $+v$ in a single move?**
   - **A**: Use difference array decomposition $\Delta[i] = a[i] - a[i-1]$; each range addition modifies only two values $\Delta[l]$ and $\Delta[r+1]$.
5. **Q5: What if elements can be updated online and we must answer the cost for prefixes dynamically?**
   - **A**: Maintain running maximums and block decompositions using a Segment Tree storing prefix max values.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `Greedy`, `Prefix-Max`, `Overflow-Safety`, `Online-Algorithm`, `Fast-IO`
- **Complexity Summary**:
  - **Time**: $\mathcal{O}(n)$
  - **Space**: $\mathcal{O}(1)$ auxiliary space
- **Related CSES Problems**:
  - **[CSES 1070 - Permutations](https://cses.fi/problemset/task/1070)**: Constructive parity-based ordering.
  - **[CSES 1071 - Number Spiral](https://cses.fi/problemset/task/1071)**: Constant-time mathematical grid deduction.
  - **[CSES 1074 - Stick Lengths](https://cses.fi/problemset/task/1074)**: Median-based minimization of $L_1$ distances.
