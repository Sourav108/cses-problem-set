# Range Xor Queries

- **Category**: Range Queries
- **CSES Task ID**: `1650`
- **CSES Problem Link**: [Range Xor Queries](https://cses.fi/problemset/task/1650)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers and $q$ queries, your task is to process each query efficiently. Each query is defined by a 1-indexed range $[a, b]$, and asks for the **bitwise XOR sum** of values in the subarray from position $a$ to position $b$ inclusive:
$$x_a \oplus x_{a+1} \oplus \dots \oplus x_b$$
The array is static (no updates occur).

### Input Format
- The first line contains two integers $n$ and $q$: the array size and number of queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the array values.
- The next $q$ lines each contain two integers $a$ and $b$: the range bounds.

### Output Format
- For each query, print the XOR sum on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$
- $1 \le a \le b \le n$

With $n, q \le 2 \cdot 10^5$, a prefix XOR array evaluates each query in strictly $\mathcal{O}(1)$ time, taking $\approx 0.05\text{s}$ total.

---

## 2. Intuition & Pattern Recognition

Bitwise XOR ($\oplus$) forms an abelian group where every element is its **own inverse**:
$$x \oplus x = 0, \quad x \oplus 0 = x$$
- **Self-Inverse Property**:
  In standard range sums, we compute the range sum as $\text{pref}[b] - \text{pref}[a-1]$ because subtraction is the inverse of addition.
  In XOR, because $x$ is its own inverse, the inverse of XOR is simply XOR itself!
- **Prefix XOR Array**:
  Define a 1-indexed prefix XOR array $\text{pref}$ of size $n + 1$:
  $$\text{pref}[0] = 0$$
  $$\text{pref}[i] = \text{pref}[i - 1] \oplus x_i \quad (1 \le i \le n)$$
- Then for any query range $[a, b]$:
  $$\text{pref}[b] \oplus \text{pref}[a - 1] = \left(\bigoplus_{i=1}^b x_i\right) \oplus \left(\bigoplus_{i=1}^{a-1} x_i\right)$$
  The terms from $1$ to $a - 1$ appear twice and cancel out to $0$ ($x_i \oplus x_i = 0$), leaving precisely:
  $$\bigoplus_{i=a}^b x_i$$
- Thus, every range XOR query is computed in strictly $\mathcal{O}(1)$ time with a single XOR operation.

---

## 3. Approach 1 — Naive Linear XOR Scan per Query

Iterate from $a$ to $b$ and compute the XOR sum.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE immediately.

---

## 4. Approach 2 — Segment Tree / Fenwick Tree

Build a Segment Tree or Fenwick Tree over the array.
- **Time Complexity**: $\mathcal{O}(n + q \log n)$.
- **Verdict**: Correct, but $\mathcal{O}(\log n)$ query time is slower and unnecessary since the array is static. Prefix XOR achieves $\mathcal{O}(1)$ query time with virtually zero memory overhead.

---

## 5. Approach 3 — Optimal CSES Solution (Prefix XOR Array)

1. Allocate array `pref[n + 1]` initialized with `pref[0] = 0`.
2. For $i = 1 \dots n$:
   $$\text{pref}[i] = \text{pref}[i - 1] \oplus x_i$$
3. For each query $(a, b)$:
   $$\text{cout} \ll (\text{pref}[b] \oplus \text{pref}[a - 1]) \ll '\backslash n'$$

```cpp
#include <iostream>
#include <vector>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    vector<int> pref(n + 1, 0);
    for (int i = 1; i <= n; ++i) {
        int val;
        cin >> val;
        pref[i] = pref[i - 1] ^ val;
    }

    while (q--) {
        int a, b;
        cin >> a >> b;
        cout << (pref[b] ^ pref[a - 1]) << '\n';
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**:
  - Precomputation: $\mathcal{O}(n)$ linear scan.
  - Query: $\mathcal{O}(1)$ per query $\implies \mathcal{O}(q)$.
  - Total Time: $\mathcal{O}(n + q) \approx 0.05\text{s}$.
- **Space Complexity**: $\mathcal{O}(n)$ for the `pref` array ($\approx 800\text{ KB}$).

---

## 6. Correctness Proof

### Group Invertibility of Bitwise XOR
- **Lemma**: $(\mathbb{Z}, \oplus)$ forms an abelian group where the identity element is $0$, and every element satisfies $y^{-1} = y$.
- **Proof**:
  1. *Associativity and Commutativity*: XOR acts independently on each bit position as addition modulo 2 ($b_1 \oplus b_2 = (b_1 + b_2) \bmod 2$).
  2. *Identity*: $y \oplus 0 = y$ for all $y$.
  3. *Inverse*: $y \oplus y = 0$ for all $y$.
- **Prefix Decomposition**:
  Let $P_k = \bigoplus_{i=1}^k x_i$. Then:
  $$P_b \oplus P_{a-1} = \left(\left(\bigoplus_{i=1}^{a-1} x_i\right) \oplus \left(\bigoplus_{i=a}^b x_i\right)\right) \oplus \left(\bigoplus_{i=1}^{a-1} x_i\right)$$
  By commutativity and associativity, we can rearrange:
  $$P_b \oplus P_{a-1} = \left(\bigoplus_{i=a}^b x_i\right) \oplus \left(\bigoplus_{i=1}^{a-1} (x_i \oplus x_i)\right) = \left(\bigoplus_{i=a}^b x_i\right) \oplus 0 = \bigoplus_{i=a}^b x_i$$
  The cancellation is exact for all $1 \le a \le b \le n$. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider array $x = [3, 2, 4, 5, 1, 1, 5, 3]$ ($n = 8$):
- In binary:
  - $x_1 = 3 = \text{0b011}$
  - $x_2 = 2 = \text{0b010}$
  - $x_3 = 4 = \text{0b100}$
  - $x_4 = 5 = \text{0b101}$
- Prefix XOR array:
  - $\text{pref}[0] = 0$
  - $\text{pref}[1] = 3$
  - $\text{pref}[2] = 3 \oplus 2 = 1$
  - $\text{pref}[3] = 1 \oplus 4 = 5$
  - $\text{pref}[4] = 5 \oplus 5 = 0$
  - $\text{pref}[5] = 0 \oplus 1 = 1$
  - $\text{pref}[6] = 1 \oplus 1 = 0$
  - $\text{pref}[7] = 0 \oplus 5 = 5$
  - $\text{pref}[8] = 5 \oplus 3 = 6$
- Query $1$: $[a = 2, b = 4]$:
  $$\text{pref}[4] \oplus \text{pref}[1] = 0 \oplus 3 = 3$$
  Elements: $x_2 \oplus x_3 \oplus x_4 = 2 \oplus 4 \oplus 5 = 3$. Correct!
- Query $2$: $[a = 5, b = 6]$:
  $$\text{pref}[6] \oplus \text{pref}[4] = 0 \oplus 0 = 0$$
  Elements: $1 \oplus 1 = 0$. Correct!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **No Integer Overflow**:
   XORing numbers $\le 10^9$ never increases the number of bits ($10^9 < 2^{30}$). Result always fits in a standard 32-bit signed `int`.
2. **Single Element Query ($a == b$)**:
   $\text{pref}[a] \oplus \text{pref}[a-1] = x_a$, correctly returning the element itself.
3. **1-Based Indexing**:
   Allocating `pref` with size $n + 1$ and `pref[0] = 0` handles queries starting at $a = 1$ without special branching.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **What if the array supports point updates?**
   Use a Fenwick tree or Segment tree with XOR operation: Fenwick tree replaces `+` with `^` directly in $\mathcal{O}(\log n)$.
2. **How do you find the maximum XOR subarray in an array?**
   Insert all prefix XORs into a **Binary Trie (0-1 Trie)**. For each prefix $P_i$, query the Trie for the path that diverges most from $P_i$ in $\mathcal{O}(30)$ time, solving the maximum XOR subarray in $\mathcal{O}(n \log (\max x))$.
3. **How do you count subarrays with XOR sum equal to $K$?**
   Maintain a hash map or frequency array of prefix XORs: if current prefix is $P_i$, add $\text{count}[P_i \oplus K]$ to total.
4. **Why does prefix array work for XOR, but not for Bitwise AND or OR?**
   Bitwise AND and OR do not form a group because they are not invertible (once a bit becomes 0 in AND or 1 in OR, the previous state cannot be recovered). Range AND/OR requires Sparse Table or Segment Tree.
5. **How does Range XOR connect to Nim games?**
   In Nim, the state is winning if and only if the XOR sum of pile sizes is non-zero (the Bouton theorem). Range XOR queries evaluate subgames of Nim in $\mathcal{O}(1)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Range Queries, Bitwise XOR, Prefix XOR, Self-Inverse, $\mathcal{O}(1)$ Query
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + q)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - [Static Range Sum Queries](https://cses.fi/problemset/task/1646) — Range sum via prefix sums
  - [Static Range Minimum Queries](https://cses.fi/problemset/task/1647) — Range minimum via Sparse Table
  - [Dynamic Range Sum Queries](https://cses.fi/problemset/task/1648) — Dynamic range updates with Fenwick Tree
