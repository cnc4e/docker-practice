locals {
  default_init_script_previous = <<SHELLSCRIPT
#!/bin/bash
echo "########## yum update ##########"
yum update -y

## install wget
echo "########## install wget ##########"
yum install -y wget

## install Docker
echo "########## install Docker ##########"
curl -sSL https://get.docker.com/ | sh

## install docker-compose
echo "########## install docker-compose ##########"
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

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
echo "########## install ssm agent ##########"
yum install -y https://s3.${data.aws_region.current.name}.amazonaws.com/amazon-ssm-${data.aws_region.current.name}/latest/linux_amd64/amazon-ssm-agent.rpm

## start ssm agent
echo "########## start ssm agent ##########"
systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

## modify hostname ##
echo "########## start modify hostname ##########"

### aws cli install ###
yum install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

/usr/local/bin/aws --version

### set hostname from tag name ##

instance_id=""
tag_name=""
count=0

while [ $count = 0 ]
do
  instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  tag_name=$(/usr/local/bin/aws ec2 describe-instances \
                    --region ${data.aws_region.current.name} \
                    --instance-id $instance_id \
                    --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' \
                    --output text)
  hostname=`echo $tag_name | sed -e s/${var.base_name}-//`
  count=$(echo -n $hostname | wc -c)
done

hostnamectl set-hostname $hostname

SHELLSCRIPT
}

data "aws_ami" "centos8_ami" {
  most_recent = true
  owners      = ["aws-marketplace"]

  # "CentOS 8 (x86_64) - with Updates HVM" の product-codeで対象AMIを指定 
  filter {
    name   = "product-code"
    values = ["47k9ia2igxpcce2bzo8u3kj03"]
  }
}

resource "aws_instance" "swarm_nodes" {
  for_each = toset(var.nodes)

  ami                         = data.aws_ami.centos8_ami.id
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
