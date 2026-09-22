# 10 Beginner Cloud Architecture Scenarios

**Practice vendor-agnostic cloud patterns locally with Floci/LocalStack + Terraform.**

Each scenario builds on previous knowledge. Recommended order: 1 → 10.

---

## 📊 Scenario Overview

| # | Name | Services | Complexity | Time | Skills |
|----|------|----------|-----------|------|--------|
| 1 | Static Website Hosting | S3 | ⭐ Beginner | 30-45 min | Bucket policies, static hosting |
| 2 | Serverless API | Lambda, API Gateway | ⭐⭐ | 45-60 min | Functions, REST APIs, IAM roles |
| 3 | Event-Driven Pipeline | S3, SNS, Lambda | ⭐⭐ | 60-75 min | Pub/sub, event notifications |
| 4 | Database + CRUD API | DynamoDB, Lambda, API Gateway | ⭐⭐⭐ | 75-90 min | Databases, CRUD operations |
| 5 | 3-Tier Web App | VPC, ALB, EC2, RDS | ⭐⭐⭐ | 90-120 min | Networking, load balancing, databases |
| 6 | CI/CD Pipeline | CodeCommit, CodeBuild, CodeDeploy | ⭐⭐⭐ | 90-120 min | Git workflows, build automation |
| 7 | Monitoring & Alerting | CloudWatch, SNS, Lambda | ⭐⭐⭐ | 60-75 min | Metrics, alarms, notifications |
| 8 | Streaming Data Pipeline | Kinesis, Lambda, DynamoDB | ⭐⭐⭐⭐ | 90-120 min | Real-time processing, streams |
| 9 | Microservices Discovery | ECS, Cloud Map, ALB | ⭐⭐⭐⭐ | 120-150 min | Containers, service discovery |
| 10 | Disaster Recovery | S3, RDS, Route53 | ⭐⭐⭐⭐⭐ | 150-180 min | Multi-region, failover, replication |

---

## 🚀 Scenario 1: Static Website Hosting ⭐

**Goal**: Host a static website with S3 (beginner-friendly introduction)

**Services**: S3  
**Estimated Time**: 30-45 minutes  
**Prerequisites**: None (start here!)

### Learning Outcomes
- [ ] Create S3 bucket
- [ ] Configure public read access
- [ ] Enable static website hosting
- [ ] Upload and serve HTML/CSS files
- [ ] Write Terraform for S3 bucket

### Architecture
```
User → HTTP Request → S3 Bucket → index.html, style.css
```

### Tasks
1. Create S3 bucket with `terraform apply`
2. Upload `index.html` and `style.css`
3. Configure bucket policy for public access
4. Enable static website hosting
5. Access via S3 endpoint or DNS

### Key Concepts
- **Bucket naming**: Global, must be unique
- **Bucket policies**: JSON-based access control
- **Static hosting**: Points to index.html for `/` requests
- **CORS**: Cross-origin resource sharing (if needed)

### Deliverables
- [ ] `scenarios/01-static-website/terraform/main.tf` (S3 bucket + policy)
- [ ] `scenarios/01-static-website/html/index.html` (sample website)
- [ ] `scenarios/01-static-website/local-setup.sh` (deployment script)
- [ ] `scenarios/01-static-website/README.md` (solution guide)

### Success Criteria
- Website accessible at S3 endpoint
- CSS loads without CORS errors
- No hardcoded credentials in code

---

## 🚀 Scenario 2: Serverless API ⭐⭐

**Goal**: Build a REST API without managing servers (Lambda + API Gateway)

**Services**: Lambda, API Gateway, CloudWatch Logs  
**Estimated Time**: 45-60 minutes  
**Prerequisites**: Scenario 1 (understand S3/Terraform)

### Learning Outcomes
- [ ] Create Lambda function with Python/Node.js
- [ ] Create API Gateway REST API
- [ ] Integrate Lambda with API Gateway
- [ ] Write IAM role for Lambda
- [ ] Test endpoints with curl/Postman

### Architecture
```
User → API Gateway → Lambda Function → CloudWatch Logs
                       ↓
                    Return JSON
```

### Tasks
1. Write Lambda function (Python): returns `{"message": "Hello from Lambda!"}`
2. Package and upload to S3 (or inline in Terraform)
3. Create API Gateway with `/hello` GET endpoint
4. Integrate endpoint to Lambda
5. Test: `curl https://api.example.com/hello`
6. Check logs in CloudWatch

### Key Concepts
- **Lambda functions**: Stateless compute
- **API Gateway**: REST API creation and routing
- **IAM roles**: Lambda execution permissions
- **Environment variables**: Configuration management
- **Lambda layers**: Shared code/libraries

