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

resource "aws_efs_file_system" "this" {
  creation_token = var.base_name

  availability_zone_name = data.terraform_remote_state.network.output.public_subnet_az

  tags = merge(
    {
      "Name" = "${var.base_name}-efs"
    },
    var.tags
  )
}

resource "aws_efs_mount_target" "this" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = data.terraform_remote_state.network.output.public_subnet_id
  security_groups = [data.terraform_remote_state.network.output.sg_id]
}
