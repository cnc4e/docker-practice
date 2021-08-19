output "mount-ip" {
  description = "EFSマウントポイントとなるIPアドレス"
  value       = module.efs.mount-ip
}
