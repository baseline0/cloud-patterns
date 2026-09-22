#!/bin/bash
set -e

# Scenario 2: Serverless API (Lambda + API Gateway) - Local Setup

echo "🚀 Starting Scenario 2: Serverless API"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
FUNCTION_NAME="serverless-api-hello"
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
    exit 1
fi
echo -e "${GREEN}✅ LocalStack is running${NC}"
echo ""

# Step 2: Prepare Lambda function package
echo -e "${BLUE}Step 2: Preparing Lambda function package...${NC}"
cd lambda
zip -q function.zip handler.py
echo -e "${GREEN}✅ Function package created (handler.py → function.zip)${NC}"
cd ..
echo ""

# Step 3: Initialize Terraform
echo -e "${BLUE}Step 3: Initializing Terraform...${NC}"
cd terraform
terraform init -upgrade
cd ..
echo -e "${GREEN}✅ Terraform initialized${NC}"
echo ""

# Step 4: Plan deployment
echo -e "${BLUE}Step 4: Planning deployment...${NC}"
cd terraform
terraform plan -var="function_name=$FUNCTION_NAME" -var="use_localstack=true" -out=tfplan
cd ..
echo -e "${GREEN}✅ Plan created (tfplan)${NC}"
echo ""

# Step 5: Apply deployment
echo -e "${BLUE}Step 5: Deploying Lambda function and API Gateway...${NC}"
cd terraform
terraform apply -auto-approve tfplan
cd ..
echo -e "${GREEN}✅ Deployment complete${NC}"
echo ""

# Step 6: Get API endpoint
echo -e "${BLUE}Step 6: Retrieving API endpoint...${NC}"
cd terraform
API_ENDPOINT=$(terraform output -raw api_endpoint 2>/dev/null || echo "")
cd ..

if [ -z "$API_ENDPOINT" ]; then
    API_ENDPOINT="$LOCALSTACK_URL/restapis/*/_user_request_"
    echo -e "${YELLOW}⚠️  Could not retrieve endpoint from Terraform${NC}"
else
    echo -e "${GREEN}✅ API endpoint: $API_ENDPOINT${NC}"
fi
echo ""

# Step 7: Wait for services to be ready
echo -e "${BLUE}Step 7: Waiting for services to be ready...${NC}"
sleep 2
echo -e "${GREEN}✅ Ready${NC}"
echo ""

# Step 8: Test basic connectivity
echo -e "${BLUE}Step 8: Testing API endpoints...${NC}"
echo ""

# Test 1: GET /hello
echo -e "${BLUE}Test 1: GET /hello${NC}"
RESPONSE=$(curl -s -X GET "$API_ENDPOINT/hello" 2>&1 || echo "")
if echo "$RESPONSE" | grep -q "Hello"; then
    echo -e "${GREEN}✅ Success${NC}"
    echo "Response: $RESPONSE" | head -c 100
    echo ""
else
    echo -e "${YELLOW}⚠️  Response: $RESPONSE${NC}"
fi
echo ""

# Test 2: GET /hello/Alice
echo -e "${BLUE}Test 2: GET /hello/Alice${NC}"
RESPONSE=$(curl -s -X GET "$API_ENDPOINT/hello/Alice" 2>&1 || echo "")
if echo "$RESPONSE" | grep -q "Alice"; then
    echo -e "${GREEN}✅ Success${NC}"
    echo "Response: $RESPONSE" | head -c 100
    echo ""
else
    echo -e "${YELLOW}⚠️  Response: $RESPONSE${NC}"
fi
echo ""

# Test 3: GET /health
echo -e "${BLUE}Test 3: GET /health${NC}"
RESPONSE=$(curl -s -X GET "$API_ENDPOINT/health" 2>&1 || echo "")
if echo "$RESPONSE" | grep -q "healthy"; then
    echo -e "${GREEN}✅ Success${NC}"
    echo "Response: $RESPONSE" | head -c 100
    echo ""
else
    echo -e "${YELLOW}⚠️  Response: $RESPONSE${NC}"
fi
echo ""

# Test 4: GET /nonexistent (404)
echo -e "${BLUE}Test 4: GET /nonexistent (expect 404)${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$API_ENDPOINT/nonexistent" 2>&1 || echo "000")
if [ "$HTTP_CODE" = "404" ]; then
    echo -e "${GREEN}✅ Correctly returned 404${NC}"
else
    echo -e "${YELLOW}⚠️  Expected 404, got $HTTP_CODE${NC}"
fi
echo ""

# Step 9: Display summary
echo -e "${BLUE}📋 Summary${NC}"
echo "================================"
echo -e "Function: ${GREEN}$FUNCTION_NAME${NC}"
echo -e "API Endpoint: ${GREEN}$API_ENDPOINT${NC}"
echo -e "Region: ${GREEN}$AWS_REGION${NC}"
echo -e "LocalStack: ${GREEN}$LOCALSTACK_URL${NC}"
echo ""
echo -e "${GREEN}✅ Scenario 2 setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. View Lambda code: cat lambda/handler.py"
echo "  2. View Terraform config: cat terraform/main.tf"
echo "  3. Test endpoints manually:"
echo "     curl $API_ENDPOINT/hello"
echo "     curl '$API_ENDPOINT/hello?name=Bob'"
echo "     curl $API_ENDPOINT/hello/Charlie"
echo "     curl $API_ENDPOINT/health"
echo "  4. View logs: aws --endpoint-url=$LOCALSTACK_URL logs tail /aws/lambda/$FUNCTION_NAME --follow"
echo "  5. Modify handler.py and re-deploy:"
echo "     cd lambda && zip -q function.zip handler.py && cd .."
echo "     cd terraform && terraform apply -auto-approve && cd .."
echo "  6. Cleanup: terraform destroy -auto-approve"
echo ""
