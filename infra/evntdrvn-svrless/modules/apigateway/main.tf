# -------------------------------------------------------------------
# API Gateway REST API (Module)
#
# Design principles:
# - Security invariants are NOT parameterized
# - Platform invariants (AWS_PROXY, HTTP semantics) are fixed
# - Only environment-specific values are exposed via variables
#
# This module creates:
# - A REST API
# - A single resource (e.g., /orders)
# - A POST method
# - Lambda proxy integration
# - Deployment + stage
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# REST API container
# -------------------------------------------------------------------
# This represents the top-level API object in API Gateway.
# It is environment-agnostic and reusable across stages.

data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "this" {
  name = var.api_name

  # Regional endpoint keeps latency low and supports private/VPC access
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# -------------------------------------------------------------------
# API Resource (/orders)
# -------------------------------------------------------------------
# Creates a child resource under the API root.
# Example: https://api-id.execute-api.region.amazonaws.com/dev/orders
resource "aws_api_gateway_resource" "orders" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = var.resource_path
}

# -------------------------------------------------------------------
# HTTP Method: POST /orders
# -------------------------------------------------------------------
# HTTP method is part of the API contract and should not vary per env.
# Authorization is configurable because security models may differ.
resource "aws_api_gateway_method" "post_orders" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.orders.id
  http_method   = "POST"
  authorization = var.authorization
}

# -------------------------------------------------------------------
# Lambda Proxy Integration
# -------------------------------------------------------------------
# Uses AWS_PROXY to forward the full HTTP request to Lambda.
#
# Platform invariants:
# - integration_http_method = POST
# - type = AWS_PROXY
#
# These should NEVER be parameterized to avoid runtime failures.
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.orders.id
  http_method             = aws_api_gateway_method.post_orders.http_method

  # Required by API Gateway even though Lambda ignores it
  integration_http_method = "POST"

  # Enforces Lambda proxy integration contract
  type = "AWS_PROXY"

  # Fully qualified Lambda invoke ARN
  uri  = var.lambda_invoke_arn
}

# -------------------------------------------------------------------
# Lambda Permission: API Gateway → Lambda
# -------------------------------------------------------------------
# Explicitly allows API Gateway to invoke the Lambda function.
#
# Security-sensitive values (principal, action) are hard-coded
# to prevent accidental privilege escalation.
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # Restricts invocation to this specific API only
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# -------------------------------------------------------------------
# Deployment
# -------------------------------------------------------------------
# Deployment represents a snapshot of the API configuration.
# Trigger-based redeployment ensures changes propagate correctly.
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.orders.id,
      aws_api_gateway_method.post_orders.id,
      aws_api_gateway_integration.lambda.id
    ]))
  }

  # Prevents downtime during redeployments
  lifecycle {
    create_before_destroy = true
  }
}

# -------------------------------------------------------------------
# Stage (e.g., dev, staging, prod)
# -------------------------------------------------------------------
# Stages are environment-specific and should always be configurable.
# Access logs are enabled for observability and debugging.
resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage_name

  # Structured JSON logs for CloudWatch
  access_log_settings {
    destination_arn = var.log_group_arn
    format = jsonencode({
      requestId = "$context.requestId"
      status    = "$context.status"
      latency   = "$context.responseLatency"
    })
  }
}
