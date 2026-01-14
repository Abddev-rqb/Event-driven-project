resource "aws_lambda_function" "this" {
  function_name = var.function_name

  s3_bucket = var.s3_bucket
  s3_key    = var.s3_key

  source_code_hash = var.source_code_hash

  role    = var.role_arn
  runtime = var.runtime
  handler = var.handler

  architectures = var.architectures
  timeout       = var.timeout
  memory_size   = var.memory_size

  environment {
    variables = var.environment_variables
  }
}
