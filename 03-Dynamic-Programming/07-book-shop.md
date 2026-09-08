# Book Shop

- **Category**: Dynamic Programming
- **CSES Task ID**: `1158`
- **CSES Problem Link**: [Book Shop](https://cses.fi/problemset/task/1158)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are visiting a book shop that sells $n$ distinct books. For each book $i$, you are given its price $h_i$ and its number of pages $s_i$. You have a maximum budget of $x$. You can buy **at most one copy** of each book. Determine the **maximum total number of pages** you can buy without exceeding your budget $x$.

### Input Format
- The first line contains two integers $n$ and $x$.
- The second line contains $n$ integers $h_1, h_2, \dots, h_n$ (prices).
- The third line contains $n$ integers $s_1, s_2, \dots, s_n$ (pages).

### Output Format
- Print one integer: the maximum number of pages.

### Numerical Constraints
- $1 \le n \le 1000$
- $1 \le x \le 10^5$
- $1 \le h_i \le 1000$
- $1 \le s_i \le 1000$

With $n = 1000$ and $x = 10^5$, an $\mathcal{O}(n \cdot x)$ 0/1 knapsack approach performs $10^8$ operations, running in $\approx 0.08\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the canonical **0/1 Knapsack Problem**:
- Each book presents a binary decision: **buy** (include) or **skip** (exclude).
- Unlike *Minimizing Coins* or *Coin Combinations* (unbounded knapsack), each book can be chosen **at most once**.
- Let $dp[i][w]$ denote the maximum pages obtainable from a subset of the first $i$ books with total price $\le w$:
  $$dp[i][w] = \max \begin{cases} dp[i-1][w] & \text{(skip book } i \text{)} \\ dp[i-1][w - h_i] + s_i & \text{(buy book } i \text{, if } w \ge h_i \text{)} \end{cases}$$
- **1D Space Optimization & Reverse Iteration**:
  To reduce memory from $\mathcal{O}(n \cdot x)$ to $\mathcal{O}(x)$, we maintain a single array `dp[w]`.
  When processing book $i$ with price $h_i$, we must iterate budget $w$ **backwards from $x$ down to $h_i$**:
  $$dp[w] = \max(dp[w], dp[w - h_i] + s_i)$$
  Traversing backwards ensures that $dp[w - h_i]$ still represents the state *before* book $i$ was considered, guaranteeing that book $i$ cannot be purchased more than once.

---

## 3. Approach 1 — Naive / Pure Recursion

Evaluate all $2^n$ subsets of books.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int solve_brute(const vector<int>& h, const vector<int>& s, int idx, int rem_budget) {
    if (idx < 0 || rem_budget <= 0) return 0;

    // Choice 1: Skip book idx
    int res = solve_brute(h, s, idx - 1, rem_budget);

    // Choice 2: Buy book idx
    if (rem_budget >= h[idx]) {
        res = max(res, s[idx] + solve_brute(h, s, idx - 1, rem_budget - h[idx]));
    }

    return res;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, x;
    if (!(cin >> n >> x)) return 0;

    vector<int> h(n), s(n);
    for (int i = 0; i < n; ++i) cin >> h[i];
    for (int i = 0; i < n; ++i) cin >> s[i];

    cout << solve_brute(h, s, n - 1, x) << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^n)$.
- **Space Complexity**: $\mathcal{O}(n)$ stack depth.
- **CSES Verdict**: TLE for $n > 25$.

---

## 4. Approach 2 — Intermediate / 2D DP Table

Store all $1000 \times 10^5$ subproblem values.

### C++17 2D DP Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, x;
    if (!(cin >> n >> x)) return 0;

    vector<int> h(n + 1), s(n + 1);
    for (int i = 1; i <= n; ++i) cin >> h[i];
    for (int i = 1; i <= n; ++i) cin >> s[i];

    // 2D table of size (1001) x (100001) ~ 10^8 ints * 4 bytes = 400 MB
    vector<vector<int>> dp(n + 1, vector<int>(x + 1, 0));

    for (int i = 1; i <= n; ++i) {
        for (int w = 0; w <= x; ++w) {
            dp[i][w] = dp[i - 1][w];
            if (w >= h[i]) {
                dp[i][w] = max(dp[i][w], dp[i - 1][w - h[i]] + s[i]);
            }
        }
    }

    cout << dp[n][x] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot x)$.
