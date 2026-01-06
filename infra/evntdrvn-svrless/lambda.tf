resource "aws_lambda_function" "new_order_service" {
  function_name = "new-order-service"

  filename         = "${path.module}/app/target/new-order-service-1.0.0.jar"
  source_code_hash = filebase64sha256("${path.module}/app/target/new-order-service-1.0.0.jar")

  role    = aws_iam_role.new_order_lambda_role.arn
  runtime = "java21"
  handler = "com.example.LambdaHandler::handleRequest"

  architectures = ["x86_64"]
  timeout       = 10
  memory_size   = 512

  environment {
    variables = {
      ORDERS_TABLE = "orders"
    }
  }
}
