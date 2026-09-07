# Collecting Numbers (CSES Task 2216 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 2216 - Collecting Numbers](https://cses.fi/problemset/task/2216)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: You are given an array that contains each number between $1 \dots n$ exactly once (a permutation). You collect the numbers from $1$ to $n$ in increasing order. On each round, you go through the array from left to right and collect as many numbers as possible. What will be the total number of rounds?
- **Constraints**: $1 \le n \le 2 \cdot 10^5$.

---

## 1. Problem, Restated

Given a permutation $x_1, x_2, \dots, x_n$ of $\{1, 2, \dots, n\}$, determine the minimum number of left-to-right sweeps across the array needed to collect all elements in strictly increasing order $1, 2, \dots, n$.

**Input**:
- First line: integer $n$ ($1 \le n \le 2 \cdot 10^5$).
- Second line: $n$ space-separated integers $x_1, \dots, x_n$.

**Output**:
- Print a single integer: the total number of rounds.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Permutation Inversions / Inverse Permutation Indexing / Greedy Traversal.
- **Aha! Insight**:
  - We must collect numbers strictly in the sequence $1, 2, 3, \dots, n$.
  - Let $\text{pos}[v]$ denote the index in the original array where the number $v$ appears ($1 \le v \le n$).
  - Suppose we have just collected the number $v - 1$ at position $\text{pos}[v - 1]$.
    - Can we collect $v$ during the **same** left-to-right pass?
    - If $\text{pos}[v] > \text{pos}[v - 1]$, then $v$ appears to the right of $v - 1$. As we continue our sweep to the right, we naturally encounter $v$ and collect it in the current round!
    - If $\text{pos}[v] < \text{pos}[v - 1]$, then $v$ appeared earlier in the array than $v - 1$. Since our sweep only moves left-to-right, we have already passed $v$ and cannot turn back. A brand new round must be started to collect $v$!
  - Therefore, a new round is triggered if and only if $\text{pos}[v] < \text{pos}[v - 1]$.
  - The total number of rounds required is simply:
    $$\text{Rounds} = 1 + \sum_{v=2}^n \mathbf{1}_{(\text{pos}[v] < \text{pos}[v-1])}$$
  - This reduces the problem to an $\mathcal{O}(n)$ linear scan over the inverted index array!
- **Signal**: Any problem asking how many left-to-right passes are needed to visit numbers in sorted order depends strictly on adjacent index comparisons $\text{pos}[v] < \text{pos}[v-1]$.

---

## 3. Approach 1 — Naive / Baseline (Simulate Sweeps)

Directly simulate each pass: start at index 0, scan to index $n-1$ collecting the target number whenever encountered.
In the worst-case (reverse sorted array $[n, n-1, \dots, 1]$), each round collects only 1 number. The simulation takes $n$ passes of length $n$, yielding $\mathcal{O}(n^2)$ time. For $n = 2 \cdot 10^5$, $n^2 = 4 \cdot 10^{10} \implies$ TLE.

---

## 4. Approach 2 — Intermediate (Sorting Pairs `(value, index)`)

Store each element as `pair<int, int>` with `(value, index)`. Sort the pairs to place values in increasing order, then count how many times `a[i].index < a[i-1].index`.
While $\mathcal{O}(n \log n)$, an inverse index array (Approach 3) runs in strictly linear $\mathcal{O}(n)$ time without comparison sorting.

---

## 5. Approach 3 — Optimal CSES Solution (Inverse Permutation Array)

### Idea
1. Read $n$ numbers. For each number $x$ at 0-based index $i$, record $\text{pos}[x] = i$.
2. Initialize `rounds = 1`.
3. Iterate $v$ from 2 to $n$:
   - If $\text{pos}[v] < \text{pos}[v-1]$, increment `rounds++`.
4. Output `rounds`.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    vector<int> pos(n + 1);
    for (int i = 0; i < n; ++i) {
        int x;
        cin >> x;
        pos[x] = i;
    }

    int rounds = 1;
    for (int v = 2; v <= n; ++v) {
        if (pos[v] < pos[v - 1]) {
            rounds++;
        }
    }

    cout << rounds << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n)$ single-pass input reading + $\mathcal{O}(n)$ linear scan from $2$ to $n$. Total operations $\approx 4 \cdot 10^5$, executing in $\approx 0.02$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ memory for the `pos` array ($2 \cdot 10^5 \times 4$ bytes $\approx 800$ KB).

---

## 6. Correctness Proof

1. **Greedy Traversal Property**:
   In any single left-to-right pass starting at index 0 and ending at index $n-1$, a set of consecutive values $v, v+1, \dots, v+k$ can be collected if and only if their indices are strictly increasing:
   $$\text{pos}[v] < \text{pos}[v+1] < \dots < \text{pos}[v+k]$$
