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

### Infrastructure Cost (18-month migration)

| Phase | Timeline | Monolith | Services | Total | Change |
|-------|----------|----------|----------|-------|--------|
| **Current** | Now | $10k/mo | $0 | $10k/mo | Baseline |
| **After Phase 1** | Mo 2 | $10k | $2k | $12k | +20% |
| **After Phase 2** | Mo 6 | $8k | $6k | $14k | +40% (peak overhead) |
| **After Phase 3** | Mo 12 | $3k | $8k | $11k | +10% |
| **After Phase 4** | Mo 18 | $1k | $10k | $11k | +10% |

**Key drivers:**
- Dual infrastructure (both running simultaneously)
- API Gateway, monitoring, logging overhead
- Database replication (while sharing schema)
- Messaging infrastructure (for eventual consistency)

### Operational Cost

| Category | Effort |
|----------|--------|
| **Planning & design** | 4 engineer-weeks |
| **Infrastructure setup** | 2 engineer-weeks |
| **Extract first service** | 6 engineer-weeks |
| **Extract services 2–5** | 4 weeks × 4 services = 16 engineer-weeks |
| **Operations & runbooks** | 8 engineer-weeks |
| **Monitoring & tracing** | 6 engineer-weeks |
| **Team training** | 4 engineer-weeks |
| **Total** | ~50 engineer-weeks (12 months, 1 FTE) |

### Total 18-Month Cost

```
Infrastructure delta: $14k × 6 months (peak) + $11k × 12 months (reduced) = $216k
Operations (50 weeks × $150/hour): $600k @ senior engineer rate
Tools (API Gateway, monitoring, etc.): $20k
Training: $10k

Total: ~$850k

Annual benefit (velocity, scalability): $500k–2M (depends on organization)
Payback period: 6–18 months after completion
```

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
