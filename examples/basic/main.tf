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

  tags = {
    terraform   = "true"
    environment = "dev"
  }
}
