# Restaurant Customers (CSES Task 1619 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1619 - Restaurant Customers](https://cses.fi/problemset/task/1619)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Given the arrival and leaving times of $n$ customers in a restaurant, find the maximum number of customers present in the restaurant at any point in time.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le a_i < b_i \le 10^9$. All arrival and leaving times are distinct.

---

## 1. Problem, Restated

Given $n$ open intervals $(a_i, b_i)$ representing the stay duration of $n$ customers:
Find the maximum overlapping depth of intervals:
$$\max_{t \in \mathbb{R}} |\{i : a_i \le t \le b_i\}|$$

**Input**:
- First line: integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Next $n$ lines: two integers $a_i$ and $b_i$, representing arrival and departure times.

**Output**:
- Print a single integer: the maximum number of concurrent customers.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Sweep-Line Algorithm / Event-Driven Simulation / Prefix Sums on Coordinate-Compressed Timeline.
- **Aha! Insight**:
  - The number of customers in the restaurant only changes at discrete moments:
    - When a customer arrives at $a_i$, customer count increases by $+1$.
    - When a customer departs at $b_i$, customer count decreases by $-1$.
  - We can decompose each customer into two independent **events**:
    $$(a_i, +1) \quad \text{and} \quad (b_i, -1)$$
  - Flatten all $2n$ events into a single array and sort them chronologically by timestamp.
  - Sweep through the sorted events from left to right, maintaining a running sum `current_customers`.
  - The answer is simply the maximum value achieved by `current_customers` throughout the sweep.
- **Signal**: "Maximum overlapping intervals" or "peak concurrent active intervals" is the textbook 1D Sweep-Line pattern.

---

## 3. Approach 1 — Naive / Baseline (Difference Array with Direct Indexing)

Using a direct prefix difference array `diff[10^9]`.
Since timestamps reach $10^9$, allocating an array of size $10^9$ requires $\approx 4$ GB of memory, causing Memory Limit Exceeded (MLE) and Time Limit Exceeded (TLE).

---

## 4. Approach 2 — Intermediate (`std::map<int, int>` Coordinate Compression)

Inserting `events[a_i]++` and `events[b_i]--` into a `std::map<int, int>`. Then iterating through the map to accumulate the prefix sum.
While $\mathcal{O}(n \log n)$, `std::map` node allocations create extra overhead compared to sorting a flat vector of pairs.

---

## 5. Approach 3 — Optimal CSES Solution (Flat Vector Event Sweep-Line)

### Idea
1. Store all $2n$ events as `pair<int, int>`: `(a_i, +1)` and `(b_i, -1)`.
2. Sort the events vector using `std::sort`. C++ pairs sort primarily by the first element (timestamp).
3. Initialize `curr = 0` and `max_cust = 0`.
4. Iterate through events: `curr += event.second`, then `max_cust = max(max_cust, curr)`.
5. Output `max_cust`.

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
    if (!(cin >> n)) return 0;

    // Store 2n events: (time, delta)
    vector<pair<int, int>> events;
    events.reserve(2 * n);

    for (int i = 0; i < n; ++i) {
        int a, b;
        cin >> a >> b;
        events.push_back({a, 1});
        events.push_back({b, -1});
    }

    sort(events.begin(), events.end());

    int current_customers = 0;
    int max_customers = 0;

    for (const auto& event : events) {
        current_customers += event.second;
        if (current_customers > max_customers) {
            max_customers = current_customers;
        }
    }

    cout << max_customers << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$ to sort the $2n$ events. The linear sweep takes $\mathcal{O}(n)$ time. For $n = 2 \cdot 10^5$, total operations $\approx 2 \cdot 10^5 \times 19 \approx 4 \times 10^6$, running in $\approx 0.09$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ memory for $2n$ pairs ($2 \times 2 \cdot 10^5 \times 8$ bytes $\approx 3.2$ MB).

---

## 6. Correctness Proof

