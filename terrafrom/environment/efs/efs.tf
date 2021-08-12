provider "aws" {
  region = "REGION"
}

# inport network value
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket         = "PJ-NAME-tfstate"
    key            = "swarm/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "PJ-NAME-tfstate-lock"
    region         = "REGION"
  }
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

  # Network
  availability_zone = data.terraform_remote_state.network.outputs.public_subnet_az
  subnet_id         = data.terraform_remote_state.network.outputs.public_subnet_id
  sg_id             = data.terraform_remote_state.network.outputs.sg_id

}
