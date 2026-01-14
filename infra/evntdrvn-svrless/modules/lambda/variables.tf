variable "function_name" { type = string }
variable "s3_bucket"     { type = string }
variable "s3_key"        { type = string }
variable "source_code_hash" { type = string }

variable "role_arn" { type = string }
variable "handler"  { type = string }

variable "runtime" {
  type    = string
  default = "java21"
}

variable "architectures" {
  type    = list(string)
  default = ["x86_64"]
}

variable "timeout" {
  type    = number
  default = 10
}

variable "memory_size" {
  type    = number
  default = 512
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}
