# Scenario 2: Serverless API (Lambda + API Gateway)

**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 45-60 minutes  
**Services**: Lambda, API Gateway, CloudWatch Logs, IAM  
**Cost**: Free tier eligible (1M free requests/month + 400k GB-seconds free compute)

---

## 🎯 Learning Objectives

After completing this scenario, you'll understand:

- ✅ AWS Lambda function fundamentals (handler, runtime, invocation)
- ✅ API Gateway REST API creation and routing
- ✅ Lambda execution roles and IAM permissions
- ✅ CloudWatch Logs integration for monitoring
- ✅ API request/response formats (JSON)
- ✅ HTTP status codes and error handling
- ✅ Lambda cold starts and warm starts
- ✅ Cost model for serverless functions

---

## 📋 Prerequisites

- Completed [Scenario 1: Static Website Hosting](../01-static-website/)
- Docker (for LocalStack emulator)
- Terraform 1.0+
- Python 3.9+ (to understand handler code)
- 45-60 minutes of uninterrupted time

---

## 🏗️ Architecture

```
Client Browser
    ↓
HTTP Request (GET /hello)
    ↓
API Gateway
  - Routing (match path to Lambda)
  - Logging (request/response)
  - Rate limiting (optional)
    ↓
Lambda Function
  - Stateless compute
  - Scale automatically
  - Pay per 100ms of execution
    ↓
CloudWatch Logs
  - Execution logs
  - Errors, debug info
    ↓
HTTP Response (JSON)
    ↓
Client Browser
```

**Key Differences from Scenario 1 (Static Website)**:

| Aspect | Scenario 1 (S3) | Scenario 2 (Lambda) |
|--------|-----------------|-------------------|
| Hosting | Storage (S3) | Compute (Lambda) |
| Content | Static (HTML/CSS) | Dynamic (computed) |
| Scale | Manual (fixed capacity) | Automatic (0 → unlimited) |
| Cost | Fixed (storage) | Variable (execution time) |
| Response Time | Milliseconds | 100-1000ms (cold start) |

---

## 🚀 Quick Start (5 Steps)

### Step 1: Start LocalStack
```bash
cd /home/mark/projects/cloud-patterns
docker-compose -f docker-compose/aws.yml up -d

# Verify it's running
curl http://localhost:4566/_localstack/health
```

### Step 2: Run Setup Script
```bash
cd scenarios/02-serverless-api
bash local-setup.sh
```

This script will:
1. Package Lambda function (handler.py → function.zip)
2. Initialize Terraform
3. Create Lambda function + API Gateway + IAM role
4. Enable CloudWatch Logs
5. Test all endpoints

### Step 3: Test the API
```bash
# All tests pass automatically in setup script, but you can re-run manually:
curl http://localhost:4566/restapis/*/\_user_request_/hello

# With query parameters
curl "http://localhost:4566/restapis/*/\_user_request_/hello?name=Alice"

# With path parameters
curl http://localhost:4566/restapis/*/\_user_request_/hello/Bob

# Health check
curl http://localhost:4566/restapis/*/\_user_request_/health
```

### Step 4: View Logs
```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test

# Tail Lambda logs (real-time)
aws --endpoint-url=http://localhost:4566 logs tail /aws/lambda/serverless-api-hello --follow

# Or view API Gateway logs
aws --endpoint-url=http://localhost:4566 logs tail /aws/apigateway/serverless-api-hello --follow
```

### Step 5: Modify and Re-deploy
```bash
# Edit the Lambda function
vim lambda/handler.py

# Re-package and re-deploy
cd lambda && zip -q function.zip handler.py && cd ..
cd terraform && terraform apply -auto-approve && cd ..

# Test again
curl http://localhost:4566/restapis/*/\_user_request_/hello
```

---

## 📚 Deep Dive: Understanding the Components

### AWS Lambda

**What it is**: Serverless compute service (run code without managing servers)

**How it works**:
1. Upload code (Python, Node.js, Java, Go, etc.)
2. Define handler function (entry point)
3. Configure runtime, memory, timeout
4. API Gateway (or other trigger) invokes function
5. Lambda scales automatically (0 → 1000s of concurrent executions)

**Key properties**:
- **Stateless**: Each execution is independent (no local storage between invocations)
- **Ephemeral**: `/tmp` directory available but deleted after invocation
- **Auto-scaling**: Handles spikes without manual configuration
- **Cost model**: Pay per 100ms of execution + GB-seconds

