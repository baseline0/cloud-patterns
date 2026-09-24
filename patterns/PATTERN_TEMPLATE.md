# Pattern: [NAME]

**Quick summary:** One sentence on what this pattern solves.

---

## Overview

### Problem It Solves
Describe the core issue this pattern addresses. What pain point or constraint drove its creation?

### When to Use
- Specific scenario 1
- Specific scenario 2
- When you have constraint X

### When NOT to Use
- Situation where this pattern is overkill
- When simpler approach is better
- Anti-patterns to avoid

### Trade-Offs Summary

| Aspect | Gain | Loss |
|--------|------|------|
| **Complexity** | ✅ Scales horizontally | ❌ Operational overhead |
| **Cost** | ✅ More efficient | ❌ Upfront infrastructure |
| **Risk** | ✅ Resilient to failure X | ❌ New failure mode Y |
| **Team** | ✅ Skill requirement | ❌ Learning curve |

---

## Architecture Diagram

### C4 Context Level
```
[Diagram description or ASCII art]

Learner → System → [Key components]
```

**Key components:**
- **Component A**: Role, technology, responsibility
- **Component B**: Role, technology, responsibility
- **Component C**: Role, technology, responsibility

**Interactions:**
- A → B: Synchronous REST calls
- B → C: Asynchronous events via message queue

---

## When to Apply This Pattern

### Prerequisites
- **Team skills**: What expertise is needed? (e.g., distributed systems knowledge)
- **Technology stack**: Any specific tech required?
- **Scale threshold**: At what scale does this become necessary?

### Problem Indicators (Does Your System Have These?)
- [ ] Indicator A (e.g., "database CPU at 80%+")
- [ ] Indicator B (e.g., "incident mean time to recovery > 1 hour")
- [ ] Indicator C (e.g., "audit trail missing; compliance risk")

### Common Misconceptions
- **Misconception 1**: "This pattern is simple to implement" → Reality: Often requires significant refactoring
- **Misconception 2**: "This pattern solves all performance issues" → Reality: Only addresses specific bottleneck

---

## Implementation Strategy

### Phase 1: Preparation (Week 1–2)
**Goal:** Understand current state; plan migration.

**Steps:**
1. Audit existing system for compatibility
2. Identify migration scope (which components, systems?)
3. Decide: greenfield or gradual adoption?
4. Draft rollback plan (how to revert if issues arise?)

**Deliverables:**
- Implementation plan (phased timeline)
- Risk mitigation checklist

### Phase 2: Pilot (Week 3–6)
**Goal:** Prove pattern works in small scope; learn operational nuances.

**Steps:**
1. Implement pattern for one subsystem or use case
2. Test under realistic load
3. Measure improvement (latency, throughput, error rate, cost)
4. Document lessons learned

**Success criteria:**
- Metric improvement > 10%
- No new failure modes
- Team comfortable with operational model

### Phase 3: Rollout (Week 7+)
**Goal:** Expand to full scope; harden operationally.

**Steps:**
1. Migrate remaining systems
2. Update monitoring and alerting
3. Update runbooks and incident response
4. Train on-call team

**Validation:**
- All monitoring checks passing
- Incident response tested
- Team trained and confident

---

## Risks & Mitigation

### Risk 1: [Primary Risk]
**Description:** What could go wrong?  
**Detection:** How would you notice this problem?  
**Impact:** What breaks if this happens?  
**Mitigation:** How to prevent or recover?  
**Probability:** Low / Medium / High

### Risk 2: [Secondary Risk]
[Repeat above]

### Risk 3: [Tertiary Risk]
[Repeat above]

---

## Cost Implications

### Infrastructure Cost
- **Low scale** (< 1M requests/month): ~$500–1,000/month
- **Medium scale** (1–10M requests/month): ~$2,000–5,000/month
- **High scale** (> 10M requests/month): $10,000+/month

**Drivers:**
- Compute instances (number, size)
- Storage (database, cache)
- Data transfer (inter-region, egress)
- Managed services (premium tier)

### Operational Cost
- **Setup effort:** X engineer-weeks (includes research, implementation, testing)
- **Ongoing maintenance:** X hours/month (monitoring, patching, optimization)
- **Team training:** X hours (onboarding new engineers)

