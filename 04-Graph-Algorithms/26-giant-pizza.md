# Giant Pizza

- **Category**: Graph Algorithms
- **CSES Task ID**: `1684`
- **CSES Problem Link**: [Giant Pizza](https://cses.fi/problemset/task/1684)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

Uolevi's family is ordering a large pizza. There are $m$ possible toppings numbered $1, 2, \dots, m$. There are $n$ family members, each giving two wishes. Each wish is of the form:
- `+ x`: The member wants topping $x$ on the pizza.
- `- x`: The member does not want topping $x$ on the pizza.

A family member is happy if **at least one** of their two wishes is satisfied. Your task is to determine whether there is a way to choose which toppings to include on the pizza such that **every** family member is happy.

If a valid topping assignment exists, print `+` or `-` for each topping $1, 2, \dots, m$. If it is impossible to satisfy all family members simultaneously, print `IMPOSSIBLE`.

### Input Format
- The first line contains two integers $n$ and $m$: the number of family members and toppings.
- The next $n$ lines describe the wishes. Each line contains four tokens: $s_1$, $x_1$, $s_2$, $x_2$, where $s_i \in \{'+', '-'\}$ and $1 \le x_i \le m$.

### Output Format
- If a valid assignment exists, print a line with $m$ characters (each `+` or `-`) separated by spaces.
- If no valid assignment exists, print `IMPOSSIBLE`.

### Numerical Constraints
- $1 \le n, m \le 10^5$
- $1 \le x_1, x_2 \le m$

With $V = 2m = 2 \cdot 10^5$ and $E = 2n = 2 \cdot 10^5$, 2-SAT via Strongly Connected Components (Kosaraju or Tarjan) runs in linear time $\mathcal{O}(n + m) \approx 0.08\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the classic **2-Satisfiability (2-SAT)** problem:
- We have $m$ boolean variables $x_1, x_2, \dots, x_m$, where $x_i = \text{true}$ means topping $i$ is included (`+`), and $x_i = \text{false}$ means topping $i$ is excluded (`-`).
- Each family member's preference is a logical clause of two literals:
  $$L_1 \lor L_2$$
  where each literal $L_i$ is either $x$ or $\neg x$.
- **Implication Graph Reduction**:
  By boolean logic, a disjunction $A \lor B$ is logically equivalent to two conditional implications:
  $$\neg A \implies B \quad \text{and} \quad \neg B \implies A$$
- **Node Mapping**:
  For each topping $x \in \{1, \dots, m\}$:
  - Let $2x$ represent literal $x$.
  - Let $2x + 1$ represent literal $\neg x$.
  - The negation of variable $u$ is $u \oplus 1$.
- **2-SAT Satisfiability Theorem (Aspvall, Plass & Tarjan, 1979)**:
  A 2-SAT formula is satisfiable **if and only if** for every variable $x$, literal $x$ and its negation $\neg x$ belong to **different Strongly Connected Components (SCCs)**:
  $$\text{scc}[2x] \ne \text{scc}[2x + 1] \quad \text{for all } x \in \{1, \dots, m\}$$
- **Constructing a Valid Assignment**:
  If the formula is satisfiable, in the condensation DAG of SCCs:
  - If $\text{scc}[x] > \text{scc}[\neg x]$:
    In Kosaraju's algorithm, a larger component index corresponds to being further downstream in the topological order. Implication arrows flow from topological earlier to topological later components.
    Setting the downstream literal to `true` avoids forcing contradictions!
    Therefore, assign $x = \text{true}$ (`+`) if $\text{scc}[2x] > \text{scc}[2x + 1]$, and $x = \text{false}$ (`-`) otherwise.

---

## 3. Approach 1 — Naive Backtracking

Try all $2^m$ possible assignments of toppings. For each assignment, check if all $n$ family members are satisfied.

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(2^m \cdot n)$.
- **Space Complexity**: $\mathcal{O}(m)$.
- **CSES Verdict**: TLE immediately for $m > 25$.

---

## 4. Approach 2 — Tarjan's 2-SAT Algorithm

Use Tarjan's single-pass DFS with `low_link` and recursion stack.
- **Verdict**: Optimal $\mathcal{O}(n + m)$.
- Kosaraju's algorithm (Approach 3) achieves the exact same linear complexity with simpler, two-pass DFS logic.

---

## 5. Approach 3 — Optimal CSES Solution (Kosaraju's 2-SAT)

1. Map variable $x \in [1, m]$:
   - Literal $+x \to 2x$.
   - Literal $-x \to 2x + 1$.
   - Negation of node $u$: $\text{neg}(u) = u \oplus 1$.
2. For each clause $L_1 \lor L_2$:
   - Add implication $\text{neg}(L_1) \to L_2$.
   - Add implication $\text{neg}(L_2) \to L_1$.
3. Run Kosaraju's Algorithm on the $2m$ literals:
   - Pass 1: DFS on original implication graph $G$, pushing finished vertices to `order`.
   - Pass 2: Reverse iterate `order`, running DFS on transposed graph $G^R$ to assign `scc_id`.
4. Verification:
   - For each topping $i \in [1, m]$:
     If $\text{scc\_id}[2i] == \text{scc\_id}[2i + 1]$, print `IMPOSSIBLE` and exit.
5. Assignment:
   - For each topping $i \in [1, m]$:
     If $\text{scc\_id}[2i] > \text{scc\_id}[2i + 1]$, print `+`, else print `-`.

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int n, m;
vector<vector<int>> adj;
vector<vector<int>> rev_adj;
vector<bool> visited;
vector<int> order;
vector<int> scc_id;
int scc_count = 0;

void dfs1(int u) {
    visited[u] = true;
    for (int v : adj[u]) {
        if (!visited[v]) {
            dfs1(v);
        }
    }
    order.push_back(u);
}

void dfs2(int u, int id) {
    visited[u] = true;
    scc_id[u] = id;
    for (int v : rev_adj[u]) {
        if (!visited[v]) {
            dfs2(v, id);
        }
    }
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> m)) return 0;

    int total_nodes = 2 * m + 2;
    adj.assign(total_nodes, vector<int>());
    rev_adj.assign(total_nodes, vector<int>());

    for (int i = 0; i < n; ++i) {
        char s1, s2;
        int x1, x2;
        cin >> s1 >> x1 >> s2 >> x2;

        int u = (s1 == '+') ? (2 * x1) : (2 * x1 + 1);
        int v = (s2 == '+') ? (2 * x2) : (2 * x2 + 1);

        int not_u = u ^ 1;
        int not_v = v ^ 1;

        // Clause (u or v) <=> (not_u => v) and (not_v => u)
        adj[not_u].push_back(v);
        rev_adj[v].push_back(not_u);

        adj[not_v].push_back(u);
        rev_adj[u].push_back(not_v);
    }

    // Pass 1: Forward DFS
    visited.assign(total_nodes, false);
    for (int i = 2; i <= 2 * m + 1; ++i) {
        if (!visited[i]) {
            dfs1(i);
        }
    }

    // Pass 2: Backward DFS on transposed graph
    visited.assign(total_nodes, false);
    scc_id.assign(total_nodes, 0);

    for (int i = (int)order.size() - 1; i >= 0; --i) {
        int u = order[i];
        if (!visited[u]) {
            scc_count++;
            dfs2(u, scc_count);
        }
    }

    // Check satisfiability and determine assignments
    vector<char> ans(m + 1);
    for (int i = 1; i <= m; ++i) {
        if (scc_id[2 * i] == scc_id[2 * i + 1]) {
            cout << "IMPOSSIBLE\n";
            return 0;
        }
        // In Kosaraju, a higher scc_id means the component is topologically later
        ans[i] = (scc_id[2 * i] > scc_id[2 * i + 1]) ? '+' : '-';
    }

    for (int i = 1; i <= m; ++i) {
        cout << ans[i] << (i == m ? '\n' : ' ');
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(n + m)$.
  - Building implication graph: $2n$ edges, $2m$ vertices: $\mathcal{O}(n + m)$.
  - Kosaraju's two DFS passes: $\mathcal{O}(n + m)$.
  - Consistency check and assignment: $\mathcal{O}(m)$.
  - Total time: $\approx 0.08\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m)$ for the adjacency lists and state vectors ($\approx 16\text{ MB}$).

