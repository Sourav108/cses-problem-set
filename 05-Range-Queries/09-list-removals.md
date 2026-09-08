# List Removals

- **Category**: Range Queries
- **CSES Task ID**: `1749`
- **CSES Problem Link**: [List Removals](https://cses.fi/problemset/task/1749)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

You are given a list consisting of $n$ integers. Then, there are $n$ removal operations. In each step, you are given an integer $p_i$, meaning you must **remove the element at position $p_i$ in the current list** (1-indexed) and print its value.

As elements are removed, the list shrinks, and the indices of all subsequent elements shift left accordingly.

### Input Format
- The first line contains an integer $n$: the initial list size.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the list elements.
- The third line contains $n$ integers $p_1, p_2, \dots, p_n$: the positions of the elements to be removed.

### Output Format
- Print $n$ integers separated by spaces: the removed elements in the order of their removal.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$
- $1 \le p_i \le \text{current list size}$

With $n = 2 \cdot 10^5$, removing $n$ elements dynamically using Fenwick Tree Binary Lifting or a Segment Tree takes $\mathcal{O}(n \log n) \approx 0.06\text{s}$.

---

## 2. Intuition & Pattern Recognition

Simulating deletions in a dynamic array (`std::vector::erase`) takes $\mathcal{O}(n)$ per removal due to shifting elements, leading to $\mathcal{O}(n^2) \approx 4 \cdot 10^{10}$ operations (TLE).
- **Presence Indicator Array**:
  Instead of physically shifting elements, keep all $n$ original elements fixed at indices $1 \dots n$.
  Maintain an indicator array:
  $$\text{present}[i] = \begin{cases} 1 & \text{if element } i \text{ has not been removed} \\ 0 & \text{if element } i \text{ has been removed} \end{cases}$$
- **Prefix Sum Mapping**:
  The position of an element in the *current* contracted list is precisely the number of active elements preceding it plus one:
  $$\text{current\_rank}(i) = \sum_{j=1}^i \text{present}[j]$$
- **Finding the $p$-th Active Element**:
  The $p$-th active element corresponds to the smallest original index $i$ such that:
  $$\sum_{j=1}^i \text{present}[j] = p$$
- **Binary Lifting on Fenwick Tree**:
  Because all $\text{present}[j] \ge 0$, prefix sums are monotonically increasing.
  Instead of binary search + Fenwick query in $\mathcal{O}(\log^2 n)$, we can **binary lift directly on the powers of 2** in the Fenwick tree in strictly **$\mathcal{O}(\log n)$ time**:
  - Maintain accumulator `idx = 0`.
  - For powers of two $2^{17}, 2^{16}, \dots, 1$:
    - If `idx + step <= n` and `tree[idx + step] < p`:
      - Advance: `idx += step`, and subtract `p -= tree[idx]`.
  - The target index is `target = idx + 1`!
  - Print $x[\text{target}]$, and mark it removed: `bit.add(target, -1)`.

---

## 3. Approach 1 — Naive Vector Erase

Use `std::vector<int>` and call `.erase(v.begin() + p - 1)` $n$ times.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Policy-Based Data Structure (`pb_ds` Order Statistic Tree)

Use GNU C++ `__gnu_pbds::tree` with `find_by_order(p - 1)` and `erase()`.
- **Complexity**: $\mathcal{O}(n \log n)$.
- **Verdict**: Correct and fast, but relies on compiler-specific PBDS extensions and red-black tree pointer overhead. Approach 3 uses standard C++ with a flat Fenwick Tree that is $3\times$ faster.

---

## 5. Approach 3 — Optimal CSES Solution (Fenwick Tree with Binary Lifting)

1. Store original values in `x[n + 1]`.
2. Initialize Fenwick tree `tree[n + 1]` with $1$ at each position $1 \dots n$.
   Linear $\mathcal{O}(n)$ build: `tree[i] += 1`, propagate to parent.
3. For each query $p$:
   - Find target index in $\mathcal{O}(\log n)$ via binary lifting:
     ```cpp
     int idx = 0;
     for (int step = 1 << 17; step > 0; step >>= 1) {
         if (idx + step <= n && tree[idx + step] < p) {
             idx += step;
             p -= tree[idx];
         }
     }
     int target = idx + 1;
     ```
   - Output $x[\text{target}]$.
   - Update `bit.add(target, -1)`.

```cpp
#include <iostream>
#include <vector>

using namespace std;

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

    // Binary lift directly on BIT nodes in O(log n) to find k-th active element
    int find_kth(int k) {
        int idx = 0;
        for (int step = 1 << 17; step > 0; step >>= 1) {
            if (idx + step <= n && tree[idx + step] < k) {
                idx += step;
                k -= tree[idx];
            }
        }
        return idx + 1;
    }
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> x(n + 1);
    for (int i = 1; i <= n; ++i) {
        cin >> x[i];
    }

    FenwickTree bit(n);
    for (int i = 1; i <= n; ++i) {
        bit.add(i, 1);
    }

    for (int i = 0; i < n; ++i) {
        int p;
        cin >> p;

        int orig_idx = bit.find_kth(p);
        cout << x[orig_idx] << (i + 1 == n ? '\n' : ' ');

        bit.add(orig_idx, -1);
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**:
  - Build: $\mathcal{O}(n \log n)$.
  - Each of the $n$ removals: `find_kth` takes 18 iterations, `add` takes 18 iterations $\implies \mathcal{O}(\log n)$.
  - Total Time: $\mathcal{O}(n \log n) \approx 2 \cdot 10^5 \times 18 \approx 3.6 \cdot 10^6$ operations $\approx 0.06\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ for array $x$ and BIT ($\approx 1.6\text{ MB}$).

---

## 6. Correctness Proof

### Monotonicity & Binary Search on Dyadic BIT Nodes
- **Theorem**: `find_kth(k)` returns the exact smallest index $i$ such that $\sum_{j=1}^i \text{present}[j] = k$.
- **Proof**:
  1. In a Fenwick tree, `tree[idx + step]` stores the sum of elements in $(idx, idx + step]$ whenever `step` is a power of 2 aligned with the binary structure.
  2. If `tree[idx + step] < k`, the interval $(idx, idx + step]$ does not contain enough active elements to satisfy rank $k$.
     Thus, the target element lies strictly to the right of $idx + step$.
     We safely advance $idx \leftarrow idx + step$ and reduce $k$ by the number of active elements in that interval: $k \leftarrow k - \text{tree}[idx]$.
  3. If `tree[idx + step] >= k`, the target element lies inside the interval $(idx, idx + step]$.
     We keep $idx$ unchanged and test smaller powers of 2.
  4. After all powers of 2 down to $2^0 = 1$ are evaluated, $idx$ is the largest index such that $\text{query}(idx) < k$.
  5. Because elements take values in $\{0, 1\}$, the very next element at $idx + 1$ must have $\text{present}[idx + 1] = 1$ and satisfies $\text{query}(idx + 1) = k$.
  6. Thus $idx + 1$ is the exact $k$-th active element. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider array $x = [2, 6, 1, 4, 2]$ ($n = 5$):
- Initially, all 5 elements are active: $[2, 6, 1, 4, 2]$.
- Remove at position 3:
  - `find_kth(3)`: returns index 3 (value 1).
  - List becomes: $[2, 6, 4, 2]$. Element 3 marked inactive.
  - Output: `1`.
- Remove at position 1:
  - `find_kth(1)`: returns index 1 (value 2).
  - List becomes: $[6, 4, 2]$. Element 1 marked inactive.
  - Output: `2`.
- Remove at position 3:
  - In current list $[6, 4, 2]$, 3rd element is 2 (original index 5).
  - `find_kth(3)`: returns index 5 (value 2).
  - Output: `2`.
- Remove at position 1:
  - In current list $[6, 4]$, 1st element is 6 (original index 2).
  - Output: `6`.
- Remove at position 1:
  - Remaining element is 4 (original index 4).
  - Output: `4`.
- Total output: `1 2 2 6 4`. Exact match!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Power of 2 for Binary Lifting**:
   $2^{17} = 131072 < 2 \cdot 10^5 < 2^{18} = 262144$. Using `step = 1 << 17` covers up to $131072 \times 2 = 262144 \ge n$.
2. **Boundary Check `idx + step <= n`**:
   Must check that candidate index does not exceed $n$ before indexing `tree[idx + step]`.
3. **Array Values**:
   Elements $x_i$ can be up to $10^9$. The tree only stores indicators ($0$ or $1$), so the Fenwick tree values fit comfortably in 32-bit `int`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How can this be solved using a Segment Tree instead?**
   Each segment tree node stores the count of active elements in its interval. To find the $k$-th element: if `left_child >= k`, go left; else go right with $k - \text{left\_child}$. Runs in $\mathcal{O}(\log n)$.
2. **What if we also need to INSERT elements at arbitrary positions?**
   Fenwick and static Segment Trees cannot support insertions into middle of list. Use a **Treap (Cartesian Tree)**, **Splay Tree**, or **Rope** in $\mathcal{O}(\log n)$.
3. **How does this relate to Josephus Problem II?**
   In Josephus Problem II, people are eliminated every $k$ steps in a circle. The elimination index is $(pos + k - 1) \bmod \text{current\_size}$, which is precisely solved using this exact $k$-th element removal technique in $\mathcal{O}(n \log n)$!
4. **Why is Fenwick binary lifting faster than Segment Tree descent?**
   The Fenwick tree binary lifting loop is a simple 18-iteration `for` loop with no recursion, branch-free conditions, and contiguous memory access.
5. **How can this be extended to finding the median dynamically?**
   Query the $(\lceil N/2 \rceil)$-th element using `find_kth` in $\mathcal{O}(\log n)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Range Queries, Fenwick Tree, Binary Lifting, Order Statistics, Point Update
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \log n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - [Josephus Problem II](https://cses.fi/problemset/task/1982) — Cyclic order statistic removals
  - [Hotel Queries](https://cses.fi/problemset/task/1143) — Binary search on Segment Tree
  - [Salary Queries](https://cses.fi/problemset/task/1144) — Frequency tree queries