**In Terraform**:
```hcl
resource "aws_lambda_function" "api" {
  filename      = "lambda/function.zip"  # Zipped code
  function_name = "serverless-api-hello"
  role         = aws_iam_role.lambda_role.arn  # Execution permissions
  handler      = "handler.lambda_handler"      # Entry point function
  runtime      = "python3.11"                  # Language + version
  memory_size  = 128                           # MB (128-10240)
  timeout      = 30                            # Seconds
}
```

**Handler format** (Python):
```python
def lambda_handler(event, context):
    """
    event: Input from trigger (API Gateway, S3, etc.)
    context: Lambda runtime information
    return: Response (format depends on trigger type)
    """
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Hello from Lambda!'})
    }
```

---

### API Gateway (HTTP API)

**What it is**: Managed service for creating REST APIs

**Key features**:
- **Routing**: Map paths/methods to Lambda functions
- **Request/Response transformation**: Convert input formats
- **Logging**: All requests logged to CloudWatch
- **Caching**: Optional response caching (reduce Lambda invocations)
- **Rate limiting**: Throttle requests per client
- **CORS**: Handle cross-origin requests
- **Stages**: dev, staging, prod environments

**In this scenario**: 
- Route `GET /hello` → Lambda function
- Route `GET /hello/{name}` → Lambda function  
- Route `GET /health` → Lambda function
- Catch-all `$default` → Lambda function (returns 404 if not matched)

**API Gateway v2 (HTTP API) vs v1 (REST API)**:

| Feature | HTTP API | REST API |
|---------|----------|----------|
| Price | $0.35/million requests | $3.50/million requests |
| Cold start | Faster (~50ms) | Slower (~200ms) |
| Features | Basic routing, CORS | Full (request validators, models) |
| Use case | Microservices, simple APIs | Complex, enterprise APIs |

**This scenario uses HTTP API** (faster, cheaper).

---

### IAM (Identity & Access Management)

**What it is**: AWS's permission system (who can do what)

**Lambda needs permissions for**:
- Write logs to CloudWatch (`logs:CreateLogGroup`, `logs:PutLogEvents`)
- Read environment variables
- Access other services (S3, DynamoDB, etc.) if needed

**Least-privilege principle**: Grant only necessary permissions

**In this scenario**:
```json
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents"
  ],
  "Resource": "arn:aws:logs:*:*:*"
}
```

This allows Lambda to create and write to CloudWatch Logs **anywhere** (not just this function).

---

### CloudWatch Logs

**What it is**: Centralized log storage and analysis

**Lambda automatically sends**:
- `console.log()` output (Python: `print()`)
- Exceptions and errors
- Custom metrics (via structured logging)

**Access logs**:
```bash
# Stream logs in real-time
aws logs tail /aws/lambda/serverless-api-hello --follow

# Search for errors
aws logs filter-log-events \
  --log-group-name /aws/lambda/serverless-api-hello \
  --filter-pattern "ERROR"

# Get statistics
aws logs describe-log-groups
```

---

## 🔑 Key Concepts

### Lambda Handler Function

**Entry point** for invocation. Must accept `event` and `context`.

```python
def lambda_handler(event, context):
    # event: Depends on trigger
    #   - API Gateway: Contains method, path, query params, headers, body
    #   - S3: Contains bucket, key, action
    #   - DynamoDB Streams: Contains modified records
    #   - etc.
    
    # context: Lambda runtime metadata
    #   - context.function_name
    #   - context.function_version
    #   - context.invoked_function_arn
    #   - context.memory_limit_in_mb
    #   - context.get_remaining_time_in_millis()
    #   - etc.
    
    return {
        'statusCode': 200,
        'body': json.dumps({'key': 'value'})
    }
```

### Cold Start vs Warm Start

**Cold Start** (new container):
- Time: 100-1000ms (depends on runtime, code size, dependencies)
- Happens when: First invocation, or after period of inactivity, or concurrent spike requires new container
- Cost: Slightly higher (includes container initialization)

**Warm Start** (existing container):
- Time: 1-10ms (just function execution)
- Happens when: Container already running and available
- Cost: Lower (no initialization overhead)

**Optimization strategies**:
1. **Reduce code size**: Remove unused dependencies (use Lambda Layers)
2. **Use provisioned concurrency**: Keep containers warm (costs more)
3. **Increase memory**: Faster CPU = faster initialization
4. **Use lightweight runtime**: Python/Node.js faster than Java

---

### Environment Variables

**Use for configuration** (database URL, feature flags, etc.)

