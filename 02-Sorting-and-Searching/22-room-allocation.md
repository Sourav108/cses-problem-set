# Room Allocation (CSES Task 1164 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1164 - Room Allocation](https://cses.fi/problemset/task/1164)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: There are $n$ customers arriving at a hotel. Customer $i$ stays from day $a_i$ to $b_i$. Two customers can share a room if the departure day of the first is strictly earlier than the arrival day of the second ($b_j < a_i$). Find the minimum number of rooms $k$, and allocate room numbers $1 \dots k$ to all customers.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le a_i \le b_i \le 10^9$.

---

## 1. Problem, Restated

Given $n$ intervals $[a_i, b_i]$ representing hotel customer stays:
Assign each customer $i$ a room number $R_i \in \{1, 2, \dots, k\}$ such that if two customers $i$ and $j$ overlap ($[a_i, b_i] \cap [a_j, b_j] \ne \emptyset$), they are assigned distinct rooms ($R_i \ne R_j$).
Minimize $k$, and output $k$ followed by the room assignments in the original input order.

**Input**:
- First line: integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Next $n$ lines: two integers $a_i$ and $b_i$.

**Output**:
- First line: integer $k$ (the minimum number of rooms).
- Second line: $n$ space-separated integers representing the room allocated to each customer.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Interval Coloring / Greedy Allocation / Priority Queue (Min-Heap) / Chromatic Number of Interval Graphs.
- **Aha! Insight**:
  - The minimum number of rooms $k$ is identically equal to the **maximum number of overlapping customers at any point in time** (the clique number of the interval graph, which by interval graph perfection equals the chromatic number).
  - To assign actual room numbers:
    - Sort all customers primarily by their **arrival day** $a_i$ in ascending order.
    - We process customers chronologically as they arrive.
    - We need to know: *is there any currently assigned room whose previous occupant has already left before day $a_i$?*
    - To answer this in $\mathcal{O}(\log n)$, maintain a **min-heap** storing the active rooms:
      $$\text{heap elements} = (\text{departure\_day}, \text{room\_id})$$
    - The top of the heap is the room that becomes vacant earliest.
    - When customer $i$ arrives on day $a_i$:
      - If $\text{heap.top().departure} < a_i$:
        The room is already empty!
        Pop this room, reassign its `room_id` to customer $i$, and push $(b_i, \text{room\_id})$ back into the heap.
      - Else (the heap is empty or the earliest room is still occupied with departure $\ge a_i$):
        All existing rooms are currently in use.
        We must open a **new room**: $\text{room\_id} = ++k$.
        Push $(b_i, \text{room\_id})$ into the heap.
    - Store the assigned `room_id` in an array `ans[customer.id]`.
- **Signal**: Constructive room assignment on overlapping intervals sorted by start time is the textbook min-heap greedy allocation pattern.

---

## 3. Approach 1 — Naive / Baseline (Linear Room Scanning)

For each customer, iterate over all existing rooms $1 \dots k$ to find one whose last occupant departed before $a_i$. If none found, create room $k+1$.
Checking $k$ rooms takes $\mathcal{O}(k)$ per customer. In the worst case $k = n$, this is $\mathcal{O}(n^2) = 4 \cdot 10^{10}$ operations $\implies$ TLE.

---

## 4. Approach 2 — Intermediate (Sweep-Line with Room Free-List)

Decompose each interval into arrival and departure events. A free-list (stack) stores vacant room IDs.
While $\mathcal{O}(n \log n)$, separating arrivals and departures requires tie-breaking logic and tracking which specific room was vacated at each departure event. The min-heap (Approach 3) handles both departure check and room reuse in a single unified container.

---

## 5. Approach 3 — Optimal CSES Solution (Arrival-Sorted Min-Heap)

### Idea
1. Store customers as a struct with `a`, `b`, and original index `id`.
2. Sort customers by arrival time $a$.
3. Maintain `priority_queue<pair<int, int>, vector<pair<int, int>>, greater<>> pq` storing `(departure_day, room_id)`.
4. Maintain `total_rooms = 0`.
5. For each customer:
   - If `!pq.empty() && pq.top().first < cur.a`:
     Reuse `room_id = pq.top().second`, pop from heap.
   - Else:
     Open new room `room_id = ++total_rooms`.
   - Record `ans[cur.id] = room_id`.
   - Push `(cur.b, room_id)` to heap.
6. Print `total_rooms`, then print `ans[i]` for all $i$.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>

using namespace std;

