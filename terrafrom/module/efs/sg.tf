resource "aws_security_group_rule" "efs" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  security_group_id = aws_security_group.swarm-node-sg.id
  self              = true
  description       = "mount efs"
}
