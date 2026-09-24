# Pattern: Strangler Fig (Monolith-to-Microservices)

**Safe, incremental migration from monolithic architecture to microservices without taking the system offline.**

---

## Overview

### Problem It Solves
Large monoliths become difficult to:
- Deploy (whole system affected by one bug)
- Scale (can't scale individual features)
- evolve (tight coupling prevents independent velocity)
- staff (new engineers need to understand entire codebase)

The "big bang" rewrite is risky. **Strangler Fig** lets you gradually replace monolith components with microservices.

### When to Use
- ✅ Monolith exists and is hard to change
- ✅ Specific high-load or high-change components identified
- ✅ Team understands distributed systems
- ✅ Willing to run dual architecture temporarily (6–18 months)
- ✅ Budget for increased operational complexity

### When NOT to Use
- ❌ Monolith is only 50k LOC and working fine (simpler to refactor)
- ❌ Team lacks distributed systems experience
- ❌ Need all-or-nothing migration in 3 months (not realistic)
- ❌ Monolith serves < 10M requests/month (ROI too low)

### Trade-Offs Summary

| Aspect | Gain | Loss |
|--------|------|------|
| **Delivery velocity** | ✅ Individual teams ship independent services | ❌ Debugging cross-service issues is harder |
| **Scalability** | ✅ Scale specific features independently | ❌ Distributed tracing overhead |
| **Operational complexity** | ❌ Running 2 architectures simultaneously | ✅ Cleaner long-term (once complete) |
| **Cost** | ❌ Higher during transition (dual infrastructure) | ✅ Can retire monolith infrastructure after |
| **Risk** | ✅ Gradual migration = lower risk per step | ❌ Risk of getting stuck halfway |

---

## Architecture Diagram

### C4 Context Level

```
┌─────────────────────────────────────────────────────────────┐
│  Users / Clients                                            │
└──────────────────┬──────────────────────────────────────────┘
                   │ HTTP/REST
        ┌──────────▼──────────┐
        │  API Gateway (New)  │
        │  - Routes requests  │
        │  - Auth, logging    │
        └──────┬───────┬──────┘
               │       │
        ┌──────▼─┐   ┌─▼──────────────┐
        │        │   │                │
    ┌───┴──────┐ │   │  ┌────────────┐│
    │ Monolith │ │   │  │ Service A  ││ (New microservice)
    │ (Shrinking)   │  │ (Extracted) ││
    │          │ │   │  └────────────┘│
    └──────────┘ │   │                │
                 │   │  ┌────────────┐│
                 │   │  │ Service B  ││ (New microservice)
                 │   │  │ (Extracted) ││
                 │   │  └────────────┘│
                 │   │ Microservices  │
                 │   └────────────────┘
                 │
        ┌────────▼────────┐
        │  Shared Data    │
        │  - Database     │
        │  - Cache        │
        │  - Message Q    │
        └─────────────────┘
```

**Key insight:** API Gateway acts as facade, routing some requests to new microservices, others to shrinking monolith. Over time, monolith handles less.

### Phase Progression

**Phase 0 (Current):** 100% monolith  
**Phase 1 (Month 3):** Monolith 90%, Service A 10%  
**Phase 2 (Month 6):** Monolith 70%, Services A,B,C 30%  
**Phase 3 (Month 12):** Monolith 20%, Services 80%  
**Phase 4 (Month 18):** Monolith <5% (retire, keep for legacy compatibility if needed)

---

## When to Apply This Pattern

### Prerequisites
- **Team skills**: Experience with distributed systems, async communication, eventual consistency
- **Technology stack**: API Gateway (Kong, AWS API Gateway, nginx), message queue (RabbitMQ, SQS), monitoring
- **Scale threshold**: Typically makes sense at 10M+ requests/month or > 100 engineers

### Do NOT Use This Pattern When:

- **Requests cannot be intercepted or routed** — If there's no way to intercept traffic and route some to services and some to monolith, Strangler Fig is impossible.
- **Source code is not available for modification** — You must be able to modify the monolith to redirect internal calls to new services. If it's a third-party binary or you have no source access, this pattern doesn't work.
- **The monolith is small enough to replace directly** — If it's < 50k LOC and relatively cohesive, a bounded rewrite may be faster and cheaper than gradual extraction.
- **Organization cannot fund parallel operation** — If budget won't support running both monolith and services simultaneously for 12–18 months, you'll get stuck halfway.
- **Leadership demands immediate full decommissioning** — If the requirement is "retire monolith by Q3," the gradual approach will not meet that timeline.
- **The real problem is organizational, not architectural** — If the blocker is unclear ownership, competing product priorities, or unclear requirements, Strangler Fig won't help. Fix the org problem first.

### Problem Indicators (Does Your Monolith Have These?)

- [ ] **Deployment frequency < 1x/week** (because risk of monolith changes is high)
- [ ] **New features take 3+ weeks** (because tight coupling requires touching multiple modules)
- [ ] **One bug takes down whole system** (lack of circuit breakers; tight coupling)
- [ ] **Database scaling is bottleneck** (monolith can't partition data)
- [ ] **New engineers take 4+ weeks to be productive** (codebase too large/complex)
- [ ] **Incident mean time to resolution > 1 hour** (hard to debug complex monolith)
- [ ] **On-call is burning people out** (too many pages; no circuit breaking)

### Common Misconceptions
- **Misconception:** "Microservices will make us faster immediately" → **Reality:** First 6 months, velocity drops (learning curve, coordination overhead)
- **Misconception:** "We should extract 20 microservices at once" → **Reality:** Start with 1–2, prove the pattern, then scale
- **Misconception:** "We can keep the monolith database" → **Reality:** Each service needs data autonomy; will require data migration

---

## Implementation Strategy

### Phase 1: Preparation (Week 1–4)
**Goal:** Understand monolith structure; identify first extraction candidate.

**Steps:**
1. **Map monolith components**
   - Which modules handle which features?
   - What are data/API dependencies?
   - Where are the hot spots (high change, high load)?

2. **Choose extraction candidate**
   - Pick feature with: High change velocity + Low coupling to rest of monolith
   - NOT first choice: Hot, tightly coupled feature
   - GOOD choice: Payment processing, user authentication, reporting service

3. **Design API Gateway**
   - What will route requests to monolith vs. services?
   - How will auth work across dual systems?
   - Logging, tracing, rate limiting strategy?

4. **Plan data migration**
   - Shared database first (both read from same DB)
   - Later: Separate databases per service (with eventual consistency)

**Deliverables:**
- Monolith dependency diagram
- First extraction candidate + rationale
- API Gateway design
- 18-month phasing plan

### Phase 2: Extract First Service (Month 1–2)
**Goal:** Prove pattern works; learn operational nuances.

**Steps:**
1. **Build Service A** (extracted feature)
   - Implement independently, separate codebase
   - Read from shared database initially
   - Implement circuit breaker for calls back to monolith

2. **Route traffic through API Gateway**
   - 10% of requests → Service A
   - 90% → Monolith
   - Monitor latency, error rate, cost

3. **Test thoroughly**
   - Failover: What if Service A is down?
   - Coordination: If both monolith and service write to DB, what happens?
   - Rollback: Can we quickly revert to 100% monolith?

4. **Operate for 2 weeks**
   - On-call team learns new operational model
   - Document incidents, surprises
   - Measure: latency, error rate, cost

**Success criteria:**
- Service A latency < 50ms (including network hop through API Gateway)
- Error rate < 0.1%
- Cost increase < 15% (temporary overhead is normal)
- Team confident in rollback

**Deliverables:**
- Operational Service A
- Incident runbook (what to do if Service A fails)
- Tracing/monitoring dashboard
- Lessons learned document

### Phase 3: Gradual Traffic Shift (Month 3–6)
**Goal:** Increase Service A to 30–50% of traffic; start extracting Service B.

**Steps:**
1. **Increase traffic to Service A**
   - Week 1: 30% of requests
   - Week 2: 50%
   - Week 3: 70%
   - Monitor at each step for issues

2. **Monitor for problems**
   - Database locks / contention (both writing to same tables)
   - Cascading failures (if Service A is down, can monolith handle 100% load?)
   - Cost creep (temporary infrastructure overhead)

3. **Extract Service B**
   - Repeat same process: Build independently, route initial 10% traffic
   - Now both services share database initially

4. **Plan data separation**
   - As services mature, each gets own database
   - Implement event-driven sync if needed (Service A event → Service B reads)

**Deliverables:**
- Service A at 70% traffic, Service B at 20%
- Updated runbooks and dashboards
- Monolith shrinking (30% less code to maintain)

### Phase 4: Scale Services (Month 7–12)
**Goal:** Migrate 80% of monolith functionality to services.

**Steps:**
1. **Continue extracting services**
   - Services C, D, E, F based on priority
   - Each follows same pattern: independent build → gradual traffic shift

2. **Decouple from shared database**
   - Service A gets its own DB
   - Monolith → Service A no longer share schema
   - Implement eventual consistency (events, webhooks, polling)

3. **Harden operational model**
   - Distributed tracing across all services
   - Unified monitoring (metrics, logs, traces)
   - Incident response for cross-service failures

4. **Plan monolith retirement**
   - What stays in monolith? (Legacy systems, low-priority features)
   - How long to keep monolith running for backward compatibility?

**Deliverables:**
- 80% of features in microservices
- Monolith in "maintenance mode" (no new features)
- Comprehensive observability across services
- Team trained on distributed systems operations

### Phase 5: Complete & Retire (Month 13–18)
**Goal:** Finish migration; retire monolith (or maintain as legacy system).

**Steps:**
1. **Migrate remaining 20% of features**
   - Low-priority features or truly intractable code

2. **Final data migration** (if any shared DB remains)
   - Each service owns its data
   - No shared schema access

3. **Retire monolith infrastructure**
   - Stop running old deployment
   - Archive code
   - Document any remaining backward-compatibility hooks

4. **Post-migration review**
   - Lessons learned
   - Cost analysis (actual vs. estimated)
   - Team morale check (did this help or hurt?)

**Deliverables:**
- Production microservices architecture
- Decommissioned monolith
- Post-migration case study

---

## Risks & Mitigation

### Risk 1: Distributed System Complexity
**Description:** Microservices introduce new failure modes (network, partial outages, eventual consistency) that team may not be prepared for.

**Detection:**
- Incident frequency increases
- Mean time to resolution increases
- Team expressing frustration

**Impact:**
- Productivity actually decreases during transition
- Developers slower to debug cross-service issues
- On-call burden increases

**Mitigation:**
- **Invest in team training** (courses, workshops on distributed systems)
- **Implement circuit breakers** (fail fast, protect downstream)
- **Comprehensive monitoring** (distributed tracing, correlation IDs)
- **Start small** (1 service, 2 months of operation before second)
- **Have rollback plan** (if monolith still has capacity, easy to revert)

**Probability:** High (happens in ~80% of monolith-to-microservices migrations if underestimated)

---

### Risk 2: Dual System Overhead (Cost & Complexity)
**Description:** Running both monolith and microservices simultaneously is expensive. Infrastructure costs increase 20–40% during transition.

**Detection:**
- Monthly cloud bill increases unexpectedly
- API Gateway becoming bottleneck
- Database under increased load (both systems hitting same tables)

**Impact:**
- Budget overrun
- Delay full transition (to reduce costs)
- Performance degradation

**Mitigation:**
- **Plan for temporary cost increase** (budget 1.5x normal spend for 6 months)
- **Identify quick wins** (retire lowest-value monolith components first)
- **Database optimization** (indices, query tuning for dual-read patterns)
- **Use spot/reserved instances** where possible to reduce compute cost

**Probability:** High (virtually guaranteed if not planned)

---

### Risk 3: Data Consistency Issues
**Description:** Monolith and services writing to shared database creates race conditions, inconsistency, or cascading failures.

**Detection:**
- Data corruption incidents
- Cascading failures (one writer locks the table)
- Eventual consistency bugs (service reads stale data)

**Impact:**
- Data loss or corruption
- System downtime
- Compliance/audit trail issues

**Mitigation:**
- **Start with read-only services** (service reads from shared DB, monolith still writes)
- **Implement saga pattern** (distributed transactions with compensation logic)
- **Use event log** (immutable log of all changes; both systems read/write)
- **Plan data separation early** (monolith → Service A copy (event-driven) → Service A owns data)

**Probability:** Medium (if not careful with data access patterns)

---

### Risk 4: Incomplete Migration (Stuck Halfway)
**Description:** Extraction stalls at 50% complete; organization runs dual systems indefinitely.

**Detection:**
- No new services extracted in 3+ months
- Priority shifts; migration work deprioritized
- Budget runs out

**Impact:**
- Never realize benefits (velocity, scalability)
- Increased cost indefinitely
- Team frustration ("we spent all that effort for what?")

**Mitigation:**
- **Strong executive sponsorship** (CEO/CTO backs initiative; resources protected)
- **Dedicated team** (don't split engineers across BAU and migration)
- **Clear timeline & milestones** (commit to completion by Month X)
- **Regular reviews** (monthly checkpoint: are we on track?)
- **Define "done"** (what % microservices = migration complete?)

**Probability:** Medium-High (happens if migration not treated as strategic priority)

---

## Cost Implications

**⚠️ Illustrative planning model — not a quote or forecast.**

Actual costs depend heavily on team composition, existing infrastructure maturity, scope, and delivery model. Use the ranges and drivers below to build your own estimate for your context.

### Assumptions

- **Team size**: 4–6 person delivery team (1 FTE architect, 2–3 engineers, 1 infrastructure, 1 QA)
- **Baseline**: Existing CI/CD, monitoring, and load-testing infrastructure in place
- **Scope**: One bounded business domain / application (not entire monolith)
- **Constraints**: No data-center exit, no regulatory migration, no hard deadline pressure
- **Blended delivery rate**: $150–200/hour (varies by geography, seniority)

### Infrastructure Cost (Illustrative Model)

| Phase | Timeline | Monolith | Services | Total | Change | Rationale |
|-------|----------|----------|----------|-------|--------|-----------|
| **Current** | Baseline | $8–15k/mo | $0 | $8–15k/mo | — | Depends on scale, region |
| **Phase 1** | Mo 1–2 | $8–15k | $1–3k | $9–18k | +10–20% | API Gateway + 1 service |
| **Phase 2** | Mo 3–6 | $6–12k | $4–8k | $10–20k | +20–40% (peak) | Dual infrastructure at max |
| **Phase 3** | Mo 7–12 | $2–6k | $8–14k | $10–20k | +10–20% | Monolith shrinking |
| **Phase 4** | Mo 13–18 | $0–2k | $12–18k | $12–20k | +10–20% | Monolith retired |

**Key cost drivers** (can shift ranges significantly):
- **Region**: EU/APAC 30–50% higher than US
- **Data transfer**: Inter-service communication, cross-region replication
- **Database duplication**: How long do both systems share DB? (affects peak cost)
- **Managed services**: Fully managed (RDS, Aurora, Lambda) vs. self-hosted (EC2, Postgres)
- **Traffic volume**: 10M req/mo vs. 1B req/mo changes infrastructure 100x

### Delivery Effort

| Category | Low Estimate | Expected | High Estimate | Notes |
|----------|-------------:|----------:|---------------:|-------|
| **Planning & design** | 2 wks | 4 wks | 8 wks | If monolith understood; unclear if not |
| **Infrastructure setup** | 1 wk | 2 wks | 4 wks | API Gateway, monitoring, CI/CD integration |
| **Extract Service 1** | 4 wks | 6 wks | 12 wks | Proof-of-concept; includes testing, docs |
| **Extract Services 2–5** | 3 wks each | 4 wks each | 6 wks each | Faster after pattern established |
| **Data strategy** | 2 wks | 3 wks | 6 wks | Schema separation, eventual consistency |
| **Operations & runbooks** | 2 wks | 4 wks | 8 wks | Incident response, scaling, failover |
| **Monitoring & tracing** | 2 wks | 3 wks | 6 wks | Distributed tracing, correlation IDs |
| **Team training** | 2 wks | 3 wks | 5 wks | Microservices concepts, deployment, incidents |
| **Total** | **20–22 wks** | **31–33 wks** | **55–60 wks** | Equivalent to 5–15 months with 1 FTE |

### Total 18-Month Program Cost (Illustrative)

Using **expected case** with $160/hour blended rate:

```
Delivery effort (33 weeks × 40 hrs/wk × $160): $211k
Infrastructure delta:
  - Months 1–6 peak overhead (+$5–10k/mo): $45k
  - Months 7–18 (+$2–5k/mo): $36k
  - Subtotal: $81k
Tools & licenses (monitoring, API Gateway): $15k
Training & consulting (if external): $0–30k

Subtotal: $307–337k (delivery + infrastructure peak)

Savings post-migration:
  - Monolith infrastructure (retire after 18mo): -$8–15k/mo × 18 = -$144–270k
  - Operational efficiency (faster deployments, less on-call): ~$50–100k/year
```

**Payback**: 12–24 months after full migration, assuming:
- Realized velocity improvement (deployment frequency 2x)
- Reduced on-call burden (team retention)
- Faster feature delivery (time-to-market)

### Sensitivity Analysis

**What could double the cost?**
- Tight coupling in monolith (data extraction takes 2x effort)
- Unclear ownership of features (investigation overhead)
- Shared database not changeable (creates consistency bottleneck)
- Organization changes mid-program (re-planning, scope creep)

**What could halve the cost?**
- Very clean monolith (clear module boundaries)
- Experienced team (not learning microservices patterns)
- Scope limited to 1–2 high-value services (not full migration)
- Existing API Gateway in place (reduce setup)

---

### Decision Framework

**Use this cost model to ask:**
- Does the expected benefit (velocity, scalability, retention) exceed the program cost for our organization?
- Do we have team stability to sustain 18-month delivery?
- Can we tolerate 12–18 months before ROI?
- Is the business case strong enough to protect budget and people?

---

## Operational Considerations

### Monitoring & Observability

**Metrics to track:**
- **Latency (p50, p99)**: Should be < 50ms overhead for service calls
- **Error rate**: Should be < 0.1% for normal operation
- **Circuit breaker state**: How often are services rejected as unhealthy?
- **Database contention**: Lock wait times, slow queries
- **Cost per request**: Track cost impact of dual infrastructure

**Alerting:**
- Page on-call if Service latency > 500ms
- Page if error rate > 1%
- Alert if monthly cost increase > 10% (unexpected)

### Incident Response

**Common failure modes:**

1. **Service A is down**
   - Symptoms: 500ms+ latency for affected feature; error rate spikes
   - Recovery: API Gateway fallback to monolith (should be automatic)
   - Runbook: [Link to Service A incident response]

2. **Database deadlock** (both monolith and service writing)
   - Symptoms: Cascading failures across both systems
   - Recovery: Kill long-running query; restart affected service
   - Runbook: [Database incident response]

3. **API Gateway is bottleneck**
   - Symptoms: All requests slow; latency increases globally
   - Recovery: Scale API Gateway horizontally; load balance
   - Runbook: [API Gateway scaling]

---

## Evidence to Collect (During Discovery)

### What System Evidence Would Justify This Pattern?

- **Deployment frequency**: How often can you currently deploy? (goal: 2–5x/week via services)
- **Incident mean time to recovery (MTTR)**: Current MTTR for monolith bugs vs. target for services
- **Time-to-feature**: How long from PR to production? (goal: reduce from weeks to days)
- **Feature coupling data**: How many components must change for a single feature?
- **Database contention**: Are database locks/deadlocks causing incidents?
- **On-call burden**: How many pages/week? Target reduction with circuit-breaker isolation?

### What Would Invalidate This Pattern?

- Small monolith (< 50k LOC) — Replace, don't extract
- No API request entry point — Can't intercept and route
- Lack of budget — Can't afford 12–18 months of dual infrastructure
- Organizational blockers — Unclear ownership, competing priorities

---

## Decision Threshold

**Fund a Pilot if:**

- [ ] Monolith > 100k LOC with > 5 loosely-coupled domains
- [ ] Deployment blocked by risk (one bug can crash whole system)
- [ ] On-call burden > 10 pages/week OR MTTR > 1 hour
- [ ] Team has distributed systems experience (or budget for training)
- [ ] Budget approved for 12–18 month dual-infrastructure period
- [ ] First extraction candidate identified (low-coupling, high-change-velocity feature)

**Do NOT fund if:**

- Any "Do NOT Use" condition above is true
- Monolith is < 50k LOC (recommend bounded rewrite instead)
- Organization cannot commit 12+ months
- Team lacks distributed systems experience AND cannot hire/train

---

## First 30 Days (Pilot Design)

**Objective**: Extract one service; prove operability; learn cost reality.

**Owner**: Lead architect + 1 engineer (part-time)

**Scope**: One extraction candidate (e.g., user authentication, reporting, payment service)

**Metric**: Service A handling 10–20% of traffic; latency < 100ms (including API Gateway hop)

**Stop Condition**: Circuit opens or latency > 500ms for > 1 minute → rollback to 100% monolith

**Rollback Plan**: API Gateway routes 100% to monolith; Service A stops; verify monolith handles full load

---

## Decision Checklist

Before committing to Strangler Fig:

- [ ] **Scale justifies it**: System handling 10M+ requests/month (or equivalent complexity)
- [ ] **Team ready**: Have 1–2 engineers with distributed systems experience
- [ ] **Budget approved**: 18-month commitment; cost increase understood
- [ ] **Executive support**: CTO/CEO committed; resources protected
- [ ] **Clear candidate**: First service extraction identified and scoped
- [ ] **Rollback plan**: Can we revert to 100% monolith if needed?
- [ ] **Success metrics**: Defined how we'll measure "complete" and "successful"
- [ ] **Alternatives considered**: Scaling monolith, simpler refactoring?

---

## References

### Books & Papers
- **"Building Microservices" by Sam Newman** — Strangler Fig pattern explained
- **"Release It!" by Michael Nygard** — Distributed systems resilience patterns

### Case Studies
- **Etsy's monolith-to-microservices** (https://www.etsy.com/codeascraft)
- **Uber's transition to microservices** (https://eng.uber.com/building-uber-engineering-efficiency-with-apache-flink/)

### Open-Source
- **Kong API Gateway** (https://konghq.com/) — Popular API Gateway choice
- **Traefik** (https://traefik.io/) — Lightweight reverse proxy for microservices

### Tools
- **Distributed tracing**: Jaeger, Zipkin
- **API Gateway**: Kong, AWS API Gateway, nginx Plus, Traefik
- **Message Queue**: RabbitMQ, Apache Kafka, AWS SQS

---

**Last updated:** 2026-09-23  
**Status:** Active — Common pattern in architecture discovery assessments  
**Used in:** Technical diligence sprints for monolith-heavy organizations
