provider "aws" {
  # 環境を構築するリージョンを指定します。
  region = "REGION"
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

  # Network
  ## VPCに割り当てるCIDRを指定します。
  vpc_cidr = "10.100.0.0/16"
  ## subnetに割り当てるCIDRを指定します。
  subnet_cidr = "10.100.0.0/24"

  # EC2
  ## 作成するノードの一覧です。リストした名前のEC2を作成します。
  nodes = ["manager0", "manager1", "manager2", "worker0", "worker1"]
  ## 作成するEC2のインスタンスタイプを指定します。
  instance_type = "t3.medium"
  ## EC2に割り当てるキーペアを指定します。あらかじめ作成が必要です。
  key_name = "key_pair_name"

  # SecurityGroup
  ## 各ノードにインターネット経由でSSH接続する場合に送信元グローバルIPを指定します。
  ## どこからも許可しない場合は空配列を指定する。
  allow_ssh_cidrs = []
  ## 各ノードにインターネット経由でdocker APIを利用する場合に送信元グローバルIPを指定します。
  ## どこからも許可しない場合は空配列を指定する。
  allow_docker_api_cidrs = []


  # ClowdWatch
  ## 作成するEC2に自動起動/自動停止のスケジュールを設定します。
  auto_start          = true                       # trueにするとEC2の自動起動をスケジュール設定します。
  auto_start_schedule = "cron(06 6 ? * MON-FRI *)" # 日本時間で平日09:00の指定
  auto_stop           = true                       # trueにするとEC2の自動停止をスケジュール設定します。
  auto_stop_schedule  = "cron(04 6 ? * MON-FRI *)" # 日本時間で平日19:00の指定
}

module "docker-swarm" {

  source = "../../module/docker-swarm"

  # Common
  base_name = "${local.pj}-${local.env}"
  tags      = local.tags

  # Network
  vpc_cidr    = local.vpc_cidr
  subnet_cidr = local.subnet_cidr

  # EC2
  nodes         = local.nodes
  instance_type = local.instance_type
  key_name      = local.key_name

  # SecurityGroup
  allow_ssh_cidrs        = local.allow_ssh_cidrs
  allow_docker_api_cidrs = local.allow_docker_api_cidrs

  # CloudWatch
  auto_start          = local.auto_start
  auto_start_schedule = local.auto_start_schedule
  auto_stop           = local.auto_stop
  auto_stop_schedule  = local.auto_stop_schedule
}
