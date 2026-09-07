# Josephus Problem II (CSES Task 2163 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 2163 - Josephus Problem II](https://cses.fi/problemset/task/2163)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: There are $n$ children numbered $1, 2, \dots, n$ standing in a circle. During the game, repeatedly $k$ children are skipped and the next child is removed from the circle. Find the complete elimination order.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $0 \le k \le 10^9$.

---

## 1. Problem, Restated

Given $n$ people arranged circularly with labels $1 \dots n$ and a skip parameter $k$:
Starting from the first person, advance $k$ steps along the active survivors (wrapping around modulo the number of currently remaining people), eliminate the person landed on, and repeat until all $n$ people are eliminated.
Output the sequence of eliminated people.

**Input**: A single line containing two integers $n$ and $k$ ($1 \le n \le 2 \cdot 10^5$, $0 \le k \le 10^9$).  
**Output**: Print $n$ space-separated integers representing the elimination sequence.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Order Statistics Tree / Policy-Based Data Structure (PBDS) / Fenwick Tree with Binary Lifting / Modular Arithmetic.
- **Aha! Insight**:
  - In Josephus Problem I, $k = 1$ enabled an $\mathcal{O}(n)$ round-halving approach.
  - Here, $k$ can be up to $10^9$, so people can wrap around the circle millions of times in a single step!
  - Let $S$ be the current number of remaining people.
  - If the previous elimination occurred at 0-based index `idx` (relative to the remaining list of survivors):
    $$\text{next\_idx} = (\text{idx} + k) \bmod S$$
  - Once `next_idx` is calculated, we must:
    1. Locate the person currently residing at 0-based rank `next_idx` among all active survivors.
    2. Print that person's label.
    3. Remove that person from the collection of survivors.
  - Standard C++ STL containers do not support both $\mathcal{O}(\log n)$ rank-lookup and $\mathcal{O}(\log n)$ deletion simultaneously.
  - However, GNU C++ provides the **Policy-Based Data Structure (PBDS) `tree`** (often called `ordered_set`):
    - `find_by_order(k)`: returns an iterator to the $k$-th smallest element in $\mathcal{O}(\log n)$ time!
    - `erase(it)`: removes the element in $\mathcal{O}(\log n)$ time!
  - With PBDS `ordered_set`, each elimination takes $\mathcal{O}(\log n)$, yielding $\mathcal{O}(n \log n)$ total time.
- **Signal**: Any problem requiring dynamic rank queries ($k$-th element) with dynamic insertions or deletions is solved instantly with PBDS `ordered_set` or a Fenwick Tree.

---

## 3. Approach 1 — Naive / Baseline (`std::vector::erase`)

Maintain an array of active children, computing `idx = (idx + k) % current_size` and calling `a.erase(a.begin() + idx)`.
Shifting elements takes $\mathcal{O}(S)$ per elimination, resulting in $\mathcal{O}(n^2) = 4 \cdot 10^{10}$ operations $\implies$ TLE.

---

## 4. Approach 2 — Intermediate (Policy-Based Data Structure `ordered_set`)

In GCC on Linux/CSES, GNU C++ provides the Policy-Based Data Structure `tree` (`ordered_set`), supporting `find_by_order(k)` in $\mathcal{O}(\log n)$ time.
While compact, it relies on compiler-specific non-standard headers (`<ext/pb_ds/...>`), which are unavailable on standard Clang/macOS without GCC toolchains. A Fenwick Tree with Binary Lifting (Approach 3) is 100% portable standard C++ and runs faster due to contiguous memory layout.

---

## 5. Approach 3 — Optimal CSES Solution (Fenwick Tree with Binary Lifting in $\mathcal{O}(\log n)$)

### Idea
1. Maintain a Fenwick Tree (Binary Indexed Tree) of size $n$, where each position $i \in [1, n]$ initially has value $1$ (representing that person $i$ is active).
2. The prefix sum in the BIT represents the count of active people up to index $i$.
3. At each step with remaining size $S$:
   - Compute `idx = (idx + k) % S` (0-based rank among remaining people).
   - Find the 1-based index $p$ whose prefix sum is `idx + 1`.
   - Instead of binary searching on the BIT ($\mathcal{O}(\log^2 n)$), we use **Binary Lifting on the Fenwick Tree powers of 2** in strictly $\mathcal{O}(\log n)$ time!
   - Output person $p$, and remove them by adding $-1$ to position $p$ in the BIT: `update(p, -1)`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>

using namespace std;

int n;
vector<int> bit;

void update(int idx, int val) {
    for (; idx <= n; idx += idx & -idx) {
        bit[idx] += val;
    }
}

