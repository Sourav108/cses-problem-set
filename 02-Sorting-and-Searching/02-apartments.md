# Apartments (CSES Task 1084 — Sorting and Searching)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 1084 - Apartments](https://cses.fi/problemset/task/1084)
- **Category**: `02-Sorting-and-Searching`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: There are $n$ applicants and $m$ free apartments. Each applicant has a desired apartment size $a_i$ and will accept any apartment of size $b_j$ such that $|a_i - b_j| \le k$. Maximize the number of applicants who get an apartment.
- **Constraints**: $1 \le n, m \le 2 \cdot 10^5$, $0 \le k \le 10^9$, $1 \le a_i, b_j \le 10^9$.

---

## 1. Problem, Restated

Given:
- An array $a$ of $n$ applicant desired sizes.
- An array $b$ of $m$ apartment sizes.
- A tolerance threshold $k$.

An applicant $i$ accepts an apartment $j$ if and only if:
$$a_i - k \le b_j \le a_i + k$$
Each applicant can occupy at most one apartment, and each apartment can be allocated to at most one applicant (maximum bipartite matching on an interval graph). Find the maximum number of matched pairs.

**Input**:
- First line: three integers $n, m, k$.
- Second line: $n$ space-separated integers $a_1, \dots, a_n$.
- Third line: $m$ space-separated integers $b_1, \dots, b_m$.

