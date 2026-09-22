#!/bin/bash
set -e

# Scenario 1: Static Website Hosting - Local Setup

echo "🚀 Starting Scenario 1: Static Website Hosting"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BUCKET_NAME="my-website-bucket"
LOCALSTACK_URL="http://localhost:4566"
AWS_REGION="us-east-1"

# Set AWS credentials for LocalStack
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=$AWS_REGION

# Step 1: Check if LocalStack is running
echo -e "${BLUE}Step 1: Checking LocalStack connection...${NC}"
if ! curl -s $LOCALSTACK_URL/_localstack/health > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  LocalStack is not running!${NC}"
    echo "Start LocalStack with:"
    echo "  docker-compose -f docker-compose/aws.yml up -d"
    echo ""
    echo "Or run manually:"
    echo "  docker run -p 4566:4566 localstack/localstack"
    exit 1
fi
echo -e "${GREEN}✅ LocalStack is running${NC}"
echo ""

# Step 2: Initialize Terraform
echo -e "${BLUE}Step 2: Initializing Terraform...${NC}"
cd terraform
terraform init -upgrade
cd ..
echo -e "${GREEN}✅ Terraform initialized${NC}"
echo ""

# Step 3: Plan deployment
echo -e "${BLUE}Step 3: Planning deployment...${NC}"
cd terraform
terraform plan -var="bucket_name=$BUCKET_NAME" -var="use_localstack=true" -out=tfplan
cd ..
echo -e "${GREEN}✅ Plan created (tfplan)${NC}"
echo ""

# Step 4: Apply deployment
echo -e "${BLUE}Step 4: Deploying S3 bucket and files...${NC}"
cd terraform
terraform apply -auto-approve tfplan
cd ..
echo -e "${GREEN}✅ Deployment complete${NC}"
echo ""

# Step 5: Verify bucket and files
echo -e "${BLUE}Step 5: Verifying S3 bucket and contents...${NC}"
BUCKET_LIST=$(aws --endpoint-url=$LOCALSTACK_URL s3 ls | grep "$BUCKET_NAME")
if [ -n "$BUCKET_LIST" ]; then
    echo -e "${GREEN}✅ Bucket created: $BUCKET_NAME${NC}"
else
    echo -e "${YELLOW}⚠️  Bucket not found. Check Terraform output.${NC}"
    exit 1
fi

FILES=$(aws --endpoint-url=$LOCALSTACK_URL s3 ls "s3://$BUCKET_NAME/" | awk '{print $4}')
echo "Files in bucket:"
echo "$FILES" | sed 's/^/  - /'
echo ""

# Step 6: Get website endpoint
echo -e "${BLUE}Step 6: Getting website endpoint...${NC}"
WEBSITE_ENDPOINT="$LOCALSTACK_URL/$BUCKET_NAME/index.html"
echo -e "${GREEN}✅ Website URL: $WEBSITE_ENDPOINT${NC}"
echo ""

# Step 7: Test access
echo -e "${BLUE}Step 7: Testing website access...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$WEBSITE_ENDPOINT")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Website is accessible (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${YELLOW}⚠️  Website returned HTTP $HTTP_CODE${NC}"
fi
echo ""

# Step 8: Display summary
echo -e "${BLUE}📋 Summary${NC}"
echo "================================"
echo -e "Bucket: ${GREEN}$BUCKET_NAME${NC}"
echo -e "URL: ${GREEN}$WEBSITE_ENDPOINT${NC}"
echo -e "Region: ${GREEN}$AWS_REGION${NC}"
echo -e "Endpoint: ${GREEN}$LOCALSTACK_URL${NC}"
echo ""
echo -e "${GREEN}✅ Scenario 1 setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Open in browser: curl $WEBSITE_ENDPOINT"
echo "  2. Upload a new file: aws --endpoint-url=$LOCALSTACK_URL s3 cp <file> s3://$BUCKET_NAME/"
echo "  3. Modify Terraform and re-deploy: cd terraform && terraform apply"
echo "  4. Cleanup: terraform destroy"
echo ""
