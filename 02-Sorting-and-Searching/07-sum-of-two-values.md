# Sum of Two Values (CSES Task 1640 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1640 - Sum of Two Values](https://cses.fi/problemset/task/1640)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: You are given an array of $n$ integers and a target sum $x$. Find two distinct positions whose values sum to $x$. If multiple solutions exist, print any. If no solution exists, print `IMPOSSIBLE`.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le x, a_i \le 10^9$.

---

## 1. Problem, Restated

Given an array $a = [a_1, a_2, \dots, a_n]$ and a target integer $x$:
Find two distinct 1-based indices $i$ and $j$ ($1 \le i < j \le n$) such that:
$$a_i + a_j = x$$
If such indices exist, print them. Otherwise, print `IMPOSSIBLE`.

**Input**:
- First line: two integers $n$ and $x$.
- Second line: $n$ space-separated integers $a_1, \dots, a_n$.

**Output**:
- Print two distinct 1-based indices, or `IMPOSSIBLE`.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Two-Sum / Two Pointers / Coordinate-Index Tracking / Binary Search.
- **Aha! Insight**:
  - We need the 1-based original positions, but sorting elements allows efficient target searching.
  - Store each element as a pair: `(value, original_1_based_index)`.
  - Sort the array of pairs primarily by `value` in non-decreasing order.
  - After sorting, apply the classic **Two Pointers** technique:
    - Pointer $L = 0$ (smallest value) and $R = n - 1$ (largest value).
    - If $a[L].\text{val} + a[R].\text{val} == x$: a valid pair is found! Print their original indices and terminate.
    - If $a[L].\text{val} + a[R].\text{val} < x$: the sum is too small. Because $R$ is already at the maximum available element, only incrementing $L$ can increase the sum.
    - If $a[L].\text{val} + a[R].\text{val} > x$: the sum is too large. Decrement $R$.
  - Two pointers runs in $\mathcal{O}(n)$ after sorting, and requires zero dynamic hashing, making it completely immune to adversarial hash-collision tests.
- **Signal**: "Find two elements summing to $X$" is the fundamental 2-Sum problem.

---

## 3. Approach 1 — Naive / Baseline (Quadratic Nested Loops)

Check all $\frac{n(n-1)}{2}$ pairs $(i, j)$ with $i < j$.
For $n = 2 \cdot 10^5$, $\frac{n^2}{2} \approx 2 \cdot 10^{10}$ operations $\implies$ TLE.

---

## 4. Approach 2 — Intermediate (`std::map` or Hash Map)

Iterate through $a_i$, checking if $x - a_i$ exists in a hash map.
While average $\mathcal{O}(n)$, standard `std::unordered_map` has $\mathcal{O}(n^2)$ worst-case due to hash collision vulnerabilities on CSES tests. Sorting with two pointers (Approach 3) is deterministic, faster, and cache-optimal.

---

## 5. Approach 3 — Optimal CSES Solution (Sorted Two Pointers on Indexed Pairs)

### Idea
1. Store elements as `vector<pair<int, int>> a` with `(value, index + 1)`.
2. Sort `a` using `std::sort`.
3. Set `L = 0, R = n - 1`.
4. While `L < R`:
   - `sum = a[L].first + a[R].first`
   - If `sum == x`, print `a[L].second << " " << a[R].second` and exit.
   - Else if `sum < x`, `L++`.
   - Else, `R--`.
5. If loop terminates without a match, print `IMPOSSIBLE`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    long long x;
    if (!(cin >> n >> x)) return 0;

    // Store (value, 1-based index)
    vector<pair<long long, int>> a(n);
    for (int i = 0; i < n; ++i) {
        cin >> a[i].first;
        a[i].second = i + 1;
    }

    sort(a.begin(), a.end());

    int l = 0;
    int r = n - 1;

    while (l < r) {
        long long sum = a[l].first + a[r].first;
        if (sum == x) {
            cout << a[l].second << ' ' << a[r].second << '\n';
            return 0;
        } else if (sum < x) {
            l++;
        } else {
            r--;
        }
    }

    cout << "IMPOSSIBLE\n";
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$ to sort the pairs. The two-pointer search runs in strictly $\mathcal{O}(n)$ time as $L$ increments or $R$ decrements in each step. For $n = 2 \cdot 10^5$, total operations $\approx 3.6 \times 10^6$, running in $\approx 0.06$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ memory to store the pairs ($2 \cdot 10^5 \times 16$ bytes $\approx 3.2$ MB).

---

## 6. Correctness Proof

