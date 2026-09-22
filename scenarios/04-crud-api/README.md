# Scenario 4: Database + CRUD API (DynamoDB + Lambda + API Gateway)

**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 60-75 minutes  
**Services**: DynamoDB, Lambda, API Gateway, CloudWatch, IAM  
**Cost**: Free tier eligible (1M requests + 25 GB storage free)

---

## 🎯 Learning Objectives

- ✅ DynamoDB fundamentals (partition key, item structure, global secondary indexes)
- ✅ CRUD operations (Create, Read, Update, Delete)
- ✅ Lambda + DynamoDB integration with boto3
- ✅ API Gateway request routing (POST, GET, PUT, DELETE)
- ✅ Request validation and error handling
- ✅ Query string parameters and path parameters
- ✅ Database schema design (NoSQL vs. SQL)
- ✅ Transactions vs. eventual consistency
- ✅ Data modeling (partition keys, sort keys, GSI)
- ✅ Cost implications of serverless databases

---

## 🏗️ Architecture

```
Client Request (HTTP)
    ↓
API Gateway (route by method + path)
    ↓
Lambda Function (CRUD logic)
    ↓
DynamoDB Table (todos)
    ↓
Response (JSON with status code)
```

**Endpoints**:
- `GET /todos` → List all todos
- `POST /todos` → Create new todo
- `GET /todos/{id}` → Get specific todo
- `PUT /todos/{id}` → Update todo
- `DELETE /todos/{id}` → Delete todo

---

## 🚀 Quick Start

```bash
# 1. Start LocalStack
docker-compose -f ../../docker-compose/aws.yml up -d

# 2. Deploy scenario
bash local-setup.sh

# 3. Test CRUD operations
curl ${API_ENDPOINT}/todos  # List

curl -X POST ${API_ENDPOINT}/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Buy groceries"}'  # Create

curl -X PUT ${API_ENDPOINT}/todos/todo-id \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'  # Update

curl -X DELETE ${API_ENDPOINT}/todos/todo-id  # Delete
```

---

## 📚 Deep Dive: DynamoDB

### What is DynamoDB?

**Managed NoSQL database** (AWS-proprietary):
- **Schemaless**: Add fields dynamically
- **Serverless**: Auto-scaling, no capacity planning
- **Fast**: Microsecond latency
- **Distributed**: Replicates across Availability Zones

### Key Concepts

**Partition Key** (required):
- Determines which partition stores the item
- Must be unique per item
- Hash-based distribution
- Example: `id` (UUID)

**Sort Key** (optional):
- Sorts items within partition
- Enables range queries
- Example: `created_at` (timestamp)

**Global Secondary Index (GSI)**:
- Alternative partition/sort key pair
- Enables different query patterns
- Example: Query todos by `created_at` instead of `id`

**Item Structure**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Buy groceries",
  "completed": false,
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

### DynamoDB vs. SQL Database

| Aspect | DynamoDB | SQL (RDS) |
|--------|----------|-----------|
| Schema | Schemaless | Fixed schema |
| Scaling | Automatic (serverless) | Manual (provisioned capacity) |
| Queries | Get by key, Scan, Query | Complex joins, WHERE clauses |
| Consistency | Eventual (default) | Strong consistency |
| Cost | Pay per request | Pay per instance hour |
| Latency | Milliseconds | Milliseconds to seconds |

**When to use DynamoDB**:
- High-scale applications (millions of requests/day)
- Key-value lookups (user profiles, sessions)
- Real-time analytics
- Mobile/IoT applications

**When to use SQL**:
- Complex queries (joins, aggregations)
- Transaction guarantees
- Reporting and analytics
- Small to medium scale

---

## CRUD Operations

### Create (POST /todos)

```python
def create_todo(event):
    body = json.loads(event.get('body', '{}'))
    title = body.get('title', '').strip()
    
    # Validation
    if not title or len(title) == 0:
        return error_response(400, "Title is required")
    
    # Generate ID
    todo_id = str(uuid.uuid4())
    now = datetime.utcnow().isoformat() + "Z"
    
    # Create item
    todo = {
        'id': todo_id,
        'title': title,
        'completed': False,
        'created_at': now,
        'updated_at': now
    }
    
    # Write to DynamoDB
    table.put_item(Item=todo)
    return success_response(todo, status_code=201)
```

### Read (GET /todos/{id})

```python
def get_todo(todo_id):
    response = table.get_item(Key={'id': todo_id})
    
    if 'Item' not in response:
        return error_response(404, f"Todo {todo_id} not found")
    
    return success_response(response['Item'])
```

### Update (PUT /todos/{id})

```python
def update_todo(todo_id, event):
    body = json.loads(event.get('body', '{}'))
    
    # Build update expression dynamically
    update_expr = "SET updated_at = :now"
    expr_values = {':now': datetime.utcnow().isoformat() + "Z"}
    
    if 'title' in body:
        update_expr += ", title = :title"
        expr_values[':title'] = body['title']
    
    if 'completed' in body:
        update_expr += ", completed = :completed"
        expr_values[':completed'] = bool(body['completed'])
    
    # Update item
    table.update_item(
        Key={'id': todo_id},
        UpdateExpression=update_expr,
        ExpressionAttributeValues=expr_values,
        ReturnValues='ALL_NEW'
    )
```