### Deliverables
- [ ] `scenarios/02-serverless-api/lambda/handler.py` (Lambda function code)
- [ ] `scenarios/02-serverless-api/terraform/main.tf` (API Gateway + Lambda)
- [ ] `scenarios/02-serverless-api/terraform/iam.tf` (Lambda execution role)
- [ ] `scenarios/02-serverless-api/test.sh` (curl commands to test)
- [ ] `scenarios/02-serverless-api/README.md` (solution guide)

### Success Criteria
- API returns 200 OK with JSON response
- Lambda execution time < 100ms
- Logs appear in CloudWatch
- Can be deployed with `terraform apply`

---

## 🚀 Scenario 3: Event-Driven Pipeline ⭐⭐

**Goal**: Trigger serverless functions when files are uploaded to S3

**Services**: S3, SNS, Lambda, IAM  
**Estimated Time**: 60-75 minutes  
**Prerequisites**: Scenarios 1-2

### Learning Outcomes
- [ ] Set up S3 event notifications
- [ ] Create SNS topic and subscriptions
- [ ] Trigger Lambda from SNS messages
- [ ] Process event payloads in Lambda
- [ ] Understand pub/sub patterns

### Architecture
```
User Uploads File → S3 Bucket → SNS Topic → Lambda Function
                                   ↓
                            Process file metadata
```

### Tasks
1. Create S3 bucket with upload monitoring
2. Create SNS topic for notifications
3. Subscribe Lambda function to SNS
4. Configure S3 to publish to SNS on file uploads
5. Upload a file, verify Lambda invocation
6. Check CloudWatch logs for processing

### Key Concepts
- **Event notifications**: S3 → SNS/SQS/Lambda
- **Fan-out pattern**: One event → multiple consumers
- **Dead-letter queues**: Handle failed invocations
- **Event filters**: Only trigger on specific prefixes/suffixes

### Deliverables
- [ ] `scenarios/03-event-driven/lambda/processor.py` (file processor Lambda)
- [ ] `scenarios/03-event-driven/terraform/main.tf` (S3 + SNS + Lambda)
- [ ] `scenarios/03-event-driven/test-data/sample.txt` (test file)
- [ ] `scenarios/03-event-driven/local-setup.sh` (trigger script)
- [ ] `scenarios/03-event-driven/README.md` (solution guide)

### Success Criteria
- File upload triggers Lambda invocation
- Lambda logs contain file metadata (size, key, etc.)
- Can retry failed invocations manually
- Terraform defines all event subscriptions

---

## 🚀 Scenario 4: Database + CRUD API ⭐⭐⭐

**Goal**: Build a todo-list API with database (serverless database operations)

**Services**: DynamoDB, Lambda, API Gateway  
**Estimated Time**: 75-90 minutes  
**Prerequisites**: Scenarios 1-3

### Learning Outcomes
- [ ] Design DynamoDB table schema (partition key, sort key)
- [ ] Implement CRUD operations (Create, Read, Update, Delete)
- [ ] Query with filters and pagination
- [ ] Write Lambda functions for each operation
- [ ] Handle errors and validation

### Architecture
```
User Requests:
  POST /todos → Lambda (CreateTodo) → DynamoDB
  GET /todos → Lambda (GetTodos) → DynamoDB
  DELETE /todos/{id} → Lambda (DeleteTodo) → DynamoDB
```

### Tasks
1. Design DynamoDB table: `todos` table with `id` partition key
2. Write 4 Lambda functions: Create, Get All, Get One, Delete
3. Create 4 API Gateway routes (POST, GET, GET /{id}, DELETE /{id})
4. Test all CRUD operations with curl
5. Add validation (empty title → 400 Bad Request)
6. Add error handling (404 for missing todos)

### Key Concepts
- **Partition key**: How items are distributed across DynamoDB
- **Sort key**: Secondary sorting within partition
- **Global Secondary Indexes (GSI)**: Query by non-key attributes
- **DynamoDB streams**: Trigger Lambda on data changes
- **Pagination**: Handle large result sets

### Deliverables
- [ ] `scenarios/04-crud-api/lambda/create_todo.py`
- [ ] `scenarios/04-crud-api/lambda/get_todos.py`
- [ ] `scenarios/04-crud-api/lambda/delete_todo.py`
- [ ] `scenarios/04-crud-api/terraform/main.tf` (DynamoDB + Lambdas + API Gateway)
- [ ] `scenarios/04-crud-api/test.sh` (CRUD test script with curl)
- [ ] `scenarios/04-crud-api/README.md` (solution guide)

