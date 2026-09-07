# Playlist (CSES Task 1141 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1141 - Playlist](https://cses.fi/problemset/task/1141)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Given a playlist of $n$ songs, find the length of the longest contiguous subsegment of songs where all songs are distinct.
- **Constraints**: $1 \le n \le 2 \cdot 10^5$, $1 \le k_i \le 10^9$.

---

## 1. Problem, Restated

Given an array $k_1, k_2, \dots, k_n$ of song IDs, find:
$$\max_{0 \le L \le R < n} (R - L + 1)$$
such that for all $L \le i < j \le R$, $k_i \ne k_j$.

**Input**:
- First line: an integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Second line: $n$ space-separated integers $k_1, \dots, k_n$.

**Output**:
- Print a single integer: the length of the longest contiguous sequence of unique songs.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Sliding Window / Two Pointers / Last Seen Position Tracking / Hash Map.
- **Aha! Insight**:
  - Suppose our current valid contiguous window without duplicate songs is $[L, R-1]$.
  - When we attempt to expand the window to include song $k_R$:
    - If song $k_R$ has never appeared within the current window $[L, R-1]$, the window $[L, R]$ remains valid, and its length is $R - L + 1$.
    - If song $k_R$ already appeared at some index $P \in [L, R-1]$, we must advance the left boundary $L$ to $P + 1$ to discard the previous duplicate!
  - Therefore, we only need to remember the **last seen index** of each song ID.
  - As the right pointer $R$ advances from $0$ to $n-1$:
    $$L = \max(L, \text{last\_pos}[k_R] + 1)$$
    $$\text{last\_pos}[k_R] = R$$
    $$\text{max\_len} = \max(\text{max\_len}, R - L + 1)$$
  - Because $L$ only moves forward (monotonically non-decreasing), the sliding window processes the entire array in linear time amortized over the index map lookups.
- **Signal**: "Longest contiguous subarray with all distinct values" is the canonical sliding window with last-occurrence tracking.

---

## 3. Approach 1 — Naive / Baseline (Quadratic Window Verification)

Check every possible starting position $L$ and scan forward until a duplicate is encountered using a set.
Takes $\mathcal{O}(n^2)$ time in the worst case (e.g. all songs distinct), requiring $4 \cdot 10^{10}$ operations $\implies$ TLE.

---

## 4. Approach 2 — Intermediate (Two Pointers with `std::set`)

Maintain an active `std::set<int>` of elements in the current window $[L, R]$. While $k_R$ is in the set, erase $k_L$ and increment $L++$. Then insert $k_R$.
While $\mathcal{O}(n \log n)$, elements are repeatedly inserted and erased from the set, adding unnecessary tree overhead.

---

## 5. Approach 3 — Optimal CSES Solution (Sliding Window with Coordinate Compression or `std::map`)

### Idea
Maintain a `map<int, int> last_seen` mapping song ID to its most recent 0-based index.
Initialize $L = 0$ and `max_len = 0`.
For $R = 0, \dots, n-1$:
- If $k_R$ was seen previously, update $L = \max(L, \text{last\_seen}[k_R] + 1)$.
- Update $\text{last\_seen}[k_R] = R$.
- Update $\text{max\_len} = \max(\text{max\_len}, R - L + 1)$.
- Output `max_len`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <map>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> a(n);
    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    map<int, int> last_pos;
    int l = 0;
    int max_len = 0;

    for (int r = 0; r < n; ++r) {
        int song = a[r];
        if (last_pos.count(song)) {
            // Jump left pointer past previous occurrence if inside current window
            l = max(l, last_pos[song] + 1);
        }
        last_pos[song] = r;
        max_len = max(max_len, r - l + 1);
    }

    cout << max_len << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n)$ due to $n$ lookups in `std::map`. For $n = 2 \cdot 10^5$, $n \log_2 n \approx 3.6 \times 10^6$ operations, executing in $\approx 0.15$ seconds. (With coordinate compression or `custom_hash` unordered map, this runs in strictly $\mathcal{O}(n)$ time $\approx 0.03$s).
- **Space Complexity**: $\mathcal{O}(n)$ memory for `last_pos` map and array storage.

---

## 6. Correctness Proof

1. **Window Invariant**:
   At the start of iteration $R$, the window $[L, R-1]$ contains only distinct song IDs.