### Delete (DELETE /todos/{id})

```python
def delete_todo(todo_id):
    table.delete_item(Key={'id': todo_id})
    return success_response({"deleted": todo_id})
```

### List (GET /todos)

```python
def list_todos():
    response = table.scan()  # Get all items
    todos = response.get('Items', [])
    
    return success_response({
        "todos": todos,
        "count": len(todos)
    })
```

---

## 🧪 Testing

### Test Sequence

```bash
# 1. Create three todos
curl -X POST http://localhost:4566.../todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Task 1"}'

curl -X POST http://localhost:4566.../todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Task 2"}'

# 2. List all (expect 2 items)
curl http://localhost:4566.../todos

# 3. Get one (by ID from response)
curl http://localhost:4566.../todos/{id}

# 4. Update (mark completed)
curl -X PUT http://localhost:4566.../todos/{id} \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'

# 5. Verify update
curl http://localhost:4566.../todos/{id}

# 6. Delete
curl -X DELETE http://localhost:4566.../todos/{id}

# 7. Verify deleted (expect 404)
curl http://localhost:4566.../todos/{id}
```

---

## 🚨 Common Issues

### Issue 1: "ValidationException: One or more parameter values were invalid"

**Cause**: DynamoDB type mismatch (string vs number)

**Solution**:
```python
# Wrong: DynamoDB expects strings/numbers, not booleans
table.put_item(Item={'id': '123', 'completed': True})

# Right: Convert explicitly
table.put_item(Item={'id': '123', 'completed': bool(True)})
```

### Issue 2: "No attribute found"

**Cause**: Trying to update non-existent attribute

**Solution**: Use `AttributeNotExists()` condition or check existence first

### Issue 3: "LimitExceededException"

**Cause**: Scan/Query hit 1MB limit

**Solution**: Implement pagination with `LastEvaluatedKey`

### Issue 4: "ProvisionedThroughputExceededException"

**Cause**: Exceeded provisioned capacity (only on provisioned tables)

**Solution**: Use `PAY_PER_REQUEST` billing mode (as in this scenario)

---

## 📊 Cost Analysis

### AWS (1M requests/month)

| Component | Cost |
|-----------|------|
| DynamoDB requests (1M) | $1.25 |
| DynamoDB storage (100 MB) | $0.025 |
| Lambda compute | $0.20 |
| API Gateway | $3.50 |
| CloudWatch Logs | $0.50 |
| **Total** | **$5.48/month** |

**Free tier**: 25 GB storage + 25 write units + 100 read units

### Comparison: Serverless vs. Managed Database

| Aspect | DynamoDB (Serverless) | RDS PostgreSQL (Managed) |
|--------|----------------------|-------------------------|
| 100 req/day | $5/month | $15/month |
| 100k req/day | $150/month | $25/month |
| 100M req/day | $150k/month | $1k/month |

**Best for**: Spiky workloads (e-commerce, SaaS)  
**Not ideal**: Predictable, steady queries (use RDS)

---

## 🎓 Extensions

### Extension 1: Add Filtering

```python
# Filter todos by status
response = table.scan(
    FilterExpression='completed = :val',
    ExpressionAttributeValues={':val': True}
)
```

### Extension 2: Add Pagination

```python
# Scan with pagination
def list_todos_paginated(limit=10, start_key=None):
    kwargs = {'Limit': limit}
    if start_key:
        kwargs['ExclusiveStartKey'] = start_key
    
    response = table.scan(**kwargs)
    return response['Items'], response.get('LastEvaluatedKey')
```

### Extension 3: Add TTL (Auto-delete)

```hcl
# Delete completed todos after 30 days
resource "aws_dynamodb_ttl" "example" {
  name           = "ttl"
  table_name     = aws_dynamodb_table.todos.name
  enabled        = true
  attribute_name = "expire_at"
}
```

### Extension 4: Add Transactions

```python
# ACID transactions (all-or-nothing)
dynamodb_client.transact_write_items(
    TransactItems=[
        {'Put': {'TableName': 'todos', 'Item': {'id': '1', 'title': 'A'}}},
        {'Update': {'TableName': 'todos', 'Key': {'id': '2'}, 'UpdateExpression': 'SET title = :val', 'ExpressionAttributeValues': {':val': 'B'}}}
    ]
)
```

---

## ✅ Completion Checklist

- [ ] DynamoDB table created (todos)
- [ ] Lambda functions: Create, Read, Update, Delete, List
- [ ] API Gateway routes for all 5 endpoints
- [ ] IAM permissions for Lambda → DynamoDB
- [ ] All CRUD operations work locally
- [ ] Error handling (400/404/500)
- [ ] CloudWatch Logs show operations
- [ ] test-crud.sh passes all tests
- [ ] You understand partition keys and GSI
- [ ] Ready for Scenario 5: 3-Tier Web App

---

## 🎉 Next Steps

You now understand:
- NoSQL databases (DynamoDB) vs. SQL
- CRUD operations in serverless context
- Data modeling and schema design
- API design (status codes, error handling)
- DynamoDB cost model

**Next?** → [Scenario 5: 3-Tier Web App](../05-3tier-web-app/)

---

**Questions?** See [SCENARIOS.md](../../SCENARIOS.md)
