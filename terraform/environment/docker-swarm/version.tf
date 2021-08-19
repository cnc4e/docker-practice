terraform {
  required_version = ">= 0.15.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.53.0, < 4.0.0"
    }
  }
}
