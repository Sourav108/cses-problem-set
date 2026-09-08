# De Bruijn Sequence

- **Category**: Graph Algorithms
- **CSES Task ID**: `1692`
- **CSES Problem Link**: [De Bruijn Sequence](https://cses.fi/problemset/task/1692)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Your task is to construct a **minimum-length bit string** that contains every possible binary string of length $n$ as a contiguous substring.

Since there are $2^n$ distinct binary strings of length $n$, any string containing all of them must have length at least $2^n + n - 1$. A **De Bruijn sequence** $B(2, n)$ achieves this exact theoretical minimum.

If there are multiple valid sequences, you may print any of them.

### Input Format
- The only input line contains an integer $n$.

### Output Format
- Print a minimum-length bit string containing all $2^n$ binary strings of length $n$ as substrings.

### Numerical Constraints
- $1 \le n \le 15$

For $n = 15$, the sequence length is $2^{15} + 15 - 1 = 32782$. An $\mathcal{O}(2^n)$ Eulerian circuit traversal executes in $< 0.01\text{s}$.

---

## 2. Intuition & Pattern Recognition

This problem is the canonical application of **Eulerian Circuits in a De Bruijn Graph**:
- **Special Case ($n = 1$)**:
  For $n = 1$, the substrings of length 1 are `'0'` and `'1'`. The string `"01"` has length 2 and contains both.
- **De Bruijn Graph Construction ($n \ge 2$)**:
  - **Vertices**: All $2^{n-1}$ binary strings of length $n - 1$ (integers $0, 1, \dots, 2^{n-1} - 1$).
  - **Edges**: Each vertex $u$ has exactly two outgoing directed edges corresponding to appending a bit $b \in \{0, 1\}$:
    $$v = \big( (u \ll 1) \mid b \big) \;\&\; \big( (1 \ll (n - 1)) - 1 \big)$$
  - Each directed edge corresponds to an $n$-bit string: $(u \ll 1) \mid b$.
- **Eulerian Circuit Existence**:
  - For every vertex $u$, its out-degree is exactly 2 (choices $b \in \{0, 1\}$).
  - Its in-degree is also exactly 2 (coming from $(0 \mid (u \gg 1))$ and $(2^{n-2} \mid (u \gg 1))$).
  - Because $\text{in\_degree}[u] == \text{out\_degree}[u] = 2$ for all vertices and the graph is strongly connected, an **Eulerian Circuit** traversing all $2^n$ edges exists!
- **String Assembly**:
  - Start with the $(n - 1)$-bit string representing vertex $0$ (i.e. $n - 1$ zeros: `"00...0"`).
  - Follow the Eulerian circuit: each directed edge appends its single transition bit $b$.
  - Traversing all $2^n$ edges produces a string of length $(n - 1) + 2^n = 2^n + n - 1$ containing all $2^n$ binary strings of length $n$.

---

## 3. Approach 1 — Naive Greedy / Backtracking

Start with $n$ zeros. At each step, greedily try appending `0` or `1` such that the resulting $n$-gram has not appeared before. If stuck, backtrack.
- **Time Complexity**: Exponential $\mathcal{O}(2^{2^n})$ in the worst case if backtracking is needed.
- **Verdict**: For $n \le 15$, backtracking can blow up without careful order. Hierholzer's algorithm on the De Bruijn graph is guaranteed to find a solution in $\mathcal{O}(2^n)$ with zero backtracking.

---

## 4. Approach 2 — Lyndon Words / Shift-Register Generator (FKM Algorithm)

Concatenate the Lyndon words of length dividing $n$ in lexicographical order.
- **Complexity**: $\mathcal{O}(2^n)$ time and $\mathcal{O}(n)$ memory.
- **Verdict**: Elegant, but the De Bruijn graph Eulerian circuit approach (Approach 3) is the fundamental, visual graph-theoretic method and very simple to implement in C++.

---

## 5. Approach 3 — Optimal CSES Solution (Hierholzer's Algorithm on De Bruijn Graph)

1. If $n = 1$, return `"01"`.
2. Let $V = 2^{n-1}$ and mask $= V - 1$.
3. Maintain an adjacency array or transition counts for each state:
   Each state $u$ has two transitions: `next_bit[u]` starting at $0$, and advancing to $1$.
4. Use an explicit DFS stack to run Hierholzer's algorithm:
   - Push start vertex $0$ to `st`.
   - While `st` is non-empty:
     - $u = \text{st.back}()$.
     - If `next_edge[u] < 2`:
       - $b = \text{next\_edge}[u]++$.
       - $v = ((u \ll 1) \mid b) \ \& \ \text{mask}$.
       - Push $v$ to `st`.
     - Else:
       - Pop $u$ from `st` and record it.
5. Reconstruct the bit sequence from the circuit transitions.
6. Prepend $n - 1$ zeros and print.

```cpp
#include <iostream>
#include <vector>
#include <string>

using namespace std;

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    int n;
    if (!(cin >> n)) return 0;

    if (n == 1) {
        cout << "01\n";
        return 0;
    }

    int total_vertices = 1 << (n - 1);
    int mask = total_vertices - 1;

    vector<int> edge_idx(total_vertices, 0);
    vector<int> st;
    vector<int> circuit;
    circuit.reserve((1 << n) + 1);

    st.push_back(0);

    while (!st.empty()) {
        int u = st.back();

        if (edge_idx[u] < 2) {
            int b = edge_idx[u]++;
            int v = ((u << 1) | b) & mask;
            st.push_back(v);
        } else {
            circuit.push_back(u);
            st.pop_back();
        }
    }

    // Build the string: start with (n - 1) zeros
    string ans(n - 1, '0');

    // The edges traversed correspond to the last bit of each state in the circuit
    // Circuit is in reverse post-order, so iterating backwards gives forward traversal
    for (int i = (int)circuit.size() - 2; i >= 0; --i) {
        ans.push_back((circuit[i] & 1) ? '1' : '0');
    }

    cout << ans << '\n';

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^n)$.
  - Graph has $V = 2^{n-1}$ vertices and $E = 2^n$ edges.
  - Hierholzer's algorithm explores each edge exactly once.
  - For $n = 15$, $E = 32768$ operations $\approx 0.005\text{s}$.
- **Space Complexity**: $\mathcal{O}(2^n)$ to store the circuit and output string ($\approx 1\text{ MB}$).

---

## 6. Correctness Proof

### The De Bruijn Eulerian Theorem
- **Lemma 1**: The directed graph $G = (V, E)$ where $V = \{0, 1\}^{n-1}$ and edges are directed from $u$ to $((u \ll 1) \mid b) \pmod{2^{n-1}}$ is connected and has in-degree equal to out-degree for all vertices.
  - *Proof*:
    - Each vertex $u = (b_1, \dots, b_{n-1})$ has out-degree 2: edges lead to $(b_2, \dots, b_{n-1}, 0)$ and $(b_2, \dots, b_{n-1}, 1)$.
    - Each vertex $u$ has in-degree 2: edges enter from $(0, b_1, \dots, b_{n-2})$ and $(1, b_1, \dots, b_{n-2})$.
    - Thus $\text{in\_degree}(u) = \text{out\_degree}(u) = 2$ for every vertex $u$.
    - From any vertex $u$, following edges with bits $0, 0, \dots, 0$ ($n-1$ times) reaches vertex $0$. From vertex $0$, any vertex $v = (c_1, \dots, c_{n-1})$ can be reached by following bits $c_1, \dots, c_{n-1}$. Thus $G$ is strongly connected.
- **Lemma 2**: An Eulerian circuit on $G$ visits every directed edge exactly once.
  - *Proof*: There are $2 \cdot 2^{n-1} = 2^n$ edges. Each edge represents the unique $n$-tuple formed by vertex label concatenated with the edge bit. Because an Eulerian circuit visits all $2^n$ edges, every possible $n$-bit binary string is generated as a substring. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 3$:
- Length $n-1 = 2$. Vertices: $\{00, 01, 10, 11\}$.
- Mask $= 3$ (`0b11`).
- Edges:
  - $00 \xrightarrow{0} 00$, $00 \xrightarrow{1} 01$
  - $01 \xrightarrow{0} 10$, $01 \xrightarrow{1} 11$
  - $10 \xrightarrow{0} 00$, $10 \xrightarrow{1} 01$
  - $11 \xrightarrow{0} 10$, $11 \xrightarrow{1} 11$
- Run Hierholzer:
  - Circuit of states visited: $[00, 00, 01, 11, 11, 10, 01, 10, 00]$.
  - Reverse traversal transitions yield bits: $0, 0, 1, 1, 1, 0, 1, 0$.
- Prepend $n - 1 = 2$ zeros: `"00"` + `"01110100"`.
- Resulting string of length $2^3 + 3 - 1 = 10$: `"0001110100"`.
- Substrings of length 3:
  - `000`, `001`, `011`, `111`, `110`, `101`, `010`, `100`.
  - All 8 distinct 3-bit substrings are present!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **$n = 1$**:
   When $n = 1$, $n - 1 = 0$, so $V = 1$, and bits shift by 0. Directly hardcode `if (n == 1) return "01";` to prevent bitshift edge cases.
2. **String Size**:
   For $n = 15$, length is $2^{15} + 14 = 32782$ characters. Fits comfortably in memory and prints instantly.
3. **Bitwise Masking**:
   Use `mask = (1 << (n - 1)) - 1`. Bitwise AND keeps the lower $n - 1$ bits correctly.
4. **Any Valid Sequence Accepted**:
   Multiple Eulerian circuits exist in the De Bruijn graph. Any valid circuit produces a correct minimum-length string.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How many distinct De Bruijn sequences exist for binary strings of length $n$?**
   By the BEST Theorem (de Bruijn, van Aardenne-Ehrenfest, Smith, Tutte), the number of Eulerian circuits in a graph is $t_w(G) \cdot \prod (d_{in}(v) - 1)!$. For binary De Bruijn graphs, the number of distinct sequences is $2^{2^{n-1} - n}$.
2. **How does this apply to general alphabets of size $k$?**
   The same De Bruijn graph has $k^{n-1}$ vertices, each with in-degree and out-degree $k$. The sequence has length $k^n + n - 1$.
3. **What are practical applications of De Bruijn sequences?**
   - **Robotics & Vision**: absolute position tracking on patterns with barcode tape.
   - **Cryptography & Pseudorandom Generators**: maximal period shift registers (LFSR/NLFSR).
   - **Bioinformatics**: genome assembly via De Bruijn graphs from short DNA sequencing reads.
4. **What is the inverse problem?**
   Given a bit string, find the smallest $n$ such that all $2^n$ binary strings are present as substrings. Solvable via rolling polynomial hash or bitset in $\mathcal{O}(|S|)$.
5. **How does this relate to Hamiltonian paths?**
   An Eulerian circuit in the De Bruijn graph $B(2, n-1)$ is equivalent to a **Hamiltonian cycle** in the line graph $B(2, n)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, De Bruijn Graph, Eulerian Circuit, Hierholzer's Algorithm, Bit Manipulation
- **Complexity Summary**:
  - Time: $\mathcal{O}(2^n)$
  - Space: $\mathcal{O}(2^n)$
- **Related CSES Problems**:
  - [Mail Delivery](https://cses.fi/problemset/task/1691) — Undirected Eulerian circuit
  - [Teleporters Path](https://cses.fi/problemset/task/1693) — Directed Eulerian path
  - [Bit Strings](https://cses.fi/problemset/task/1617) — Power of two computations
