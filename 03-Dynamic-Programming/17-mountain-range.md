# Mountain Range

- **Category**: Dynamic Programming
- **CSES Task ID**: `3314`
- **CSES Problem Link**: [Mountain Range](https://cses.fi/problemset/task/3314)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ mountains in a row, with heights $h_1, h_2, \dots, h_n$. You want to find a hang gliding route that visits as many mountains as possible. You begin at some mountain of your choice, and can glide from mountain $a$ to mountain $b$ if and only if:
1. Mountain $a$ is strictly taller than mountain $b$: $h_a > h_b$.
2. All mountains strictly between $a$ and $b$ are strictly shorter than $a$: $\forall k \in (\min(a, b), \max(a, b)), \; h_k < h_a$.

What is the **maximum number of mountains** you can visit on your route?

### Input Format
- The first line contains an integer $n$: the number of mountains.
- The second line contains $n$ integers $h_1, h_2, \dots, h_n$: the heights of the mountains.

### Output Format
- Print one integer: the maximum number of mountains on a valid route.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le h_i \le 10^9$

With $n = 2 \cdot 10^5$, an $\mathcal{O}(n^2)$ graph construction or pairwise reachability search performs $4 \cdot 10^{10}$ operations and will fail with TLE. We need an $\mathcal{O}(n)$ or $\mathcal{O}(n \log n)$ algorithm combining Monotonic Stacks and Dynamic Programming on a DAG.

---

## 2. Intuition & Pattern Recognition

Let us analyze the gliding condition in reverse:
- A route is a sequence of mountains $v_1 \to v_2 \to \dots \to v_k$ with strictly decreasing heights:
  $$h_{v_1} > h_{v_2} > \dots > h_{v_k}$$
- For any mountain $b$, which mountains $a$ could be the **immediate predecessor** of $b$ on an optimal route?
  Mountain $a$ must satisfy $h_a > h_b$ and all mountains between $a$ and $b$ must have $h_k < h_a$.
- **The Intermediate Mountain Lemma (Exchange Argument)**:
  Suppose $a$ is to the left of $b$ ($a < b$) and satisfies the gliding condition to $b$.
  Let $L[b]$ be the **nearest mountain to the left of $b$ that is strictly taller than $b$** ($h_{L[b]} > h_b$).
  - If $a = L[b]$, $a$ can directly glide to $b$.
  - If $a < L[b]$, then $L[b]$ lies strictly between $a$ and $b$.
  - Since $a$ can glide to $b$, all mountains between $a$ and $b$ must be strictly shorter than $a$. In particular, $h_{L[b]} < h_a$.
  - Therefore, all mountains between $a$ and $L[b]$ are also strictly shorter than $a$, which means **$a$ can glide to $L[b]$**!
  - Furthermore, by definition of $L[b]$, all mountains between $L[b]$ and $b$ have $h_k \le h_b < h_{L[b]}$, so **$L[b]$ can glide to $b$**!
  - Thus, the transition $a \to b$ can **always** be replaced with $a \to L[b] \to b$, which visits $L[b]$ as well and increases the path length by at least $1$!
- **Key Realization**:
  To maximize the number of mountains visited, any jump landing at mountain $i$ only ever needs to come from:
  1. $L[i]$: the nearest mountain to the left strictly taller than $i$.
  2. $R[i]$: the nearest mountain to the right strictly taller than $i$.
- This reduces a dense graph to a **Directed Acyclic Graph (DAG) where each vertex has in-degree at most 2**!
- Let $dp[i]$ be the maximum mountains visited ending at mountain $i$:
  $$dp[i] = 1 + \max(dp[L[i]], \; dp[R[i]])$$
  (with $dp[0] = 0$ for null boundaries).

---

## 3. Approach 1 — Naive / All-Pairs Graph DP

For each mountain $i$, scan left and right to find all visible shorter mountains $j$ and build an explicit graph, then compute the longest path via topological sort.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2)$. A mountain can have $\mathcal{O}(n)$ visible destinations.
- **Space Complexity**: $\mathcal{O}(n^2)$ edges.
- **CSES Verdict**: TLE and MLE for $n > 5000$.

---

## 4. Approach 2 — Intermediate / Segment Tree Range Maximum DP

We can sort mountains by height descending and use a Range Maximum Segment Tree to query the maximum DP value in the visible interval of each mountain.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n)$.
- **Space Complexity**: $\mathcal{O}(n)$.
- **Verdict**: Fully passes, but a monotonic stack with memoized DFS achieves the same in cleaner $\mathcal{O}(n)$ time without tree data structures.

---

