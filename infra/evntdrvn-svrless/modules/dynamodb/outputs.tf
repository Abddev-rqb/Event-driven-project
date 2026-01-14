# -------------------------------------------------------------------
# Outputs
#
# These values are consumed by:
# - Lambda modules (environment variables)
# - IAM policy documents (Resource ARNs)
# -------------------------------------------------------------------

# Table name (used by application code)
output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.this.name
}

# Table ARN (used in IAM policies)
output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.this.arn
}
