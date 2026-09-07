# Traffic Lights (CSES Task 1163 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1163 - Traffic Lights](https://cses.fi/problemset/task/1163)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: A street of length $x$ has positions $0 \dots x$. Initially there are lights at $0$ and $x$. Then $n$ traffic lights are added one after another at positions $p_1, \dots, p_n$. After each addition, calculate the length of the longest passage without traffic lights.
- **Constraints**: $1 \le x \le 10^9$, $1 \le n \le 2 \cdot 10^5$, $0 < p_i < x$. All positions $p_i$ are distinct.

---

## 1. Problem, Restated

Given a line segment $[0, x]$:
Sequentially insert $n$ distinct points $p_1, p_2, \dots, p_n \in (0, x)$.
Each inserted point $p_i$ splits the interval $(L, R)$ containing it into two smaller sub-intervals $(L, p_i)$ and $(p_i, R)$.
After each insertion, report the length of the longest existing interval:
$$\max_{\text{adjacent } u < v} (v - u)$$

**Input**:
- First line: two integers $x$ and $n$.
- Second line: $n$ space-separated integers $p_1, \dots, p_n$.

**Output**:
- Print $n$ space-separated integers: the maximum passage length after each light addition.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Dynamic Interval Splitting / Dual Balanced BST (`std::set` + `std::multiset`) / Offline Reverse Processing (DSU).
- **Aha! Insight**:
  - We need two dynamic operations:
    1. Given a new light at $p$, locate its immediate left and right light neighbors $L$ and $R$.
    2. Remove the old length $(R - L)$ from our collection of passage lengths, and insert the two new lengths $(p - L)$ and $(R - p)$.
    3. Query the maximum length in the collection.
  - In C++, we can maintain two standard library containers:
    - `std::set<int> lights`: stores all current light positions (initialized with $\{0, x\}$).
    - `std::multiset<int> passages`: stores the lengths of all current passages (initialized with $\{x\}$).
  - For each new position $p$:
    - Use `lights.upper_bound(p)` to find $R$ in $\mathcal{O}(\log n)$.
    - The predecessor is $L = \text{prev}(R)$.
    - Erase one instance of $(R - L)$ from `passages` using `passages.erase(passages.find(R - L))`.
    - Insert $(p - L)$ and $(R - p)$ into `passages`.
    - Insert $p$ into `lights`.
    - The longest passage is `*passages.rbegin()` in $\mathcal{O}(1)$!
- **Signal**: Maintaining the maximum among dynamic split intervals is solved cleanly with dual balanced search trees or reverse DSU.

---

## 3. Approach 1 — Naive / Baseline (Linear Scan over Sorted Vector)

Inserting $p$ into a sorted vector and scanning all adjacent differences takes $\mathcal{O}(n)$ per query, resulting in $\mathcal{O}(n^2)$ time. For $n = 2 \cdot 10^5$, $4 \cdot 10^{10}$ operations $\implies$ TLE.

---

## 4. Approach 2 — Intermediate (Offline Reverse Queries with DSU)

Process queries in reverse order!
First, insert all $n$ lights into an array, sorting them to identify all final intervals.
Then, process queries from $n-1$ down to $0$, removing lights (which merges adjacent intervals using Disjoint Set Union).
Because DSU supports $\mathcal{O}(\alpha(n))$ union operations, tracking the maximum component size runs in $\mathcal{O}(n \log n + n \alpha(n))$.
While asymptotically optimal, dual balanced sets (Approach 3) solve the problem directly online.

---

## 5. Approach 3 — Optimal CSES Solution (Dual Sets: `std::set` + `std::multiset`)

