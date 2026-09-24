# Cloud Architecture Patterns Library

**Enterprise design patterns for architecture discovery, modernization planning, and technical diligence.**

This library contains vendor-agnostic patterns useful for assessing existing systems and planning evolution. Each pattern includes:
- **Use cases & when to apply**
- **Architecture diagram (C4 level)**
- **Trade-offs & risks**
- **Implementation considerations**
- **Cost implications**
- **Related patterns**

---

## Pattern Categories

### 🏗️ Structural Patterns (System Organization)

1. **[Monolith-to-Microservices (Strangler Fig)](01-strangler-fig.md)**
   - Safe migration path from monolith to microservices
   - Use when: Need to modernize without disruption
   - Risk: Complexity of running both patterns simultaneously
   - Cost: Higher initially (dual maintenance), lower long-term

2. **[Multi-Tenant Architecture](02-multi-tenant.md)**
   - Share infrastructure across customers with isolation
   - Use when: Building SaaS product or shared platform
   - Risk: Data isolation bugs; noisy neighbor problems
   - Cost: Efficient resource utilization

3. **[Hybrid Cloud Connectivity](03-hybrid-cloud.md)**
   - Connect on-premises infrastructure to cloud
   - Use when: Legacy systems can't move; gradual migration
   - Risk: Network latency; security complexity
   - Cost: Dedicated connectivity lines; VPN overhead

4. **[Service Mesh (Observability & Control)](04-service-mesh.md)**
   - Centralized service communication management
   - Use when: 10+ microservices; need distributed tracing
   - Risk: Operational complexity; performance overhead
   - Cost: Resource overhead; learning curve

### 🔄 Data Flow Patterns (Processing & Movement)

5. **[Event Sourcing & CQRS](05-event-sourcing-cqrs.md)**
   - Immutable event log + separate read/write models
   - Use when: Audit trail required; complex domain logic
   - Risk: Eventual consistency challenges; event schema versioning
   - Cost: More storage; operational complexity

6. **[Data Lake & Analytics Pipeline](06-data-lake.md)**
   - Centralized data repository for analytics
   - Use when: Multiple data sources; analytics + real-time processing
   - Risk: Data governance; schema-on-read confusion
   - Cost: High storage + compute; data transfer

7. **[Saga Pattern (Distributed Transactions)](07-saga-pattern.md)**
   - Coordinate transactions across microservices
   - Use when: Multi-service transactions; compensation logic needed
   - Risk: Cascading failures; partial rollback complexity
   - Cost: Additional orchestration layer

### 🚀 Reliability Patterns (Resilience)

8. **[Circuit Breaker & Resilience](08-circuit-breaker.md)**
   - Fail fast; protect downstream systems
   - Use when: Microservices; external API dependencies
   - Risk: False positives (legitimate timeouts marked as failures)
   - Cost: Low (library-level pattern)

9. **[Database Replication & Sharding](09-replication-sharding.md)**
   - Scale databases; achieve high availability
   - Use when: Single database is bottleneck; need HA
   - Risk: Replication lag; shard hot-spotting
   - Cost: 2–3x infrastructure; operational complexity

10. **[Cache-Aside Pattern](10-cache-aside.md)**
    - Keep frequently accessed data in fast cache
    - Use when: Read-heavy workloads; database is bottleneck
    - Risk: Cache invalidation; stale data
    - Cost: Cache infrastructure (Redis, Memcached)

### 🔐 Operational Patterns (Deployment & Management)

11. **[API Gateway & Rate Limiting](11-api-gateway.md)**
    - Central entry point; traffic control; security
    - Use when: Public APIs; need DDoS protection, auth, rate limits
    - Risk: Gateway becomes bottleneck; single point of failure
    - Cost: API gateway service fee; modest

12. **[Cost Optimization (Reserved Instances, Spot)](12-cost-optimization.md)**
    - Reduce cloud spending via commitment models
    - Use when: Predictable workload; cost is constraint
    - Risk: Commitment lock-in; reduced flexibility
    - Cost: 40–70% savings on compute

---

## How to Use This Library

### For Architecture Discovery Sprints
1. **Identify current patterns** in client's architecture
2. **Map gaps** — which patterns are missing? Which are causing incidents?
3. **Recommend adoption** with explicit trade-offs (risk, cost, effort)
4. **Link to 90-day roadmap** — phased implementation

### For Risk Assessment
- Each pattern includes **common failure modes**
- Use to populate risk register during assessment
- Reference incident patterns from client's history

### For Cost Analysis
- Each pattern includes **cost estimates**
- Compare to client's current spend
- Identify optimization opportunities

### For Team Decisions
- Patterns are **language/provider-agnostic**
- Share with cross-functional teams
- Use to align on architecture decisions

---

## Pattern Template

Each pattern file includes:

```
# [Pattern Name]

## Overview
- **Use when**: Specific problem or constraint
- **Solves**: Core issue addressed
- **Trade-offs**: What you gain vs. lose
- **Typical cost**: Budget impact (low/medium/high)

## Architecture Diagram
- C4 context level (learner → system)
- Key components and interactions
- Data flows

## When to Apply
- Specific use cases
- Anti-patterns to avoid
- Common misconceptions

## Implementation Considerations
- Prerequisites (team skills, existing tech)
- Phasing strategy (how to adopt incrementally)
- Common pitfalls

## Risk & Mitigation
- Primary risks
- How to detect problems
- Mitigation strategies

## Cost Implications
- Infrastructure costs (typical monthly range)
- Operational overhead
- Effort to implement

## Related Patterns
- Patterns that complement this one
- Patterns to consider as alternatives
- Evolution path (what comes next)

## References
- Books, papers, case studies
- Open-source implementations
- Provider-specific resources (AWS, Azure, GCP)
```

---

## Quick Reference: Which Pattern Do I Need?

### "Our database is the bottleneck"
→ [Database Replication & Sharding](09-replication-sharding.md) or [Cache-Aside Pattern](10-cache-aside.md)

### "We need to migrate from monolith without disruption"
→ [Strangler Fig](01-strangler-fig.md)

### "Compliance requires audit trail for all changes"
→ [Event Sourcing & CQRS](05-event-sourcing-cqrs.md)

### "We have data in 10 different systems; can't analyze it"
→ [Data Lake & Analytics Pipeline](06-data-lake.md)

### "One service outage takes down the whole system"
→ [Circuit Breaker & Resilience](08-circuit-breaker.md) or [Service Mesh](04-service-mesh.md)

### "We're paying $50k/month in cloud; need to reduce"
→ [Cost Optimization](12-cost-optimization.md)

### "We need to coordinate transactions across services"
→ [Saga Pattern](07-saga-pattern.md)

### "We want to build SaaS but worried about data isolation"
→ [Multi-Tenant Architecture](02-multi-tenant.md)

### "We have on-prem legacy systems; can't move everything to cloud"
→ [Hybrid Cloud Connectivity](03-hybrid-cloud.md)

### "We can't see what's happening in our microservices"
→ [Service Mesh](04-service-mesh.md) or [API Gateway](11-api-gateway.md)

---

## Contributing New Patterns

To add a pattern:

1. Copy `PATTERN_TEMPLATE.md` → `NN-pattern-name.md`
2. Fill in all sections (see template)
3. Add C4 diagram to `likec4.ts` (link to pattern)
4. Update this index
5. Add references to related patterns
6. Submit PR with consulting use case

---

**Last updated:** 2026-09-23  
**Maintained by:** Mark Alexiuk  
**Status:** Active — 12 core patterns, open to extension
