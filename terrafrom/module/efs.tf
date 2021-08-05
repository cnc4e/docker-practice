resource "aws_efs_file_system" "this" {
  creation_token = var.base_name

  availability_zone_name = "aws_subnet.pub-sub.name"

  tags = merge(
    {
      "Name" = "${var.base_name}-efs"
    },
    var.tags
  )
}
