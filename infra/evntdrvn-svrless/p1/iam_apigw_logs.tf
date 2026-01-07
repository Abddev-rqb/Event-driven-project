# IAM Role for API Gateway to write logs to Amazon CloudWatch
resource "aws_iam_role" "apigw_cloudwatch_role" {
  # Unique identifier for the IAM role
  name = "apigateway-cloudwatch-role"

  # Trust policy: defines which AWS service can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"  # Standard IAM policy language version
    Statement = [{
      Effect = "Allow"      # Explicitly permits the assume action
      Principal = {
        # Only API Gateway service is allowed to use this role
        Service = "apigateway.amazonaws.com"
      }
      Action = "sts:AssumeRole"  # Permission for API Gateway to take on this role
    }]
  })
}

# Attaches a managed AWS policy to the role, granting CloudWatch permissions
resource "aws_iam_role_policy_attachment" "apigw_logs_policy" {
  # Reference to the role created above
  role       = aws_iam_role.apigw_cloudwatch_role.name
  # Pre-defined AWS policy for API Gateway CloudWatch Logs delivery
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}