# Number Spiral (CSES Task 1071 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1071 - Number Spiral](https://cses.fi/problemset/task/1071)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: A number spiral is an infinite grid whose upper-left square has number 1. Here are the first five layers:
  ```
  1   2   9  10  25
  4   3   8  11  24
  5   6   7  12  23
  16 15  14  13  22
  17 18  19  20  21
  ```
  Your task is to find out the number in row $y$ and column $x$ (1-indexed).
- **Constraints**: $1 \le t \le 10^5$ test cases. $1 \le y, x \le 10^9$.

---

## 1. Problem, Restated

Given coordinates $(y, x)$ in a 1-indexed spiral grid where numbers increment in concentric square shells, return the number at $(y, x)$ in $\mathcal{O}(1)$ time per query across $t \le 10^5$ independent test cases.

**Input**: First line contains $t$. The next $t$ lines each contain two integers $y$ and $x$ via `cin`.  
**Output**: For each test case, print the number on `cout` ending with `\n`.  
**Critical Constraints**: $y, x \le 10^9$. The maximum cell value can reach $(10^9)^2 = 10^{18}$, which drastically exceeds 32-bit signed integers ($2 \cdot 10^9$). Storing or calculating cells requires 64-bit unsigned/signed integers (`long long`). Simulating grid cells $\mathcal{O}(y \cdot x)$ will cause severe TLE/MLE. An explicit closed-form $\mathcal{O}(1)$ formula is required.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Coordinate Math / Geometric Shell Decomposition / Closed-Form Reduction.
- **Aha! Insight**:
  - Notice that each cell $(y, x)$ belongs to a square shell (layer) of size $m = \max(y, x)$.
  - The inner square of dimension $(m - 1) \times (m - 1)$ contains exactly $(m - 1)^2$ numbers.
  - Therefore, the $m$-th shell occupies the value range $[(m - 1)^2 + 1, m^2]$.
  - The shell orientation alternates with the parity of $m$:
    - **When $m$ is even**: Values increase downwards along column $m$ from row 1 to $m$, then decrease leftwards along row $m$ from column $m$ to 1. The maximum value $m^2$ occurs at $(m, 1)$.
      - If row $y == m$: $\text{val} = m^2 - (x - 1)$.
      - If column $x == m$: $\text{val} = (m - 1)^2 + y$.
    - **When $m$ is odd**: Values increase rightwards along row $m$ from column 1 to $m$, then decrease upwards along column $m$ from row $m$ to 1. The maximum value $m^2$ occurs at $(1, m)$.
      - If column $x == m$: $\text{val} = m^2 - (y - 1)$.
      - If row $y == m$: $\text{val} = (m - 1)^2 + x$.
- **Signal**: Grid numbering following concentric geometric contours with coordinates up to $10^9$ signals layer-based closed-form math.

---

## 3. Approach 1 — Naive / Baseline (Matrix Generation / Simulation)

### Idea
Preallocate or iteratively simulate the spiral layer by layer up to $\max(y, x)$ to locate the cell.

