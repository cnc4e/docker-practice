locals {
  default_init_script_previous = <<SHELLSCRIPT
#!/bin/bash
## .repoファイル更新 ##
echo "########## .repo fix ##########"
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
dnf install centos-release-stream -y
dnf swap centos-{linux,stream}-repos -y

## packages update ##
echo "########## packages update ###########"
dnf upgrade -y

## install wget
echo "########## install wget ##########"
dnf install -y wget

## install Docker
echo "########## install Docker ##########"
curl -sSL https://get.docker.com/ | sh

## install docker-compose
echo "########## install docker-compose ##########"
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

## start docker
# systemctl daemon-reload
echo "########## start dokcer.services ##########"
systemctl enable docker
systemctl restart docker

## install ssm agent
echo "########## install ssm agent ##########"
dnf install -y https://s3.${data.aws_region.current.name}.amazonaws.com/amazon-ssm-${data.aws_region.current.name}/latest/linux_amd64/amazon-ssm-agent.rpm

## start ssm agent
echo "########## start ssm agent ##########"
systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

## modify hostname ##
echo "########## start modify hostname ##########"

### aws cli install ###
dnf install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

/usr/local/bin/aws --version

### set hostname from tag name ##

instance_id=""
tag_name=""
hostname=""
hostname_count=0
count=0

while [ $hostname_count -eq 0 ] && [ $count -lt 100 ]
do
  instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  tag_name=$(/usr/local/bin/aws ec2 describe-instances \
                    --region ${data.aws_region.current.name} \
                    --instance-id $instance_id \
                    --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' \
                    --output text)
  hostname=`echo $tag_name | sed -e s/${var.base_name}-//`
  hostname_count=$(echo -n $hostname | wc -c)
  count=$((count += 1))
done

hostnamectl set-hostname $hostname
echo $hostname

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
