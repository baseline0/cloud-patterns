# Scenario 3: Event-Driven Architecture (S3 → SNS → Lambda)

**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 45-60 minutes  
**Services**: S3, SNS, Lambda, CloudWatch Logs, IAM  
**Cost**: Free tier eligible (S3: $0.023/GB, SNS: $0.50/million, Lambda: free 1M/month)

---

## 🎯 Learning Objectives

- ✅ S3 event notifications (ObjectCreated, ObjectRemoved, etc.)
- ✅ SNS pub/sub messaging (topics, subscriptions, filtering)
- ✅ Lambda triggers from SNS (async invocation, retry logic)
- ✅ Event-driven vs. request-driven architectures
- ✅ Decoupling producers from consumers
- ✅ Fan-out patterns (one topic → multiple subscribers)
- ✅ IAM permissions for cross-service triggers
- ✅ CloudWatch Logs for async debugging
- ✅ Retry logic and dead-letter queues
- ✅ Cost implications of event-driven systems

---

## 🏗️ Architecture

```
User uploads file
       ↓
S3 Bucket (uploads/ prefix)
       ↓ [s3:ObjectCreated:* event]
SNS Topic
       ↓ [automatic subscription]
Lambda Function (async)
       ↓
Process file (resize, parse, etc.)
       ↓
CloudWatch Logs
```

**Key Difference from Scenario 2**:
- **Scenario 2** (Lambda + API Gateway): Synchronous (user waits for response)
- **Scenario 3** (S3 → SNS → Lambda): Asynchronous (file uploads trigger background processing)

---

## 🚀 Quick Start

```bash
# 1. Start emulator
docker-compose -f ../../docker-compose/aws.yml up -d

# 2. Deploy scenario
cd scenarios/03-event-driven
bash local-setup.sh

# 3. Upload test file
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://event-driven-uploads-bucket/uploads/test.txt

# 4. View Lambda logs in real-time
aws --endpoint-url=http://localhost:4566 logs tail /aws/lambda/file-processor-function --follow

# 5. Try different file types
aws --endpoint-url=http://localhost:4566 s3 cp image.jpg s3://event-driven-uploads-bucket/uploads/image.jpg
aws --endpoint-url=http://localhost:4566 s3 cp data.csv s3://event-driven-uploads-bucket/uploads/data.csv
```

---

## 📚 Deep Dive: Event-Driven Architecture

### S3 Event Notifications

**What**: S3 publishes events when objects are created/deleted/modified

**Event Types**:
- `s3:ObjectCreated:*` — Any put/post/copy to new object
- `s3:ObjectRemoved:*` — Delete or lifecycle expiration
- `s3:ObjectRestore:*` — Restore from Glacier

**Destinations** (SNS, SQS, Lambda):
```
S3 Object Event → SNS Topic → Lambda Function
                            → SQS Queue
                            → Email notification
```

**In this scenario**: S3 → SNS → Lambda

---

### SNS Pub/Sub Messaging

**What**: Decouples message producers from consumers

**Benefits**:
1. **Decoupling**: S3 doesn't know about Lambda (or vice versa)
2. **Fan-out**: One event → multiple consumers
3. **Retry logic**: Automatic retries with exponential backoff
4. **Filtering**: Subscribers receive only matching messages

**Subscription Types**:
- Lambda (async invocation)
- SQS (queue for buffering)
- Email/SMS (notifications)
- HTTPS (webhooks)
- Application (any protocol)

**In this scenario**: SNS Topic subscribed by Lambda Function

---

### Lambda Trigger from SNS

**Invocation Format**:
```json
{
  "Records": [
    {
      "Sns": {
        "Message": "{\"Records\":[{\"s3\":{\"bucket\":{\"name\":\"my-bucket\"},\"object\":{\"key\":\"file.txt\"}}}]}"
      }
    }
  ]
}
```

**Key Points**:
- SNS wraps S3 event in "Records" array
- Message is JSON string (not object) → Must parse
- Multiple events can arrive in single invocation

---

### Event-Driven vs. Request-Driven

