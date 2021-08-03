locals {
  default_init_script_previous = <<SHELLSCRIPT
#!/bin/bash
echo "########## start yum update ##########"
yum update -y
echo "########## finish yum update ##########"

## install Docker
echo "########## start install Docker ##########"
curl -sSL https://get.docker.com/ | sh
echo "########## finish install Docker ##########"

## install docker-compose
echo "########## start install docker-compose ##########"
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
echo "########## finish install docker-compose ##########"

## setup docker
# mkdir /etc/docker
# cat << EOF > /etc/docker/daemon.json
# {
#   "hosts" : [ "tcp://0.0.0.0:2375", "unix:///var/run/docker.sock" ]
# }
# EOF
# mkdir -p /etc/systemd/system/docker.service.d/
# cat <<EOF > /etc/systemd/system/docker.service.d/docker.conf
# [Service]
# ExecStart=
# ExecStart=/usr/bin/dockerd
# EOF

## start docker
# systemctl daemon-reload
echo "########## start dokcer.services ##########"
systemctl enable docker
systemctl restart docker

## install ssm agent
yum install -y https://s3.${data.aws_region.current.name}.amazonaws.com/amazon-ssm-${data.aws_region.current.name}/latest/linux_amd64/amazon-ssm-agent.rpm

## start ssm agent
systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

SHELLSCRIPT
}

resource "aws_instance" "swarm_nodes" {
  for_each = toset(var.nodes)

  ami                         = var.ami
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.swarmnode.name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.pub-sub.id
  vpc_security_group_ids      = [aws_security_group.swarm-node-sg.id]
  user_data_base64            = base64encode(local.default_init_script_previous)
  key_name                    = var.key_name

  tags = merge(
    {
      "Name" = "${var.base_name}-${each.value}"
    },
    var.tags
  )

}
