# Two Knights (CSES Task 1072 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1072 - Two Knights](https://cses.fi/problemset/task/1072)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Your task is to count for $k = 1, 2, \dots, n$ the number of ways two knights can be placed on a $k \times k$ chessboard so that they do not attack each other.
- **Constraints**: $1 \le n \le 10000$.

---

## 1. Problem, Restated

For each integer board dimension $k \in [1, n]$, determine the number of distinct configurations of placing 2 identical, non-attacking knights on a $k \times k$ grid. Print the answer for each $k$ on a new line.

**Input**: A single integer $n$ via `cin`.  
**Output**: $n$ lines, where line $k$ contains the count of valid non-attacking knight pairs.  
**Critical Constraints**: $n \le 10000$. An $\mathcal{O}(k^4)$ brute-force iteration over all square pairs for each $k$ gives $\mathcal{O}(n^5)$ operations, which will heavily TLE. Even an $\mathcal{O}(k^2)$ per board computation gives $\mathcal{O}(n^3) \approx 10^{12}$ operations. A closed-form $\mathcal{O}(1)$ formula per $k$ yielding $\mathcal{O}(n)$ total time is mandatory. Furthermore, for $k = 10000$, total pairs $\approx \frac{k^4}{2} \approx 5 \cdot 10^{15}$, exceeding 32-bit signed integers and requiring 64-bit `long long`.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Complementary Counting / Combinatorics on Grids / Geometry of Pieces.
- **Aha! Insight**:
  Instead of directly counting non-attacking pairs, compute:
  $$\text{Valid Pairs} = \text{Total Pairs} - \text{Attacking Pairs}$$
  1. **Total Pairs**: Two squares chosen from $k^2$ squares without replacement:
     $$\binom{k^2}{2} = \frac{k^2(k^2 - 1)}{2}$$
  2. **Attacking Pairs**: Two knights attack each other if and only if one knight's move forms an "L-shape" ($2 \times 1$ or $1 \times 2$). Notice that two attacking knights are always located at opposite diagonally opposite corners of a $2 \times 3$ or $3 \times 2$ bounding rectangle!
     - Every $2 \times 3$ rectangle contains exactly 2 attacking knight pairs (the two main diagonals).
     - How many $2 \times 3$ rectangles fit in a $k \times k$ board? $(k - 1) \times (k - 2)$.
     - Every $3 \times 2$ rectangle contains exactly 2 attacking knight pairs.
     - How many $3 \times 2$ rectangles fit in a $k \times k$ board? $(k - 2) \times (k - 1)$.
     - Total attacking pairs:
       $$2(k - 1)(k - 2) + 2(k - 2)(k - 1) = 4(k - 1)(k - 2)$$
  3. **Closed-Form Formula**:
     $$\text{ans}(k) = \frac{k^2(k^2 - 1)}{2} - 4(k - 1)(k - 2)$$
- **Signal**: Counting non-attacking pieces on regular symmetric grids is the classic signature of complementary counting via bounding bounding subgrids.

---

## 3. Approach 1 — Naive / Baseline (Pairwise Grid Simulation)

### Idea
Iterate over all pairs of squares $(r_1, c_1)$ and $(r_2, c_2)$, and verify whether $|r_1 - r_2| \cdot |c_1 - c_2| == 2$.

