data "aws_availability_zones" "available" {}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      "Name" = "${var.base_name}-vpc"
    },
    var.tags
  )

}

resource "aws_subnet" "pub-sub" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = "${var.base_name}-pub-sub"
    },
    var.tags
  )

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.base_name}-igw"
    },
    var.tags
  )
}

resource "aws_route_table" "pub-table" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      "Name" = "${var.base_name}-pub-table"
    },
    var.tags
  )
}

resource "aws_route" "route-ipv4" {
  route_table_id         = aws_route_table.pub-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.pub-sub.id
  route_table_id = aws_route_table.pub-table.id
}
