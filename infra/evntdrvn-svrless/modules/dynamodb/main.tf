# -------------------------------------------------------------------
# DynamoDB Table (Reusable Module)
#
# Design principles:
# - Table schema is part of the data contract → NOT over-parameterized
# - Capacity mode is configurable (on-demand vs provisioned)
# - Safe defaults for production usage
# -------------------------------------------------------------------
resource "aws_dynamodb_table" "this" {

  # ---------------------------------------------------------------
  # Table name
  #
  # This is an external identifier used by:
  # - Lambda environment variables
  # - IAM policies
  # ---------------------------------------------------------------
  name = var.table_name

  # ---------------------------------------------------------------
  # Billing mode
  #
  # PAY_PER_REQUEST:
  # - No capacity planning
  # - Ideal for event-driven / serverless workloads
  #
  # PROVISIONED:
  # - Requires read/write capacity units
  # ---------------------------------------------------------------
  billing_mode = var.billing_mode

  # ---------------------------------------------------------------
  # Primary key definition
  #
  # hash_key is mandatory
  # range_key (used for composite keys)
  # ---------------------------------------------------------------
  hash_key  = var.hash_key
  range_key = var.range_key

  # ---------------------------------------------------------------
  # Attribute definitions
  #
  # DynamoDB requires attributes to be declared
  # ONLY if they are part of a key or index.
  # ---------------------------------------------------------------
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

#   # ---------------------------------------------------------------
#   # Global Secondary Indexes (GSIs)
#   #
#   # Used for alternative query patterns.
#   # ---------------------------------------------------------------
#   dynamic "global_secondary_index" {
#     for_each = var.global_secondary_indexes
#     content {
#       name            = global_secondary_index.value.name
#       hash_key        = global_secondary_index.value.hash_key
#       range_key       = global_secondary_index.value.range_key
#       projection_type = global_secondary_index.value.projection_type
#     }
#   }

  # ---------------------------------------------------------------
  # Tags (mandatory in enterprise setups)
  # ---------------------------------------------------------------
  tags = var.tags
}
