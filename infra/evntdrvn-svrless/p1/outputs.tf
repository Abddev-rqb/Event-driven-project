output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.ordering.id
}

output "api_gateway_invoke_url" {
  description = "Invoke URL for the dev stage"
  value       = "https://${aws_api_gateway_rest_api.ordering.id}.execute-api.${var.aws_region}.amazonaws.com/dev"
}

# Lambda Outputs
output "new_order_lambda_name" {
  description = "NewOrder Lambda function name"
  value       = aws_lambda_function.new_order_service
}

output "new_order_lambda_arn" {
  description = "NewOrder Lambda ARN"
  value       = aws_lambda_function.new_order_service.arn
}

output "reserve_inventory_lambda_arn" {
  description = "ReserveInventory Lambda ARN"
  value       = aws_lambda_function.reserve_inventory.arn
}

# DynamoDB Outputs
output "orders_table_name" {
  description = "Orders DynamoDB table name"
  value       = aws_dynamodb_table.orders.name
}

output "orders_table_arn" {
  description = "Orders DynamoDB table ARN"
  value       = aws_dynamodb_table.orders.arn
}

# SQS Outputs
output "order_created_queue_url" {
  description = "OrderCreatedQueue URL"
  value       = aws_sqs_queue.order_created.url
}

output "order_created_queue_arn" {
  description = "OrderCreatedQueue ARN"
  value       = aws_sqs_queue.order_created.arn
}

output "inventory_reserved_queue_url" {
  description = "InventoryReservedQueue URL"
  value       = aws_sqs_queue.inventory_reserved.url
}
