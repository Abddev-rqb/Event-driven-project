# IAM Policy granting SQS consumption permissions to the reserve_inventory Lambda
resource "aws_iam_policy" "reserve_inventory_sqs_policy" {
  name = "reserve-inventory-sqs-policy"

  # Policy document following least privilege for queue consumption
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        # Permissions required for Lambda to poll and process messages
        Action = [
          "sqs:ReceiveMessage",    # Retrieve messages from the queue
          "sqs:DeleteMessage",     # Remove processed messages (on success)
          "sqs:GetQueueAttributes" # Required for Lambda event source mapping
        ]
        # Scope restricted to the specific 'order_created' queue
        Resource = aws_sqs_queue.order_created.arn
      }
    ]
  })
}

# Attaches the SQS consumption policy to the reserve_inventory Lambda's role
resource "aws_iam_role_policy_attachment" "reserve_inventory_attach" {
  # The IAM role assumed by the reserve_inventory Lambda function
  role       = aws_iam_role.new_order_lambda_role.name
  # Reference to the policy defined above
  policy_arn = aws_iam_policy.reserve_inventory_sqs_policy.arn
}