**Theorem**: If there exists any pair of indices $(i, j)$ with $i \ne j$ such that $a_i + a_j = x$, the two-pointer search is guaranteed to find it.

**Proof by Invariant**:
1. Suppose a solution exists. Let $(L^*, R^*)$ be the indices in the sorted array such that $L^* < R^*$ and $a[L^*].\text{val} + a[R^*].\text{val} = x$.
2. We maintain the invariant: $L \le L^*$ and $R \ge R^*$ (the target pair is always contained within the active window $[L, R]$).
   - Initially, $L = 0 \le L^*$ and $R = n - 1 \ge R^*$, so the invariant holds.
   - Suppose at some state $L < L^*$ and $R = R^*$.
     Then $a[L].\text{val} \le a[L^*].\text{val}$, so $a[L].\text{val} + a[R].\text{val} \le a[L^*].\text{val} + a[R^*].\text{val} = x$.
     - If the sum equals $x$, the algorithm finds a valid pair immediately.
     - If the sum is strictly $< x$, the algorithm increments $L \to L + 1 \le L^*$. The invariant is maintained! $R$ is never decremented past $R^*$.
   - By symmetric logic, if $L = L^*$ and $R > R^*$, the sum is $> x$, so $R$ decrements without crossing $R^*$.
3. Since $L$ strictly increases and $R$ strictly decreases, the algorithm must eventually reach $L = L^*$ and $R = R^*$ unless another valid solution is encountered earlier.
4. Hence, the algorithm never misses a valid solution. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 4, x = 8$.
$a = [2, 7, 5, 1]$.
Indexed pairs: `[(2, 1), (7, 2), (5, 3), (1, 4)]`.

Sorted pairs:
- `a[0] = (1, 4)`
- `a[1] = (2, 1)`
- `a[2] = (5, 3)`
- `a[3] = (7, 2)`

Pointers trace:
- Step 1: $L = 0 (1), R = 3 (7)$.
  $\text{sum} = 1 + 7 = 8 == x$!
  Valid pair found!
- Print original indices: `a[0].second` and `a[3].second` $\implies$ `4 2`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Single element array ($n = 1$)**: Loop condition `l < r` fails immediately ($0 < 0$ false), correctly outputs `IMPOSSIBLE`.
- **Distinct positions requirement**: Because the loop enforces $L < R$, the same element can never be used twice.
- **Identical values summing to $x$ (e.g. $x = 8$, array has two $4$s)**: Because pairs preserve original distinct 1-based indices, both $4$s are adjacent in the sorted array, properly matching when $L$ and $R$ converge on them.
- **64-bit Integer Bounds**: $a_i \le 10^9$, so $a_i + a_j \le 2 \cdot 10^9$, fitting inside 32-bit `int`. Using `long long` for $x$ and `sum` avoids any overflow pitfalls.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How to solve Sum of Three Values ($a_i + a_j + a_k = x$)?**
   - Fix the first element $a_i$ in $\mathcal{O}(n)$, then run Two Pointers on the remaining elements for target $x - a_i$, running in $\mathcal{O}(n^2)$ total time (CSES 1641).
2. **How to solve Sum of Four Values?**
   - Store all $\mathcal{O}(n^2)$ pairwise sums in a hash table or sorted array, reducing the problem to 2-Sum in $\mathcal{O}(n^2)$ time (CSES 1642).
3. **How many total pairs sum to $x$?**
   - When $a[L] + a[R] == x$, count duplicates of $a[L]$ and $a[R]$ to add their product to the total count.
4. **What if the array was already sorted?**
   - Two pointers runs in strictly linear $\mathcal{O}(n)$ time with $\mathcal{O}(1)$ space.
5. **Why is Two Pointers preferred over `unordered_map` in C++ contests?**
   - Codeforces and CSES problem sets include custom test cases engineered to produce hash collisions in `std::unordered_map` causing $\mathcal{O}(n^2)$ performance. Two Pointers is 100% deterministic.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Two Pointers, Sorting, Binary Search, 2-Sum.
- **Time Complexity**: $\mathcal{O}(n \log n)$ sorting time, $\mathcal{O}(n)$ search time.
- **Space Complexity**: $\mathcal{O}(n)$ storage for pairs.

### Related CSES Tasks
- [CSES 1641 - Sum of Three Values](https://cses.fi/problemset/task/1641): 3-Sum via outer loop + Two Pointers.
- [CSES 1642 - Sum of Four Values](https://cses.fi/problemset/task/1642): 4-Sum via pair decomposition.
- [CSES 1645 - Nearest Smaller Values](https://cses.fi/problemset/task/1645): Monotonic stack position queries.