**Output**:
- Print a single integer: the maximum number of applicants who receive an apartment.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Greedy Strategy / Two Pointers / Bipartite Matching on Convex Graphs / Interval Scheduling.
- **Aha! Insight**:
  - Suppose we sort both the applicants $a$ and apartments $b$ in ascending order.
  - Consider the applicant with the smallest desired size $a_i$. If there are several apartments that satisfy $a_i - k \le b_j \le a_i + k$, which one should we give to $a_i$?
  - **Greedy Choice**: We should give applicant $i$ the **smallest** available compatible apartment!
    - Giving $a_i$ a larger compatible apartment $b_{j'}$ ($b_{j'} > b_j$) can only hurt future applicants with larger demands $a_{i'} \ge a_i$, because smaller apartments are harder for larger applicants to satisfy.
  - This allows a linear **two-pointer scan**:
    - Pointer $i$ for applicants, pointer $j$ for apartments.
    - If $b_j < a_i - k$: apartment $j$ is too small for applicant $i$. Because applicants are sorted, $b_j$ is strictly too small for all subsequent applicants $i' \ge i$. Hence apartment $j$ is useless; advance $j++$.
    - If $b_j > a_i + k$: apartment $j$ is too large for applicant $i$. Because apartments are sorted, all subsequent apartments $j' \ge j$ are even larger. Hence applicant $i$ can never be satisfied; advance $i++$.
    - If $|a_i - b_j| \le k$: match applicant $i$ with apartment $j$, advance both $i++, j++$, and increment our match count.
- **Signal**: Matching two 1D point sets with tolerance bounds $|a_i - b_j| \le k$ is the textbook sorted two-pointer greedy match.

---

## 3. Approach 1 — Naive / Baseline (`std::multiset` with Binary Search)

### Idea
Insert all apartment sizes into a `std::multiset<int>`. For each applicant $a_i$, search for the smallest element $\ge a_i - k$ using `lower_bound`. If that element is $\le a_i + k$, erase it and increment the counter.

### C++17 Code
```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <set>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    long long k;
    if (!(cin >> n >> m >> k)) return 0;

    vector<long long> a(n);
    for (int i = 0; i < n; ++i) cin >> a[i];

    multiset<long long> b;
    for (int i = 0; i < m; ++i) {
        long long x;
        cin >> x;
        b.insert(x);
    }

    sort(a.begin(), a.end());

    int matches = 0;
    for (int i = 0; i < n; ++i) {
        auto it = b.lower_bound(a[i] - k);
        if (it != b.end() && *it <= a[i] + k) {
            matches++;
            b.erase(it);
        }
    }

    cout << matches << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(m \log m + n \log m)$ due to tree insertions and tree node deletions. For $N, M = 2 \cdot 10^5$, this takes $\approx 0.35$s.
- **Space Complexity**: $\mathcal{O}(m)$ node allocations for the red-black tree.

---

## 4. Approach 2 — Intermediate (Sorting + Binary Search with Deque)

Sorting both arrays, then binary searching for each applicant.
While $\mathcal{O}(n \log m)$, marking elements as used requires a balanced BST or Fenwick Tree to avoid $\mathcal{O}(m)$ vector erasures.

---

## 5. Approach 3 — Optimal CSES Solution (Sorted Two-Pointer Greedy Scan)

### Idea
Sort both `a` and `b` in non-decreasing order. Use two pointers `i = 0` and `j = 0` to match elements in a single pass.

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, m;
    long long k;
    if (!(cin >> n >> m >> k)) return 0;

    vector<long long> a(n);
    for (int i = 0; i < n; ++i) {
        cin >> a[i];
    }

    vector<long long> b(m);
    for (int i = 0; i < m; ++i) {
        cin >> b[i];
    }

    sort(a.begin(), a.end());
    sort(b.begin(), b.end());

    int i = 0; // applicant pointer
    int j = 0; // apartment pointer
    int matches = 0;

    while (i < n && j < m) {
        if (b[j] < a[i] - k) {
            // Apartment j is too small for applicant i (and all later applicants)
            j++;
        } else if (b[j] > a[i] + k) {
            // Apartment j is too large for applicant i (and all later apartments are larger)
            i++;
        } else {
            // Valid match found
            matches++;
            i++;
            j++;
        }
    }

    cout << matches << '\n';
    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n \log n + m \log m)$ for sorting both arrays. The two-pointer traversal visits each element at most once: $\mathcal{O}(n + m)$. Total runtime for $2 \cdot 10^5$ is $\approx 0.08$ seconds.
- **Space Complexity**: $\mathcal{O}(n + m)$ contiguous array storage. $\mathcal{O}(1)$ auxiliary space.

---

## 6. Correctness Proof

We prove optimality via a standard **greedy exchange argument**:
1. Let $G$ be the set of pairs matched by our greedy algorithm: $(a_{i_1}, b_{j_1}), (a_{i_2}, b_{j_2}), \dots$ ordered by increasing applicant index.
2. Let $O$ be an optimal matching that maximizes the number of pairs, sharing the longest common prefix of matches with $G$.
3. Consider the first discrepancy where $G$ pairs applicant $i$ with apartment $j$, but $O$ pairs applicant $i$ with apartment $j'$ (or leaves applicant $i$ unmatched).
   - Case 1 ($O$ pairs $i$ with $j'$ where $j' > j$):
     By our greedy choice, $j$ was the smallest available valid apartment. If $O$ used $j$ for some other applicant $i' > i$, then because $a_i \le a_{i'}$ and $b_j < b_{j'}$, swapping the assignments (giving $j$ to $i$ and $j'$ to $i'$) remains valid since:
     $$a_{i'} - k \le a_i - k \le b_j \le b_{j'} \le a_{i'} + k$$
     Thus, we obtain another optimal matching $O'$ that agrees with $G$ on one more element.
   - Case 2 ($O$ does not match $i$ at all):
     If $j$ is unused in $O$, we can add $(i, j)$ to $O$, increasing the size of $O$ (contradicting optimality of $O$). If $j$ was matched to $i'$ in $O$, assigning $j$ to $i$ and leaving $i'$ unmatched preserves the total number of matches while matching $i$.
4. By induction, the greedy matching achieves the maximal possible cardinality. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Input: $n = 4, m = 3, k = 5$.
$a = [60, 45, 80, 60]$, $b = [30, 60, 75]$.

After sorting:
- $a = [45, 60, 60, 80]$
- $b = [30, 60, 75]$

Tracing pointers:
- $i = 0 (a_0 = 45), j = 0 (b_0 = 30)$:
  $a_0 - k = 40$. $b_0 = 30 < 40$. Apartment 30 is too small. $j \to 1$.
- $i = 0 (a_0 = 45), j = 1 (b_0 = 60)$:
  $a_0 + k = 50$. $b_1 = 60 > 50$. Apartment 60 is too large for applicant 45. $i \to 1$.
- $i = 1 (a_1 = 60), j = 1 (b_1 = 60)$:
  $|60 - 60| = 0 \le 5$. **Match!** $matches \to 1$, $i \to 2, j \to 2$.
- $i = 2 (a_2 = 60), j = 2 (b_2 = 75)$:
  $a_2 + k = 65 < 75$. Too large for applicant 60. $i \to 3$.
- $i = 3 (a_3 = 80), j = 2 (b_2 = 75)$:
  $|80 - 75| = 5 \le 5$. **Match!** $matches \to 2$, $i \to 4, j \to 3$.
- Loop terminates ($i = 4$).

Final Output: `2`.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$k = 0$**: Requires exact match $a_i == b_j$. Handled cleanly by $|a_i - b_j| \le 0$.
- **Disjoint ranges**: If all apartments are strictly smaller than all applicants ($b_m < a_1 - k$), $j$ increments to $m$ and returns 0 matches.
- **64-bit bounds**: $a_i + k$ can equal $10^9 + 10^9 = 2 \cdot 10^9$. While fitting just inside 32-bit signed integer limits ($2.14 \times 10^9$), using `long long` for $k, a_i, b_j$ prevents any undefined signed overflow risks.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if each apartment can hold up to $C_j$ applicants?**
   - We would maintain the capacity of $b_j$, advancing $j$ only when apartment $j$'s remaining capacity reaches 0.
2. **What if each applicant had an individual tolerance $k_i$?**
   - The intervals $[a_i - k_i, a_i + k_i]$ no longer have a uniform radius. We would sort applicants by end-time/right bound $a_i + k_i$ and greedily assign the smallest valid apartment using a segment tree or `std::multiset`.
3. **Can this problem be solved with Max Flow / Bipartite Matching?**
   - Yes, standard maximum bipartite matching solves it, but Dinic's algorithm runs in $\mathcal{O}(E \sqrt{V}) \approx \mathcal{O}(N M \sqrt{N})$, which severely times out for $2 \cdot 10^5$. Two pointers exploits the 1D geometric ordering.
4. **How to return the actual matching pairs?**
   - Store pairs $(a_i, b_j)$ into a `vector<pair<int, int>>` whenever a match is made.
5. **What if we want to minimize the total sum of differences $\sum |a_i - b_j|$ among maximum matches?**
   - This requires min-cost maximum matching or dynamic programming on the sorted arrays.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Two Pointers, Greedy, Sorting, Bipartite Matching.
- **Time Complexity**: $\mathcal{O}(n \log n + m \log m)$ sorting time, $\mathcal{O}(n + m)$ linear scan.
- **Space Complexity**: $\mathcal{O}(n + m)$ memory.

### Related CSES Tasks
- [CSES 1090 - Ferris Wheel](https://cses.fi/problemset/task/1090): Two-pointer greedy pairing of weights.
- [CSES 1091 - Concert Tickets](https://cses.fi/problemset/task/1091): Dynamic greedy matching using balanced trees.
- [CSES 1629 - Movie Festival](https://cses.fi/problemset/task/1629): Classical interval scheduling greedy strategy.
