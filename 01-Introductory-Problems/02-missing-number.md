# Missing Number (CSES Task 1083 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 9-section format.

- **Source**: [CSES Task 1083 - Missing Number](https://cses.fi/problemset/task/1083)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: You are given all numbers between $1, 2, \dots, n$ except one. Your task is to find the missing number.
- **Constraints**: $2 \le n \le 2 \cdot 10^5$. All elements are distinct and lie in the range $[1, n]$.

---

## 1. Problem, Restated

Given an integer $n$ and an unsorted sequence of $n - 1$ distinct integers chosen from the set $\{1, 2, \dots, n\}$, determine the single missing integer.

**Input**: First line contains $n$. Second line contains $n - 1$ space-separated integers.  
**Output**: Print the single missing integer.  
**Key Constraints**: $n \le 2 \cdot 10^5$. An $\mathcal{O}(n^2)$ search will TLE. Calculating the total sum $\sum_{i=1}^n i = \frac{n(n+1)}{2}$ yields up to $\approx 2 \cdot 10^{10}$, which exceeds 32-bit signed integers and requires 64-bit arithmetic or bitwise XOR.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Data Recovery / Invariant Math / Bitwise XOR Algebra.
- **Aha! Insight**: We know every number in the range $[1, n]$ appears exactly once in the ideal set, and every number except the target appears exactly once in the input. Two elegant $\mathcal{O}(n)$ time, $\mathcal{O}(1)$ space methods exist:
  1. **Sum Invariant**: The missing value is $\text{Total Sum} - \text{Actual Sum} = \frac{n(n+1)}{2} - \sum_{i=1}^{n-1} a_i$.
  2. **Bitwise XOR**: Because $x \oplus x = 0$ and $x \oplus 0 = x$, XOR-ing all numbers in $[1, n]$ and all $n - 1$ input elements leaves solely the missing number, with zero risk of arithmetic overflow!
- **Clue**: "Find the one missing element from a contiguous range of $1 \dots n$." This is the textbook XOR or Gauss sum problem.

---

## 3. Approach 1 — Naive (Hash Map / Boolean Vector)

### Idea
Track presence of each number using a boolean vector of size $n + 1$. After reading all elements, scan the vector for the unvisited index.

### C++17 Code
```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

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
- **Why it's sub-optimal**: While it passes within 1.00s, allocating $\mathcal{O}(n)$ memory is redundant when $\mathcal{O}(1)$ memory is achievable.

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
    cin.tie(NULL);

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

## 5. Approach 3 — Optimal CSES Solution (Bitwise XOR & Gauss Sum)

### Idea
We read the stream of $n - 1$ numbers online without storing them in memory.
Using **Bitwise XOR**:
Initialize `ans = 0`. XOR all values from $1$ to $n$, and XOR every incoming value from standard input. Because XOR is commutative and associative:
$$\text{ans} = (1 \oplus 2 \dots \oplus n) \oplus (a_1 \oplus a_2 \dots \oplus a_{n-1}) = \text{missing number}$$
Alternatively, Gauss summation $\frac{n(n+1)}{2} - \sum a_i$ with `long long`.

### C++17 Production Code (Bitwise XOR — Zero Overflow Risk)
```cpp
#include <iostream>

using namespace std;

int main() {
    // Fast I/O for large streaming inputs (N = 200,000)
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    int n;
    if (!(cin >> n)) return 0;

    int xor_sum = 0;
    // XOR all expected numbers from 1 to n
    for (int i = 1; i <= n; i++) {
        xor_sum ^= i;
    }

    // XOR all given n - 1 numbers
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
- **Time Complexity**: $\mathcal{O}(n)$ — exactly $n + (n - 1)$ XOR operations, executing in $\approx 1.5$ ms for $n = 2 \cdot 10^5$.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary memory — values are processed online without storing an array.
- **Optimality**: Must examine all $n - 1$ elements to identify the missing one, satisfying the theoretical $\Omega(n)$ lower bound.

---

## 6. Dry Run & Visual State Trace

Input: `n = 5`, sequence: `[2, 3, 1, 5]`

1. Range XOR: $1 \oplus 2 \oplus 3 \oplus 4 \oplus 5 = 1$
2. Input XOR:
   - Read 2: $1 \oplus 2 = 3$
   - Read 3: $3 \oplus 3 = 0$
   - Read 1: $0 \oplus 1 = 1$
   - Read 5: $1 \oplus 5 = 4$
3. Final Result: `4` ✅

---

## 7. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 2$**: Minimum boundary condition. Single input given, properly resolves to the other number.
- **Missing Element at Boundaries**: Correctly handles missing $1$ or missing $n$.
- **Arithmetic Overflow**: When using $\text{expected\_sum} = n(n+1)/2$, for $n = 2 \cdot 10^5$, $\text{expected\_sum} = \frac{200000 \times 200001}{2} = 20,000,100,000 > 2^{31}-1$. A 32-bit signed `int` overflows into a negative value. The XOR approach is completely immune to overflow because bitwise XOR never exceeds the bit-width of its operands.

---

## 8. Competitive Programming & Interview Follow-Up Questions

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

## 9. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `Bit-Manipulation`, `Math`, `XOR`, `Online-Algorithm`, `Fast-IO`
- **Complexity**:
  - Time: $\mathcal{O}(n)$
  - Space: $\mathcal{O}(1)$
- **Related CSES Problems**:
  - **[CSES 1068 - Weird Algorithm](https://cses.fi/problemset/task/1068)**: Foundational simulation and overflow avoidance.
  - **[CSES 1069 - Repetitions](https://cses.fi/problemset/task/1069)**: Linear single-pass character scan.
  - **[CSES 1617 - Bit Strings](https://cses.fi/problemset/task/1617)**: Binary powers and modular arithmetic.
