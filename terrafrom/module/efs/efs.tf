resource "aws_efs_file_system" "this" {
  creation_token = var.base_name

  availability_zone_name = data.aws_availability_zones.available.names[0]

  tags = merge(
    {
      "Name" = "${var.base_name}-efs"
    },
    var.tags
  )
}

resource "aws_efs_mount_target" "this" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = aws_subnet.pub-sub.id
  security_groups = [aws_security_group.swarm-node-sg.id]
}
