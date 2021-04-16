terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.61"
    }
  }
  required_version = ">= 0.14"
}
