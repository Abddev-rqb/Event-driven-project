# IAM role assumed by AWS Lambda service
# Maps to runbook step:
# "Create IAM role with trusted entity = Lambda"
resource "aws_iam_role" "new_order_lambda_role" {
  name = "new-order-lambda-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}