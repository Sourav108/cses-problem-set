# 05-Range-Queries (Complete 25 Problems)

> **Category Problem Count**: 25 Problems  
> **Status**: 🟢 Completed (25/25)  
> **Language**: Modern C++ (C++17/C++20 with Fast I/O, No Java)

## 📌 Overview

Range queries, point and range updates, 2D range sum/count, and persistence:
- **Prefix Sums & Sparse Tables**: Static range sum, range XOR, summed-area tables, and $\mathcal{O}(1)$ static RMQ.
- **Fenwick Trees (BIT)**: Point updates with range queries, difference arrays with point queries, coordinate compression, binary lifting on Fenwick trees, and 2D Fenwick trees.
- **Segment Trees**:
  - Point-update iterative segment trees for RMQ and dynamic range sums.
  - Divide-and-conquer monoid merging (Kadane algorithm for prefix/suffix/maximum subarray sums).
  - Walk on Segment Trees (binary searching the first element $\ge X$).
  - Dual segment trees for asymmetric distance metrics (pizzeria delivery costs).
  - Merge Sort Trees for 2D orthogonal range counting.
  - Dual Lazy Propagation (combining range additions and range assignments).
  - Polynomial / Arithmetic Progression Lazy Tags.
- **Persistent Segment Trees**:
  - Path copying for versioning and branched array copying.
  - Multi-version value-range queries for missing coin sums.
- **Binary Lifting**:
  - Monotonic stack next-greater chains for visible buildings and increasing arrays.
  - Time-domain activity scheduling for movie festivals.

---

## 📋 Problem Checklist

- [x] **Problem 01**: [Static Range Sum Queries](./01-static-range-sum-queries.md) — [`CSES 1646`](https://cses.fi/problemset/task/1646) — 🟢 Completed
- [x] **Problem 02**: [Static Range Minimum Queries](./02-static-range-minimum-queries.md) — [`CSES 1647`](https://cses.fi/problemset/task/1647) — 🟢 Completed
- [x] **Problem 03**: [Dynamic Range Sum Queries](./03-dynamic-range-sum-queries.md) — [`CSES 1648`](https://cses.fi/problemset/task/1648) — 🟢 Completed
- [x] **Problem 04**: [Dynamic Range Minimum Queries](./04-dynamic-range-minimum-queries.md) — [`CSES 1649`](https://cses.fi/problemset/task/1649) — 🟢 Completed
- [x] **Problem 05**: [Range Xor Queries](./05-range-xor-queries.md) — [`CSES 1650`](https://cses.fi/problemset/task/1650) — 🟢 Completed
- [x] **Problem 06**: [Range Update Queries](./06-range-update-queries.md) — [`CSES 1651`](https://cses.fi/problemset/task/1651) — 🟢 Completed
- [x] **Problem 07**: [Forest Queries](./07-forest-queries.md) — [`CSES 1652`](https://cses.fi/problemset/task/1652) — 🟢 Completed
- [x] **Problem 08**: [Hotel Queries](./08-hotel-queries.md) — [`CSES 1143`](https://cses.fi/problemset/task/1143) — 🟢 Completed
- [x] **Problem 09**: [List Removals](./09-list-removals.md) — [`CSES 1749`](https://cses.fi/problemset/task/1749) — 🟢 Completed
- [x] **Problem 10**: [Salary Queries](./10-salary-queries.md) — [`CSES 1144`](https://cses.fi/problemset/task/1144) — 🟢 Completed
- [x] **Problem 11**: [Prefix Sum Queries](./11-prefix-sum-queries.md) — [`CSES 2166`](https://cses.fi/problemset/task/2166) — 🟢 Completed
- [x] **Problem 12**: [Pizzeria Queries](./12-pizzeria-queries.md) — [`CSES 2206`](https://cses.fi/problemset/task/2206) — 🟢 Completed
- [x] **Problem 13**: [Visible Buildings Queries](./13-visible-buildings-queries.md) — [`CSES 3304`](https://cses.fi/problemset/task/3304) — 🟢 Completed
- [x] **Problem 14**: [Range Interval Queries](./14-range-interval-queries.md) — [`CSES 3163`](https://cses.fi/problemset/task/3163) — 🟢 Completed
- [x] **Problem 15**: [Subarray Sum Queries](./15-subarray-sum-queries.md) — [`CSES 1190`](https://cses.fi/problemset/task/1190) — 🟢 Completed
- [x] **Problem 16**: [Subarray Sum Queries II](./16-subarray-sum-queries-ii.md) — [`CSES 3226`](https://cses.fi/problemset/task/3226) — 🟢 Completed
- [x] **Problem 17**: [Distinct Values Queries](./17-distinct-values-queries.md) — [`CSES 1734`](https://cses.fi/problemset/task/1734) — 🟢 Completed
- [x] **Problem 18**: [Distinct Values Queries II](./18-distinct-values-queries-ii.md) — [`CSES 3356`](https://cses.fi/problemset/task/3356) — 🟢 Completed
- [x] **Problem 19**: [Increasing Array Queries](./19-increasing-array-queries.md) — [`CSES 2416`](https://cses.fi/problemset/task/2416) — 🟢 Completed
- [x] **Problem 20**: [Movie Festival Queries](./20-movie-festival-queries.md) — [`CSES 1664`](https://cses.fi/problemset/task/1664) — 🟢 Completed
- [x] **Problem 21**: [Forest Queries II](./21-forest-queries-ii.md) — [`CSES 1739`](https://cses.fi/problemset/task/1739) — 🟢 Completed
- [x] **Problem 22**: [Range Updates and Sums](./22-range-updates-and-sums.md) — [`CSES 1735`](https://cses.fi/problemset/task/1735) — 🟢 Completed
- [x] **Problem 23**: [Polynomial Queries](./23-polynomial-queries.md) — [`CSES 1736`](https://cses.fi/problemset/task/1736) — 🟢 Completed
- [x] **Problem 24**: [Range Queries and Copies](./24-range-queries-and-copies.md) — [`CSES 1737`](https://cses.fi/problemset/task/1737) — 🟢 Completed
- [x] **Problem 25**: [Missing Coin Sum Queries](./25-missing-coin-sum-queries.md) — [`CSES 2184`](https://cses.fi/problemset/task/2184) — 🟢 Completed

---

## 💡 Standard Format

All 25 problems in `05-Range-Queries` adhere strictly to the 10-section format specified in [`../AI_PROMPT_TEMPLATE.md`](../AI_PROMPT_TEMPLATE.md), featuring rigorous correctness proofs, state trace tables, and competitive follow-up questions.
