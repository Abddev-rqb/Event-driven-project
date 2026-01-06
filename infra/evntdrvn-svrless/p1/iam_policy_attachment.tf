# Attaches DynamoDB write policy to Lambda execution role
# This connects IAM role + policy (very important separation)
resource "aws_iam_role_policy_attachment" "attach_dynamodb_policy" {

  role       = aws_iam_role.new_order_lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_put_order_policy.arn
}
# Allows Lambda to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "attach_basic_logging" {

  role       = aws_iam_role.new_order_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
