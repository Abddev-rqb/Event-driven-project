# Queue name
variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
}

# Visibility timeout
variable "visibility_timeout_seconds" {
  description = "Visibility timeout for the queue (seconds)"
  type        = number
  default     = 30
}

# Message retention
variable "message_retention_seconds" {
  description = "How long messages are retained in the queue (seconds)"
  type        = number
  default     = 345600 # 4 days
}

# Tags
variable "tags" {
  description = "Tags applied to the SQS queue"
  type        = map(string)
  default     = {}
}
