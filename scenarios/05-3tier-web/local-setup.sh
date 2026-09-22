#!/bin/bash
set -e

echo "🚀 Scenario 5: 3-Tier Web App - Setup"
echo "========================================"

# Step 1: Initialize Terraform
cd terraform
echo "📦 Initializing Terraform..."
terraform init -upgrade

# Step 2: Plan infrastructure
echo "📋 Planning infrastructure..."
terraform plan -out=tfplan

# Step 3: Apply infrastructure
echo "🔨 Deploying infrastructure..."
terraform apply -auto-approve tfplan

# Step 4: Extract outputs
ALB_DNS=$(terraform output -raw alb_dns_name)
DB_ENDPOINT=$(terraform output -raw db_endpoint)
echo "✅ Infrastructure deployed!"
echo "   ALB DNS: $ALB_DNS"
echo "   DB Endpoint: $DB_ENDPOINT"

cd ..

# Step 5: Wait for ALB health checks
echo "⏳ Waiting for ALB to stabilize (30s)..."
sleep 30

# Step 6: Test application
echo "🧪 Testing application..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$ALB_DNS/" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Application is healthy (HTTP $HTTP_CODE)"
else
    echo "⚠️  Application returned HTTP $HTTP_CODE (expected 200)"
    echo "   Check: curl http://$ALB_DNS/"
fi

# Step 7: Show next steps
echo ""
echo "📚 Next steps:"
echo "   1. Monitor ALB: terraform output alb_dns_name"
echo "   2. SSH to instance: aws ec2-instance-connect open-session --instance-ids <id>"
echo "   3. Cleanup: cd terraform && terraform destroy"
echo ""
echo "✨ Scenario 5 deployment complete!"
