# -------------------------------------------------------------------
# Outputs
#
# These values are consumed by:
# - Lambda environment variables
# - IAM policies
# - Event source mappings
# -------------------------------------------------------------------

# Queue URL (used by SDKs to send messages)
output "queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.this.url
}

# Queue ARN (used in IAM policies and event source mappings)
output "queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.this.arn
}

# Queue name (used for configuration & logging)
output "queue_name" {
  description = "Name of the SQS queue"
  value       = aws_sqs_queue.this.name
}
