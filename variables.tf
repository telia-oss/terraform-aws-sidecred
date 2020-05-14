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

variable "s3_bucket" {
  description = "The bucket where the lambda function is uploaded."
  type        = string
  default     = "sidecred-lambda/v0.3.0.zip"
}

variable "s3_key" {
  description = "The s3 key for the Lambda artifact."
  type        = string
  default     = "telia-oss"
}

variable "filename" {
  description = "Path to the lambda artifact in the local filesystem. Should be a zip file that contains the 'sidecred-lambda' executable."
  type        = string
  default     = null
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