```hcl
resource "aws_lambda_function" "api" {
  # ...
  environment {
    variables = {
      DATABASE_URL = "postgresql://..."
      DEBUG_MODE   = "true"
      VERSION      = "1.0.0"
    }
  }
}
```

**Access in Python**:
```python
import os

db_url = os.environ.get('DATABASE_URL')
debug = os.environ.get('DEBUG_MODE') == 'true'
```

**Security**: Don't put secrets (passwords, API keys) in environment variables. Use AWS Secrets Manager or Parameter Store instead.

---

## 🧪 Testing & Verification

### Test Endpoints

**Create a file** `test.sh` (provided in this scenario):
```bash
bash test.sh http://localhost:4566/restapis
```

**Manual curl commands**:
```bash
# Simple request
curl http://localhost:4566/restapis/*/\_user_request_/hello

# Pretty-print JSON response
curl -s http://localhost:4566/restapis/*/\_user_request_/hello | jq .

# Check HTTP status
curl -i http://localhost:4566/restapis/*/\_user_request_/hello

# Test 404
curl http://localhost:4566/restapis/*/\_user_request_/nonexistent
```

### View Logs

```bash
# Real-time tail
aws --endpoint-url=http://localhost:4566 logs tail /aws/lambda/serverless-api-hello --follow

# Filter for errors
aws --endpoint-url=http://localhost:4566 logs filter-log-events \
  --log-group-name /aws/lambda/serverless-api-hello \
  --filter-pattern "ERROR"
```

### Performance Testing

```bash
# Install Apache Bench
sudo apt-get install apache2-utils

# Test with 100 requests, 10 concurrent
ab -n 100 -c 10 http://localhost:4566/restapis/*/\_user_request_/hello

# Expected:
# Requests per second: 50-100 (depends on cold starts)
# Average latency: 50-100ms (cold start) or 10-20ms (warm)
```

---

## 🚨 Common Issues & Solutions

### Issue 1: "404 Not Found" when accessing API

**Cause**: API Gateway URL incorrect, or Lambda not deployed

**Solution**:
```bash
# Verify Lambda function exists
aws --endpoint-url=http://localhost:4566 lambda list-functions

# Verify API Gateway exists
aws --endpoint-url=http://localhost:4566 apigatewayv2 get-apis

# Re-run setup
bash local-setup.sh
```

### Issue 2: Lambda execution times out (502 Bad Gateway)

**Cause**: Function takes > configured timeout (default 30s)

**Solution**:
```hcl
# Increase timeout in main.tf
variable "lambda_timeout" {
  default = 60  # Increase from 30
}

# Re-deploy
cd terraform && terraform apply && cd ..
```

### Issue 3: "Permission denied" errors in Lambda logs

**Cause**: Lambda execution role doesn't have required permissions

**Solution**:
```hcl
# Add IAM policy to main.tf (example: S3 read access)
resource "aws_iam_role_policy" "lambda_s3" {
  name = "lambda-s3-policy"
  role = aws_iam_role.lambda_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "s3:GetObject"
      Resource = "arn:aws:s3:::my-bucket/*"
    }]
  })
}
```

### Issue 4: Environment variables not accessible

**Cause**: Terraform didn't apply updated environment block

**Solution**:
```bash
# Verify environment vars in Lambda
aws --endpoint-url=http://localhost:4566 lambda get-function-configuration \
  --function-name serverless-api-hello | jq .Environment

# Re-apply Terraform
cd terraform && terraform apply -auto-approve && cd ..
```

### Issue 5: Cold start too slow

**Cause**: Lambda container initialization taking 500ms+

**Solution**:
```hcl
# Option 1: Increase memory (faster CPU)
variable "lambda_memory" {
  default = 512  # From 128, gives better performance
}

# Option 2: Add provisioned concurrency (keeps containers warm)
resource "aws_lambda_provisioned_concurrency_config" "api" {
  function_name                     = aws_lambda_function.api.function_name
  provisioned_concurrent_executions = 5
  qualifier                         = aws_lambda_alias.live.name
}
```

---

## 📊 Cost Analysis

### AWS Pricing (Real Cloud)

**Lambda compute**: $0.20 per 1M requests + $0.0000166667 per GB-second

**Example: 1M requests/month**
- Function memory: 128 MB
- Average duration: 50ms
- Compute: 1M requests × 50ms × 128MB / 1024 = 6,250 GB-seconds
- Cost: (1M × $0.20) + (6,250 × $0.0000166667) = **$200 + $0.10 = $200.10/month**

