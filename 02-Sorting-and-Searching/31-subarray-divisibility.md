# Subarray Divisibility

- **Category**: Sorting and Searching
- **CSES Task ID**: `1662`
- **CSES Problem Link**: [Subarray Divisibility](https://cses.fi/problemset/task/1662)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers $a_1, a_2, \dots, a_n$, count the total number of contiguous subarrays whose sum is divisible by $n$.

### Input Format
- The first line contains an integer $n$.
- The second line contains $n$ integers $a_1, a_2, \dots, a_n$.

### Output Format
- Print one integer: the number of subarrays with a sum divisible by $n$.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $-10^9 \le a_i \le 10^9$

With $n = 2 \cdot 10^5$, an $\mathcal{O}(n^2)$ check fails with TLE. Additionally, the maximum number of valid subarrays is $\frac{n(n+1)}{2} \approx 2 \cdot 10^{10}$, which exceeds 32-bit signed integer limits and requires `long long`.

---

## 2. Intuition & Pattern Recognition

This problem merges **Prefix Sums** with **Modular Arithmetic**:
- The sum of subarray $a[i \dots j]$ is $P[j] - P[i-1]$, where $P[k] = \sum_{m=1}^k a_m$ and $P[0] = 0$.
- The subarray sum is divisible by $n$ if and only if:
  $$(P[j] - P[i-1]) \equiv 0 \pmod n \iff P[j] \equiv P[i-1] \pmod n$$
- Two prefix sums have the same remainder modulo $n$ if and only if the subarray between them sums to a multiple of $n$.

Because the divisor is $n$, the remainder modulo $n$ can only take $n$ possible values: $0, 1, \dots, n-1$. 
- Instead of using a hash map, we can use a direct-indexed frequency array `cnt[n]` of size $n$.
- If a remainder $r$ occurs $c$ times across all prefix sums $P[0], P[1], \dots, P[n]$, any pair of these indices forms a valid subarray. The number of such pairs is $\binom{c}{2} = \frac{c(c-1)}{2}$.

---

## 3. Approach 1 — Naive / Baseline

Inspect all subarrays $(i, j)$ and check if their sum is divisible by $n$.

### C++17 Baseline Code

```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<long long> a(n);
    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    long long count = 0;
    for (int i = 0; i < n; ++i) {
        long long current_sum = 0;
        for (int j = i; j < n; ++j) {
            current_sum += a[j];
            if (current_sum % n == 0) {
                count++;
            }
        }
    }

    cout << count << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2)$ iterations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE for $n > 5000$.

---

## 4. Approach 2 — Intermediate / Hash Map Frequency Counter

We can track prefix remainders using an `unordered_map<int, int>` or `map<int, int>`.

```cpp
#include <iostream>
#include <vector>
#include <map>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    map<int, int> rem_count;
    rem_count[0] = 1;

    long long current_sum = 0;
    long long ans = 0;

    for (int i = 0; i < n; ++i) {
        long long x;
        cin >> x;
        current_sum += x;
        int rem = ((current_sum % n) + n) % n;
        ans += rem_count[rem];
        rem_count[rem]++;
    }

    cout << ans << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n \log n)$ with `map` or $\mathcal{O}(n)$ with `unordered_map`.
- **Space Complexity**: $\mathcal{O}(n)$.
- **Bottleneck**: Dynamic allocations and hash overhead are entirely unnecessary because the key space is strictly $[0, n-1]$. A fixed-size array is strictly faster and uses $\mathcal{O}(1)$ dynamic overhead.

---

## 5. Approach 3 — Optimal CSES Solution (Direct Array Frequency Count)

We allocate a vector `cnt` of size $n$ initialized to zero. Since an empty prefix has sum $0$, we set `cnt[0] = 1`. 

For each element, we update the running prefix sum, normalize its remainder into $[0, n-1]$ using `((sum % n) + n) % n`, add `cnt[rem]` to our answer, and increment `cnt[rem]`.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    // Direct frequency array for remainders in [0, n - 1]
    vector<long long> cnt(n, 0);
    cnt[0] = 1; // Empty prefix has sum 0, and 0 % n = 0

    long long current_sum = 0;
    long long total_subarrays = 0;

    for (int i = 0; i < n; ++i) {
        long long x;
        cin >> x;
        current_sum += x;

        // Modulo normalization handling negative values
        int rem = ((current_sum % n) + n) % n;

        // Add the number of previous prefixes with the same remainder
        total_subarrays += cnt[rem];

        // Increment the count of this remainder
        cnt[rem]++;
    }

    cout << total_subarrays << '\n';
    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n)$. A single linear pass through the array with $\mathcal{O}(1)$ direct array index operations.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space for the `cnt` vector of size $n$.
- **Optimality Guarantee**: Reading the input requires $\Omega(n)$ time. With $\mathcal{O}(n)$ time and direct array indexing, this is optimal.

---

## 6. Correctness Proof

