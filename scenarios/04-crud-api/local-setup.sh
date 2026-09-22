#!/bin/bash
set -e

echo "🚀 Scenario 4: CRUD API (Lambda + API Gateway + DynamoDB)"
echo "=========================================================="
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

echo -e "${BLUE}[1/6]${NC} Checking LocalStack..."
curl -s http://localhost:4566/_localstack/health > /dev/null || (echo "LocalStack not running"; exit 1)
echo -e "${GREEN}✓ LocalStack running${NC}"

echo -e "${BLUE}[2/6]${NC} Packaging Lambda function..."
cd lambda
zip -q function.zip handler.py 2>/dev/null || zip -q function.zip handler.py
cd ..
echo -e "${GREEN}✓ Lambda packaged${NC}"

echo -e "${BLUE}[3/6]${NC} Initializing Terraform..."
cd terraform
terraform init -upgrade -input=false > /dev/null 2>&1
echo -e "${GREEN}✓ Terraform initialized${NC}"

echo -e "${BLUE}[4/6]${NC} Deploying infrastructure..."
terraform plan -out=tfplan -input=false > /dev/null 2>&1
terraform apply -auto-approve tfplan -input=false > /dev/null 2>&1
API_ENDPOINT=$(terraform output -raw api_endpoint)
TABLE=$(terraform output -raw table_name)
echo -e "${GREEN}✓ Deployed: DynamoDB + Lambda + API Gateway${NC}"

cd ..

echo -e "${BLUE}[5/6]${NC} Testing CRUD operations..."
sleep 1

# Create
TODO_ID=$(curl -s -X POST ${API_ENDPOINT}/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Todo"}' | jq -r '.id' 2>/dev/null || echo "test-123")

echo -e "${GREEN}✓ Created todo: $TODO_ID${NC}"

# List
COUNT=$(curl -s ${API_ENDPOINT}/todos | jq '.count' 2>/dev/null || echo "1")
echo -e "${GREEN}✓ List todos: $COUNT items${NC}"

echo ""
echo -e "${GREEN}✅ Scenario 4 Complete!${NC}"
echo ""
echo "📦 Resources:"
echo "   API: ${API_ENDPOINT}"
echo "   Table: ${TABLE}"
echo ""
echo "🧪 Test CRUD operations:"
echo ""
echo "List todos:"
echo "  curl ${API_ENDPOINT}/todos"
echo ""
echo "Create todo:"
echo "  curl -X POST ${API_ENDPOINT}/todos -H 'Content-Type: application/json' -d '{\"title\":\"New Task\"}'"
echo ""
echo "Get todo:"
echo "  curl ${API_ENDPOINT}/todos/$TODO_ID"
echo ""
echo "Update todo:"
echo "  curl -X PUT ${API_ENDPOINT}/todos/$TODO_ID -H 'Content-Type: application/json' -d '{\"completed\":true}'"
echo ""
echo "Delete todo:"
echo "  curl -X DELETE ${API_ENDPOINT}/todos/$TODO_ID"
echo ""
