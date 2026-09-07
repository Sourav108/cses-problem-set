# Josephus Problem I (CSES Task 2162 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 2162 - Josephus Problem I](https://cses.fi/problemset/task/2162)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: There are $n$ children numbered $1, 2, \dots, n$ standing in a circle. Starting from child 1, every other child is removed from the circle until no children are left. In which order will the children be removed?
- **Constraints**: $1 \le n \le 2 \cdot 10^5$.

---

## 1. Problem, Restated

Given a circle of $n$ people labeled $1$ through $n$:
Starting at 1, alternate between skipping and eliminating people:
- Person 1: skipped
- Person 2: eliminated
- Person 3: skipped
- Person 4: eliminated
- ...
Continue cycling around the remaining people until everyone has been eliminated. Output the complete sequence of eliminated numbers.

**Input**: A single line with an integer $n$ ($1 \le n \le 2 \cdot 10^5$).  
**Output**: Print $n$ space-separated integers representing the elimination order.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Josephus Elimination / Halving Cycles / Ordered Statistics / Geometric Series.
- **Aha! Insight**:
  - In a full pass around the circle of size $m$, we eliminate roughly half the children ($\lfloor m / 2 \rfloor$).
  - Instead of simulating person-by-person with a linked list or tree, we can simulate **entire rounds** at once!
  - Maintain a list of current survivors and a boolean state `skip_next` indicating whether the next element in the current pass should be skipped:
    - If `skip_next == false`: the element is kept as a survivor for the next round, and `skip_next` flips to `true`.
    - If `skip_next == true`: the element is printed/eliminated, and `skip_next` flips to `false`.
  - When a round finishes, the remaining survivors form the circle for the next round, and the value of `skip_next` carries over seamlessly into the next round!
  - **Complexity Insight**:
    - Round 1 processes $n$ children.
    - Round 2 processes $\approx n / 2$ children.
    - Round 3 processes $\approx n / 4$ children.
    - Total work across all rounds is:
      $$n + \frac{n}{2} + \frac{n}{4} + \dots = 2n = \mathcal{O}(n)$$
  - This solves the problem in strictly **linear $\mathcal{O}(n)$ time** without any balanced trees, segment trees, or Policy-Based Data Structures!
- **Signal**: Josephus with step size $k = 1$ (skipping every second child) admits an exact $\mathcal{O}(n)$ round-halving simulation.

---

## 3. Approach 1 — Naive / Baseline (`std::vector::erase`)

Maintain `std::vector<int>` of size $n$, computing `idx = (idx + 1) % size` and erasing `vec.erase(vec.begin() + idx)`.
Because `std::vector::erase` shifts all subsequent elements in $\mathcal{O}(n)$, the total time is $\mathcal{O}(n^2) = 4 \cdot 10^{10}$ operations $\implies$ TLE.

---

## 4. Approach 2 — Intermediate (Policy-Based Data Structure `ordered_set`)

Using GNU C++ PBDS `tree<int, null_type, ...>` with `find_by_order(idx)` to locate the $k$-th remaining child and delete in $\mathcal{O}(\log n)$ time.
While $\mathcal{O}(n \log n)$ and necessary for the generalized Josephus Problem II (where $k \le 10^9$), for $k = 1$ round-halving (Approach 3) is strictly $\mathcal{O}(n)$ and $10\times$ faster.

---

## 5. Approach 3 — Optimal CSES Solution (Round Halving in Strictly $\mathcal{O}(n)$)

### Idea
Maintain a `vector<int> current` initialized to $[1, 2, \dots, n]$ and a boolean `bool skip = false`.
While `current` is non-empty:
- Create `vector<int> next_round`.
- For each person $x$ in `current`:
  - If `skip` is true: print $x$ (eliminated), toggle `skip = false`.
  - If `skip` is false: keep $x$ in `next_round`, toggle `skip = true`.
- Move `next_round` into `current`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <numeric>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> current(n);
    iota(current.begin(), current.end(), 1);

    bool skip = false; // Start at index 0: skip person 1, remove person 2

    while (!current.empty()) {
        vector<int> next_round;
        next_round.reserve(current.size() / 2 + 1);

        for (int x : current) {
            if (skip) {
                cout << x << ' ';
            } else {
                next_round.push_back(x);
            }
            skip = !skip;
        }

        current = move(next_round);
    }

    cout << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n)$. The number of elements processed in round $j$ is $\le \lceil n / 2^j \rceil$.
  $$\sum_{j=0}^{\lceil \log_2 n \rceil} \frac{n}{2^j} < 2n$$
  For $n = 2 \cdot 10^5$, total loop iterations $\le 4 \cdot 10^5$, completing in $\approx 0.02$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ storage for `current` and `next_round` vectors.

---

## 6. Correctness Proof

1. **Cycle Preservation**:
   The sequence of children visited in round $j$ represents the cyclic ordering of active survivors.
   Because the state variable `skip` preserves whether the immediately preceding child was skipped or eliminated, the alternating pattern `(skip, eliminate, skip, eliminate, ...)` is maintained unbroken across the wrap-around boundary between consecutive rounds.
