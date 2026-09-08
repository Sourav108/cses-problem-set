# 06-Tree-Algorithms (Complete 16 Problems)

> **Category Problem Count**: 16 Problems  
> **Status**: 🟢 Completed (16/16)  
> **Language**: Modern C++ (C++17/C++20 with Fast I/O, No Java)

## 📌 Overview

Tree structures, hierarchies, dynamic programming on trees, and advanced decompositions:
- **Tree Traversals & Post-Order DFS**: Subtree sizes, greedy leaf matching, height/depth calculations.
- **Tree Diameter & Center**: Extremal path identification via Two-BFS and dynamic programming.
- **Tree Rerooting Dynamic Programming (Up-Down DP)**:
  - Computing eccentricities (maximum distances) for every node.
  - Computing all-pairs distance sums in linear $\mathcal{O}(n)$ time via subtree size rebalancing.
- **Binary Lifting (Doubling)**:
  - $k$-th ancestor queries in $\mathcal{O}(\log n)$ time.
  - Lowest Common Ancestor (LCA) in $\mathcal{O}(\log n)$ time.
  - Pairwise tree distance queries in $\mathcal{O}(\log n)$ time.
- **Tree Difference Arrays (Prefix Sums on Trees)**:
  - Offline path coverage counting in $\mathcal{O}(n + m \log n)$ time via LCA.
- **Euler Tour Flattening (DFS Entry/Exit Times)**:
  - Subtree updates and subtree sum queries via Fenwick tree.
  - Path sums from root to node via ancestor-subtree duality and difference arrays.
- **Heavy-Light Decomposition (HLD)**:
  - Decomposing trees into logarithmic heavy chains.
  - Dynamic point updates and range maximum queries on arbitrary tree paths in $\mathcal{O}(\log^2 n)$ time.
- **Subtree Color Merging**:
  - Small-to-Large merging (`std::set::swap`) for counting distinct colors in subtrees in $\mathcal{O}(n \log^2 n)$ time.
- **Centroid Decomposition**:
  - Jordan's centroid finding via greedy descent in $\mathcal{O}(n)$ time.
  - Divide-and-conquer counting of paths with exact length $k$ in $\mathcal{O}(n \log n)$ time.
  - Path counting for lengths in range $[k_1, k_2]$ via Fenwick tree in $\mathcal{O}(n \log^2 n)$ time.

---

## 📋 Problem Checklist

- [x] **Problem 01**: [Subordinates](./01-subordinates.md) — [`CSES 1674`](https://cses.fi/problemset/task/1674) — 🟢 Completed
- [x] **Problem 02**: [Tree Matching](./02-tree-matching.md) — [`CSES 1130`](https://cses.fi/problemset/task/1130) — 🟢 Completed
- [x] **Problem 03**: [Tree Diameter](./03-tree-diameter.md) — [`CSES 1131`](https://cses.fi/problemset/task/1131) — 🟢 Completed
- [x] **Problem 04**: [Tree Distances I](./04-tree-distances-i.md) — [`CSES 1132`](https://cses.fi/problemset/task/1132) — 🟢 Completed
- [x] **Problem 05**: [Tree Distances II](./05-tree-distances-ii.md) — [`CSES 1133`](https://cses.fi/problemset/task/1133) — 🟢 Completed
- [x] **Problem 06**: [Company Queries I](./06-company-queries-i.md) — [`CSES 1687`](https://cses.fi/problemset/task/1687) — 🟢 Completed
- [x] **Problem 07**: [Company Queries II](./07-company-queries-ii.md) — [`CSES 1688`](https://cses.fi/problemset/task/1688) — 🟢 Completed
- [x] **Problem 08**: [Distance Queries](./08-distance-queries.md) — [`CSES 1135`](https://cses.fi/problemset/task/1135) — 🟢 Completed
- [x] **Problem 09**: [Counting Paths](./09-counting-paths.md) — [`CSES 1136`](https://cses.fi/problemset/task/1136) — 🟢 Completed
- [x] **Problem 10**: [Subtree Queries](./10-subtree-queries.md) — [`CSES 1137`](https://cses.fi/problemset/task/1137) — 🟢 Completed
- [x] **Problem 11**: [Path Queries](./11-path-queries.md) — [`CSES 1138`](https://cses.fi/problemset/task/1138) — 🟢 Completed
- [x] **Problem 12**: [Path Queries II](./12-path-queries-ii.md) — [`CSES 2134`](https://cses.fi/problemset/task/2134) — 🟢 Completed
- [x] **Problem 13**: [Distinct Colors](./13-distinct-colors.md) — [`CSES 1139`](https://cses.fi/problemset/task/1139) — 🟢 Completed
- [x] **Problem 14**: [Finding a Centroid](./14-finding-a-centroid.md) — [`CSES 2079`](https://cses.fi/problemset/task/2079) — 🟢 Completed
- [x] **Problem 15**: [Fixed-Length Paths I](./15-fixed-length-paths-i.md) — [`CSES 2080`](https://cses.fi/problemset/task/2080) — 🟢 Completed
- [x] **Problem 16**: [Fixed-Length Paths II](./16-fixed-length-paths-ii.md) — [`CSES 2081`](https://cses.fi/problemset/task/2081) — 🟢 Completed

---

## 💡 Standard Format

All 16 problems in `06-Tree-Algorithms` adhere strictly to the 10-section format specified in [`../AI_PROMPT_TEMPLATE.md`](../AI_PROMPT_TEMPLATE.md), featuring rigorous correctness proofs, state trace tables, and competitive follow-up questions.
