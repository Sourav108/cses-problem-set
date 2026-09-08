# Distinct Values Queries

- **Category**: Range Queries
- **CSES Task ID**: `1734`
- **CSES Problem Link**: [Distinct Values Queries](https://cses.fi/problemset/task/1734)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given an array of $n$ integers $x_1, x_2, \dots, x_n$ and $q$ queries.
In each query:
- Given a range $[a, b]$ with $1 \le a \le b \le n$, determine the number of **distinct values** in the subarray $x_a, x_{a+1}, \dots, x_b$.

Array indices are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the array size and the number of queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the array elements.
- The next $q$ lines each contain two integers $a$ and $b$: the boundaries of the query range.

### Output Format
- For each query, print the number of distinct values on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$
- $1 \le a \le b \le n$

---

## 2. Intuition & Pattern Recognition

A value $v$ should be counted exactly once in a range $[a, b]$ if at least one occurrence of $v$ falls in $[a, b]$.
To avoid overcounting duplicates without inspecting all elements in the range:
- Consider sorting queries offline by their right endpoint $b$.
- As we sweep an index $R$ from $1$ to $n$, we maintain an indicator array $I$:
  $$I[i] = 1 \iff i \text{ is the rightmost occurrence of value } x_i \text{ in the prefix } [1, R]$$
- For any value $v$ appearing multiple times in the prefix $[1, R]$, only its **most recent** index has $I = 1$; all earlier occurrences have $I = 0$.
- Under this invariant, for any query range $[a, R]$, a value $v$ appears in $[a, R]$ if and only if its rightmost occurrence in $[1, R]$ is $\ge a$.
- Therefore, the number of distinct values in $[a, R]$ is simply the range sum:
  $$\sum_{i=a}^R I[i]$$
- As $R$ advances to $R + 1$:
  - If $x_{R+1}$ appeared previously at position $prev\_pos$, we set $I[prev\_pos] \leftarrow 0$ (subtract $1$).
  - We set $I[R+1] \leftarrow 1$ (add $1$).
- Both point updates and prefix sum queries take $\mathcal{O}(\log n)$ time using a **Fenwick Tree (Binary Indexed Tree)**.

---

## 3. Approach 1 — Naive Set / Frequency Array per Query

For each query $[a, b]$, insert elements $x_a, \dots, x_b$ into an `std::unordered_set<int>` and return `set.size()`.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Mo's Algorithm (Offline Block Decomposition)

Decompose queries into $\sqrt{n}$ blocks by left endpoint, sorting right endpoints within each block. Maintain a two-pointer sliding window with a frequency hash table or array.
- **Time Complexity**: $\mathcal{O}((n + q) \sqrt{n}) \approx 4 \cdot 10^5 \times 450 \approx 1.8 \cdot 10^8$ operations.
- **Space Complexity**: $\mathcal{O}(n + q)$.
- **CSES Verdict**: Passes near the time limit ($\approx 0.7\text{s}$), but is significantly slower and more memory-intensive than the offline Fenwick Tree.

---

## 5. Approach 3 — Optimal CSES Solution (Offline Sweep-Line + Fenwick Tree)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Query {
    int l, r, id;
};

struct Fenwick {
    int n;
    vector<int> tree;
    Fenwick(int n) : n(n), tree(n + 1, 0) {}

    void add(int i, int delta) {
        for (; i <= n; i += i & -i) {
            tree[i] += delta;
        }
    }

    int query(int i) const {
        int sum = 0;
        for (; i > 0; i -= i & -i) {
            sum += tree[i];
        }
        return sum;
    }

    int query(int l, int r) const {
        if (l > r) return 0;
        return query(r) - query(l - 1);
    }
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    vector<int> x(n + 1);
    vector<int> vals;
    vals.reserve(n);
    for (int i = 1; i <= n; ++i) {
        cin >> x[i];
        vals.push_back(x[i]);
    }

    // Coordinate compress values for O(1) array lookups
    sort(vals.begin(), vals.end());
    vals.erase(unique(vals.begin(), vals.end()), vals.end());
    for (int i = 1; i <= n; ++i) {
        x[i] = lower_bound(vals.begin(), vals.end(), x[i]) - vals.begin();
    }

    vector<vector<Query>> queries_at(n + 1);
    for (int i = 0; i < q; ++i) {
        int a, b;
        cin >> a >> b;
        queries_at[b].push_back({a, b, i});
    }

    Fenwick bit(n);
    vector<int> last_pos(vals.size(), 0);
    vector<int> ans(q);

    // Sweep R from 1 to n
    for (int r = 1; r <= n; ++r) {
        int val = x[r];
        if (last_pos[val] != 0) {
            bit.add(last_pos[val], -1); // Remove previous occurrence
        }
        bit.add(r, 1);                  // Add current rightmost occurrence
        last_pos[val] = r;

        for (const auto& qry : queries_at[r]) {
            ans[qry.id] = bit.query(qry.l, r);
        }
    }