1. **Piecewise Constant Customer Count**:
   The function $C(t) = \sum_{i=1}^n \mathbf{1}_{[a_i, b_i]}(t)$ is constant between consecutive event times $t_k$ and $t_{k+1}$.
   Hence, $\sup_{t \in \mathbb{R}} C(t)$ must occur at an event transition point $t = a_i$.
2. **Cumulative Event Representation**:
   Let the sorted sequence of events be $(t_1, \Delta_1), (t_2, \Delta_2), \dots, (t_{2n}, \Delta_{2n})$.
   At any time immediately following $t_k$, the number of active customers is:
   $$C(t_k) = \sum_{j=1}^k \Delta_j$$
   Since each customer adds $+1$ at $a_i$ and $-1$ at $b_i$, every customer present in the interval contributes $+1$, and customers who have departed contribute $+1 + (-1) = 0$.
3. **Distinct Times**:
   Because all $a_i$ and $b_i$ are distinct, each $t_k$ is unique, so event ordering between simultaneous arrivals and departures is unambiguous.
   Therefore, $\max_k C(t_k)$ strictly equals the global maximum. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 3$.
Customers: $(5, 8), (2, 4), (3, 9)$.

Events generated:
`[(5, +1), (8, -1), (2, +1), (4, -1), (3, +1), (9, -1)]`

Sorted events:
1. $(2, +1) \implies \text{curr} = 1, \max = 1$
2. $(3, +1) \implies \text{curr} = 2, \max = 2$
3. $(4, -1) \implies \text{curr} = 1, \max = 2$
4. $(5, +1) \implies \text{curr} = 2, \max = 2$
5. $(8, -1) \implies \text{curr} = 1, \max = 2$
6. $(9, -1) \implies \text{curr} = 0, \max = 2$

Maximum concurrent customers: **2**.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1$**: Exactly one customer arrives and leaves; maximum is `1`.
- **Completely disjoint visits**: Intervals do not overlap; maximum is `1`.
- **All intervals mutually overlapping**: All arrivals occur before any departures; maximum is $n$.
- **Simultaneous timestamps**: If arrival and departure could coincide, sorting `(time, delta)` with departure delta `-1` before arrival `+1` handles open intervals (leaving before someone enters), or `+1` before `-1` for closed intervals. In CSES 1619, all times are strictly distinct.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if we needed to find the continuous time interval during which the restaurant had the peak number of customers?**
   - Record the timestamp when `current_customers` first reaches `max_customers` and the timestamp of the next departure.
2. **What if customers have groups of size $w_i$ rather than 1?**
   - Change deltas to $(a_i, +w_i)$ and $(b_i, -w_i)$. The sweep-line logic remains identical.
3. **How to solve this dynamically with online insert/delete of bookings?**
   - Use a Segment Tree with lazy propagation over coordinate-compressed timestamps to query range max in $\mathcal{O}(\log n)$.
4. **How would you find the total duration during which at least $k$ customers were present?**
   - Accumulate $(t_{j+1} - t_j)$ whenever `current_customers >= k`.
5. **How does this problem compare to LeetCode 253 (Meeting Rooms II)?**
   - The problem is identical: both ask for the chromatic number / clique size of an interval graph, solved via sweep-line in $\mathcal{O}(n \log n)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Sweep-Line, Sorting, Two Pointers, Events, Prefix Sums.
- **Time Complexity**: $\mathcal{O}(n \log n)$ event sorting time.
- **Space Complexity**: $\mathcal{O}(n)$ event storage.

### Related CSES Tasks
- [CSES 1629 - Movie Festival](https://cses.fi/problemset/task/1629): Non-overlapping interval scheduling.
- [CSES 1164 - Room Allocation](https://cses.fi/problemset/task/1164): Assigning specific room IDs using priority queues.
- [CSES 2168 - Nested Ranges Check](https://cses.fi/problemset/task/2168): Sweep-line on 2D interval containment.
