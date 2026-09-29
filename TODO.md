# Cloud Patterns Catalogue — Development Roadmap

**Status:** Phase A Complete (Schema, Two Patterns, Detail Pages)  
**Current Focus:** Validation Before Expansion  
**Last Updated:** 2026-09-24

---

## Phase B: Quality Assurance & User Testing

**Goal:** Validate that two patterns are sufficient to test real user needs before adding more content.

### B1: Quality Assurance Pass (Before Sharing)

**Status:** ✅ Complete  
**Effort:** 2 hours  
**Evidence:** See `docs/QA_REVIEW.md`

#### Browser & Navigation Checks
- [x] Load `/` directly; load a detail URL directly in fresh tab
- [x] Refresh detail URL; confirm renders correctly
- [x] Test browser back/forward controls (not just custom back link)
- [x] Confirm document-relative URLs work under localhost:8000/
- [ ] Confirm document-relative URLs work under localhost:8080/patterns/ (deferred to nginx test)
  - **Re-entry condition:** User-facing nginx routing scenario with acceptance criteria defined and deployment context available
- [x] Confirm pattern cards have unique, stable URL identifiers
- [x] Test invalid pattern ID; shows usable error state (not blank page or JS crash)

#### Content Review

**Asynchronous Job Processing:**
- [x] Problem readable by manager + architect (not just architect jargon)
- [x] Decision statement uses decisive language (what + why)
- [x] "Avoid when" conditions are honest, meaningful (not boilerplate)
- [x] All 7 design decisions have clear rationale
- [x] Tradeoffs framed as consequences, not generic pros/cons
- [x] Reader understands: durable acceptance, idempotency, retries, DLQ, status visibility, monitoring
- [x] Further reading references clearly labeled as "conceptual" or "implementation"

**Strangler Fig:**
- [x] Problem readable by manager + architect
- [x] Decision emphasizes **staged replacement through seams**, not just "API gateway in front of old system"
- [x] Routing/feature flags explained as core mechanism (not tangential)
- [x] "Avoid when" conditions honest (e.g., monoliths with no seams; immediate timeline requirements)
- [x] Reader understands: seam identification, graceful fallback, data bridge, parallel operation window
- [x] References to Fowler's original framing clear

#### Diagram Checks (Both Patterns)
- [x] Every arrow has clear direction and purpose
- [x] One central takeaway per diagram
- [x] Labels readable at normal browser zoom
- [x] Consistent visual vocabulary across both SVGs (colors, fonts, component shapes)
- [x] Color does not carry meaning without text labels
- [x] `alt` text describes information flow, not "Strangler Fig diagram"
- [x] Diagrams are original creations; references shown as reading, not implied sources
- [x] No vendor logos or service names (vendor-neutral)

---

### B2: User Testing with Three Audiences (Task-Based)

**Status:** ⏳ Not Started  
**Effort:** 2–3 hours (includes scheduling + synthesis)

#### Setup
- Use localhost screen-share, reverse-proxy route, or temporary preview deployment
- Give task (not "what do you think?")
- Record answers without leading responses

#### Sample Task Prompt
> "You are trying to make a long-running, failure-prone workflow reliable without blocking user requests. Which pattern would you choose, what decision does it recommend, and what trade-off worries you most?"

#### Audiences
1. **Senior Engineer / Architect**
   - Assess: Technical correctness, missing operational caveats, terminology precision
   - Target: 1 person (colleague, hiring contact, or consulting prospect)

2. **Engineering Manager or Technical Lead**
   - Assess: Whether pattern helps decision-making (not just describes technology)
   - Target: 1 person (manager, product contact, or hiring manager)

3. **Non-Technical Business-Oriented Contact**
   - Assess: Whether problem/outcome and relevance are intelligible to non-engineers
   - Target: 1 person (executive, product person, or business stakeholder)

#### Questions for Each Tester
1. What do you think this site is for?
2. Which section was most useful in deciding whether to use the pattern?
3. What was unclear, redundant, or too detailed?
4. What would you want to see before trusting this as a practical engineering reference?

#### Feedback Synthesis
- [ ] Document observations in `docs/FEEDBACK.md`
- [ ] Note which patterns were clearer (if only one tested)
- [ ] Identify common confusion points
- [ ] Record requests for additional content or changes

---

## Phase C: Add Feedback Mechanism (Lightweight)

**Status:** ✅ Complete  
**Effort:** 30 minutes

- [x] Add "Was this useful? Send feedback" link on detail pages
- [x] Link opens email draft with prepopulated subject: `Cloud Patterns feedback — {pattern-id}`
- [x] Captures feedback from visitors outside live conversations
- [x] Includes structured prompts: what was useful, what was unclear, what decision would it help make

**Implementation:** mailto link with subject and body template in pattern.html footer

---

## Decision Gate: When to Add More Patterns

**Do NOT add Circuit Breaker or Event-Driven Architecture until you observe:**

| Observation | Next Action |
|---|---|
| Users understand the site and want more patterns | Add Circuit Breaker (state machines, resilience) |
| Users understand concept but want operational guidance | Improve existing decision/monitoring sections first |
| Users focus on diagrams, miss trade-offs | Improve hierarchy; link diagrams to decisions |
| Users want implementation proof | Add code examples or "how we implemented this" panel |
| Users cannot distinguish patterns | Improve catalogue labels, categories, card summaries |
| Format feels too dense | Reduce or progressively disclose components/variations |

