# cloud-patterns Configuration

**Vendor-agnostic cloud design patterns with local emulators, IaC, and real-world scenarios.**

For universal rules, see `~/.claude/CLAUDE.md`.

## Project Context

**Purpose**: Teach cloud architecture patterns (vendor-agnostic) through hands-on practice using local emulators, Terraform, and scenario-based learning.

**Key Principles**:
- Patterns first, provider details second
- Cost-free: All learning uses local emulators or free tier IaC (`terraform plan`)
- Vendor-agnostic: Every pattern has AWS/Azure/GCP implementations
- Diagram-driven: Architecture diagrams paired with Terraform code
- Scenario-based: Learn through real-world architecture challenges

**Key Modules**:
- `patterns/*/` — Cloud architecture patterns (serverless, microservices, data lakes, etc.)
- `terraform/{aws,azure,gcp}/` — Production-ready IaC for each pattern + provider
- `docker-compose/` — Local emulator setup (Floci/LocalStack)
- `diagrams/` — Architecture diagrams (Draw.io source)
- `scenarios/` — Real-world architecture exercises
- `references/` — Best practices from AWS/Azure/GCP

## Dependencies

### Local
- `docker` — Container runtime for emulators
- `docker-compose` — Orchestration
- `terraform` >= 1.0 — Infrastructure-as-code
- `tflint` — Terraform linter
- `draw.io` (optional) — Edit architecture diagrams

### Providers (Optional)
- `aws-cli` — AWS CLI for local testing
- `azure-cli` — Azure CLI (optional)
- `gcloud` — GCP CLI (optional)

### Emulators
- `floci` — AWS/Azure/GCP emulator (Docker image: floci/floci)
- `localstack` — AWS emulator (Docker image: localstack/localstack, alternative)

## Quick Commands

### Start Emulators
```bash
# AWS (Floci)
docker-compose -f docker-compose/aws.yml up -d

# Azure (Floci)
docker-compose -f docker-compose/azure.yml up -d

# GCP (Floci)
docker-compose -f docker-compose/gcp.yml up -d

# Verify services are running
curl http://localhost:4566/health  # AWS
curl http://localhost:4577/health  # Azure
curl http://localhost:4588/health  # GCP
```

### Terraform
```bash
# Validate IaC (no deployment)
cd terraform/aws/<pattern>
terraform init
terraform validate
terraform plan

# Lint for issues
tflint .

# Check security (Checkov)
checkov -d . --framework terraform

# Do NOT run apply (only for learning)
# terraform apply
```

### Diagrams
```bash
# Edit in Draw.io (online)
open diagrams/*.drawio

# Or open locally
docker run -it -p 8080:8080 -v $(pwd)/diagrams:/data jgraph/drawio:latest
# Visit http://localhost:8080
```

## Code Standards

**Terraform**:
- All configs follow Terraform 1.0+ best practices
- Modules parameterized with `variables.tf`, `terraform.tfvars.example`
- Output key results in `outputs.tf`
- Comments explain *why* (not what—HCL is self-documenting)
- Use consistent naming: `aws_s3_bucket`, `azurerm_storage_account`, `google_storage_bucket` (provider-specific)

**Architecture Diagrams**:
- Use provider icon libraries (AWS, Azure, GCP in Draw.io)
- Label all components (name + purpose)
- Show data flow with arrows
- Include legend (what each color/shape means)

**Pattern Docs**:
- `README.md`: When to use, trade-offs, prerequisites
- `local-setup.sh`: Script to run pattern locally with emulator
- `SOLUTION.md` (in scenarios): Model solution with rationale

**Learning Materials**:
- Hands-on exercises (timed, achievable in 30-60 mins)
- Clear success criteria (what "done" looks like)
- Model solutions with trade-off explanations

## Project Structure

