# Visible Buildings Queries

- **Category**: Range Queries
- **CSES Task ID**: `3304`
- **CSES Problem Link**: [Visible Buildings Queries](https://cses.fi/problemset/task/3304)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ buildings in a row numbered $1, 2, \dots, n$ from left to right with heights $h_1, h_2, \dots, h_n$. You are standing immediately to the left of a designated subarray $[a, b]$.

A building $i \in [a, b]$ is **visible** if and only if it is strictly taller than all buildings to its left within the range $[a, b]$:
$$h_i > \max_{a \le j < i} h_j$$
(The very first building $a$ has no buildings to its left in $[a, b]$, so it is always visible.)

You must answer $q$ independent queries of the form:
- Given range $[a, b]$, determine how many buildings are visible.

### Input Format
- The first line contains two integers $n$ and $q$: the number of buildings and queries.
- The second line contains $n$ integers $h_1, h_2, \dots, h_n$: the heights of the buildings.
- The next $q$ lines each contain two integers $a$ and $b$: the boundaries of the query subarray.

### Output Format
- For each query, print the number of visible buildings on a new line.

### Numerical Constraints
- $1 \le n \le 10^5$
- $1 \le q \le 2 \cdot 10^5$
- $1 \le h_i \le 10^9$
- $1 \le a \le b \le n$

---

## 2. Intuition & Pattern Recognition

Consider what happens when looking at the subarray $[a, b]$:
1. The first building $a$ is visible. Its height is $H_1 = h_a$.
2. All buildings between $a$ and the next building that is strictly taller than $h_a$ will be hidden behind building $a$.
3. The next visible building is the **first** building to the right of $a$ whose height strictly exceeds $h_a$:
   $$nxt[a] = \min \{ j > a \mid h_j > h_a \}$$
   If $nxt[a] \le b$, then building $nxt[a]$ is visible.
4. Continuing inductively, the sequence of visible buildings in $[a, b]$ is precisely the trajectory:
   $$a \to nxt[a] \to nxt[nxt[a]] \to \dots$$
   truncated at the last index that is $\le b$.

Because the next taller building $nxt[i]$ depends **only on the global heights $h$** and not on the query endpoints, the transitions form a directed forest (or a tree rooted at a dummy sentinel $n + 1$).

### Key Insight: Binary Lifting on the Jump Tree
The problem reduces to counting how many steps can be taken along $u \leftarrow nxt[u]$ starting at $u = a$ such that $u \le b$.
- Precompute $nxt[i]$ for all $i \in [1, n]$ in $\mathcal{O}(n)$ time using a monotonic stack.
- Build a binary lifting table:
  $$\text{up}[u][k] = \text{the } 2^k\text{-th next taller building after } u$$
- For each query $[a, b]$:
  - Start at $u = a$, count = 1.
  - For $k = 18$ down to $0$:
    - If $\text{up}[u][k] \le b$:
      $$\text{count} \mathrel{+}= 2^k, \quad u \leftarrow \text{up}[u][k]$$
  - Return `count` in $\mathcal{O}(\log n)$ time.

---

## 3. Approach 1 — Naive Simulation per Query

For each query $[a, b]$, maintain `current_max = 0` and `count = 0`. Iterate through $i \in [a, b]$. If $h_i > \text{current\_max}$, increment `count` and update `current_max = h_i`.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 2 \cdot 10^5 \times 10^5 = 2 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$ to store heights.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Segment Tree with Historic Maximums / Monad Merging

A segment tree can compute visible prefixes in $\mathcal{O}(\log^2 n)$ or $\mathcal{O}(\log n)$ by defining a merge function `count_greater(node, threshold)` that counts how many visible buildings in the right child exceed the maximum of the left child.
- While elegant for dynamic updates, it requires $\mathcal{O}(\log^2 n)$ time per query without precomputed jump pointers.
- Since there are no updates in this problem, Binary Lifting (Approach 3) is strictly faster, simpler, and runs in $\mathcal{O}(\log n)$ per query.

---

## 5. Approach 3 — Optimal CSES Solution (Monotonic Stack + Binary Lifting)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <stack>

using namespace std;

static const int MAX_LOG = 18;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    vector<int> h(n + 1);
    for (int i = 1; i <= n; ++i) {
        cin >> h[i];
    }

    // Step 1: Precompute next strictly greater element using a monotonic stack
    // Sentinel n + 1 represents no taller building to the right
    vector<int> nxt(n + 2, n + 1);
    stack<int> st;

    for (int i = n; i >= 1; --i) {
        while (!st.empty() && h[st.top()] <= h[i]) {
            st.pop();
        }
        if (!st.empty()) {
            nxt[i] = st.top();
        }
        st.push(i);
    }

    // Step 2: Binary lifting table up[node][k]
    vector<vector<int>> up(n + 2, vector<int>(MAX_LOG, n + 1));
    for (int i = 1; i <= n; ++i) {
        up[i][0] = nxt[i];
    }
    up[n + 1][0] = n + 1;

    for (int k = 1; k < MAX_LOG; ++k) {
        for (int i = 1; i <= n + 1; ++i) {
            up[i][k] = up[up[i][k - 1]][k - 1];
        }
    }

    // Step 3: Process queries
    while (q--) {
        int a, b;
        cin >> a >> b;

        int count = 1; // Building 'a' is always visible
        int curr = a;

        for (int k = MAX_LOG - 1; k >= 0; --k) {
            if (up[curr][k] <= b) {
                count += (1 << k);
                curr = up[curr][k];
            }
        }

        cout << count << '\n';
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Lemma 1 (Greedy Next Taller Characterization)
Let $v_1, v_2, \dots, v_m$ be the indices of visible buildings in $[a, b]$ in increasing order.
Then $v_1 = a$.
For each $k \ge 1$, $v_{k+1}$ is the smallest index $j \in (v_k, b]$ such that $h_j > h_{v_k}$.
*Proof*:
By definition, a building $j \in (v_k, b]$ is visible iff $h_j > \max_{a \le i < j} h_i$.
Because $v_k$ is the latest visible building before $j$, $\max_{a \le i < j} h_i = h_{v_k}$.
Thus, $j$ is visible iff $h_j > h_{v_k}$. The earliest such index is by definition $nxt[v_k]$.
No building between $v_k$ and $nxt[v_k]$ can be visible because their heights are $\le h_{v_k}$.
Thus $v_{k+1} = nxt[v_k]$. By induction, the set of visible buildings is precisely $\{ a, nxt[a], nxt[nxt[a]], \dots \} \cap [a, b]$. $\blacksquare$

### Binary Lifting Invariant
The jump table satisfies $\text{up}[u][k] = nxt^{(2^k)}[u]$.
Because $nxt[u] > u$, the sequence of indices strictly increases along the chain.
Binary lifting greedily accumulates power-of-two jumps as long as the destination does not exceed $b$.
Since the sequence is strictly monotonic, this binary search finds the unique maximal path length in exactly $\mathcal{O}(\log n)$ steps.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
4 1 2 2 3
1 5
2 5
3 4
```

### Monotonic Stack Precomputation
Heights: `h = [-, 4, 1, 2, 2, 3]`
- $i = 5$ ($h_5 = 3$): Stack empty $\implies nxt[5] = 6$. Stack: `[5]`.
- $i = 4$ ($h_4 = 2$): $h_5 = 3 > 2 \implies nxt[4] = 5$. Stack: `[4, 5]`.
- $i = 3$ ($h_3 = 2$): Top $4$ has $h_4 = 2 \le 2$ (pop 4). Top $5$ has $h_5 = 3 > 2 \implies nxt[3] = 5$. Stack: `[3, 5]`.
- $i = 2$ ($h_2 = 1$): Top $3$ has $h_3 = 2 > 1 \implies nxt[2] = 3$. Stack: `[2, 3, 5]`.
- $i = 1$ ($h_1 = 4$): Pop all ($2, 3, 5 \le 4$) $\implies$ Stack empty $\implies nxt[1] = 6$. Stack: `[1]`.

`nxt` array:
- `nxt[1] = 6`
- `nxt[2] = 3`
- `nxt[3] = 5`
- `nxt[4] = 5`
- `nxt[5] = 6`

### Queries
1. **Query `1 5` ($a = 1, b = 5$)**:
   - Start $curr = 1$, `count = 1`.
   - `up[1][0] = 6 > 5`. Cannot jump.
   - Result: `1` (only building 1 is visible; with height 4, it blocks all others).
2. **Query `2 5` ($a = 2, b = 5$)**:
   - Subarray heights: `[1, 2, 2, 3]`.
   - Start $curr = 2$, `count = 1`.
   - `up[2][0] = 3 <= 5` $\implies curr = 3, count = 2$.
   - `up[3][0] = 5 <= 5` $\implies curr = 5, count = 3$.
   - `up[5][0] = 6 > 5`. Cannot jump.
   - Result: `3` (buildings at indices 2, 3, 5 with heights 1, 2, 3 are visible).
3. **Query `3 4` ($a = 3, b = 4$)**:
   - Subarray heights: `[2, 2]`.
   - Start $curr = 3$, `count = 1`.
   - `up[3][0] = 5 > 4`. Cannot jump.
   - Result: `1` (building 3 is visible; building 4 has height 2 which is not strictly greater).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Equal Heights**:
   The problem specifies that a building is visible if it is *strictly* taller than all previous buildings ($h_i > \max$). Therefore, buildings with equal height are not visible. In the monotonic stack, `h[st.top()] <= h[i]` must be popped so that `nxt[i]` points strictly to an element with $h[j] > h[i]$.
2. **Single-Element Range ($a = b$)**:
   When $a = b$, the loop condition `up[curr][k] <= b` is never satisfied, and the initial `count = 1` is correctly returned.
3. **Strictly Decreasing Array**:
   Every building blocks all buildings to its right ($nxt[i] = n + 1$). The answer for every query $[a, b]$ is correctly 1.
4. **Strictly Increasing Array**:
   Every building is visible ($nxt[i] = i + 1$). The answer for query $[a, b]$ is $b - a + 1$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if we are standing to the right of the subarray (looking left)?**
   We reverse the logic: $prev[i]$ is the first index to the left with $h[j] > h_i$. The jump pointers go leftwards towards index 0.
2. **What if the heights can be dynamically updated?**
   Binary lifting is static. With updates, we must use a Segment Tree that supports "visible buildings in child exceeding threshold" in $\mathcal{O}(\log^2 n)$ per query/update (Divide & Conquer on Trees).
3. **Can this be solved offline using a Fenwick tree?**
   Yes. Queries can be sorted by $a$. Processing from right to left, visible buildings from $a$ correspond to a path on a Cartesian Tree.
4. **How does this connect to Cartesian Trees?**
   The $nxt$ pointers are equivalent to right-ancestor transitions on the Cartesian tree of the sequence $h$.
5. **What if each building has a visibility weight or beauty score?**
   Along with `up[u][k]`, we maintain `sum_score[u][k]` representing the total score accumulated along the $2^k$ jumps.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Monotonic Stack**: $\mathcal{O}(n)$
  - **Binary Lifting Preprocessing**: $\mathcal{O}(n \log n)$
  - **Per Query**: $\mathcal{O}(\log n)$
  - **Overall Run Time**: $\mathcal{O}((n + q) \log n) \approx 0.05\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n \log n)$ for the `up` table $\approx 10^5 \times 18 \times 4\text{ B} \approx 7.2\text{ MB}$ (Limit: 512 MB).

### Related CSES Problems
- [Planets Queries I](https://cses.fi/problemset/task/1750) — Binary lifting on functional graphs
- [Static Range Minimum Queries](https://cses.fi/problemset/task/1647) — Monotonic properties and table lookup
- [Increasing Array Queries](https://cses.fi/problemset/task/2416) — Weighted jump chains on monotonic structures
