# Creates an automatic trigger between an SQS queue and a Lambda function
resource "aws_lambda_event_source_mapping" "order_created_trigger" {
  # ARN of the SQS queue that will provide the events
  event_source_arn = aws_sqs_queue.order_created.arn
  # Name of the Lambda function to invoke when messages arrive
  function_name    = aws_lambda_function.reserve_inventory.function_name
  # Number of queue messages to batch in a single Lambda invocation (1-10)
  batch_size       = 10
  # Active state of the trigger (true=enabled, false=disabled)
  enabled          = true
}