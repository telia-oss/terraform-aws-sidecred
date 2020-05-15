terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = ">= 2.61"
  region  = var.region
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
    SIDECRED_STS_PROVIDER_ENABLED              = "true"
    SIDECRED_STS_PROVIDER_SESSION_DURATION     = "20m"
    SIDECRED_SECRET_STORE_BACKEND              = "ssm"
    SIDECRED_SSM_STORE_PATH_TEMPLATE           = "/sidecred/{{ .Namespace }}/{{ .Name }}"
    SIDECRED_DEBUG                             = "true"
  }

  tags = {
    terraform   = "true"
    environment = "dev"
  }
}