### Migration Cost (If Adopting Existing System)
- **Code refactoring:** X engineer-weeks
- **Data migration:** X hours (downtime, validation)
- **Testing & validation:** X engineer-weeks
- **Cutover:** X hours

### Total Cost of Ownership (12 months)
```
Infrastructure: $X
Operations: $Y
Team: $Z
Training: $W
Total: $(X+Y+Z+W)

Savings vs. current approach: $S/month
Payback period: N months
```

---

## Operational Considerations

### Monitoring & Observability
**What to measure:**
- [Metric 1]: Why it matters, normal range
- [Metric 2]: Why it matters, normal range
- [Metric 3]: Why it matters, normal range

**Alerting thresholds:**
- Alert on [condition] at [threshold]
- Page on-call if [critical condition]

### Incident Response
**Common failure modes:**
1. [Failure A]: Symptoms → Investigation → Resolution
2. [Failure B]: Symptoms → Investigation → Resolution

**Runbook:** [Link to incident response guide]

### Scaling & Performance
- **Horizontal scaling:** How to add more nodes/instances
- **Vertical scaling:** When to upgrade instance size
- **Throttling:** How to handle traffic spikes

---

## Implementation Examples

### Example 1: AWS
```terraform
resource "aws_example" "this" {
  # Configuration for this pattern on AWS
}
```

**Cost:** $X/month (estimated)  
**Deployment time:** X hours

### Example 2: Azure
```terraform
resource "azurerm_example" "this" {
  # Configuration for this pattern on Azure
}
```

**Cost:** $Y/month (estimated)  
**Deployment time:** Y hours

### Example 3: GCP
```terraform
resource "google_example" "this" {
  # Configuration for this pattern on GCP
}
```

**Cost:** $Z/month (estimated)  
**Deployment time:** Z hours

---

## Related Patterns

### Complements This Pattern
- **[Pattern A](link)**: Works well alongside this pattern
- **[Pattern B](link)**: Often used together to solve larger problem

### Alternative Approaches
- **[Pattern C](link)**: Simpler but less scalable
- **[Pattern D](link)**: More complex but more powerful

### Evolution Path
**Natural progression:**
1. Start with [Pattern X]
2. As scale increases, introduce [Pattern Y]
3. At scale, combine with [Pattern Z] for full solution

---

## Decision Checklist

Before adopting this pattern, verify:

- [ ] **Team skills**: Does team have required expertise? If not, budget training
- [ ] **Scale**: Is system actually at scale where this pattern adds value?
- [ ] **Complexity**: Can team handle additional operational burden?
- [ ] **Cost**: Is cost justified by improvement (payback < 12 months)?
- [ ] **Migration**: Is greenfield, or does refactoring have acceptable risk?
- [ ] **Monitoring**: Can you instrument pattern to observe behavior?
- [ ] **Incidents**: Do you have incident response plan for failures?
- [ ] **Alternatives**: Have you considered simpler approaches?

---

## References

### Books & Papers
- [Book/Paper Title](link) — Key insight: X
- [Another Reference](link) — Key insight: Y

### Case Studies
- [Company A Case Study](link) — How they implemented; lessons learned
- [Company B Case Study](link) — Similar problem; different solution

### Open-Source Implementations
- [Project A](link) — Production-ready implementation
- [Project B](link) — Reference implementation

### Provider Resources
- **AWS**: [Service documentation](link)
- **Azure**: [Service documentation](link)
- **GCP**: [Service documentation](link)

---

## Questions for Your Team

Use these questions when discussing whether to adopt this pattern:

1. **Current pain point**: What specific problem are we trying to solve? Can we quantify it?
2. **Scale threshold**: At what scale does this become necessary?
3. **Timeline**: What's the deadline? Is phased adoption feasible?
4. **Team capacity**: Who will implement? Do they have time?
5. **Operational readiness**: Do we have monitoring, alerting, runbooks?
6. **Rollback plan**: If things go wrong, how do we revert?
7. **Success metric**: How will we measure improvement?
8. **Cost/benefit**: Is expected improvement worth the cost?

---

**Last updated:** [Date]  
**Contributor:** [Name]  
**Status:** [Active | Under Review | Deprecated]
