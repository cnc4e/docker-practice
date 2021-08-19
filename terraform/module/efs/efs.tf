resource "aws_efs_file_system" "this" {
  creation_token = var.base_name

  availability_zone_name = var.availability_zone

  tags = merge(
    {
      "Name" = "${var.base_name}-efs"
    },
    var.tags
  )
}

resource "aws_efs_mount_target" "this" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_id
  security_groups = [var.sg_id]
}
