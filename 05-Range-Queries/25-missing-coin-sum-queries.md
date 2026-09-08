# Missing Coin Sum Queries

- **Category**: Range Queries
- **CSES Task ID**: `2184`
- **CSES Problem Link**: [Missing Coin Sum Queries](https://cses.fi/problemset/task/2184)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You have $n$ coins with positive integer values $x_1, x_2, \dots, x_n$. You must process $q$ queries:
- For a given range $[a, b]$ ($1 \le a \le b \le n$), if you can use only the subset of coins $x_a, x_{a+1}, \dots, x_b$, what is the **smallest positive integer sum** that cannot be produced?

Each query is independent.

### Input Format
- The first line contains two integers $n$ and $q$: the number of coins and queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the coin values.
- The next $q$ lines each contain two integers $a$ and $b$: the boundaries of the query range.

### Output Format
- For each query, print the smallest unreachable positive sum on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$
- $1 \le a \le b \le n$

---

## 2. Intuition & Pattern Recognition

Recall the greedy characterization from the original CSES *Missing Coin Sum* (Task 2183):
- Suppose a subset of coins can form all integer sums in the interval $[1, S]$.
- If we consider the remaining unused coins, the next coin with value $c$ can extend our reachable range to $[1, S + c]$ **if and only if** $c \le S + 1$.
- If every unused coin has value strictly greater than $S + 1$, then $S + 1$ can **never** be formed, and $S + 1$ is the optimal answer.

### Range Queries Formulation
In range $[a, b]$, coins are not pre-sorted. Sorting coins for each query would take $\mathcal{O}(q \cdot n \log n)$, which is too slow.
Instead, observe the generalization:
1. Start with reachable upper bound $S = 0$.
2. In each iteration, query the sum of **all coins** in subarray $x[a \dots b]$ that have value $\le S + 1$.
   Let this sum be $S'$.
3. If $S' = S$:
   No additional coins with value $\le S + 1$ exist in $[a, b]$.
   Therefore, $S + 1$ cannot be formed! Terminate and return $S + 1$.
4. If $S' > S$:
   All newly included coins satisfy $x_i \le S + 1$. Because each new coin is within the reach of the previous subset, they can greedily extend the reachable interval all the way to $S'$.
   Update $S \leftarrow S'$ and repeat!

### Logarithmic Iterations Bound
In each step where $S' > S$, $S$ at least includes a new coin of value $\ge \text{previous } (S + 1)$ (or grows exponentially). Consequently, $S$ roughly doubles in each step, guaranteeing that the loop terminates in at most $\mathcal{O}(\log(\sum x_i)) \le 60$ iterations (in practice $\le 30$).

### 2D Range Sum via Persistent Segment Tree
Each step requires:
$$\sum \{ x_i \mid i \in [a, b] \text{ and } x_i \le S + 1 \}$$
This is an orthogonal 2D range sum query. We build a **Persistent Segment Tree** over the indices $1 \dots n$:
- Version $i$ contains the prefix of coins $x_1, \dots, x_i$, with values placed in a segment tree over sorted distinct coin values.
- Summing coins in $[a, b]$ with value $\le V$ is:
  $$\text{query}(\text{root}[b], 1, V) - \text{query}(\text{root}[a - 1], 1, V)$$
This takes $\mathcal{O}(\log n)$ time per iteration, for a total query time of $\mathcal{O}(\log(\sum x) \log n)$.

---

## 3. Approach 1 — Naive Subarray Extraction & Sorting

For each query $[a, b]$, copy the subarray $x_a, \dots, x_b$, sort it in $\mathcal{O}(k \log k)$ time, and run the linear greedy check.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n \log n) \approx 2 \cdot 10^5 \times (2 \cdot 10^5 \times 18) \approx 7 \cdot 10^{11}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Merge Sort Tree Range Query

Maintain a Merge Sort Tree with prefix sums stored in each node.
- Range sum of elements $\le V$ takes $\mathcal{O}(\log^2 n)$ time.
- Total query time: $\mathcal{O}(\log(\sum x) \log^2 n)$.
- While feasible, the Persistent Segment Tree (Approach 3) eliminates one $\log n$ factor, achieving $\mathcal{O}(\log(\sum x) \log n)$ query time.

---

