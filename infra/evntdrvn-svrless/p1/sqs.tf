# Standard SQS Queue where new orders are initially placed
resource "aws_sqs_queue" "order_created" {
  name = "OrderCreatedQueue"  # Logical identifier for the queue
}

# Secondary SQS Queue for the next step in the workflow
resource "aws_sqs_queue" "inventory_reserved" {
  name = "InventoryReservedQueue"  # Logical identifier for the queue
}