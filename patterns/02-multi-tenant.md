# Pattern: Multi-Tenant Architecture

**Share infrastructure across customers with strong data isolation and per-tenant operations control.**

---

## The Decision

### Do Use Multi-Tenant When:

- Building a SaaS product or shared platform serving multiple independent customers
- Tenants have different configurations, feature flags, or data retention policies
- Cost efficiency is important (shared infrastructure = lower per-customer cost)
- Tenants require isolation (compliance, competitive sensitivity)

### Do NOT Use When:

- Single large customer ("enterprise deployment" is simpler than multi-tenant)
- Isolation requirement is soft (B2B platform where data sharing is acceptable)
- Real-time shared view across tenants is core feature (defeats isolation)
- Regulatory requires separate infrastructure per customer (Germany, China restrictions)

---

## Quick Comparison: Isolation Models

| Model | Cost | Isolation | Scaling | Ops Complexity |
|-------|------|-----------|---------|-----------------|
| **Separate DB per tenant** | $$$ | ✅ Perfect | ✅ Per-tenant scaling | ⚠️ Schema management 100x |
| **Separate schema per tenant** | $$ | ✅ Very Good | ⚠️ Shared compute limits | ⚠️ Schema migrations complex |
| **Row-level isolation (shared table)** | $ | ⚠️ Software-enforced | ✅ Scales well | ✅ Simplest ops |

**Most common**: Start with row-level isolation; migrate to separate schema if tenant isolation audit fails.

---

## Key Risks & Mitigations

| Risk | Symptom | Mitigation |
|------|---------|-----------|
| **"Noisy neighbor"** — One tenant's queries slow all others | Query latency spikes; other tenants page | Query quotas per tenant; connection pooling; separate read replicas |
| **Data leakage** — Row-level isolation code has bug | Tenant A sees Tenant B's data | Immutable row-level checks; audit queries; regular isolation tests |
| **Tenant A pays $10k/month, must scale separately** | High-value tenant hitting limits | Reserved capacity for enterprise tiers; separate DB cluster |
| **Migration hell** — Moving from row-level to schema isolation | Weeks of planned downtime; schema consistency | Plan isolation model upfront; budget data migration effort |

---

## Evidence to Collect

**Justify adopting multi-tenant if:**
- [ ] Customer count > 10 AND growing (otherwise single-tenant is simpler)
- [ ] Per-customer cost > $5k/month (ROI from shared infrastructure is visible)
- [ ] Compliance/audit requires data isolation (document which regulations)
- [ ] Different tenants need different features/configs
- [ ] SaaS pricing model implemented (per-tenant metrics matter)

**Invalidates multi-tenant:**
- Single large customer (build single-tenant first)
- Real-time data sharing across tenants (defeats isolation)

---

## First 30 Days (Pilot)

**Scope**: One customer; row-level isolation; test isolation rigorously

**Metric**: Query latency p99 < 200ms; zero data leakage in isolation tests

**Stop if**: Noisy neighbor effects (one tenant's queries affect others) OR data leakage found

**Rollback**: Provision single-tenant DB for pilot customer; migrate back

---

## References

- **Multi-tenancy patterns** (Microsoft): Row-level, schema, database isolation models
- **Data leakage risk** (OWASP): Common tenant isolation bugs

---

**Status**: Decision card (skeleton) — ready for elaboration based on client evidence