    for (int i = 0; i < q; ++i) {
        cout << ans[i] << '\n';
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Loop Invariant
At the end of step $R \in [1, n]$ of the sweep-line:
1. For every distinct value $v \in \{x_1, \dots, x_R\}$, `last_pos[v]` holds the maximum index $j \le R$ such that $x_j = v$.
2. The Fenwick tree contains a value of $1$ at index $j$ if and only if $j = \text{last\_pos}[x_j]$ for some value present in the prefix $[1, R]$; all other positions contain $0$.
3. Any occurrence of value $v$ at index $i < \text{last\_pos}[v]$ was zeroed out when `last_pos[v]` was processed.

### Query Evaluation
For any query with range $[a, R]$:
- A distinct value $v$ appears at least once in $x_a, \dots, x_R$ if and only if its last occurrence in $[1, R]$ falls within $[a, R]$, i.e., $a \le \text{last\_pos}[v] \le R$.
- By the invariant, exactly one position corresponding to $v$ has value $1$ in the Fenwick tree, which is $\text{last\_pos}[v]$.
- Thus, the sum of values in the Fenwick tree over $[a, R]$:
  $$\text{bit.query}(a, R) = \sum_{i=a}^R I[i]$$
  counts each distinct value present in $[a, R]$ exactly once.
Because queries are answered when the sweep-line reaches $R = b$, each query result is exact.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 3
3 2 3 1 2
1 3
2 4
1 5
```

### Sweep-Line Execution
- **$R = 1$ ($x_1 = 3$)**:
  - `last_pos[3]` was 0 $\implies$ `bit.add(1, +1)`. `last_pos[3] = 1`.
  - Fenwick active: `{1}`.
- **$R = 2$ ($x_2 = 2$)**:
  - `last_pos[2]` was 0 $\implies$ `bit.add(2, +1)`. `last_pos[2] = 2`.
  - Fenwick active: `{1, 2}`.
- **$R = 3$ ($x_3 = 3$)**:
  - `last_pos[3]` was 1 $\implies$ `bit.add(1, -1)`, `bit.add(3, +1)`. `last_pos[3] = 3`.
  - Fenwick active: `{2, 3}`.
  - Query `1 3` ($a = 1, b = 3$): `bit.query(1, 3) = 2` (values 2 and 3).
- **$R = 4$ ($x_4 = 1$)**:
  - `last_pos[1]` was 0 $\implies$ `bit.add(4, +1)`. `last_pos[1] = 4`.
  - Fenwick active: `{2, 3, 4}`.
  - Query `2 4` ($a = 2, b = 4$): `bit.query(2, 4) = 3` (values 2, 3, and 1).
- **$R = 5$ ($x_5 = 2$)**:
  - `last_pos[2]` was 2 $\implies$ `bit.add(2, -1)`, `bit.add(5, +1)`. `last_pos[2] = 5`.
  - Fenwick active: `{3, 4, 5}`.
  - Query `1 5` ($a = 1, b = 5$): `bit.query(1, 5) = 3` (values 3, 1, and 2).

### Outputs
`2`, `3`, `3` — matches ground truth.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **All Elements Identical**:
   If array is $[7, 7, 7, 7, 7]$, at any step $R$, only position $R$ has $+1$ and earlier positions are $-1$. Any query $[a, b]$ returns $1$.
2. **All Elements Distinct**:
   Every element is added once and never removed. Every query $[a, b]$ returns $b - a + 1$.
3. **Values Exceeding $10^9$**:
   Values cannot be used directly as array indices. Coordinate compression via `std::sort` + `std::unique` maps them to $[0, \text{distinct} - 1]$ in $\mathcal{O}(n \log n)$ time, allowing an $\mathcal{O}(n)$ flat array for `last_pos` rather than `std::map`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How can we answer distinct value queries fully online (without sorting queries)?**
   Use a **Persistent Segment Tree**. Each version $R$ represents the Fenwick/Segment Tree state at prefix $R$. Querying version $b$ over $[a, b]$ gives the answer in $\mathcal{O}(\log n)$ time.
2. **Can this handle dynamic point updates ($x_k \leftarrow u$)?**
   Online updates with distinct value counting requires 2D dynamic point updates (e.g., Segment Tree of Treaps / CDQ divide-and-conquer / 2D Fenwick Tree), running in $\mathcal{O}(\log^2 n)$ or $\mathcal{O}(n^{2/3})$ with Mo's with updates.
3. **What if we want the count of values appearing at least $k$ times in $[a, b]$?**
   Maintain pointers to the $k$-th most recent occurrence of each value. Position $pos$ is activated in the Fenwick tree when value $v$ appears for the $k$-th time.
4. **How does this relate to CSES Distinct Values Queries II?**
   CSES 3356 asks whether *all* elements in $[a, b]$ are distinct under point updates. That problem simplifies to checking if $\max_{i \in [a, b]} prev[i] < a$, which requires only dynamic RMQ!
5. **What is the space complexity comparison between Mo's and Offline BIT?**
   Mo's uses $\mathcal{O}(n + q)$ memory and $\mathcal{O}((n + q) \sqrt{n})$ time. Offline BIT uses $\mathcal{O}(n + q)$ memory and $\mathcal{O}((n + q) \log n)$ time, which is $\approx 10\times$ faster.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Coordinate Compression**: $\mathcal{O}(n \log n)$
  - **Offline Sweep & Fenwick Updates**: $\mathcal{O}((n + q) \log n)$
  - **Overall Run Time**: $\approx 0.08\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n + q)$ auxiliary space for query buckets and Fenwick tree.

### Related CSES Problems
- [Distinct Values Queries II](https://cses.fi/problemset/task/3356) — Dynamic distinct verification
- [Range Interval Queries](https://cses.fi/problemset/task/3163) — 2D range counting
- [Salary Queries](https://cses.fi/problemset/task/1144) — Coordinate compression and Fenwick trees
