"""
Serverless API Handler - Lambda function for HTTP requests

This function handles HTTP requests from API Gateway and returns JSON responses.
Demonstrates core Lambda + API Gateway patterns:
- Query parameters (?name=World)
- Path parameters (/{name})
- Error handling (404, 400, 500)
- Structured logging
"""

import json
import os
from datetime import datetime
from typing import Dict, Any, Tuple


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main Lambda handler - processes HTTP requests from API Gateway.

    Args:
        event: API Gateway event (contains method, path, query params, headers)
        context: Lambda context (function metadata, remaining time, etc.)

    Returns:
        API Gateway response format (statusCode, headers, body)
    """

    # Log incoming request
    print(f"Method: {event.get('requestContext', {}).get('http', {}).get('method')}")
    print(f"Path: {event.get('rawPath')}")
    print(f"Query params: {event.get('queryStringParameters')}")

    try:
        # Route handling
        path = event.get('rawPath', '')
        method = event.get('requestContext', {}).get('http', {}).get('method', 'GET')

        # GET /hello
        if path == '/hello' and method == 'GET':
            return handle_hello(event)

        # GET /hello/{name}
        elif path.startswith('/hello/') and method == 'GET':
            name = path.split('/hello/')[-1]
            return handle_hello_with_name(name)

        # GET /health
        elif path == '/health' and method == 'GET':
            return handle_health()

        # 404 Not Found
        else:
            return error_response(404, f"Endpoint {method} {path} not found")

    except Exception as e:
        print(f"Error: {str(e)}")
        return error_response(500, f"Internal server error: {str(e)}")


def handle_hello(event: Dict[str, Any]) -> Dict[str, Any]:
    """
    GET /hello - Return greeting (optionally with query parameter ?name=World)
    """
    # Get name from query string (e.g., ?name=Alice)
    query_params = event.get('queryStringParameters') or {}
    name = query_params.get('name', 'World')

    # Validate name length
    if len(name) > 100:
        return error_response(400, "Name must be <= 100 characters")

    # Build response
    response_data = {
        "message": f"Hello, {name}!",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "endpoint": "/hello",
        "parameters": {
            "name": name
        }
    }

    return success_response(response_data)


def handle_hello_with_name(name: str) -> Dict[str, Any]:
    """
    GET /hello/{name} - Return greeting with path parameter
    """
    # Decode URL-encoded name (Python doesn't do this automatically)
    try:
        from urllib.parse import unquote
        name = unquote(name)
    except Exception:
        pass

    # Validate name
    if not name or len(name) == 0:
        return error_response(400, "Name cannot be empty")
    if len(name) > 100:
        return error_response(400, "Name must be <= 100 characters")

    response_data = {
        "message": f"Hello, {name}!",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "endpoint": "/hello/{name}",
        "parameters": {
            "name": name
        }
    }

    return success_response(response_data)


def handle_health() -> Dict[str, Any]:
    """
    GET /health - Return health check status

    Used by monitoring systems, load balancers, uptime checks
    """
    response_data = {
        "status": "healthy",
        "service": "serverless-api",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "region": os.environ.get('AWS_REGION', 'unknown'),
        "environment": os.environ.get('ENVIRONMENT', 'dev'),
        "stage": os.environ.get('STAGE', 'dev'),
        "function_version": os.environ.get('AWS_LAMBDA_FUNCTION_VERSION', '1'),
        "memory_limit": os.environ.get('AWS_LAMBDA_FUNCTION_MEMORY_IN_MB', 'unknown')
    }

    return success_response(response_data)


def success_response(data: Dict[str, Any], status_code: int = 200) -> Dict[str, Any]:
    """
    Format successful API response

    Args:
        data: Response payload (will be JSON-encoded)
        status_code: HTTP status code (default 200)

    Returns:
        API Gateway response format
    """
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'X-API-Version': '1.0'
        },
        'body': json.dumps(data)
    }


def error_response(status_code: int, message: str) -> Dict[str, Any]:
    """
    Format error API response

    Args:
        status_code: HTTP status code (400, 404, 500, etc.)
        message: Error message

    Returns:
        API Gateway error response
    """
    response_data = {
        "error": True,
        "status": status_code,
        "message": message,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

    # Map status codes to HTTP status names
    status_names = {
        400: "Bad Request",
        404: "Not Found",
        500: "Internal Server Error"
    }

    response_data["status_name"] = status_names.get(status_code, "Error")

    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'X-API-Version': '1.0'
        },
        'body': json.dumps(response_data)
    }
