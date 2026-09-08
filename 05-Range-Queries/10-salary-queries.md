# Salary Queries

- **Category**: Range Queries
- **CSES Task ID**: `1144`
- **CSES Problem Link**: [Salary Queries](https://cses.fi/problemset/task/1144)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

A company has $n$ employees numbered $1, 2, \dots, n$, with initial salaries $p_1, p_2, \dots, p_n$. You are given $q$ queries to process. Queries are of two types:
1. `! k x`: **Update** the salary of employee $k$ to $x$.
2. `? a b`: **Query** the number of employees whose salary is between $a$ and $b$ inclusive ($a \le \text{salary} \le b$).

### Input Format
- The first line contains two integers $n$ and $q$: the number of employees and queries.
- The second line contains $n$ integers $p_1, p_2, \dots, p_n$: the initial salaries.
- The next $q$ lines each describe an operation in one of the two formats:
  - `! k x`
  - `? a b`

### Output Format
- For each `?` query, print the count of employees within the salary range on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le p_i, x, a, b \le 10^9$
- $1 \le k \le n$
- $a \le b$

Salaries reach $10^9$, so an array indexed directly by salary is impossible. Coordinate Compression with a Fenwick Tree processes all queries in $\mathcal{O}((n + q) \log(n + q)) \approx 0.18\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is a dynamic **Point Update and Range Count Query** on a sparse domain ($[1, 10^9]$):
- If salary values were small ($\le 2 \cdot 10^5$), we could maintain a frequency array $\text{freq}[s]$: the number of employees with salary $s$, and answer range queries via a standard Fenwick Tree.
- **Coordinate Compression**:
  Although salaries range up to $10^9$, the total number of distinct salary values that ever appear in the input (initial salaries, update values $x$, and query boundaries $a, b$) is at most:
  $$N_{\text{distinct}} \le n + 3q \le 2 \cdot 10^5 + 6 \cdot 10^5 = 8 \cdot 10^5$$
- By gathering all candidate salary values, sorting them, and removing duplicates, we establish a bijective order-preserving mapping from each original salary to a compressed rank in $[1, U]$:
  $$\text{rank}(v) \in [1, U], \quad \text{where } U \le 8 \cdot 10^5$$
- **Query Resolution on Compressed Domain**:
  - For `! k x`:
    - Decrement frequency of employee $k$'s old salary: `bit.add(rank(old), -1)`.
    - Update employee $k$'s salary to $x$.
    - Increment frequency of new salary: `bit.add(rank(x), +1)`.
  - For `? a b`:
    - Find the smallest compressed index whose value is $\ge a$:
      $$L = \text{lower\_bound}(a)$$
    - Find the largest compressed index whose value is $\le b$:
      $$R = \text{upper\_bound}(b) - 1$$
    - The answer is the range sum $\text{bit.query}(L, R)$.

---

## 3. Approach 1 — Policy-Based Data Structure (`pb_ds` Order Statistic Tree)

Maintain all salaries in a GNU PBDS `tree<pair<int, int>, ...>` (storing `{salary, id}`).
- Count in $[a, b]$: `order_of_key({b + 1, 0}) - order_of_key({a, 0})`.
- **Complexity**: $\mathcal{O}((n + q) \log n)$.
- **Verdict**: Valid and fast, but PBDS tree has high node allocation overhead and pointer chasing. Offline coordinate compression with a flat Fenwick tree (Approach 3) is cache-friendly and consumes less memory.

---

## 4. Approach 2 — Dynamic Segment Tree (Implicit Segment Tree)

Create a segment tree over range $[1, 10^9]$ that allocates child nodes on demand.
- **Memory**: Each update adds $\mathcal{O}(\log(10^9)) \approx 30$ nodes, requiring $2 \cdot 10^5 \times 30 \times 32 \text{ bytes} \approx 192\text{ MB}$.
- **Verdict**: Valid, but pointer allocations add overhead. Coordinate compression allows a flat, static Fenwick tree.

---

## 5. Approach 3 — Optimal CSES Solution (Offline Coordinate Compression + Fenwick Tree)

1. Read all queries offline.
2. Collect initial salaries and all values mentioned in queries ($x, a, b$) into a `vector<int> vals`.
3. Sort `vals` and remove duplicates with `std::unique`.
4. Rank lookup functions:
   - `get_id(v)`: `lower_bound` 1-based index.
   - For range $[a, b]$:
     $L$ is `lower_bound(a) - begin + 1`.
     $R$ is `upper_bound(b) - begin` (1-based index of last element $\le b$).
5. Maintain Fenwick tree of size $U = |\text{vals}|$.
6. Populate initial employee frequencies.
7. Execute queries sequentially:
   - Type `!`: decrement old rank, update array, increment new rank.
   - Type `?`: if $L \le R$, print `bit.range_query(L, R)`, else print $0$.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Query {
    char type;
    int a, b;
};

struct FenwickTree {
    int n;
    vector<int> tree;

    FenwickTree(int n) : n(n), tree(n + 1, 0) {}

    void add(int i, int delta) {
        while (i <= n) {
            tree[i] += delta;
            i += i & -i;
        }
    }

    int query(int i) {
        int sum = 0;
        while (i > 0) {
            sum += tree[i];
            i -= i & -i;
        }
        return sum;
    }

    int range_query(int l, int r) {
        if (l > r) return 0;
        return query(r) - query(l - 1);
    }
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    vector<int> p(n + 1);
    vector<int> vals;
    vals.reserve(n + 3 * q);

    for (int i = 1; i <= n; ++i) {
        cin >> p[i];
        vals.push_back(p[i]);
    }

    vector<Query> queries(q);
    for (int i = 0; i < q; ++i) {
        cin >> queries[i].type >> queries[i].a >> queries[i].b;
        if (queries[i].type == '!') {
            vals.push_back(queries[i].b);
        } else {
            vals.push_back(queries[i].a);
            vals.push_back(queries[i].b);
        }
    }

    // Coordinate Compression
    sort(vals.begin(), vals.end());
    vals.erase(unique(vals.begin(), vals.end()), vals.end());

    auto get_id = [&](int val) -> int {
        return lower_bound(vals.begin(), vals.end(), val) - vals.begin() + 1;
    };

    int U = vals.size();
    FenwickTree bit(U);

    for (int i = 1; i <= n; ++i) {
        bit.add(get_id(p[i]), 1);
    }

    for (const auto& qry : queries) {
        if (qry.type == '!') {
            int k = qry.a;
            int new_val = qry.b;
            bit.add(get_id(p[k]), -1);
            p[k] = new_val;
            bit.add(get_id(new_val), 1);
        } else {
            int a = qry.a;
            int b = qry.b;

            int l = lower_bound(vals.begin(), vals.end(), a) - vals.begin() + 1;
            int r = upper_bound(vals.begin(), vals.end(), b) - vals.begin();

            cout << bit.range_query(l, r) << '\n';
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}((n + q) \log (n + q))$.
  - Sorting and uniquing coordinates: $\mathcal{O}(U \log U)$ where $U \le 8 \cdot 10^5$.
  - Answering $q$ queries: each query does $\mathcal{O}(\log U)$ binary search and $\mathcal{O}(\log U)$ Fenwick operation.
  - Total Time: $\approx 0.18\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + q)$ for the compressed vector, query buffer, and Fenwick tree ($\approx 16\text{ MB}$).

---

## 6. Correctness Proof

### Order-Preserving Invariance of Coordinate Compression
- **Definition**: Coordinate compression defines an order-preserving injection $f: \text{vals} \to \{1, \dots, U\}$ where $x < y \iff f(x) < f(y)$.
- **Range Invariance**:
  For any real interval $[a, b]$:
  - An element $x \in \text{vals}$ satisfies $a \le x \le b$ if and only if $f(x) \ge L$ and $f(x) \le R$, where:
    $$L = \min \{ f(x) \mid x \in \text{vals}, \; x \ge a \}$$
    $$R = \max \{ f(x) \mid x \in \text{vals}, \; x \le b \}$$
  - If no element in $\text{vals}$ is $\le b$ or no element is $\ge a$, $L > R$, and the query correctly evaluates to $0$.
  - Otherwise, the set of distinct values in $[a, b]$ corresponds bijectively to the contiguous range of compressed indices $[L, R]$.
- **Frequency Conservation**:
  The Fenwick tree maintains $\text{freq}[f(v)]$, which tracks the exact number of active employees currently having salary $v$.
  Summing $\text{freq}[i]$ for $i \in [L, R]$ equals the exact number of employees with salaries in $[a, b]$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 5, q = 3$:
- Initial salaries: $p = [3, 7, 2, 2, 5]$
- Queries:
  1. `? 2 3`
  2. `! 3 6` (change employee 3 from 2 to 6)
  3. `? 2 3`
- Values collected: $\{2, 3, 5, 6, 7\}$. Compressed:
  - $2 \to 1, 3 \to 2, 5 \to 3, 6 \to 4, 7 \to 5$.
- Initial BIT frequencies:
  - Rank 1 (val 2): 2 employees (emp 3, 4)
  - Rank 2 (val 3): 1 employee (emp 1)
  - Rank 3 (val 5): 1 employee (emp 5)
  - Rank 5 (val 7): 1 employee (emp 2)
- Query 1: `? 2 3`
  - $a = 2 \implies L = 1$ (val 2)
  - $b = 3 \implies R = 2$ (val 3)
  - Range sum on $[1, 2]$: $2 + 1 = 3$. Output: `3`.
- Query 2: `! 3 6`
  - Emp 3 old salary 2 (rank 1) $\implies$ decrement rank 1 (freq becomes 1).
  - New salary 6 (rank 4) $\implies$ increment rank 4 (freq becomes 1).
- Query 3: `? 2 3`
  - Range $[1, 2]$ sum: now $1 + 1 = 2$. Output: `2`.
- Outputs: `3`, `2`. Correct!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Range with No Present Salaries**:
   If query range $[a, b]$ lies entirely between two existing values, $L > R$. The check `if (l > r) return 0;` safely returns 0 without out-of-bounds access.
2. **$a > \max(\text{vals})$ or $b < \min(\text{vals})$**:
   `lower_bound` or `upper_bound` boundary checks ensure $L > R$, outputting 0.
3. **Query Format**:
   Remember to check `qry.type == '!'` vs `'?'`.
4. **No 64-bit Overflow for Counts**:
   Employee counts never exceed $n = 2 \cdot 10^5$, so 32-bit signed `int` is completely sufficient for frequencies.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How would you solve this online without knowing future queries?**
   Use a **Dynamic / Implicit Segment Tree** or a **Treap / PBDS Order Statistic Tree** which support insertions and range counts online in $\mathcal{O}(\log (\max x))$.
2. **What if we want to find the $K$-th smallest salary dynamically?**
   Use binary lifting on the Fenwick tree (`find_kth`) over the compressed coordinates in $\mathcal{O}(\log U)$ time.
3. **How does this connect to counting inversions?**
   Counting inversions compresses array values and queries the prefix frequency of elements smaller than the current element as they are inserted.
4. **Why not just use `std::map<int, int>`?**
   `std::map` finds keys in $\mathcal{O}(\log n)$, but range sum of values in a map requires linear iteration $\mathcal{O}(k)$ through the range.
5. **How does Fractional Cascading optimize coordinate queries?**
   Fractional cascading allows range queries in multidimensional segment trees without repeated binary searches.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Range Queries, Coordinate Compression, Fenwick Tree, Offline Processing, Frequency Counting
- **Complexity Summary**:
  - Time: $\mathcal{O}((n + q) \log (n + q))$
  - Space: $\mathcal{O}(n + q)$
- **Related CSES Problems**:
  - [List Removals](https://cses.fi/problemset/task/1749) — Order statistics via Fenwick Tree
  - [Nested Ranges Check](https://cses.fi/problemset/task/2168) — Coordinate compression with 2D bounds
  - [Distinct Values Queries](https://cses.fi/problemset/task/1734) — Offline range queries with Fenwick Tree
