resource "aws_iam_policy" "dynamodb_put_order_policy" {
  name        = "dynamodb-put-order-policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
        ]
        Effect   = "Allow"
        Resource = "${aws_dynamodb_table.orders.arn}"
      },
    ]
  })
}