2. **Necessity of Starting a New Round**:
   If $\text{pos}[v] < \text{pos}[v - 1]$, then by the time $v - 1$ is collected, the current scan position is $\text{pos}[v - 1]$.
   Since the scan only moves forward (indices $\ge \text{pos}[v-1]$), and $\text{pos}[v] < \text{pos}[v-1]$, the element $v$ cannot be visited in the remainder of the current pass.
   Because $v$ cannot be collected before $v - 1$, collecting $v$ strictly requires a subsequent pass.
3. **Sufficiency of One Extra Round**:
   Whenever a new round begins, the scan starts back at index 0. Element $v$ will be encountered at $\text{pos}[v]$ and collected. Any subsequent element $w = v + 1$ with $\text{pos}[w] > \text{pos}[v]$ will be collected in that same pass.
   Thus, the number of rounds increases by exactly 1 if and only if $\text{pos}[v] < \text{pos}[v-1]$.
4. Total rounds is identically $1 + \sum_{v=2}^n \mathbf{1}_{(\text{pos}[v] < \text{pos}[v-1])}$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 5$, array: `[4, 2, 1, 5, 3]`.
Indices (0-based):
- Value 4 is at index 0 $\implies \text{pos}[4] = 0$
- Value 2 is at index 1 $\implies \text{pos}[2] = 1$
- Value 1 is at index 2 $\implies \text{pos}[1] = 2$
- Value 5 is at index 3 $\implies \text{pos}[5] = 3$
- Value 3 is at index 4 $\implies \text{pos}[3] = 4$

Inverse positions:
`pos = [-, 2, 1, 4, 0, 3]` (for values $1, 2, 3, 4, 5$).

Transitions:
- Value 1: Start round 1. Position = 2.
- Value 2: $\text{pos}[2] = 1 < \text{pos}[1] = 2 \implies$ **New round 2**!
- Value 3: $\text{pos}[3] = 4 > \text{pos}[2] = 1 \implies$ Same round 2.
- Value 4: $\text{pos}[4] = 0 < \text{pos}[3] = 4 \implies$ **New round 3**!
- Value 5: $\text{pos}[5] = 3 > \text{pos}[4] = 0 \implies$ Same round 3.

Rounds breakdown:
- Round 1 collects: `{1}`
- Round 2 collects: `{2, 3}`
- Round 3 collects: `{4, 5}`

Total rounds: **3**.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Already Sorted Array ($[1, 2, \dots, n]$)**: $\text{pos}[v] = v - 1$. $\text{pos}[v] > \text{pos}[v-1]$ always holds, outputs `1`.
- **Reverse Sorted Array ($[n, n-1, \dots, 1]$)**: $\text{pos}[v] < \text{pos}[v-1]$ for every $v \ge 2$, outputs $n$.
- **$n = 1$**: Loop $v$ from 2 to 1 does not execute, correctly outputs `1`.
- **1-based vs 0-based indexing**: `pos` vector must have size $n + 1$ so that accessing `pos[n]` is safe.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if we have $m$ swap queries (Collecting Numbers II)?**
   - Each swap between $x_a$ and $x_b$ only affects the relative order of at most 4 pairs of numbers: $(x_a - 1, x_a), (x_a, x_a + 1), (x_b - 1, x_b), (x_b, x_b + 1)$. We can update the answer in $\mathcal{O}(1)$ time per query (CSES 2217).
2. **What if we can collect numbers backwards from right to left as well?**
   - This becomes an alternating sweep problem; each transition depends on whether the next target lies in the current scan direction.
3. **What is the maximum possible number of rounds?**
   - The maximum is $n$ (achieved when the permutation is strictly descending).
4. **How does this relate to Dilworth's Theorem?**
   - The collection of numbers into rounds partitions the sequence of indices into increasing subsequences. By Dilworth's Theorem, the minimum number of increasing subsequences equals the size of the maximum decreasing subsequence.
5. **Can this be solved if array elements have duplicates?**
   - If values can repeat, we greedily pick the nearest valid instance $\ge$ current scan pointer, requiring binary search (`std::upper_bound`) over vectors of indices.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Greedy, Sorting, Permutations, Inversions, Two Pointers.
- **Time Complexity**: $\mathcal{O}(n)$ linear time.
- **Space Complexity**: $\mathcal{O}(n)$ space for inverse index mapping.

### Related CSES Tasks
- [CSES 2217 - Collecting Numbers II](https://cses.fi/problemset/task/2217): Dynamic updates with $\mathcal{O}(1)$ swap queries.
- [CSES 1069 - Repetitions](https://cses.fi/problemset/task/1069): Single-pass linear scan.
- [CSES 1070 - Permutations](https://cses.fi/problemset/task/1070): Constructive permutation ordering.
