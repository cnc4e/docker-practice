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
variable "vpc_cidr" {
  description = "VPCに割り当てるCIDRブロック"
  type        = string
}

variable "availability_zone" {
  description = "Subnetを作成するAZ"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnetに割り当てるCIDRブロック"
  type        = string
}

# EC2
variable "nodes" {
  description = "作成するEC2のノード名一覧"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2のインスタンスタイプ"
  type        = string
}

variable "key_name" {
  description = "EC2で使用するキーペア名"
  type        = string
}

# SecurityGroup
variable "allow_ssh_cidrs" {
  description = "I/NからSSH接続を許可する送信元IPアドレス"
  type        = list(string)
}

variable "allow_docker_api_cidrs" {
  description = "I/NからAPI接続を許可する送信元IPアドレス"
  type        = list(string)
}

# CloudWatch
variable "auto_start" {
  description = "EC2自動起動を有効にするフラグ"
  type        = bool
}

variable "auto_start_schedule" {
  description = "EC2自動起動スケジュール"
  type        = string
}

variable "auto_stop" {
  description = "EC2自動停止を有効にするフラグ"
  type        = bool
}

variable "auto_stop_schedule" {
  description = "EC2自動停止スケジュール"
  type        = string
}
