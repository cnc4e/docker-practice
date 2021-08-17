# Swarm mode演習環境構築用Terraform

## 概要

本ガイドではTerraformを使用してSwarm mode演習環境をAWS上に構築する手順を解説します。
環境のイメージは次の通りです。

**AWS環境図**

![AWS環境図](./.images/aws.drawio.svg)

## バージョン

本レポジトリのモジュール群は以下のバージョンを前提とします。

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.15.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.53.0, < 4.0.0 |

## 使用方法

以下の順番で各モジュールを実行します。
`efsモジュール`は[Swarm中級-ボリューム](../swarm-intermediate/swarm-volume.md)で使用します。
こちらの章を実施しない場合、efsモジュールの実行は不要です。

### Docker Swarm

まず本レポジトリを任意の場所でクローンします。
なお、以降の手順では任意のディレクトリのパスを環境変数`$CLONEDIR`として進めます。

```sh
export CLONEDIR=`pwd`
git clone https://github.com/cnc4e/docker-practice.git
```

<!--
次に全モジュールで共通して設定する`PJ-NAME`、`ENVIRONMENT`、`OWNER`、`REGION`の値をsedコマンドを使用して置換します。
本ガイドでは以下の値を例として使用します。

|変数|値|
|---|---|
|PJ-NAME|"docker-practice"|
|ENVIROMNENT|"test"|
|OWNER|"test-user"|
|REGION|"us-west-1"|

**Linuxの場合**

``` sh
export PJ-NAME=docker-practice
export ENVIROMNENT=test
export OWNER=test-user
export REGION=us-west-1

cd $CLONEDIR/docker-practice/terraform/

find ./ -type f -exec grep -l 'PJ-NAME' {} \; | xargs sed -i -e 's:PJ-NAME:'$PJ-NAME':g'
find ./ -type f -exec grep -l 'ENVIRONMENT' {} \; | xargs sed -i -e 's:ENVIRONMENT:'$ENVIRONMENT':g'
find ./ -type f -exec grep -l 'OWNER' {} \; | xargs sed -i -e 's:OWNER:'$OWNER':g'
find ./ -type f -exec grep -l 'REGION' {} \; | xargs sed -i -e 's:REGION:'$REGION':g'
```

**macの場合**

``` sh
export PJ-NAME=docker-practice
export ENVIROMNENT=test
export OWNER=test-user
export REGION=us-west-1

cd $CLONEDIR/docker-practice/terraform/

find ./ -type f -exec grep -l 'PJ-NAME' {} \; | xargs sed -i -e 's:PJ-NAME:'$PJ-NAME':g'
find ./ -type f -exec grep -l 'ENVIRONMENT' {} \; | xargs sed -i -e 's:ENVIRONMENT:'$ENVIRONMENT':g'
find ./ -type f -exec grep -l 'OWNER' {} \; | xargs sed -i -e 's:OWNER:'$OWNER':g'
find ./ -type f -exec grep -l 'REGION' {} \; | xargs sed -i -e 's:REGION:'$REGION':g'
```
-->

docker-swarmモジュールのディレクトリへ移動します。

``` sh
cd $CLONEDIR/docker-practice/terraform/environment/docker-swarm
```

環境構築に使用する各種パラメータを`docker-swarm.tf`に指定します。

``` terraform
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
  nodes         = ["manager0", "manager1", "manager2", "worker0", "worker1"]
  ## 作成するEC2のインスタンスタイプを指定します。
  instance_type = "t3.medium"
  ## EC2に割り当てるキーペアを指定します。あらかじめ作成が必要です。
  key_name      = "key_pair_name"

  # SecurityGroup
　## 各ノードにインターネット経由でSSH接続する場合に送信元グローバルIPを指定します。
  ## どこからも許可しない場合は空配列を指定する。
  allow_ssh_cidrs        = [] 
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
```

<!--
### tfバックエンド

Terraformのtfstateを保存するバックエンド[^1]を作成します。
まずtfバックエンドモジュールのディレクトリへ移動します。

[^1]:バックエンドに関する詳細は公式ドキュメント[Backends](https://www.terraform.io/docs/language/settings/backends/index.html)を参照してください。

``` sh
cd $CLONEDIR/docker-practice/terraform/environment/tf-backend
```

次に以下のコマンドでリソースを作成します。

``` sh
terraform init
terraform apply
> yes
```

以降の手順で作成するリソースの情報は上記手順で作成したS3バケットに保存されます。
しかしこのモジュールで作成したS3やDynamoDBの情報は実行したディレクトリのtfstateファイルに保存されます。
このtfstateファイルは削除しないようにご注意ください。
-->

以下のコマンドでリソースを作成します。

``` sh
terraform init
terraform apply
> yes
```

これでSwarmクラスタの構築に必要なMnagerノード、Workerノードが作成されます。
現時点ではSwarmクラスタ自体は構築されていません。
[Swarm初級-Swarmクラスタの構築](../swarm-beginner/swarm-create.md)へ移動し、Swarmクラスタを実際に作成してみましょう。

### EFS

[Swarm中級-ボリューム](../swarm-intermediate/swarm-volume.md)で使用する
Amazon EFSボリュームおよび周辺設定を作成します。
まずefsモジュールのディレクトリへ移動します。

``` sh
cd $CLONEDIR/docker-practice/terraform/environment/efs
```

環境構築に使用する各種パラメータを`efs.tf`に指定します。

``` terraform
provider "aws" {
  # 環境を構築するリージョンを指定します。
  region = "REGION"
}

　<中略>

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
```

以下のコマンドでリソースを作成します。

``` sh
terraform init
terraform apply
> yes
```

これでEFSボリュームが作成されます。
[Swarm中級-ボリューム](../swarm-intermediate/swarm-volume.md)へ移動し、
コンテナへのボリュームマウントを実際に試してみましょう。
