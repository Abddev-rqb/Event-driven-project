# IAM role assumed by ReserveInventory Lambda
resource "aws_iam_role" "reserve_inventory_lambda_role" {
  name = "reserve-inventory-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
