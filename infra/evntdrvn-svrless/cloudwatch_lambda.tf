resource "aws_cloudwatch_log_group" "new_order_logs" {
  name              = "/aws/lambda/${aws_lambda_function.new_order_service.function_name}"
  retention_in_days = 14
}
