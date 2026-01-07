resource "aws_lambda_function" "reserve_inventory" {
  function_name = "reserve-inventory-service"
  role          = aws_iam_role.reserve_inventory_lambda_role.arn
  handler       = "com.example.ReserveInventoryHandler"
  runtime       = "java21"
  architectures = ["x86_64"]

  filename         = "${path.module}/../app/target/new-order-service-1.0.0.jar"
  source_code_hash = filebase64sha256("${path.module}/../app/target/new-order-service-1.0.0.jar")


  timeout = 30
}
# Allow ReserveInventory Lambda to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "reserve_inventory_basic_logs" {
  role       = aws_iam_role.reserve_inventory_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
