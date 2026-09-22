# Scenario 1: Static Website Hosting

**Difficulty**: ⭐ Beginner  
**Estimated Time**: 30-45 minutes  
**Services**: S3, CloudFront (optional)  
**Cost**: Free tier eligible

---

## 🎯 Learning Objectives

After completing this scenario, you'll understand:

- ✅ How to create an S3 bucket for website hosting
- ✅ S3 bucket policies (public read access)
- ✅ Static website hosting configuration
- ✅ How to upload and serve files via S3
- ✅ Terraform patterns for S3 resources
- ✅ Error document handling (404.html)

---

## 📋 Prerequisites

- Docker (for LocalStack/Floci emulator)
- Terraform 1.0+
- AWS CLI (optional, for manual verification)
- 30 minutes of uninterrupted time

---

## 🏗️ Architecture

```
User's Browser
    ↓
HTTP GET /index.html
    ↓
S3 Bucket (static website hosting enabled)
    ↓
Bucket Policy (allows public read)
    ↓
Return index.html, style.css, 404.html
```

**Key Components**:
1. **S3 Bucket**: Object storage (files are "objects")
2. **Bucket Policy**: JSON-based access control
3. **Static Hosting Config**: Points to index.html for `/` requests
4. **Error Document**: Serves 404.html for missing files

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
cd scenarios/01-static-website
bash local-setup.sh
```

This script will:
1. Initialize Terraform
2. Create S3 bucket + upload files
3. Configure public access
4. Enable static website hosting
5. Verify everything works

### Step 3: Access the Website
```bash
# Option 1: Via LocalStack endpoint
curl http://localhost:4566/my-website-bucket/index.html

# Option 2: Print the URL
terraform output access_instructions
```

### Step 4: Modify and Re-deploy
```bash
# Edit app/index.html
vim app/index.html

# Re-deploy (only changed files are uploaded)
cd terraform
terraform apply
```

### Step 5: Cleanup
```bash
terraform destroy -auto-approve
```

---

## 📚 Deep Dive: Understanding the Components

### S3 Bucket

**What it is**: Object storage service (like Dropbox/Google Drive for developers)

**Key properties**:
- **Global namespace**: Bucket names must be unique across AWS (all accounts, all regions)
- **Regions**: Choose where your data is stored (us-east-1, eu-west-1, etc.)
- **Objects**: Files stored in buckets (e.g., index.html, style.css, image.png)
- **Versioning**: Track previous versions of files (optional)
- **Lifecycle policies**: Auto-delete old files after N days

**In Terraform**:
```hcl
resource "aws_s3_bucket" "website" {
  bucket = "my-website-bucket"  # Must be globally unique!
  
  tags = {
    Name        = "my-website-bucket"
    Environment = "dev"
  }
}
```

### Bucket Policy (Public Access)

**What it is**: JSON-based access control (who can do what to what)

**Default**: S3 buckets are PRIVATE (nobody can access them)

**To make public**, add this policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-website-bucket/*"
    }
  ]
}
```

**Translation**: "Allow anyone (`Principal: "*"`) to read objects (`GetObject`) in my bucket"

**In Terraform**:
```hcl
resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website.id
  policy = jsonencode({
    # ... policy JSON above
  })
}
```

### Static Website Hosting

**What it is**: S3 feature that:
- Serves `index.html` when you request `/` (instead of listing bucket contents)
- Serves `404.html` when a file is not found
- Enables HTTP (not HTTPS) public access

**Enable in Terraform**:
```hcl
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id
  
  index_document {
    suffix = "index.html"  # Serve this for / requests
  }
  
  error_document {
    key = "404.html"  # Serve this for 404 errors
  }
}
```

### Upload Files to S3

**In Terraform**, upload files automatically:
```hcl
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"  # Path in bucket
  source       = "${path.module}/../app/index.html"  # Local file
  content_type = "text/html"
  etag         = filemd5("${path.module}/../app/index.html")  # Detect changes
}
```

The `etag` field tells Terraform: "Re-upload if the file has changed"

---

## 🔑 Key Concepts

### Object vs Bucket
- **Bucket**: Container (like a folder in Google Drive)
- **Object**: File (like index.html, style.css)

### Key (Path)
- In Terraform: `key = "index.html"`
- In browser: `https://bucket-name.s3.amazonaws.com/index.html`
- For static hosting: `/index.html` → shows as `/`

### Content-Type (MIME Type)
- `text/html` → Browser displays as HTML
- `text/css` → Browser parses as CSS
- `application/json` → Browser displays as JSON
- Wrong type → Browser downloads as file!

### Etag (Entity Tag)
- Hash of file contents
- Terraform uses it to detect changes
- If file changes → Terraform re-uploads automatically

---

## 🧪 Testing & Verification

