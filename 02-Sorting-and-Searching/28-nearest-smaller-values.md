# Nearest Smaller Values

- **Category**: Sorting and Searching
- **CSES Task ID**: `1645`
- **CSES Problem Link**: [Nearest Smaller Values](https://cses.fi/problemset/task/1645)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Given an array of $n$ integers $x_1, x_2, \dots, x_n$, find for each position $i$ ($1 \le i \le n$) the nearest position $j < i$ such that $x_j < x_i$. If no such position exists, report $0$.

### Input Format
- The first line contains an integer $n$.
- The second line contains $n$ integers $x_1, x_2, \dots, x_n$.

### Output Format
- Print $n$ integers: for each element, the 1-based index of the nearest smaller value to its left, separated by spaces.

### Numerical Constraints
- $1 \le n \le 2 \cdot 10^5$
- $1 \le x_i \le 10^9$

With $n = 2 \cdot 10^5$, an $\mathcal{O}(n^2)$ pairwise scan performs up to $\approx 2 \cdot 10^{10}$ operations and will fail with Time Limit Exceeded (TLE). A linear $\mathcal{O}(n)$ or $\mathcal{O}(n \log n)$ approach is mandatory.

---

## 2. Intuition & Pattern Recognition

This is the quintessential **Monotonic Stack** pattern (specifically, a strictly increasing stack).

For a given index $i$ and value $x_i$:
- Any earlier element $j < i$ that satisfies $x_j \ge x_i$ can **never** serve as the nearest smaller value for any future element $k > i$. Why? Because $x_i$ is strictly smaller than $x_j$ and lies closer to $k$ ($j < i < k$). Hence, $x_i$ dominates $x_j$ in all future comparisons.
- Therefore, we can permanently discard elements $\ge x_i$ from our candidate pool.
- Maintaining candidates in strictly increasing order of values on a stack allows us to peek at the top to find the nearest smaller value, pop all dominated candidates in amortized $\mathcal{O}(1)$ time, and push the current element.

---

## 3. Approach 1 — Naive / Baseline

For each element at index $i$, iterate backwards from $i - 1$ down to $1$ until finding the first element strictly smaller than $x_i$.

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

    vector<int> a(n + 1);
    for (int i = 1; i <= n; ++i) {
        cin >> a[i];
    }

    for (int i = 1; i <= n; ++i) {
        int ans = 0;
        for (int j = i - 1; j >= 1; --j) {
            if (a[j] < a[i]) {
                ans = j;
                break;
            }
        }
        cout << ans << (i == n ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n^2)$. On a strictly decreasing array like $[n, n-1, \dots, 2, 1]$, each index $i$ scans all $i-1$ preceding elements, yielding $\frac{n(n-1)}{2} \approx 2 \cdot 10^{10}$ iterations.
- **Space Complexity**: $\mathcal{O}(n)$ to store the array.
- **CSES Verdict**: Fails with TLE on test cases where $n > 5000$.

---

## 4. Approach 2 — Intermediate / Segment Tree with Binary Search

We can maintain a point-update range-minimum segment tree over coordinate values, or compress values and query the maximum index among all values $< x_i$. Alternatively, binary search on a Fenwick tree over coordinate-compressed values takes $\mathcal{O}(n \log n)$ time.

However, building a tree structure incurs unnecessary logarithmic factors and dynamic memory overhead when a simple stack solves the problem in pure linear time. Hence, we proceed directly to the optimal monotonic stack.

---

## 5. Approach 3 — Optimal CSES Solution (Monotonic Stack)

We maintain a stack of pairs `(value, 1-based index)`. As we process each $x_i$:
1. While the stack is non-empty and `stack.top().value >= x_i`, pop the top element.
2. If the stack is empty, no smaller element exists to the left $\implies$ output `0`.
3. If the stack is non-empty, the top element is the nearest strictly smaller element $\implies$ output `stack.top().index`.
4. Push `(x_i, i)` onto the stack.

### C++17 Contest-Ready Implementation

```cpp
#include <iostream>
#include <vector>
#include <stack>

using namespace std;

struct Element {
    int val;
    int idx;
};

int main() {
    // Fast I/O
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    // Monotonic stack maintaining strictly increasing values
    stack<Element> st;

    for (int i = 1; i <= n; ++i) {
        int x;
        cin >> x;

        // Discard all candidates that are >= x (they can never be the nearest smaller)
        while (!st.empty() && st.top().val >= x) {
            st.pop();
        }

        // If stack is empty, no smaller element to the left
        if (st.empty()) {
            cout << 0 << (i == n ? '\n' : ' ');
        } else {
            cout << st.top().idx << (i == n ? '\n' : ' ');
        }

        // Push current element as a candidate for future elements
        st.push({x, i});
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n)$. Each index from $1$ to $n$ is pushed onto the stack exactly once and popped at most once across the entire execution. Thus, the inner `while` loop executes at most $n$ times total across all iterations (amortized $\mathcal{O}(1)$ per element).
- **Space Complexity**: $\mathcal{O}(n)$ auxiliary space to store up to $n$ elements in the stack.
- **Optimality Guarantee**: Every element must be inspected at least once ($\Omega(n)$ input size), so $\mathcal{O}(n)$ is optimal.

---

## 6. Correctness Proof

### Invariant
At the start of processing index $i$, the stack contains a subset of indices $j < i$ sorted strictly in increasing order of both their indices and their values:
$$j_1 < j_2 < \dots < j_k \quad \text{and} \quad x_{j_1} < x_{j_2} < \dots < x_{j_k}$$
Moreover, for any index $p < i$ not in the stack, there exists some $j \in \text{stack}$ such that $p < j < i$ and $x_j \le x_p$ (i.e. $p$ is dominated by $j$).

### Maintenance
1. When considering $x_i$, any element $j$ currently on top with $x_j \ge x_i$ cannot be the answer for $i$ (since $x_j \not< x_i$).
2. Furthermore, $j$ cannot be the nearest smaller value for any future element $k > i$: if $x_j < x_k$, then since $x_i \le x_j$, we also have $x_i < x_k$. Because $j < i < k$, $i$ is strictly closer to $k$ than $j$ is, so $j$ will never be the *nearest* smaller element.
3. Therefore, safely popping all $j$ with $x_j \ge x_i$ preserves the guarantee that no valid candidate is prematurely eliminated.
4. After popping, if the stack is non-empty, the top element $j_{top}$ has $x_{j_{top}} < x_i$. Because all elements between $j_{top}$ and $i$ were either already popped or popped now (meaning they were $\ge x_i > x_{j_{top}}$), $j_{top}$ is indeed the *closest* position with a value $< x_i$.
5. Pushing $(x_i, i)$ maintains the strictly increasing invariant because $x_i > x_{j_{top}}$.

---

## 7. Dry Run & Visual State Trace

### Sample Input
```text
8
2 5 1 4 8 3 2 5
```

| Step $i$ | Value $x_i$ | Stack Before Popping | Elements Popped | Stack Top (Answer) | Stack After Push |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | 2 | `[]` | None | None $\implies$ **0** | `[(2, 1)]` |
| **2** | 5 | `[(2, 1)]` | None | `(2, 1)` $\implies$ **1** | `[(2, 1), (5, 2)]` |
| **3** | 1 | `[(2, 1), (5, 2)]` | `(5, 2)`, `(2, 1)` | None $\implies$ **0** | `[(1, 3)]` |
| **4** | 4 | `[(1, 3)]` | None | `(1, 3)` $\implies$ **3** | `[(1, 3), (4, 4)]` |
| **5** | 8 | `[(1, 3), (4, 4)]` | None | `(4, 4)` $\implies$ **4** | `[(1, 3), (4, 4), (8, 5)]` |
| **6** | 3 | `[(1, 3), (4, 4), (8, 5)]` | `(8, 5)`, `(4, 4)` | `(1, 3)` $\implies$ **3** | `[(1, 3), (3, 6)]` |
| **7** | 2 | `[(1, 3), (3, 6)]` | `(3, 6)` | `(1, 3)` $\implies$ **3** | `[(1, 3), (2, 7)]` |
| **8** | 5 | `[(1, 3), (2, 7)]` | None | `(2, 7)` $\implies$ **7** | `[(1, 3), (2, 7), (5, 8)]` |

**Output**: `0 1 0 3 4 3 3 7` (Matches CSES example).

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

- **$n = 1$**: Single element immediately prints `0` and exits without issue.
- **Strictly Increasing Array** ($[1, 2, 3, 4]$): Stack grows to size $n$, outputs `0 1 2 3`.
- **Strictly Decreasing Array** ($[4, 3, 2, 1]$): Every element pops the entire stack, outputs `0 0 0 0`. Stack size remains $\le 1$.
- **Duplicates** ($[2, 2, 2, 2]$): The condition `st.top().val >= x` correctly pops equal elements because the problem requires strictly smaller ($x_j < x_i$). Outputs `0 0 0 0`.
- **Value Magnitude**: $x_i \le 10^9$ fits comfortably inside signed 32-bit `int`.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Nearest Smaller to the Right?**
   - Traverse from $n$ down to $1$ maintaining the same monotonic stack logic.
2. **Nearest Smaller or Equal?**
   - Change the pop condition from `st.top().val >= x` to `st.top().val > x`.
3. **Largest Rectangle in Histogram?**
   - Combine Nearest Smaller to the Left and Nearest Smaller to the Right for every bar to determine its maximal width $[L_i + 1, R_i - 1]$ in linear time.
4. **Dynamic Online Updates (Point Updates + Queries)?**
   - If array values can change dynamically, a monotonic stack cannot support fast updates. A Segment Tree with binary lifting/range minimum queries or a Treap is required, increasing complexity to $\mathcal{O}(\log n)$ per operation.
5. **Memory Optimization ($\mathcal{O}(1)$ Extra Space)?**
   - We can repurpose an existing array of size $n$ as a jump table: `prev_smaller[i]` stores the answer. If $a[i-1] < a[i]$, then answer is $i-1$; otherwise jump via `k = prev_smaller[i-1]` until $a[k] < a[i]$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: `[monotonic-stack, sorting-and-searching, data-structures, amortized-analysis]`
- **Complexity Summary**:
  - Time: $\mathcal{O}(n)$
  - Space: $\mathcal{O}(n)$
- **Related CSES Problems**:
  - `CSES 1644` — [Maximum Subarray Sum II](https://cses.fi/problemset/task/1644) (Monotonic deque for sliding window min/max).
  - `CSES 1643` — [Maximum Subarray Sum](https://cses.fi/problemset/task/1643) (Kadane's algorithm on linear arrays).
  - `CSES 1141` — [Playlist](https://cses.fi/problemset/task/1141) (Two-pointer sliding window with index tracking).
