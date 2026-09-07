# Repetitions (CSES Task 1069 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1069 - Repetitions](https://cses.fi/problemset/task/1069)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: You are given a DNA sequence: a string consisting of characters `A`, `C`, `G`, and `T`. Your task is to find the longest repetition in the sequence (i.e. the maximum-length contiguous substring containing only one type of character).
- **Constraints**: $1 \le n \le 10^6$, where $n$ is the length of the string.

---

## 1. Problem, Restated

Given a string of up to $10^6$ characters made exclusively of `{A, C, G, T}`, determine the length of the longest contiguous block of identical characters.

**Input**: A single line containing a non-empty string via `cin`.  
**Output**: A single integer denoting the maximum length on `cout` ending with `\n`.  
**Key Constraints**: $n \le 10^6$. An $\mathcal{O}(n^2)$ solution requires $10^{12}$ operations, which will heavily TLE. An $\mathcal{O}(n)$ single-pass scan is strictly required.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Run-Length Scanning / Greedy Sliding Window.
- **Aha! Insight**: As we iterate through the characters from left to right, we only need to compare each character with its immediate predecessor:
  - If `s[i] == s[i - 1]`, the current run continues: `current_streak++`.
  - If `s[i] != s[i - 1]`, a new run begins: `current_streak = 1`.
  - Maintain `max_streak = max(max_streak, current_streak)` at every step.
- **Signal**: "Longest contiguous subarray/substring with property X (all identical elements)" is the canonical run-length linear scan.

---

## 3. Approach 1 — Naive / Baseline (Checking Every Substring)

### Idea
For every starting index $i$ and ending index $j$, verify if all characters in the substring $s[i \dots j]$ are identical.

### C++17 Code
```cpp
#include <iostream>
#include <string>
#include <algorithm>

using namespace std;

int main() {
    string s;
    if (!(cin >> s)) return 0;
    int n = s.size();
    int max_len = 1;

    for (int i = 0; i < n; i++) {
        for (int j = i; j < n; j++) {
            bool all_same = true;
            for (int k = i; k <= j; k++) {
                if (s[k] != s[i]) {
                    all_same = false;
                    break;
                }
            }
            if (all_same) {
                max_len = max(max_len, j - i + 1);
            }
        }
    }

    cout << max_len << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n^3)$ — $\mathcal{O}(n^2)$ substrings, each validated in $\mathcal{O}(n)$ time.
- **Space Complexity**: $\mathcal{O}(1)$ auxiliary space.
- **CSES Verdict**: TLE immediately on $n \ge 1000$.

---

## 4. Approach 2 — Intermediate (Two-Pointer Expansion)

### Idea
For each starting index $i$, expand rightward pointer $j$ as long as $s[j] == s[i]$, then jump $i$ directly to $j$.

### C++17 Code
```cpp
#include <iostream>
#include <string>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    string s;
    if (!(cin >> s)) return 0;
    int n = s.size();
    int max_len = 0;

    int i = 0;
    while (i < n) {
        int j = i;
        while (j < n && s[j] == s[i]) {
            j++;
        }
        max_len = max(max_len, j - i);
        i = j;
    }

    cout << max_len << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n)$ — each character is visited at most twice.
- **Space Complexity**: $\mathcal{O}(n)$ to hold the string in memory.

---

## 5. Approach 3 — Optimal CSES Solution (Single-Pass Online Scan)

### Idea
We can scan the string in a single linear pass maintaining only `current_len` and `max_len`. This requires only $\mathcal{O}(1)$ auxiliary memory and finishes in one pass.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <string>
#include <algorithm>

using namespace std;

int main() {
    // Standardized Fast I/O for 1M characters
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    string s;
    if (!(cin >> s)) return 0;

    int max_len = 1;
    int current_len = 1;

    for (size_t i = 1; i < s.size(); i++) {
        if (s[i] == s[i - 1]) {
            current_len++;
        } else {
            current_len = 1;
        }
        if (current_len > max_len) {
            max_len = current_len;
        }
    }

    cout << max_len << '\n';

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n)$ — exact $n - 1$ character comparisons. For $n = 10^6$, takes $\approx 12$ ms.
- **Space Complexity**: $\mathcal{O}(n)$ to store the string ($\approx 1$ MB, well within 512 MB). Can be reduced to $\mathcal{O}(1)$ space using character-by-character stream reading.
- **Optimality**: Matches the best known/asymptotically optimal complexity for the problem ($\Omega(n)$ lower bound to examine the input) and comfortably satisfies the CSES limits.

