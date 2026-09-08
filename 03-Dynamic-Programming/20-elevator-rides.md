# Elevator Rides

- **Category**: Dynamic Programming
- **CSES Task ID**: `1653`
- **CSES Problem Link**: [Elevator Rides](https://cses.fi/problemset/task/1653)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ people who need to be transported to the top of a building using a single elevator. You are given the weight of each person $w_1, w_2, \dots, w_n$ and the maximum capacity of the elevator $x$. The sum of weights of people in any single ride cannot exceed $x$. 

Determine the **minimum number of elevator rides** required to transport all $n$ people.

### Input Format
- The first line contains two integers $n$ and $x$.
- The second line contains $n$ integers $w_1, w_2, \dots, w_n$.

### Output Format
- Print one integer: the minimum number of elevator rides.

### Numerical Constraints
- $1 \le n \le 20$
- $1 \le x \le 10^9$
- $1 \le w_i \le x$

With $n \le 20$, the number of subsets of people is $2^n \le 2^{20} = 1\,048\,576$. An $\mathcal{O}(n \cdot 2^n)$ bitmask dynamic programming solution performs $\approx 2 \cdot 10^7$ operations, executing in $\approx 0.08\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the classic **Bin Packing Problem** with small $n$, solved via **Bitmask Dynamic Programming**:
- **Why Greedy Fails**:
  Greedy bin-packing heuristics (such as First-Fit Decreasing) do not guarantee the absolute minimal number of bins. For small $n \le 20$, exact exponential search is required.
- **State Representation**:
  Represent any subset of transported people as an integer `mask` $\in [0, 2^n - 1]$, where the $i$-th bit is $1$ if person $i$ has already been transported.
- **Two-Dimensional Cost Tuple**:
  To make optimal future decisions, minimizing the number of rides alone is insufficient. We must also know how much weight is already inside the *current (last)* elevator ride!
  - We define $dp[\text{mask}]$ as a pair:
    $$dp[\text{mask}] = (\text{rides}, \; \text{last\_weight})$$
  - Order states **lexicographically**:
    1. Fewer `rides` is strictly better.
    2. If `rides` are equal, smaller `last\_weight` is strictly better (leaving more spare capacity for future passengers).
- **Transitions**:
  For an untransported person $i$ (`!(mask & (1 << i))`):
  - If they fit in the current ride ($\text{last\_weight} + w_i \le x$):
    Candidate: $(\text{rides}, \; \text{last\_weight} + w_i)$.
  - If they do not fit, they must start a new ride:
    Candidate: $(\text{rides} + 1, \; w_i)$.
  - $dp[\text{mask} \mid (1 \ll i)] = \min(dp[\text{mask} \mid (1 \ll i)], \; \text{candidate})$.
- Base case: $dp[0] = (1, 0)$ (1 ride open with 0 weight inside).

---

## 3. Approach 1 — Naive / Recursive Backtracking with Pruning

Recursively place people into bins.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n!)$ worst-case.
- **Space Complexity**: $\mathcal{O}(n)$ stack depth.
- **CSES Verdict**: TLE for $n \ge 16$.

---

## 4. Approach 2 — Intermediate / Meet-in-the-Middle

Split $n$ into two halves of size 10. While valid for subset-sum reachability, bin packing requires continuous bin capacity constraints that do not decompose into clean halves.

---

## 5. Approach 3 — Optimal CSES Solution (Bitmask DP with Lexicographical Pairs)

We allocate a single vector `dp` of size $2^n$, where each element is a pair `(int rides, int last_weight)`. 
We iterate `mask` forwards from $0$ to $2^n - 1$, guaranteeing that submasks are solved before supermasks.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    long long x;
    if (!(cin >> n >> x)) return 0;

    vector<long long> w(n);
    for (int i = 0; i < n; ++i) {
        cin >> w[i];
    }

    int total_masks = 1 << n;

    // dp[mask] = {min_rides, min_weight_of_last_ride}
    // Initialized to an upper bound (n + 1 rides)
    vector<pair<int, long long>> dp(total_masks, {n + 1, 0});

    // Base case: empty subset requires 1 ride with 0 weight currently in it
    dp[0] = {1, 0};

    // Iterate through all submasks in increasing order
    for (int mask = 0; mask < total_masks; ++mask) {
        int current_rides = dp[mask].first;
        long long current_weight = dp[mask].second;

        // Try adding each person i not yet in mask
        for (int i = 0; i < n; ++i) {
            if (!(mask & (1 << i))) {
                pair<int, long long> candidate;

                if (current_weight + w[i] <= x) {
                    // Person i fits into the current elevator ride
                    candidate = {current_rides, current_weight + w[i]};
                } else {
                    // Person i must start a new elevator ride
                    candidate = {current_rides + 1, w[i]};
                }

                // Lexicographical minimization: fewer rides first, then lighter last ride
                int next_mask = mask | (1 << i);
                if (candidate < dp[next_mask]) {
                    dp[next_mask] = candidate;
                }
            }
        }
    }

    // Output the minimum rides required for the full mask (111...1)
    cout << dp[total_masks - 1].first << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \cdot 2^n)$. There are $2^n$ masks. For each mask, we iterate over $n$ bits with $\mathcal{O}(1)$ operations. For $n = 20$, total operations are $20 \times 1\,048\,576 \approx 2.1 \cdot 10^7$, executing in $\approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(2^n)$ auxiliary space. An array of $2^{20}$ pairs of integers occupies $\approx 16\text{ MB}$, well within the 512 MB memory limit.
