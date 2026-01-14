# -------------------------------------------------------------------
# SQS Queue (Reusable Module)
#
# Design principles:
# - Queue name is external-facing → configurable
# - Visibility timeout is configurable (consumer-dependent)
# - Encryption enabled by default (security invariant)
# - No IAM logic inside this module
# -------------------------------------------------------------------
resource "aws_sqs_queue" "this" {

  # ---------------------------------------------------------------
  # Queue name
  #
  # Used by:
  # - Producers (Lambda, EventBridge)
  # - Consumers
  # ---------------------------------------------------------------
  name = var.queue_name

  # ---------------------------------------------------------------
  # Visibility timeout
  #
  # Must be >= Lambda timeout when used with Lambda triggers
  # ---------------------------------------------------------------
  visibility_timeout_seconds = var.visibility_timeout_seconds

  # ---------------------------------------------------------------
  # Message retention period
  #
  # Default: 4 days (345600 seconds)
  # ---------------------------------------------------------------
  message_retention_seconds = var.message_retention_seconds

  # ---------------------------------------------------------------
  # Server-side encryption
  #
  # Security invariant → should NOT be optional in prod
  # ---------------------------------------------------------------
  sqs_managed_sse_enabled = true

  # ---------------------------------------------------------------
  # Tags (mandatory in enterprise environments)
  # ---------------------------------------------------------------
  tags = var.tags
}
