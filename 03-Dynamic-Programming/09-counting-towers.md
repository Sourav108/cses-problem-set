# Counting Towers

- **Category**: Dynamic Programming
- **CSES Task ID**: `2413`
- **CSES Problem Link**: [Counting Towers](https://cses.fi/problemset/task/2413)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Your task is to count the number of different towers you can build of width $2$ and height $n$ using rectangular blocks of integer dimensions. Blocks cannot rotate, and must fit together without gaps. You are given $t$ independent test cases. Output each answer modulo $10^9 + 7$.

### Input Format
- The first line contains an integer $t$: the number of test cases.
- The next $t$ lines each contain an integer $n$: the desired tower height.

### Output Format
- For each test case, print the number of towers of height $n$ modulo $10^9 + 7$.

### Numerical Constraints
- $1 \le t \le 100$
- $1 \le n \le 10^6$

With $N_{\max} = 10^6$, precomputing the recurrence up to $10^6$ takes $\mathcal{O}(N_{\max})$ time ($\approx 0.02\text{s}$), and answering each of the $t$ queries takes $\mathcal{O}(1)$ time.

---

## 2. Intuition & Pattern Recognition

This is a **State Machine / Coupled Linear Recurrence DP**:
- A tower of width $2$ consists of two columns of width $1$.
- At any horizontal unit level $i$, there are two structural states based on the vertical dividing line between the two columns:
  1. **State $A_i$ (Split)**: The level at height $i$ is divided into **two separate $1 \times 1$ horizontal sections**.
  2. **State $B_i$ (Fused/Joined)**: The level at height $i$ is covered by a **single $1 \times 2$ block** spanning both columns.

### Transition Analysis:
When building level $i$ on top of level $i - 1$:
1. **To form State $A_i$ (Split level)**:
   - *From $A_{i-1}$ (previously split)*:
     - Extend both left and right blocks upward (1 choice).
     - Extend left block upward, start a new right block (1 choice).
     - Extend right block upward, start a new left block (1 choice).
     - Close both blocks and start two new $1 \times 1$ blocks (1 choice).
     - Total: $4 \times A_{i-1}$.
   - *From $B_{i-1}$ (previously joined)*:
     - A joined block cannot extend into split blocks. It must terminate, and we start two new separate $1 \times 1$ blocks (1 choice).
     - Total: $1 \times B_{i-1}$.
   $$\implies A_i = 4 A_{i-1} + B_{i-1}$$

2. **To form State $B_i$ (Joined level)**:
   - *From $A_{i-1}$ (previously split)*:
     - Two separate blocks cannot merge into an ongoing block. Both must terminate, and we start a new $1 \times 2$ block (1 choice).
     - Total: $1 \times A_{i-1}$.
   - *From $B_{i-1}$ (previously joined)*:
     - Extend the existing $1 \times 2$ block upward (1 choice).
     - Terminate the existing block and start a new $1 \times 2$ block (1 choice).
     - Total: $2 \times B_{i-1}$.
   $$\implies B_i = A_{i-1} + 2 B_{i-1}$$

- Base cases for height $1$: $A_1 = 1$, $B_1 = 1$. Total towers of height $n$ is $A_n + B_n \pmod{10^9 + 7}$.

---

## 3. Approach 1 — Naive / Pure Recursion

Evaluate mutual recurrences naively for each query.

### C++17 Baseline Code

```cpp
#include <iostream>

using namespace std;

const int MOD = 1e9 + 7;

pair<long long, long long> solve_brute(int n) {
    if (n == 1) return {1, 1};

    auto [prev_A, prev_B] = solve_brute(n - 1);
    long long A = (4 * prev_A + prev_B) % MOD;
    long long B = (prev_A + 2 * prev_B) % MOD;

    return {A, B};
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int t;
    if (!(cin >> t)) return 0;

    while (t--) {
        int n;
        cin >> n;
        auto [A, B] = solve_brute(n);
        cout << (A + B) % MOD << '\n';
    }
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(t \cdot n)$. For $t = 100$ and $n = 10^6$, operations $\approx 10^8$, which times out with function call overhead.
- **Space Complexity**: $\mathcal{O}(n)$ call stack depth (risks stack overflow on macOS/Linux).
- **CSES Verdict**: TLE / Runtime Error.

---

## 4. Approach 2 — Intermediate / Per-Query DP Tabulation

Allocate vectors and compute DP for each test case individually.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(\sum n) \le \mathcal{O}(t \cdot N_{\max}) \approx 10^8$ operations.
- **Space Complexity**: $\mathcal{O}(n)$ per test case.
- **Verdict**: Inefficient because the recurrence is static and independent of the queries.

---

## 5. Approach 3 — Optimal CSES Solution (Offline Precomputation + $\mathcal{O}(1)$ Query)

Precompute arrays $A$ and $B$ up to $N = 10^6$ once before reading queries. Answer each query in $\mathcal{O}(1)$ time.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>

using namespace std;

const int MAXN = 1000000;
const int MOD = 1e9 + 7;

// A[i] = towers of height i ending with two separate 1x1 blocks
// B[i] = towers of height i ending with a single joined 1x2 block
int A[MAXN + 1];
int B[MAXN + 1];

void precompute() {
    // Base cases for height 1
    A[1] = 1;
    B[1] = 1;

    for (int i = 2; i <= MAXN; ++i) {
        // A[i] = 4 * A[i-1] + B[i-1]
        A[i] = (4LL * A[i - 1] + B[i - 1]) % MOD;

        // B[i] = A[i-1] + 2 * B[i-1]
        B[i] = (1LL * A[i - 1] + 2LL * B[i - 1]) % MOD;
    }
}

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    precompute();

    int t;
    if (!(cin >> t)) return 0;

    while (t--) {
        int n;
        cin >> n;
        int total = (A[n] + B[n]) % MOD;
        cout << total << '\n';
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: 
  - Precomputation: $\mathcal{O}(N_{\max})$ where $N_{\max} = 10^6$ ($\approx 0.015\text{s}$).
  - Query Time: $\mathcal{O}(1)$ per test case. Total query time for $t \le 100$ is negligible ($< 0.001\text{s}$).
  - Overall Time: $\mathcal{O}(N_{\max} + t)$.
- **Space Complexity**: $\mathcal{O}(N_{\max})$ global storage. Two arrays of $10^6$ 32-bit integers consume $8\text{ MB}$, well within 512 MB.
- **Optimality Guarantee**: Since answers for $n \le 10^6$ are required, $\mathcal{O}(N_{\max})$ precomputation with $\mathcal{O}(1)$ lookup is optimal.

---

## 6. Correctness Proof

### Disjoint Partition of Top Boundary
At height $i$, every valid tower has either:
1. A vertical division between $x = 1$ and $x = 2$ at the top level $\implies$ Configuration $A_i$.
2. No vertical division (a single horizontal block of width 2 spans both columns) $\implies$ Configuration $B_i$.
These two cases partition all valid towers of height $i$ into mutually exclusive, exhaustive sets.

### Transitions Exhaustion
1. **Underlying $A_i$ (Two $1 \times 1$ blocks at top)**:
   - Left column can independently either continue or terminate ($2$ choices).
   - Right column can independently either continue or terminate ($2$ choices).
   - $2 \times 2 = 4$ ways when placed atop $A_{i-1}$.
   - Atop $B_{i-1}$, neither column can continue (cannot split an unbroken block), yielding $1$ way.
2. **Underlying $B_i$ (Single $1 \times 2$ block at top)**:
   - Atop $A_{i-1}$, neither column can merge into an ongoing block $\implies$ must start new ($1$ way).
   - Atop $B_{i-1}$, the single width-2 block can either continue or start new ($2$ ways).
3. The linear recurrences maintain the exact count of valid tilings inductively for all $i \ge 1$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
3
2
6
1337
```

| Height $i$ | $A_i = (4 A_{i-1} + B_{i-1}) \bmod \text{MOD}$ | $B_i = (A_{i-1} + 2 B_{i-1}) \bmod \text{MOD}$ | Total $= A_i + B_i$ |
| :---: | :---: | :---: | :---: |
| **1** | $1$ | $1$ | $1 + 1 = \mathbf{2}$ |
| **2** | $4(1) + 1 = \mathbf{5}$ | $1 + 2(1) = \mathbf{3}$ | $5 + 3 = \mathbf{8}$ |
| **3** | $4(5) + 3 = \mathbf{23}$ | $5 + 2(3) = \mathbf{11}$ | $23 + 11 = \mathbf{34}$ |
| **4** | $4(23) + 11 = \mathbf{103}$ | $23 + 2(11) = \mathbf{45}$ | $103 + 45 = \mathbf{148}$ |
| **5** | $4(103) + 45 = \mathbf{457}$ | $103 + 2(45) = \mathbf{193}$ | $457 + 193 = \mathbf{650}$ |
| **6** | $4(457) + 193 = \mathbf{2021}$ | $457 + 2(193) = \mathbf{843}$ | $2021 + 843 = \mathbf{2864}$ |

For $n = 2$: Output is `8`. Matches CSES example!  
For $n = 6$: Output is `2864`. Matches CSES example!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1$**: Outputs $A_1 + B_1 = 1 + 1 = 2$ (two $1\times 1$ blocks, or one $1 \times 2$ block).
- **Multiple Queries ($t = 100$)**: Recomputing DP inside each test case leads to redundant work. Global precomputation is essential.
- **Integer Overflow**: $4 A_{i-1} + B_{i-1}$ can exceed $2^{31} - 1$. Casting to `4LL * A[i-1]` prevents 32-bit signed overflow.
- **Cache Locality**: Storing $A$ and $B$ as global primitive arrays `int A[MAXN + 1]` avoids vector overhead and optimizes cache lines.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if $n \le 10^{18}$ and $t \le 10$?**
   - The system is a $2 \times 2$ matrix transition:
     $$\begin{pmatrix} A_i \\ B_i \end{pmatrix} = \begin{pmatrix} 4 & 1 \\ 1 & 2 \end{pmatrix} \begin{pmatrix} A_{i-1} \\ B_{i-1} \end{pmatrix}$$
     Compute using **Matrix Exponentiation** in $\mathcal{O}(2^3 \log n) = \mathcal{O}(\log n)$ time per query.
2. **Tower of width 3 ($3 \times n$)?**
   - State space expands: count partitions of width 3 (e.g. three $1\times 1$, one $1\times 2$ + one $1\times 1$, one $1\times 3$). This gives a system of 5 coupled states with a $5 \times 5$ transition matrix.
3. **General width $W$ ($W \le 10$)?**
   - Use **Profile DP / Broken Profile DP / Counting Tilings** (`CSES 2181`) with bitmasks in $\mathcal{O}(n \cdot 2^{2W})$ time.
4. **Closed Form via Characteristic Polynomial?**
   - Characteristic equation: $\det(M - \lambda I) = \lambda^2 - 6\lambda + 7 = 0$.
     Eigenvalues are $\lambda = 3 \pm \sqrt{2}$. Solvable via field extensions $\mathbb{Z}_p[\sqrt{2}]$.
5. **Reconstructing a random valid tower?**
   - Sample backwards from height $n$ down to $1$ with branch probabilities weighted by $A_{i-1}$ and $B_{i-1}$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[dynamic-programming, state-machine, linear-recurrence, precomputation]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(N_{\max} + t)$
  - Space: $\mathcal{O}(N_{\max})$
- **Related CSES Problems**:
  - `CSES 1633` — [Dice Combinations](https://cses.fi/problemset/task/1633) (Linear recurrence combinations).
  - `CSES 1746` — [Array Description](https://cses.fi/problemset/task/1746) (State-transition DP).
  - `CSES 2181` — [Counting Tilings](https://cses.fi/problemset/task/2181) (Profile DP on general grids).
