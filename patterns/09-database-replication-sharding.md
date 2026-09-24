# Pattern: Database Replication & Sharding

**Scale reads via replication; scale writes via sharding.**

---

## The Decision

### Do Use Replication When:

- Single database at CPU/memory limit but disk/network can handle reads
- Read-heavy workload (analytics, dashboards; 80%+ read, <20% write)
- High availability needed (failover to read replica if primary down)

### Do Use Sharding When:

- Single database at storage limit (hundreds of GB; won't fit single node)
- Write throughput is bottleneck (primary disk I/O saturated)
- Cost is constraint (smaller shards = cheaper nodes)

### Do NOT Use When:

- Database is not bottleneck (CPU idle; plenty of RAM; disk space available)
- Queries join across multiple shards (defeats sharding; requires denormalization)
- Team lacks expertise (sharding requires careful testing; easy to get wrong)

---

## Quick Comparison

| Approach | Complexity | Cost | Read Scale | Write Scale | Consistency |
|----------|-----------|------|-----------|------------|-------------|
| **Single DB** | ⭐ (none) | $ | ❌ Limited | ❌ Limited | ✅ Strong |
| **Replication** | ⭐⭐ | $$ | ✅ Good | ❌ No | ⚠️ Eventual |
| **Sharding** | ⭐⭐⭐⭐ | $$$ | ✅ Good | ✅ Good | ⚠️ Per-shard consistency |
| **Replication + Sharding** | ⭐⭐⭐⭐⭐ | $$$$ | ✅ Great | ✅ Great | ⚠️ Eventual |

**Replication lag**: Typically 100–1000ms (async writes from primary)  
**Sharding complexity**: Cross-shard joins become complex; planning shard key is critical

---

## Key Risks

| Risk | Symptom | Mitigation |
|------|---------|-----------|
| **Replication lag** — Read replica lags behind primary by seconds | Application reads stale data; consistency issues | Use primary for critical reads; accept eventual consistency for non-critical |
| **"Hot shard"** — One shard receives 90% of writes (bad shard key) | One node at 100% CPU while others idle; uneven scaling | Monitor shard distribution; choose shard key carefully (hash-based better than sequential) |
| **"Cascading replication lag"** — Replica's replica falls further behind | Chain of replicas become inconsistent; recovery complex | Prefer star topology (replicas connect to primary, not other replicas) |
| **Sharding key can't change** — If shard key is wrong, resharding is expensive | Months of data migration; downtime risk | Plan sharding strategy carefully upfront; consider future resharding cost |

---

## Cost Estimate (Illustrative)

| Scenario | Setup | Hardware/Month | Complexity |
|----------|-------|---|----------|
| **Single DB** | 1 node | $500–1000 | Simple |
| **Replication** | Primary + 2 read replicas | $1500–3000 | Medium (replication lag management) |
| **Sharding (4 shards)** | 4 primaries + 1 replica each | $3000–6000 | High (shard key, routing, consistency) |

**Sharding effort**: 6–12 engineer-weeks (planning + implementation + testing + migration)

---

## Evidence to Collect

**Justify replication if:**
- [ ] Database CPU > 70% consistently
- [ ] Read QPS > Write QPS (3:1 or higher)
- [ ] Read latency SLA is tight (< 50ms p99)
- [ ] HA required (failover needed if primary down)

**Justify sharding if:**
- [ ] Database size > 100GB AND growing 10GB/month
- [ ] Write QPS > 5000 req/sec (assuming 10KB per write)
- [ ] Storage cost is significant (> $1000/month)
- [ ] Single query covers < 5% of data (most queries shard-local)

**Invalidates sharding:**
- Cross-shard joins are common (defeats sharding benefits)
- Shard key cannot be identified (hash customer_id works; hash timestamp doesn't)
- Team has no sharding experience (risk too high)

---

## First 30 Days

**Replication Pilot**:
- [ ] Create read replica; verify it syncs within 100ms
- [ ] Test failover (primary down → promote replica)
- [ ] Metric: Replica lag < 100ms; failover time < 5 min

**Sharding Pilot** (if applicable):
- [ ] Shard key strategy decided (hash customer_id, not sequential)
- [ ] 2–3 shards created; data split evenly
- [ ] Routing logic working (request goes to correct shard)
- [ ] Metric: Shard imbalance < 10%; cross-shard queries < 5%

**Stop if**:
- Replication lag > 1000ms (indicates primary saturation; needs optimization first)
- Sharding creates imbalance > 30% (shard key choice wrong)
- Cross-shard queries unavoidable (defeats sharding; reconsider architecture)

---

## References

- **Database sharding strategies** (MySQL docs)
- **Replication topologies** (PostgreSQL docs)
- **Consistent hashing** (for shard key selection)

---

**Status**: Decision card (skeleton) — elaborate based on database queries and write patterns
