# Increasing Array Queries

- **Category**: Range Queries
- **CSES Task ID**: `2416`
- **CSES Problem Link**: [Increasing Array Queries](https://cses.fi/problemset/task/2416)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an array $x_1, x_2, \dots, x_n$ of $n$ positive integers. You may increase any element by 1 in a single operation.

You must answer $q$ queries:
- For a query range $[a, b]$ ($1 \le a \le b \le n$), what is the **minimum number of operations** needed to make the subarray $x_a, x_{a+1}, \dots, x_b$ non-decreasing (i.e., $x_i \ge x_{i-1}$ for all $a < i \le b$)?

Each query is independent (the array is not modified).

### Input Format
- The first line contains two integers $n$ and $q$: the array size and the number of queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the array elements.
- The next $q$ lines each contain two integers $a$ and $b$: the subarray boundaries.

### Output Format
- For each query, print the minimum number of operations on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$
- $1 \le a \le b \le n$

---

## 2. Intuition & Pattern Recognition

Recall the greedy solution for the classic CSES problem *Increasing Array*:
To make an array non-decreasing from left to right using only increments, we maintain a running prefix maximum $M$. For each position $i$, the element must be increased to at least $M$:
$$x'_i = \max(x_i, M)$$
The number of operations is:
$$\sum_{i=a}^b (x'_i - x_i) = \sum_{i=a}^b x'_i - \sum_{i=a}^b x_i$$
The second term, $\sum_{i=a}^b x_i$, is simply a static range sum computable in $\mathcal{O}(1)$ via a prefix sum array:
$$\text{sum}(a, b) = P[b] - P[a - 1], \quad \text{where } P[k] = \sum_{i=1}^k x_i$$

### Analyzing the Target Sum $\sum_{i=a}^b x'_i$
In the subarray $[a, b]$, the first element $x_a$ sets the initial maximum:
- As long as subsequent elements are $\le x_a$, they are all lifted to $x_a$.
- The first element strictly greater than $x_a$ occurs at index:
  $$nxt[a] = \min \{ j > a \mid x_j > x_a \} \quad (\text{or } n + 1 \text{ if none})$$
- Therefore, $x_a$ dominates all indices in $[a, \min(nxt[a] - 1, b)]$.
- If $nxt[a] \le b$, then at index $nxt[a]$, the value $x_{nxt[a]}$ becomes the new running maximum and dominates the interval $[nxt[a], \min(nxt[nxt[a]] - 1, b)]$.

This generates a jump trajectory:
$$a \to nxt[a] \to nxt[nxt[a]] \to \dots$$
Each step from node $u$ to $nxt[u]$ spans $(nxt[u] - u)$ positions, contributing:
$$\text{cost}(u) = x_u \cdot (nxt[u] - u)$$
to the target sum.

### Binary Lifting on the Jump Tree
Because each node $u$ jumps along a deterministic functional chain $u \to nxt[u]$, we can use **Binary Lifting**:
- `up[u][k]`: the node reached after $2^k$ jumps from $u$.
- `cost[u][k]`: the sum of contributions $\sum x_v \cdot (nxt[v] - v)$ accumulated over the $2^k$ jumps.

For query $[a, b]$:
1. Start at $curr = a$.
2. For $k = 18$ down to $0$:
   - If $\text{up}[curr][k] \le b$:
     $$\text{total} \mathrel{+}= \text{cost}[curr][k], \quad curr \leftarrow \text{up}[curr][k]$$
3. When no further full jumps can be made ($\text{up}[curr][0] > b$), the element $x_{curr}$ is the maximum for all remaining positions from $curr$ to $b$.
   Add its partial span:
   $$\text{total} \mathrel{+}= x_{curr} \cdot (b - curr + 1)$$
4. The final answer is:
   $$\text{total} - (P[b] - P[a - 1])$$

---

## 3. Approach 1 — Naive Linear Scan per Query

For each query $[a, b]$, maintain `cur_max = x[a]` and iterate $i$ from $a$ to $b$, accumulating $\max(0LL, cur\_max - x_i)$.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Offline Sweep with Monotonic Stack & Fenwick Tree

Sort queries by left endpoint $a$ descending. Maintain a monotonic stack of indices with decreasing values. When index $a$ is added, it pops all smaller elements and updates a range on a Fenwick tree.
- **Time Complexity**: $\mathcal{O}((n + q) \log n)$.
- **Space Complexity**: $\mathcal{O}(n + q)$.
- **Trade-off**: Requires offline sorting. Binary Lifting (Approach 3) is online, cleaner, and achieves identical asymptotic time.

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

    vector<long long> x(n + 2);
    vector<long long> pref(n + 1, 0);

    for (int i = 1; i <= n; ++i) {
        cin >> x[i];
        pref[i] = pref[i - 1] + x[i];
    }

    // Step 1: Precompute next strictly greater element using a monotonic stack
    vector<int> nxt(n + 2, n + 1);
    stack<int> st;

    for (int i = n; i >= 1; --i) {
        while (!st.empty() && x[st.top()] <= x[i]) {
            st.pop();
        }
        if (!st.empty()) {
            nxt[i] = st.top();
        }
        st.push(i);
    }

    // Step 2: Binary lifting table up[node][k] and cost[node][k]
    vector<vector<int>> up(n + 2, vector<int>(MAX_LOG, n + 1));
    vector<vector<long long>> cost(n + 2, vector<long long>(MAX_LOG, 0));

    for (int i = 1; i <= n; ++i) {
        up[i][0] = nxt[i];
        cost[i][0] = x[i] * (nxt[i] - i);
    }
    up[n + 1][0] = n + 1;
    cost[n + 1][0] = 0;

    for (int k = 1; k < MAX_LOG; ++k) {
        for (int i = 1; i <= n + 1; ++i) {
            up[i][k] = up[up[i][k - 1]][k - 1];
            cost[i][k] = cost[i][k - 1] + cost[up[i][k - 1]][k - 1];
        }
    }

    // Step 3: Process queries
    while (q--) {
        int a, b;
        cin >> a >> b;

        long long total_new = 0;
        int curr = a;

        for (int k = MAX_LOG - 1; k >= 0; --k) {
            if (up[curr][k] <= b) {
                total_new += cost[curr][k];
                curr = up[curr][k];
            }
        }

        // Add the tail contribution from curr to b
        total_new += x[curr] * (b - curr + 1);

        long long original_sum = pref[b] - pref[a - 1];
        cout << (total_new - original_sum) << '\n';
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Optimal Substructure of Non-Decreasing Prefix
For any array $x_a, \dots, x_b$, the condition $x'_i \ge x'_{i-1}$ implies $x'_i \ge \max_{a \le j \le i} x_j$.
Because each operation increments an element and operations are non-negative, the minimal valid choice for $x'_i$ is precisely:
$$x'_i = \max_{a \le j \le i} x_j$$
Any sequence of valid operations must result in $x''_i \ge x'_i$, so $\sum (x''_i - x_i) \ge \sum (x'_i - x_i)$.
Thus, $\sum_{i=a}^b x'_i - \sum_{i=a}^b x_i$ is the exact mathematical minimum.

### Partitioning by Jump Chain
Let the chain of maximal prefixes in $[a, b]$ be $v_0 = a < v_1 < \dots < v_m \le b$.
By definition of $nxt$, for any $k < m$ and any index $j \in [v_k, v_{k+1}-1]$, $x_j \le x_{v_k}$.
Thus $\max_{a \le t \le j} x_t = x_{v_k}$.
The sum of $x'_j$ for $j \in [v_k, v_{k+1}-1]$ is therefore exactly:
$$\sum_{j=v_k}^{v_{k+1}-1} x_{v_k} = x_{v_k} \cdot (v_{k+1} - v_k) = \text{cost}[v_k][0]$$
For the final interval $[v_m, b]$, no element strictly greater than $x_{v_m}$ exists in $[v_m, b]$, so $x'_j = x_{v_m}$ for all $j \in [v_m, b]$, contributing $x_{v_m} \cdot (b - v_m + 1)$.
Summing these disjoint components over the entire interval $[a, b]$ is exact.
Binary lifting computes this sum in $\mathcal{O}(\log n)$ steps.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
2 10 4 2 5
3 5
2 2
1 4
```

### Initial Array
$x = [-, 2, 10, 4, 2, 5]$
Prefix sums $P = [0, 2, 12, 16, 18, 23]$

Monotonic Stack:
- $nxt[5] = 6$
- $nxt[4] = 5$ ($x_5 = 5 > 2$)
- $nxt[3] = 6$ (no element after 3 is $> 4$ except none, $5 > 4 \implies nxt[3] = 5$)
- $nxt[2] = 6$ ($x_2 = 10$, largest)
- $nxt[1] = 2$ ($x_2 = 10 > 2$)

### Query 1: `3 5` ($a = 3, b = 5$)
- Subarray $x[3 \dots 5] = [4, 2, 5]$.
- Original sum: $P[5] - P[2] = 23 - 12 = 11$.
- Start $curr = 3$.
  - $nxt[3] = 5 \le 5$. Jump to 5!
  - `cost[3][0]` $= x_3 \cdot (5 - 3) = 4 \cdot 2 = 8$.
  - $curr = 5$.
  - $nxt[5] = 6 > 5$. Cannot jump.
- Tail: $curr = 5$, span $[5, 5]$ of length 1: $x_5 \cdot 1 = 5 \cdot 1 = 5$.
- `total_new` $= 8 + 5 = 13$.
- Operations: $13 - 11 = 2$.
- Subarray becomes $[4, 4, 5]$, requiring $0 + 2 + 0 = 2$ operations.
- Output: `2`.

### Query 2: `2 2` ($a = 2, b = 2$)
- Single element $x_2 = 10$.
- Output: `0`.

### Query 3: `1 4` ($a = 1, b = 4$)
- Subarray $x[1 \dots 4] = [2, 10, 4, 2]$.
- Original sum: $P[4] - P[0] = 18$.
- Start $curr = 1$.
  - $nxt[1] = 2 \le 4$. Jump to 2!
  - `cost[1][0]` $= x_1 \cdot (2 - 1) = 2 \cdot 1 = 2$.
  - $curr = 2$.
  - $nxt[2] = 6 > 4$. Stop jumping.
- Tail: $curr = 2$, span $[2, 4]$ of length 3: $x_2 \cdot 3 = 10 \cdot 3 = 30$.
- `total_new` $= 2 + 30 = 32$.
- Operations: $32 - 18 = 14$.
- Subarray becomes $[2, 10, 10, 10]$, requiring $0 + 0 + 6 + 8 = 14$ operations.
- Output: `14`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **64-bit Integer Overflow**:
   $n = 2 \cdot 10^5, x_i = 10^9$. The maximum sum of transformed elements can be $2 \cdot 10^{14}$, which overflows 32-bit integer. `cost`, `total_new`, and `pref` must be `long long`.
2. **Single Element Range ($a = b$)**:
   The binary lifting loop does not trigger, and the tail calculation adds $x_a \cdot 1$. Subtracting $P[a] - P[a-1] = x_a$ yields $0$, which is correct.
3. **Array Already Non-Decreasing**:
   Every element satisfies $nxt[i] = i + 1$. The algorithm jumps from $a$ to $b$, giving $\sum x_i$ and resulting in $0$ operations.
4. **All Elements Equal**:
   Equal elements cannot jump to each other ($x_j > x_i$ strict). The first element $a$ has $nxt[a] = n + 1$, so it dominates the entire range $[a, b]$, correctly producing 0 operations.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if we are allowed to decrease elements as well (L1 isotonic regression)?**
   If both increments and decrements are allowed, the optimal transformed array is non-decreasing and minimizes $\sum |x'_i - x_i|$. This requires Slope Trick / Leftist Heaps / Persistent Treaps in $\mathcal{O}(n \log n)$.
2. **Can this problem support point updates ($x_k \leftarrow u$)?**
   With point updates, $nxt$ pointers change globally, breaking static binary lifting. A dynamic solution requires a Segment Tree where each node maintains the function mapping an incoming prefix maximum to the resulting sum.
3. **What if the operations have cost $c_i$ per unit increase?**
   If costs vary per element, prefix maximums no longer define the optimal shape; linear programming duality or min-cost flow on DAGs is required.
4. **How does this connect to CSES Visible Buildings Queries?**
   CSES 3304 counts the number of visible buildings, which is simply the number of hops along the exact same $nxt$ pointer tree. CSES 2416 weights each hop by $x_u \cdot (nxt[u] - u)$.
5. **Can the table memory be reduced?**
   Yes. The table size is $200000 \times 18 \times 8\text{ B} \approx 28.8\text{ MB}$, well within 512 MB. Flattening vectors into 1D arrays further improves cache locality.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Monotonic Stack**: $\mathcal{O}(n)$
  - **Binary Lifting Precomputation**: $\mathcal{O}(n \log n)$
  - **Per Query**: $\mathcal{O}(\log n)$
  - **Overall Run Time**: $\mathcal{O}((n + q) \log n) \approx 0.08\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n \log n)$ auxiliary space ($\approx 30\text{ MB}$).

### Related CSES Problems
- [Visible Buildings Queries](https://cses.fi/problemset/task/3304) — Same jump tree structure
- [Increasing Array](https://cses.fi/problemset/task/1091) — Original linear greedy problem
- [Prefix Sum Queries](https://cses.fi/problemset/task/2166) — Prefix operations on intervals
