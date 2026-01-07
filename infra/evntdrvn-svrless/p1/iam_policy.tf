# IAM Policy granting specific DynamoDB permissions
resource "aws_iam_policy" "dynamodb_put_order_policy" {
  # Unique name for the IAM policy
  name        = "dynamodb-put-order-policy"

  # The policy document defining permissions
  policy = jsonencode({
    Version = "2012-10-17"  # Standard IAM policy syntax version
    Statement = [
      {
        # Specific DynamoDB action allowed - follows least privilege
        Action = [
          "dynamodb:PutItem",  # Permits writing single items only
        ]
        Effect   = "Allow"      # Explicitly permits the action
        # ARN of the specific DynamoDB table, referenced from Terraform
        Resource = "${aws_dynamodb_table.orders.arn}"
      },
    ]
  })
}