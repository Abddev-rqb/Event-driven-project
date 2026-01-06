resource "aws_dynamodb_table" "orders" {
  name             = "orders"
  hash_key         = "orderId"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "orderId"
    type = "S"
  }
}