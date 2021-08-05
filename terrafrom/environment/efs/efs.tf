terraform {
  required_version = ">= 0.15.4"

  backend "s3" {
    bucket         = "PJ-NAME-tfstate"
    key            = "efs/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "PJ-NAME-tfstate-lock"
    region         = "REGION"
  }
}

provider "aws" {
  region = "REGION"
}

locals {
  # common parameter
  pj    = "PJ-NAME"
  env   = "ENVIRONMENT"
  owner = "OWNER"

  tags = {
    pj    = local.pj
    env   = local.env
    owner = local.owner
  }
}

module "efs" {

  source = "../../module/efs"

  # Common
  base_name = "${local.pj}-${local.env}"
  tags      = local.tags

}

output "mount-ip" {
  value = module.efs.mount-ip
}