### If Feedback is Positive:
- **Circuit Breaker next** (introduces state transitions; tests schema flexibility)
- Event-Driven Architecture fourth (broader scope; tests if catalogue stays useful without becoming generic)

### If Feedback Suggests Changes:
- **Do not expand content**
- Improve clarity/density of existing patterns
- Retest before adding new ones

---

## Success Criteria for Phase B

✅ **Content Review:** All checks pass without major rewrites  
✅ **QA Pass:** Site works under both localhost:8000 and localhost:8080/patterns/  
✅ **User Testing:** Collect feedback from 3 people without major usability blockers  
✅ **Decision Made:** Clear signal on whether to add patterns or improve existing ones  

**Timeline:** Complete by end of week (2026-09-27)

---

## Phase D: Content Expansion (Conditional)

**Status:** ⏳ Blocked on Phase B feedback

- Circuit Breaker (if approved by user testing)
- Event-Driven Architecture (if Circuit Breaker validation succeeds)
- Polish and publication based on evidence

---

## Current Asset Status

| Item | Status | Notes |
|---|---|---|
| Async Job Processing (pattern + diagram + detail page) | ✅ Complete | Fully implemented, validated |
| Strangler Fig (pattern + diagram + detail page) | ✅ Complete | Fully implemented, validated |
| Schema validation (tests/validate_patterns.py) | ✅ Complete | Runs via `just test` |
| Homepage (index.html) | ✅ Complete | Loads patterns, renders grid |
| Detail page (pattern.html) | ✅ Complete | Loads pattern data, renders full view |
| Navigation (card → detail → back) | ✅ Complete | Tested locally |
| Infrastructure (nginx, docker-compose) | ✅ Complete | Deployed and working |
| Feedback mechanism | ✅ Complete | Mailto link with structured prompts |
| Circuit Breaker pattern | ⏳ Deferred | Only if Phase B testing approves |
| Event-Driven Architecture pattern | ⏳ Deferred | Only if Circuit Breaker succeeds |

---

## Immediate Next Steps

1. **Schedule 3 user testing sessions** (Phase B2) with task-based prompts
2. **Conduct user testing** and document feedback in `docs/FEEDBACK.md`
3. **Make decision** on Circuit Breaker based on user signal

**Do not start adding patterns until Phase B feedback is collected and reviewed.**

---

---

## Backlog: Future Phases

### Path Routing & Deployment (Deferred to After User Testing)

- [ ] Test nginx reverse proxy with subpath routing
  - [ ] Confirm `http://localhost:8080/patterns/` loads homepage
  - [ ] Confirm detail pages load at `http://localhost:8080/patterns/pattern.html?id=...`
  - [ ] Confirm all assets (JSON, SVGs, stylesheets) load correctly
  - [ ] Test invalid pattern IDs under proxied route
  - [ ] Test browser back/forward under proxied route
- [ ] Deploy to public preview (GitHub Pages or Netlify)
  - [ ] Test same routing checks on public URL
  - [ ] Share read-only link with users

### Content Expansion (Only After Phase B User Testing)

**Decision Gate:** Only add Circuit Breaker if:
- Users understand the site format and want more patterns, OR
- Feedback suggests the format works but content depth is needed

If feedback suggests clarity/density issues instead, improve existing patterns first.

- [ ] Add Circuit Breaker pattern (if approved by user testing)
  - [ ] Pattern schema in patterns.json
  - [ ] SVG diagram (state machine: Closed → Open → Half-Open)
  - [ ] Design decisions focusing on fail-fast and recovery testing
  - [ ] Integration with async job processing and event-driven patterns
- [ ] Add Event-Driven Architecture pattern (only after Circuit Breaker validation)
  - [ ] Pattern schema in patterns.json
  - [ ] SVG diagram (vendor-neutral: producers → event channel → consumers)
  - [ ] Design decisions on event ownership, schema evolution, idempotency, replay
- [ ] Consider implementation proof
  - [ ] Link to repository code examples (fleet-ops, fleet-base)
  - [ ] Add "How we implemented this" panel showing real usage

### Format & UX Refinement (Only After User Testing)

- [ ] Improve diagram-to-decision linking if users miss trade-offs
- [ ] Progressively disclose components/variations if format feels dense
- [ ] Add pattern categories or filtering if 4+ patterns and users request discovery help
- [ ] Improve card summaries if users cannot distinguish patterns at a glance

### Analytics & Monitoring (Defer Until After Public Launch)

- [ ] Track which patterns are viewed most
- [ ] Monitor bounce rate and time-on-page
- [ ] Correlate feedback email responses with viewing patterns
- [ ] Do NOT add analytics before user testing (email feedback is sufficient)

### Nice-to-Have (Lowest Priority)

- [ ] Related patterns section: Link from Async to Circuit Breaker, etc.
- [ ] Pattern comparison modal (compare two patterns side-by-side)
- [ ] Search/filter by concern (reliability, scalability, etc.)
- [ ] Dark mode toggle
- [ ] Print stylesheet for reference/sharing

---

## Notes for Future Phases

- **Deployment:** Use GitHub Pages or Netlify for public preview; confirm subpath routing works first
- **Analytics:** Defer; use email feedback + direct conversations until public launch
- **Scaling:** If 10+ patterns are added later, consider categories/filters; keep flat for now
- **Implementation evidence:** Valuable; consider linking to code examples or architecture decision records
- **Diagram library:** Current SVG style (vendor-neutral, decision-focused) scales well; document the visual language for future patterns
