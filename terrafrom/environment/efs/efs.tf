provider "aws" {
  # 環境を構築するリージョンを指定します。
  region = "REGION"
}

# inport network value
data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../docker-swarm/"
  }
}

locals {
  # common parameter
  ## 各リソースの名称やタグ情報に使用するパラメータを指定します。
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
