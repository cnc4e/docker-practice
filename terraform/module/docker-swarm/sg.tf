resource "aws_security_group" "swarm-node-sg" {
  name        = "${var.base_name}-swarm-node-sg"
  description = "for swarm instances"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    {
      "Name" = "${var.base_name}-swarm-node-sg"
    },
    var.tags
  )

}

resource "aws_security_group_rule" "ssh" {
  count = length(var.allow_ssh_cidrs) != 0 ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.swarm-node-sg.id
  cidr_blocks       = var.allow_ssh_cidrs
  description       = "allow ssh"
}

resource "aws_security_group_rule" "docker-api" {
  count = length(var.allow_docker_api_cidrs) != 0 ? 1 : 0

  type              = "ingress"
  from_port         = 2376
  to_port           = 2376
  protocol          = "tcp"
  security_group_id = aws_security_group.swarm-node-sg.id
  cidr_blocks       = var.allow_docker_api_cidrs
  description       = "allow Docker API"
}

resource "aws_security_group_rule" "self-2377" {
  type              = "ingress"
  from_port         = 2377
  to_port           = 2377
  protocol          = "tcp"
  security_group_id = aws_security_group.swarm-node-sg.id
  self              = true
  description       = "cluster management"
}

resource "aws_security_group_rule" "self-7946-tcp" {
  type              = "ingress"
  from_port         = 7946
  to_port           = 7946
  protocol          = "tcp"
  security_group_id = aws_security_group.swarm-node-sg.id
  self              = true
  description       = "node communication TCP"
}

resource "aws_security_group_rule" "self-7946-udp" {
  type              = "ingress"
  from_port         = 7946
  to_port           = 7946
  protocol          = "udp"
  security_group_id = aws_security_group.swarm-node-sg.id
  self              = true
  description       = "node communication UDP"
}

resource "aws_security_group_rule" "self-4789" {
  type              = "ingress"
  from_port         = 4789
  to_port           = 4789
  protocol          = "udp"
  security_group_id = aws_security_group.swarm-node-sg.id
  self              = true
  description       = "overlay network"
}

resource "aws_security_group_rule" "self-esp" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = 50
  security_group_id = aws_security_group.swarm-node-sg.id
  self              = true
  description       = "overlay network encripted"
}

resource "aws_security_group_rule" "zabbix" {
  type              = "ingress"
  from_port         = 10050
  to_port           = 10051
  protocol          = "tcp"
  security_group_id = aws_security_group.swarm-node-sg.id
  self              = true
  description       = "zabbix"
}
