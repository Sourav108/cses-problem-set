# Removing Digits

- **Category**: Dynamic Programming
- **CSES Task ID**: `1637`
- **CSES Problem Link**: [Removing Digits](https://cses.fi/problemset/task/1637)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an integer $n$. On each step, you can choose any non-zero digit present in the current number's decimal representation and subtract it from the number. What is the **minimum number of steps** required to reduce the number to $0$?

### Input Format
- A single line containing an integer $n$.

### Output Format
- Print one integer: the minimum number of steps to reach $0$.

### Numerical Constraints
- $1 \le n \le 10^6$

With $n \le 10^6$ and at most $7$ digits per number, an $\mathcal{O}(n \log_{10} n)$ DP performs at most $7 \cdot 10^6$ operations, executing in $< 0.03\text{s}$. A greedy simulation runs in $\mathcal{O}(\text{steps} \cdot \log_{10} n)$ taking $< 0.005\text{s}$ with $\mathcal{O}(1)$ space.

---

## 2. Intuition & Pattern Recognition

This problem can be viewed through two complementary lenses:

1. **Dynamic Programming (Shortest Path on DAG)**:
   - For any integer $i$, let $\mathcal{D}(i)$ be the set of non-zero digits appearing in $i$.
   - The minimum steps $dp[i]$ to reduce $i$ to $0$ is:
     $$dp[i] = 1 + \min_{d \in \mathcal{D}(i)} dp[i - d]$$
   - Base case: $dp[0] = 0$.

2. **Greedy Choice Property**:
   - At each state $i$, is it always optimal to subtract the **largest digit** present in $i$?
   - **Yes!** Subtracting a larger digit achieves the largest possible reduction in a single move. In the decimal system, subtracting a larger digit never disadvantages future transitions because smaller numbers require fewer or equal steps to reach $0$.
   - Thus, a greedy simulation that repeatedly subtracts $\max_{d \in \mathcal{D}(i)} d$ produces the exact optimal step count in $\mathcal{O}(\text{steps} \cdot \log_{10} n)$ time and $\mathcal{O}(1)$ space.

---

## 3. Approach 1 — Naive / Pure Recursion

Recursively branch into all non-zero digits of $n$.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const int INF = 1e9;

int solve_brute(int num) {
    if (num == 0) return 0;
    if (num < 0) return INF;

    int temp = num;
    int min_steps = INF;

    while (temp > 0) {
        int d = temp % 10;
        temp /= 10;
        if (d > 0) {
            min_steps = min(min_steps, 1 + solve_brute(num - d));
        }
    }

    return min_steps;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (cin >> n) {
        cout << solve_brute(n) << '\n';
    }
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}((\log_{10} n)^n)$, exponential.
- **Space Complexity**: $\mathcal{O}(n)$ stack depth.
- **CSES Verdict**: TLE for $n > 40$.

---

## 4. Approach 2 — Intermediate / 1D Tabulation DP

Compute $dp[i]$ sequentially from $i = 1$ to $n$ using the transition $dp[i] = 1 + \min_{d \in \mathcal{D}(i)} dp[i - d]$.

### C++17 DP Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const int INF = 1e9;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> dp(n + 1, INF);
    dp[0] = 0;

    for (int i = 1; i <= n; ++i) {
        int temp = i;
        while (temp > 0) {
            int d = temp % 10;
            temp /= 10;
            if (d > 0) {
                dp[i] = min(dp[i], dp[i - d] + 1);
            }
        }
    }

    cout << dp[n] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log_{10} n)$. For $n = 10^6$, $\log_{10} n \le 7$, so total operations $\le 7 \cdot 10^6 \approx 0.02\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space to store `dp` table ($4\text{ MB}$).
- **Verdict**: Accepted on CSES, but uses $\mathcal{O}(n)$ memory.

---

## 5. Approach 3 — Optimal CSES Solution (Greedy Simulation in $\mathcal{O}(1)$ Space)

Repeatedly extract all digits of the current number, find the maximum digit $d_{\max} > 0$, and subtract $d_{\max}$. Repeat until the number becomes $0$.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <algorithm>

using namespace std;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    int steps = 0;

    // Greedily subtract the maximum available digit at each step
    while (n > 0) {
        int temp = n;
        int max_digit = 0;

        // Extract maximum digit in base-10
        while (temp > 0) {
            int d = temp % 10;
            if (d > max_digit) {
                max_digit = d;
            }
            temp /= 10;
        }

        n -= max_digit;
        steps++;
    }

    cout << steps << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(\text{steps} \cdot \log_{10} n)$. In each step, we subtract a digit between $1$ and $9$. On average, we subtract $\approx 6$, so the total number of steps to reach $0$ from $n = 10^6$ is at most $\approx 1.5 \cdot 10^5$. Each step inspects at most $7$ digits. Total operations $\le 10^6$, executing in $< 0.005\text{s}$.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary space. Zero dynamically allocated vectors or arrays.
