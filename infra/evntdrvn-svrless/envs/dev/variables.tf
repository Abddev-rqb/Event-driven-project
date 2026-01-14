variable "aws_region" {
  description = "AWS region for dev environment"
  type        = string
}

variable "orders_table_name" {
  description = "DynamoDB table for orders"
  type        = string
}

variable "order_created_queue_name" {
  description = "SQS queue for order-created events"
  type        = string
}

variable "lambda_jar_path" {
  description = "Path to Lambda deployment JAR"
  type        = string
}
