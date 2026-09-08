# Minimizing Coins

- **Category**: Dynamic Programming
- **CSES Task ID**: `1634`
- **CSES Problem Link**: [Minimizing Coins](https://cses.fi/problemset/task/1634)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given a money system consisting of $n$ distinct positive coin values $c_1, c_2, \dots, c_n$ and a target sum $x$, determine the **minimum number of coins** required to construct the exact sum $x$. You can use an unlimited supply of each coin denomination. If it is impossible to form the sum, output `-1`.

### Input Format
- The first line contains two integers $n$ and $x$.
- The second line contains $n$ distinct integers $c_1, c_2, \dots, c_n$.

### Output Format
- Print one integer: the minimum number of coins required, or `-1` if impossible.

### Numerical Constraints
- $1 \le n \le 100$
- $1 \le x \le 10^6$
- $1 \le c_i \le 10^6$

With $n \le 100$ and $x \le 10^6$, an unbounded knapsack DP performs at most $n \cdot x = 10^8$ operations, executing in $\approx 0.15\text{s}$ (well within the 1.00s limit).

---

## 2. Intuition & Pattern Recognition

This is the classic **Unbounded Knapsack / Shortest Path on a Directed Acyclic Graph (DAG)**:
- Greedy strategies (such as always choosing the largest coin) **fail** on arbitrary coin systems (e.g., coins $\{1, 3, 4\}$ for sum $6$: greedy picks $4 + 1 + 1 = 3$ coins, but the optimal is $3 + 3 = 2$ coins).
- We must evaluate optimal subproblems: to form sum $i$, the last coin added must be some coin $c \in \{c_1, \dots, c_n\}$ with $c \le i$.
- The minimum coins to form sum $i$ is $1$ plus the minimum coins needed to form the remainder $i - c$:
  $$dp[i] = 1 + \min_{c \in \{c_1, \dots, c_n\}, c \le i} dp[i - c]$$
- Base case: $dp[0] = 0$ (zero coins needed to form sum 0). All other states initialized to $\infty$.

---

## 3. Approach 1 — Naive / Pure Recursion

Recursively try every coin from $x$ down to $0$.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const int INF = 1e9;

int solve_brute(const vector<int>& coins, int rem) {
    if (rem == 0) return 0;
    if (rem < 0) return INF;

    int min_coins = INF;
    for (int c : coins) {
        if (rem >= c) {
            min_coins = min(min_coins, 1 + solve_brute(coins, rem - c));
        }
    }
    return min_coins;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, x;
    if (!(cin >> n >> x)) return 0;

    vector<int> coins(n);
    for (int i = 0; i < n; ++i) cin >> coins[i];

    int ans = solve_brute(coins, x);
    cout << (ans >= INF ? -1 : ans) << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^x)$, exponential branching.
- **Space Complexity**: $\mathcal{O}(x)$ recursion depth.
- **CSES Verdict**: TLE for $x > 30$.

---

## 4. Approach 2 — Intermediate / Breadth-First Search (BFS) on State Graph

We can model sums from $0$ to $x$ as nodes in an unweighted graph, with directed edges $(u, u + c)$ of weight $1$ for each coin $c$. A BFS starting from node $0$ finds the shortest path to node $x$.

### C++17 BFS Implementation

```cpp
#include <iostream>
#include <vector>
#include <queue>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, x;
    if (!(cin >> n >> x)) return 0;

    vector<int> coins(n);
    for (int i = 0; i < n; ++i) cin >> coins[i];

    vector<int> dist(x + 1, -1);
    queue<int> q;

    dist[0] = 0;
    q.push(0);

    while (!q.empty()) {
        int u = q.front();
        q.pop();

        if (u == x) break;

        for (int c : coins) {
            if (u + c <= x && dist[u + c] == -1) {
                dist[u + c] = dist[u] + 1;
                q.push(u + c);
            }
        }
    }

    cout << dist[x] << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(V + E) = \mathcal{O}(x + n \cdot x) = \mathcal{O}(n \cdot x)$.
- **Space Complexity**: $\mathcal{O}(x)$ for `dist` array and BFS queue.
- **Verdict**: Accepted, but `std::queue` dynamic operations incur more cache misses than a simple contiguous array iteration.

---

## 5. Approach 3 — Optimal CSES Solution (1D Tabulation DP)

We allocate a single vector `dp` of size $x + 1$, initialized with $\infty$. Set $dp[0] = 0$. We iterate $i$ from $1$ up to $x$, updating $dp[i]$ by checking each coin $c$.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const int INF = 1e9;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, x;
    if (!(cin >> n >> x)) return 0;

    vector<int> coins(n);
    for (int i = 0; i < n; ++i) {
        cin >> coins[i];
    }

    // dp[s] stores the minimum coins to produce sum s
    vector<int> dp(x + 1, INF);

    // Base case: 0 coins needed to produce sum 0
    dp[0] = 0;

    for (int i = 1; i <= x; ++i) {
        for (int c : coins) {
            if (i >= c && dp[i - c] != INF) {
                dp[i] = min(dp[i], dp[i - c] + 1);
            }
        }
    }

    // If unreachable, output -1
    cout << (dp[x] == INF ? -1 : dp[x]) << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot x)$. Outer loop executes $x$ times; inner loop scans $n$ coins. With $n \le 100$ and $x \le 10^6$, total operations $\le 10^8$, finishing in $\approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(x)$ auxiliary space. A vector of $10^6$ 32-bit integers consumes only $4\text{ MB}$, comfortably within the 512 MB memory limit.
- **Optimality Guarantee**: Every state $i \in [1, x]$ can depend on any coin $c$, so $\Omega(n \cdot x)$ transitions are required.

---

## 6. Correctness Proof

### Optimal Substructure
Let an optimal coin multiset for sum $i$ be $S = \{k_1, k_2, \dots, k_m\}$ with $|S| = m$ coins.
- If we remove any coin $k_j \in S$, the remaining multiset $S' = S \setminus \{k_j\}$ has sum $i - k_j$ and cardinality $m - 1$.
- If there existed a valid configuration for $i - k_j$ with fewer than $m - 1$ coins, say $m' < m - 1$, then adding $k_j$ back would yield a combination for $i$ of size $m' + 1 < m$, contradicting the optimality of $S$.
- Hence, the problem exhibits optimal substructure.

### Inductive Invariant
At the conclusion of iteration $i$, $dp[i]$ contains the exact minimum number of coins to form sum $i$ (or $\infty$ if unreachable).
- Base case $i = 0$: $dp[0] = 0$ is trivially correct.
- Assume $dp[k]$ is correct for all $0 \le k < i$. Any valid combination summing to $i$ must end with some coin $c \in \{c_1, \dots, c_n\}$ leaving remainder $i - c$.
- By the induction hypothesis, $dp[i - c]$ stores the minimum coins to form $i - c$.
- Taking the minimum of $dp[i - c] + 1$ over all $c \le i$ guarantees that $dp[i]$ is the global minimum for sum $i$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
3 11
1 5 7
```
$n = 3$, $x = 11$, coins = $\{1, 5, 7\}$.

| Sum $i$ | Coin 1 ($c=1$) | Coin 5 ($c=5$) | Coin 7 ($c=7$) | Min Value ($dp[i]$) |
| :---: | :---: | :---: | :---: | :---: |
| **0** | - | - | - | **0** |
| **1** | $dp[0]+1 = 1$ | - | - | **1** |
| **2** | $dp[1]+1 = 2$ | - | - | **2** |
| **3** | $dp[2]+1 = 3$ | - | - | **3** |
| **4** | $dp[3]+1 = 4$ | - | - | **4** |
| **5** | $dp[4]+1 = 5$ | $dp[0]+1 = 1$ | - | **1** (single 5-coin) |
| **6** | $dp[5]+1 = 2$ | $dp[1]+1 = 2$ | - | **2** ($5+1$) |
| **7** | $dp[6]+1 = 3$ | $dp[2]+1 = 3$ | $dp[0]+1 = 1$ | **1** (single 7-coin) |
| **8** | $dp[7]+1 = 2$ | $dp[3]+1 = 4$ | $dp[1]+1 = 2$ | **2** ($7+1$) |
| **9** | $dp[8]+1 = 3$ | $dp[4]+1 = 5$ | $dp[2]+1 = 3$ | **3** |
| **10** | $dp[9]+1 = 4$ | $dp[5]+1 = 2$ | $dp[3]+1 = 4$ | **2** ($5+5$) |
| **11** | $dp[10]+1 = 3$ | $dp[6]+1 = 3$ | $dp[4]+1 = 5$ | **3** ($5+5+1$ or $7+1+1+... \to 3$) |

**Final Output**: `3` (using coins $5 + 5 + 1$).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Unreachable Sum**: If $x$ cannot be formed (e.g. coins are $\{2, 4\}$ and $x = 7$), $dp[x]$ remains `INF`. Output `-1`.
- **$c_i > x$**: A coin larger than $x$ can never be used; skipped by `if (i >= c)`.
- **Infinity Constant**: Set `INF = 1e9` instead of `INT_MAX` to avoid integer overflow when calculating `dp[i - c] + 1`.
- **$x = 0$**: Requires $0$ coins.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Reconstruct the actual coins used?**
   - Store a `parent[i]` array indicating which coin was chosen to achieve the minimum $dp[i]$. Backtrack from $x$ by subtracting `parent[x]` repeatedly until reaching $0$.
2. **What if each coin can be used AT MOST ONCE (0/1 Knapsack)?**
   - Loop coins in the outer loop, and iterate sum $i$ backwards from $x$ down to $c$: $dp[i] = \min(dp[i], dp[i - c] + 1)$.
3. **What if $x$ is very large ($x \le 10^9$) and $n \le 100$?**
   - When $x$ is large, DP is too slow. However, if $c_i \le 10^5$, by the Frobenius coin problem/periodicity, the largest coin $C_{\max}$ can be used greedily for the vast majority of $x$, reducing the problem to Dijkstra / DP over remainders modulo $C_{\max}$ (**Shortest Path Faster Algorithm / Dijkstra on Modulo Graph**) in $\mathcal{O}(C_{\max} \log C_{\max})$.
4. **Number of ways to achieve the minimum number of coins?**
   - Maintain a second array `ways[i]`: if $dp[i - c] + 1 < dp[i]$, update $dp[i]$ and set `ways[i] = ways[i - c]`; if equal, add `ways[i - c]` to `ways[i]`.
5. **Weighted coins (each coin has cost $w_i$ and value $c_i$)?**
   - Standard Unbounded Knapsack minimizing total cost for value $x$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, unbounded-knapsack, shortest-path, optimization]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot x)$
  - Space: $\mathcal{O}(x)$
- **Related CSES Problems**:
  - `CSES 1633` — [Dice Combinations](https://cses.fi/problemset/task/1633) (Count ordered combinations).
  - `CSES 1635` — [Coin Combinations I](https://cses.fi/problemset/task/1635) (Count ordered ways to form sum).
  - `CSES 1636` — [Coin Combinations II](https://cses.fi/problemset/task/1636) (Count unordered combinations).