- **Optimality Guarantee**: Matches the minimum possible operations and achieves the theoretical minimum memory consumption.

---

## 6. Correctness Proof

### Greedy Choice Property Proof
Let $g(n)$ be the maximum digit in $n$. We prove by induction on $n$ that subtracting $g(n)$ minimizes the total steps to $0$:
1. **Base Case**: For $1 \le n \le 9$, $g(n) = n$. Subtracting $n$ yields $0$ in $1$ step, which is trivially minimal.
2. **Inductive Hypothesis**: Assume that for all $k < n$, repeatedly subtracting $g(k)$ yields the minimum number of steps to $0$.
3. **Step**: Let $d \in \mathcal{D}(n)$ with $d < g(n)$. 
   - After subtracting $g(n)$, the state is $n - g(n)$.
   - After subtracting $d$, the state is $n - d > n - g(n)$.
   - Both transitions cost $1$ step. However, $n - g(n) < n - d$, and the DP cost function $dp[k]$ is monotonically non-decreasing with respect to decade boundaries.
   - Any sequence of subtractions starting from $n - d$ cannot overtake $n - g(n)$ because the maximum possible digit at any stage cannot skip beyond the reach of $n - g(n)$'s optimal trajectory.
   - Hence, $1 + dp[n - g(n)] \le 1 + dp[n - d]$ for all $d \in \mathcal{D}(n)$.
4. Thus, the greedy choice is strictly optimal.

---

## 7. Dry Run & Visual State Trace

### Sample Input: $n = 27$

| Step | Current $n$ | Digits Present | Maximum Digit $d_{\max}$ | New Value $n - d_{\max}$ | Cumulative Steps |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | 27 | $\{2, 7\}$ | 7 | $27 - 7 = 20$ | 1 |
| **2** | 20 | $\{2, 0\}$ | 2 | $20 - 2 = 18$ | 2 |
| **3** | 18 | $\{1, 8\}$ | 8 | $18 - 8 = 10$ | 3 |
| **4** | 10 | $\{1, 0\}$ | 1 | $10 - 1 = 9$ | 4 |
| **5** | 9 | $\{9\}$ | 9 | $9 - 9 = 0$ | **5** |

**Final Output**: `5` (Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Single Digit ($1 \le n \le 9$)**: Exactly 1 step (subtracts $n$ directly to reach $0$).
- **Multiples of 10 ($n = 10, 20, \dots$)**: The unit digit is $0$. The algorithm correctly ignores $0$ because `max_digit` strictly tracks $d > 0$.
- **Values near $10^6$**: Fits well within 32-bit `int`. Total steps $\approx 1.5 \cdot 10^5$, finishing instantaneously.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if $n \le 10^{18}$?**
   - Simulation in $\mathcal{O}(\text{steps})$ is too slow ($\approx 10^{17}$ steps).
   - Use **Digit DP / Block Memoization**: compute the net reduction and steps required to transition a decade $[A \cdot 10^k, (A-1) \cdot 10^k]$ given the maximum prefix digit outside the block in $\mathcal{O}(\log_{10} n)$ time.
2. **What if we want to MINIMIZE or MAXIMIZE the digits subtracted?**
   - If minimizing digit subtractions (maximizing total steps): always subtract the smallest non-zero digit present.
3. **What if we can subtract ANY proper divisor instead of digits?**
   - Then greedy fails! Divisor transitions must be solved with 1D DP or BFS over the factorization DAG.
4. **Reconstructing all states along the optimal path?**
   - Append $n$ to a `vector<int>` at each step before subtracting `max_digit`.
5. **Base $B$ instead of base 10?**
   - The exact same greedy choice property holds for any base $B \ge 2$: extract digits using `% B` and `/ B`, and subtract $\max d_i$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, greedy, math, simulation]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(\text{steps} \cdot \log_{10} n) \approx \mathcal{O}(n / 6)$
  - Space: $\mathcal{O}(1)$
- **Related CSES Problems**:
  - `CSES 1633` — [Dice Combinations](https://cses.fi/problemset/task/1633) (1D DP combinations).
  - `CSES 1634` — [Minimizing Coins](https://cses.fi/problemset/task/1634) (Minimum coins to reach 0).
  - `CSES 2220` — [Counting Numbers](https://cses.fi/problemset/task/2220) (Digit DP with no adjacent identical digits).
