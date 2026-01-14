# Table name
variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

# Billing mode: PAY_PER_REQUEST or PROVISIONED
variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

# Primary key
variable "hash_key" {
  description = "Partition key for the table"
  type        = string
}

variable "range_key" {
  description = "Optional sort key for the table"
  type        = string
  default     = null
}

# Attribute definitions
variable "attributes" {
  description = "List of DynamoDB attributes"
  type = list(object({
    name = string
    type = string
  }))
} 

# Global Secondary Indexes
# variable "global_secondary_indexes" {
#   description = "List of GSIs for the table"
#   type = list(object({
#     name            = string
#     hash_key        = string
#     range_key       = optional(string)
#     projection_type = string
#   }))
#   default = []
# }

# Tags
variable "tags" {
  description = "Tags applied to the DynamoDB table"
  type        = map(string)
  default     = {}
}
