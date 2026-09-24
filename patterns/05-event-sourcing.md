# Pattern: Event Sourcing

**Store immutable event log as system of record; derive state from events.**

---

## The Decision

### Do Use Event Sourcing When:

- **Audit trail is non-optional** — Financial, medical, or compliance systems need "show me all changes to this record"
- **Temporal queries matter** — "What was inventory on Sep 1?" (not just current state)
- **Domain events are semantically important** — Events represent real business occurrences (OrderPlaced, PaymentReceived, not just state mutations)
- **Decoupled projections needed** — Different services need different views of same event stream (accounting sees credits/debits; operations sees inventory)

### Do NOT Use When:

- **Audit trail is just "nice to have"** — Conventional change logs (UPDATE audit_log) are simpler and sufficient
- **Simple CRUD application** — Store/retrieve/update records; no temporal complexity; no decoupling
- **Tenants require real-time consistency** — Eventual consistency from projections is acceptable?
- **Team is unfamiliar with distributed systems** — Event sourcing assumes async, eventual consistency thinking

### The Trap (Most Common Mistake)

Client says: "We need an audit trail."  
Team thinks: "Event sourcing!"  
Reality: 95% of systems need `UPDATE audit_log set changed_by=?, changed_at=? WHERE id=?` and a history table. Not event sourcing.

---

## Cost & Complexity

| Aspect | Event Sourcing | Conventional History Table |
|--------|---|---|
| **Audit compliance** | ✅ Yes (immutable log) | ✅ Yes (easier) |
| **Temporal queries** | ✅ Yes | ❌ Hard / complex |
| **Schema flexibility** | ✅ High (events are opaque) | ❌ Rigid schema |
| **Operational complexity** | ❌ High (async, eventual consistency, projections) | ✅ Simple (sync, strong consistency) |
| **Storage** | ❌ Grows indefinitely (never delete events) | ✅ Pruning + archival possible |
| **Team learning curve** | ❌ High (6–8 months to operationalize) | ✅ None (standard SQL) |

**Startup cost**: 4–8 engineer-weeks  
**Ongoing**: 1–2 events (projections, snapshots) per business domain  
**ROI**: Positive only if temporal queries or decoupled projections are genuinely needed

---

## Quick Audit: Do You Actually Need Event Sourcing?

Ask these questions:

1. **Is "show me all changes to this record" genuinely required?** (Compliance, legal, domain logic)
   - NO → Use history table. STOP.
   - YES → Continue.

2. **Do you need temporal queries** like "What was state on date X"?
   - NO → Conventional logging sufficient. STOP.
   - YES → Event sourcing makes sense.

3. **Do different parts of system need different views of same fact?** (Accounting ledger, operations dashboard, compliance audit all see order differently)
   - NO → Single view sufficient. Use history table instead.
   - YES → Event sourcing's decoupled projections shine.

4. **Can team handle eventual consistency** in projections? (Projection lag is OK; snapshot rebuilds needed; consistency bugs are hard to debug)
   - NO → Don't do event sourcing.
   - YES → Proceed.

If all 4 are YES, event sourcing is justified. If even one is NO, consider conventional approach.

---

## Common Mistakes & Costs

| Mistake | Impact | Mitigation |
|---------|--------|-----------|
| **Schema evolution** — How to handle event version changes? | Events from 2020 have different schema; deserialization breaks | Plan versioning upfront; evolve schema carefully |
| **Projection rebuilds** — When projection logic changes, must replay full event log | Can take hours for large events; consistency window is wide | Cache snapshots; rebuild in background; version projections |
| **Event log grows unbounded** | Storage costs increase indefinitely; query performance degrades | Archival strategy; snapshot/compaction design |
| **Debugging is hard** — Tracing a bug requires replaying events; eventual consistency bugs are subtle | Invest in tracing, replay tools; extra QA effort | Comprehensive testing + domain knowledge |

---

## Evidence to Collect

**Justify event sourcing if:**
- [ ] Compliance/legal requirement for audit trail (document regulation)
- [ ] Temporal queries are core feature (show historical state, trends)
- [ ] Multiple projections needed (3+ different views of same event stream)
- [ ] Domain logic involves sagas/compensations (event-driven workflows)
- [ ] Team has 1+ person with distributed systems + eventual consistency experience

**Invalidates event sourcing:**
- Simple audit trail only (use history table)
- Strong consistency required (projections eventually consistent)
- Team lacks distributed systems experience (learning curve too high)
- Storage/query performance is critical and tight (event log unbounded growth)

---

## First 30 Days (Pilot)

**Scope**: One aggregate/domain entity (e.g., Order, Account, not entire system)

**Metric**: 
- Events stored immutably
- Projection rebuilds complete in < 5 min
- No event deserialization failures
- Audit trail meets compliance test

**Stop if**: 
- Projection rebuilds take > 30 min (performance concern)
- Schema evolution causes data loss
- Team unable to reason about eventual consistency

**Rollback**: Keep event log; switch read queries back to conventional tables; maintain dual writes

---

## References

- **Event Sourcing** (Microsoft): When to use, anti-patterns, schema evolution
- **Event Sourcing** (Greg Young): Original pattern definition; practical concerns

---

**Status**: Decision card (skeleton) — validate necessity before implementation