## 5. Approach 3 — Optimal CSES Solution (Persistent Segment Tree)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Node {
    long long sum;
    int lc;
    int rc;
    Node() : sum(0), lc(0), rc(0) {}
};

static const int MAX_NODES = 200005 * 40;
Node tree[MAX_NODES];
int node_cnt = 0;

int update(int prev, int l, int r, int val_idx, long long val) {
    int id = ++node_cnt;
    tree[id] = tree[prev];
    tree[id].sum += val;
    if (l == r) return id;
    int mid = l + (r - l) / 2;
    if (val_idx <= mid) {
        tree[id].lc = update(tree[prev].lc, l, mid, val_idx, val);
    } else {
        tree[id].rc = update(tree[prev].rc, mid + 1, r, val_idx, val);
    }
    return id;
}

long long query(int id, int l, int r, int ql, int qr) {
    if (!id || ql > r || qr < l) return 0;
    if (ql <= l && r <= qr) return tree[id].sum;
    int mid = l + (r - l) / 2;
    return query(tree[id].lc, l, mid, ql, qr) + query(tree[id].rc, mid + 1, r, ql, qr);
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    vector<long long> x(n + 1);
    vector<long long> vals;
    vals.reserve(n);

    for (int i = 1; i <= n; ++i) {
        cin >> x[i];
        vals.push_back(x[i]);
    }

    sort(vals.begin(), vals.end());
    vals.erase(unique(vals.begin(), vals.end()), vals.end());
    int K = static_cast<int>(vals.size());

    vector<int> roots(n + 1, 0);
    for (int i = 1; i <= n; ++i) {
        int v_idx = static_cast<int>(lower_bound(vals.begin(), vals.end(), x[i]) - vals.begin()) + 1;
        roots[i] = update(roots[i - 1], 1, K, v_idx, x[i]);
    }

    while (q--) {
        int a, b;
        cin >> a >> b;

        long long S = 0;
        while (true) {
            // Find rightmost distinct value <= S + 1
            int v_idx = static_cast<int>(upper_bound(vals.begin(), vals.end(), S + 1) - vals.begin());
            if (v_idx == 0) break;

            long long S_prime = query(roots[b], 1, K, 1, v_idx) - query(roots[a - 1], 1, K, 1, v_idx);
            if (S_prime == S) break;
            S = S_prime;
        }

        cout << (S + 1) << '\n';
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Lemma 1 (Subset Sum Reachability Invariant)
Let $C = \{c_1, c_2, \dots, c_m\}$ be all coins in $[a, b]$ with value $\le S + 1$.
If the coins with value $< S + 1$ can form all sums in $[1, S]$, and every coin $c \in C$ satisfies $c \le S + 1$, then by induction on adding coins one by one, the multiset $C$ can form every integer sum in $[1, \sum_{c \in C} c]$.
*Proof*:
Assume coins $c_1, \dots, c_k$ form all integers in $[1, \sigma]$.
The next coin $c_{k+1}$ satisfies $c_{k+1} \le S + 1 \le \sigma + 1$.
Adding $c_{k+1}$ extends the reachable range from $[1, \sigma]$ to $[1, \sigma] \cup [1 + c_{k+1}, \sigma + c_{k+1}] = [1, \sigma + c_{k+1}]$.
There are no gaps because $c_{k+1} \le \sigma + 1$.
Thus all integers up to $\sum c_i = S'$ are reachable. $\blacksquare$

### Lemma 2 (Termination Characterization)
If $S' = S$, there are no coins in $[a, b]$ with value in $(S, S + 1]$.
Because every existing coin in $[a, b]$ with value $\le S + 1$ has already been summed into $S$, any unused coin has value $\ge S + 2$.
Thus, no subset of coins can sum to $S + 1$.
$S + 1$ is strictly unreachable and minimal. $\blacksquare$

### Iteration Complexity
Whenever $S' > S$, $S'$ must include at least one coin $c > S_{\text{old}}$.
Because $c \ge 1$, after $c$ is added, $S \ge c$.
In subsequent steps, any new coin added must be $\ge S_{\text{old}} + 1$, which forces $S' \ge 2S_{\text{old}} + 1$.
Hence, $S$ at least doubles in value every step where new coins enter, bounding total iterations by $\mathcal{O}(\log(\sum x_i)) \le 60$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
2 9 1 2 7
2 4
4 4
1 5
```

### Initial Array
$x = [-, 2, 9, 1, 2, 7]$

### Query 1: `2 4` ($a = 2, b = 4$)
- Coins available: $x_2=9, x_3=1, x_4=2$.
- $S = 0$:
  - Query coins $\le S + 1 = 1$: coin at pos 3 has value 1 $\implies S' = 1$.
- $S = 1$:
  - Query coins $\le S + 1 = 2$: coins at pos 3 (1) and pos 4 (2) $\implies S' = 1 + 2 = 3$.
- $S = 3$:
  - Query coins $\le S + 1 = 4$: no new coins (pos 2 has 9) $\implies S' = 3$.
- $S' = S = 3 \implies$ break!
- Output: $S + 1 = 3 + 1 = 4$.

### Query 2: `4 4` ($a = 4, b = 4$)
- Coins available: $x_4 = 2$.
- $S = 0$:
  - Query coins $\le 1$: none $\implies S' = 0$.
- $S' = S = 0 \implies$ break!
- Output: $S + 1 = 1$.

### Query 3: `1 5` ($a = 1, b = 5$)
- Coins available: $[2, 9, 1, 2, 7]$.
- $S = 0 \implies$ coins $\le 1$: $\{1\} \implies S' = 1$.
- $S = 1 \implies$ coins $\le 2$: $\{1, 2, 2\} \implies S' = 5$.
- $S = 5 \implies$ coins $\le 6$: no new coins (next are 7, 9) $\implies S' = 5$.
- $S' = S = 5 \implies$ break!
- Output: $S + 1 = 6$.

Outputs match: `4`, `1`, `6`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Coin of Value 1 Missing**:
   If no coin of value 1 exists in $[a, b]$, the first iteration checks coins $\le 1$, finds sum 0, and immediately returns $0 + 1 = 1$.
2. **64-bit Sum Overflow**:
   Coin values up to $10^9$ with $n = 2 \cdot 10^5$. Total sum reaches $2 \cdot 10^{14}$. $S$, $S'$, and node sums must be `long long`.
3. **Values Greater than $S + 1$ Outside Array Range**:
   If $S + 1 \ge \max(x)$, `upper_bound` returns `vals.size()`, querying the sum of all coins in $[a, b]$ without index errors.
4. **Memory Allocation**:
   `MAX_NODES = 200005 * 40 \approx 8 \cdot 10^6` nodes $\times 16\text{ B} \approx 128\text{ MB}$, well within 512 MB.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Why is this problem solvable in $\mathcal{O}(\log^2 n)$ despite having unbounded coin values?**
   Because the reachable sum grows exponentially ($S \ge 2S_{\text{old}} + 1$). The logarithmic number of steps acts like binary lifting on value ranges.
2. **Can this problem support point updates on coins ($x_k \leftarrow u$)?**
   Yes. Replacing the Persistent Segment Tree with a **2D Fenwick Tree** or **Segment Tree of Fenwick Trees** allows point updates in $\mathcal{O}(\log^2 n)$ and queries in $\mathcal{O}(\log(\sum x) \log^2 n)$.
3. **What if coin values can be negative?**
   If coin values can be negative, the greedy reachability invariant fails completely (it becomes the NP-hard Subset Sum problem).
4. **How would you find the number of ways to form each sum?**
   Counting the number of ways to form sums requires generating functions (polynomial multiplication via NTT), which is $\mathcal{O}(S \log S)$.
5. **How does this compare to finding the $k$-th smallest missing coin sum?**
   Finding the $k$-th missing sum requires searching for gaps in the subset sum distribution, which cannot be expressed as simple prefix checks.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Coordinate Compression & Tree Build**: $\mathcal{O}(n \log n)$
  - **Per Query**: $\mathcal{O}(\log(\sum x_i) \cdot \log n) \le 30 \times 18 \approx 540$ operations
  - **Overall Run Time**: $\mathcal{O}(n \log n + q \log(\sum x) \log n) \approx 0.14\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n \log n)$ memory for persistent tree versions ($\approx 128\text{ MB}$).

### Related CSES Problems
- [Missing Coin Sum](https://cses.fi/problemset/task/2183) — Original 1-pass greedy problem
- [Range Queries and Copies](https://cses.fi/problemset/task/1737) — Persistent Segment Tree
- [Distinct Values Queries](https://cses.fi/problemset/task/1734) — Range queries with point subsets
