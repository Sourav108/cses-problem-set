# School Dance

- **Category**: Graph Algorithms
- **CSES Task ID**: `1696`
- **CSES Problem Link**: [School Dance](https://cses.fi/problemset/task/1696)
- **Limits**: Time Limit: 1.00s | Memory Limit: 512 MB

---

## 1. Problem, Restated

There are $n$ boys and $m$ girls at a school dance. There are $k$ potential pairs of boys and girls who are willing to dance with each other. Each boy can dance with at most one girl, and each girl can dance with at most one boy.

Your task is to calculate the **maximum number of dance pairs** that can be formed, and list the pairs. If there are multiple optimal solutions, you may output any of them.

### Input Format
- The first line contains three integers $n$, $m$, and $k$: the number of boys, girls, and potential pairs.
- The next $k$ lines each contain two integers $a$ and $b$: boy $a$ is willing to dance with girl $b$.

### Output Format
- On the first line, print an integer $r$: the maximum number of pairs.
- On the next $r$ lines, print two integers $a$ and $b$: a boy and a girl who will dance together.

### Numerical Constraints
- $1 \le n, m \le 500$
- $1 \le k \le 1000$
- $1 \le a \le n$
- $1 \le b \le m$

With $V = n + m \le 1000$ and $E = k \le 1000$, Maximum Bipartite Matching runs in $\mathcal{O}(V \cdot E) \approx 10^6$ operations $\approx 0.002\text{s}$.

---

## 2. Intuition & Pattern Recognition

This is the standard **Maximum Bipartite Matching** problem:
- The graph is bipartite: one partition consists of boys $B = \{1, \dots, n\}$, and the other of girls $G = \{1, \dots, m\}$.
- A matching is a subset of edges without common vertices.
- **Berge's Lemma (1957)**:
  A matching $M$ is maximum **if and only if** there are no **augmenting paths** with respect to $M$.
  An augmenting path is an alternating path starting and ending at unmatched vertices.
- **Kuhn's Algorithm**:
  1. Maintain `match_girl[g]`: the boy currently paired with girl $g$ (or $0$ if unmatched).
  2. For each boy $b \in \{1, \dots, n\}$, attempt to find an augmenting path starting at $b$ via DFS:
     - For each girl $g$ that boy $b$ likes:
       - If girl $g$ is currently unmatched, pair $b$ with $g$!
       - If girl $g$ is already matched to some boy $b' = \text{match\_girl}[g]$, see if $b'$ can find an alternative unmatched girl via DFS. If $b'$ succeeds, reassign $g$ to $b$!
  3. Each successful augmenting path increases the total matching size by exactly 1.

---

## 3. Approach 1 — Naive Greedy Matching

Iterate through pairs and match greedily.
- **Flaw**: Greedy choices can block optimal alternating reassignments, producing sub-optimal matchings (e.g. matching size 1 when maximum is 2).

---

## 4. Approach 2 — Dinic's Algorithm (Max Flow)

Add a source $s$ connected to all boys with capacity 1, directed edges from boys to girls with capacity 1, and directed edges from girls to sink $t$ with capacity 1. Run Dinic's algorithm in $\mathcal{O}(E \sqrt{V})$.
- **Verdict**: Fully optimal. However, Kuhn's Algorithm (Approach 3) is much simpler (under 40 lines of code) and runs in $< 0.002\text{s}$ for $n, m \le 500$.

---

## 5. Approach 3 — Optimal CSES Solution (Kuhn's Augmenting Path Algorithm)

1. Store adjacency list `adj[u]` where $u$ is a boy and elements are girls.
2. Maintain array `match_girl[m + 1]` initialized to 0.
3. For each boy $i \in \{1, \dots, n\}$:
   - Reset `visited_boy[1...n] = false`.
   - Call `dfs(i)`:
     ```cpp
     bool dfs(int u) {
         visited_boy[u] = true;
         for (int v : adj[u]) {
             if (match_girl[v] == 0 || (!visited_boy[match_girl[v]] && dfs(match_girl[v]))) {
                 match_girl[v] = u;
                 return true;
             }
         }
         return false;
     }
     ```
   - If `dfs(i)` returns `true`, increment matching count.
4. Output the total matching count.
5. For each girl $g \in \{1, \dots, m\}$:
   - If `match_girl[g] != 0`, print `match_girl[g] << ' ' << g`.

```cpp
#include <iostream>
#include <vector>

using namespace std;

int n, m, k;
vector<vector<int>> adj;
vector<int> match_girl;
vector<bool> visited;

bool dfs(int u) {
    visited[u] = true;

    for (int v : adj[u]) {
        if (match_girl[v] == 0 || (!visited[match_girl[v]] && dfs(match_girl[v]))) {
            match_girl[v] = u;
            return true;
        }
    }

    return false;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    if (!(cin >> n >> m >> k)) return 0;

    adj.assign(n + 1, vector<int>());
    match_girl.assign(m + 1, 0);

    for (int i = 0; i < k; ++i) {
        int u, v;
        cin >> u >> v;
        adj[u].push_back(v);
    }

    int max_matching = 0;
    visited.resize(n + 1);

    for (int i = 1; i <= n; ++i) {
        fill(visited.begin(), visited.end(), false);
        if (dfs(i)) {
            max_matching++;
        }
    }

    cout << max_matching << '\n';
    for (int g = 1; g <= m; ++g) {
        if (match_girl[g] != 0) {
            cout << match_girl[g] << ' ' << g << '\n';
        }
    }

    return 0;
}
```

### Complexity Analysis
- **Time Complexity**: $\mathcal{O}(V \cdot E) = \mathcal{O}(n \cdot k)$.
  - For each of the $n$ boys, the DFS visits each edge at most once: $\mathcal{O}(k)$.
  - For $n \le 500, k \le 1000$, total operations $\le 500 \times 1000 = 5 \cdot 10^5$, running in $\approx 0.002\text{s}$.
- **Space Complexity**: $\mathcal{O}(n + m + k)$ for the bipartite graph and match array ($\approx 500\text{ KB}$).

---

## 6. Correctness Proof

### Berge's Augmenting Path Theorem
- **Augmenting Path Definition**:
  An augmenting path $P = (u_1, v_1, u_2, v_2, \dots, u_p, v_p)$ starts at an unmatched boy $u_1$, alternates between unmatched edges and matched edges, and ends at an unmatched girl $v_p$.
- **Matching Augmentation**:
  - The path $P$ contains an odd number of edges $2p - 1$.
  - Exactly $p$ edges are currently not in $M$, and $p - 1$ edges are in $M$.
  - Inverting the membership of edges along $P$ (the symmetric difference $M \oplus P$) produces a valid matching of size $|M| + 1$.
- **Kuhn's DFS Correctness**:
  The function `dfs(u)` searches for an augmenting path starting at $u$.
  - If it finds an unmatched girl $v$ directly, it pairs $u$ with $v$.
  - If girl $v$ is matched to boy $u'$, it recursively searches for an augmenting path from $u'$.
  - The recursive reassignment `match_girl[v] = u` applies the symmetric difference along the path, strictly increasing the matching size by 1.
  - When all boys have been tested and no augmenting path exists, by Berge's Lemma, the matching is maximum. $\blacksquare$

---

## 7. Dry Run & Visual State Trace

Consider $n = 3, m = 3, k = 4$:
- Potential pairs: $(1, 1), (1, 2), (2, 1), (3, 2)$
- **Boy 1**:
  - Check girl 1: `match_girl[1] == 0` $\implies$ pair `match_girl[1] = 1`. Size = 1.
- **Boy 2**:
  - Check girl 1: matched to boy 1.
  - Recurse on boy 1: check girl 2 for boy 1: `match_girl[2] == 0` $\implies$ pair `match_girl[2] = 1`.
  - Reassign `match_girl[1] = 2`. Size = 2.
  - (Current pairs: $2-1$ and $1-2$).
- **Boy 3**:
  - Check girl 2: matched to boy 1.
  - Recurse on boy 1: no other girls available. Fails.
  - Boy 3 cannot be matched.
- Total matching: 2.
  - Girl 1 with Boy 2, Girl 2 with Boy 1.

---

## 8. Edge Cases, Overflow Gotchas & CSES Constraints

1. **Duplicate Edges in Input**:
   Multiple identical pairs $(a, b)$ can appear in the input. Kuhn's algorithm handles duplicate edges naturally; adding `sort` and `unique` on `adj[u]` can further optimize execution.
2. **More Boys than Girls ($n > m$) or Girls than Boys ($m > n$)**:
   The maximum matching cannot exceed $\min(n, m)$. Handled seamlessly without special cases.
3. **Completely Disconnected Participants**:
   Participants with no edges remain unmatched, correctly ignored.

---

## 9. Competitive Programming & Interview Follow-Up Questions

1. **How does Kuhn's algorithm compare to Hopcroft-Karp?**
   Hopcroft-Karp finds multiple vertex-disjoint shortest augmenting paths simultaneously in phases using BFS + DFS, running in $\mathcal{O}(E \sqrt{V})$. For $V \le 1000$, Kuhn's algorithm is faster in practice due to minimal overhead.
2. **What is König's Theorem?**
   In any bipartite graph, the size of a **Maximum Bipartite Matching** equals the size of a **Minimum Vertex Cover**.
3. **How do you find the Minimum Vertex Cover from the matching?**
   Run DFS from unmatched boys along alternating paths. The minimum vertex cover consists of $(L \setminus \text{visited}) \cup (R \cap \text{visited})$.
4. **How do you find the Maximum Independent Set in a bipartite graph?**
   By Gallai's Theorem: $\text{Maximum Independent Set} = V - \text{Minimum Vertex Cover} = V - \text{Maximum Matching}$.
5. **What if edge weights represent compatibility scores (Maximum Weight Bipartite Matching)?**
   Use the **Hungarian Algorithm** (Kuhn-Munkres) in $\mathcal{O}(V^3)$ or Min-Cost Max-Flow in $\mathcal{O}(V^2 E)$.

---

## 10. Tags, Complexity Summary & Related CSES Problems

- **Tags**: Graph Theory, Bipartite Matching, Kuhn's Algorithm, Augmenting Paths, Berge's Lemma
- **Complexity Summary**:
  - Time: $\mathcal{O}(n \cdot k)$
  - Space: $\mathcal{O}(n + m + k)$
- **Related CSES Problems**:
  - [Download Speed](https://cses.fi/problemset/task/1694) — Maximum Flow via Dinic
  - [Police Chase](https://cses.fi/problemset/task/1695) — Minimum Cut via Max Flow
  - [Distinct Routes](https://cses.fi/problemset/task/1711) — Edge-disjoint paths