### Congruence Condition
Let $P[k] = \sum_{m=1}^k a_m$ with $P[0] = 0$. For any $0 \le i < j \le n$:
$$\sum_{m=i+1}^j a_m = P[j] - P[i]$$
This sum is divisible by $n$ if and only if:
$$P[j] - P[i] \equiv 0 \pmod n \iff P[j] \equiv P[i] \pmod n$$

### Modulo Normalization
In C++, the `%` operator on negative numbers yields a negative result (e.g. `-7 % 5 = -2`). Adding $n$ and taking modulo again:
$$((x \bmod n) + n) \bmod n$$
maps every integer $x$ into its unique canonical remainder $r \in \{0, 1, \dots, n-1\}$.

### Counting Argument
When processing $P[j]$ with remainder $r$:
1. Exactly `cnt[r]` previous prefixes $P[i]$ ($i < j$) share this remainder $r$.
2. For each such $P[i]$, the subarray $a[i+1 \dots j]$ has a sum divisible by $n$.
3. Since $j$ is uniquely increasing, each pair $(i, j)$ with $P[i] \equiv P[j] \pmod n$ is counted once, at the moment $j$ is processed.
4. Hence, every valid subarray is counted exactly once.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5
3 1 4 1 5
```

| Step $j$ | Element $a_j$ | Running Sum $P[j]$ | $P[j] \bmod 5$ | `cnt[rem]` Before | Add to Total | Updated `cnt` |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Initial | - | 0 | 0 | 1 | 0 | `cnt[0] = 1` |
| **1** | 3 | 3 | 3 | 0 | 0 | `cnt[3] = 1` |
| **2** | 1 | 4 | 4 | 0 | 0 | `cnt[4] = 1` |
| **3** | 4 | 8 | 3 | 1 | **+1** (pair: $P[1] \equiv P[3] \equiv 3 \implies [1, 4]$) | `cnt[3] = 2` |
| **4** | 1 | 9 | 4 | 1 | **+1** (pair: $P[2] \equiv P[4] \equiv 4 \implies [4, 1]$) | `cnt[4] = 2` |
| **5** | 5 | 14 | 4 | 2 | **+2** (pairs with $P[2]$ and $P[4]$) | `cnt[4] = 3` |

**Total Count**: $0 + 0 + 1 + 1 + 2 = \mathbf{4}$.
- Subarrays:
  1. $a[2 \dots 3] = [1, 4]$, sum $= 5$ (divisible by 5)
  2. $a[3 \dots 4] = [4, 1]$, sum $= 5$ (divisible by 5)
  3. $a[3 \dots 5] = [4, 1, 5]$, sum $= 10$ (divisible by 5)
  4. $a[5 \dots 5] = [5]$, sum $= 5$ (divisible by 5)

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Negative Values**: Elements can be as small as $-10^9$. Cumulative sums can be deeply negative. The double-modulo idiom `((sum % n) + n) % n` ensures non-negative indices into `cnt`.
- **Empty Prefix Initialization**: Omitting `cnt[0] = 1` ignores any prefix that is itself divisible by $n$.
- **64-bit Overflow on Total Count**: If all elements are multiples of $n$, then all $n+1$ prefixes have remainder $0$. The answer is $\binom{n+1}{2} \approx 2 \cdot 10^{10}$, overflowing a 32-bit signed `int`.
- **Large Array Sums**: Cumulative sums can reach $\pm 2 \cdot 10^{14}$, requiring `long long` for `current_sum`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the divisor is $K \ne n$?**
   - If $K \le 10^6$, use an array of size $K$. If $K > 10^6$, use a hash map `unordered_map<int, int, custom_hash>` to count frequencies of remainder states in $\mathcal{O}(n)$ time.
2. **Subarray sum with remainder $R \ne 0$?**
   - Condition becomes $(P[j] - P[i-1]) \equiv R \pmod K \iff P[i-1] \equiv (P[j] - R) \pmod K$. Query the frequency of `(rem - R + K) % K`.
3. **Longest subarray divisible by $K$?**
   - Store the first occurrence index of each remainder $r$. The maximum length ending at $j$ is $j - \text{first}[r]$.
4. **Range updates with Divisibility Queries?**
   - If array values undergo point updates, dynamic prefix remainders shift. For prime $K$, maintaining remainder distributions requires a Segment Tree with convolution/frequency vectors at each node, taking $\mathcal{O}(K \log n)$ per update.
5. **Divisibility in 2D grids?**
   - Iterate over pair of rows $(r_1, r_2)$ in $\mathcal{O}(R^2)$, compute column prefix sums, and apply the 1D algorithm on the columns in $\mathcal{O}(C)$. Total time: $\mathcal{O}(R^2 \cdot C)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[prefix-sums, modular-arithmetic, counting, sorting-and-searching]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - `CSES 1661` — [Subarray Sums II](https://cses.fi/problemset/task/1661) (Exact sum match with negative numbers).
  - `CSES 1660` — [Subarray Sums I](https://cses.fi/problemset/task/1660) (Two-pointer approach for strictly positive values).
  - `CSES 1643` — [Maximum Subarray Sum](https://cses.fi/problemset/task/1643) (Kadane's algorithm).
