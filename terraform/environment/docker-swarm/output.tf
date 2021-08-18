output "public_subnet_az" {
  description = "Public Subnet を作成したAZ"
  value       = module.docker-swarm.public_subnet_az
}

output "public_subnet_id" {
  description = "Public SubnetのID"
  value       = module.docker-swarm.pubulic_subnet_id
}

output "sg_id" {
  description = "nodeに割り当てたSGのID"
  value       = module.docker-swarm.sg_id
}