### Test with curl
```bash
# Get index.html
curl http://localhost:4566/my-website-bucket/index.html

# Check HTTP status
curl -i http://localhost:4566/my-website-bucket/index.html

# Get a missing file (404)
curl http://localhost:4566/my-website-bucket/nonexistent.html
```

### Test with AWS CLI
```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test

# List buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# List files in bucket
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-website-bucket/

# Download a file
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-website-bucket/index.html index.html

# Upload a file
aws --endpoint-url=http://localhost:4566 s3 cp my-file.txt s3://my-website-bucket/
```

### Verify Terraform
```bash
cd terraform

# Validate syntax
terraform validate

# Check for issues
tflint .

# Preview changes (before applying)
terraform plan

# Show current resources
terraform show

# Show specific output
terraform output website_endpoint
```

---

## 🚨 Common Issues & Solutions

### Issue 1: "Access Denied" when accessing website

**Cause**: Bucket policy not applied or too restrictive

**Solution**:
```bash
# Check bucket policy
aws --endpoint-url=http://localhost:4566 s3api get-bucket-policy --bucket my-website-bucket

# Re-apply Terraform
cd terraform
terraform apply
```

### Issue 2: LocalStack not running

**Cause**: Docker container not started

**Solution**:
```bash
docker-compose -f docker-compose/aws.yml up -d
docker ps | grep floci  # Verify it's running
```

### Issue 3: File not found (404)

**Cause**: File not uploaded, or wrong bucket name

**Solution**:
```bash
# Check bucket contents
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-website-bucket/

# Re-upload manually
aws --endpoint-url=http://localhost:4566 s3 cp app/index.html s3://my-website-bucket/

# Or re-deploy with Terraform
cd terraform
terraform apply
```

### Issue 4: CSS not loading (blank page)

**Cause**: `Content-Type: text/css` not set, or wrong path

**Solution**:
```hcl
# Make sure content_type is correct in Terraform
resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.website.id
  key          = "style.css"
  source       = "${path.module}/../app/style.css"
  content_type = "text/css"  # Critical!
  etag         = filemd5("${path.module}/../app/style.css")
}
```

---

## 📊 Cost Analysis

### AWS (Real Cloud)

| Resource | Usage | Cost |
|----------|-------|------|
| S3 Storage | 1 MB/month | < $0.01 |
| GET requests | 1,000/month | < $0.01 |
| Data transfer (egress) | 10 GB/month | $0.90 |
| **Total** | | **~$1/month** |

**Free Tier**: 5 GB storage + 20,000 GET requests/month

### LocalStack (Free, Local)

- Zero cost (runs on your laptop)
- Unlimited storage/requests
- Perfect for learning

---

## 🎓 Extensions & Challenges

### Challenge 1: Add More Pages
```
Add about.html and contact.html
Link them from index.html
Deploy with Terraform
```

### Challenge 2: Add Images
```
Add a logo.png to app/
Upload via Terraform (content_type = "image/png")
Reference in index.html: <img src="logo.png" />
Verify it displays
```

### Challenge 3: Add CloudFront CDN
```
Create CloudFront distribution pointing to S3
Distribute content globally
Compare performance (edge location vs direct S3)
```

### Challenge 4: Custom Domain
```
Buy domain on Route53
Create Alias record pointing to S3 website
Test: https://my-domain.com
```

### Challenge 5: HTTPS/SSL
```
Create SSL certificate in ACM (AWS Certificate Manager)
Create CloudFront distribution with HTTPS
Test: https://my-domain.com (vs plain HTTP)
```

---

## 📚 Learning Resources

### Official AWS Documentation
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [S3 Bucket Policies](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-policies.html)
- [S3 Common Use Cases](https://docs.aws.amazon.com/AmazonS3/latest/userguide/use-cases.html)

### Terraform Documentation
- [AWS S3 Bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
- [AWS S3 Bucket Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)
- [AWS S3 Website Configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration)

### LocalStack Documentation
- [LocalStack S3](https://docs.localstack.cloud/user-guide/aws/s3/)
- [LocalStack CLI](https://docs.localstack.cloud/user-guide/integrations/aws-cli/)

---

## ✅ Completion Checklist

- [ ] LocalStack is running
- [ ] Terraform deploys S3 bucket successfully
- [ ] index.html is accessible via endpoint
- [ ] CSS loads correctly (page is styled)
- [ ] 404.html is served for missing pages
- [ ] Terraform can re-deploy (no errors)
- [ ] terraform destroy cleans up resources
- [ ] You've modified and re-deployed at least once
- [ ] You understand bucket policies
- [ ] You're ready for Scenario 2: Serverless API

---

## 🎉 Next Steps

**Congratulations!** You've completed Scenario 1. You now understand:
- S3 buckets and objects
- Bucket policies (public access)
- Static website hosting
- Terraform patterns for S3

**Ready to level up?** → [Scenario 2: Serverless API](../02-serverless-api/)

---

**Questions?** See [SCENARIOS.md](../../SCENARIOS.md) or [README.md](../../README.md)