| Aspect | Request-Driven (API) | Event-Driven (SNS) |
|--------|---------------------|-------------------|
| Trigger | HTTP request | Event (file upload) |
| Response | Synchronous | Asynchronous |
| Latency | Immediate | 1-100ms delay |
| Error handling | Return 500 | Auto-retry |
| Scaling | Request-based | Event-based |
| Cost model | Per-request | Per-event |
| Use case | User actions | Background processing |

**When to use event-driven**:
- Image resizing after upload
- Data validation and transformation
- Cross-system notifications
- Batch processing
- Asynchronous workflows

---

## 🧪 Testing & Verification

### Test 1: Simple Upload

```bash
echo "test content" > test.txt
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://event-driven-uploads-bucket/uploads/test.txt
```

**Expected logs**:
```
Event: ObjectCreated:Put | Bucket: event-driven-uploads-bucket | Key: uploads/test.txt
[FILE] Processing: uploads/test.txt
✓ Processed: uploads/test.txt
```

### Test 2: Image File

```bash
# Create dummy image
echo "fake image data" > image.jpg
aws --endpoint-url=http://localhost:4566 s3 cp image.jpg s3://event-driven-uploads-bucket/uploads/image.jpg
```

**Expected logs**:
```
[IMAGE] Processing: uploads/image.jpg
→ Would resize image, generate thumbnail
✓ Processed: uploads/image.jpg
```

### Test 3: Data File

```bash
echo "name,age
Alice,30
Bob,25" > data.csv
aws --endpoint-url=http://localhost:4566 s3 cp data.csv s3://event-driven-uploads-bucket/uploads/data.csv
```

**Expected logs**:
```
[DATA] Processing: uploads/data.csv
→ Would parse data, validate schema, load to DB
✓ Processed: uploads/data.csv
```

---

## 🚨 Common Issues & Solutions

### Issue 1: Lambda Not Invoked

**Symptom**: File uploaded, but no CloudWatch logs

**Solutions**:
```bash
# Verify SNS subscription exists
aws --endpoint-url=http://localhost:4566 sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:000000000000:file-uploads-topic

# Verify Lambda has permission to be invoked by SNS
aws --endpoint-url=http://localhost:4566 lambda get-policy \
  --function-name file-processor-function

# Re-deploy
cd terraform && terraform apply && cd ..
```

### Issue 2: S3 Event Not Published

**Symptom**: SNS topic has no activity

**Solutions**:
```bash
# Check bucket notification config
aws --endpoint-url=http://localhost:4566 s3api get-bucket-notification-configuration \
  --bucket event-driven-uploads-bucket

# Verify file uploaded to correct prefix (must be "uploads/")
aws --endpoint-url=http://localhost:4566 s3 ls s3://event-driven-uploads-bucket/uploads/

# Upload to wrong prefix won't trigger
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://event-driven-uploads-bucket/test.txt  # Won't trigger!
```

### Issue 3: Lambda Timeout

**Symptom**: Lambda runs but times out after 10 seconds

**Solution**:
```hcl
# In variables.tf, increase timeout
variable "lambda_timeout" {
  default = 30  # Increase from 10
}

# Re-deploy
cd terraform && terraform apply && cd ..
```

### Issue 4: SNS Retry Loop

**Symptom**: Lambda invoked repeatedly for same event

**Solution**:
Always return 200, even on error:
```python
try:
    process_event(event)
except Exception as e:
    logger.error(f"Error: {e}")
    # Still return 200 to acknowledge
    return {"statusCode": 200, "error": str(e)}
```

### Issue 5: Message Format Error

**Symptom**: "json.JSONDecodeError" in Lambda logs

**Solution**:
SNS wraps message as JSON string:
```python
# Correct
sns_message = record.get("Sns", {}).get("Message", "")
s3_event = json.loads(sns_message)  # Parse string

# Wrong (direct access)
s3_event = record.get("Sns", {}).get("Message")  # Still a string!
```

---

## 📊 Cost Analysis

### AWS (Production, 1M events/month)

