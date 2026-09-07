# Concert Tickets (CSES Task 1091 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1091 - Concert Tickets](https://cses.fi/problemset/task/1091)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: There are $n$ concert tickets available with prices $h_1, \dots, h_n$. Then, $m$ customers arrive sequentially. Each announces the maximum price $t_j$ they are willing to pay. Each customer receives the most expensive available ticket $\le t_j$, which is then removed from inventory. If no ticket is available, print `-1`.
- **Constraints**: $1 \le n, m \le 2 \cdot 10^5$, $1 \le h_i, t_j \le 10^9$.

---

## 1. Problem, Restated

Given a multiset of $n$ ticket prices $\{h_1, \dots, h_n\}$ and an online stream of $m$ queries $t_1, \dots, t_m$:
For each customer budget $t_j$:
1. Query the largest available ticket price $p$ such that $p \le t_j$.
2. If such $p$ exists: print $p$ and delete one instance of $p$ from the inventory.
3. If no such ticket exists (all available tickets have price $> t_j$): print `-1`.

**Input**:
- First line: two integers $n$ and $m$.
- Second line: $n$ space-separated integers $h_1, \dots, h_n$.
- Third line: $m$ space-separated integers $t_1, \dots, t_m$.

**Output**:
- Print $m$ lines: each containing the price paid by customer $j$, or `-1`.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Dynamic Predecessor Queries / Self-Balancing BST / `std::multiset` / Upper Bound.
- **Aha! Insight**:
  - The customers arrive sequentially, and tickets are consumed dynamically. We need a data structure that supports:
    1. Predecessor query: find $\max \{x \in S : x \le t\}$.
    2. Deletion of the queried element.
  - In C++, `std::multiset<int>` is implemented as a red-black tree, supporting insertion, binary search, and deletion in $\mathcal{O}(\log n)$ time.
  - To find the largest element $\le t_j$:
    - Query `it = tickets.upper_bound(t_j)`.
    - `upper_bound(t_j)` finds the first element strictly greater than $t_j$.
    - If `it == tickets.begin()`, then every element in the multiset is $> t_j$, meaning no ticket is affordable $\implies$ print `-1`.
    - Otherwise, the preceding iterator `--it` points to the **largest element $\le t_j$**!
    - Print `*it` and delete it via `tickets.erase(it)`.
- **Signal**: "Repeatedly find the largest available number $\le X$ and remove it" is the exact definition of a predecessor query in a dynamic balanced search tree.

---

## 3. Approach 1 — Naive / Baseline (Linear Search over Vector)

Store tickets in a `vector<int>`. For each query $t_j$, scan all remaining tickets, find the maximum ticket $\le t_j$, and erase it from the vector.
Linear scan and erasure take $\mathcal{O}(n)$ per query, resulting in $\mathcal{O}(m \cdot n)$ total time. For $n, m = 2 \cdot 10^5$, this is $4 \cdot 10^{10}$ operations (instant TLE).

---

## 4. Approach 2 — Intermediate (Coordinate Compression + Segment Tree)

Coordinate compress all distinct ticket prices into $[0, U-1]$. Maintain a Segment Tree storing frequencies of each price. For budget $t_j$, binary search the prefix on the segment tree to find the rightmost non-zero frequency $\le t_j$, then decrement its frequency.
While optimal at $\mathcal{O}((n + m) \log n)$, coordinate compression adds code length compared to `std::multiset`.

---

## 5. Approach 3 — Optimal CSES Solution (`std::multiset` Predecessor Search)

