# Cloud Design Patterns: Vendor-Agnostic Learning

**Master cloud architecture through hands-on practice—without cost risk or cloud accounts.**

This repository teaches **cloud design patterns** (not provider features) using local emulators, infrastructure-as-code, and real-world scenarios. Learn once, apply anywhere (AWS, Azure, GCP, or any provider).

## 🗺️ Interactive Architecture Diagrams

Explore all 10 scenarios visually with clickable links to implementations:

👉 **[View Interactive Diagrams →](https://baseline0.github.io/cloud-patterns/)** (Live on GitHub Pages)

Each diagram links directly to:
- 📂 Terraform infrastructure code (AWS/Azure/GCP)
- 📖 Scenario README documentation
- 🏃 Local setup scripts

## 🎯 Philosophy

- **Vendor-agnostic**: Patterns first, provider details second
- **Cost-free**: Local emulators (Floci, LocalStack) run on your laptop
- **IaC-first**: Every pattern includes Terraform for AWS/Azure/GCP
- **Scenario-driven**: Learn through architecture exercises, not tutorials
- **Diagram + Code**: Architecture diagrams paired with working implementations

## 📚 What's Included

### **Part 1: Pattern Library** (`patterns/`)

Core cloud architecture patterns with:
- **Pattern summary**: What it solves, when to use it, trade-offs
- **Architecture diagram**: Visual reference (Draw.io source)
- **Local emulator setup**: Docker Compose to run locally
- **Terraform implementation**: AWS/Azure/GCP variants
- **Cost analysis**: Realistic pricing estimates (cloud)

**Patterns**:
1. **3-Tier Web Application** (load balancer → app servers → database)
2. **Serverless Event-Driven** (S3 → SNS/SQS → Lambda → Database)
3. **Microservices + Kubernetes** (Helm charts, service mesh optional)
4. **Data Lake & ETL** (object storage → data pipeline → warehouse)
5. **Multi-Region Disaster Recovery** (active-active, failover strategies)
6. **Event Sourcing + CQRS** (event log, separate read/write models)
7. **API Gateway + Caching** (CDN, API rate limiting, authentication)
8. **Hybrid Cloud** (on-prem ↔ cloud connectivity)

### **Part 2: Local Emulator Setup** (`docker-compose/`)

One-command local environment for each provider:

```bash
# AWS
docker-compose -f docker-compose/aws.yml up

# Azure
docker-compose -f docker-compose/azure.yml up

# GCP
docker-compose -f docker-compose/gcp.yml up
```

Services included:
- **AWS**: S3, DynamoDB, Lambda, SQS, SNS, API Gateway
- **Azure**: Blob Storage, Queue Storage, Functions, Service Bus
- **GCP**: Cloud Storage, Pub/Sub, Firestore, Cloud Functions

### **Part 3: Infrastructure-as-Code** (`terraform/`)

Production-ready Terraform for each pattern + provider:

```
terraform/
├── aws/
│   ├── 3-tier-web/
│   ├── serverless-event-driven/
│   ├── eks-microservices/
│   └── ...
├── azure/
│   ├── 3-tier-web/
│   ├── serverless-event-driven/
│   ├── aks-microservices/
│   └── ...
└── gcp/
    ├── 3-tier-web/
    ├── serverless-event-driven/
    ├── gke-microservices/
    └── ...
```

**Each includes**:
- `main.tf` — Infrastructure definition
- `variables.tf` — Parameterization (region, instance size, etc.)
- `outputs.tf` — What to display after deployment
- `terraform.tfvars.example` — Copy to `terraform.tfvars` to deploy
- `test.sh` — Validation script (runs `terraform plan`, checks syntax)

### **Part 4: Architecture Diagrams** (`diagrams/`)

Draw.io source files for each pattern:

```
diagrams/
├── 3-tier-web-app.drawio
├── serverless-event-driven.drawio
├── microservices-kubernetes.drawio
├── data-lake-etl.drawio
├── multi-region-dr.drawio
├── event-sourcing-cqrs.drawio
├── api-gateway-caching.drawio
└── hybrid-cloud.drawio
```

Open in [Draw.io](https://draw.io) (free, browser-based):
- Drag to edit
- Export as PNG/PDF for presentations
- AWS/Azure/GCP icon libraries included

### **Part 5: Scenario-Based Exercises** (`scenarios/`)

Real-world architecture challenges:

1. **E-commerce Platform** (1M daily users, 99.99% uptime, PCI compliance)
2. **Data Pipeline** (1TB/day ingestion, real-time analytics, 7-year retention)
3. **Migration Strategy** (on-prem VMs → cloud, zero downtime)
4. **Cost Optimization** (existing design, reduce 40% spend)
5. **Disaster Recovery** (RTO = 1 hr, RPO = 15 min)
6. **Security Hardening** (compliance, zero-trust, encryption)

**Each scenario includes**:
- Requirements document
- Success criteria (latency, availability, cost, compliance)
- Starter diagram (incomplete)
- Solution checklist
- Model solution (with trade-offs explained)

### **Part 6: Learning Path** (`LEARNING.md`)

Structured progression: Weeks 1-8

- **Week 1-2**: Fundamentals (Well-Architected Framework, diagramming)
- **Week 3-4**: Hands-on with emulators (serverless, databases)
- **Week 5-6**: Deep dives (pick 1-2 patterns, study deeply)
- **Week 7-8**: Mock scenarios (architect solutions under time pressure)

### **Part 7: References** (`references/`)

Best practices from each provider:

- **AWS**: Well-Architected Framework, Architecture Center
- **Azure**: Azure Architecture Center, design principles
- **GCP**: Architecture Framework, patterns & practices
- **Cross-provider**: CQRS, event sourcing, microservices patterns

## 🚀 Quick Start

### **Option 1: Local Practice (Recommended)**

```bash
# Clone repo
git clone <repo> cloud-patterns && cd cloud-patterns

# Start AWS emulator
docker-compose -f docker-compose/aws.yml up -d

# Deploy serverless pattern locally
cd patterns/serverless-event-driven
./local-setup.sh  # Creates S3 bucket, DynamoDB table, simulates Lambda

# Verify
aws --endpoint-url=http://localhost:4566 s3 ls
```

### **Option 2: Study Architectures**

```bash
# Open diagram
open diagrams/3-tier-web-app.drawio

# Read pattern guide
cat patterns/3-tier-web-app/README.md

# Review Terraform (all 3 providers side-by-side)
ls terraform/{aws,azure,gcp}/3-tier-web/
```

### **Option 3: Practice Scenarios**

```bash
# Review scenario
cat scenarios/ecommerce-platform/README.md

# 30-min timer: Design a solution, diagram in Draw.io
# Compare to model solution
cat scenarios/ecommerce-platform/SOLUTION.md
```

## 📖 Learning Outcomes

After completing this repo, you'll understand:

- ✅ **Vendor-agnostic patterns**: How to think about cloud architecture independent of provider
- ✅ **IaC best practices**: Terraform patterns, modularity, state management
- ✅ **Scalability trade-offs**: When to use horizontal vs. vertical scaling
- ✅ **Resilience design**: Multi-region, failover, circuit breakers
- ✅ **Cost optimization**: Reserved instances, spot pricing, caching strategies
- ✅ **Security architecture**: Zero-trust, encryption, compliance patterns
- ✅ **Data patterns**: ETL, event sourcing, CQRS, real-time analytics
- ✅ **Operational excellence**: Monitoring, logging, deployment strategies

## 🛠️ Technology Stack

- **Emulators**: Floci (AWS/Azure/GCP), LocalStack (AWS)
- **IaC**: Terraform 1.0+
- **Diagramming**: Draw.io
- **Containers**: Docker, Docker Compose
- **CLI Tools**: AWS CLI, Azure CLI, gcloud CLI (optional)
- **Testing**: `terraform validate`, `tflint`, `checkov`

## 📋 Project Structure

```
cloud-patterns/
├── README.md                      # This file
├── LEARNING.md                    # 8-week learning path
├── CONTRIBUTING.md                # How to add patterns
├── patterns/
│   ├── 3-tier-web-app/
│   ├── serverless-event-driven/
│   ├── microservices-kubernetes/
│   ├── data-lake-etl/
│   ├── multi-region-dr/
│   ├── event-sourcing-cqrs/
│   ├── api-gateway-caching/
│   └── hybrid-cloud/
├── terraform/
│   ├── aws/
│   ├── azure/
│   └── gcp/
├── docker-compose/
│   ├── aws.yml
│   ├── azure.yml
│   └── gcp.yml
├── diagrams/
│   └── *.drawio
├── scenarios/
│   ├── ecommerce-platform/
│   ├── data-pipeline/
│   ├── migration-strategy/
│   ├── cost-optimization/
│   ├── disaster-recovery/
│   └── security-hardening/
├── references/
│   ├── aws-waf/
│   ├── azure-patterns/
│   └── gcp-patterns/
└── .github/workflows/
    └── validate.yml               # CI: Terraform validation
```

## 🎯 Design Principles

1. **Pattern → Implementation**: Learn the pattern first (vendor-agnostic), then see how each provider implements it
2. **Local → Remote**: Practice locally with emulators before touching real cloud
3. **Diagram → Code**: Start with architecture diagrams, then translate to IaC
4. **Why → What**: Understand *why* a pattern exists before implementing *what*
5. **Trade-offs matter**: Every pattern has pros/cons; document them explicitly

## 🔗 External References

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [GCP Architecture Framework](https://cloud.google.com/architecture/framework)
- [Floci Emulator](https://floci.io/)
- [LocalStack](https://localstack.cloud/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest)

## 💡 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add new patterns, scenarios, or diagrams.

**Contribution areas**:
- New patterns (with Terraform + diagrams + scenarios)
- Scenario improvements (clearer requirements, model solutions)
- IaC optimizations (cost, security, maintainability)
- Documentation (typos, clarity, examples)

## 📄 License

MIT. Free to use, modify, and distribute.

---

**Start here**: [LEARNING.md](LEARNING.md) for the 8-week learning path, or jump to [patterns/](patterns/) to explore specific architecture patterns.
