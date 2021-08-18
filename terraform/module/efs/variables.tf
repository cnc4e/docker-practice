# Common
variable "base_name" {
  description = "PJ名+環境名"
  type        = string
}

variable "tags" {
  description = "各リソースに設定するタグ"
  type        = map(string)
}

# Network
variable "availability_zone" {
  description = "EFSを作成するAZ"
  type        = string
}

variable "sg_id" {
  description = "EFS接続用Inbound設定を追加するSGのID"
  type        = string
}

variable "subnet_id" {
  description = "EFSのマウントポイントを作成するSubnetのID"
  type        = string
}