### Idea
Insert all ticket prices into `std::multiset<int> tickets`.
For each query $t$:
1. Call `auto it = tickets.upper_bound(t)`.
2. If `it == tickets.begin()`, print `-1`.
3. Else, decrement `it`, print `*it`, and erase via `tickets.erase(it)`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <set>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    if (!(cin >> n >> m)) return 0;

    multiset<int> tickets;
    for (int i = 0; i < n; ++i) {
        int h;
        cin >> h;
        tickets.insert(h);
    }

    for (int j = 0; j < m; ++j) {
        int t;
        cin >> t;

        auto it = tickets.upper_bound(t);
        if (it == tickets.begin()) {
            cout << -1 << '\n';
        } else {
            --it;
            cout << *it << '\n';
            tickets.erase(it); // Erase by iterator removes exactly ONE instance
        }
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**:
  - Building the multiset: $n$ insertions take $\mathcal{O}(n \log n)$.
  - Processing queries: each customer performs an `upper_bound` ($\mathcal{O}(\log n)$) and an iterator erasure ($\mathcal{O}(1)$ amortized).
  - Total time: $\mathcal{O}((n + m) \log n)$. For $2 \cdot 10^5$, total operations $\approx 3.6 \times 10^6$, finishing in $\approx 0.28$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ tree nodes in `std::multiset`.

---

## 6. Correctness Proof

1. **Predecessor Invariance**:
   Let $S$ be the current multiset of available tickets.
   `upper_bound(t)` returns an iterator to the first element in $S$ strictly greater than $t$:
   $$it = \min \{x \in S : x > t\}$$
   - If $it = \text{begin}(S)$, then for all $x \in S$, $x > t$. No ticket satisfies $x \le t$. Correctly outputs `-1`.
   - If $it \ne \text{begin}(S)$, the predecessor $p = \text{prev}(it)$ is the maximal element in $S$ satisfying $p \le t$. Because $S$ is totally ordered, $p$ is the closest available ticket under budget $t$.
2. **Single-Element Deletion**:
   Calling `tickets.erase(it)` on an iterator deletes exactly the single referenced node. If multiple tickets have the identical price $p$, only one ticket is removed, leaving the duplicates available for subsequent customers.
3. **Sequential Invariance**:
   Customers are processed strictly in arrival order $j = 1, \dots, m$. Each customer receives the locally optimal ticket, updating the inventory for all future customers. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Tickets: $h = [5, 3, 7, 8, 5]$, Customers: $t = [4, 8, 3]$.
Initial multiset: `{3, 5, 5, 7, 8}`.

- Customer 1 ($t = 4$):
  - `upper_bound(4)` finds `5` (at index 1).
  - Predecessor `--it` points to `3`.
  - Print `3`.
  - `erase(it)` removes `3`.
  - Multiset: `{5, 5, 7, 8}`.
- Customer 2 ($t = 8$):
  - `upper_bound(8)` returns `end()`.
  - Predecessor `--it` points to `8`.
  - Print `8`.
  - `erase(it)` removes `8`.
  - Multiset: `{5, 5, 7}`.
- Customer 3 ($t = 3$):
  - `upper_bound(3)` finds `5` (at index 0).
  - `it == tickets.begin()`.
  - Print `-1`.

Output:
```text
3
8
-1
```

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **CRITICAL C++ GOTCHA: `erase(it)` vs `erase(val)`**:
  - Calling `tickets.erase(*it)` or `tickets.erase(val)` erases **ALL** occurrences of `val` in the multiset!
  - Calling `tickets.erase(it)` erases **ONLY the single occurrence** pointed to by `it`.
  - Passing `*it` instead of `it` fails test cases with duplicate ticket prices!
- **All tickets cheaper than budget**: `upper_bound(t)` returns `end()`, `--it` correctly points to the maximum ticket.
- **All tickets more expensive than budget**: `upper_bound(t)` returns `begin()`, correctly triggers `-1`.
- **Fast I/O**: With $m = 2 \cdot 10^5$ queries, printing using `'\n'` with fast I/O is mandatory.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How to solve this if tickets were given as ranges $[L_i, R_i]$?**
   - Use an interval tree or segment tree to find the stabbing interval that covers $t_j$.
2. **Can this be solved in $\mathcal{O}((n + m) \alpha(n))$ using Disjoint Set Union (DSU)?**
   - If customer budgets are known offline or sorted, or using DSU on sorted tickets where each root points to the next available smaller ticket, predecessor queries can be answered nearly in linear time.
3. **What if customers want the cheapest ticket $\ge t_j$?**
   - Query `lower_bound(t_j)`. If `it != tickets.end()`, take `*it` and erase.
4. **Why is `std::multiset` preferred over sorted `std::vector` here?**
   - Inserting or erasing from the middle of a `vector` requires shifting elements in $\mathcal{O}(n)$ time.
5. **How does `ordered_set` (PBDS) compare with `multiset` here?**
   - Policy-Based Data Structures (PBDS) provide `find_by_order` and `order_of_key`, but standard `std::multiset` is simpler and faster when rank queries are not required.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Balanced BST, Multiset, Binary Search, Predecessor Query, Greedy.
- **Time Complexity**: $\mathcal{O}((n + m) \log n)$.
- **Space Complexity**: $\mathcal{O}(n)$ space for tree nodes.

### Related CSES Tasks
- [CSES 1163 - Traffic Lights](https://cses.fi/problemset/task/1163): Dynamic interval splitting with `std::set` and `std::multiset`.
- [CSES 1073 - Towers](https://cses.fi/problemset/task/1073): Greedy sequence extension with multiset upper bound.
- [CSES 1164 - Room Allocation](https://cses.fi/problemset/task/1164): Greedy interval scheduling with priority queues.
