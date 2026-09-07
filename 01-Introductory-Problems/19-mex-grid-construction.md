# Mex Grid Construction (CSES Task 3419 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 3419 - Mex Grid Construction](https://cses.fi/problemset/task/3419)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Construct an $n \times n$ grid where each square $(r, c)$ contains the smallest non-negative integer that does not appear to the left in the same row or above in the same column ($\text{mex}$).
- **Constraints**: $1 \le n \le 100$.

---

## 1. Problem, Restated

Given an integer $n$, construct an $n \times n$ matrix $A$ indexed by rows $r \in [0, n-1]$ and columns $c \in [0, n-1]$.
Each entry $A[r][c]$ is defined recursively as:
$$A[r][c] = \text{mex}\Big(\{A[r][j] : 0 \le j < c\} \cup \{A[i][c] : 0 \le i < r\}\Big)$$
where $\text{mex}(S)$ (minimum excluded value) is the smallest non-negative integer not present in set $S$.

**Input**: A single line containing the integer $n$ ($1 \le n \le 100$).  
**Output**: Print the $n \times n$ grid of values, with each row on a new line and numbers separated by a single space.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Game Theory / Sprague-Grundy Theorem / Bitwise XOR (Nim-Addition).
- **Aha! Insight**:
  - Look at the example grid for $n = 5$:
    ```text
    0 1 2 3 4
    1 0 3 2 5
    2 3 0 1 6
    3 2 1 0 7
    4 5 6 7 0
    ```
  - Check bitwise XOR $r \oplus c$:
    - $0 \oplus 0 = 0,\quad 0 \oplus 1 = 1,\quad 0 \oplus 2 = 2,\quad 0 \oplus 3 = 3,\quad 0 \oplus 4 = 4$
    - $1 \oplus 0 = 1,\quad 1 \oplus 1 = 0,\quad 1 \oplus 2 = 3,\quad 1 \oplus 3 = 2,\quad 1 \oplus 4 = 5$
    - $2 \oplus 0 = 2,\quad 2 \oplus 1 = 3,\quad 2 \oplus 2 = 0,\quad 2 \oplus 3 = 1,\quad 2 \oplus 4 = 6$
    - $3 \oplus 0 = 3,\quad 3 \oplus 1 = 2,\quad 3 \oplus 2 = 1,\quad 3 \oplus 3 = 0,\quad 3 \oplus 4 = 7$
    - $4 \oplus 0 = 4,\quad 4 \oplus 1 = 5,\quad 4 \oplus 2 = 6,\quad 4 \oplus 3 = 7,\quad 4 \oplus 4 = 0$
  - Cell $(r, c)$ is **identically equal to $r \oplus c$**!
  - This is no coincidence: this 2D grid precisely models the Grundy values of a 2-pile game of Nim! A move in 2-pile Nim allows reducing either pile $r$ or pile $c$ to any strictly smaller non-negative value. By the Sprague-Grundy theorem, the Grundy value of a game consisting of independent piles of sizes $r$ and $c$ is their XOR sum: $G(r, c) = r \oplus c$.
- **Signal**: Any 2D minimum excluded value over leftward row cells and upward column cells is the standard Nim-sum grid $A[r][c] = r \oplus c$.

---

## 3. Approach 1 — Naive / Baseline (Direct Simulation with Sets)

### Idea
Iterate $r$ from $0$ to $n-1$ and $c$ from $0$ to $n-1$. At each cell, collect all elements in row $r$ left of $c$ and column $c$ above $r$ into an array or hash set. Find the smallest non-negative integer not in the set.