### C++17 Code
```cpp
#include <iostream>
#include <algorithm>

using namespace std;

int main() {
    int t;
    if (!(cin >> t)) return 0;
    while (t--) {
        long long y, x;
        cin >> y >> x;
        long long curr = 1;
        long long cy = 1, cx = 1;
        // Step-by-step traversal along the spiral
        // Impossible for coordinates up to 10^9!
        if (y == 1 && x == 1) {
            cout << 1 << '\n';
        } else {
            // Placeholder: Simulation TLEs immediately
            cout << -1 << '\n';
        }
    }
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(\max(y, x)^2)$ per testcase $\approx 10^{18}$ steps.
- **Space Complexity**: $\mathcal{O}(1)$ or $\mathcal{O}(\max(y, x)^2)$ if storing a grid.
- **CSES Verdict**: TLE and MLE.

---

## 4. Approach 2 — Intermediate (Binary Search on Layers)

Binary searching the layer $m$ is redundant because $m = \max(y, x)$ is directly computable in $\mathcal{O}(1)$.
No meaningful intermediate step — the optimal closed-form solution below computes the answer in $\mathcal{O}(1)$ operations directly.

---

## 5. Approach 3 — Optimal CSES Solution (Closed-Form Parity Math)

### Idea
Compute $m = \max(y, x)$ in $\mathcal{O}(1)$. Based on whether $m$ is even or odd, branch into checking whether $(y, x)$ is on the horizontal row edge ($y = m$) or vertical column edge ($x = m$). Compute the offset from $(m-1)^2$ or $m^2$ using 64-bit arithmetic.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <algorithm>

using namespace std;

void solve() {
    long long y, x;
    cin >> y >> x;

    long long m = max(y, x);

    if (m % 2 == 0) {
        // Even layer: values increase along col m down to (m, m), then decrease along row m to (m, 1)
        if (y == m) {
            cout << m * m - x + 1 << '\n';
        } else {
            cout << (m - 1) * (m - 1) + y << '\n';
        }
    } else {
        // Odd layer: values increase along row m right to (m, m), then decrease along col m to (1, m)
        if (x == m) {
            cout << m * m - y + 1 << '\n';
        } else {
            cout << (m - 1) * (m - 1) + x << '\n';
        }
    }
}

int main() {
    // Standardized Fast I/O for 10^5 test cases
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int t;
    if (cin >> t) {
        while (t--) {
            solve();
        }
    }
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(1)$ per testcase $\implies \mathcal{O}(t)$ total time for $t$ queries. For $t = 10^5$, executes in $\approx 15$ ms.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary memory.
- **Optimality Guarantee**: Each query requires reading $y, x$ and printing one number ($\Omega(1)$ per query), matching the theoretical lower bound.

---

## 6. Correctness Proof

- **Geometric Layer Boundary**: A cell $(y, x)$ satisfies $1 \le y, x \le m$ if and only if it lies inside the $m \times m$ square prefix. The cells added when expanding from $(m-1) \times (m-1)$ to $m \times m$ are precisely those with $\max(y, x) = m$. The total number of cells strictly inside smaller layers is $(m-1)^2$. Thus, the labels in layer $m$ form a bijection with $[(m-1)^2 + 1, m^2]$.
- **Even Layer Traversal**:
  - For even $m$, the spiral enters at $(1, m)$ and moves down to $(m, m)$, then left to $(m, 1)$.
  - Along the vertical segment $x = m$, the row index $y$ ranges from $1$ to $m$. The distance from entry is $y - 1$, so $\text{val} = (m-1)^2 + 1 + (y - 1) = (m-1)^2 + y$. At $(m, m)$, this yields $(m-1)^2 + m$.
  - Along the horizontal segment $y = m$, the column index $x$ decreases from $m$ to $1$. The terminal cell $(m, 1)$ receives $m^2$. For column $x$, the cell is $x - 1$ steps before the end, so $\text{val} = m^2 - (x - 1)$.
- **Odd Layer Traversal**:
  - For odd $m$, the spiral enters at $(m, 1)$ and moves right to $(m, m)$, then up to $(1, m)$.
  - Along the horizontal segment $y = m$, the distance from entry is $x - 1$, so $\text{val} = (m-1)^2 + x$.
  - Along the vertical segment $x = m$, the terminal cell $(1, m)$ receives $m^2$, so cell $(y, m)$ receives $m^2 - (y - 1)$.
- **Mutual Exclusivity & Completeness**: Because $\max(y, x) = m$, either $y = m$, $x = m$, or both. When $y = x = m$, both formulas yield $(m-1)^2 + m = m^2 - m + 1$, maintaining consistency. The formulas are exhaustive and exact.

---

## 7. Dry Run & Visual State Trace

Test Cases:
1. `(y = 2, x = 3)`: $m = \max(2, 3) = 3$ (odd layer).
   - $x == m \implies \text{val} = m^2 - y + 1 = 3^2 - 2 + 1 = 9 - 2 + 1 = 8$. (Grid shows row 2, col 3 is 8 ✅)
2. `(y = 4, x = 2)`: $m = \max(4, 2) = 4$ (even layer).
   - $y == m \implies \text{val} = m^2 - x + 1 = 4^2 - 2 + 1 = 16 - 2 + 1 = 15$. (Grid shows row 4, col 2 is 15 ✅)
3. `(y = 3, x = 3)`: $m = 3$ (odd layer).
   - $x == m \implies 3^2 - 3 + 1 = 7$. (Corner cell is 7 ✅)

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$y = 1, x = 1$ Corner**: $m = 1$ (odd). $x = m \implies 1^2 - 1 + 1 = 1$. Correct.
- **64-bit Overflow Trap**: $m$ can be $10^9$. $m^2 = 10^{18}$, which overflows 32-bit signed integers ($2.14 \times 10^9$) and 32-bit unsigned integers ($4.29 \times 10^9$). Using `long long` for $y, x, m$ is mandatory.
- **I/O Speed**: $t = 10^5$ queries require Fast I/O (`cin.tie(nullptr)`) and `'\n'` to avoid TLE.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Q1: What if the spiral starts winding in the opposite orientation (clockwise vs counter-clockwise)?**
   - **A**: The parity roles simply invert: odd $m$ behaves as even $m$, and even $m$ behaves as odd $m$.
2. **Q2: What is the inverse problem: given a value $V \le 10^{18}$, find its coordinates $(y, x)$?**
   - **A**: Compute $m = \lceil \sqrt{V} \rceil$ using integer square root `sqrtl`. Check $m$'s parity and determine whether $V$ falls on the horizontal or vertical wing by comparing with $(m-1)^2 + m$. Solve for $x$ or $y$ in $\mathcal{O}(1)$.
3. **Q3: What if the spiral is centered at $(0, 0)$ and expands in all 4 quadrants (Ulam Spiral)?**
   - **A**: The layer is $m = \max(|x|, |y|)$. Each layer has side length $2m + 1$ and contains $8m$ cells. The corners are $(2m-1)^2 + 2km$ for $k \in \{1, 2, 3, 4\}$.
4. **Q4: Can we query the sum of a subgrid $[y_1 \dots y_2] \times [x_1 \dots x_2]$?**
   - **A**: For large subgrids, use 2D inclusion-exclusion $S(y_2, x_2) - S(y_1-1, x_2) - S(y_2, x_1-1) + S(y_1-1, x_1-1)$, integrating layer areas using polynomial summation formulas ($\sum m^2, \sum m^3$).
5. **Q5: What if queries arrive in parallel across multiple threads?**
   - **A**: The closed-form function is purely stateless and functional ($\mathcal{O}(1)$ time, 0 shared memory), making it embarrassingly parallelizable.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `Math`, `Coordinate-Geometry`, `Closed-Form`, `Parity`, `Fast-IO`
- **Complexity Summary**:
  - **Time**: $\mathcal{O}(1)$ per query $\implies \mathcal{O}(t)$ total
  - **Space**: $\mathcal{O}(1)$ auxiliary space
- **Related CSES Problems**:
  - **[CSES 1072 - Two Knights](https://cses.fi/problemset/task/1072)**: Closed-form combinatorial counting on chessboard grids.
  - **[CSES 1068 - Weird Algorithm](https://cses.fi/problemset/task/1068)**: Foundational simulation and 64-bit integer handling.
  - **[CSES 2431 - Digit Queries](https://cses.fi/problemset/task/2431)**: Position math on expanding numerical layers.
