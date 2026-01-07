# IAM Policy granting SQS permissions for the new-order-service Lambda
resource "aws_iam_policy" "new_order_sqs_policy" {
  name = "new-order-sqs-policy"

  # Policy document following the principle of least privilege
  policy = jsonencode({
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
        Resource = aws_sqs_queue.order_created.arn
      }
    ]
  })
}

# Attaches the SQS policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "new_order_attach" {
  # References the IAM role used by the 'new-order-service' Lambda function
  role       = aws_iam_role.new_order_lambda_role.name
  # References the policy created above
  policy_arn = aws_iam_policy.new_order_sqs_policy.arn
}