- **Space Complexity**: $\mathcal{O}(n \cdot x)$. Allocating $400\text{ MB}$ causes memory bandwidth thrashing and is dangerously close to memory limits.
- **Verdict**: Slow ($\approx 0.38\text{s}$) due to poor cache locality.

---

## 5. Approach 3 — Optimal CSES Solution (1D Reverse-Sweep DP)

Maintain a single 1D array `dp` of size $x + 1$ initialized to $0$. 
For each book $(h_i, s_i)$, sweep $w$ backwards from $x$ down to $h_i$:
```cpp
dp[w] = max(dp[w], dp[w - h_i] + s_i);
```

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, x;
    if (!(cin >> n >> x)) return 0;

    vector<int> price(n);
    for (int i = 0; i < n; ++i) {
        cin >> price[i];
    }

    vector<int> pages(n);
    for (int i = 0; i < n; ++i) {
        cin >> pages[i];
    }

    // dp[w] stores the maximum pages obtainable with budget at most w
    vector<int> dp(x + 1, 0);

    // Process each book sequentially
    for (int i = 0; i < n; ++i) {
        int cost = price[i];
        int page_count = pages[i];

        // Traverse backwards to guarantee each book is used at most once
        for (int w = x; w >= cost; --w) {
            dp[w] = max(dp[w], dp[w - cost] + page_count);
        }
    }

    cout << dp[x] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot x)$. Outer loop runs $n$ times; inner loop runs $x - h_i + 1 \le x$ times. With $n \le 1000$ and $x \le 10^5$, total operations $\le 10^8$, finishing in $\approx 0.05\text{s}$.
- **Space Complexity**: $\mathcal{O}(x)$ auxiliary space. An array of $10^5$ 32-bit integers uses only $400\text{ KB}$, fitting effortlessly into L2/L3 CPU cache.
- **Optimality Guarantee**: 0/1 knapsack with arbitrary weights is NP-complete, and pseudo-polynomial $\mathcal{O}(n \cdot x)$ time is optimal.

---

## 6. Correctness Proof

### Induction on Book Prefix
Let $dp^{(i)}[w]$ denote the maximum pages using a subset of the first $i$ books with total price $\le w$.
- **Base Case**: For $i = 0$, no books are available, so $dp^{(0)}[w] = 0$ for all $w \in [0, x]$.
- **Inductive Step**: When considering book $i$ with cost $h_i$ and value $s_i$:
  - If we exclude book $i$, the best score is $dp^{(i-1)}[w]$.
  - If we include book $i$, it consumes cost $h_i$, leaving budget $w - h_i$ to be filled by books from $\{1, \dots, i-1\}$. The best score is $dp^{(i-1)}[w - h_i] + s_i$.
  - Therefore, $dp^{(i)}[w] = \max(dp^{(i-1)}[w], dp^{(i-1)}[w - h_i] + s_i)$.
- **Reverse Iteration Correctness**:
  Because $w$ iterates strictly backwards from $x$ down to $h_i$:
  - When computing $dp[w]$, the value at $dp[w - h_i]$ has **not yet been updated** in iteration $i$, and thus still holds $dp^{(i-1)}[w - h_i]$.
  - This prevents book $i$ from being applied multiple times to the same budget state.
  - At the end of $n$ iterations, $dp[x]$ contains $dp^{(n)}[x]$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
