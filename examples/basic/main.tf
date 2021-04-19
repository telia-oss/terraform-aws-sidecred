terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  region = var.region
}

module "sidecred" {
  source      = "../../"
  name_prefix = var.name_prefix

  configurations = [{
    namespace = "example"
    config    = "config.yml"
  }]

  environment = {
    SIDECRED_RANDOM_PROVIDER_ROTATION_INTERVAL = "1m"
    SIDECRED_SSM_STORE_ENABLED                 = "true"
    SIDECRED_SSM_STORE_SECRET_TEMPLATE         = "/sidecred/{{ .Namespace }}/{{ .Name }}"
    SIDECRED_DEBUG                             = "true"
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
