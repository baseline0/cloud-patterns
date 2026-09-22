# Contributing to cloud-patterns

Thank you for helping build cloud-patterns! This guide explains how to add new patterns, scenarios, or improvements.

## 🎯 What We Accept

### ✅ Yes Please

- **New patterns** (with Terraform + diagrams + local setup)
- **New scenarios** (real-world architecture exercises)
- **Terraform improvements** (cost optimization, security enhancements, modularity)
- **Diagram improvements** (clarity, AWS/Azure/GCP icon consistency)
- **Documentation** (typos, examples, clearer explanations)
- **Learning materials** (exercises, case studies, cost models)

### ❌ No Thanks

- Cloud-specific tutorials (use official provider docs)
- Live cloud deployments (emulator-only or `terraform plan`)
- Proprietary or vendor-lock-in patterns
- Code that requires cloud accounts or costs money
- Advanced topics (focus on fundamentals + common patterns)

## 🚀 Adding a New Pattern

### Step 1: Create Pattern Directory

```bash
mkdir -p patterns/<pattern-name>
cd patterns/<pattern-name>
```

### Step 2: Write Pattern Guide (`README.md`)

```markdown
# <Pattern Name>

## Summary
- **When to use**: <Specific scenarios>
- **When NOT**: <Anti-patterns>
- **Cost**: $<estimate>/month (1M daily users)
- **Complexity**: Beginner | Intermediate | Advanced
- **Providers**: AWS | Azure | GCP (all supported)

## Problem Statement
<What problem does this solve?>

## Architecture
<Diagram description>

## Components
- **Load Balancer**: <Description>
- **Compute**: <Description>
- **Storage**: <Description>
- **Networking**: <Description>

## Trade-offs
| Aspect | Pro | Con |
|--------|-----|-----|
| Scalability | Auto-scaling handles 10x load | Higher operational complexity |
| Cost | Efficient resource utilization | Reserved instances needed for optimization |

## Implementation
1. Deploy infrastructure (Terraform)
2. Configure services
3. Test with local emulator
4. Monitor and optimize

## References
- [AWS Architecture Pattern](...)
- [Azure Implementation](...)
- [GCP Best Practices](...)

## Examples
- E-commerce platform
- SaaS application
- Real-time analytics
```

### Step 3: Create Terraform

```bash
mkdir -p patterns/<pattern-name>/terraform/{aws,azure,gcp}
```

**AWS example** (`terraform/aws/main.tf`):
```hcl
# Load balancer
resource "aws_lb" "main" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  
  tags = {
    Name = "app-lb"
  }
}

# ... more resources
```

**Include**:
- `main.tf` — Infrastructure definition
- `variables.tf` — Parameterization (region, instance size, tags, etc.)
- `terraform.tfvars.example` — Example values
- `outputs.tf` — Key outputs (endpoint URLs, ARNs, etc.)
- `test.sh` — Validation script:
  ```bash
  #!/bin/bash
  terraform init
  terraform validate
  tflint .
  ```

### Step 4: Create Diagram

```bash
# In Draw.io (https://draw.io):
# 1. Create new diagram
# 2. Add AWS/Azure/GCP icon library
# 3. Draw components:
#    - Load Balancer
#    - Compute instances
#    - Database
#    - Storage
#    - Caching layer (if applicable)
# 4. Add arrows showing data flow
# 5. Export as "diagrams/<pattern-name>.drawio"
```

### Step 5: Create Local Setup Script

`local-setup.sh`:
```bash
#!/bin/bash
set -e

# Start AWS emulator (if not running)
docker-compose -f ../../docker-compose/aws.yml up -d

# Wait for services
sleep 3

# Create S3 bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-bucket

# Create DynamoDB table
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name my-table \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

echo "✅ Local setup complete"
echo "Bucket: s3://my-bucket"
echo "Table: my-table"
```

### Step 6: Document Cost Model

`COST.md`:
```markdown
# Cost Analysis

## AWS (per month)

| Resource | Qty | Unit | Cost |
|----------|-----|------|------|
| EC2 t2.medium | 3 | $0.0468/hr | $100 |
| RDS db.t3.micro | 1 | $0.017/hr | $12 |
| S3 | 100GB | $0.023/GB | $2.30 |
| Data transfer | 1TB | $0.09/GB | $92 |
| **Total** | | | **$206.30** |

## Azure (per month)

| Resource | Qty | Unit | Cost |
|----------|-----|------|------|
| B2s VM | 3 | $0.0953/hr | $204 |
| SQL Database | 1 | $15/month | $15 |
| Blob Storage | 100GB | $0.018/GB | $1.80 |
| Data transfer | 1TB | $0.087/GB | $87 |
| **Total** | | | **$307.80** |

## GCP (per month)

| Resource | Qty | Unit | Cost |
|----------|-----|------|------|
| e2-medium VM | 3 | $0.0269/hr | $58 |
| Cloud SQL | 1 | $6/month | $6 |
| Cloud Storage | 100GB | $0.020/GB | $2 |
| Egress | 1TB | $0.12/GB | $123 |
| **Total** | | | **$189** |

## Scale-Out Example

At 1M daily users (100x increase):
- Double compute (add load balancer, replicate DB)
- Estimated total: $400-600/month (varies by provider)
```

### Step 7: Add Scenario (Optional)

