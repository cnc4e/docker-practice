output "public_subnet_az" {
  description = "Public Subnet を作成したAZ"
  value       = aws_subnet.pub-sub.availability_zone
}

output "pubulic_subnet_id" {
  description = "Public SubnetのID"
  value       = aws_subnet.pub-sub.id
}

output "sg_id" {
    description = "nodeに割り当てたSGのID"
    value = aws_security_group.swarm-node-sg.id
}