2. **Exhaustive Elimination**:
   In each round of size $m \ge 2$, at least $\lfloor m / 2 \rfloor \ge 1$ children are eliminated.
   When $m = 1$, the single remaining child is eliminated on its second visit (as `skip` toggles to true).
   Hence the number of survivors strictly decreases to 0.
3. **Equivalence to Circle Elimination**:
   Because every child is eliminated if and only if exactly one active child was skipped since the previous elimination, the simulation matches the physical rules of the Josephus game. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 7$.
Initial: `current = [1, 2, 3, 4, 5, 6, 7]`, `skip = false`.

- **Round 1**:
  - $x = 1$: `skip = false` $\implies$ keep 1, `skip` $\to$ true.
  - $x = 2$: `skip = true` $\implies$ **eliminate 2**, `skip` $\to$ false.
  - $x = 3$: `skip = false` $\implies$ keep 3, `skip` $\to$ true.
  - $x = 4$: `skip = true` $\implies$ **eliminate 4**, `skip` $\to$ false.
  - $x = 5$: `skip = false` $\implies$ keep 5, `skip` $\to$ true.
  - $x = 6$: `skip = true` $\implies$ **eliminate 6**, `skip` $\to$ false.
  - $x = 7$: `skip = false` $\implies$ keep 7, `skip` $\to$ true.
  - Output: `2 4 6`. Survivors: `[1, 3, 5, 7]`. `skip = true`.
- **Round 2** (`skip = true` carries over!):
  - $x = 1$: `skip = true` $\implies$ **eliminate 1**, `skip` $\to$ false.
  - $x = 3$: `skip = false` $\implies$ keep 3, `skip` $\to$ true.
  - $x = 5$: `skip = true` $\implies$ **eliminate 5**, `skip` $\to$ false.
  - $x = 7$: `skip = false` $\implies$ keep 7, `skip` $\to$ true.
  - Output: `2 4 6 1 5`. Survivors: `[3, 7]`. `skip = true`.
- **Round 3** (`skip = true`):
  - $x = 3$: `skip = true` $\implies$ **eliminate 3**, `skip` $\to$ false.
  - $x = 7$: `skip = false` $\implies$ keep 7, `skip` $\to$ true.
  - Output: `2 4 6 1 5 3`. Survivors: `[7]`. `skip = true`.
- **Round 4** (`skip = true`):
  - $x = 7$: `skip = true` $\implies$ **eliminate 7**, `skip` $\to$ false.
  - Output: `2 4 6 1 5 3 7`. Survivors: `[]`.

Final Output: `2 4 6 1 5 3 7`. Exactly matches example!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1$**: Child 1 is skipped on first touch (`skip = false` $\to$ true, kept), then eliminated in the second pass. Outputs `1`.
- **$n$ is a power of 2 (e.g. $n = 4$)**:
  Eliminates `2 4`, survivors `[1, 3]`, eliminates `1`, eliminates `3`. Handled cleanly.
- **Fast I/O**: Printing $2 \cdot 10^5$ integers with spaces requires `cin.tie(nullptr)`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How to find ONLY the last remaining survivor in $\mathcal{O}(1)$ math?**
   - The famous Josephus formula for $k = 1$: write $n = 2^m + l$ where $0 \le l < 2^m$. The last survivor is $W(n) = 2l + 1$!
     (e.g. for $n = 7 = 4 + 3$, survivor is $2(3) + 1 = 7$).
2. **How to solve for arbitrary skip size $k$ (Josephus Problem II)?**
   - When $k$ is large, we cannot use round halving. We use a **Policy-Based Data Structure (PBDS)** `ordered_set` or a **Fenwick Tree with binary lifting** to locate the $((cur + k) \bmod \text{size})$-th element in $\mathcal{O}(\log n)$ time.
3. **What if $n$ is up to $10^{18}$ and we only want the last survivor for general $k$?**
   - Use the dynamic programming transition $J(n, k) = (J(n-1, k) + k) \bmod n$, accelerated when $k \ll n$ by skipping $\lfloor (n - 1 - J) / k \rfloor$ steps at once in $\mathcal{O}(k \log n)$.
4. **How would you implement this with a circularly linked list?**
   - A circularly linked list takes $\mathcal{O}(n)$ time since each elimination traverses 2 pointers. However, memory allocations and cache misses make vector halving faster.
5. **Why is `vector::reserve` important in the loop?**
   - `next_round.reserve(current.size() / 2 + 1)` prevents dynamic reallocation of the survivors vector.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Simulation, Josephus, Halving, Amortized Analysis, Queues.
- **Time Complexity**: $\mathcal{O}(n)$ strictly linear time.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary memory.

### Related CSES Tasks
- [CSES 2163 - Josephus Problem II](https://cses.fi/problemset/task/2163): Generalized skip size $k$ via PBDS `ordered_set`.
- [CSES 1070 - Permutations](https://cses.fi/problemset/task/1070): Parity-based ordering.
- [CSES 2165 - Tower of Hanoi](https://cses.fi/problemset/task/2165): Recursive elimination mechanics.
