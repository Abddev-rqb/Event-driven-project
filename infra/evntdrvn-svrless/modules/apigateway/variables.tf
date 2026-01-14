variable "api_name" {
  type = string
}

variable "resource_path" {
  type    = string
  default = "orders"
}

variable "authorization" {
  type    = string
  default = "NONE"
}

variable "lambda_invoke_arn" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "stage_name" {
  type    = string
  default = "dev"
}

variable "log_group_arn" {
  type = string
}
