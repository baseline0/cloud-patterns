# Scenario 5: 3-Tier Web App (VPC + ALB + EC2 + RDS)

**Difficulty**: ⭐⭐⭐⭐ Expert  
**Estimated Time**: 90-120 minutes  
**Services**: VPC, ALB, EC2, RDS, Auto Scaling, CloudWatch, IAM  
**Cost**: Roughly $15-25/month on AWS (t3.micro + db.t3.micro)

---

## 🎯 Learning Objectives

- ✅ VPC fundamentals (subnets, routing, internet gateways)
- ✅ Public vs. private subnets (network isolation)
- ✅ Application Load Balancer (ALB) for HTTP routing
- ✅ EC2 auto-scaling groups (dynamic scaling)
- ✅ RDS PostgreSQL (managed relational database)
- ✅ Security groups (network access control)
- ✅ Multi-AZ deployment for high availability
- ✅ Health checks and failover
- ✅ Database connections from EC2 → RDS
- ✅ Infrastructure-as-Code at scale (Terraform)

---

## 🏗️ Architecture

```
Internet
  ↓ (HTTP:80)
Internet Gateway
  ↓
Public Subnets (ALB)
  ↓ (Internal routing)
Private Subnets (EC2 Auto Scaling Group)
  ↓ (SQL queries)
Private Subnets (RDS PostgreSQL Multi-AZ)
```

**Components**:

| Component | Purpose | Tier |
|-----------|---------|------|
| **Internet Gateway** | Route external traffic into VPC | Edge |
| **Application Load Balancer** | Distribute HTTP traffic across EC2s | Web |
| **EC2 (Auto Scaling)** | Run application servers | Application |
| **RDS PostgreSQL** | Persistent data storage | Database |
| **Security Groups** | Firewall rules (network isolation) | Network |

---

## 🚀 Quick Start

```bash
# 1. Start LocalStack
docker-compose -f ../../docker-compose/aws.yml up -d

# 2. Deploy 3-tier stack
bash local-setup.sh

# 3. Get ALB DNS
ALB_DNS=$(terraform output alb_dns_name)

# 4. Test application
curl http://$ALB_DNS/
# Expected: {"status": "healthy", "instance": "..."}

# 5. Monitor EC2 instances
aws --endpoint-url=http://localhost:4566 ec2 describe-instances

# 6. Check RDS database
psql -h localhost -U postgres -d appdb -c "SELECT VERSION();"
```

---

## 📚 Deep Dive

### VPC (Virtual Private Cloud)

**What**: Isolated network environment in AWS

**Key Concepts**:
- **Subnets**: Subdivisions of VPC CIDR block
- **Public Subnet**: Has route to internet (ALB/NAT sits here)
- **Private Subnet**: No direct internet access (EC2/RDS sits here)
- **Route Tables**: Define traffic routing rules
- **Internet Gateway**: Connects VPC to internet

**In this scenario**:
```
VPC CIDR: 10.0.0.0/16
├─ Public Subnets (2 AZs)
│  ├─ 10.0.1.0/24 (AZ-A)
│  └─ 10.0.2.0/24 (AZ-B)
├─ Private Subnets (2 AZs)
│  ├─ 10.0.10.0/24 (AZ-A) → EC2
│  └─ 10.0.11.0/24 (AZ-B) → EC2
└─ Private Database Subnets (2 AZs)
   ├─ 10.0.20.0/24 (AZ-A) → RDS
   └─ 10.0.21.0/24 (AZ-B) → RDS
```

---

### Application Load Balancer (ALB)

**What**: Layer 7 (Application) load balancer that routes HTTP/HTTPS traffic

**Key Features**:
- **Host-based routing**: `api.example.com` → API targets
- **Path-based routing**: `/images/*` → image service
- **Health checks**: Automatic failover to healthy targets
- **Cross-AZ**: Distributes traffic across availability zones

**Listener** (ALB configuration):
```
Port 80 → Route to Target Group (EC2 instances on port 8080)
```

**Health Check**:
```
GET / every 30s
  ✅ 200 → Healthy
  ❌ Timeout/non-200 → Mark unhealthy → Remove from rotation
```

---

### EC2 Auto Scaling Group (ASG)

**What**: Automatically launches/terminates EC2 instances based on demand

**Scaling Policies**:
- **Min size**: Always keep 2 instances running
- **Max size**: Never exceed 4 instances
- **Desired**: Typically equal to min (2)

**Benefits**:
1. **High Availability**: Instance dies → ASG launches replacement
2. **Cost**: Scale down during low traffic
3. **Performance**: Scale up during peak traffic

**In this scenario**:
```
Min: 2 instances (always running)
Max: 4 instances (scale up if needed)
Desired: 2 instances (current target)
→ ALB health checks → Auto-scale up if >2 failing
```

---

### RDS PostgreSQL (Relational Database)

**What**: AWS-managed PostgreSQL database with automatic backups, patches, failover

**Key Features**:
- **Multi-AZ**: Primary in AZ-A, standby in AZ-B (automatic failover)
- **Managed**: AWS handles backups, patches, maintenance
- **Persistent**: Data survives EC2 restarts
- **Security**: Private subnet (no internet access)

**Connection from EC2**:
```python
# EC2 instance running PHP/Python
conn = psycopg2.connect(
    host="app-db.xxxxxxxxx.rds.amazonaws.com",  # RDS endpoint
    database="appdb",
    user="postgres",
    password="TempPassword123!"
)
```

