# Creating Strings (CSES Task 1622 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1622 - Creating Strings](https://cses.fi/problemset/task/1622)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Given a string, your task is to generate all different strings that can be created using its characters. Print the number of different strings, and then all strings in alphabetical order.
- **Constraints**: $1 \le n \le 8$, where $n$ is the length of the string. The string consists of lowercase English characters `a`–`z`.

---

## 1. Problem, Restated

Given a string with length at most 8 (possibly containing duplicate characters), generate and print all distinct permutations of the multiset of characters in lexicographical (alphabetical) order, along with the total count.

**Input**: A single line containing a string via `cin`.  
**Output**: First line contains the integer count $K$. The following $K$ lines each contain one distinct string in alphabetical order on `cout`.  
**Key Constraints**: $n \le 8$. The maximum number of permutations occurs when all characters are distinct: $8! = 40,320$. When duplicate characters exist, the count is strictly less. An algorithm running in $\mathcal{O}(n \cdot P)$ where $P \le 40,320$ finishes in a few milliseconds.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Multiset Permutations / Lexicographical Traversal / Backtracking.
- **Aha! Insight**:
  - The total number of distinct strings formed from character frequencies $f_1, f_2, \dots, f_k$ is the multinomial coefficient:
    $$P = \frac{n!}{f_1! \, f_2! \, \cdots \, f_k!} \le 8! = 40,320$$
  - If we sort the input string alphabetically at the start, it represents the **lexicographically first** permutation.
  - Repeatedly calling `next_permutation` transforms the string to the next valid distinct permutation in lexicographical order, naturally skipping duplicate anagrams.
  - Accumulate the strings in a `vector<string>` until `next_permutation` returns `false`.
  - Print the size, followed by each permutation.
- **Signal**: "Generate all distinct reorderings in alphabetical order" for small $n \le 10$ is the canonical `next_permutation` or multiset backtracking problem.

---

## 3. Approach 1 — Naive / Baseline (Generating All Permutations and Deduplicating with Set)

### Idea
Generate all $n!$ index permutations without duplicate filtering, insert all into `set<string>`, then print the set size and contents.