---

## 6. Correctness Proof

- **Invariant Definition**: Let $L(i)$ be the length of the longest contiguous monochromatic block ending at index $i$, and $M(i) = \max_{0 \le k \le i} L(k)$ be the global maximum length over the prefix $s[0 \dots i]$.
- **Base Case**: At $i = 0$, $L(0) = 1$ and $M(0) = 1$, which is correct for a string of length 1.
- **Inductive Step**: Assume $L(i-1)$ and $M(i-1)$ are correct.
  - If $s[i] == s[i-1]$, character $s[i]$ extends the monochromatic block ending at $i-1$. Therefore $L(i) = L(i-1) + 1$.
  - If $s[i] \ne s[i-1]$, no contiguous monochromatic block can cross the boundary between $i-1$ and $i$. The block ending at $i$ starts at $i$, so $L(i) = 1$.
  - In both cases, $M(i) = \max(M(i-1), L(i))$.
- **Termination & Completeness**: The loop covers all indices $1 \dots n-1$. Upon termination, $M(n-1)$ is strictly the maximum length of any monochromatic contiguous substring in $s$.

---

## 7. Dry Run & Visual State Trace

Input: `s = "ATTCGGGA"`

| Index `i` | Character `s[i]` | Previous `s[i-1]` | Match? | `current_len` | `max_len` |
|:---:|:---:|:---:|:---:|:---:|:---:|
| 0 | `'A'` | - | Initial | 1 | 1 |
| 1 | `'T'` | `'A'` | No | 1 | 1 |
| 2 | `'T'` | `'T'` | Yes | 2 | 2 |
| 3 | `'C'` | `'T'` | No | 1 | 2 |
| 4 | `'G'` | `'C'` | No | 1 | 2 |
| 5 | `'G'` | `'G'` | Yes | 2 | 2 |
| 6 | `'G'` | `'G'` | Yes | 3 | 3 |
| 7 | `'A'` | `'G'` | No | 1 | 3 |

Output: `3` (from `"GGG"`) ✅

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Length $n = 1$**: Loop from index 1 to $n-1$ never runs; correctly prints initialized `max_len = 1`.
- **All characters identical** (e.g. `"AAAAAA"`): `current_len` grows monotonically to $n$; correctly outputs $n$.
- **All characters alternating** (e.g. `"ACGTACGT"`): `current_len` resets on each step; correctly outputs 1.
- **Memory Footprint**: `string` of $10^6$ characters occupies $1$ MB, comfortably within the 512 MB limit.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Q1: What if memory limit is 1 KB (streaming data)?**
   - **A**: Read characters one by one with `char ch; while (cin >> ch)` without saving the string. Compare with `prev_ch`. Memory is strictly $\mathcal{O}(1)$.
2. **Q2: What if we can replace at most $k$ characters to maximize the repetition?**
   - **A**: Sliding window with frequency map: find $\max(\text{window length})$ such that $\text{window length} - \text{max frequency in window} \le k$ (LeetCode 424).
3. **Q3: What if we need to return both the maximum length and the character that achieved it?**
   - **A**: Track `best_char`: whenever `current_len > max_len`, update `best_char = s[i]`.
4. **Q4: What if queries update characters dynamically ($Q \le 10^5$ updates)?**
   - **A**: Use a Segment Tree where each node stores prefix matching, suffix matching, total length, and maximum internal run for each character. Merging two nodes takes $\mathcal{O}(1)$, yielding $\mathcal{O}(\log n)$ query and update times.
5. **Q5: Can this be parallelized for terabytes of genetic sequencing data?**
   - **A**: Yes. Divide data into chunks. Each worker computes internal max run and prefix/suffix boundary runs. The master node merges adjacent boundaries in $\mathcal{O}(1)$ per chunk boundary.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `Strings`, `Two-Pointers`, `Greedy`, `Linear-Scan`, `Fast-IO`
- **Complexity Summary**:
  - **Time**: $\mathcal{O}(n)$
  - **Space**: $\mathcal{O}(1)$ auxiliary space
- **Related CSES Problems**:
  - **[CSES 1083 - Missing Number](https://cses.fi/problemset/task/1083)**: Single-pass invariant verification.
  - **[CSES 1094 - Increasing Array](https://cses.fi/problemset/task/1094)**: Sequential adjacent element adjustments.
  - **[CSES 1755 - Palindrome Reorder](https://cses.fi/problemset/task/1755)**: Character frequency analysis and rearrangement.
