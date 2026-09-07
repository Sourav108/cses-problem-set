# Missing Number (CSES Task 1083 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1083 - Missing Number](https://cses.fi/problemset/task/1083)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: You are given all numbers between $1, 2, \dots, n$ except one. Your task is to find the missing number.
- **Constraints**: $2 \le n \le 2 \cdot 10^5$. All elements are distinct and lie in the range $[1, n]$.

---

## 1. Problem, Restated

Given an integer $n$ and an unsorted sequence of $n - 1$ distinct integers chosen from the set $\{1, 2, \dots, n\}$, determine the single missing integer.

**Input**: First line contains $n$. Second line contains $n - 1$ space-separated integers via `cin`.  
**Output**: Print the single missing integer on `cout` followed by `\n`.  
**Key Constraints**: $n \le 2 \cdot 10^5$. Calculating the total sum $\sum_{i=1}^n i = \frac{n(n+1)}{2}$ yields up to $\approx 2 \cdot 10^{10}$, which exceeds 32-bit signed integers and requires 64-bit arithmetic or bitwise XOR.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Invariant Recovery / Bitwise XOR Algebra / Gauss Summation.
- **Aha! Insight**: We know every number in the range $[1, n]$ appears exactly once in the ideal set, and every number except the missing value appears in the input.
  Two elegant $\mathcal{O}(n)$ time, $\mathcal{O}(1)$ space methods exist:
  1. **Bitwise XOR**: Because $x \oplus x = 0$ and $x \oplus 0 = x$, XOR-ing all numbers in $[1, n]$ with all $n - 1$ input elements cancels every present element in pairs, leaving exclusively the missing number with zero risk of arithmetic overflow!
  2. **Sum Invariant**: Missing value is $\frac{n(n+1)}{2} - \sum a_i$ computed in `long long`.
- **Clue**: "Find the single missing element from a contiguous permutation of $1 \dots n$." Signals XOR or sum reduction.

---

## 3. Approach 1 — Naive / Baseline (Boolean Visited Vector)

### Idea
Track presence of each number using a boolean vector of size $n + 1$. After reading all elements, scan the vector for the unvisited index.