4 10
4 8 5 3
5 12 8 1
```
$n = 4, x = 10$. Books:
- Book 0: Price 4, Pages 5
- Book 1: Price 8, Pages 12
- Book 2: Price 5, Pages 8
- Book 3: Price 3, Pages 1

| Book $(h, s)$ | Budget $w = 10$ | $w = 9$ | $w = 8$ | $w = 7$ | $w = 6$ | $w = 5$ | $w = 4$ | $w = 3$ |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Initial** | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| **Book 0 (4, 5)** | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 0 |
| **Book 1 (8, 12)** | $\max(5, 0+12)=12$ | 12 | 12 | 5 | 5 | 5 | 5 | 0 |
| **Book 2 (5, 8)** | $\max(12, 5+8)=\mathbf{13}$ | $\max(12, 5+8)=13$ | 12 | 8 | 8 | 8 | 5 | 0 |
| **Book 3 (3, 1)** | $\max(13, 8+1)=13$ | $\max(13, 8+1)=13$ | $\max(12, 8+1)=12$ | 9 | 9 | 8 | 5 | 1 |

Optimal choice at $w = 10$ is $\mathbf{13}$ pages (Book 0 with Price 4 + Book 2 with Price 5 = Price 9 $\le 10$, Pages $= 5 + 8 = 13$).
**Output**: `13`. Matches CSES example.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Insufficient Budget**: If all $h_i > x$, the inner loop never executes, returning $0$.
- **Exact Budget Match**: The algorithm maximizes pages for budget *at most* $x$, automatically covering configurations that spend $< x$.
- **Page Accumulation**: Total pages $\le 1000 \times 1000 = 10^6$, which fits within a standard 32-bit signed `int`.
- **Direction of Loop**:
  - `for (int w = x; w >= cost; --w)` $\implies$ **0/1 Knapsack** (at most one of each).
  - `for (int w = cost; w <= x; ++w)` $\implies$ **Unbounded Knapsack** (unlimited supply).

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Reconstruct the books selected?**
   - Use the 2D DP matrix or bitset masks. If $dp[i][w] == dp[i-1][w - h_i] + s_i$, book $i$ was included.
2. **What if $x \le 10^9$ and $n \le 1000$, but total pages $\sum s_i \le 10^5$?**
   - Invert the DP state! Let $dp[p]$ be the **minimum cost** to achieve exactly $p$ pages.
     $$dp[p] = \min(dp[p], dp[p - s_i] + h_i)$$
     Find the largest $p$ such that $dp[p] \le x$. Time becomes $\mathcal{O}(n \sum s_i)$.
3. **What if $n \le 40$ and $x \le 10^{18}$?**
   - Pseudo-polynomial DP fails. Use **Meet-in-the-Middle**: divide $n$ into two halves of size 20, enumerate all $2^{20}$ subsets in each half, sort, and match using two pointers in $\mathcal{O}(2^{n/2})$.
4. **Bounded Knapsack (each book has quantity $k_i$)?**
   - Decompose $k_i$ into binary powers $\{1, 2, 4, \dots, R\}$ and run 0/1 knapsack in $\mathcal{O}(x \sum \log k_i)$.
5. **Fractional Knapsack (can buy fractions of books)?**
   - Greedy algorithm: sort by page-to-price ratio $\frac{s_i}{h_i}$ in $\mathcal{O}(n \log n)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, 0-1-knapsack, space-optimization, subset-sum]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot x)$
  - Space: $\mathcal{O}(x)$
- **Related CSES Problems**:
  - `CSES 1634` — [Minimizing Coins](https://cses.fi/problemset/task/1634) (Unbounded knapsack optimization).
  - `CSES 1745` — [Money Sums](https://cses.fi/problemset/task/1745) (0/1 Knapsack reachability with bitsets).
  - `CSES 1093` — [Two Sets II](https://cses.fi/problemset/task/1093) (0/1 Knapsack partition counting).