- **Optimality Guarantee**: Bin packing is NP-hard, and $\mathcal{O}(n \cdot 2^n)$ represents the optimal dynamic programming boundary for exact solutions.

---

## 6. Correctness Proof

### Optimal Substructure & Lexicographical Ordering
Let $dp[\text{mask}] = (r, w)$.
- We claim that between two valid configurations for subset `mask`, $(r_1, w_1) < (r_2, w_2)$ lexicographically is strictly superior:
  - If $r_1 < r_2$, configuration 1 has used strictly fewer rides, dominating configuration 2 regardless of remaining capacity.
  - If $r_1 = r_2$ and $w_1 < w_2$, configuration 1 has less weight in the current ride, offering strictly more remaining capacity ($x - w_1 > x - w_2$). Any future person who fits into configuration 2's current ride will also fit into configuration 1's current ride, while the converse is not true.
  - Thus, lexicographical comparison preserves the optimal substructure.
- **Inductive Step**:
  Assume $dp[\text{sub}]$ is optimal for all proper submasks. Every assignment of people in `mask` must finish with some person $i \in \text{mask}$. Removing person $i$ leaves submask $\text{mask} \setminus \{i\}$. By evaluating all candidate predecessors $\text{mask} \setminus \{i\}$ and taking the lexicographical minimum, $dp[\text{mask}]$ is globally optimal.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
4 10
4 8 6 1
```
$n = 4, x = 10$. Weights: $w = [4, 8, 6, 1]$.

| Mask (Binary) | People in Mask | Predecessor Transition | Candidate Evaluation | Optimal $dp[\text{mask}]$ |
| :---: | :---: | :---: | :---: | :---: |
| `0000` | $\emptyset$ | Base Case | - | `(1, 0)` |
| `0001` | $\{0\}$ | From `0000` + $w_0=4$ | $0 + 4 \le 10 \implies (1, 4)$ | `(1, 4)` |
| `0010` | $\{1\}$ | From `0000` + $w_1=8$ | $0 + 8 \le 10 \implies (1, 8)$ | `(1, 8)` |
| `0011` | $\{0, 1\}$ | From `0001` + $w_1=8$<br>From `0010` + $w_0=4$ | $4 + 8 > 10 \implies (2, 8)$<br>$8 + 4 > 10 \implies (2, 4)$ | `(2, 4)` |
| `0100` | $\{2\}$ | From `0000` + $w_2=6$ | $0 + 6 \le 10 \implies (1, 6)$ | `(1, 6)` |
| `0101` | $\{0, 2\}$ | From `0001` + $w_2=6$ | $4 + 6 = 10 \le 10 \implies (1, 10)$ | `(1, 10)` |
| `1000` | $\{3\}$ | From `0000` + $w_3=1$ | $0 + 1 \le 10 \implies (1, 1)$ | `(1, 1)` |
| `1111` | $\{0, 1, 2, 3\}$ | From `1110` (`{1, 2, 3}` $\implies (2, 7)$) + $w_0=4$<br>From `0111` (`{0, 1, 2}` $\implies (2, 8)$) + $w_3=1$ | $7 + 4 > 10 \implies (3, 4)$<br>$8 + 1 = 9 \le 10 \implies \mathbf{(2, 9)}$ | `(2, 9)` |

**Final Output**: `2` rides!  
Ride 1: person 1 ($8$) + person 3 ($1$) = weight 9 $\le 10$.  
Ride 2: person 0 ($4$) + person 2 ($6$) = weight 10 $\le 10$.  
(Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1$**: Single person: $w_1 \le x \implies$ output `1`.
- **All People Fit in 1 Ride**: $\sum w_i \le x \implies$ output `1`.
- **Every Person Needs Their Own Ride**: Output $n$.
- **Capacities up to $10^9$**: Weights fit inside standard types, but sums in a ride can reach $10^9$. `last_weight` should be `long long`.
- **Loop Ordering**: Iterating `mask` from $0$ up to $2^n - 1$ ensures that any submask $\text{mask} \setminus \{i\}$ is strictly processed before `mask`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Reconstruct which people share each ride?**
   - Store `parent_person[mask] = i`. Backtrack from $(1 \ll n) - 1$ to $0$, tracing which person was added last. Group people by ride boundaries.
2. **What if $n \le 40$ and $x$ is small?**
   - For $n = 40$, $2^{40}$ is too large. If capacities or number of bins are small, use Branch and Bound or integer linear programming.
3. **Elevator Travels Between Floors (Different pickup/dropoff floors)?**
   - Transforms into the Capacitated Vehicle Routing Problem (CVRP) or Pick-up and Delivery TSP, requiring state $(mask, current\_floor)$.
4. **Count the number of ways to achieve the minimum number of rides?**
   - Extend DP state to `(rides, last_weight, ways)` with modular arithmetic.
5. **Traveling Salesman Problem (TSP) similarity?**
   - Both use bitmask DP in $\mathcal{O}(n \cdot 2^n)$ or $\mathcal{O}(n^2 \cdot 2^n)$ time.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, bitmask-dp, bin-packing, greedy]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot 2^n)$
  - Space: $\mathcal{O}(2^n)$
- **Related CSES Problems**:
  - `CSES 2181` — [Counting Tilings](https://cses.fi/problemset/task/2181) (Profile DP with bitmasks).
  - `CSES 1654` — [Bit Problem](https://cses.fi/problemset/task/1654) (Sum Over Subsets / SOS DP).
  - `CSES 1690` — [Hamiltonian Flights](https://cses.fi/problemset/task/1690) (Graph TSP with bitmask DP).
