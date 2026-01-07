# CloudWatch Log Group for capturing AWS Lambda function execution logs
resource "aws_cloudwatch_log_group" "new_order_logs" {
  # Log group name following AWS Lambda naming convention
  name              = "/aws/lambda/${aws_lambda_function.new_order_service.function_name}"
  # Automatically delete logs after 14 days to manage storage costs
  retention_in_days = 14
}