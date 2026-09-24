# Pattern: Circuit Breaker & Resilience

**Fail fast; protect downstream systems from cascading failures caused by dependency outages.**

---

## Overview

### Problem It Solves
When Service A calls Service B and Service B becomes slow/down:
- ❌ Service A threads pile up waiting for B's response
- ❌ Thread pool exhausted
- ❌ Service A becomes slow/down too
- ❌ Cascading failure: entire system collapses

**Circuit Breaker** prevents this by:
- ✅ Failing fast (don't wait for slow dependency)
- ✅ Limiting retries (don't hammer slow service)
- ✅ Enabling graceful degradation (return cached/default value)
- ✅ Protecting downstream (slow service can recover)

### When to Use
- ✅ Service calls external APIs or microservices
- ✅ Cannot afford thread/connection pool exhaustion
- ✅ Need sub-second timeout enforcement
- ✅ High concurrency (100+ concurrent requests)

### When NOT to Use
- ❌ Single monolith (no external dependencies)
- ❌ Synchronous work without parallelism (circuit breaker overhead > benefit)
- ❌ Very low volume (< 1 req/sec) where failures are rare

### Trade-Offs Summary

| Aspect | Gain | Loss |
|--------|------|------|
| **Latency** | ✅ Fail fast instead of timeout wait | ❌ Slightly higher latency (circuit state check) |
| **Reliability** | ✅ Cascading failures prevented | ❌ Temporary degradation (circuit open) |
| **Complexity** | ❌ More operational states to manage | ✅ Simple library implementation |
| **Cost** | ✅ Low (library pattern) | ❌ Slightly more CPU for state management |

---

## Architecture Diagram

### C4 Context Level

```
┌──────────────────────────────────────────────────┐
│  User Request                                    │
└──────────────┬───────────────────────────────────┘
               │
        ┌──────▼──────────────┐
        │  Service A          │
        │  (with Circuit Br.) │
        └──────┬──────────────┘
               │
        ┌──────▼──────────────┐
        │  Circuit Breaker    │
        │  State: [CLOSED]    │
        │  ├─ CLOSED: Normal  │
        │  ├─ OPEN: Fail fast │
        │  └─ HALF-OPEN: Test│
        └──────┬──────────────┘
               │ (Calls)
        ┌──────▼──────────────┐
        │  Service B          │
        │  (External API /    │
        │   Microservice)     │
        └─────────────────────┘
```

### Circuit Breaker States

```
CLOSED (Normal)
  └─ Failure count exceeds threshold (e.g., 5 failures)
     └─ OPEN (Fail fast)
        └─ Timeout expires (e.g., 30 seconds)
           └─ HALF-OPEN (Test if recovered)
              ├─ Successful request
              │  └─ CLOSED (Resume normal)
              └─ Failed request
                 └─ OPEN (Failure confirmed, try again later)
```

---

## When to Apply This Pattern

### Prerequisites
- **Technology stack**: Circuit breaker library (Hystrix, Resilience4j, Polly, PyBreaker)
- **Monitoring**: Can track circuit breaker state transitions
- **Team knowledge**: Understand failure modes, timeout tuning

### Problem Indicators (Does Your System Have These?)

- [ ] **Cascading failures**: One slow service takes down whole system
- [ ] **Thread pool exhaustion**: "Thread deadlock; system unresponsive"
- [ ] **Incident recovery slow**: Dependent service recovers but parent remains hung
- [ ] **No timeout enforcement**: Requests wait indefinitely for hung dependencies
- [ ] **Thundering herd**: Recovery causes retry storm, re-crashes recovered service

### Common Misconceptions
- **Misconception:** "Circuit breaker solves performance issues" → **Reality:** It prevents cascading failures, doesn't fix root cause
- **Misconception:** "Set timeout = RTT + 100ms" → **Reality:** Timeouts must account for percentile latency (p99, not p50)
- **Misconception:** "Open circuit = bad" → **Reality:** Open circuit = protecting system; perfectly normal

---

## Implementation Strategy

### Phase 1: Identify Critical Dependencies (Week 1–2)
**Goal:** Find services/APIs that can cause cascading failures if slow.

**Steps:**
1. **Map dependency graph**
   - Which external services does yours call?
   - For each: How many concurrent requests? What's average latency?
   - Which would cause customer-visible impact if slow?

2. **Identify failure risk**
   - External API (vendor, no SLA) = HIGH risk
   - Internal microservice (team owns) = MEDIUM risk
   - Local database call = LOW risk

3. **Prioritize**
   - Start with HIGH risk dependencies
   - Focus on critical user paths (login, checkout, core feature)

**Deliverables:**
- Dependency map with risk scoring
- List of 3–5 critical dependencies to protect

### Phase 2: Implement for 1 Dependency (Week 3–6)
**Goal:** Prove pattern works; tune parameters; learn operational model.

**Steps:**
1. **Choose circuit breaker library**
   - **Java/Kotlin**: Hystrix, Resilience4j
   - **Python**: PyBreaker, Tenacity
   - **Go**: Gobreaker
   - **Node**: Opossum
   - Recommendation: Pick mature library with good monitoring

2. **Wrap critical dependency call**
   ```python
   from pybreaker import CircuitBreaker

   breaker = CircuitBreaker(
       fail_max=5,           # Open circuit after 5 failures
       reset_timeout=60,     # Try again after 60 seconds
       listeners=[...]       # Notify on state changes
   )

   def call_external_api():
       try:
           return breaker.call(external_api.get_data)
       except CircuitBreakerListener:
           return cached_data()  # Graceful degradation
   ```

3. **Tune parameters**
   - **fail_max**: How many failures before opening? (5–10 typical)
   - **reset_timeout**: How long before testing recovery? (30–60 sec typical)
   - **expected_exception**: What counts as failure? (timeout, 5xx, not 4xx)
   - **success_threshold**: How many successful calls in HALF-OPEN before closing? (2–5)

4. **Test failure scenarios**
   - Kill dependency service
   - Make dependency artificially slow
   - Verify circuit opens; system degrades gracefully
   - Verify recovery works when dependency recovers

5. **Monitor & measure**
   - Circuit breaker state transitions (CLOSED → OPEN → HALF-OPEN → CLOSED)
   - Requests rejected (because circuit open)
   - Graceful degradation success rate (did fallback work?)

**Deliverables:**
- Working circuit breaker for 1 critical dependency
- Monitoring dashboard showing circuit state
- Incident runbook for circuit breaker failures
- Operational parameters documented

### Phase 3: Expand to All Critical Dependencies (Month 2–3)
**Goal:** Apply pattern across all risky external calls.

**Steps:**
1. **Wrap remaining HIGH-risk dependencies**
   - Same pattern: fail_max, reset_timeout, monitoring
   - Tune parameters per dependency (external API vs. internal service)

2. **Implement fallbacks**
   - For each wrapped call: what's the fallback? (cache, default, null)
   - Make fallback explicit in code

3. **Standardize monitoring**
   - Unified dashboard showing state of all circuit breakers
   - Alert on unusual patterns (circuit open for > 5 min)

4. **Document expectations**
   - What % open circuit is acceptable? (1% typical during incidents)
   - What does open circuit mean for customers? (degraded feature, not down)

**Deliverables:**
- All critical dependencies protected
- Unified monitoring & alerting
- Runbook for various circuit breaker states

### Phase 4: Observe & Tune (Ongoing)
**Goal:** Refine parameters based on real behavior.

**Steps:**
1. **Collect metrics**
   - When does circuit actually open? (compare predicted vs. actual)
   - Are timeouts too aggressive or too lenient?
   - Are fallbacks actually used, and do they work?

2. **Adjust parameters**
   - If circuit opens too often (false positives): increase fail_max or reset_timeout
   - If circuit doesn't open when it should (missing failures): lower fail_max or reduce timeout
   - Quarterly review with on-call team

3. **Evolve graceful degradation**
   - Start: return null / cache data
   - Mature: return degraded version of feature (lighter response, no ads, etc.)

---

## Risks & Mitigation

### Risk 1: False Positives (Circuit Opens When Shouldn't)
**Description:** Temporary latency spike or transient failure triggers circuit breaker unnecessarily.

**Detection:**
- Circuit opens frequently (multiple times/hour)
- No actual downstream failure
- Customer-visible degradation without real issue

**Impact:**
- Unnecessary feature degradation
- Customer frustration
- On-call team noise (false alerts)

**Mitigation:**
- **Tune fail_max higher** (maybe issue is 1–2 transient failures, not 5)
- **Use adaptive timeouts** (if p99 latency is 100ms, timeout = 200ms, not 50ms)
- **Exclude transient failures** (network timeouts != 500 errors; separate handling)
- **Canary deployment** (deploy with high fail_max, tune down after week of observation)

**Probability:** High if timeouts not tuned correctly

---

### Risk 2: Cascading Open Circuits
**Description:** If Circuit A opens, retry storm from callers causes Circuit B to open, etc.

**Detection:**
- Multiple circuit breakers open simultaneously
- Retry avalanche (logs show 1000x normal request volume)
- System cascading failure despite circuit breaker

**Impact:**
- Entire system degradation
- Circuit breakers don't prevent cascade (only delay it)

**Mitigation:**
- **Implement exponential backoff** (don't retry immediately)
- **Use bulkheads** (limit thread pool per dependency; prevent starving other services)
- **Timeout hierarchy** (ensure parent timeout > child timeout)
- **Fallback that doesn't retry** (if circuit open, don't call again; use cache instead)

**Probability:** Medium (if multiple dependent services and poor timeout tuning)

---

### Risk 3: Stale Cache in Degraded Mode
**Description:** When circuit opens, service returns cached data that's obsolete (hours/days old).

**Detection:**
- Customer complaints about stale data
- Audit/compliance issues (old data returned as current)

**Impact:**
- Data consistency issues
- Compliance violations (if data should be fresh)
- Loss of user trust

**Mitigation:**
- **Cache TTL management** (cache data with expiration; return error if cache expired)
- **Versioning** (cache includes timestamp; inform user "this data is X hours old")
- **Feature flagging** (feature disabled entirely if cache > X hours old, rather than serving stale)
- **Write-through caching** (user writes bypass circuit breaker)

**Probability:** Medium (if not thought through)

---

## Cost Implications

### Infrastructure Cost
**Circuit breaker is library-level pattern**: ~$0 additional infrastructure cost.

### Operational Cost
| Task | Effort |
|------|--------|
| **Identify dependencies** | 1 engineer-week |
| **Implement for 1 service** | 1 engineer-week |
| **Expand to all dependencies** | 2 engineer-weeks |
| **Monitoring & dashboards** | 1 engineer-week |
| **Team training** | 1 engineer-week |
| **Ongoing: tuning & review** | 4 hours/month |
| **Total** | ~6 engineer-weeks + 2 hours/month |

### Cost/Benefit
```
Implementation cost: 6 weeks @ $150/hour = $36k
Prevented downtime (first year): 1–2 incidents × $50k/incident = $100k
Operational improvement: faster recovery, less on-call noise = invaluable

ROI: Positive within first incident prevented
```

---

## Operational Considerations

### Monitoring & Observability

**Metrics to track:**
- **Circuit breaker state**: CLOSED (normal), OPEN (degraded), HALF-OPEN (testing recovery)
- **Requests rejected**: Count of requests failed due to open circuit
- **Fallback usage**: How often is fallback used?
- **Dependency latency**: Actual p50, p99 latency of dependency
- **Circuit transitions**: How often does circuit open/close? (should be rare; ~1–2x/month)

**Alert on:**
- Circuit OPEN for > 5 min (indicates real issue)
- Fallback requests increasing (dependency degrading)
- Circuit thrashing (opening/closing multiple times/hour)

### Incident Response

**Scenario 1: Circuit opens, dependency slow/down**
- Symptoms: Feature degraded; circuit breaker metric shows OPEN
- Investigation: Is dependency actually slow/down? Check its metrics
- Resolution: Either (a) wait for dependency to recover + circuit auto-closes, or (b) manually trigger dependency rollback
- Runbook: [Dependency incident response]

**Scenario 2: Circuit opens, no actual dependency issue**
- Symptoms: Circuit open; metrics show fallback usage; but dependency is healthy
- Root cause: Circuit parameters mis-tuned (timeout too aggressive, fail_max too low)
- Resolution: Adjust parameters; retune based on observed latency
- Runbook: [Circuit breaker tuning]

**Scenario 3: Cascading open circuits**
- Symptoms: Multiple circuit breakers open simultaneously; system degraded
- Root cause: Usually dependency chain problem (A calls B calls C, C slow)
- Resolution: Identify root cause (usually C), fix C
- Runbook: [Cascading failure diagnosis]

---

## Decision Checklist

- [ ] **Dependency is external or risky**: External API or microservice with uncontrolled SLA
- [ ] **High concurrency**: Service handles 100+ concurrent requests
- [ ] **Cascading failure risk**: If dependency slow, does whole system slow?
- [ ] **Library available**: Circuit breaker library exists for our language/framework
- [ ] **Monitoring in place**: Can track circuit state and request metrics
- [ ] **Fallback strategy**: Defined what service does when circuit is open
- [ ] **Parameters tuned**: fail_max, reset_timeout, timeout chosen based on actual metrics
- [ ] **Tested**: Verified circuit opens/closes under actual failure scenarios

---

## References

### Books & Papers
- **"Release It!" by Michael Nygard** — Circuit breaker pattern, stability patterns
- **"Hystrix: Latency and Fault Tolerance for Distributed Systems" (Netflix)** — Original circuit breaker design

### Open-Source Implementations
- **Resilience4j** (Java/Kotlin): https://resilience4j.readme.io/
- **Hystrix** (Java): https://github.com/Netflix/Hystrix (archived, use Resilience4j)
- **PyBreaker** (Python): https://github.com/danielfm/pybreaker
- **Opossum** (Node): https://github.com/nodeshift/opossum

### Monitoring Tools
- **Prometheus + Grafana**: Circuit breaker metrics exported as Prometheus metrics
- **Datadog**: Built-in circuit breaker insights
- **CloudWatch**: AWS Lambda circuit breaker patterns

---

**Last updated:** 2026-09-23  
**Status:** Active — Critical pattern in incident analysis  
**Used in:** Risk registers for systems with external dependencies
