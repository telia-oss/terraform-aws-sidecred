# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
variable "name_prefix" {
  description = "A prefix used for naming resources."
  type        = string
}

variable "configurations" {
  description = "A list of configurations that will trigger the sidecred lambda."
  type        = list(object({ namespace = string, config = string }))
}

variable "environment" {
  description = "Environment variables for the lambda. This is how you configure sidecred."
  type        = map(string)
}

variable "schedule_expression" {
  description = "The scheduling expression for how often sidecred should run. For example, cron(0 */5 * ? * *) or rate(10 minutes)."
  type        = string
  default     = "rate(10 minutes)"
}

variable "s3_bucket" {
  description = "The bucket where the lambda function is uploaded."
  type        = string
  default     = "telia-oss"
}

variable "s3_key" {
  description = "The s3 key for the lambda artifact."
  type        = string
  default     = "sidecred-lambda/v0.14.0.zip"
}

variable "filename" {
  description = "Path to the lambda artifact in the local filesystem. Should be a zip file that contains the 'sidecred-lambda' executable."
  type        = string
  default     = null
}

variable "lambda_timeout" {
  description = "The amount of time the sidecred lambda function has to run in seconds."
  type        = number
  default     = 300
}

variable "source_code_hash" {
  description = "Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either filename or s3_key."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = map(string)
  default     = {}
}
