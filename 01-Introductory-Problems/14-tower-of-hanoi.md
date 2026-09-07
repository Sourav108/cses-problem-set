# Tower of Hanoi (CSES Task 2165 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 2165 - Tower of Hanoi](https://cses.fi/problemset/task/2165)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: The Tower of Hanoi puzzle consists of three stacks (numbered 1, 2, and 3) and $n$ disks of different sizes. Initially, stack 1 has all $n$ disks sorted in increasing size from top to bottom. The goal is to move all disks to stack 3 using stack 2 as intermediate. On each move, you can move the topmost disk of one stack to another stack, provided you never place a larger disk on top of a smaller disk. Your task is to find a solution with the minimum number of moves.
- **Constraints**: $1 \le n \le 16$.

---

## 1. Problem, Restated

Find and print the sequence of moves that transfers $n$ disks from stack 1 to stack 3 obeying the Tower of Hanoi rules in the theoretical minimum number of moves.

**Input**: A single integer $n$ via `cin`.  
**Output**: First line contains the minimum number of moves $K$. Next $K$ lines each contain two integers $a$ and $b$ (representing a disk move from stack $a$ to stack $b$) on `cout`.  
**Key Constraints**: $1 \le n \le 16$. The minimum move count is $2^n - 1$. For $n = 16$, $2^{16} - 1 = 65,535$ moves. The algorithm must execute in $\mathcal{O}(2^n)$ time with minimal stack overhead.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Divide and Conquer / Structural Recursion / State Transitions.
- **Aha! Insight**:
  - To move disk $n$ (the largest disk) from stack 1 to stack 3:
    1. Disks $1 \dots n-1$ must not be on stack 1 (because disk $n$ cannot move until it is on top).
    2. Disks $1 \dots n-1$ must not be on stack 3 (because disk $n$ cannot be placed on top of any smaller disk).
    3. Therefore, all $n - 1$ smaller disks must be on stack 2!
  - This directly yields the canonical 3-step divide-and-conquer recurrence:
    1. Recursively move $n - 1$ disks from stack `from` to stack `aux` (using `to` as temporary).
    2. Move disk $n$ directly from stack `from` to stack `to`.
    3. Recursively move $n - 1$ disks from stack `aux` to stack `to` (using `from` as temporary).
  - Move recurrence: $M(n) = 2 M(n - 1) + 1$, with base case $M(1) = 1$.
  - Solving the recurrence: $M(n) = 2^n - 1$.
- **Signal**: Moving a pyramid of elements subject to strict size-monotonicity constraints is the archetypal Tower of Hanoi divide-and-conquer problem.

---

## 3. Approach 1 — Naive / Baseline (Breadth-First Search on State Space)

### Idea
Model each stack configuration as a state $(s_1, s_2, s_3)$ and run BFS to find the shortest path from $[1 \dots n], [], []$ to $[], [], [1 \dots n]$.

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(3^n)$ states and transitions.
- **Space Complexity**: $\mathcal{O}(3^n)$ memory.
- **CSES Verdict**: TLE and MLE for $n \ge 10$ ($3^{16} \approx 4.3 \times 10^7$ state objects).

---

## 4. Approach 2 — Intermediate (Iterative Binary-Reflected Gray Code)

Disks can be moved iteratively without recursion using the binary representation of step $k \in [1, 2^n - 1]$: the disk to move is the number of trailing zeros in $k$, and the target stack depends on whether $n$ is even or odd.
The recursive solution below is more intuitive, concise, and equally optimal.

---

## 5. Approach 3 — Optimal CSES Solution (Divide and Conquer in $\mathcal{O}(2^n)$)

### Idea
Compute and print $2^n - 1$ first. Then execute the recursive procedure `hanoi(n, 1, 3, 2)`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>

using namespace std;

void hanoi(int n, int from, int to, int aux) {
    if (n == 0) return;
    // Step 1: Move n - 1 disks from 'from' to 'aux' using 'to'
    hanoi(n - 1, from, aux, to);

    // Step 2: Move disk n from 'from' to 'to'
    cout << from << ' ' << to << '\n';

    // Step 3: Move n - 1 disks from 'aux' to 'to' using 'from'
    hanoi(n - 1, aux, to, from);
}

