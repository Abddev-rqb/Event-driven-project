# IAM role assumed by AWS Lambda service
# Maps to runbook step: "Create IAM role with trusted entity = Lambda"
resource "aws_iam_role" "new_order_lambda_role" {
  # Unique name for the IAM role
  name = "new-order-lambda-role"

  # Trust policy defining which AWS service can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"  # IAM policy language version
    Statement = [
      {
        Action = "sts:AssumeRole"  # Permission to assume the role
        Effect = "Allow"            # Explicitly permit the action
        Sid    = ""                 # Optional statement identifier
        Principal = {
          Service = "lambda.amazonaws.com"  # Only Lambda can assume this role
        }
      },
    ]
  })
}