### C++17 Code
```cpp
#include <iostream>
#include <vector>
#include <vector>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<vector<int>> a(n, vector<int>(n, 0));
    vector<bool> seen(2 * n + 5, false);

    for (int r = 0; r < n; ++r) {
        for (int c = 0; c < n; ++c) {
            fill(seen.begin(), seen.end(), false);
            for (int j = 0; j < c; ++j) {
                if (a[r][j] < (int)seen.size()) seen[a[r][j]] = true;
            }
            for (int i = 0; i < r; ++i) {
                if (a[i][c] < (int)seen.size()) seen[a[i][c]] = true;
            }
            int mex = 0;
            while (mex < (int)seen.size() && seen[mex]) {
                ++mex;
            }
            a[r][c] = mex;
        }
    }

    for (int r = 0; r < n; ++r) {
        for (int c = 0; c < n; ++c) {
            cout << a[r][c] << (c + 1 == n ? '\n' : ' ');
        }
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n^3)$ — for each of the $n^2$ cells, we scan up to $2n$ predecessors. For $n = 100$, $100^3 = 10^6$ operations, which passes well within 1.0s.
- **Space Complexity**: $\mathcal{O}(n^2)$ to store the grid.

---

## 4. Approach 2 — Intermediate (Fast Bitset Mex Simulation)

Instead of searching a boolean vector, store row and column presences in bitsets:
`row_mask[r]` and `col_mask[c]`.
At cell $(r, c)$, take `combined = row_mask[r] | col_mask[c]`. The mex is the position of the lowest unset bit: `__builtin_ctz(~combined)`.
This reduces simulation time to $\mathcal{O}(n^2)$, but requires state management when a simple $\mathcal{O}(1)$ closed form exists.

---

## 5. Approach 3 — Optimal CSES Solution (Direct Bitwise XOR Closed Form)

### Idea
Compute each cell directly as $A[r][c] = r \oplus c$ using the C++ bitwise XOR operator `^`.
No intermediate grid storage is even required—we can stream the answers directly to standard output!

### C++17 Contest-Ready Code
```cpp
#include <iostream>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    for (int r = 0; r < n; ++r) {
        for (int c = 0; c < n; ++c) {
            cout << (r ^ c) << (c + 1 == n ? '\n' : ' ');
        }
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n^2)$. Each cell evaluation is a single CPU instruction `xor`. For $n = 100$, $100 \times 100 = 10^4$ operations, completing in $< 0.001$ seconds.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary space beyond I/O buffers.

---

## 6. Correctness Proof

**Theorem**: For all non-negative integers $r, c \ge 0$,
$$G(r, c) = \text{mex}\Big(\{G(r, j) : 0 \le j < c\} \cup \{G(i, c) : 0 \le i < r\}\Big) = r \oplus c$$

**Proof by 2D Mathematical Induction**:
- **Base Case**: For $(r, c) = (0, 0)$, both sets are empty, so $\text{mex}(\emptyset) = 0 = 0 \oplus 0$.
- **Inductive Hypothesis**: Assume $G(i, j) = i \oplus j$ holds for all pairs $(i, j)$ with $i < r$ or $j < c$.
- We must prove two properties for $G(r, c) = r \oplus c$:
  1. **Exclusion**: $r \oplus c$ is not in the set of predecessors.
     - Suppose for contradiction that $r \oplus j = r \oplus c$ for some $j < c$. XORing both sides by $r$ yields $j = c$, contradicting $j < c$.
     - Similarly, $i \oplus c = r \oplus c \implies i = r$, contradicting $i < r$.
     - Hence, $r \oplus c \notin \{G(r, j)\} \cup \{G(i, c)\}$.
  2. **Inclusion of all smaller values**: Every integer $v$ with $0 \le v < r \oplus c$ is present.
     - Let $k = (r \oplus c) \oplus v$. Since $v < r \oplus c$, the most significant bit (MSB) where $v$ and $r \oplus c$ differ must be $1$ in $r \oplus c$ and $0$ in $v$. Let this bit index be $d$.
     - In the XOR sum $r \oplus c$, bit $d$ is $1$. Therefore, bit $d$ must be $1$ in either $r$ or $c$.
     - **Case 1 (Bit $d$ is $1$ in $r$)**:
       Choose $i = r \oplus k = c \oplus v$.
       Since bit $d$ is $1$ in $r$ and $1$ in $k$, and all higher bits of $k$ are $0$, $i = r \oplus k < r$.
       By induction, $G(i, c) = i \oplus c = (c \oplus v) \oplus c = v$. Thus, $v$ appears in column $c$.
     - **Case 2 (Bit $d$ is $1$ in $c$)**:
       Choose $j = c \oplus k = r \oplus v$.
       By identical logic, $j < c$, and by induction $G(r, j) = r \oplus j = r \oplus (r \oplus v) = v$. Thus, $v$ appears in row $r$.
