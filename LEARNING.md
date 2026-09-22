# 8-Week Cloud Architecture Learning Path

**Goal**: Master vendor-agnostic cloud design patterns through hands-on practice.

**Prerequisites**: Basic Linux/shell, familiarity with JSON/YAML, understanding of networking concepts (TCP/IP, DNS).

**Time commitment**: 10-15 hours/week (can be compressed or spread out).

---

## Week 1-2: Foundations

### Learning Objectives
- Understand the 5 pillars of cloud architecture
- Learn to read and diagram 3-tier systems
- Know when to choose scaling strategies
- Understand cost drivers

### Topics

**1. Cloud Architecture Fundamentals** (3 hrs)
- Read: [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/) (5 pillars: operational excellence, security, reliability, performance efficiency, cost optimization)
- Read: [Azure Architecture Center - Design Principles](https://learn.microsoft.com/en-us/azure/architecture/guide/)
- Skim: [GCP Architecture Framework](https://cloud.google.com/architecture/framework)

**Key takeaway**: These pillars are **provider-agnostic**. A secure design is secure whether it's on AWS, Azure, or GCP.

**2. Architecture Diagramming** (2 hrs)
- Install [Draw.io](https://draw.io) (or open online)
- Open `diagrams/3-tier-web-app.drawio`
- Study the components: Load Balancer, App Servers, Database, caching layer
- Re-draw from memory in 15 minutes (time yourself)
- Compare to original; identify gaps

**3. Scaling Strategies** (2 hrs)
- **Horizontal scaling**: Add more servers, distribute load
  - Pro: Linear cost scaling, natural resilience
  - Con: Stateless requirement, distributed tracing complexity
- **Vertical scaling**: Bigger servers
  - Pro: Simpler initially, fewer operational overhead
  - Con: Hits limits, cost jumps (exponential), single point of failure
- Read: [Designing Scalable Cloud Applications](https://aws.amazon.com/blogs/architecture/) (case studies)

**4. Cost Drivers** (2 hrs)
- **Compute**: Instance hour, CPU type (ARM vs x86), commitment discounts
- **Storage**: GB/month, access patterns (hot/warm/cold), replication
- **Data transfer**: Egress charges, inter-region costs, content delivery
- **Database**: Provisioned vs. pay-per-request, reserved capacity, multi-AZ replication
- Exercise: Estimate monthly cost for:
  - Small web app (1k daily users)
  - Data pipeline (100GB/day ingestion)
  - Real-time analytics (10k concurrent streams)

### Hands-On Practice

**Exercise 1: Diagram a 3-Tier System** (30 mins)
```
Scenario: Online bookstore, 10k daily users, peak 2x average
- Design using diagramming tool
- Label: load balancer, web servers, app servers, database
- Add: caching (Redis/Memcached), CDN
- Identify: single points of failure
```

**Exercise 2: Cost Estimation** (30 mins)
```
Given: 10k daily users, average 5 minutes session, $0.01 per hour per t3.medium EC2
- How many instances needed? (assume 80% CPU utilization = 250 req/sec per instance)
- What's monthly compute cost? (use on-demand rate)
- How much cheaper with 1-year reserved instances?
```

### Deliverables
- [ ] Diagram of 3-tier system saved in `diagrams/my-3-tier.drawio`
- [ ] Cost estimation spreadsheet (3 scenarios)
- [ ] 1-page summary: "5 pillars and how they apply to any architecture"

---

## Week 3-4: Hands-On with Emulators

### Learning Objectives
- Set up local AWS/Azure/GCP emulators
- Deploy a serverless function locally
- Create infrastructure with Terraform (plan mode, no actual deployment)
- Understand event-driven architecture

### Topics

**1. Local Emulator Setup** (2 hrs)
```bash
# Install Docker (if not already)
docker --version

# Start AWS emulator
cd docker-compose
docker-compose -f aws.yml up -d

# Verify (list buckets)
aws --endpoint-url=http://localhost:4566 s3 ls
```

**What you just created**: Local S3, Lambda, DynamoDB, SQS, SNS, API Gateway

**2. Serverless Event-Driven Pattern** (3 hrs)
```bash
# Navigate to pattern
cd patterns/serverless-event-driven

# Study the diagram
open diagrams/serverless-event-driven.drawio

# Run local setup
./local-setup.sh

# This creates:
# - S3 bucket
# - DynamoDB table (event log)
# - Lambda-like function (Python script)
# - SNS topic (notifications)

# Trigger event
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://my-bucket/

# Check results
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name events
```

**What you learned**: How events propagate through a system, fan-out patterns, eventual consistency

**3. Terraform Plan (No Deployment)** (2 hrs)
```bash
# Navigate to Terraform example
cd terraform/aws/serverless-event-driven

# Initialize Terraform
terraform init

# See what WOULD be created (without creating anything)
terraform plan

# Check syntax
terraform validate

# Lint (find potential issues)
tflint .
```

**What you learned**: Infrastructure-as-code basics, declarative definitions, what resources are needed

**4. Multi-Provider Comparison** (2 hrs)
```bash
# Compare same pattern across providers
cat terraform/aws/serverless-event-driven/main.tf
cat terraform/azure/serverless-event-driven/main.tf
cat terraform/gcp/serverless-event-driven/main.tf

# Study differences:
# - AWS Lambda vs Azure Functions vs Google Cloud Functions
# - AWS SNS vs Azure Service Bus vs GCP Pub/Sub
# - How permissions are defined differently
```

**Key insight**: The *pattern* is identical (event → function → storage), but the provider *details* differ.

### Hands-On Practice

**Exercise 1: Local Event-Driven App** (1 hr)
```bash
Scenario: Photo upload → image resize → metadata extraction → notification
- Use local emulator
- Upload photo to S3
- Trigger Lambda function (Python script)
- Write resized image + metadata to DynamoDB
- Publish notification to SNS
- Verify all steps complete
```

**Exercise 2: Terraform Cost Simulation** (30 mins)
```bash
Task: Modify terraform/aws/serverless-event-driven/variables.tf
- Change lambda_memory from 128MB to 512MB
- Change s3 replication from single-region to multi-region
- Run 'terraform plan' and note changes
- Mentally estimate new cost (compare to Week 1 exercise)
```

**Exercise 3: Adapt to Another Provider** (1 hr)
```bash
Task: Write Terraform for GCP Pub/Sub + Cloud Functions
- Open terraform/gcp/serverless-event-driven/main.tf (template)
- Modify to match AWS pattern you just studied
- Run 'terraform validate'
- Compare your code to the template solution
```

### Deliverables
- [ ] Successful local event-driven app (screenshot of DynamoDB results)
- [ ] `terraform plan` output for modified serverless pattern
- [ ] Terraform config for one pattern on your chosen provider (validated, no deploy)

---

## Week 5-6: Deep Dives (Pick 2 Patterns)

### Learning Objectives
- Master 2-3 specific patterns thoroughly
- Understand trade-offs deeply
- Write Terraform for real deployment (in free tier or local)
- Connect architectural decisions to business requirements

### Choose Your Patterns

**Option A: Microservices + Kubernetes** (for scalability)
- When to use: 50+ developers, need independent deployments
- When NOT: < 10 developers, monolith works fine
- Learn: Service mesh, Helm charts, cluster networking
- Deploy: Minikube locally or AWS EKS/Azure AKS/GCP GKE in free tier

**Option B: Data Lake + ETL** (for analytics)
- When to use: Petabyte-scale data, needs to be queried in multiple ways
- When NOT: < 100GB, traditional data warehouse sufficient
- Learn: Data partitioning, schema-on-read, distributed processing
- Deploy: S3 → Glue (AWS) or ADLS → Synapse (Azure) or GCS → Dataflow (GCP)

**Option C: Multi-Region Disaster Recovery** (for resilience)
- When to use: 99.99%+ uptime requirement, regulatory compliance
- When NOT: Single-region is fine, cost-sensitive
- Learn: Active-active vs active-passive, data replication lag, failover automation
- Deploy: Cross-region RDS with read replicas (AWS) or Geo-replication (Azure/GCP)

**Option D: Event Sourcing + CQRS** (for complex domains)
- When to use: Need audit trail, complex state transitions, temporal queries
- When NOT: Simple CRUD operations, small data
- Learn: Event store, projections, eventual consistency
- Deploy: DynamoDB + Lambda (AWS) or Cosmos DB + Functions (Azure) or Firestore + Cloud Functions (GCP)

### Week 5: Pattern 1

**Monday-Wednesday**:
1. Read pattern guide: `patterns/<pattern>/README.md`
2. Study diagram: `diagrams/<pattern>.drawio`
3. Read case studies (AWS/Azure/GCP architecture blogs)

**Thursday-Friday**:
1. Write Terraform: `terraform/aws/<pattern>/main.tf`
2. Run `terraform plan` (check for errors)
3. Document decisions: Why this architecture? Trade-offs? Costs?

### Week 6: Pattern 2 + Comparison

**Monday-Wednesday**:
1. Repeat Week 5 for Pattern 2
2. Compare Pattern 1 + 2:
   - Which is more cost-efficient?
   - Which scales better?
   - When would you pick one over the other?

**Thursday-Friday**:
1. Write multi-provider Terraform for Pattern 1 (AWS → Azure or GCP)
2. Document provider-specific differences
3. Create decision matrix: "When to use each provider for this pattern"

### Hands-On Practice

**Exercise 1: Terraform Parameterization** (1 hr)
```bash
Task: Make terraform/aws/<pattern>/main.tf reusable
- Add variables: region, environment, tags
- Create separate tfvars for dev/staging/prod
- Test: terraform plan -var-file=dev.tfvars
- Test: terraform plan -var-file=prod.tfvars (should show different resources)
```

**Exercise 2: Cost Comparison** (1 hr)
```bash
Task: Compare Pattern 1 across AWS/Azure/GCP
- Identify key resources (compute, storage, data transfer)
- Find pricing in each provider's calculator
- Build cost model (monthly cost vs. daily users)
- Create spreadsheet: "At 1M daily users, which provider is cheapest?"
```

**Exercise 3: Failure Scenarios** (1 hr)
```bash
Task: List failure modes for Pattern 1
Example for 3-tier web:
- Database fails → App returns 500 errors → Load balancer marks unhealthy → Routes to other instances
- Load balancer fails → Traffic drops to 50% → Alerts trigger → Manual failover to standby
- Caching layer fails → Direct DB queries spike → Slow responses

For your pattern: Identify 5-10 failure modes, mitigation per each.
```

### Deliverables
- [ ] Pattern 1: Terraform (all 3 providers, validated)
- [ ] Pattern 2: Terraform (at least 1 provider, validated)
- [ ] Cost comparison spreadsheet (Pattern 1 across AWS/Azure/GCP)
- [ ] Decision matrix: "When to use each provider/pattern"
- [ ] 2-page design doc: Why these patterns, trade-offs, business requirements

---

## Week 7-8: Mock Scenarios

### Learning Objectives
- Apply patterns to real-world problems
- Make trade-off decisions under constraints
- Practice architecture interviews
- Get feedback on designs

### Scenarios

**Pick 3 of 5 scenarios** (30-45 mins each, timed):

1. **E-commerce Platform**
   - Requirements: 1M daily users, 99.99% uptime, PCI compliance, peak is 10x off-peak
   - Constraints: $100k/month budget
   - Questions: How do you scale checkout? Handle Black Friday? Ensure compliance?

2. **Data Pipeline**
   - Requirements: 1TB/day ingestion, real-time analytics, 7-year retention, compliance
   - Constraints: $50k/month, latency < 5 mins
   - Questions: Which storage tier for different ages? How do you query old data? Cost optimization?

3. **Migration Strategy**
   - Requirements: Move 500 on-prem VMs to cloud, zero downtime, optimize costs
   - Constraints: 3-month timeline, existing licenses can be transferred
   - Questions: Lift-and-shift vs. refactor? Hybrid connectivity? Rollback plan?

4. **Cost Optimization**
   - Requirements: Existing 3-tier web app, reduce costs by 40%, maintain performance
   - Constraints: Can't change code, minimal downtime
   - Questions: Reserved instances? Caching? Auto-scaling adjustments? Architecture changes?

5. **Disaster Recovery**
   - Requirements: RTO = 1 hour, RPO = 15 minutes, multi-region failover
   - Constraints: Budget < 2x baseline costs
   - Questions: Active-active vs. active-passive? Data replication strategy? Testing plan?

### Exercise Format

**Per scenario** (45 mins total):

1. **Read requirements** (5 mins)
   - Understand constraints, success criteria, trade-offs

2. **Design solution** (25 mins)
   - Sketch diagram in Draw.io
   - List components (compute, storage, networking, data flow)
   - Note assumptions and risks

3. **Prepare explanation** (10 mins)
   - Write bullet points explaining decisions
   - Anticipate questions: "Why not X?" or "What if Y happens?"

4. **Review model solution** (5 mins)
   - Compare to `scenarios/<scenario>/SOLUTION.md`
   - Note different approaches, trade-offs
   - Identify gaps in your design

### Deliverables
- [ ] 3 completed scenarios (diagram + written solution)
- [ ] Feedback document: "What I'd do differently next time"
- [ ] Video walkthrough: 5-minute explanation of one scenario (optional but recommended)

---

## Capstone Project (Week 9+, Optional)

**Design a complete system for a business you know:**

1. **Choose domain**: E-commerce, SaaS, mobile app, data analytics, gaming
2. **Write requirements**: Users, scale, compliance, performance targets
3. **Design architecture**: 
   - Diagram (multi-component)
   - Component descriptions (why each piece?)
   - Failure scenarios (what breaks? how do you recover?)
4. **Write Terraform**: For at least 1 provider (AWS, Azure, or GCP)
5. **Cost estimate**: Monthly costs at different scales
6. **Trade-off analysis**: "Why this approach? What would I change?"

**Example capstone**: Build architecture for a real-time collaborative document editor (like Google Docs).

---

## Success Criteria

### Week 1-2
- [ ] Can explain 5 pillars of cloud architecture
- [ ] Can diagram a 3-tier system from scratch
- [ ] Can estimate costs for a given workload

### Week 3-4
- [ ] Local emulator running without errors
- [ ] `terraform plan` works for one pattern, one provider
- [ ] Can compare pattern implementation across AWS/Azure/GCP

### Week 5-6
- [ ] Terraform for 2 patterns (validated, documented)
- [ ] Cost comparison across providers
- [ ] Can explain when to use each pattern

### Week 7-8
- [ ] 3 completed scenarios with diagrams
- [ ] Can defend architectural decisions
- [ ] Identifies real trade-offs (not just "it's faster/cheaper")

### Capstone (Optional)
- [ ] Full-system design with Terraform
- [ ] Cost model and failure analysis
- [ ] 10-minute presentation explaining architecture

---

## Resources

### Free Cloud Learning
- [AWS Skill Builder](https://skillbuilder.aws/learn) (free tier)
- [Microsoft Learn](https://learn.microsoft.com/en-us/) (free tier)
- [Google Cloud Skills Boost](https://www.cloudskillsboost.google/cloud-skill-boosts) (free tier)

### Tools
- [Draw.io](https://draw.io) — Free diagramming
- [Terraform](https://www.terraform.io/) — Free IaC
- [Docker Desktop](https://www.docker.com/products/docker-desktop) — Free emulator container runtime
- [tflint](https://github.com/terraform-linters/tflint) — Free Terraform linter
- [checkov](https://www.checkov.io/) — Free security scanning

### Documentation
- [AWS Architecture Center](https://aws.amazon.com/architecture/)
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [GCP Architecture Framework](https://cloud.google.com/architecture/framework)
- [Terraform Docs](https://www.terraform.io/docs/)

### Communities
- r/devops, r/aws, r/learnprogramming
- Local cloud/DevOps meetups
- Cloud architecture blogs (AWS, Azure, GCP)

---

**Ready to start?** Go to [Week 1](LEARNING.md#week-1-2-foundations) above, or jump straight to [patterns/](patterns/) if you prefer hands-on learning first.