```
cloud-patterns/
├── README.md                      # Project overview
├── LEARNING.md                    # 8-week learning path
├── CLAUDE.md                      # This file
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
│   │   ├── 3-tier-web-app/
│   │   ├── serverless-event-driven/
│   │   └── ...
│   ├── azure/
│   │   ├── 3-tier-web-app/
│   │   ├── serverless-event-driven/
│   │   └── ...
│   └── gcp/
│       ├── 3-tier-web-app/
│       ├── serverless-event-driven/
│       └── ...
├── docker-compose/
│   ├── aws.yml                    # Floci AWS emulator
│   ├── azure.yml                  # Floci Azure emulator
│   └── gcp.yml                    # Floci GCP emulator
├── diagrams/
│   ├── 3-tier-web-app.drawio
│   ├── serverless-event-driven.drawio
│   └── ...
├── scenarios/
│   ├── ecommerce-platform/
│   ├── data-pipeline/
│   ├── migration-strategy/
│   ├── cost-optimization/
│   ├── disaster-recovery/
│   └── security-hardening/
├── references/
│   ├── aws-waf.md
│   ├── azure-patterns.md
│   └── gcp-patterns.md
└── .github/workflows/
    └── validate.yml               # CI: Terraform validation
```

## Git Workflow

Use raw `git` for this project (no `just` recipe needed):

```bash
# Check status
git status

# Stage specific files
git add patterns/<pattern>/README.md

# Commit (follow conventional commits)
git commit -m "feat: Add 3-tier web app pattern

- Diagram with load balancer, app tier, database
- Terraform for AWS/Azure/GCP (use t2.micro, cost optimized)
- Local emulator setup with Docker Compose
- Scenario: E-commerce platform 10k daily users
- Cost analysis: $500/month estimate

Closes #5"

# Push
git push origin main
```

**Commit message format**:
- Type: `feat:` (new pattern), `docs:` (documentation), `fix:` (bug fix), `refactor:` (improve existing)
- Title: What changed (one line, < 50 chars)
- Body: Why it changed, trade-offs, references to scenarios/requirements

## Testing & Validation

**Terraform validation** (CI-automated via GitHub Actions):
```bash
terraform init
terraform validate
tflint .
checkov -d . --framework terraform
```

**Manual testing** (local emulator):
```bash
# Start emulator
docker-compose -f docker-compose/aws.yml up -d

# Run local setup script
cd patterns/<pattern>
./local-setup.sh

# Verify (e.g., list S3 buckets)
aws --endpoint-url=http://localhost:4566 s3 ls

# Check DynamoDB tables
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

# Stop emulator
docker-compose -f docker-compose/aws.yml down
```

**Scenario validation**:
- [ ] Exercise completes without errors
- [ ] Success criteria met (timing, accuracy)
- [ ] Model solution provided and documented
- [ ] Trade-offs explained (why this approach, not alternatives?)

## Contributing

See `CONTRIBUTING.md` for detailed guidelines.

**What we accept**:
- New patterns (with Terraform + diagrams + scenarios)
- Scenario improvements (clearer requirements, better model solutions)
- IaC optimizations (cost, security, maintainability)
- Documentation (typos, clarity, examples)

**What we don't accept**:
- Cloud-specific tutorials (use official provider docs instead)
- Live cloud deployments (all examples use emulators or `terraform plan`)
- Proprietary or non-vendor-agnostic patterns

## References

### Learning
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [GCP Architecture Framework](https://cloud.google.com/architecture/framework)
- [LEARNING.md](LEARNING.md) — 8-week curriculum

### Tools
- [Floci](https://floci.io/) — Cloud emulator
- [LocalStack](https://localstack.cloud/) — AWS emulator (alternative)
- [Terraform Docs](https://www.terraform.io/docs/)
- [Draw.io](https://draw.io) — Free diagramming

### Communities
- r/devops, r/aws, r/azure, r/gcp
- Cloud architecture blogs (AWS, Azure, GCP)
- Local DevOps/SRE meetups

## Project Goals

**Phase 1 (MVP)**: 4 core patterns (3-tier, serverless, microservices, data lake)
**Phase 2**: 4 additional patterns (multi-region DR, event sourcing, API gateway, hybrid cloud)
**Phase 3**: 10 real-world scenarios with model solutions and cost analysis
**Phase 4**: Community contributions, certification prep materials

## Questions?

See [README.md](README.md) for overview, [LEARNING.md](LEARNING.md) for curriculum, or [patterns/](patterns/) for specific pattern guides.