### Success Criteria
- Create todo: `POST /todos` returns 201 with todo ID
- List todos: `GET /todos` returns all todos
- Delete todo: `DELETE /todos/{id}` returns 204
- Missing todo: `GET /todos/invalid-id` returns 404
- Invalid input: `POST /todos` with no title returns 400

---

## 🚀 Scenario 5: 3-Tier Web App ⭐⭐⭐

**Goal**: Deploy a complete web application with load balancer, app servers, and database

**Services**: VPC, ALB, EC2, RDS, Auto Scaling, Security Groups  
**Estimated Time**: 90-120 minutes  
**Prerequisites**: Scenarios 1-4 (understand networking concepts)

### Learning Outcomes
- [ ] Design VPC with public/private subnets
- [ ] Create Application Load Balancer
- [ ] Set up Auto Scaling Group for EC2
- [ ] Deploy RDS PostgreSQL database
- [ ] Configure security groups (network firewall)
- [ ] Understand multi-AZ deployment

### Architecture
```
User → Internet Gateway → ALB (Public)
                           ↓
                        EC2 Instances (Private, Auto-scaling)
                           ↓
                        RDS PostgreSQL (Private, Multi-AZ)
```

### Tasks
1. Create VPC with CIDR `10.0.0.0/16`
2. Create 2 public subnets (ALB placement)
3. Create 2 private subnets (EC2 + RDS placement)
4. Deploy Internet Gateway for public internet access
5. Create Security Groups: ALB (allow 80/443) → EC2 (allow 3306) → RDS
6. Deploy ALB in public subnets
7. Create Auto Scaling Group (2-4 EC2 t2.micro instances)
8. Deploy RDS PostgreSQL in private subnet (Multi-AZ)
9. Test: Access web app via ALB DNS name

### Key Concepts
- **VPC**: Virtual private cloud, isolated network
- **Subnets**: Public (internet-accessible) vs. Private (internal only)
- **Route tables**: Determine where traffic is routed
- **Security groups**: Stateful firewall rules
- **Auto Scaling**: Automatically adjust instance count based on load
- **Multi-AZ**: Distribute across availability zones for resilience

### Deliverables
- [ ] `scenarios/05-3tier-web/terraform/vpc.tf` (VPC + subnets + IGW)
- [ ] `scenarios/05-3tier-web/terraform/alb.tf` (Application Load Balancer)
- [ ] `scenarios/05-3tier-web/terraform/ec2.tf` (Auto Scaling Group)
- [ ] `scenarios/05-3tier-web/terraform/rds.tf` (RDS PostgreSQL)
- [ ] `scenarios/05-3tier-web/terraform/security.tf` (Security groups)
- [ ] `scenarios/05-3tier-web/app/index.html` (sample web app)
- [ ] `scenarios/05-3tier-web/README.md` (solution guide)

