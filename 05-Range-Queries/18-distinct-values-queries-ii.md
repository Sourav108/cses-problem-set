# Distinct Values Queries II

- **Category**: Range Queries
- **CSES Task ID**: `3356`
- **CSES Problem Link**: [Distinct Values Queries II](https://cses.fi/problemset/task/3356)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array $x_1, x_2, \dots, x_n$ of $n$ integers, you must process $q$ queries of two types:
1. `1 k u`: Update the value at position $k$ to $u$ ($x_k \leftarrow u$).
2. `2 a b`: Check whether every value in the subarray range $[a, b]$ is distinct. Print `YES` if all values are pairwise distinct, and `NO` otherwise.

Array positions are 1-indexed.

### Input Format
- The first line contains two integers $n$ and $q$: the array size and the number of queries.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$: the initial array elements.
- The next $q$ lines each contain three integers:
  - `1 k u`
  - `2 a b`

### Output Format
- For each query of type 2, print `YES` or `NO` on a new line.

### Numerical Constraints
- $1 \le n, q \le 2 \cdot 10^5$
- $1 \le x_i, u \le 10^9$
- $1 \le k \le n$
- $1 \le a \le b \le n$

---

## 2. Intuition & Pattern Recognition

Rather than counting the exact number of distinct values in $[a, b]$ (which is notoriously heavy to maintain dynamically), the problem only asks a **decision question**: *are there any duplicate values in $[a, b]$?*

### Mathematical Reformulation via Predecessor Pointers
For each index $i \in [1, n]$, define:
$$\text{prev}[i] = \max(\{ j < i \mid x_j = x_i \} \cup \{0\})$$
That is, $\text{prev}[i]$ is the index of the most recent previous occurrence of value $x_i$ to the left of $i$ (or $0$ if $x_i$ appears for the first time).

### Fundamental Equivalence
> **Claim**: All values in $x_a, x_{a+1}, \dots, x_b$ are pairwise distinct if and only if:
> $$\max_{i \in [a, b]} \text{prev}[i] < a$$

- **If all values are distinct**: No two indices in $[a, b]$ share the same value. For any $i \in [a, b]$, any duplicate must occur strictly outside and before the interval, meaning $\text{prev}[i] < a$. Hence, the maximum over $i \in [a, b]$ is strictly less than $a$.
- **If there exists a duplicate**: Let $j < i$ both lie in $[a, b]$ with $x_j = x_i$. Then by definition, the most recent occurrence of $x_i$ before $i$ satisfies $\text{prev}[i] \ge j \ge a$. Consequently, $\max_{k \in [a, b]} \text{prev}[k] \ge a$.

Thus, query `2 a b` is reduced to:
$$\text{query\_max}(a, b) < a \implies \text{YES}, \quad \text{otherwise} \implies \text{NO}$$
This is a standard **Range Maximum Query (RMQ)** on the array $\text{prev}[1 \dots n]$!

### Handling Dynamic Updates
When $x_k$ changes from $old\_val$ to $new\_val$, only **three** elements in the $\text{prev}$ array can change:
1. In the set of occurrences of $old\_val$:
   - Let $p$ be the predecessor of $k$ and $s$ be the successor of $k$.
   - When $k$ is removed, the predecessor of $s$ shifts from $k$ to $p$. Thus $\text{prev}[s] \leftarrow p$.
2. In the set of occurrences of $new\_val$:
   - Insert $k$. Let $p'$ be the predecessor of $k$ and $s'$ be the successor of $k$.
   - The predecessor of $k$ becomes $p'$. Thus $\text{prev}[k] \leftarrow p'$.
   - The predecessor of $s'$ shifts from $p'$ to $k$. Thus $\text{prev}[s'] \leftarrow k$.

By storing for each distinct value an `std::set<int>` of its 1-based indices, finding predecessors and successors takes $\mathcal{O}(\log n)$ time, and updating the Segment Tree takes $\mathcal{O}(\log n)$ time.

---

## 3. Approach 1 — Naive Subarray Frequency Map per Query

For each type 2 query, traverse $x_a, \dots, x_b$ inserting into a hash set; return `NO` upon encountering any duplicate.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(1)$ per update, $\mathcal{O}(n)$ per query. Total time $\mathcal{O}(q \cdot n) \approx 4 \cdot 10^{10}$ operations.
- **Space Complexity**: $\mathcal{O}(n)$.
- **CSES Verdict**: TLE.

---

## 4. Approach 2 — Dynamic 2D Range Counting (Segment Tree of Treaps)

Count how many indices $i \in [a, b]$ satisfy $\text{prev}[i] \ge a$. If this count is 0, then all values are distinct.
- While correct, maintaining a 2D dynamic tree requires $\mathcal{O}(\log^2 n)$ per operation with heavy pointer manipulation.
- Approach 3 replaces 2D counting with 1D RMQ, taking only $\mathcal{O}(\log n)$ time and tiny constant factor.

---

## 5. Approach 3 — Optimal CSES Solution (Segment Tree RMQ + Occurrence Sets)

### C++ Source Code

```cpp
#include <iostream>
#include <vector>
#include <set>
#include <map>
#include <algorithm>

using namespace std;

static const int MAXN = 200005;
int tree[4 * MAXN];
int prev_arr[MAXN];

void update_tree(int node, int l, int r, int pos, int val) {
    if (l == r) {
        tree[node] = val;
        return;
    }
    int mid = l + (r - l) / 2;
    if (pos <= mid) {
        update_tree(2 * node, l, mid, pos, val);
    } else {
        update_tree(2 * node + 1, mid + 1, r, pos, val);
    }
    tree[node] = max(tree[2 * node], tree[2 * node + 1]);
}

int query_tree(int node, int l, int r, int ql, int qr) {
    if (ql <= l && r <= qr) {
        return tree[node];
    }
    int mid = l + (r - l) / 2;
    int res = 0;
    if (ql <= mid) {
        res = max(res, query_tree(2 * node, l, mid, ql, qr));
    }
    if (qr > mid) {
        res = max(res, query_tree(2 * node + 1, mid + 1, r, ql, qr));
    }
    return res;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n, q;
    if (!(cin >> n >> q)) return 0;

    vector<int> x(n + 1);
    map<int, set<int>> occ;

    for (int i = 1; i <= n; ++i) {
        cin >> x[i];
        occ[x[i]].insert(i);
    }

    for (int i = 1; i <= n; ++i) {
        auto& st = occ[x[i]];
        auto it = st.find(i);
        if (it != st.begin()) {
            prev_arr[i] = *prev(it);
        } else {
            prev_arr[i] = 0;
        }
    }

    // Build segment tree on prev_arr
    for (int i = 1; i <= n; ++i) {
        update_tree(1, 1, n, i, prev_arr[i]);
    }

    while (q--) {
        int type;
        cin >> type;
        if (type == 1) {
            int k, u;
            cin >> k >> u;
            if (x[k] == u) continue;

            int old_val = x[k];
            int new_val = u;

            // Remove k from old_val set
            {
                auto& st = occ[old_val];
                auto it = st.find(k);
                int p = (it != st.begin()) ? *prev(it) : 0;
                auto succ_it = next(it);
                if (succ_it != st.end()) {
                    int s = *succ_it;
                    prev_arr[s] = p;
                    update_tree(1, 1, n, s, p);
                }
                st.erase(it);
            }

            // Insert k into new_val set
            x[k] = new_val;
            {
                auto& st = occ[new_val];
                auto [it, _] = st.insert(k);
                int p = (it != st.begin()) ? *prev(it) : 0;
                prev_arr[k] = p;
                update_tree(1, 1, n, k, p);

                auto succ_it = next(it);
                if (succ_it != st.end()) {
                    int s = *succ_it;
                    prev_arr[s] = k;
                    update_tree(1, 1, n, s, k);
                }
            }
        } else {
            int a, b;
            cin >> a >> b;
            int max_prev = query_tree(1, 1, n, a, b);
            if (max_prev < a) {
                cout << "YES\n";
            } else {
                cout << "NO\n";
            }
        }
    }

    return 0;
}
```

---

## 6. Correctness Proof

### Theorem
For any query $[a, b]$, all elements $x_a, x_{a+1}, \dots, x_b$ are distinct if and only if $\max_{i \in [a, b]} \text{prev}[i] < a$.

*Proof*:
1. **Sufficiency ($\implies$)**:
   Suppose the elements in $[a, b]$ are pairwise distinct.
   Assume for contradiction that $\max_{i \in [a, b]} \text{prev}[i] \ge a$.
   Then there exists some index $i^* \in [a, b]$ such that $\text{prev}[i^*] = j \ge a$.
   Because $\text{prev}[i^*] < i^*$ by definition, we have $a \le j < i^* \le b$.
   By definition of $\text{prev}$, $x_j = x_{i^*}$.
   Both $j$ and $i^*$ belong to $[a, b]$, so the subarray contains a duplicate value, contradicting the assumption that all elements are pairwise distinct.
   Therefore, $\max_{i \in [a, b]} \text{prev}[i] < a$.

2. **Necessity ($\impliedby$)**:
   Suppose $\max_{i \in [a, b]} \text{prev}[i] < a$.
   Assume for contradiction that there exists a duplicate pair in $[a, b]$, say $x_j = x_i$ with $a \le j < i \le b$.
   Then the set $\{ k < i \mid x_k = x_i \}$ is non-empty and contains $j$.
   The maximal element of this set is $\text{prev}[i] \ge j \ge a$.
   Since $i \in [a, b]$, this implies $\max_{k \in [a, b]} \text{prev}[k] \ge \text{prev}[i] \ge a$, contradicting our hypothesis.
   Hence, no duplicate can exist. $\blacksquare$

### State Invariant Under Updates
An `std::set` ordered by index correctly maintains the sequence of occurrences of each value. Inserting or erasing an element in a doubly-linked structure modifies only the adjacent predecessor and successor pointers. Updating the segment tree at these positions preserves the definition of $\text{prev}$ across all $n$ positions.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
5 4
3 2 7 2 8
2 3 5
2 2 5
1 2 9
2 2 5
```

### Initial Setup ($x = [-, 3, 2, 7, 2, 8]$)
Occurrences:
- $3: \{1\} \implies \text{prev}[1] = 0$
- $2: \{2, 4\} \implies \text{prev}[2] = 0, \text{prev}[4] = 2$
- $7: \{3\} \implies \text{prev}[3] = 0$
- $8: \{5\} \implies \text{prev}[5] = 0$
Array $\text{prev} = [-, 0, 0, 0, 2, 0]$.

### Query 1: `2 3 5` ($a = 3, b = 5$)
- Range $[3, 5]$ in $\text{prev}$: $\max(0, 2, 0) = 2$.
- Condition: is $\max < a$?
  $2 < 3$ is **true**!
- Output: `YES` (values in range $[3, 5]$ are $[7, 2, 8]$, all distinct).

### Query 2: `2 2 5` ($a = 2, b = 5$)
- Range $[2, 5]$ in $\text{prev}$: $\max(0, 0, 2, 0) = 2$.
- Condition: is $\max < a$?
  $2 < 2$ is **false** ($2 \ge 2$).
- Output: `NO` (value 2 appears twice at positions 2 and 4).

### Query 3: `1 2 9` ($x_2 \leftarrow 9$)
- Old value at 2 was 2. Successor of 2 in set of 2 is 4.
  Predecessor of 4 becomes 0. $\text{prev}[4] \leftarrow 0$.
- New value at 2 is 9. No previous occurrence $\implies \text{prev}[2] = 0$.
- Array $\text{prev}$ becomes $[-, 0, 0, 0, 0, 0]$.

### Query 4: `2 2 5` ($a = 2, b = 5$)
- Range $[2, 5]$ in $\text{prev}$: $\max(0, 0, 0, 0) = 0$.
- Condition: $0 < 2$ is **true**!
- Output: `YES` (values are now $[9, 7, 2, 8]$, all distinct).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Repeated Update with Same Value ($x_k = u$)**:
   The check `if (x[k] == u) continue;` skips redundant set modifications, avoiding iterator invalidation.
2. **Single-Element Query ($a = b$)**:
   For any single element, $\text{prev}[a] < a$ is always true by definition of $\text{prev}$ (since $\text{prev}[i] \le i - 1 < i$). The query always outputs `YES`.
3. **Values up to $10^9$**:
   Since elements are up to $10^9$, we use `std::map<int, std::set<int>>` or hash map. Because each element is inserted and erased at most once per update, at most $n + q$ sets exist, easily fitting in 512 MB.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Why does this reduction to RMQ not work for counting distinct values?**
   Counting distinct values requires evaluating how many elements have $\text{prev}[i] < a$, which is a 2D range sum. Checking if *all* are distinct is an extreme-value condition ($\forall i, \text{prev}[i] < a \iff \max \text{prev}[i] < a$), which reduces directly to 1D RMQ.
2. **Can we replace `std::map` with coordinate compression?**
   If we collect all initial values and all update values offline, we can coordinate compress everything into $[0, n + q - 1]$ and replace `std::map` with a `vector<set<int>>`, reducing runtime by $\approx 2\times$.
3. **What if we want to find the first duplicate in $[a, b]$?**
   Binary search walk down the segment tree: find the first leaf in $[a, b]$ with $\text{prev}[i] \ge a$.
4. **How would you check if all elements in $[a, b]$ are distinct in an unweighted tree path?**
   Flatten the tree via Euler tour / heavy-light decomposition (HLD) and map the predecessor pointer logic onto tree paths using LCA.
5. **What is the worst-case depth of the Segment Tree?**
   For $n \le 2 \cdot 10^5$, $\lceil \log_2 n \rceil = 18$. Each point update visits at most 18 nodes.

---

## 10. Tags, Complexity Summary & Related CSES Problems

### Complexity Summary
- **Time Complexity**:
  - **Initialization**: $\mathcal{O}(n \log n)$
  - **Per Update**: $\mathcal{O}(\log n)$ (set operations + at most 3 segment tree point updates)
  - **Per Query**: $\mathcal{O}(\log n)$ (segment tree RMQ)
  - **Overall Run Time**: $\mathcal{O}((n + q) \log n) \approx 0.16\text{s}$ (Limit: 1.00s)
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space for Segment Tree and balanced sets.

### Related CSES Problems
- [Distinct Values Queries](https://cses.fi/problemset/task/1734) — Offline distinct counting
- [Dynamic Range Minimum Queries](https://cses.fi/problemset/task/1649) — Dynamic RMQ
- [Range Interval Queries](https://cses.fi/problemset/task/3163) — 2D Range Counting
