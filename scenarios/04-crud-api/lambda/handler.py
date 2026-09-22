"""CRUD API: Lambda + API Gateway + DynamoDB

Demonstrates full Create-Read-Update-Delete operations on a serverless database.
"""

import json
import os
import uuid
from datetime import datetime
from typing import Any, Dict
import boto3

# DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ.get('TABLE_NAME', 'todos'))


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """Route HTTP requests to CRUD operations."""
    method = event.get('requestContext', {}).get('http', {}).get('method', 'GET')
    path = event.get('rawPath', '')

    try:
        # Parse path and route
        if path == '/todos' and method == 'GET':
            return list_todos()
        elif path == '/todos' and method == 'POST':
            return create_todo(event)
        elif path.startswith('/todos/') and method == 'GET':
            todo_id = path.split('/todos/')[-1]
            return get_todo(todo_id)
        elif path.startswith('/todos/') and method == 'PUT':
            todo_id = path.split('/todos/')[-1]
            return update_todo(todo_id, event)
        elif path.startswith('/todos/') and method == 'DELETE':
            todo_id = path.split('/todos/')[-1]
            return delete_todo(todo_id)
        else:
            return error_response(404, f"Endpoint {method} {path} not found")

    except Exception as e:
        print(f"Error: {str(e)}")
        return error_response(500, str(e))


def list_todos() -> Dict[str, Any]:
    """GET /todos - List all todos."""
    try:
        response = table.scan()
        todos = response.get('Items', [])

        return success_response({
            "todos": todos,
            "count": len(todos),
            "timestamp": datetime.utcnow().isoformat() + "Z"
        })
    except Exception as e:
        return error_response(500, str(e))


def create_todo(event: Dict[str, Any]) -> Dict[str, Any]:
    """POST /todos - Create new todo."""
    try:
        body = json.loads(event.get('body', '{}'))
        title = body.get('title', '').strip()

        if not title or len(title) == 0:
            return error_response(400, "Title is required")
        if len(title) > 200:
            return error_response(400, "Title must be <= 200 characters")

        todo_id = str(uuid.uuid4())
        now = datetime.utcnow().isoformat() + "Z"

        todo = {
            'id': todo_id,
            'title': title,
            'completed': False,
            'created_at': now,
            'updated_at': now
        }

        table.put_item(Item=todo)

        return success_response(todo, status_code=201)

    except json.JSONDecodeError:
        return error_response(400, "Invalid JSON in request body")
    except Exception as e:
        return error_response(500, str(e))


def get_todo(todo_id: str) -> Dict[str, Any]:
    """GET /todos/{id} - Get specific todo."""
    try:
        response = table.get_item(Key={'id': todo_id})

        if 'Item' not in response:
            return error_response(404, f"Todo {todo_id} not found")

        return success_response(response['Item'])

    except Exception as e:
        return error_response(500, str(e))


def update_todo(todo_id: str, event: Dict[str, Any]) -> Dict[str, Any]:
    """PUT /todos/{id} - Update existing todo."""
    try:
        body = json.loads(event.get('body', '{}'))

        # Check if todo exists
        response = table.get_item(Key={'id': todo_id})
        if 'Item' not in response:
            return error_response(404, f"Todo {todo_id} not found")

        # Build update expression
        update_expr = "SET updated_at = :now"
        expr_values = {':now': datetime.utcnow().isoformat() + "Z"}

        if 'title' in body:
            title = body['title'].strip()
            if not title:
                return error_response(400, "Title cannot be empty")
            update_expr += ", title = :title"
            expr_values[':title'] = title

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

        # Fetch updated item
        response = table.get_item(Key={'id': todo_id})
        return success_response(response['Item'])

    except json.JSONDecodeError:
        return error_response(400, "Invalid JSON in request body")
    except Exception as e:
        return error_response(500, str(e))


def delete_todo(todo_id: str) -> Dict[str, Any]:
    """DELETE /todos/{id} - Delete todo."""
    try:
        # Check if exists
        response = table.get_item(Key={'id': todo_id})
        if 'Item' not in response:
            return error_response(404, f"Todo {todo_id} not found")

        # Delete
        table.delete_item(Key={'id': todo_id})

        return success_response({"deleted": todo_id})

    except Exception as e:
        return error_response(500, str(e))


def success_response(data: Dict[str, Any], status_code: int = 200) -> Dict[str, Any]:
    """Format success response."""
    return {
        'statusCode': status_code,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps(data)
    }


def error_response(status_code: int, message: str) -> Dict[str, Any]:
    """Format error response."""
    return {
        'statusCode': status_code,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({
            "error": True,
            "status": status_code,
            "message": message
        })
    }