## 5. Approach 3 — Optimal CSES Solution (Monotonic Stack + DAG DP)

1. Use a **monotonic stack** (strictly decreasing) to compute:
   - $L[i]$: 1-based index of the nearest element to the left with $h > h_i$ (or $0$ if none).
   - $R[i]$: 1-based index of the nearest element to the right with $h > h_i$ (or $0$ if none).
2. Because edges point from taller mountains to shorter mountains, we can compute $dp[i]$ in topological order:
   - Sort mountain indices $1 \dots n$ by height descending:
     $$dp[i] = 1 + \max(dp[L[i]], dp[R[i]])$$
   - Or evaluate via memoized recursion `solve(i)` with a `memo` table in $\mathcal{O}(n)$ time.
3. The answer is $\max_{1 \le i \le n} dp[i]$.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <stack>
#include <algorithm>

using namespace std;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> h(n + 1);
    for (int i = 1; i <= n; ++i) {
        cin >> h[i];
    }

    // L[i] = nearest index to the left with h[L[i]] > h[i]
    // R[i] = nearest index to the right with h[R[i]] > h[i]
    vector<int> L(n + 1, 0);
    vector<int> R(n + 1, 0);

    // Monotonic stack to find L[i]
    stack<int> st;
    for (int i = 1; i <= n; ++i) {
        while (!st.empty() && h[st.top()] <= h[i]) {
            st.pop();
        }
        if (!st.empty()) {
            L[i] = st.top();
        }
        st.push(i);
    }

    // Clear stack to find R[i]
    while (!st.empty()) st.pop();

    for (int i = n; i >= 1; --i) {
        while (!st.empty() && h[st.top()] <= h[i]) {
            st.pop();
        }
        if (!st.empty()) {
            R[i] = st.top();
        }
        st.push(i);
    }

    // Order indices by height descending to compute DP in topological order
    vector<int> order(n);
    for (int i = 0; i < n; ++i) {
        order[i] = i + 1;
    }
    sort(order.begin(), order.end(), [&](int a, int b) {
        return h[a] > h[b];
    });

    // dp[i] stores the maximum number of mountains on a route ending at mountain i
    vector<int> dp(n + 1, 0);
    int max_visited = 1;

    for (int idx : order) {
        int left_parent = L[idx];
        int right_parent = R[idx];

        int best_prev = 0;
        if (left_parent != 0) {
            best_prev = max(best_prev, dp[left_parent]);
        }
        if (right_parent != 0) {
            best_prev = max(best_prev, dp[right_parent]);
        }

        dp[idx] = 1 + best_prev;
        max_visited = max(max_visited, dp[idx]);
    }

    cout << max_visited << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n)$ due to sorting indices by height. (Can be reduced to $\mathcal{O}(n)$ using a Cartesian Tree or memoized DFS). For $n = 2 \cdot 10^5$, sorting $2 \cdot 10^5$ integers takes $< 0.05\text{s}$. The monotonic stack passes and DP iterations take $\mathcal{O}(n)$ time.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space to store $L$, $R$, `order`, and `dp` vectors.
- **Optimality Guarantee**: Since every mountain must be processed and predecessors found, $\mathcal{O}(n)$ is the theoretical lower bound.

---

## 6. Correctness Proof

### Optimal Predecessor Invariant
Let $P = (v_1, v_2, \dots, v_k)$ be an optimal route of maximal length ending at mountain $v_k = b$.
1. If $k = 1$, $dp[b] = 1$ is trivially achievable.
2. Suppose $k \ge 2$, and $a = v_{k-1}$ is the penultimate mountain.
   Without loss of generality, let $a < b$ (the case $a > b$ is symmetric).
3. Since $a \to b$ is a valid glide:
   - $h_a > h_b$.
   - $\forall m \in (a, b), \; h_m < h_a$.
4. Let $L[b]$ be the nearest mountain to the left with $h_{L[b]} > h_b$.
   - $a$ is a mountain to the left with height $> h_b$, so $L[b]$ must exist and satisfy $a \le L[b] < b$.
   - If $a = L[b]$, the predecessor is indeed $L[b]$.
   - If $a < L[b]$, then $L[b] \in (a, b)$, which implies $h_{L[b]} < h_a$.
   - Then $a$ can glide to $L[b]$ and $L[b]$ can glide to $b$.
   - Replacing the edge $a \to b$ with $a \to L[b] \to b$ yields a valid route of length $k + 1 > k$, which contradicts the maximality of $P$.
   - Hence, $a$ must be $L[b]$ (or $R[b]$ if $a > b$).