### C++17 Code
```cpp
#include <iostream>
#include <string>
#include <vector>
#include <numeric>
#include <algorithm>
#include <set>

using namespace std;

int main() {
    string s;
    if (!(cin >> s)) return 0;
    int n = s.size();

    vector<int> p(n);
    iota(p.begin(), p.end(), 0);

    set<string> unique_strings;
    do {
        string cur = "";
        for (int idx : p) cur += s[idx];
        unique_strings.insert(cur);
    } while (next_permutation(p.begin(), p.end()));

    cout << unique_strings.size() << '\n';
    for (const string& str : unique_strings) {
        cout << str << '\n';
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n! \cdot (n \log(\text{set size})))$ — for $n = 8$, $40320 \times 8 \times 16 \approx 5 \times 10^6$ operations.
- **Space Complexity**: $\mathcal{O}(P \cdot n)$ memory for red-black tree nodes.
- **Why it's sub-optimal**: `set<string>` introduces tree node allocation and string comparison overhead for duplicate insertions.

---

## 4. Approach 2 — Intermediate (Recursive Backtracking with Frequency Map)

Recursively choose characters from a frequency table `freq[26]`, pruning duplicate choices at the same recursion depth.
While optimal, `next_permutation` below is more compact and directly leverages the C++ standard library.

---

## 5. Approach 3 — Optimal CSES Solution (`next_permutation` on Sorted String)

### Idea
1. Read `s` and sort it alphabetically: `sort(s.begin(), s.end())`.
2. Push `s` to a `vector<string> res`.
3. Use a `while (next_permutation(s.begin(), s.end()))` loop, pushing each distinct permutation to `res`.
4. Print `res.size()`, then print each string.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
    // Standardized Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    string s;
    if (!(cin >> s)) return 0;

    // Sort to obtain the lexicographically smallest permutation
    sort(s.begin(), s.end());

    vector<string> results;
    do {
        results.push_back(s);
    } while (next_permutation(s.begin(), s.end()));

    cout << results.size() << '\n';
    for (const string& str : results) {
        cout << str << '\n';
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n + n \cdot P)$ where $P = \frac{n!}{\prod f_i!} \le 40,320$. Each `next_permutation` step takes $\mathcal{O}(n)$ time amortized. Total operations $\approx 3.2 \cdot 10^5$, executing in $\approx 2$ ms.
- **Space Complexity**: $\mathcal{O}(n \cdot P)$ memory to buffer the permutations before printing the count. For $P \le 40,320$ and $n \le 8$, memory is $\approx 350$ KB.
- **Optimality Guarantee**: Matches the best known/asymptotically optimal complexity for the problem ($\Omega(n \cdot P)$ to output all characters) and comfortably satisfies the CSES limits.

---

## 6. Correctness Proof

- **Initial Lexicographical Minimality**:
  - A string $s$ is lexicographically minimal among all permutations of its character multiset if and only if $s[0] \le s[1] \le \dots \le s[n - 1]$. Sorting initially establishes this invariant.
- **Successor Invariant (`next_permutation`)**:
  - Given a sequence, `next_permutation` finds the largest index $i$ such that $s[i] < s[i + 1]$.
  - If no such $i$ exists, the entire sequence is non-increasing ($s[0] \ge s[1] \ge \dots \ge s[n-1]$), which is the lexicographically maximal permutation; the algorithm terminates.
  - Otherwise, it identifies the smallest element $s[j]$ strictly greater than $s[i]$ to the right of $i$ ($j > i$), swaps $s[i]$ and $s[j]$, and reverses the suffix $s[i + 1 \dots n - 1]$.
  - This guarantees:
    1. The new sequence is strictly greater lexicographically than the previous sequence.
    2. No intermediate permutation of the multiset exists between the two sequences.
    3. Identical characters never produce duplicate sequence states.
- **Exhaustiveness & Ordering**:
  - The sequence starts at the unique minimum, visits every distinct valid permutation in strictly ascending order, and terminates at the unique maximum. The resulting list is complete, strictly sorted, and duplicate-free.

---

## 7. Dry Run & Visual State Trace

Input: `s = "aab"` (Length $n = 3$, characters $\{a: 2, b: 1\}$)
- Multinomial Count: $\frac{3!}{2! \, 1!} = \frac{6}{2} = 3$ strings.
- Initial sorted string: `"aab"`

| Step | State | Action | Next Permutation Found? |
|:---:|:---:|:---:|:---:|
| 1 | `"aab"` | Record `"aab"` | `next_permutation("aab")` $\to$ swaps $a$ and $b$, gives `"aba"` (true) |
| 2 | `"aba"` | Record `"aba"` | `next_permutation("aba")` $\to$ gives `"baa"` (true) |
| 3 | `"baa"` | Record `"baa"` | `next_permutation("baa")` $\to$ non-increasing suffix, returns `false` |

Output:
```
3
aab
aba
baa
```
Total strings: 3 ✅

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **Length $n = 1$** (e.g. `"a"`): Loop runs once, prints `1\na\n`.
- **All characters identical** (e.g. `"aaaa"`): Count is $\frac{4!}{4!} = 1$; outputs `1\naaaa\n`.
- **All characters distinct** (e.g. `"abcdefgh"`): Generates all $8! = 40,320$ strings.
- **Fast I/O**: Outputting 40,320 strings of length 8 requires `cin.tie(nullptr)` and `'\n'` to avoid stream flushing.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Q1: What if $n$ is up to $10^5$ and we ONLY need to output the total count of distinct permutations modulo $10^9 + 7$?**
   - **A**: Precompute factorials and modular inverses using Fermat's Little Theorem. The answer is $\frac{n!}{\prod f_i!} \pmod{10^9 + 7}$, computable in $\mathcal{O}(n + \log \text{MOD})$ time (CSES Task 1715 - Creating Strings II).
2. **Q2: What is the $k$-th lexicographical permutation directly without generating the previous $k - 1$?**
   - **A**: Factoradic / Combinatorial Number System: for each position from left to right, count how many permutations start with each available candidate character using $\frac{(n - 1 - i)!}{\prod f_c!}$. Compare with remaining $k$ to place the character in $\mathcal{O}(26 \cdot n)$ time.
3. **Q3: How do we implement `next_permutation` from scratch without `<algorithm>`?**
   - **A**:
     ```cpp
     bool my_next_permutation(string& s) {
         int n = s.size(), i = n - 2;
         while (i >= 0 && s[i] >= s[i + 1]) i--;
         if (i < 0) return false;
         int j = n - 1;
         while (s[j] <= s[i]) j--;
         swap(s[i], s[j]);
         reverse(s.begin() + i + 1, s.end());
         return true;
     }
     ```
4. **Q4: Can we stream the permutations directly without storing all $40,320$ strings in memory?**
   - **A**: Yes. Compute the count $P = \frac{n!}{\prod f_i!}$ first using a small factorial formula, print $P$, and then print each string on the fly inside the `do ... while` loop in $\mathcal{O}(1)$ auxiliary space.
5. **Q5: What if we want to generate permutations such that no two adjacent characters are identical?**
   - **A**: Backtracking with lookahead pruning, or a max-heap greedy strategy placing the most frequent valid character at each step.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `Strings`, `Permutations`, `Combinatorics`, `Backtracking`, `Fast-IO`
- **Complexity Summary**:
  - **Time**: $\mathcal{O}(n \cdot P)$ where $P \le 40,320$
  - **Space**: $\mathcal{O}(n \cdot P)$
- **Related CSES Problems**:
  - **[CSES 1715 - Creating Strings II](https://cses.fi/problemset/task/1715)**: Combinatorial multinomial counting modulo $10^9 + 7$ for $n \le 10^6$.
  - **[CSES 1070 - Permutations](https://cses.fi/problemset/task/1070)**: Beautiful permutations without adjacent difference 1.
  - **[CSES 1623 - Apple Division](https://cses.fi/problemset/task/1623)**: Subset generation and partition balance.