**Example: 10M requests/month** (higher volume)
- Compute: 62,500 GB-seconds
- Cost: (10M × $0.20) + (62,500 × $0.0000166667) = **$2,000 + $1.04 = $2,001.04/month**

**Free tier**: 1M free requests/month + 400,000 GB-seconds free

**API Gateway pricing**: $3.50 per million requests (HTTP API $0.35)

**Total monthly cost** (10M requests, HTTP API):
- Lambda: $2,001
- API Gateway: $35
- **Total: $2,036/month**

**Comparison to EC2 (Scenario 5)**:
- 3x t3.medium instances (always on): ~$60/month each = $180/month
- Fixed cost regardless of traffic
- Better for predictable, constant load

---

### LocalStack (Free, Local)

- Zero cost
- Unlimited requests/compute
- Perfect for learning and testing

---

## 🎓 Extensions & Challenges

### Challenge 1: Add a POST endpoint
```python
# Modify handler.py to accept POST /hello with JSON body
if method == 'POST' and path == '/hello':
    body = json.loads(event.get('body', '{}'))
    name = body.get('name', 'World')
    return handle_hello_with_name(name)
```

### Challenge 2: Add request validation
```python
# Validate name length, format
def validate_name(name):
    if not name or len(name) == 0:
        return False, "Name cannot be empty"
    if len(name) > 100:
        return False, "Name must be <= 100 characters"
    if not name.isalnum():
        return False, "Name must contain only alphanumeric characters"
    return True, ""
```

### Challenge 3: Add error handling
```python
# Return different responses for different error types
try:
    result = process_request(event)
except ValueError as e:
    return error_response(400, str(e))
except Exception as e:
    print(f"Unexpected error: {e}")
    return error_response(500, "Internal server error")
```

### Challenge 4: Add response caching
```hcl
# Cache /health endpoint response for 60 seconds
resource "aws_apigatewayv2_route" "health" {
  # ...
  
  # Add caching configuration (requires REST API, not HTTP API)
  method_responses = [{
    status_code = "200"
    response_models = {
      "application/json" = "Empty"
    }
  }]
}
```

### Challenge 5: Add metrics and monitoring
```python
# Send custom metric to CloudWatch
import boto3

cloudwatch = boto3.client('cloudwatch')

def record_metric(name, value):
    cloudwatch.put_metric_data(
        Namespace='ServerlessAPI',
        MetricData=[{
            'MetricName': name,
            'Value': value,
            'Unit': 'Count'
        }]
    )

# Usage
record_metric('HelloRequests', 1)
```

---

## 📚 Learning Resources

### Official AWS Documentation
- [Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/)
- [API Gateway for Lambda](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html)
- [Lambda Execution Roles](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)
- [CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/)

### Terraform Documentation
- [AWS Lambda Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)
- [API Gateway v2 Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api)
- [IAM Role Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)

### Performance & Cost Optimization
- [Lambda Performance Optimization](https://aws.amazon.com/blogs/compute/operating-lambda-performance-optimization-part-1/)
- [Lambda Cost Optimization](https://aws.amazon.com/blogs/compute/operating-lambda-performance-optimization-part-2/)
- [Cold Start Analysis](https://aws.amazon.com/blogs/compute/new-cold-start-benchmark-for-aws-lambda/)

---

## ✅ Completion Checklist

- [ ] LocalStack is running
- [ ] Terraform deploys Lambda + API Gateway successfully
- [ ] `GET /hello` returns greeting (HTTP 200)
- [ ] `GET /hello/{name}` works with path parameters
- [ ] `GET /health` returns service status
- [ ] `GET /nonexistent` returns 404
- [ ] CloudWatch Logs show function executions
- [ ] Can modify handler.py and re-deploy
- [ ] test.sh passes all tests
- [ ] terraform destroy cleans up resources
- [ ] You've modified and re-deployed at least once
- [ ] You understand cold starts vs warm starts
- [ ] You're ready for Scenario 3: Event-Driven Pipeline

---

## 🎉 Next Steps

**Congratulations!** You've completed Scenario 2. You now understand:
- Lambda function fundamentals (handler, runtime, invocation)
- API Gateway routing and configuration
- IAM execution roles and permissions
- CloudWatch Logs integration
- Terraform patterns for serverless

**Ready to level up?** → [Scenario 3: Event-Driven Pipeline](../03-event-driven/)

---

**Questions?** See [SCENARIOS.md](../../SCENARIOS.md) or [README.md](../../README.md)