### C++17 Code
```cpp
#include <iostream>
#include <cmath>

using namespace std;

int main() {
    int n;
    if (!(cin >> n)) return 0;

    for (long long k = 1; k <= n; k++) {
        long long count = 0;
        for (long long r1 = 0; r1 < k; r1++) {
            for (long long c1 = 0; c1 < k; c1++) {
                for (long long r2 = r1; r2 < k; r2++) {
                    for (long long c2 = (r2 == r1 ? c1 + 1 : 0); c2 < k; c2++) {
                        long long dr = abs(r1 - r2);
                        long long dc = abs(c1 - c2);
                        if (!( (dr == 1 && dc == 2) || (dr == 2 && dc == 1) )) {
                            count++;
                        }
                    }
                }
            }
        }
        cout << count << '\n';
    }
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\sum_{k=1}^n \mathcal{O}(k^4) = \mathcal{O}(n^5)$ operations. For $n = 10000$, this is $\sim 10^{20}$, an impossible runtime.
- **Space Complexity**: $\mathcal{O}(1)$.
- **CSES Verdict**: TLE for $n > 50$.

---

## 4. Approach 2 — Intermediate (Iterating Single Knight Moves)

Place the first knight at $(r, c)$, count its valid attack squares inside the board, and sum over all $(r, c)$ in $\mathcal{O}(k^2)$ per board. Total time $\sum_{k=1}^n \mathcal{O}(k^2) = \mathcal{O}(n^3) \approx 10^{12}$ operations, still TLE for $n = 10000$.

---

## 5. Approach 3 — Optimal CSES Solution (Closed-Form Combinatorics in $\mathcal{O}(n)$)

### Idea
Evaluate the closed-form formula $\frac{k^2(k^2 - 1)}{2} - 4(k - 1)(k - 2)$ directly for each $k \in [1, n]$ in $\mathcal{O}(1)$ arithmetic operations using `long long`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>

using namespace std;

int main() {
    // Standardized Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    for (long long k = 1; k <= n; k++) {
        long long total_positions = k * k;
        long long total_pairs = total_positions * (total_positions - 1) / 2;
        long long attacking_pairs = 4 * (k - 1) * (k - 2);

        cout << total_pairs - attacking_pairs << '\n';
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(1)$ arithmetic operations per $k \implies \mathcal{O}(n)$ total time. For $n = 10000$, executes in $\approx 2$ ms.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary space.
- **Optimality Guarantee**: Printing $n$ integers requires $\Omega(n)$ operations, matching the theoretical lower bound.

---

## 6. Correctness Proof

- **Universe of Configurations**: The chessboard contains $k^2$ distinct cells. The number of ways to place 2 indistinguishable knights without restriction is the combination $\binom{k^2}{2} = \frac{k^2(k^2 - 1)}{2}$.
- **Characterization of Knight Attacks**: Two cells $(r_1, c_1)$ and $(r_2, c_2)$ threaten each other under knight movement rules if and only if $\{|r_1 - r_2|, |c_1 - c_2|\} = \{1, 2\}$.
- **Bijection to Subgrids**:
  - The minimal bounding box enclosing two attacking cells has dimensions either $2 \times 3$ (vertical difference 1, horizontal difference 2) or $3 \times 2$ (vertical difference 2, horizontal difference 1).
  - In any $2 \times 3$ subgrid, exactly 2 pairs of cells threaten each other: the diagonal pairs $((r, c), (r+1, c+2))$ and $((r+1, c), (r, c+2))$.
  - In any $3 \times 2$ subgrid, exactly 2 pairs of cells threaten each other: $((r, c), (r+2, c+1))$ and $((r+2, c), (r, c+1))$.
  - No two distinct $2 \times 3$ or $3 \times 2$ subgrids share the same pair of opposite corners; thus each attacking pair belongs to a unique minimal bounding box.
- **Counting Bounding Boxes**:
  - A $2 \times 3$ box requires 2 consecutive rows and 3 consecutive columns. In a $k \times k$ board, there are $(k - 2 + 1) = (k - 1)$ row choices and $(k - 3 + 1) = (k - 2)$ column choices, yielding $(k - 1)(k - 2)$ boxes.
  - By symmetry, there are $(k - 2)(k - 1)$ boxes of size $3 \times 2$.
  - Total attacking pairs $= 2(k - 1)(k - 2) + 2(k - 2)(k - 1) = 4(k - 1)(k - 2)$.
- **Base Cases**:
  - For $k = 1$: $\binom{1}{2} = 0$, $4(0)(-1) = 0 \implies 0 - 0 = 0$. Correct.
  - For $k = 2$: $\binom{4}{2} = 6$, $4(1)(0) = 0 \implies 6 - 0 = 6$. Correct.
- **Conclusion**: By the principle of complementary counting, subtracting attacking pairs from total pairs gives the exact number of non-attacking configurations for all $k \ge 1$.

---

## 7. Dry Run & Visual State Trace

| $k$ | Total Cells $k^2$ | Total Pairs $\binom{k^2}{2}$ | $4(k-1)(k-2)$ | Attacking Pairs | Answer |
|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | 1 | 0 | $4(0)(-1) = 0$ | 0 | **0** |
| 2 | 4 | $4 \times 3 / 2 = 6$ | $4(1)(0) = 0$ | 0 | **6** |
| 3 | 9 | $9 \times 8 / 2 = 36$ | $4(2)(1) = 8$ | 8 | **28** |
| 4 | 16 | $16 \times 15 / 2 = 120$ | $4(3)(2) = 24$ | 24 | **96** |
| 5 | 25 | $25 \times 24 / 2 = 300$ | $4(4)(3) = 48$ | 48 | **252** |

Outputs match sample output precisely ✅

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$k = 1$ and $k = 2$**: No $2 \times 3$ or $3 \times 2$ rectangles fit on the board, so $(k-1)(k-2)$ evaluates to 0. Correctly yields 0 and 6 without special conditionals.
- **64-bit Integer Overflow**: For $k = 10000$:
  - $k^2 = 10^8$.
  - $k^2(k^2 - 1) \approx 10^{16}$.
  - Storing intermediate values in 32-bit `int` causes catastrophic overflow. Using `long long` for all calculations prevents overflow.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Q1: What if we place 2 Rooks instead of 2 Knights?**
   - **A**: Two rooks do not attack if they are in different rows and different columns. First rook has $k^2$ choices. Second rook must be placed in one of the $(k-1)^2$ non-conflicting cells. Dividing by $2!$ yields $\frac{k^2(k-1)^2}{2}$.
2. **Q2: What if the board is rectangular $M \times N$ instead of square $k \times k$?**
   - **A**: The formula generalizes directly: $\binom{MN}{2} - 2(M-1)(N-2) - 2(M-2)(N-1)$ for $M, N \ge 2$.
3. **Q3: What if we want to place $K > 2$ non-attacking knights?**
   - **A**: For arbitrary $K$, this is the Maximum Independent Set on a bipartite graph (since knights only attack opposite color squares), solvable in polynomial time via Maximum Bipartite Matching (König's theorem).
4. **Q4: What if the board wraps around toroidally (Pac-Man board)?**
   - **A**: On a torus, every knight has degree exactly 8 regardless of position. Total attacking pairs $= \frac{k^2 \times 8}{2} = 4k^2$ (for $k \ge 5$). Non-attacking pairs $= \binom{k^2}{2} - 4k^2$.
5. **Q5: Can we compute the sum of answers for all $k$ from $1$ to $n$ in $\mathcal{O}(1)$ time?**
   - **A**: Yes! Expanding the polynomial gives a degree-4 polynomial in $k$. Applying Faulhaber's formulas ($\sum k^4, \sum k^3, \dots$) yields an explicit closed-form $\mathcal{O}(1)$ formula for the sum.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `Math`, `Combinatorics`, `Complementary-Counting`, `Geometry`, `Fast-IO`
- **Complexity Summary**:
  - **Time**: $\mathcal{O}(n)$ total ($\mathcal{O}(1)$ per $k$)
  - **Space**: $\mathcal{O}(1)$ auxiliary space
- **Related CSES Problems**:
  - **[CSES 1071 - Number Spiral](https://cses.fi/problemset/task/1071)**: Closed-form grid arithmetic.
  - **[CSES 1624 - Chessboard and Queens](https://cses.fi/problemset/task/1624)**: Backtracking placement on chessboards.
  - **[CSES 1092 - Two Sets](https://cses.fi/problemset/task/1092)**: Combinatorial partitioning of natural numbers.
