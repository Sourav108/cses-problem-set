# Raab Game I (CSES Task 3399 — Introductory Problems)

This is a complete, gold-standard competitive programming note in C++ following the standardized 10-section format.

- **Source**: [CSES Task 3399 - Raab Game I](https://cses.fi/problemset/task/3399)
- **Category**: `01-Introductory-Problems`
- **Limits**: Time: 1.00s | Memory: 512 MB
- **Statement**: Consider a two-player game where each player has $n$ cards numbered $1, 2, \dots, n$. In each turn, both players reveal one card. The higher card earns 1 point; if equal, neither scores. The game continues until all cards are played. Given $n, a, b$, determine if scores $a$ (Player 1) and $b$ (Player 2) can occur, and if so, construct an example game.
- **Constraints**: $1 \le t \le 1000$, $1 \le n \le 100$, $0 \le a, b \le n$.

---

## 1. Problem, Restated

Given the number of cards $n$ and desired final scores $a$ (Player 1) and $b$ (Player 2), determine whether there exist permutations $P_1 = (x_1, \dots, x_n)$ and $P_2 = (y_1, \dots, y_n)$ of $\{1, 2, \dots, n\}$ such that:
1. $|\{i : x_i > y_i\}| = a$
2. $|\{i : y_i > x_i\}| = b$
3. $|\{i : x_i = y_i\}| = n - a - b \ge 0$

If possible, output `YES` followed by $P_1$ on one line and $P_2$ on the next. Otherwise, output `NO`.

**Input**:
- First line: integer $t$ ($1 \le t \le 1000$).
- Next $t$ lines: three space-separated integers $n, a, b$.

**Output**:
- For each test case, print `YES` and two permutations if achievable, else `NO`.

---

## 2. Intuition & Pattern Recognition

- **Pattern**: Constructive Permutations / Invariant Analysis / Cyclic Shift / Game Theory.
- **Aha! Insight**:
  - Let $c = n - (a + b)$ be the number of ties ($x_i = y_i$). Obviously, $a + b \le n$, so $c \ge 0$ is a necessary condition.
  - Consider the sum invariant:
    $$\sum_{i=1}^n (x_i - y_i) = \sum_{i=1}^n x_i - \sum_{i=1}^n y_i = \frac{n(n+1)}{2} - \frac{n(n+1)}{2} = 0$$
  - Every round with $x_i > y_i$ contributes a strictly positive difference $(x_i - y_i) > 0$.
  - Every round with $y_i > x_i$ contributes a strictly negative difference $(x_i - y_i) < 0$.
  - Rounds with ties contribute $0$.
  - Therefore, it is **impossible** for all non-zero terms to have the same sign!
    - If $a = 0$ and $b > 0$, then $(x_i - y_i) \le 0$ for all $i$, with at least one strictly negative term. The sum cannot equal 0. Contradiction!
    - Similarly, if $b = 0$ and $a > 0$, the sum cannot equal 0.
  - Thus, a valid outcome requires either:
    1. $a = 0$ and $b = 0$ (all rounds are ties), OR
    2. $a > 0$ and $b > 0$ (both players win at least one round).
  - **Constructive Strategy**:
    - Assign the first $c = n - (a + b)$ cards to be identical: $x_i = y_i = i$ for $i \in [1, c]$.
    - For the remaining $m = a + b$ cards (values $c + 1, \dots, n$):
      - Let Player 1 play them in increasing order: $c + 1, c + 2, \dots, n$.
      - Let Player 2 play a **cyclic shift** of these $m$ cards by $a$ positions to the left:
        $$(c + 1 + a, \dots, n, c + 1, \dots, c + a)$$
      - In this cyclic shift, exactly $a$ elements wrap around to the end, giving Player 1 $a$ wins, while the other $m - a = b$ elements are larger than Player 1's cards, giving Player 2 $b$ wins!

---

## 3. Approach 1 — Naive / Baseline (Permutation Backtracking)

Search all $n!$ permutations of $P_2$ with $P_1 = (1, 2, \dots, n)$ until a matching score $(a, b)$ is found.
For $n = 100$, $100! \approx 9.3 \times 10^{157}$, which results in TLE. It only works for $n \le 8$.

---

## 4. Approach 2 — Intermediate (Random Shuffling / Heuristic Swap)

Repeatedly generate permutations or use hill-climbing swaps to adjust points. While acceptable for a single test case, with $t = 1000$ it risks timeouts or failing rare corner cases.

---

## 5. Approach 3 — Optimal CSES Solution (Closed-Form Cyclic Shift Construction)

### Idea
1. Check feasibility:
   - If $a + b > n \implies$ `NO`.
   - If $(a == 0 \text{ and } b > 0) \lor (b == 0 \text{ and } a > 0) \implies$ `NO`.
2. Otherwise, print `YES`.
3. Construct the two lines:
   - The first $c = n - (a + b)$ numbers are identical for both players ($1, 2, \dots, c$).
   - For the remaining $m = a + b$ cards ($c + 1, \dots, n$):
     - $P_1$ appends $c + 1, \dots, n$.
     - $P_2$ appends the suffix of size $b$ followed by the prefix of size $a$:
       $$(c + 1 + a, c + 2 + a, \dots, n, c + 1, c + 2, \dots, c + a)$$

### C++17 Contest-Ready Code
```cpp
#include <iostream>
#include <vector>

using namespace std;

void solve() {
    int n, a, b;
    cin >> n >> a >> b;

    if (a + b > n) {
        cout << "NO\n";
        return;
    }
    if ((a == 0 && b > 0) || (b == 0 && a > 0)) {
        cout << "NO\n";
        return;
    }

    cout << "YES\n";

    int c = n - (a + b);
    vector<int> p1, p2;
    p1.reserve(n);
    p2.reserve(n);

    // Step 1: Assign c tied rounds
    for (int i = 1; i <= c; ++i) {
        p1.push_back(i);
        p2.push_back(i);
    }

    // Step 2: Assign remaining m = a + b rounds
    int m = a + b;
    if (m > 0) {
        vector<int> rem(m);
        for (int i = 0; i < m; ++i) {
            rem[i] = c + 1 + i;
        }

        // P1 plays in ascending order
        for (int i = 0; i < m; ++i) {
            p1.push_back(rem[i]);
        }

        // P2 plays cyclic shift by a
        for (int i = a; i < m; ++i) {
            p2.push_back(rem[i]);
        }
        for (int i = 0; i < a; ++i) {
            p2.push_back(rem[i]);
        }
    }

    // Output Player 1
    for (int i = 0; i < n; ++i) {
        cout << p1[i] << (i + 1 == n ? '\n' : ' ');
    }
    // Output Player 2
    for (int i = 0; i < n; ++i) {
        cout << p2[i] << (i + 1 == n ? '\n' : ' ');
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int t;
    if (!(cin >> t)) return 0;
    while (t--) {
        solve();
    }

    return 0;
}
```

### Complexity Derivation
- **Time Complexity**: $\mathcal{O}(n)$ per test case. Across $t$ test cases, $\mathcal{O}(t \cdot n)$. For $t = 1000, n = 100$, total operations $\le 10^5$, taking $< 0.01$ seconds.
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary vectors per query.

---

## 6. Correctness Proof

1. **Validity of Permutations**:
   - The values used are $\{1, \dots, c\} \cup \{c+1, \dots, n\} = \{1, \dots, n\}$.
   - $P_1$ consists of $1, \dots, c$ and then $c+1, \dots, n$, so every number appears once.
   - $P_2$ consists of $1, \dots, c$ and a cyclic permutation of $\{c+1, \dots, n\}$, so every number appears once.
2. **Score Verification**:
   - For indices $i \in [0, c-1]$: $p_1[i] = p_2[i]$, generating $c$ ties (0 points each).
   - For indices $j \in [0, b-1]$ of the remaining block:
     $$p_1[c + j] = c + 1 + j$$
     $$p_2[c + j] = c + 1 + j + a$$
     Since $a \ge 1$, $p_2[c+j] > p_1[c+j]$, so Player 2 wins exactly $b$ rounds.
   - For indices $j \in [b, m-1]$ (there are $m - b = a$ such indices):
     $$p_1[c + j] = c + 1 + j \ge c + 1 + b$$
     $$p_2[c + j] = c + 1 + (j - b) \le c + 1 + (m - 1 - b) = c + a$$
     Since $c + 1 + b > c + a$ is equivalent to $b + 1 > a$ (if $b \ge a$) or unconditionally by noting $p_1[c + j] \in [c+1+b, n]$ while $p_2[c + j] \in [c+1, c+a]$:
     The minimum element in $p_1$ for this block is $c + b + 1$, which strictly exceeds the maximum element in $p_2$ for this block ($c + a$).
     Hence $p_1[c + j] > p_2[c + j]$ always holds! Player 1 wins exactly $a$ rounds.
3. **Necessity Proof**:
   As established in Section 2, the total zero-sum invariant $\sum (p_1[i] - p_2[i]) = 0$ requires that if any round is won by Player 1, at least one round must be won by Player 2. Hence $a=0 \iff b=0$.

---

## 7. Dry Run & Visual State Trace

Input: $n = 4, a = 1, b = 2$.
- $c = 4 - (1 + 2) = 1$ tie.
- $m = 1 + 2 = 3$ active cards: $\{2, 3, 4\}$.
- $P_1$: $[1] + [2, 3, 4] = [1, 2, 3, 4]$.
- $P_2$: cyclic shift of $[2, 3, 4]$ by $a = 1$: $[3, 4, 2]$.
  $P_2 = [1] + [3, 4, 2] = [1, 3, 4, 2]$.

Comparison:
- Round 1: 1 vs 1 $\implies$ Tie (0, 0)
- Round 2: 2 vs 3 $\implies$ $y_2 > x_2 \implies$ Player 2 scores (0, 1)
- Round 3: 3 vs 4 $\implies$ $y_3 > x_3 \implies$ Player 2 scores (0, 2)
- Round 4: 4 vs 2 $\implies$ $x_4 > y_4 \implies$ Player 1 scores (1, 2)

Final Scores: $a = 1, b = 2$. Exactly matches input.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$a = 0, b = 0$**: Handled properly; $c = n$, all rounds are identical $1, \dots, n$, result is `YES`.
- **$a = 0, b > 0$ or $a > 0, b = 0$**: Correctly outputs `NO`.
- **$a + b > n$**: Correctly outputs `NO`.
- **$a + b = n$**: $c = 0$, entire array undergoes the cyclic shift with 0 ties.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if cards were not distinct (multisets of card values)?**
   - If both players have identical multisets, the same zero-sum invariant $\sum (x_i - y_i) = 0$ holds. However, duplicate values create additional tie opportunities.
2. **Can we maximize or minimize the sum of margins $\sum |x_i - y_i|$?**
   - Yes, using the Hungarian algorithm or sorting-based matching (Rearrangement Inequality).
3. **What if Player 1 must play their cards in standard order $1, 2, \dots, n$?**
   - Our construction already enforces Player 1 playing strictly in ascending order $1, 2, \dots, n$, satisfying this additional constraint for free!
4. **How would you count the number of distinct valid games?**
   - This relates to derangements and Eulerian numbers, which requires inclusion-exclusion and polynomial generating functions.
5. **What if ties were awarded 0.5 points to each player?**
   - The total score would be $a + b + 0.5 c = n \implies 2a + 2b + c = 2n$. The parity and sum conditions adjust accordingly.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Constructive Algorithms, Permutations, Game Theory, Invariants.
- **Time Complexity**: $\mathcal{O}(n)$ per test case, $\mathcal{O}(t \cdot n)$ total.
- **Space Complexity**: $\mathcal{O}(n)$ per test case.

### Related CSES Tasks
- [CSES 1070 - Permutations](https://cses.fi/problemset/task/1070): Parity-based constructive array arrangement.
- [CSES 1092 - Two Sets](https://cses.fi/problemset/task/1092): Invariant-driven sum partitioning.
- [CSES 1754 - Coin Piles](https://cses.fi/problemset/task/1754): Linear Diophantine and modular invariants.
