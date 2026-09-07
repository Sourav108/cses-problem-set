# Distinct Values Subsequences (CSES Task 3421 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 3421 - Distinct Values Subsequences](https://cses.fi/problemset/task/3421)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Given an array of $n$ integers, count the number of non-empty subsequences where each element is distinct. Print the answer modulo $10^9 + 7$.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le x_i \le 10^9$.

---

## 1. Problem, Restated

Given an array $x = [x_1, x_2, \dots, x_n]$, a subsequence is defined by choosing an index subset $I = \{i_1 < i_2 < \dots < i_m\}$.
A subsequence is valid if no two chosen indices have the same value:
$$x_{i_a} \ne x_{i_b}, \quad \forall 1 \le a < b \le m$$
Count the total number of non-empty valid index subsets $I$, modulo $10^9 + 7$.

**Input**:
- First line: integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Second line: $n$ space-separated integers $x_1, \dots, x_n$.

**Output**:
- Print a single integer: the number of distinct-element subsequences modulo $10^9 + 7$.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Combinatorics / Product Rule / Frequency Counting / Modular Arithmetic.
- **Aha! Insight**:
  - The definition of a valid subsequence requires that **no value appears more than once**.
  - Let the distinct values present in the array be $v_1, v_2, \dots, v_k$, with frequencies $f_1, f_2, \dots, f_k$.
  - In any valid subsequence:
    - For value $v_1$: we can either choose **none** of its occurrences (1 choice), or choose **any one** of its $f_1$ occurrences ($f_1$ choices).
      Total choices for value $v_1$: $(f_1 + 1)$.
    - For value $v_2$: independently, $(f_2 + 1)$ choices.
    - In general, for each distinct value $v_j$, we independently have $(f_j + 1)$ choices.
  - Notice that any choice of at most one index for each distinct value produces a unique subset of indices whose values are mutually distinct!
  - When written in increasing order of their indices, these chosen indices automatically form a valid subsequence of distinct values.
  - Conversely, every valid subsequence of distinct values corresponds to choosing exactly one occurrence of each value present in the subsequence.
  - By the **Fundamental Rule of Product**, the total number of such index choices is:
    $$\prod_{j=1}^k (f_j + 1)$$
  - Subtracting 1 (to exclude the empty subsequence) gives the exact answer:
    $$\text{Answer} = \left( \prod_{j=1}^k (f_j + 1) \right) - 1 \pmod{10^9 + 7}$$
  - No dynamic programming, segment trees, or complex transitions are needed—just sort to find frequencies and multiply!
- **Signal**: "Count subsequences where all elements are distinct" is the pure product over $(f_i + 1) - 1$.

---

## 3. Approach 1 — Naive / Baseline (Exponential Power Set Generation)

Iterate through all $2^n$ subsequences and verify if each contains distinct elements using a hash set.
For $n = 2 \cdot 10^5$, $2^{200000}$ operations is impossible $\implies$ TLE.

---

## 4. Approach 2 — Intermediate (`std::map` Frequency Counting)

Insert all elements into `std::map<int, int>` to compute frequencies $f_j$. Then compute $\prod (f_j + 1) - 1 \pmod{10^9 + 7}$.
While $\mathcal{O}(n \log n)$, tree node allocations can be avoided by sorting a vector (Approach 3).

---

## 5. Approach 3 — Optimal CSES Solution (Sorting + Run-Length Frequency Product)

### Idea
1. Read $n$ numbers into `vector<int> a(n)`.
2. Sort `a` using `std::sort`.
3. Scan `a` using run-length encoding: for each distinct value with frequency $f$, update:
   $$\text{ans} = (\text{ans} \times (f + 1)) \pmod{10^9 + 7}$$
4. At the end, subtract 1: `(ans - 1 + MOD) % MOD`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const long long MOD = 1000000007;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> a(n);
    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    sort(a.begin(), a.end());

    long long ans = 1;
    int i = 0;
    while (i < n) {
        int j = i;
        while (j < n && a[j] == a[i]) {
            j++;
        }
        long long freq = j - i;
        ans = (ans * (freq + 1)) % MOD;
        i = j;
    }

    ans = (ans - 1 + MOD) % MOD;
    cout << ans << '\n';

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$ to sort the array. The linear scan takes $\mathcal{O}(n)$. For $n = 2 \cdot 10^5$, total operations $\approx 3.6 \times 10^6$, executing in $\approx 0.04$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ contiguous vector storage. $\mathcal{O}(1)$ auxiliary space.

---

## 6. Correctness Proof