struct Customer {
    int a, b, id;
};

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<Customer> customers(n);
    for (int i = 0; i < n; ++i) {
        cin >> customers[i].a >> customers[i].b;
        customers[i].id = i;
    }

    // Sort primarily by arrival day
    sort(customers.begin(), customers.end(), [](const Customer& x, const Customer& y) {
        if (x.a != y.a) return x.a < y.a;
        return x.b < y.b;
    });

    // Min-heap storing (departure_day, room_id)
    priority_queue<pair<int, int>, vector<pair<int, int>>, greater<pair<int, int>>> pq;

    vector<int> room_assigned(n);
    int total_rooms = 0;

    for (int i = 0; i < n; ++i) {
        int room_id;
        if (!pq.empty() && pq.top().first < customers[i].a) {
            // Reuse earliest vacated room
            room_id = pq.top().second;
            pq.pop();
        } else {
            // Allocate a new room
            room_id = ++total_rooms;
        }

        room_assigned[customers[i].id] = room_id;
        pq.push({customers[i].b, room_id});
    }

    cout << total_rooms << '\n';
    for (int i = 0; i < n; ++i) {
        cout << room_assigned[i] << (i + 1 == n ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$. Sorting $n$ customers takes $\mathcal{O}(n \log n)$. Each customer pushes and pops from the priority queue of size $\le n$, taking $\mathcal{O}(\log n)$. Total operations $\approx 3.6 \times 10^6$, executing in $\approx 0.09$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ memory for `customers`, `room_assigned`, and priority queue.

---

## 6. Correctness Proof

1. **Non-Overlapping Room Invariant**:
   A room $R$ is only reused for customer $i$ if the previous occupant of room $R$ departed on day $b_{\text{prev}} < a_i$.
   Because customers are processed in non-decreasing order of arrival day $a_i$, any room whose departure day is $< a_i$ has completely finished before customer $i$ begins.
   Hence, no two customers occupying the same room ever overlap in time.
2. **Minimality of Total Rooms $k$**:
   A new room is opened only when the heap top satisfies $b_{\min} \ge a_i$.
   Because $b_{\min}$ is the minimum departure day among all currently open rooms, every single currently active room has an occupant staying through day $a_i$.
   Therefore, at moment $a_i$, all existing rooms are simultaneously occupied by active customers who overlap with each other and with customer $i$.
   This forms a clique of size $k$ in the interval graph.
   By graph theory, any valid coloring requires at least as many colors as the size of the maximum clique ($\chi(G) \ge \omega(G)$).
   Since our greedy algorithm never exceeds this lower bound, $k$ is strictly minimal. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 3$.
Customers: `[1, 2] (id 0)`, `[2, 4] (id 1)`, `[4, 4] (id 2)`.

Sorted by arrival:
1. `[1, 2]` (id 0)
2. `[2, 4]` (id 1)
3. `[4, 4]` (id 2)

**Step 1**: Customer `[1, 2]` (id 0).
- Heap is empty $\implies$ New room 1.
- `room_assigned[0] = 1`.
- Push `(2, 1)`. Heap: `[(2, 1)]`. `total_rooms = 1`.

**Step 2**: Customer `[2, 4]` (id 1).
- Heap top: `(2, 1)`. Departure day is 2. Arrival is 2.
- Condition `departure < arrival` is $2 < 2$ (False! Overlaps on day 2!).
- Must open new room 2!
- `room_assigned[1] = 2`.
- Push `(4, 2)`. Heap: `[(2, 1), (4, 2)]`. `total_rooms = 2`.

**Step 3**: Customer `[4, 4]` (id 2).
- Heap top: `(2, 1)`. Departure is $2 < 4$ (True! Room 1 is free!).
- Reuse room 1! Pop `(2, 1)`.
- `room_assigned[2] = 1`.
- Push `(4, 1)`. Heap: `[(4, 1), (4, 2)]`.

Final Output:
`2`
`1 2 1` (matches CSES example!).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Single Day Stays ($a_i = b_i$)**: Handled correctly. An interval $[4, 4]$ occupies day 4; a previous customer with $b \le 3$ is free to be reused ($3 < 4$).
- **Departure on Arrival Day ($b_{\text{prev}} == a_i$)**: The problem specifies that two customers can share a room only if the departure day of the first is *strictly earlier* than the arrival day of the second ($b_{\text{prev}} < a_i$). Using `<` strictly enforces this requirement.
- **Output Order**: The answer must be printed in the original input order, not the sorted order. Storing `id` inside the struct enables direct indexing into `room_assigned[id]`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does this differ from Restaurant Customers (CSES 1619)?**
   - CSES 1619 only asks for the *count* of maximum overlapping customers (the value $k$). CSES 1164 requires the constructive allocation of specific room IDs to every customer.
2. **What if rooms have different capacities?**
   - Generalizes to capacitated bin packing or interval scheduling with resource constraints.
3. **What if we want to minimize room changes for customers who stay across multiple bookings?**
   - Formulate as min-cost flow on interval graphs.
4. **Why is `greater<pair<int, int>>` used in `std::priority_queue`?**
   - C++ `std::priority_queue` is a max-heap by default. Passing `greater<>` configures it as a min-heap, placing the earliest departure time at the top.
5. **How does this problem connect to Register Allocation in compilers?**
   - Register allocation on straight-line code (basic blocks) without spilling is precisely interval graph coloring, solved using this exact linear-scan algorithm (Poletto & Sarkar, 1999).

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Greedy, Priority Queue, Heap, Interval Scheduling, Graph Coloring.
- **Time Complexity**: $\mathcal{O}(n \log n)$ optimal time.
- **Space Complexity**: $\mathcal{O}(n)$ memory.

### Related CSES Tasks
- [CSES 1619 - Restaurant Customers](https://cses.fi/problemset/task/1619): Maximum concurrent interval count.
- [CSES 1629 - Movie Festival](https://cses.fi/problemset/task/1629): Selecting non-overlapping intervals.
- [CSES 1632 - Movie Festival II](https://cses.fi/problemset/task/1632): $k$-person interval scheduling.
