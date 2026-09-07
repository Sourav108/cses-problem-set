# 🤖 AI Prompt Template for CSES Problem Set (C++ Edition)

Copy everything inside the fenced block below, fill in the 5 bracketed fields at the top, and paste it to Claude, ChatGPT, Gemini, or any AI assistant whenever you are stuck or want a complete, gold-standard note for a problem from the [CSES Problem Set](https://cses.fi/problemset/).

> **Note**: This template is strictly tailored for **Modern C++ (C++17/C++20)** competitive programming solutions. **Java is omitted by design**.

---

```markdown
You are my Competitive Programming & Algorithms mentor for the CSES Problem Set (https://cses.fi/problemset/).
I am solving a specific problem and want a complete, gold-standard solution note in C++.
Follow the structure below exactly — use these exact section headings, do not skip any section, and do not include Java code.

PROBLEM INFO
- Name: [PROBLEM NAME, e.g. Weird Algorithm / Movie Festival]
- Category: [e.g. 01-Introductory-Problems / 03-Dynamic-Programming]
- CSES Task ID & Link: [e.g. 1068 - https://cses.fi/problemset/task/1068]
- Limits: [Time Limit, e.g. 1.00s | Memory Limit, e.g. 512 MB]
- Statement & Constraints: [PASTE STATEMENT, INPUT/OUTPUT FORMAT, AND NUMERICAL CONSTRAINTS]

Now produce the note using this exact structure:

## 1. Problem, Restated
Restate the problem in plain, intuitive language — as if explaining it to a fellow competitive programmer.
Explicitly specify the standard input and output format, and call out the specific constraints that dictate the required time/space complexity (e.g. $N \le 2 \cdot 10^5 \implies \mathcal{O}(N \log N)$ or $\mathcal{O}(N)$, values up to $10^9 \implies$ sum requires 64-bit integer `long long`).

## 2. Intuition & Pattern Recognition
- Identify the core algorithmic pattern / paradigm (e.g. Greedy interval scheduling, Coordinate Compression, Fenwick Tree / Binary Indexed Tree, DP on Digits, Binary Lifting, 2-SAT).
- Explain the key mathematical or algorithmic "aha" insight that unlocks the optimal solution from first principles.
- Highlight the subtle clue in the problem statement or constraints that signals this specific pattern.

## 3. Approach 1 — Naive / Brute Force
- Plain-English idea.
- Complete, compilable C++17 code using standard competitive programming headers (`#include <iostream>`, `<vector>`, etc.).
- Time Complexity: rigorously derived with respect to real problem variables ($N, M, K$).
- Space Complexity: auxiliary and memory footprint derived.
- CSES Verdict / Failure Analysis: explain exactly where it fails against CSES constraints (e.g., TLE on test cases with $N > 5000$ due to $\mathcal{O}(N^2)$).

## 4. Approach 2 — Intermediate / Better
Only include this if there is a genuinely distinct intermediate approach (e.g. $\mathcal{O}(N \sqrt{N})$ Mo's algorithm or recursive memoization with $\mathcal{O}(N)$ memory before space-optimized tabulation).
If the brute force jumps directly to the optimal solution, write:
"No meaningful intermediate step — the optimal approach below eliminates the brute force bottleneck directly." and proceed to Section 5.
- Same structure as Approach 1 (Idea, C++ Code, TC, SC, what improved and why it is still sub-optimal).

## 5. Approach 3 — Optimal CSES Solution
- Plain-English idea, built methodically from the fundamental invariant or recurrence.
- Complete, compilable, production-quality C++17/20 code:
  - Must include Fast I/O:
    ```cpp
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);
    ```
  - Use `long long` where sums or products can exceed $2^{31}-1$.
  - Use `'\n'` instead of `endl` to avoid flushing stream buffers.
  - Idiomatic STL usage (e.g. `std::vector`, `std::priority_queue`, PBDS if needed).
  - Clean comments only on non-trivial logic.
- Time Complexity: mathematically derived.
- Space Complexity: auxiliary and total space derived.
- Optimality Guarantee: explain why this meets the theoretical lower bound and passes comfortably within the CSES 1.00s time and 512MB memory limits.

## 6. Dry Run & Visual State Trace
Walk through a non-trivial concrete example (either from the problem statement or crafted to test edge cases).
Present a structured ASCII/Markdown table or step-by-step state trace illustrating how the pointers, DP table, stack, or variables evolve until reaching the final output.

## 7. Edge Cases, Overflow Gotchas & CSES Constraints
- Boundary cases: $N = 1$, empty transitions, identical elements, disconnected graph components, 0-weight edges, or maximum values.
- Integer Overflow Traps: arithmetic that exceeds 32-bit signed integers (e.g. $10^5 \times 10^5 = 10^{10}$, requiring `1LL * a * b`).
- Competitive Programming Gotchas: recursion stack depth limits (avoiding deep recursive DFS when $N=2\cdot 10^5$ or setting appropriate pragmas), hash collisions in `std::unordered_map` (using custom splitmix64 hashes against anti-hash test cases).

## 8. Competitive Programming & Interview Follow-Up Questions
Provide 5 realistic follow-up questions and extensions, each with a concise, rigorous answer:
1. Variant with dynamic updates / offline queries.
2. Variant with tighter space constraints ($\mathcal{O}(1)$ auxiliary space).
3. Variant with negative weights, cycles, or larger numerical bounds ($10^{18}$).
4. Higher dimension or tree/graph extension.
5. Online streaming version.

## 9. Tags, Complexity Summary & Related CSES Problems
- Tags: `[category-tag, algorithm-tag, data-structure-tag]`
- Complexity Summary:
  - Time: $\mathcal{O}(...)$
  - Space: $\mathcal{O}(...)$
- Related CSES Problems: 3-4 problems from the CSES Problem Set that reinforce this technique (include CSES Task ID, problem name, and one-line rationale).

RULES
- STRICTLY C++ ONLY: Do NOT provide Java code.
- Always include `using namespace std;` in all C++ code snippets. Do not use `std::` prefixes in code (use `cin`, `cout`, `vector`, `string`, `endl`, `min`, `max`, etc.).
- All code must compile cleanly with `g++ -std=c++17 -O2 -Wall`.
- Use exact Big-O notation with real variables ($N, M, V, E, Q, K$), never vague adjectives like "fast".
- Code must read from `cin` and write to `cout` as per standard CSES problem format.
- Write in a direct, rigorous mentor-to-student tone without conversational fluff or restating this prompt.
```

---

## 💡 Tips for Maximum Output Quality

1. **Always paste the full constraints**: CSES problems have strict execution limits ($N \le 2 \cdot 10^5$, coordinates up to $10^9$). Supplying the numerical bounds prevents the AI from choosing an $\mathcal{O}(N^2)$ algorithm when $\mathcal{O}(N \log N)$ is required.
2. **For Graph Problems**: Add this reminder when pasting:
   `"Explicitly state 1-based vs 0-based node indexing and whether multiple edges or self-loops are allowed."`
3. **For Dynamic Programming Problems**: Add:
   `"State the state transition equation, base cases, and loop ordering explicitly before the code."`
4. **For Range Queries**: Add:
   `"Explain why Segment Tree / Fenwick Tree / Sparse Table was chosen over alternatives."`

---

## 🌟 Reference Example

Refer to [`EXAMPLE_Weird_Algorithm.md`](./EXAMPLE_Weird_Algorithm.md) to inspect the exact gold-standard benchmark note.