1. **Bijection between Index Subsets and Subsequences**:
   A subsequence is uniquely determined by the set of chosen indices $I \subseteq \{0, 1, \dots, n-1\}$.
   The condition that all elements are distinct means no two indices in $I$ can share the same value:
   $$\forall i, j \in I \text{ with } i \ne j \implies a_i \ne a_j$$
2. **Partition by Distinct Values**:
   Let the array's distinct values be $\mathcal{V} = \{v_1, \dots, v_k\}$.
   Partition the index set $\{0, 1, \dots, n-1\}$ into fibers $F(v) = \{i : a_i = v\}$.
   A subset $I$ satisfies the distinctness condition if and only if $|I \cap F(v)| \le 1$ for all $v \in \mathcal{V}$.
3. **Independence of Choices**:
   For each fiber $F(v)$ of size $|F(v)| = f_v$:
   - We either select no index from $F(v)$ ($1$ choice).
   - Or we select exactly one index from $F(v)$ ($f_v$ choices).
   Total choices from $F(v)$ is $(f_v + 1)$.
   Because the fibers $F(v_1), \dots, F(v_k)$ form a disjoint partition of the index space, the selections from each fiber are completely independent.
4. By the rule of product, the total number of valid index subsets is $\prod_{v \in \mathcal{V}} (f_v + 1)$.
   Excluding the empty set $|I| = 0$ yields $\prod_{v \in \mathcal{V}} (f_v + 1) - 1$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 4$, array = `[1, 2, 1, 3]`.
Sorted: `[1, 1, 2, 3]`.

- Value 1: frequency $f = 2$ $\implies \text{factor} = 2 + 1 = 3$.
  `ans = 1 * 3 = 3`.
- Value 2: frequency $f = 1$ $\implies \text{factor} = 1 + 1 = 2$.
  `ans = 3 * 2 = 6`.
- Value 3: frequency $f = 1$ $\implies \text{factor} = 1 + 1 = 2$.
  `ans = 6 * 2 = 12`.
- End of loop:
  `ans = (12 - 1) % MOD = 11`.

Matches the example output **11** exactly!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Modulo Arithmetic**: Must apply `% MOD` at each multiplication. Adding `MOD` before subtracting 1 (`(ans - 1 + MOD) % MOD`) prevents negative values.
- **All elements distinct ($f_i = 1$)**: $\text{ans} = 2^n - 1 \pmod{MOD}$ (every non-empty subset is valid).
- **All elements identical ($k = 1, f_1 = n$)**: $\text{ans} = (n + 1) - 1 = n$ (only subsequences of length 1 are valid).
- **$n = 1$**: Output is $(1 + 1) - 1 = 1$.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the question asked for distinct subsequences by *value* (avoiding duplicate content)?**
   - That is the classic **Distinct Subsequences DP**:
     $$dp[i] = 2 \cdot dp[i-1] - dp[\text{last\_pos}[a_i] - 1]$$
2. **What if we required subsequences of length exactly $K$?**
   - That is equivalent to finding the coefficient of $x^K$ in the generating function $\prod_{j=1}^k (1 + f_j x)$, solvable via Divide and Conquer + Fast Fourier Transform (FFT) in $\mathcal{O}(n \log^2 n)$.
3. **Why does this formula NOT work for subarrays (CSES 3420)?**
   - Subarrays must be contiguous; indices cannot have gaps. Subsequences allow arbitrary gaps, allowing independent choices for each value.
4. **Can this exceed $10^9+7$ before modulo?**
   - Multiplying two `long long` integers up to $10^9+7$ produces $\le 10^{18}$, which fits safely within standard 64-bit signed `long long` ($9.22 \times 10^{18}$).
5. **How does this connect to square-free divisors in number theory?**
   - If $N = p_1^{a_1} p_2^{a_2} \dots p_k^{a_k}$, the number of square-free divisors is $\prod (1 + 1) = 2^k$, identical to setting $f_j = 1$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Combinatorics, Sorting, Two Pointers, Modular Arithmetic.
- **Time Complexity**: $\mathcal{O}(n \log n)$ sorting time.
- **Space Complexity**: $\mathcal{O}(n)$ vector storage.

### Related CSES Tasks
- [CSES 3420 - Distinct Values Subarrays](https://cses.fi/problemset/task/3420): Contiguous version of the problem.
- [CSES 1617 - Bit Strings](https://cses.fi/problemset/task/1617): Basic modular exponentiation combinatorics.
- [CSES 1622 - Creating Strings](https://cses.fi/problemset/task/1622): Multiset permutations.