5. Thus, the longest route ending at $b$ can always be formed by extending an optimal route ending at either $L[b]$ or $R[b]$.
6. Inductively, $dp[b] = 1 + \max(dp[L[b]], dp[R[b]])$ computes the exact maximum route length.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
10
20 15 17 35 25 40 12 19 13 12
```

Indices: $1 \dots 10$. Heights: $[20, 15, 17, 35, 25, 40, 12, 19, 13, 12]$.

| Index $i$ | Height $h_i$ | Nearest Greater Left $L[i]$ | Nearest Greater Right $R[i]$ | Topological Order (by Height) | $dp[i] = 1 + \max(dp[L], dp[R])$ |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **6** | 40 | 0 | 0 | 1st | $1 + 0 = \mathbf{1}$ |
| **4** | 35 | 0 | 6 (40) | 2nd | $1 + dp[6] = 1 + 1 = \mathbf{2}$ |
| **5** | 25 | 4 (35) | 6 (40) | 3rd | $1 + \max(dp[4], dp[6]) = 1 + 2 = \mathbf{3}$ |
| **1** | 20 | 0 | 4 (35) | 4th | $1 + dp[4] = 1 + 2 = \mathbf{3}$ |
| **8** | 19 | 6 (40) | 0 | 5th | $1 + dp[6] = 1 + 1 = \mathbf{2}$ |
| **3** | 17 | 1 (20) | 4 (35) | 6th | $1 + \max(dp[1], dp[4]) = 1 + 3 = \mathbf{4}$ |
| **2** | 15 | 1 (20) | 3 (17) | 7th | $1 + \max(dp[1], dp[3]) = 1 + 4 = \mathbf{5}$ |
| **9** | 13 | 8 (19) | 0 | 8th | $1 + dp[8] = 1 + 2 = \mathbf{3}$ |
| **7** | 12 | 6 (40) | 8 (19) | 9th | $1 + \max(dp[6], dp[8]) = 1 + 2 = \mathbf{3}$ |
| **10** | 12 | 9 (13) | 0 | 10th | $1 + dp[9] = 1 + 3 = \mathbf{4}$ |

Max visited value across all mountains: $\mathbf{5}$ (at mountain 2).  
Route: $6 \to 4 \to 1 \to 3 \to 2$ (Heights: $40 \to 35 \to 20 \to 17 \to 15$).  
**Output**: `5`. Matches CSES example!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Strictly Increasing / Decreasing Array**: For $[10, 20, 30, 40]$, glide goes $4 \to 3 \to 2 \to 1$, visited is $n$.
- **All Equal Heights**: E.g. $[10, 10, 10]$. No mountain is strictly taller than any other. Stack finds no greater element ($L=0, R=0$). Output is `1`.
- **Heights up to $10^9$**: Heights fit inside 32-bit signed `int`.
- **Strict Inequalities**: The problem specifies $h_k < h_a$. A mountain of equal height blocks the glide. The monotonic stack condition `h[st.top()] <= h[i]` correctly pops equal elements.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Reconstruct the optimal route of mountains?**
   - Store `choice[i] = (dp[L[i]] >= dp[R[i]] ? L[i] : R[i])`. Starting from the mountain that achieves the maximum DP value, backtrack predecessors and reverse.
2. **What if the gliding cost/energy depends on horizontal distance $|a - b|$?**
   - If energy penalty is incurred, the Intermediate Mountain Lemma no longer holds. A segment tree with Li Chao Tree or Convex Hull Trick is needed.
3. **Cartesian Tree Connection?**
   - The tree formed by choosing $\text{parent}(i) = \text{argmin}_{p \in \{L[i], R[i]\}} h_p$ is precisely the **Cartesian Tree** of the array! The problem is equivalent to finding the longest path down the Cartesian Tree.
4. **Online Query: What if mountain heights are updated dynamically?**
   - Requires dynamic Cartesian Tree maintenance via Link-Cut Trees or Splay Trees in $\mathcal{O}(\log n)$ per update.
5. **Circular Mountain Range?**
   - If the mountains form a ring, compute nearest greater elements in a circular array by duplicating to length $2n$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, monotonic-stack, dag, greedy, cartesian-tree]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \log n)$ (or $\mathcal{O}(n)$ with memoized DFS)
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - `CSES 1645` — [Nearest Smaller Values](https://cses.fi/problemset/task/1645) (Monotonic stack fundamentals).
  - `CSES 1145` — [Increasing Subsequence](https://cses.fi/problemset/task/1145) (Classic longest path on sequence DAG).
  - `CSES 1638` — [Grid Paths I](https://cses.fi/problemset/task/1638) (DAG dynamic programming).
