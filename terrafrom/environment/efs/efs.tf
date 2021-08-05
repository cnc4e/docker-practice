terraform {
  required_version = ">= 0.15.4"

  backend "s3" {
    bucket         = "dc-practice-tfstate"
    key            = "efs/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "dc-practice-tfstate-lock"
    region         = "us-west-1"
  }
}

provider "aws" {
  region = "us-west-1"
}

locals {
  # common parameter
  pj    = "dc-practice"
  env   = "test"
  owner = "shimadzu"

  tags = {
    pj    = local.pj
    env   = local.env
    owner = local.owner
  }
}

module "amazon-efs" {

  source = "../../module/efs.tf"

  # Common
  base_name = "${local.pj}-${local.env}"
  tags      = local.tags

}
