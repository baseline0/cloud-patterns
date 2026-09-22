#!/bin/bash

# Test script for Serverless API endpoints
# Run after local-setup.sh completes

API_ENDPOINT="${1:-http://localhost:4566/restapis}"

echo "🧪 Testing Serverless API"
echo "API Endpoint: $API_ENDPOINT"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counter
PASSED=0
FAILED=0

test_endpoint() {
    local method=$1
    local path=$2
    local expected_status=$3
    local description=$4

    echo -e "${BLUE}Test: $description${NC}"
    echo "  $method $path"

    HTTP_CODE=$(curl -s -o /tmp/response.json -w "%{http_code}" -X "$method" "$API_ENDPOINT$path")
    RESPONSE=$(cat /tmp/response.json)

    if [ "$HTTP_CODE" = "$expected_status" ]; then
        echo -e "  ${GREEN}✅ HTTP $HTTP_CODE (expected $expected_status)${NC}"
        echo "  Response: $(echo $RESPONSE | jq -c . 2>/dev/null || echo $RESPONSE | head -c 80)"
        ((PASSED++))
    else
        echo -e "  ${RED}❌ HTTP $HTTP_CODE (expected $expected_status)${NC}"
        echo "  Response: $RESPONSE"
        ((FAILED++))
    fi
    echo ""
}

# Run tests
test_endpoint "GET" "/hello" "200" "GET /hello - Simple greeting"
test_endpoint "GET" "/hello?name=Alice" "200" "GET /hello?name=Alice - With query param"
test_endpoint "GET" "/hello/Bob" "200" "GET /hello/Bob - With path param"
test_endpoint "GET" "/health" "200" "GET /health - Health check"
test_endpoint "GET" "/nonexistent" "404" "GET /nonexistent - Not found"

# Summary
echo -e "${BLUE}📊 Test Summary${NC}"
echo "================================"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