2. **Duplicate Exclusion**:
   When considering element $a_R$:
   - If $a_R$ previously occurred at index $P < L$, that previous occurrence is already strictly outside the window $[L, R-1]$. The window remains valid without moving $L$.
   - If $a_R$ previously occurred at index $P \ge L$, including $a_R$ at position $R$ creates a duplicate of $a_P$.
     To eliminate this duplicate, any valid window ending at $R$ must start strictly after $P$ ($L' \ge P + 1$).
     Setting $L \gets \max(L, P + 1)$ chooses the minimal possible starting index that removes $P$, maximizing the resulting window length.
3. **Optimality**:
   For every right endpoint $R \in [0, n-1]$, the algorithm computes the earliest possible left endpoint $L(R)$ such that $[L(R), R]$ contains no duplicates.
   Since any subsegment with right endpoint $R$ must have a starting index $\ge L(R)$, $R - L(R) + 1$ is the maximal length of a distinct subsegment ending at $R$.
   Maximizing this over all $R$ yields the globally optimal maximum unique subsegment. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 8$, array = `[1, 2, 1, 3, 2, 7, 4, 2]`.

| $R$ | Song $a_R$ | Previous Index $P$ | Left Pointer $L = \max(L, P+1)$ | Window $[L, R]$ | Window Length | Max Length |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 0 | 1 | None | 0 | `[1]` | 1 | 1 |
| 1 | 2 | None | 0 | `[1, 2]` | 2 | 2 |
| 2 | 1 | 0 | $\max(0, 0+1) = 1$ | `[2, 1]` | 2 | 2 |
| 3 | 3 | None | 1 | `[2, 1, 3]` | 3 | 3 |
| 4 | 2 | 1 | $\max(1, 1+1) = 2$ | `[1, 3, 2]` | 3 | 3 |
| 5 | 7 | None | 2 | `[1, 3, 2, 7]` | 4 | 4 |
| 6 | 4 | None | 2 | `[1, 3, 2, 7, 4]` | 5 | **5** |
| 7 | 2 | 4 | $\max(2, 4+1) = 5$ | `[7, 4, 2]` | 3 | 5 |

Final Output: **5** (corresponding to subsegment `[1, 3, 2, 7, 4]`).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **All songs unique ($k_1 < k_2 < \dots < k_n$)**: $L$ remains 0 for all $R$; output is $n$.
- **All songs identical ($k_1 = k_2 = \dots = k_n$)**: $L$ advances to $R$ on every step; output is 1.
- **$n = 1$**: Output is 1.
- **Song IDs up to $10^9$**: Values cannot directly index a flat array; `std::map` or coordinate compression is mandatory.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How to solve this in strictly $\mathcal{O}(n)$ time without `std::map`?**
   - Coordinate compress the song IDs to $[0, U-1]$ in $\mathcal{O}(n \log n)$, then use a flat integer array `int last_pos[U]` for $\mathcal{O}(1)$ lookups.
   - Alternatively, use `std::unordered_map` with a custom splitmix64 hash functor to prevent worst-case collision attacks.
2. **What if we want to find the number of subarrays with all unique elements?**
   - At each step $R$, any subarray starting in $[L, R]$ and ending at $R$ has all distinct elements. We simply accumulate $\sum_{R=0}^{n-1} (R - L + 1)$ (this is **Distinct Values Subarrays, CSES 3420**!).
3. **What if at most $k$ duplicates were allowed?**
   - Maintain a frequency map and track the number of elements with frequency $> 1$, advancing $L$ when duplicates exceed $k$.
4. **How would you print the actual songs in the longest playlist?**
   - Track `best_L` and `best_R` when updating `max_len`, then print elements from $a[\text{best\_L}]$ to $a[\text{best\_R}]$.
5. **How does this problem compare to LeetCode 3?**
   - CSES 1141 is the exact integer-array version of LeetCode 3 (Longest Substring Without Repeating Characters).

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Sliding Window, Two Pointers, Hash Map, Deduplication.
- **Time Complexity**: $\mathcal{O}(n \log n)$ using `std::map`, or $\mathcal{O}(n)$ with coordinate compression.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary storage.

### Related CSES Tasks
- [CSES 3420 - Distinct Values Subarrays](https://cses.fi/problemset/task/3420): Counting distinct subarrays via two pointers.
- [CSES 2428 - Distinct Values Subarrays II](https://cses.fi/problemset/task/2428): Sliding window with at most $k$ distinct values.
- [CSES 1621 - Distinct Numbers](https://cses.fi/problemset/task/1621): Global unique elements counting.
