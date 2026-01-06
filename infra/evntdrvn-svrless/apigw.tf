resource "aws_api_gateway_rest_api" "ordering" {
  name = "ordering-platform-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "orders" {
  parent_id   = aws_api_gateway_rest_api.ordering.root_resource_id
  path_part   = "orders"
  rest_api_id = aws_api_gateway_rest_api.ordering.id
}

resource "aws_api_gateway_method" "post_orders" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.orders.id
  rest_api_id   = aws_api_gateway_rest_api.ordering.id
}

resource "aws_api_gateway_integration" "lambda" {
  http_method = aws_api_gateway_method.post_orders.http_method
  resource_id = aws_api_gateway_resource.orders.id
  rest_api_id = aws_api_gateway_rest_api.ordering.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.new_order_service.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.new_order_service.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ordering.execution_arn}/*/*"
}


resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.ordering.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.orders.id,
      aws_api_gateway_method.post_orders.id,
      aws_api_gateway_integration.lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.ordering.id
  stage_name    = "dev"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_logs.arn
    format = jsonencode({
      requestId = "$context.requestId"
      status    = "$context.status"
      latency   = "$context.responseLatency"
    })
  }
}
