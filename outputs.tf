# ------------------------------------------------------------------------------
# Output
# ------------------------------------------------------------------------------
output "arn" {
  description = "The Amazon Resource Name (ARN) identifying the sidecred Lambda Function."
  value       = module.lambda.arn
}

output "role_arn" {
  description = "The ARN of the sidecred lambda execution role."
  value       = module.lambda.role_arn
}

output "role_name" {
  description = "The name of the sidecred lambda execution role."
  value       = module.lambda.role_name
}

output "bucket_id" {
  description = "ID (name) of the config bucket."
  value       = aws_s3_bucket.bucket.id
}