- Since $r \oplus c$ is not present, and every integer in $[0, r \oplus c - 1]$ is present, the minimum excluded value is precisely $r \oplus c$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

For $n = 4$:
- $r = 0$:
  - $c = 0: 0 \oplus 0 = 0$
  - $c = 1: 0 \oplus 1 = 1$
  - $c = 2: 0 \oplus 2 = 2$
  - $c = 3: 0 \oplus 3 = 3$
- $r = 1$:
  - $c = 0: 1 \oplus 0 = 1$
  - $c = 1: 1 \oplus 1 = 0$
  - $c = 2: 1 \oplus 2 = 3$
  - $c = 3: 1 \oplus 3 = 2$
- $r = 2$:
  - $c = 0: 2 \oplus 0 = 2$
  - $c = 1: 2 \oplus 1 = 3$
  - $c = 2: 2 \oplus 2 = 0$
  - $c = 3: 2 \oplus 3 = 1$
- $r = 3$:
  - $c = 0: 3 \oplus 0 = 3$
  - $c = 1: 3 \oplus 1 = 2$
  - $c = 2: 3 \oplus 2 = 1$
  - $c = 3: 3 \oplus 3 = 0$

Notice every $2^k \times 2^k$ block forms a Latin square containing numbers $\{0, \dots, 2^k - 1\}$.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1$**: Output is simply `0`. Handled automatically.
- **Maximum value**: For $n \le 100$, the maximum value in the grid is $< 2^{\lceil \log_2 100 \rceil + 1} = 256$, comfortably fitting in 32-bit `int`.
- **0-based vs 1-based indexing**: The problem statement specifies the top-left square is 0 (smallest non-negative integer with no predecessors). Our loop $r, c \in [0, n-1]$ matches this perfectly.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What is the value at square $(r, c)$ for $n = 10^9$?**
   - With our closed-form $r \oplus c$, any single cell can be queried in $\mathcal{O}(1)$ time, even for $r, c \le 10^{18}$!
2. **What is the sum of all elements in the $n \times n$ grid for $n = 10^5$?**
   - We can sum $r \oplus c$ bit-by-bit: for each bit $k$, count the number of row indices with bit $k$ set and column indices with bit $k$ unset, plus vice versa, running in $\mathcal{O}(\log n)$.
3. **Why does this grid relate to the game of Nim?**
   - Each state in 2-pile Nim $(r, c)$ allows transitions to $(r, j)$ with $j < c$ or $(i, c)$ with $i < r$. The Grundy value of a game is the mex of its reachable options. This exact transition graph generates $G(r, c) = r \oplus c$.
4. **Is every row and column a permutation when $n$ is a power of 2?**
   - Yes, for $n = 2^k$, the set $\{r \oplus c : 0 \le c < 2^k\}$ is a permutation of $\{0, 1, \dots, 2^k - 1\}$.
5. **How would you find the position of the value $0$ in row $r$?**
   - $r \oplus c = 0 \iff c = r$. The zeroes lie strictly on the main diagonal!

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Constructive, Game Theory, Sprague-Grundy, Bit Manipulation, XOR.
- **Time Complexity**: $\mathcal{O}(n^2)$ optimal time.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary space.

### Related CSES Tasks
- [CSES 1735 - Nim Game I](https://cses.fi/problemset/task/1735): Standard game of Nim and XOR-sum.
- [CSES 2205 - Gray Code](https://cses.fi/problemset/task/2205): Bitwise XOR code reflections.
- [CSES 1071 - Number Spiral](https://cses.fi/problemset/task/1071): Direct geometric mapping on grids.
