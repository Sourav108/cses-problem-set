# Missing Coin Sum (CSES Task 2183 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 2183 - Missing Coin Sum](https://cses.fi/problemset/task/2183)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: You have $n$ coins with positive integer values. What is the smallest positive sum you cannot create using a subset of the coins?
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le x_i \le 10^9$.

---

## 1. Problem, Restated

Given a multiset of $n$ positive coin denominations $X = \{x_1, x_2, \dots, x_n\}$, find the smallest integer $S \ge 1$ such that no subset $U \subseteq X$ satisfies $\sum_{u \in U} u = S$.

**Input**:
- First line: an integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Second line: $n$ space-separated integers $x_1, \dots, x_n$.

**Output**:
- Print a single integer: the smallest unreachable positive sum.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Inductive Range Extension / Greedy Sorting / Subset Sum Reachability.
- **Aha! Insight**:
  - Sort the coins in ascending order: $x_1 \le x_2 \le \dots \le x_n$.
  - Maintain an invariant: let $R$ be the smallest sum that **cannot** yet be formed using any subset of the coins processed so far.
    - Initially, with 0 coins, the reachable sums are $\{0\}$. The smallest positive unreachable sum is $R = 1$.
    - We have proved that all integers in $[1, R - 1]$ can be formed.
  - Now consider the next coin $x_i$:
    - **Case 1 ($x_i > R$)**:
      Can we form $R$?
      - Using coins $< x_i$, the maximum sum we can form is $R - 1$.
      - If we use $x_i$, the minimum positive sum containing $x_i$ is $x_i$.
      - Since $x_i > R$, the value $R$ falls into an unreachable gap!
      - Furthermore, all future coins are $\ge x_i > R$, so no subsequent coin can ever help form $R$.
      - Thus, $R$ is permanently impossible to form. We immediately terminate and return $R$.
    - **Case 2 ($x_i \le R$)**:
      - We can already form all integers in $[1, R - 1]$.
      - By adding the new coin $x_i$ to each of those known subsets, we can additionally form all integers in $[x_i, R - 1 + x_i]$.
      - Because $x_i \le R$, the intervals $[1, R - 1]$ and $[x_i, R + x_i - 1]$ overlap or touch ($x_i \le R \implies x_i - 1 \le R - 1$).
      - Their union forms a seamless, unbroken range:
        $$[1, R - 1] \cup [x_i, R + x_i - 1] = [1, R + x_i - 1]$$
      - Hence, our reachable range extends to $[1, R + x_i - 1]$.
      - The new smallest unreachable sum becomes $R \gets R + x_i$!
  - If the loop finishes all $n$ coins without encountering a gap, the answer is $R = \sum x_i + 1$.
- **Signal**: "Smallest positive sum that cannot be formed" is the textbook greedy prefix reachability problem.

---

## 3. Approach 1 — Naive / Baseline (0/1 Knapsack Dynamic Programming)

Using a boolean DP table or `std::bitset` to compute all reachable subset sums up to $W = \sum x_i$.
The total sum can reach $2 \cdot 10^5 \times 10^9 = 2 \cdot 10^{14}$. A bitset of size $2 \cdot 10^{14}$ would require hundreds of terabytes of memory, causing instant MLE.

---

## 4. Approach 2 — Intermediate (Recursive Backtracking)

Branching on whether to include each coin.
With $n = 2 \cdot 10^5$, $2^{200000}$ is astronomical $\implies$ TLE.

---

## 5. Approach 3 — Optimal CSES Solution (Sorted Inductive Extension)

### Idea
1. Read $n$ coins and sort them in non-decreasing order.
2. Initialize `smallest_unreachable = 1LL`.
3. For each coin $x$:
   - If $x > \text{smallest\_unreachable}$, break loop.
   - Else, $\text{smallest\_unreachable} += x$.
4. Print `smallest_unreachable`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<long long> x(n);
    for (int i = 0; i < n; ++i) {
        cin >> x[i];
    }

    sort(x.begin(), x.end());

    long long current_reach = 1;

    for (int i = 0; i < n; ++i) {
        if (x[i] > current_reach) {
            break;
        }
        current_reach += x[i];
    }

    cout << current_reach << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$ to sort the coins. The greedy loop runs in $\mathcal{O}(n)$ single-pass time. For $n = 2 \cdot 10^5$, $n \log_2 n \approx 3.6 \times 10^6$ operations, finishing in $\approx 0.04$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ storage for the coins array. $\mathcal{O}(1)$ auxiliary space.

---

## 6. Correctness Proof

**Theorem**: Let $x_1 \le x_2 \le \dots \le x_n$ be sorted positive integers. Define $R_0 = 1$ and $R_k = R_{k-1} + x_k$.
If for some index $k$, $x_k > R_{k-1}$, then $R_{k-1}$ is the minimum unreachable sum. Otherwise, $R_n$ is the minimum unreachable sum.

