terraform {
  required_version = "~> 0.15.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.53.0, < 4.0.0"
    }
  }

  backend "s3" {
    bucket         = "PJ-NAME-tfstate"
    key            = "efs/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "PJ-NAME-tfstate-lock"
    region         = "REGION"
  }
}
