# -------------------------------
# IAM Role – API Gateway CloudWatch Logging
# -------------------------------
module "apigw_cloudwatch_role" {
  source = "../../modules/iam-role"

  name = "apigateway-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# -------------------------------
# IAM Role Policy Attachment – CloudWatch Logs
# -------------------------------
module "apigw_logs_policy" {
  source = "../../modules/iam-attachment"

  role_name  = module.apigw_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# -------------------------------
# API Gateway Account – Enable CloudWatch Logging
# -------------------------------
resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = module.apigw_cloudwatch_role.arn
}
