terraform {
  required_version = ">= 0.14"

  required_providers {
    # 3.0 makes aws_s3_bucket.region read-only which is a breaking change for this module.
    aws = "~> 2.0"
  }
}