**Proof by Induction**:
1. **Base Case ($k = 0$)**: With 0 coins, the only subset sum is 0. The smallest positive integer not formable is 1. The interval of formable positive integers is $\emptyset = [1, 0]$.
2. **Inductive Step**:
   Assume using a subset of the first $k-1$ coins, every integer in $[1, R_{k-1} - 1]$ can be formed, and no integer $\ge R_{k-1}$ can be formed without coins from $\{x_k, \dots, x_n\}$.
   - If $x_k > R_{k-1}$:
     Any subset not containing coins from $\{x_k, \dots, x_n\}$ can only sum up to at most $\sum_{j=1}^{k-1} x_j = R_{k-1} - 1 < R_{k-1}$.
     Any subset containing at least one coin from $\{x_k, \dots, x_n\}$ must have sum $\ge x_k > R_{k-1}$.
     Therefore, no subset can sum to $R_{k-1}$. Thus $R_{k-1}$ is the global minimum unreachable sum.
   - If $x_k \le R_{k-1}$:
     For any integer $v \in [1, R_{k-1} - 1]$, $v$ is formable by induction hypothesis.
     For any integer $v \in [R_{k-1}, R_{k-1} + x_k - 1]$, observe that $v - x_k \in [R_{k-1} - x_k, R_{k-1} - 1]$.
     Since $x_k \le R_{k-1}$, $0 \le R_{k-1} - x_k$.
     Hence, $v - x_k$ is a non-negative integer $\le R_{k-1} - 1$.
     By induction hypothesis, $v - x_k$ can be formed using a subset of the first $k-1$ coins.
     Adding $x_k$ to this subset produces the sum $(v - x_k) + x_k = v$.
     Thus, every integer in $[1, R_k - 1]$ is formable.
3. By mathematical induction, the condition is both necessary and sufficient. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 5$, coins: `[2, 9, 1, 2, 7]`.
Sorted coins: `[1, 2, 2, 7, 9]`.

- Initial: `current_reach = 1`.
- Step 1: Coin $x_0 = 1$.
  - $1 \le 1$ $\implies$ Valid!
  - `current_reach` $= 1 + 1 = 2$. (Formable: $[1, 1]$)
- Step 2: Coin $x_1 = 2$.
  - $2 \le 2$ $\implies$ Valid!
  - `current_reach` $= 2 + 2 = 4$. (Formable: $[1, 3]$)
- Step 3: Coin $x_2 = 2$.
  - $2 \le 4$ $\implies$ Valid!
  - `current_reach` $= 4 + 2 = 6$. (Formable: $[1, 5]$)
- Step 4: Coin $x_3 = 7$.
  - $7 > 6$ $\implies$ **Gap detected!**
  - Break loop.

Output: **6**. (Numbers 1 through 5 can be formed: $1=1, 2=2, 3=1+2, 4=2+2, 5=1+2+2$. Sum 6 cannot be formed).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Coin 1 Missing ($x_0 > 1$, e.g. `[2, 3, 5]`)**:
  On step 0, $x_0 = 2 > 1$, loop breaks immediately and correctly prints `1`.
- **All coins are 1s**: `current_reach` accumulates to $n + 1$.
- **CRITICAL 64-bit Integer Overflow**:
  $n = 2 \cdot 10^5$, and $x_i \le 10^9$.
  If all coins are valid, `current_reach` reaches:
  $$1 + \sum_{i=1}^n x_i \le 1 + 2 \cdot 10^5 \times 10^9 = 2 \cdot 10^{14} + 1$$
  This significantly exceeds signed 32-bit `int` ($2.14 \times 10^9$).
  `long long` for `current_reach` and coin weights is strictly required.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if we can answer queries on subsegments $[L, R]$ of the array?**
   - Use a Segment Tree / Persistent Segment Tree or Merge Sort Tree to query the sum of elements $\le R$ iteratively, doubling $R$ in each step, solving each query in $\mathcal{O}(\log(\sum x) \cdot \log n)$.
2. **What if each coin can be used up to $c_i$ times (Bounded Coin System)?**
   - The condition generalizes to: if $x_i \le R$, new reach becomes $R + c_i \cdot x_i$.
3. **What is a "complete" sequence of integers?**
   - A sequence of positive integers is complete if every positive integer can be expressed as a sum of a subset. By our theorem, a sorted sequence is complete if and only if $x_1 = 1$ and $x_{k} \le 1 + \sum_{j=1}^{k-1} x_j$ for all $k$.
4. **How does this connect to binary representations?**
   - For powers of 2 ($x = [1, 2, 4, 8, 16]$), $x_k = 2^{k-1} \le 1 + (2^{k-1} - 1) = 2^{k-1}$, so every integer up to $2^n - 1$ is formable.
5. **How does this compare to LeetCode 330 (Patching Array)?**
   - LeetCode 330 asks for the minimum number of coins to *patch* (insert) so all numbers up to $N$ are formable. It uses this exact greedy condition, inserting $R$ whenever $x_i > R$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Greedy, Sorting, Math, Number Theory, Reachability.
- **Time Complexity**: $\mathcal{O}(n \log n)$ sorting time, $\mathcal{O}(n)$ linear scan.
- **Space Complexity**: $\mathcal{O}(n)$ storage for array.

### Related CSES Tasks
- [CSES 1074 - Stick Lengths](https://cses.fi/problemset/task/1074): Median minimization on sorted values.
- [CSES 1640 - Sum of Two Values](https://cses.fi/problemset/task/1640): Two-pointer search on sorted pairs.
- [CSES 1660 - Subarray Sums I](https://cses.fi/problemset/task/1660): Subarray target reachability.
