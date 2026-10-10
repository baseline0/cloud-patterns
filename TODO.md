# cloud-patterns TODO

Two patterns complete (Async Job, Strangler Fig). Phase A (patterns) and B1 (QA) done.

## Quick Wins - `quickwin`

- [ ] Schedule 3 user testing sessions [TTV: 1h]

## Blockers - `blocker`

- [ ] Conduct user testing with 3 audiences [TTV: 2h total]
  - Senior Engineer / Architect
  - Engineering Manager / Technical Lead
  - Non-Technical Business Contact
  - Document feedback in docs/FEEDBACK.md (not yet created)
- [ ] Synthesize feedback patterns [TTV: 30m]

## Features - `feature`

- [ ] Decide on Circuit Breaker pattern (if positive feedback). `patterns/08-circuit-breaker.md` exists.

---

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
