output "api_invoke_url" {
  description = "Base invoke URL for Orders API"
  value       = module.ordering_api.invoke_url
}

output "order_queue_url" {
  description = "Order Created SQS queue URL"
  value       = module.order_created_queue.queue_url
}
