# CloudWatch Log Group for API Gateway execution logs
resource "aws_cloudwatch_log_group" "apigw_logs" {
  # Standard naming convention for API Gateway logs
  name              = "/aws/apigateway/ordering-platform-api"
  # Log retention period (14 days), prevents indefinite log accumulation
  retention_in_days = 14
}