---

## 6. Correctness Proof

### The 2-SAT Correctness Theorem
- **Theorem**: A 2-SAT instance is satisfiable if and only if no variable $x$ has both $x$ and $\neg x$ in the same Strongly Connected Component.
- **Proof**:
  1. *Necessity ($\implies$)*: Suppose $x$ and $\neg x$ belong to the same SCC. Then there exists an implication path $x \rightsquigarrow \neg x$ and a path $\neg x \rightsquigarrow x$.
     If $x = \text{true}$, the first path forces $\neg x = \text{true} \implies x = \text{false}$, a contradiction.
     If $x = \text{false}$, the second path forces $x = \text{true}$, a contradiction.
     Thus, no satisfying assignment can exist.
  2. *Sufficiency ($\impliedby$)*: Suppose for all variables $x$, $x$ and $\neg x$ lie in distinct SCCs.
     Condense the SCCs into a DAG.
     Assign truth values by processing components in reverse topological order: for each variable $x$, if $\text{scc}[x]$ appears after $\text{scc}[\neg x]$ in topological order, set $x = \text{true}$; otherwise set $x = \text{false}$.
     Because implications only flow forward in topological order, no edge can go from a $\text{true}$ component to a $\text{false}$ component.
     Hence, every implication $(\neg A \implies B)$ evaluates to $\text{true}$, satisfying every clause. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 3, m = 2$:
- Wishes:
  1. `+ 1 + 2` $\implies (x_1 \lor x_2) \implies (\neg x_1 \to x_2)$ and $(\neg x_2 \to x_1)$
  2. `- 1 + 2` $\implies (\neg x_1 \lor x_2) \implies (x_1 \to x_2)$ and $(\neg x_2 \to \neg x_1)$
  3. `+ 1 - 2` $\implies (x_1 \lor \neg x_2) \implies (\neg x_1 \to \neg x_2)$ and $(x_2 \to x_1)$

- Implication paths:
  - $\neg x_2 \to x_1 \to x_2$.
  - Therefore, if $\neg x_2$ is true, $x_2$ must be true $\implies \neg x_2$ must be false $\implies x_2 = \text{true}$ (`+`).
  - Once $x_2 = \text{true}$, $x_2 \to x_1 \implies x_1 = \text{true}$ (`+`).
- SCC check: $x_1$ and $\neg x_1$ are in different SCCs. $x_2$ and $\neg x_2$ are in different SCCs.
- $\text{scc}[2 \cdot 1] > \text{scc}[2 \cdot 1 + 1] \implies +$
- $\text{scc}[2 \cdot 2] > \text{scc}[2 \cdot 2 + 1] \implies +$
- Output: `+ +`. All 3 members satisfied!

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Unconstrained Variables**:
   If some topping is never mentioned by any member, its literals have in-degree and out-degree 0. They form singleton SCCs. The tie-breaker `scc_id[2i] > scc_id[2i+1]` deterministically picks `+` or `-` without issue.
2. **Conflicting Demands (Instant Contradiction)**:
   If a member demands $(+1 \lor +1)$ and another demands $(-1 \lor -1)$, the implication graph contains $1 \leftrightarrow \neg 1$, placing both in the same SCC $\implies$ output `IMPOSSIBLE`.
3. **Array Offsets and Indexing**:
   Mapping topping $x \in [1, m]$ to literals $2x$ and $2x + 1$ requires table size $2m + 2$. Using 0-indexed bitwise negation `u ^ 1` handles negations without arithmetic errors.
4. **Kosaraju Component Ordering**:
   In Kosaraju's algorithm, vertices are extracted in reverse finishing time. The first SCC discovered in Pass 2 is a sink in the condensation DAG. Thus, components assigned earlier have smaller IDs and appear downstream. The condition `scc_id[2i] > scc_id[2i+1]` corresponds to choosing the topologically later literal.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **Why is 2-SAT solvable in polynomial time, but 3-SAT is NP-complete?**
   In 2-SAT, each clause $(A \lor B)$ allows only one deduction per false literal ($\neg A \implies B$), giving a directed implication graph. In 3-SAT, knowing $A$ is false still leaves $(B \lor C)$, branching into non-deterministic choices.
2. **How do we handle single-literal requirements like "topping 1 MUST be included"?**
   Represent $x$ as the clause $(x \lor x)$, which generates implications $\neg x \to x$.
3. **How do we handle "EXACTLY ONE of topping A or B"?**
   Exclusive OR $(A \oplus B)$ expands to two 2-SAT clauses: $(A \lor B) \land (\neg A \lor \neg B)$.
4. **How do we find the lexicographically smallest 2-SAT assignment?**
   2-SAT with lexicographically smallest assignment is NP-hard in general. However, greedily trying to assign variables to `false` and propagating reachability in $\mathcal{O}(V(V + E))$ can find it for small $N$.
5. **How does 2-SAT relate to Maximum Independent Set on bipartite graphs?**
   2-SAT can be viewed as finding an independent set on an associated graph of incompatible assignments, closely connecting logic to structural graph theory.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, 2-SAT, Strongly Connected Components, Kosaraju's Algorithm, Boolean Logic
- **Complexity Summary**:
  - Time: $\mathcal{O}(n + m)$
  - Space: $\mathcal{O}(n + m)$
- **Related CSES Problems**:
  - [Planets and Kingdoms](https://cses.fi/problemset/task/1683) — General SCC extraction
  - [Flight Routes Check](https://cses.fi/problemset/task/1682) — Strong connectivity testing
  - [Coin Collector](https://cses.fi/problemset/task/1686) — DAG DP over condensed SCCs
