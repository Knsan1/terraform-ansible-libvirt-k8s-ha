output "master_ips" {
  value = {
    for k, v in local.masters : k => v.ip_address
  }
}

output "worker_ips" {
  value = {
    for k, v in local.workers : k => v.ip_address
  }
}