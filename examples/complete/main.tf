terraform {
  required_version = ">= 0.13"
}

provider "aws" {
  region  = var.region
}

resource "local_file" "config" {
  filename = "${path.module}/generated-config.yml"
  content  = <<EOF
---
version: 1

namespace: example

stores:
  - type: ssm

requests:
  - store: ssm 
    creds:
    - type: aws:sts
      name: sts-credential-1
      config:
        role_arn: ${aws_iam_role.example.arn}
        duration: 900
EOF
}

module "sidecred" {
  source      = "../../"
  name_prefix = var.name_prefix
  depends_on = [
    local_file.config,
  ]
  configurations = [
    {
      namespace = "example"
      config    = "config.yml"
    },
    {
      namespace = "example"
      config    = local_file.config.filename
    }
  ]

  environment = {
    SIDECRED_RANDOM_PROVIDER_ROTATION_INTERVAL = "20m"
    SIDECRED_STS_PROVIDER_ENABLED              = "true"
    SIDECRED_STS_PROVIDER_SESSION_DURATION     = "20m"
    SIDECRED_SSM_STORE_ENABLED                 = "true"
    SIDECRED_SSM_STORE_SECRET_TEMPLATE         = "/sidecred/{{ .Namespace }}/{{ .Name }}"
    SIDECRED_DEBUG                             = "true"
    SIDECRED_ROTATION_WINDOW                   = "19m"
  }

  tags = {
    terraform   = "true"
    environment = "dev"
  }
}

resource "aws_iam_role_policy" "sidecred" {
  name   = "sidecred-permissions"
  role   = module.sidecred.role_name
  policy = data.aws_iam_policy_document.sidecred.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "sidecred" {
  # Allow STS provider to assume any role (in any account) with a sidecred = allow tag.
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::*:role/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:ResourceTag/sidecred"
      values   = ["allow"]
    }
  }

  # Read/write SSM Parameters (required for the secret store)
  statement {
    effect = "Allow"

    actions = [
      "ssm:PutParameter",
      "ssm:DeleteParameter",
    ]

    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/sidecred*",
    ]
  }
}

# Example of an assumable IAM role that can be used in a STS provider request.
resource "aws_iam_role" "example" {
  name               = "${var.name_prefix}-assumable-role"
  assume_role_policy = data.aws_iam_policy_document.example_assume.json

  tags = {
    sidecred    = "allow"
    terraform   = "true"
    environment = "dev"
  }
}

data "aws_iam_policy_document" "example_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"

      identifiers = [
        # For cross account roles this should be the ARN of the sidecred execution role.
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }
}
