# -------------------------------------------------------------------
# DEV Environment – Infrastructure Composition
# -------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# -------------------------------
# DynamoDB – Orders Table
# -------------------------------
module "orders" {
  source = "../../modules/dynamodb"

  table_name = "orders"

  hash_key = "orderId"

  attributes = [
    {
      name = "orderId"
      type = "S"
    }
  ]

  tags = {
    Service = "ordering"
    Env     = "dev"
  }
}

# -------------------------------
# SQS – Order Created Queue
# -------------------------------
module "order_created_queue" {
  source = "../../modules/sqs"

  queue_name = "OrderCreatedQueue"

  tags = {
    Service = "ordering"
    Env     = "dev"
  }
}

# -------------------------------
# SQS – Inventory Reserved Queue
# -------------------------------
module "inventory_reserved_queue" {
  source = "../../modules/sqs"

  queue_name = "InventoryReservedQueue"

  tags = {
    Service = "inventory"
    Env     = "dev"
  }
}

# -------------------------------
# IAM Role – New Order Lambda
# -------------------------------
module "new_order_lambda_role" {
  source = "../../modules/iam/iam-role"

  role_name = "new-order-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# -------------------------------
# IAM Role – Reserve Inventory Lambda
# -------------------------------
module "reserve_inventory_lambda_role" {
  source = "../../modules/iam/iam-role"

  role_name = "reserve-inventory-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# -------------------------------
# CloudWatch Log Group – API Gateway Access Logs
# -------------------------------
module "apigw_logs" {
  source = "../../modules/cloudwatch-log-group" 
  # Standard naming convention for API Gateway logs
  name              = "/aws/apigateway/ordering-platform-api"
  # Log retention period (14 days), prevents indefinite log accumulation
  retention_in_days = 14
}

# -------------------------------
# CloudWatch Log Group – New Order Lambda
# -------------------------------
module "new_order_lambda_logs" {
  source = "../../modules/cloudwatch-log-group"
  # Must exactly match the Lambda function name
  name = "/aws/lambda/${module.new_order_lambda.function_name}"
  retention_in_days = 14
}

# -------------------------------
# CloudWatch Log Group – Reserve Inventory Lambda
# -------------------------------
module "reserve_inventory_lambda_logs" {
  source = "../../modules/cloudwatch-log-group"

  # Must exactly match the Lambda function name
  name = "/aws/lambda/${module.reserve_inventory_lambda.function_name}"
  retention_in_days = 14
}

# -------------------------------
# IAM Policy – DynamoDB PutItem Permission
# -------------------------------
module "dynamodb_put_policy" {
  source = "../../modules/iam/iam-policy"

  policy_name = "dynamodb-put-order-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:PutItem"]
      Resource = "${module.orders.table_arn}"
    }]
  })
}

# -------------------------------
# IAM Policy – SQS Permissions for ReserveInventory Lambda
# -------------------------------
module "reserve_inventory_sqs_policy" {
  source = "../../modules/iam/iam-policy"

  policy_name = "reserve-inventory-sqs-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      Resource = "${module.order_created_queue.queue_arn}"
    }]
  })
}

# -------------------------------
# IAM Policy – SQS Permissions for New Order Lambda
# -------------------------------
module "new_order_sqs_policy" {
  source = "../../modules/iam/iam-policy"
  policy_name = "new-order-sqs-policy"

  # Policy document following the principle of least privilege
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        # Minimal permissions required: find the queue and send messages
        Action = [
          "sqs:GetQueueUrl",   # Required to resolve the queue URL by name
          "sqs:SendMessage"    # Allows publishing messages to the queue
        ]
        # Restricted to the specific 'order_created' queue ARN
        Resource = "${module.order_created_queue.queue_arn}"

      }
    ]
  })
}

# -------------------------------
# IAM Role Policy Attachment – Link Policy to Role
# -------------------------------
module "attach_dynamodb_policy" {
  source = "../../modules/iam-attachment"

  role_name = module.new_order_lambda_role.role_name
  policy_arn = module.dynamodb_put_policy.policy_arn
}

# -------------------------------
# IAM Role Policy Attachment – Link SQS Policy to New Order Role
# -------------------------------
module "new_order_attach" {
  source = "../../modules/iam-attachment"

  role_name  = module.new_order_lambda_role.role_name
  policy_arn = module.new_order_sqs_policy.policy_arn
}

