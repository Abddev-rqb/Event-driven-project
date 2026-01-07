# AWS Lambda Function definition for processing new orders
resource "aws_lambda_function" "new_order_service" {
  # Unique identifier for the Lambda function within AWS
  function_name = "new-order-service"

  # Path to the deployment package (JAR file) containing the function code
  filename         = "${path.module}/../app/target/new-order-service-1.0.0.jar"
  # Automatically detect code changes by hashing the JAR file
  source_code_hash = filebase64sha256("${path.module}/../app/target/new-order-service-1.0.0.jar")

  # IAM role granting execution permissions (e.g., writing to DynamoDB)
  role    = aws_iam_role.new_order_lambda_role.arn
  # Java 21 runtime environment
  runtime = "java21"
  # Fully qualified Java class and method to invoke
  handler = "com.example.LambdaHandler::handleRequest"

  # Processor architecture (x86_64 is standard, arm64 is more cost-efficient)
  architectures = ["x86_64"]
  # Maximum execution duration before timeout (seconds)
  timeout       = 10
  # Amount of memory allocated (MB)
  memory_size   = 512

  # Runtime environment variables accessible to the function
  environment {
    variables = {
      # Reference to a DynamoDB table for order storage
      ORDERS_TABLE = "orders"
    }
  }
}