### Success Criteria
- ALB is accessible via DNS name (http://ALB-DNS:80)
- EC2 instances health checks pass
- Can SSH into instances (via bastion host or VPN in prod)
- RDS is reachable from EC2 instances
- Application displays database data

---

## Scenarios 6-10 (Summaries)

### 🚀 Scenario 6: CI/CD Pipeline ⭐⭐⭐
**Goal**: Automate code deployment  
**Services**: CodeCommit, CodeBuild, CodeDeploy, S3  
**Time**: 90-120 minutes  
**Key Skills**: Git workflows, build automation, deployment strategies  
**Architecture**: Git Push → CodeBuild → CodeDeploy → EC2

### 🚀 Scenario 7: Monitoring & Alerting ⭐⭐⭐
**Goal**: Set up infrastructure monitoring  
**Services**: CloudWatch, SNS, Lambda  
**Time**: 60-75 minutes  
**Key Skills**: Metrics, alarms, dashboard creation  
**Architecture**: EC2 → CloudWatch Metrics → Alarms → SNS → Email/Lambda

### 🚀 Scenario 8: Streaming Data Pipeline ⭐⭐⭐⭐
**Goal**: Process real-time streaming data  
**Services**: Kinesis, Lambda, DynamoDB  
**Time**: 90-120 minutes  
**Key Skills**: Streaming patterns, batch processing, real-time analytics  
**Architecture**: Data Producer → Kinesis → Lambda → DynamoDB

### 🚀 Scenario 9: Microservices with Service Discovery ⭐⭐⭐⭐
**Goal**: Deploy containerized microservices  
**Services**: ECS Fargate, Cloud Map, ALB  
**Time**: 120-150 minutes  
**Key Skills**: Containers, orchestration, service-to-service communication  
**Architecture**: ALB → ECS Services (via Cloud Map) ↔ Microservices

### 🚀 Scenario 10: Disaster Recovery ⭐⭐⭐⭐⭐
**Goal**: Design multi-region failover  
**Services**: S3, RDS, Route53, Auto Scaling  
**Time**: 150-180 minutes  
**Key Skills**: Multi-region architectures, failover strategies, data replication  
**Architecture**: Primary Region ↔ Replica Region (Cross-region replication)

---

## 📅 Recommended Learning Schedule

| Week | Scenarios | Focus Area | Time |
|------|-----------|-----------|------|
| **Week 1** | 1-2 | Storage + Serverless Basics | 2-3 hrs |
| **Week 2** | 3-4 | Events + Databases | 2-3 hrs |
| **Week 3** | 5-6 | Networking + Automation | 3-4 hrs |
| **Week 4** | 7-8 | Monitoring + Streams | 2-3 hrs |
| **Week 5** | 9-10 | Advanced (Containers, DR) | 4-5 hrs |

**Total**: ~20-25 hours to complete all 10 scenarios

---

## 🎯 Practice Workflow (Per Scenario)

### Step 1: Read & Design (10 mins)
- Read scenario description
- Draw architecture on paper/Draw.io
- Identify AWS services needed

### Step 2: Write Terraform (20 mins)
- Create `main.tf` with resource definitions
- Add `variables.tf` for parameterization
- Run `terraform validate` and `tflint`

### Step 3: Deploy Locally (10 mins)
```bash
docker-compose -f docker-compose/aws.yml up -d
cd scenarios/<scenario>
terraform init
terraform apply
```

### Step 4: Test (10 mins)
- Run provided test script
- Verify with AWS CLI or curl
- Check CloudWatch logs

### Step 5: Break It Intentionally (10 mins)
- Delete a resource manually
- Observe what breaks
- Rebuild with Terraform

### Step 6: Document Learnings (5 mins)
- What worked well?
- What was confusing?
- How would you improve this?

---

## 🛠️ Tools & Setup

### Prerequisites
```bash
# Install Docker
docker --version

# Install Terraform
terraform --version

# Install AWS CLI (optional)
brew install awscli  # macOS

# Install tflint (Terraform linter)
brew install tflint  # macOS
```

### Start LocalStack/Floci
```bash
# Option 1: LocalStack (AWS only)
docker-compose -f docker-compose/aws.yml up -d

# Option 2: Floci (AWS + Azure + GCP)
docker run -p 4566:4566 floci/floci

# Verify
curl http://localhost:4566/_localstack/health
```

### Configure AWS CLI
```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

aws --endpoint-url=http://localhost:4566 s3 ls
```

---

## ✅ Checklist for Each Scenario

- [ ] Terraform code written and validated
- [ ] `local-setup.sh` script created and tested
- [ ] All resources created successfully
- [ ] Tests pass (curl, Lambda invocation, etc.)
- [ ] CloudWatch logs show expected output
- [ ] Cost estimate documented (if applicable)
- [ ] README with rationale written

---

## 💡 Tips for Success

1. **Start simple**: Don't skip Scenario 1. Building confidence matters.
2. **Reuse code**: Copy Terraform from earlier scenarios (DRY principle).
3. **Read error messages**: LocalStack errors mimic real AWS—learn to debug.
4. **Test incrementally**: Don't wait until the end to test.
5. **Version control**: Commit each scenario: `git commit -am "Complete Scenario 3"`
6. **Compare solutions**: After completing a scenario, review the model solution.
7. **Teach it**: Explain your design to someone else (reinforces learning).

---

## 📚 Next Steps After Scenarios

Once you complete all 10:

1. **Real Cloud Deployment** (optional)
   - Deploy Scenario 5 to real AWS (free tier)
   - Set billing alerts first!
   - Cost: ~$5-20/month

2. **Certifications**
   - AWS Solutions Architect Associate
   - Azure Administrator
   - GCP Associate Cloud Engineer

3. **Advanced Topics**
   - Kubernetes (EKS/AKS/GKE)
   - Serverless frameworks (SAM, Serverless, CDK)
   - Infrastructure as Code (Pulumi, CloudFormation)
   - Security (VPC endpoints, KMS, secrets management)

---

**Ready to start?** Begin with [Scenario 1: Static Website Hosting](#-scenario-1-static-website-hosting-)

**Questions?** See [README.md](README.md) or [LEARNING.md](LEARNING.md)
