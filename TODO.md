# cloud-patterns: User Testing (Phase B2)

Two patterns complete (Async Job Processing, Strangler Fig), schema validated, UI functional, feedback mechanism added.
Phase A (patterns) and B1 (QA) done. Phase B2 user testing is the gate to Circuit Breaker.

---

## Phase B2: User Testing with Three Audiences

**Unresolved:** Schedule and conduct 3 user testing sessions; document feedback in `docs/FEEDBACK.md`.

**Audiences:**
1. Senior Engineer / Architect — technical correctness, operational caveats
2. Engineering Manager / Technical Lead — decision-making value
3. Non-Technical Business Contact — problem/outcome clarity

**Task prompt:** "You are trying to make a long-running, failure-prone workflow reliable without blocking user requests. Which pattern would you choose, what decision does it recommend, and what trade-off worries you most?"

**Questions:**
1. What do you think this site is for?
2. Which section was most useful in deciding whether to use the pattern?
3. What was unclear, redundant, or too detailed?
4. What would you want to see before trusting this as a practical engineering reference?

**After B2:** Decide on Circuit Breaker (if positive feedback) or iterate existing patterns first.
