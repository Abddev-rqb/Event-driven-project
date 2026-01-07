# Main REST API container
resource "aws_api_gateway_rest_api" "ordering" {
  name = "ordering-platform-api"
  endpoint_configuration {
    types = ["REGIONAL"]  # Deploy API in a specific AWS region
  }
}

# Resource path within the API: creates the `/orders` endpoint
resource "aws_api_gateway_resource" "orders" {
  parent_id   = aws_api_gateway_rest_api.ordering.root_resource_id  # Root path "/"
  path_part   = "orders"                                             # Child path "/orders"
  rest_api_id = aws_api_gateway_rest_api.ordering.id                # Belongs to main API
}

# HTTP method configuration for the `/orders` resource
resource "aws_api_gateway_method" "post_orders" {
  authorization = "NONE"                                          # No authentication required
  http_method   = "POST"                                          # Accept POST requests
  resource_id   = aws_api_gateway_resource.orders.id             # Attached to /orders
  rest_api_id   = aws_api_gateway_rest_api.ordering.id           # Belongs to main API
}

# Connects the POST method to the Lambda function (AWS_PROXY integration)
resource "aws_api_gateway_integration" "lambda" {
  http_method             = aws_api_gateway_method.post_orders.http_method
  resource_id             = aws_api_gateway_resource.orders.id
  rest_api_id             = aws_api_gateway_rest_api.ordering.id
  integration_http_method = "POST"                               # How API Gateway calls Lambda
  type                    = "AWS_PROXY"                          # Lambda proxy integration
  uri                     = aws_lambda_function.new_order_service.invoke_arn  # Target Lambda
}

# Grants API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.new_order_service.function_name  # Target function
  principal     = "apigateway.amazonaws.com"                            # Who gets permission
  source_arn    = "${aws_api_gateway_rest_api.ordering.execution_arn}/*/*"  # Any stage/method
}

# Creates a deployable version of the API configuration
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.ordering.id

  # Triggers new deployment when underlying resources change
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.orders.id,
      aws_api_gateway_method.post_orders.id,
      aws_api_gateway_integration.lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true  # Prevent downtime during updates
  }
}

# Creates a named stage ("dev") for the deployed API
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.deploy.id          # Which deployment to use
  rest_api_id   = aws_api_gateway_rest_api.ordering.id          # Belongs to main API
  stage_name    = "dev"                                          # Environment name

  # Enables CloudWatch logging for this stage
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_logs.arn    # From cloudwatch_apigw.tf
    # JSON-formatted log structure for easy parsing
    format = jsonencode({
      requestId = "$context.requestId"
      status    = "$context.status"
      latency   = "$context.responseLatency"
    })
  }
}