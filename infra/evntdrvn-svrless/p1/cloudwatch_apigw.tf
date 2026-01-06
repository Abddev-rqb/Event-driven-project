resource "aws_cloudwatch_log_group" "apigw_logs" {
  name              = "/aws/apigateway/ordering-platform-api"
  retention_in_days = 14
}