# -------------------------------
# IAM Role Policy Attachment – Link SQS Policy to ReserveInventory Role
# -------------------------------
module "attach_reserve_inventory_sqs" {
  source = "../../modules/iam-attachment"

  role_name  = module.reserve_inventory_lambda_role.role_name
  policy_arn = module.reserve_inventory_sqs_policy.policy_arn
}

# -------------------------------
# S3 Bucket – Lambda Artifacts
# -------------------------------
module "lambda_artifacts_bucket" {
  source = "../../modules/s3-artifacts"

  bucket_name = "ordering-artifacts-dev"

  tags = {
    Service = "ordering"
    Env     = "dev"
  }
}

resource "aws_s3_object" "new_order_lambda_jar" {
  bucket = module.lambda_artifacts_bucket.bucket_name
  key    = "lambda/new-order-service-1.0.0.jar"

  source = "../../app/newOrder/target/new-order-service-1.0.0.jar"
  etag   = filemd5("../../app/newOrder/target/new-order-service-1.0.0.jar")

  content_type = "application/java-archive"
}

resource "aws_s3_object" "reserve_inventory_lambda_jar" {
  bucket = module.lambda_artifacts_bucket.bucket_name
  key    = "lambda/reserve-inventory-service-1.0.0.jar"
  source = "../../app/reserveInventory/target/reserve-inventory-service-1.0.0.jar"
  etag   = filemd5("../../app/reserveInventory/target/reserve-inventory-service-1.0.0.jar")
  content_type = "application/java-archive"
}

# -------------------------------
# Lambda – New Order Service
# -------------------------------
module "new_order_lambda" {
  source = "../../modules/lambda"

  function_name = "new-order-service"

  s3_bucket = module.lambda_artifacts_bucket.bucket_name
  s3_key    = aws_s3_object.new_order_lambda_jar.key

  source_code_hash = filebase64sha256("../../app/newOrder/target/new-order-service-1.0.0.jar")

  role_arn = module.new_order_lambda_role.role_arn
  handler  = "com.example.NewOrderHandler"

  environment_variables = {
    ORDERS_TABLE = module.orders.table_name
    QUEUE_NAME   = module.order_created_queue.queue_name
  }
}

# -------------------------------
# Logging Role Attachment – New Order Lambda
# -------------------------------
module "new_order_basic_logs" {
  source     = "../../modules/iam-attachment"
  role_name = module.new_order_lambda_role.role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# -------------------------------
# Lambda – Reserve Inventory Service
# -------------------------------
module "reserve_inventory_lambda" {
  source = "../../modules/lambda"

  function_name = "reserve-inventory-service"

  s3_bucket = module.lambda_artifacts_bucket.bucket_name
  s3_key    = aws_s3_object.reserve_inventory_lambda_jar.key

  source_code_hash = filebase64sha256("../../app/reserveInventory/target/reserve-inventory-service-1.0.0.jar")

  role_arn = module.reserve_inventory_lambda_role.role_arn
  handler  = "com.example.ReserveInventoryHandler"
}

# -------------------------------
# Logging Role Attachment – Reserve Inventory Lambda
# -------------------------------
module "reserve_inventory_basic_logs" {
  source     = "../../modules/iam-attachment"
  role_name = module.reserve_inventory_lambda_role.role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# -------------------------------
# API Gateway – Orders API
# -------------------------------
module "ordering_api" {

  source = "../../modules/apigateway"

  # Logical name for the REST API
  api_name = "ordering-platform-api"

  # Lambda integration
  lambda_invoke_arn    = module.new_order_lambda.invoke_arn
  lambda_function_name = module.new_order_lambda.function_name

  # API configuration
  resource_path = "orders"
  stage_name    = "dev"

  # CloudWatch log group for API access logs
  log_group_arn = module.apigw_logs.arn
}

# -------------------------------
# Event Source Mapping – SQS to Lambda
# -------------------------------
resource "aws_lambda_event_source_mapping" "order_created_trigger" {
  # ARN of the SQS queue that will provide the events
  event_source_arn = module.order_created_queue.queue_arn

  # Name of the Lambda function to invoke when messages arrive
  function_name    = module.reserve_inventory_lambda.function_name

  # Number of queue messages to batch in a single Lambda invocation (1-10)
  batch_size       = 10
  
  # Active state of the trigger (true=enabled, false=disabled)
  enabled          = true
}

