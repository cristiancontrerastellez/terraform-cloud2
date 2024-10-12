variable "lambda_runtime" {
  type    = string
  default = "nodejs14.x"
}

variable "lambda_handler" {
  type    = string
  default = "index.handler"
}

variable "lambda_memory_size" {
  type    = number
  default = 128
}

variable "lambda_timeout" {
  type    = number
  default = 10
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "table_name" {
  type    = string
  description = "Name of the DynamoDB table"
}