int main() {
    // Standardized Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    // Minimum moves: 2^n - 1
    int total_moves = (1 << n) - 1;
    cout << total_moves << '\n';

    // Output sequence of moves
    hanoi(n, 1, 3, 2);

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(2^n)$ — exactly $2^n - 1$ recursive calls that print a move. For $n = 16$, $2^{16} - 1 = 65,535$ operations, completing in $\approx 5$ ms.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary recursion stack depth. For $n = 16$, the stack uses negligible memory ($\approx$ a few kilobytes).
- **Optimality Guarantee**: Matches the theoretical lower bound $2^n - 1$ (as proven below) and comfortably satisfies the CSES limits.

---

## 6. Correctness Proof

- **Inductive Invariant**: For any $k \ge 1$, `hanoi(k, A, B, C)` transfers the top $k$ disks from stack $A$ to stack $B$ using stack $C$ without violating the size invariant, assuming all other disks present on stacks $A, B, C$ are strictly larger than the top $k$ disks.
- **Base Case ($k = 1$)**: Moving 1 disk from $A$ to $B$ takes 1 move. Because any existing disks on $B$ are strictly larger than disk 1, the move is legal.
- **Inductive Step**:
  - Assume the procedure correctly transfers $k - 1$ disks between any pair of pegs in $2^{k-1} - 1$ moves.
  - Step 1: Transfers disks $1 \dots k-1$ from $A$ to $C$. By hypothesis, this is legal and leaves disk $k$ on top of $A$.
  - Step 2: Moves disk $k$ from $A$ to $B$. This is legal because stack $B$ only contains disks larger than $k$, and disk $k$ is currently the top of $A$.
  - Step 3: Transfers disks $1 \dots k-1$ from $C$ to $B$. By hypothesis, this is legal and places all $k - 1$ disks on top of disk $k$ on $B$.
  - Total moves: $M(k) = M(k - 1) + 1 + M(k - 1) = 2M(k - 1) + 1$.
  - By induction, $M(n) = 2^n - 1$.
- **Proof of Minimality (Lower Bound)**:
  - To transfer $n$ disks from 1 to 3, disk $n$ must move from 1 to 3 at least once.
  - At the moment disk $n$ moves, disks $1 \dots n-1$ cannot be on stack 1 (or disk $n$ would not be on top) and cannot be on stack 3 (or disk $n$ would be placed on top of a smaller disk).
  - Thus, disks $1 \dots n-1$ must reside entirely on stack 2. Reaching this configuration requires at least $M(n-1)$ moves.
  - Moving disk $n$ requires 1 move.
  - Moving disks $1 \dots n-1$ from stack 2 to stack 3 requires at least $M(n-1)$ moves.
  - Therefore, any valid move sequence requires at least $M(n-1) + 1 + M(n-1) = 2M(n-1) + 1$ moves.
  - Hence, $M(n) = 2^n - 1$ is the absolute minimum.

---

## 7. Dry Run & Visual State Trace

Input: `n = 3` (Total moves $2^3 - 1 = 7$)

```
Initial: Stack 1: [3, 2, 1], Stack 2: [], Stack 3: []
```

| Move # | Move Command | Stack 1 | Stack 2 | Stack 3 | Description |
|:---:|:---:|:---:|:---:|:---:|:---|
| 1 | `1 3` | `[3, 2]` | `[]` | `[1]` | Disk 1 to 3 |
| 2 | `1 2` | `[3]` | `[2]` | `[1]` | Disk 2 to 2 |
| 3 | `3 2` | `[3]` | `[2, 1]` | `[]` | Disk 1 to 2 (top 2 disks now on stack 2) |
| 4 | `1 3` | `[]` | `[2, 1]` | `[3]` | Disk 3 to 3 (largest disk placed!) |
| 5 | `2 1` | `[1]` | `[2]` | `[3]` | Disk 1 to 1 |
| 6 | `2 3` | `[1]` | `[]` | `[3, 2]` | Disk 2 to 3 |
| 7 | `1 3` | `[]` | `[]` | `[3, 2, 1]` | Disk 1 to 3 (Complete!) |

Total moves: 7 ✅

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1$**: Outputs `1\n1 3\n`.
- **$n = 16$**: $2^{16} - 1 = 65,535$. `1 << n` with $n = 16$ is safe from signed integer overflow.
- **Fast I/O**: Generating 65,535 lines of moves requires `cin.tie(nullptr)` and `'\n'` to avoid stream flushing.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Q1: What if there are 4 stacks instead of 3 (Reve's Puzzle / Frame-Stewart Algorithm)?**
   - **A**: The optimal strategy partitions $n$ into $k$ and $n-k$ disks: move $k$ disks to an auxiliary stack using 4 stacks, move the remaining $n-k$ disks to destination using 3 stacks, and move the $k$ disks to destination using 4 stacks. Choosing $k \approx n - \lfloor \sqrt{2n} \rfloor$ achieves sub-exponential $\mathcal{O}(2^{\sqrt{2n}})$ moves.
2. **Q2: What is the $k$-th move without generating all previous moves?**
   - **A**: The disk moved at step $k$ is determined by the lowest set bit of $k$ (`__builtin_ctz(k) + 1`). The source and destination pegs can be determined via modular arithmetic on the ternary cycle.
3. **Q3: What if certain transitions between pegs are forbidden (e.g., no direct moves between 1 and 3)?**
   - **A**: Every move between 1 and 3 must pass through 2. The recurrence becomes $M(n) = 3M(n-1) + 2 \implies M(n) = 3^n - 1$.
4. **Q4: What if disks are initially placed in an arbitrary valid configuration across pegs?**
   - **A**: Greedily identify the largest disk $d$ not yet on its target peg. Move all smaller disks $1 \dots d-1$ to the unique third peg, move disk $d$, and recurse. Total moves is at most $2^n - 1$.
5. **Q5: Can we solve the problem non-recursively with a simple while loop?**
   - **A**: Yes. Alternating rule: On odd moves, move the smallest disk clockwise (or counter-clockwise depending on parity of $n$). On even moves, make the only legal move that does not involve the smallest disk.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `Recursion`, `Divide-and-Conquer`, `Combinatorics`, `Fast-IO`
- **Complexity Summary**:
  - **Time**: $\mathcal{O}(2^n)$
  - **Space**: $\mathcal{O}(n)$ recursion depth
- **Related CSES Problems**:
  - **[CSES 2205 - Gray Code](https://cses.fi/problemset/task/2205)**: Sequential transitions identical to Hanoi moves.
  - **[CSES 1622 - Creating Strings](https://cses.fi/problemset/task/1622)**: Permutations and recursive branching.
  - **[CSES 1623 - Apple Division](https://cses.fi/problemset/task/1623)**: Complete search across $2^n$ binary choices.