// Binary lifting on Fenwick Tree: finds smallest index with prefix sum >= target
int find_kth(int target) {
    int idx = 0;
    // Largest power of 2 <= n (for n <= 200000, 1 << 17 = 131072)
    for (int i = 1 << 17; i > 0; i >>= 1) {
        if (idx + i <= n && bit[idx + i] < target) {
            idx += i;
            target -= bit[idx];
        }
    }
    return idx + 1;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    long long k;
    if (!(cin >> n >> k)) return 0;

    bit.assign(n + 1, 0);
    for (int i = 1; i <= n; ++i) {
        update(i, 1);
    }

    int idx = 0;
    for (int size = n; size >= 1; --size) {
        idx = (idx + k) % size;
        int person = find_kth(idx + 1);
        cout << person << (size == 1 ? '\n' : ' ');
        update(person, -1);
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**:
  - Tree initialization: $n$ updates take $\mathcal{O}(n \log n)$ (or $\mathcal{O}(n)$ using linear construction).
  - Queries: for each of the $n$ eliminations, `find_kth` executes 18 bitwise loop iterations ($\mathcal{O}(\log n)$), and `update` takes $\mathcal{O}(\log n)$.
  - Total Time: strictly $\mathcal{O}(n \log n)$. For $n = 2 \cdot 10^5$, total operations $\approx 2 \cdot 10^5 \times 18 \times 2 \approx 7.2 \times 10^6$, executing in $\approx 0.06$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ flat integer array memory ($2 \cdot 10^5 \times 4$ bytes $\approx 800$ KB), vastly superior to tree pointer overhead.

---

## 6. Correctness Proof

1. **Rank Invariant**:
   At the start of each elimination step, let the $S$ active survivors in cyclic order be $x_0, x_1, \dots, x_{S-1}$.
   By definition of the game, the scan resumes from the position immediately following the previous elimination (which currently sits at 0-based rank `idx`).
   Advancing $k$ steps in a circular list of length $S$ lands at rank:
   $$\text{target} = (\text{idx} + k) \bmod S$$
2. **Order Statistics Correctness**:
   `find_by_order(target)` returns the element with exactly `target` elements smaller than it in the set, corresponding precisely to the 0-indexed `target`-th survivor.
3. **Index Preservation After Deletion**:
   When the element at index `target` is erased, all subsequent elements shift left by 1.
   Therefore, the element immediately following the eliminated person now resides precisely at index `target`!
   Hence, setting `idx = target` correctly prepares the starting pointer for the next iteration without any adjustment. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 7, k = 2$.
Initial set: `{1, 2, 3, 4, 5, 6, 7}`, `idx = 0`.

- **Step 1 ($S = 7$)**:
  - `idx = (0 + 2) % 7 = 2`.
  - `find_by_order(2)` $\implies$ **3**.
  - Erase 3. Remaining: `{1, 2, 4, 5, 6, 7}`.
- **Step 2 ($S = 6$)**:
  - `idx = (2 + 2) % 6 = 4`.
  - `find_by_order(4)` $\implies$ **6**.
  - Erase 6. Remaining: `{1, 2, 4, 5, 7}`.
- **Step 3 ($S = 5$)**:
  - `idx = (4 + 2) % 5 = 1`.
  - `find_by_order(1)` $\implies$ **2**.
  - Erase 2. Remaining: `{1, 4, 5, 7}`.
- **Step 4 ($S = 4$)**:
  - `idx = (1 + 2) % 4 = 3`.
  - `find_by_order(3)` $\implies$ **7**.
  - Erase 7. Remaining: `{1, 4, 5}`.
- **Step 5 ($S = 3$)**:
  - `idx = (3 + 2) % 3 = 2`.
  - `find_by_order(2)` $\implies$ **5**.
  - Erase 5. Remaining: `{1, 4}`.
- **Step 6 ($S = 2$)**:
  - `idx = (2 + 2) % 2 = 0`.
  - `find_by_order(0)` $\implies$ **1**.
  - Erase 1. Remaining: `{4}`.
- **Step 7 ($S = 1$)**:
  - `idx = (0 + 2) % 1 = 0`.
  - `find_by_order(0)` $\implies$ **4**.

Output: `3 6 2 7 5 1 4`. Exactly matches the CSES example!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$k = 0$**: `idx = (idx + 0) % S = idx`. Eliminates the current person at each step, producing `1 2 3 ... n`.
- **Large $k$ ($k \le 10^9$)**: $k$ is up to $10^9$, while `idx` is up to $2 \cdot 10^5$.
  `idx + k` can reach $10^9 + 2 \cdot 10^5$, which fits inside signed 32-bit `int`, but using `long long` for $k$ is standard practice to prevent overflow.
- **Single person ($n = 1$)**: Loop runs once, prints `1`.
- **PBDS Header**: PBDS is standard in GCC/Clang on all competitive programming platforms (CSES, Codeforces, AtCoder).

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How to implement this with a Fenwick Tree in strictly $\mathcal{O}(n \log n)$?**
   - Maintain BIT of size $n$ initialized to 1. To find the $k$-th element, use binary lifting directly on the BIT powers of 2 (testing bits $2^{17}, 2^{16}, \dots, 1$) in $\mathcal{O}(\log n)$ without binary search.
2. **What if elements also have insertion operations interleaved?**
   - PBDS `ordered_set` supports `s.insert(val)` in $\mathcal{O}(\log n)$ while preserving order statistics.
3. **What is the inverse operation `order_of_key(x)` in PBDS?**
   - `s.order_of_key(x)` returns the number of strictly smaller elements in the set (the 0-based rank of $x$).
4. **How to make PBDS support duplicate keys (multiset)?**
   - Use `pair<int, int>` as the value type: `tree<pair<int, int>, null_type, ...>` where the second element is a unique ID.
5. **Why can't standard `std::set` do this?**
   - Standard `std::set` does not store subtree sizes, so advancing an iterator with `std::advance(it, k)` takes $\mathcal{O}(k)$ time, degenerating to $\mathcal{O}(n^2)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: PBDS, Ordered Set, Segment Tree, Binary Lifting, Josephus.
- **Time Complexity**: $\mathcal{O}(n \log n)$ optimal time.
- **Space Complexity**: $\mathcal{O}(n)$ tree storage.

### Related CSES Tasks
- [CSES 2162 - Josephus Problem I](https://cses.fi/problemset/task/2162): Unit skip size solved in linear time.
- [CSES 2168 - Nested Ranges Check](https://cses.fi/problemset/task/2168): 2D interval dominance counting.
- [CSES 2169 - Nested Ranges Count](https://cses.fi/problemset/task/2169): Counting nested ranges via PBDS.
