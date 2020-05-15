# ------------------------------------------------------------------------------
# Output
# ------------------------------------------------------------------------------
output "arn" {
  description = "The Amazon Resource Name (ARN) identifying the sidecred Lambda Function."
  value       = module.lambda.arn
}

output "role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the sidecred lambda execution role."
  value       = module.lambda.role_arn
}

output "bucket_id" {
  description = "ID (name) of the config bucket."
  value       = aws_s3_bucket.bucket.id
}