| Component | Cost |
|-----------|------|
| S3 storage (100 GB) | $2.30 |
| S3 requests (1M) | $0.40 |
| SNS (1M events) | $0.50 |
| Lambda (128MB, 100ms each) | $0.20 |
| CloudWatch Logs (5 GB) | $0.50 |
| **Total** | **$3.90/month** |

**Free tier covers**: 5 GB S3 + 1M requests + 1M SNS + 1M Lambda invocations

### Comparison: Event-Driven vs. Polling

**Polling** (Lambda checks S3 every minute):
- 1,440 invocations/day × 30 days = 43,200 invocations/month
- 99% are wasted (no new files)
- Cost: ~$8.64/month

**Event-Driven** (Lambda only on upload):
- 1,000 events/month (realistic)
- 0% wasted
- Cost: ~$0.02/month

**Savings**: Event-driven is **400x cheaper** for sporadic workloads

---

## 🎓 Extensions & Challenges

### Challenge 1: Add Email Notifications

Subscribe your email to SNS:
```bash
aws --endpoint-url=http://localhost:4566 sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:000000000000:file-uploads-topic \
  --protocol email \
  --notification-endpoint your-email@example.com
```

Upload file → Get email notification

### Challenge 2: Multi-Subscriber Fan-Out

Create multiple Lambda functions subscribed to same SNS topic:
```hcl
# Lambda 1: Image processor
resource "aws_sns_topic_subscription" "image_processor" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.image_processor.arn
}

# Lambda 2: Data validator
resource "aws_sns_topic_subscription" "data_validator" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.data_validator.arn
}

# One file upload → Both Lambdas invoked
```

### Challenge 3: Message Filtering

Filter events by file extension:
```hcl
resource "aws_sns_topic_subscription" "image_processor" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.image_processor.arn
  
  filter_policy = jsonencode({
    eventName = ["ObjectCreated:Put"]
  })
}
```

### Challenge 4: Add SQS Buffer

Insert queue between SNS and Lambda (buffering + rate limiting):
```
S3 → SNS → SQS Queue → Lambda
                ↓
          (Decouple peak load)
```

### Challenge 5: Dead-Letter Queue (DLQ)

Capture failed Lambda invocations:
```hcl
resource "aws_sqs_queue" "dlq" {
  name = "file-processor-dlq"
}

resource "aws_sns_topic_subscription" "lambda_sub" {
  # ...
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
  })
}
```

---

## 📚 References

- [S3 Event Notifications](https://docs.aws.amazon.com/AmazonS3/latest/userguide/NotificationHowTo.html)
- [SNS Developer Guide](https://docs.aws.amazon.com/sns/latest/dg/)
- [Lambda SNS Integration](https://docs.aws.amazon.com/lambda/latest/dg/with-sns.html)
- [Fan-Out Pattern](https://aws.amazon.com/blogs/compute/fan-out-messages-to-multiple-endpoints-with-amazon-sns/)
- [Event-Driven Architecture](https://aws.amazon.com/event-driven-architecture/)

---

## ✅ Completion Checklist

- [ ] Terraform deploys S3 + SNS + Lambda + IAM
- [ ] S3 bucket created with correct name
- [ ] SNS topic subscribed to by Lambda
- [ ] Lambda function invoked on file upload
- [ ] CloudWatch logs show file processing
- [ ] Can upload different file types (jpg, csv, txt)
- [ ] Error handling returns 200 (no retry loop)
- [ ] terraform destroy cleans up resources
- [ ] You've tested multiple scenarios
- [ ] You understand event-driven vs. request-driven
- [ ] Ready for Scenario 4: Database + CRUD API

---

## 🎉 Next Steps

Congratulations! You now understand:
- Event-driven architecture (producer → event → consumer)
- S3 event notifications and SNS pub/sub
- Lambda async invocation and retry logic
- Decoupling and fan-out patterns

**Ready for more?** → [Scenario 4: Database + CRUD API](../04-crud-api/)

---

**Questions?** See [SCENARIOS.md](../../SCENARIOS.md) or [README.md](../../README.md)