If your pattern fits, create a scenario in `scenarios/`:

```bash
mkdir -p scenarios/<scenario-name>
```

**`scenarios/<scenario-name>/README.md`**:
```markdown
# <Scenario Name>

## Requirements
- Users: 1M daily
- Uptime: 99.99%
- Latency: < 100ms
- Cost: $100k/month budget
- Compliance: PCI-DSS

## Success Criteria
- [ ] Handle 10x peak load
- [ ] Automatic failover < 1 min
- [ ] Cost within budget
- [ ] All data encrypted at rest

## Your Task
1. Design architecture (30 mins)
2. Create diagram in Draw.io
3. Write component list
4. Identify failure modes
5. Compare to model solution
```

**`scenarios/<scenario-name>/SOLUTION.md`**:
```markdown
# Model Solution

## Architecture
[Diagram description]

## Components
- Load Balancer (AWS ELB)
- Auto Scaling Group (EC2 t2.medium, 3-10 instances)
- RDS Multi-AZ (db.t3.micro)
- ElastiCache (Redis)
- S3 + CloudFront

## Rationale
- **Load Balancer**: Distribute traffic, automatic health checks
- **ASG**: Handle 10x peak automatically
- **Multi-AZ RDS**: 99.99% uptime, automatic failover
- **Redis**: Cache hot data, reduce DB load
- **CloudFront**: CDN for static assets

## Trade-offs
| Decision | Alternative | Why This |
|----------|-------------|----------|
| Multi-AZ RDS | Read replicas | Simpler ops, proven failover |
| t2.medium | t2.large | Cost optimization (reserve instances) |
| Redis | DynamoDB | Lower latency, familiar to team |

## Estimated Cost
$150/month (on-demand), $95/month (reserved 1-year)

## Failure Modes
1. **ELB fails** → Auto-replace via ASG (< 1 min)
2. **AZ fails** → Multi-AZ RDS + ASG in multiple AZs
3. **Cache fails** → Falls back to direct DB queries (slower but available)

## Monitoring
- CloudWatch: CPU, memory, requests/sec
- Alerts: > 80% CPU, > 5s latency, unhealthy instances
```

## 📋 Checklist for New Pattern

Before submitting:

- [ ] `patterns/<pattern>/README.md` written (100+ lines)
- [ ] `terraform/{aws,azure,gcp}/main.tf` created (validated)
- [ ] `diagrams/<pattern>.drawio` created (clear, labeled)
- [ ] `local-setup.sh` works (tested)
- [ ] `COST.md` written (realistic estimates)
- [ ] Scenario created (optional, but recommended)
- [ ] All files follow project structure
- [ ] No provider API keys or secrets in code
- [ ] Terraform uses only free tier eligible resources (or low-cost)

## 📋 Checklist for New Scenario

Before submitting:

- [ ] `scenarios/<scenario>/README.md` written (requirements clear)
- [ ] `scenarios/<scenario>/SOLUTION.md` written (30-45 min to solve)
- [ ] Model solution includes rationale + trade-offs
- [ ] Success criteria are measurable
- [ ] Starter diagram provided (if helpful)
- [ ] Solution is vendor-agnostic OR shows all 3 providers

## 🔄 Pull Request Process

1. **Fork** the repository (or create feature branch)
2. **Create new pattern/scenario** following checklist above
3. **Test locally**:
   ```bash
   cd patterns/<pattern>
   ./local-setup.sh  # Works without errors?
   terraform validate  # Syntax correct?
   tflint .  # Best practices?
   ```
4. **Commit** with clear message:
   ```bash
   git commit -m "feat: Add serverless event-driven pattern
   
   - Diagram with S3 → Lambda → DynamoDB
   - Terraform for AWS/Azure/GCP
   - Local emulator setup
   - Cost analysis ($50/month estimate)
   - Scenario: Photo processing pipeline
   
   Closes #10"
   ```
5. **Push** to your fork
6. **Create Pull Request** with:
   - Title: What pattern/scenario was added
   - Description: Rationale, key design decisions, any open questions
   - Screenshots: Diagrams, test results
7. **Respond to feedback** (maintainers will review)

## 🎓 Quality Standards

### Documentation
- Clear, concise writing (avoid jargon, explain terms)
- Examples for each concept
- Visual diagrams (not just text)
- Links to official documentation (AWS/Azure/GCP)

### Code Quality
- Terraform:
  - Follows HCL conventions (snake_case, clear names)
  - Comments explain *why*, not what
  - Parameterized (use variables, not hardcoded values)
  - Validated (`terraform validate`, `tflint`)
  - Tested (locally with emulator)
- Bash:
  - Error handling (`set -e`, check return codes)
  - Comments for non-obvious steps
  - Idempotent (safe to run multiple times)

### Learning Value
- Teaches a real pattern (not toy examples)
- Scales from beginner to advanced understanding
- Includes failure scenarios and trade-offs
- Connects to real-world use cases

## 🤔 Questions?

Open an issue to discuss:
- New pattern ideas
- Improvements to existing patterns
- Learning path feedback
- Tool/framework suggestions

## 🙏 Thank You!

Every contribution makes cloud-patterns better for learners worldwide. Whether it's a new pattern, typo fix, or documentation improvement—we appreciate it!

---

**Ready to contribute?** Start with [Adding a New Pattern](#-adding-a-new-pattern) above.