### C++17 Code
```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<bool> seen(n + 1, false);
    for (int i = 0; i < n - 1; i++) {
        int val;
        cin >> val;
        seen[val] = true;
    }

    for (int i = 1; i <= n; i++) {
        if (!seen[i]) {
            cout << i << '\n';
            break;
        }
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n)$ — one pass to mark, one pass to search.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary memory for the boolean vector.
- **Why it's sub-optimal**: Allocating $\mathcal{O}(n)$ memory is unnecessary when an online accumulator requires only $\mathcal{O}(1)$ space.

---

## 4. Approach 2 — Intermediate (Sorting)

### Idea
Store all $n - 1$ elements in an array, sort them in $\mathcal{O}(n \log n)$, then linearly scan until `arr[i] != i + 1`.

### C++17 Code
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

    vector<int> a(n - 1);
    for (int i = 0; i < n - 1; i++) cin >> a[i];

    sort(a.begin(), a.end());

    int missing = n;
    for (int i = 0; i < n - 1; i++) {
        if (a[i] != i + 1) {
            missing = i + 1;
            break;
        }
    }

    cout << missing << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$ due to comparison sorting.
- **Space Complexity**: $\mathcal{O}(n)$ to store elements.
- **Why it's sub-optimal**: Unnecessary sorting overhead; $\mathcal{O}(n \log n)$ does $\approx 3.6 \times 10^6$ operations compared to a single linear pass of $2 \cdot 10^5$.

---

## 5. Approach 3 — Optimal CSES Solution (Bitwise XOR Online Streaming)

### Idea
Maintain `xor_sum = 0`. XOR all numbers from $1$ to $n$, and XOR every incoming integer online as it is read from `cin`.

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

    int xor_sum = 0;
    // XOR all expected numbers from 1 to n
    for (int i = 1; i <= n; i++) {
        xor_sum ^= i;
    }

    // XOR all given n - 1 numbers online
    for (int i = 0; i < n - 1; i++) {
        int val;
        cin >> val;
        xor_sum ^= val;
    }

    cout << xor_sum << '\n';

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n)$ — exactly $n + (n - 1)$ XOR operations, running in $\approx 1.5$ ms for $n = 2 \cdot 10^5$.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary memory — values are consumed directly from stream.
- **Optimality Guarantee**: Matches the theoretical lower bound $\Omega(n)$ (since all $n - 1$ inputs must be inspected) and runs in optimal $\mathcal{O}(1)$ space.

---

## 6. Correctness Proof

- **Algebraic Property**: Bitwise XOR is associative, commutative, satisfies $x \oplus x = 0$, and has identity $x \oplus 0 = x$.
- **Set Partition**: Let $S = \{1, 2, \dots, n\}$ be the complete set and $A = \{a_1, a_2, \dots, a_{n-1}\}$ be the given subset. By definition, there exists a unique element $m \in S$ such that $S \setminus A = \{m\}$.
- **Cancellation**:
  $$\left(\bigoplus_{x \in S} x\right) \oplus \left(\bigoplus_{y \in A} y\right) = m \oplus \left(\bigoplus_{y \in A} (y \oplus y)\right) = m \oplus 0 = m$$
  Because every element in $A$ appears once in $S$ and once in $A$, each cancels to 0, leaving $m$ strictly isolated.
- **Termination**: The loops iterate exactly $n$ and $n-1$ times, guaranteeing deterministic finite termination.

---

## 7. Dry Run & Visual State Trace

Input: `n = 5`, sequence: `[2, 3, 1, 5]`

1. Range XOR: $1 \oplus 2 \oplus 3 \oplus 4 \oplus 5 = 1$
2. Input XOR:
   - Read 2: $1 \oplus 2 = 3$
   - Read 3: $3 \oplus 3 = 0$
   - Read 1: $0 \oplus 1 = 1$
   - Read 5: $1 \oplus 5 = 4$
3. Final Result: `4` ✅

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 2$ Boundary**: Smallest valid constraint. Single input given, properly resolves to the remaining number.
- **Missing Boundary Element**: Correctly handles missing $1$ or missing $n$.
- **Arithmetic Overflow**: When using $\text{expected\_sum} = n(n+1)/2$, for $n = 2 \cdot 10^5$, $\text{expected\_sum} = \frac{200000 \times 200001}{2} = 20,000,100,000 > 2^{31}-1$. A 32-bit signed `int` overflows to a negative value. The XOR approach is completely immune to overflow because bitwise XOR never exceeds the bit-width of its operands.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Q1: What if TWO numbers are missing from the range $[1, n]$?**
   - **A**: Compute $X = \text{XOR of all } [1, n] \oplus \text{input} = u \oplus v$. Since $u \ne v$, $X$ has at least one set bit (say the lowest set bit $b = X \ \& \ (-X)$). Partition the numbers into two groups based on bit $b$ and XOR each group separately to isolate $u$ and $v$ in $\mathcal{O}(n)$ time and $\mathcal{O}(1)$ space.
2. **Q2: Can we compute the XOR of $1 \dots n$ in $\mathcal{O}(1)$ time instead of an $\mathcal{O}(n)$ loop?**
   - **A**: Yes! The prefix XOR sequence has a 4-periodic pattern:
     - $n \equiv 0 \pmod 4 \implies n$
     - $n \equiv 1 \pmod 4 \implies 1$
     - $n \equiv 2 \pmod 4 \implies n + 1$
     - $n \equiv 3 \pmod 4 \implies 0$
3. **Q3: What if the numbers are not consecutive $[1, n]$ but form an arbitrary Arithmetic Progression?**
   - **A**: Use the AP sum formula $S = \frac{n}{2}(2a + (n-1)d)$ with `long long` and subtract the input sum.
4. **Q4: What if input is received as an infinite read-once stream across distributed machines?**
   - **A**: Bitwise XOR is associative and commutative; partial XOR sums can be computed independently on worker nodes and XOR-ed together at the coordinator.
5. **Q5: What if duplicate numbers are present and one number appears an odd number of times?**
   - **A**: The same XOR strategy isolates the element with odd frequency since pairs cancel ($x \oplus x = 0$).

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `Bit-Manipulation`, `Math`, `XOR`, `Online-Algorithm`, `Fast-IO`
- **Complexity Summary**:
  - **Time**: $\mathcal{O}(n)$
  - **Space**: $\mathcal{O}(1)$ auxiliary space
- **Related CSES Problems**:
  - **[CSES 1068 - Weird Algorithm](https://cses.fi/problemset/task/1068)**: Foundational simulation and overflow avoidance.
  - **[CSES 1069 - Repetitions](https://cses.fi/problemset/task/1069)**: Linear single-pass character scan.
  - **[CSES 1617 - Bit Strings](https://cses.fi/problemset/task/1617)**: Binary powers and modular arithmetic.
