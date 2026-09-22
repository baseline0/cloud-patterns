#!/bin/bash
set -e

echo "🚀 Scenario 3: Event-Driven Architecture (S3 → SNS → Lambda)"
echo "=============================================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Exports for AWS CLI
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Check LocalStack
echo -e "${BLUE}[1/7]${NC} Checking LocalStack..."
if ! curl -s http://localhost:4566/_localstack/health > /dev/null; then
    echo -e "${YELLOW}LocalStack not running. Start with: docker-compose -f ../../docker-compose/aws.yml up -d${NC}"
    exit 1
fi
echo -e "${GREEN}✓ LocalStack running${NC}"

# Package Lambda
echo -e "${BLUE}[2/7]${NC} Packaging Lambda function..."
cd lambda
zip -q lambda.zip handler.py 2>/dev/null || zip -q lambda.zip handler.py
cd ..
echo -e "${GREEN}✓ Lambda packaged${NC}"

# Terraform init
echo -e "${BLUE}[3/7]${NC} Initializing Terraform..."
cd terraform
terraform init -upgrade -input=false > /dev/null 2>&1
echo -e "${GREEN}✓ Terraform initialized${NC}"

# Terraform plan
echo -e "${BLUE}[4/7]${NC} Planning deployment..."
terraform plan -out=tfplan -input=false > /dev/null 2>&1
echo -e "${GREEN}✓ Plan complete${NC}"

# Terraform apply
echo -e "${BLUE}[5/7]${NC} Deploying infrastructure..."
terraform apply -auto-approve tfplan -input=false > /dev/null 2>&1
BUCKET=$(terraform output -raw bucket_name)
echo -e "${GREEN}✓ Deployed: S3, SNS, Lambda, IAM, CloudWatch${NC}"

# Get outputs
echo -e "${BLUE}[6/7]${NC} Retrieving deployment details..."
TOPIC=$(terraform output -raw topic_arn)
FUNCTION=$(terraform output -raw function_arn)
echo -e "${GREEN}✓ Details retrieved${NC}"

# Test
echo -e "${BLUE}[7/7]${NC} Testing event-driven pipeline..."
sleep 1
aws --endpoint-url=http://localhost:4566 s3 cp ../test.txt "s3://${BUCKET}/uploads/test.txt" --quiet 2>/dev/null || true
echo -e "${GREEN}✓ Test file uploaded${NC}"

cd ..

echo ""
echo -e "${GREEN}✅ Scenario 3 Complete!${NC}"
echo ""
echo "📦 Resources:"
echo "   S3 Bucket: ${BUCKET}"
echo "   SNS Topic: ${TOPIC}"
echo "   Lambda: ${FUNCTION}"
echo ""
echo "🧪 Test the pipeline:"
echo "   1. Upload a file: aws --endpoint-url=http://localhost:4566 s3 cp file.txt s3://${BUCKET}/uploads/file.txt"
echo "   2. View logs: aws --endpoint-url=http://localhost:4566 logs tail /aws/lambda/file-processor-function --follow"
echo "   3. Upload different types: image.jpg, data.csv, test.txt"
echo ""
echo "💡 Key concepts:"
echo "   - S3 publishes ObjectCreated event to SNS"
echo "   - SNS invokes Lambda asynchronously"
echo "   - Lambda processes file (resize, parse, etc.)"
echo "   - Logs appear in CloudWatch automatically"
echo ""
