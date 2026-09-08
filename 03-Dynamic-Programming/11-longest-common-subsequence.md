# Longest Common Subsequence

- **Category**: Dynamic Programming
- **CSES Task ID**: `3403`
- **CSES Problem Link**: [Longest Common Subsequence](https://cses.fi/problemset/task/3403)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given two integer arrays $a$ of length $n$ and $b$ of length $m$, find their **longest common subsequence (LCS)**. A subsequence is formed by deleting zero or more elements from an array without changing the relative order of the remaining elements.

You must output:
1. The length of the longest common subsequence.
2. An example of such a subsequence. (If multiple valid sequences exist, any one is acceptable).

### Input Format
- The first line contains two integers $n$ and $m$.
- The second line contains $n$ integers $a_1, a_2, \dots, a_n$.
- The third line contains $m$ integers $b_1, b_2, \dots, b_m$.

### Output Format
- Print the length of the LCS on the first line.
- Print the elements of the LCS separated by spaces on the second line.

### Numerical Constraints
- $1 \le n, m \le 1000$
- $1 \le a_i, b_i \le 10^9$

With $n, m \le 1000$, the state space $n \times m = 10^6$ is small. An $\mathcal{O}(n \cdot m)$ dynamic programming table uses $\approx 4\text{ MB}$ of memory and finishes in $< 0.02\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the standard **2D String/Sequence Dynamic Programming with Solution Reconstruction**:
- Let $dp[i][j]$ be the length of the LCS between prefix $a[0 \dots i-1]$ and prefix $b[0 \dots j-1]$.
- Transitions:
  1. If the current elements match ($a[i-1] == b[j-1]$):
     $$dp[i][j] = dp[i-1][j-1] + 1$$
  2. If they do not match ($a[i-1] \ne b[j-1]$):
     $$dp[i][j] = \max(dp[i-1][j], dp[i][j-1])$$
- Base cases: $dp[i][0] = 0$ and $dp[0][j] = 0$.
- **Path Reconstruction**:
  Unlike problems that only require the scalar length, this task requires printing the actual elements. By maintaining the full $n \times m$ DP table, we can trace backwards from $(n, m)$ to $(0, 0)$ in $\mathcal{O}(n + m)$ steps:
  - If $a[i-1] == b[j-1]$, this element was included in the LCS: record $a[i-1]$ and transition to $(i-1, j-1)$.
  - Otherwise, follow the direction of the maximum: if $dp[i-1][j] \ge dp[i][j-1]$, decrement $i$; else decrement $j$.
  - Finally, reverse the collected elements to restore their original order.

---

## 3. Approach 1 — Naive / Pure Recursion

Branch recursively across all subsequence combinations.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int solve_brute(const vector<int>& a, const vector<int>& b, int i, int j) {
    if (i == 0 || j == 0) return 0;
    if (a[i - 1] == b[j - 1]) {
        return 1 + solve_brute(a, b, i - 1, j - 1);
    }
    return max(solve_brute(a, b, i - 1, j), solve_brute(a, b, i, j - 1));
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<int> a(n), b(m);
    for (int i = 0; i < n; ++i) cin >> a[i];
    for (int i = 0; i < m; ++i) cin >> b[i];

    cout << solve_brute(a, b, n, m) << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^{\min(n, m)})$.
- **Space Complexity**: $\mathcal{O}(n + m)$ call stack.
- **CSES Verdict**: TLE for $n, m > 20$.

---

## 4. Approach 2 — Intermediate / Space-Optimized Length Only (No Reconstruction)

If only the length were requested, two rolling rows would reduce memory to $\mathcal{O}(\min(n, m))$. However, reconstruction requires knowing the transition path taken across the entire grid, making full table storage necessary (or Hirschberg's divide-and-conquer algorithm).

---

## 5. Approach 3 — Optimal CSES Solution (2D DP Tabulation + Backtracking)

We allocate a 2D matrix `dp[n + 1][m + 1]`. After computing all cells in $\mathcal{O}(n \cdot m)$ time, we perform a deterministic backwards walk to reconstruct the solution.

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

    int n, m;
    if (!(cin >> n >> m)) return 0;

    vector<int> a(n);
    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    vector<int> b(m);
    for (int i = 0; i < m; ++i) {
        cin >> b[i];
    }

    // dp[i][j] stores the length of LCS for prefixes a[0..i-1] and b[0..j-1]
    vector<vector<int>> dp(n + 1, vector<int>(m + 1, 0));

    for (int i = 1; i <= n; ++i) {
        for (int j = 1; j <= m; ++j) {
            if (a[i - 1] == b[j - 1]) {
                dp[i][j] = dp[i - 1][j - 1] + 1;
            } else {
                dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
            }
        }
    }

    int lcs_len = dp[n][m];
    cout << lcs_len << '\n';

    // Backtracking to reconstruct the actual sequence
    vector<int> lcs_elements;
    lcs_elements.reserve(lcs_len);

    int i = n;
    int j = m;

    while (i > 0 && j > 0) {
        if (a[i - 1] == b[j - 1]) {
            lcs_elements.push_back(a[i - 1]);
            i--;
            j--;
        } else if (dp[i - 1][j] >= dp[i][j - 1]) {
            i--;
        } else {
            j--;
        }
    }

    // Reverse to restore original left-to-right order
    reverse(lcs_elements.begin(), lcs_elements.end());

    for (int k = 0; k < lcs_len; ++k) {
        cout << lcs_elements[k] << (k + 1 == lcs_len ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot m)$ for table evaluation, plus $\mathcal{O}(n + m)$ for backtracking. With $n, m \le 1000$, total operations $\le 10^6$, running in $\approx 0.01\text{s}$.
- **Space Complexity**: $\mathcal{O}(n \cdot m)$ auxiliary space. A $1001 \times 1001$ `vector<vector<int>>` uses $4\text{ MB}$, well within 512 MB.
- **Optimality Guarantee**: Matches the conditional lower bound $\Omega(n \cdot m)$ under SETH for general sequence alphabet LCS.

---

## 6. Correctness Proof

### Optimal Substructure
Let $Z = (z_1, \dots, z_k)$ be an optimal LCS of $X = (x_1, \dots, x_n)$ and $Y = (y_1, \dots, y_m)$:
1. If $x_n == y_m$, then $z_k = x_n = y_m$, and the prefix $Z_{k-1}$ is an LCS of $X_{n-1}$ and $Y_{m-1}$. (If a longer common subsequence existed for $X_{n-1}$ and $Y_{m-1}$, appending $x_n$ would produce a common subsequence of $X$ and $Y$ of length $> k$, a contradiction).
2. If $x_n \ne y_m$, then $z_k \ne x_n \implies Z$ is a common subsequence of $X_{n-1}$ and $Y$, or $z_k \ne y_m \implies Z$ is a common subsequence of $X$ and $Y_{m-1}$.
Thus, $dp[i][j]$ maintains the maximal length for every prefix pair.

### Backtracking Correctness
Starting at $(n, m)$:
- If $a[i-1] == b[j-1]$, moving diagonally to $(i-1, j-1)$ decreases the remaining required LCS length by exactly $1$, which matches the chosen element.
- If they differ, moving to the neighbor that holds value $dp[i][j]$ guarantees that the subproblem can still realize the full remaining LCS length without skipping valid characters.
- Termination: Reaches $i = 0$ or $j = 0$ after at most $n + m$ steps, collecting exactly $dp[n][m]$ elements.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
8 6
3 1 3 2 7 4 8 2
6 5 1 2 3 4
```
$n = 8, m = 6$.
$a = [3, 1, 3, 2, 7, 4, 8, 2]$  
$b = [6, 5, 1, 2, 3, 4]$

| DP Matrix | $\emptyset$ | 6 | 5 | 1 | 2 | 3 | 4 |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| $\emptyset$ | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| **3** | 0 | 0 | 0 | 0 | 0 | 1 | 1 |
| **1** | 0 | 0 | 0 | **1** | 1 | 1 | 1 |
| **3** | 0 | 0 | 0 | 1 | 1 | **2** | 2 |
| **2** | 0 | 0 | 0 | 1 | **2** | 2 | 2 |
| **7** | 0 | 0 | 0 | 1 | 2 | 2 | 2 |
| **4** | 0 | 0 | 0 | 1 | 2 | 2 | **3** |
| **8** | 0 | 0 | 0 | 1 | 2 | 2 | 3 |
| **2** | 0 | 0 | 0 | 1 | 2 | 2 | **3** |

Backtracking:
- From cell $(8, 6)$, value 3: $dp[7][6] = 3 \implies i \gets 7$.
- From cell $(7, 6)$, value 3: $dp[6][6] = 3 \implies i \gets 6$.
- At $(6, 6)$: $a[5] = 4, b[5] = 4 \implies$ **pick 4**, move to $(5, 5)$.
- From $(5, 5)$, value 2: $dp[4][5] = 2 \implies i \gets 4$.
- At $(4, 4)$: $a[3] = 2, b[3] = 2 \implies$ **pick 2**, move to $(3, 3)$.
- From $(3, 3)$, value 1: $dp[2][3] = 1 \implies i \gets 2$.
- At $(2, 3)$: $a[1] = 1, b[2] = 1 \implies$ **pick 1**, move to $(1, 2)$.
- Trace finishes.

Collected in reverse: `[4, 2, 1]`.  
Reversed to original: `1 2 4`.  
Length: `3`. (Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **No Common Elements**: $dp[n][m] = 0$, outputs `0` on first line and empty line on second line.
- **All Elements Equal**: If $a$ and $b$ are identical arrays of length $n$, outputs $n$ and the full array.
- **Large Values ($10^9$)**: Elements are up to $10^9$, handled cleanly by `int` without affecting table logic (values are compared for equality, not used as indices).
- **Multiple Valid LCS**: Any valid LCS of maximal length is accepted by CSES judge.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Space-Efficient Reconstruction in $\mathcal{O}(n + m)$ Memory?**
   - Use **Hirschberg's Algorithm** (Divide and Conquer with DP): find the midpoint alignment split in $\mathcal{O}(n \cdot m)$ time and $\mathcal{O}(\min(n, m))$ memory.
2. **What if elements in each array are DISTINCT (Permutation LCS)?**
   - Map each element in $a$ to its index. Replace elements in $b$ with their corresponding index in $a$. The LCS reduces to **Longest Increasing Subsequence (LIS)** in $\mathcal{O}(n \log n)$ time! (`CSES 1145`).
3. **Shortest Common Supersequence (SCS)?**
   - Length is $|a| + |b| - \text{LCS}(a, b)$. Reconstruct by printing characters from both strings along the LCS path.
4. **LCS of 3 Arrays?**
   - 3D Dynamic Programming: $dp[i][j][k]$ in $\mathcal{O}(n_1 \cdot n_2 \cdot n_3)$ time.
5. **Counting the Number of Distinct Longest Common Subsequences?**
   - Maintain a second array `ways[i][j]` using modular arithmetic, handling duplicate transitions using last-occurrence index maps.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, longest-common-subsequence, backtracking, 2d-dp]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot m)$
  - Space: $\mathcal{O}(n \cdot m)$
- **Related CSES Problems**:
  - `CSES 1639` — [Edit Distance](https://cses.fi/problemset/task/1639) (String edit distance with insertions/deletions/replacements).
  - `CSES 1145` — [Increasing Subsequence](https://cses.fi/problemset/task/1145) (LIS in $\mathcal{O}(n \log n)$).
  - `CSES 1744` — [Rectangle Cutting](https://cses.fi/problemset/task/1744) (2D grid cutting DP).