### Idea
Maintain `set<int> lights = {0, x}` and `multiset<int> passages = {x}`.
For each light $p$:
1. `auto it = lights.upper_bound(p)`
2. `int r = *it, l = *prev(it)`
3. `passages.erase(passages.find(r - l))` (removes exactly one instance of old length)
4. `passages.insert(p - l)`
5. `passages.insert(r - p)`
6. `lights.insert(p)`
7. Output `*passages.rbegin()`

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <set>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int x, n;
    if (!(cin >> x >> n)) return 0;

    set<int> lights = {0, x};
    multiset<int> passages = {x};

    for (int i = 0; i < n; ++i) {
        int p;
        cin >> p;

        auto it = lights.upper_bound(p);
        int r = *it;
        int l = *prev(it);

        // Erase exactly one instance of the old length
        passages.erase(passages.find(r - l));

        // Insert two new split lengths
        passages.insert(p - l);
        passages.insert(r - p);

        // Record the new light
        lights.insert(p);

        // Output largest passage length
        cout << *passages.rbegin() << (i + 1 == n ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$. Each of the $n$ lights triggers:
  - `lights.upper_bound`: $\mathcal{O}(\log n)$
  - `passages.find` and `erase`: $\mathcal{O}(\log n)$
  - Two `passages.insert`: $\mathcal{O}(\log n)$
  - `lights.insert`: $\mathcal{O}(\log n)$
  - `passages.rbegin()`: $\mathcal{O}(1)$
  Total operations $\approx 2 \cdot 10^5 \times 18 \times 5 \approx 1.8 \cdot 10^7$, executing in $\approx 0.32$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ tree nodes in `lights` and `passages`.

---

## 6. Correctness Proof

1. **Bracketing Invariant**:
   At any point, `lights` contains a strictly sorted set of boundary points $0 = p_{(0)} < p_{(1)} < \dots < p_{(k)} = x$.
   For any point $p \notin \text{lights}$, `upper_bound(p)` returns $p_{(j)}$ where $p_{(j-1)} < p < p_{(j)}$.
   Because no light exists between $p_{(j-1)}$ and $p_{(j)}$, the interval $(p_{(j-1)}, p_{(j)})$ was a contiguous unbroken passage before adding $p$.
2. **Splitting Invariant**:
   Adding $p$ divides $(p_{(j-1)}, p_{(j)})$ into $(p_{(j-1)}, p)$ of length $p - p_{(j-1)}$ and $(p, p_{(j)})$ of length $p_{(j)} - p$.
   All other intervals are untouched.
   Replacing $(p_{(j)} - p_{(j-1)})$ with $(p - p_{(j-1)})$ and $(p_{(j)} - p)$ in `passages` preserves the exact multiset of existing passage lengths.
3. **Maximal Property**:
   Because `std::multiset` maintains elements in non-decreasing order, `*passages.rbegin()` is unconditionally the maximum element in the multiset. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $x = 8, n = 3$, lights: `[3, 6, 2]`.
Initial: `lights = {0, 8}`, `passages = {8}`.

- Light 1 ($p = 3$):
  - `upper_bound(3)` finds 8. $L = 0, R = 8$.
  - Remove $8 - 0 = 8$.
  - Insert $3 - 0 = 3$ and $8 - 3 = 5$.
  - `lights = {0, 3, 8}`, `passages = {3, 5}`.
  - Max passage: `*passages.rbegin() = 5`.
- Light 2 ($p = 6$):
  - `upper_bound(6)` finds 8. $L = 3, R = 8$.
  - Remove $8 - 3 = 5$.
  - Insert $6 - 3 = 3$ and $8 - 6 = 2$.
  - `lights = {0, 3, 6, 8}`, `passages = {2, 3, 3}`.
  - Max passage: `*passages.rbegin() = 3`.
- Light 3 ($p = 2$):
  - `upper_bound(2)` finds 3. $L = 0, R = 3$.
  - Remove $3 - 0 = 3$. (One copy of 3 removed, `{2, 3}` remains).
  - Insert $2 - 0 = 2$ and $3 - 2 = 1$.
  - `lights = {0, 2, 3, 6, 8}`, `passages = {1, 2, 2, 3}`.
  - Max passage: `*passages.rbegin() = 3`.

Output: `5 3 3`. Exactly matches example!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **CRITICAL C++ GOTCHA: `passages.erase(val)`**:
  - Calling `passages.erase(r - l)` deletes **ALL** passages of length $(r - l)$!
  - Calling `passages.erase(passages.find(r - l))` deletes **ONLY the single passage** being split!
  - Failing to use `.find()` will wipe out identical passages and produce incorrect answers.
- **Street Length $x \le 10^9$**: Handled properly; all coordinate differences fit in 32-bit `int` (up to $10^9$).
- **Single light ($n = 1$)**: Output is $\max(p_1, x - p_1)$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How to solve this if lights can also be removed?**
   - The dual BST approach handles dynamic insertions and deletions symmetrically: when removing light $p$, find $L = \text{prev}(p)$ and $R = \text{next}(p)$, erase $(p - L)$ and $(R - p)$ from `passages`, insert $(R - L)$, and erase $p$ from `lights`.
2. **How does the Offline DSU approach achieve $\mathcal{O}(n \alpha(n))$?**
   - After reading all queries, sort all lights to form the final array of segments. When removing a light in reverse, merge the segment to its left with the segment to its right in a Disjoint Set Union (DSU) structure, tracking the maximum segment size.
3. **What if the street was a closed circular loop (Ferris wheel / ring road)?**
   - Position arithmetic wraps around modulo $x$; the initial light breaks the circle into a linear segment of length $x$.
4. **Can this be solved using a Segment Tree?**
   - Yes, coordinate compress the light positions and maintain max subarray / empty runs on a Segment Tree in $\mathcal{O}(n \log n)$.
5. **Why is `*passages.rbegin()` $\mathcal{O}(1)$?**
   - In a C++ red-black tree, the maximum element is cached or reachable via the rightmost child pointer in $\mathcal{O}(1)$ time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Balanced BST, Set, Multiset, Dynamic Intervals, Two Pointers, DSU.
- **Time Complexity**: $\mathcal{O}(n \log n)$ online time.
- **Space Complexity**: $\mathcal{O}(n)$ memory for balanced trees.

### Related CSES Tasks
- [CSES 1091 - Concert Tickets](https://cses.fi/problemset/task/1091): Dynamic predecessor queries via `std::multiset`.
- [CSES 1164 - Room Allocation](https://cses.fi/problemset/task/1164): Interval allocation using priority queues.
- [CSES 2168 - Nested Ranges Check](https://cses.fi/problemset/task/2168): 2D interval containment tracking.