---

## 🧪 Testing & Verification

### Test 1: Load Balancer Response

```bash
ALB_DNS=$(terraform output alb_dns_name)
curl -v http://$ALB_DNS/
```

**Expected**:
```
HTTP/1.1 200 OK
{
  "status": "healthy",
  "instance": "i-abcd1234",
  "timestamp": "2024-01-15T10:30:00",
  "database": "connected"
}
```

### Test 2: Check EC2 Instances

```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances \
  --filters "Name=tag:Name,Values=app-asg-instance"
```

**Expected**: 2 running instances in different AZs

### Test 3: Database Connectivity

```bash
# From EC2 instance (SSH)
psql -h app-db.xxxxxxxxx.rds.amazonaws.com \
     -U postgres -d appdb -c "SELECT NOW();"
```

**Expected**: Current timestamp returned

### Test 4: Health Check Failure

```bash
# Stop an EC2 instance
aws --endpoint-url=http://localhost:4566 ec2 stop-instances --instance-ids i-abcd1234

# Wait 60s for health check
sleep 60

# Verify ASG launched replacement
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
# Should see new instance (different ID) in running state
```

---

## 🚨 Common Issues & Solutions

### Issue 1: ALB Not Responding

**Symptom**: `curl http://$ALB_DNS/` times out

**Solutions**:
```bash
# Check ALB security group allows port 80
aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups \
  --filters "Name=group-name,Values=app-alb-sg"

# Check target group health
aws --endpoint-url=http://localhost:4566 elbv2 describe-target-health \
  --target-group-arn <TG_ARN>
```

### Issue 2: EC2 Instances Unhealthy

**Symptom**: Target group shows all targets "Unhealthy"

**Solutions**:
```bash
# SSH to instance and check Apache
sudo systemctl status httpd

# Check security group allows 8080 from ALB SG
aws ec2 describe-security-groups --group-ids sg-xxxxx
```

### Issue 3: Database Connection Fails

**Symptom**: PHP returns "Error: could not connect to database"

**Solutions**:
```bash
# Verify RDS security group allows 5432 from EC2
aws ec2 describe-security-groups --group-ids sg-xxxxx

# Check RDS is running
aws --endpoint-url=http://localhost:4566 rds describe-db-instances

# Test connection from EC2 (requires SSH)
psql -h <RDS_ENDPOINT> -U postgres -d appdb -c "SELECT 1;"
```

---

## 📊 Cost Analysis

### AWS (Production, 2 EC2 + 1 RDS)

| Component | Cost |
|-----------|------|
| EC2 t3.micro (2 × 730h/mo) | $7.20 |
| RDS db.t3.micro (730h/mo) | $8.34 |
| ALB | $16.20 |
| Data transfer | $0.50 |
| **Total** | **$32.24/month** |

**Free tier covers**: t2.micro (750h/year), RDS (750h first year)

### Savings with Auto Scaling

If traffic is spiky (80% idle):
- **Minimum (2 instances)**: $0.008/hour × 730h = $5.84/month
- **Maximum (4 instances)**: $0.016/hour × 146h = $2.34/month
- **Total**: ~$8.18/month (vs fixed $32 without scaling)

---

## 🎓 Extensions

### Extension 1: Enable HTTPS (TLS)

```hcl
# Create self-signed certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = "example.com"
  validation_method = "DNS"
}

# Add HTTPS listener to ALB
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
```

### Extension 2: RDS Read Replicas

```hcl
# Create read-only replica in different AZ
resource "aws_db_instance" "read_replica" {
  replicate_source_db = aws_db_instance.main.identifier
  instance_class      = "db.t3.micro"
  availability_zone   = "us-east-1b"
}

# App reads from replica, writes to primary
```

### Extension 3: CloudWatch Auto Scaling Alarms

```hcl
# Scale up when CPU > 70%
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
}
```

### Extension 4: NAT Gateway for Outbound Traffic

```hcl
# Allow private subnets to reach internet (for updates)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
}

# Route private traffic through NAT
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
```

---

## ✅ Completion Checklist

- [ ] VPC created with public + private subnets
- [ ] Internet Gateway and route tables configured
- [ ] Application Load Balancer deployed
- [ ] EC2 Auto Scaling Group with 2+ instances
- [ ] RDS PostgreSQL database deployed
- [ ] Security groups allow correct traffic (80→ALB, 8080→EC2, 5432→RDS)
- [ ] EC2 instances pass ALB health checks
- [ ] Application responds via ALB DNS
- [ ] Database connections from EC2 work
- [ ] ASG replaces failed instances automatically
- [ ] `terraform destroy` cleans up all resources
- [ ] You understand VPC, ALB, ASG, RDS architecture
- [ ] Ready for Scenario 6: CI/CD Pipeline

---

## 🎉 What You've Learned

Congratulations! You now understand:
- VPC design (public/private subnets, routing)
- Load balancing (ALB, health checks, failover)
- Auto-scaling (dynamic capacity management)
- Managed databases (RDS, multi-AZ failover)
- Multi-tier architecture (web + app + database)

**Next?** → [Scenario 6: CI/CD Pipeline](../06-cicd-pipeline/)

---

**Questions?** See [SCENARIOS.md](../../SCENARIOS.md)
