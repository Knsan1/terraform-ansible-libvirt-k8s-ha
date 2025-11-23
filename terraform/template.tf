data "template_file" "master_user_data" {
  for_each = local.masters
  template = file("${path.module}/cloud-init/cloud-init.tmpl")
  vars = {
    hostname = each.value.hostname
    vm_name  = each.value.vm_name
  }
}

data "template_file" "master_net_cfg" {
  for_each = local.masters
  template = file("${path.module}/network-config/network-config.tmpl")
  vars = {
    ip_address = each.value.ip_address
    gateway    = each.value.gateway
    dns        = each.value.dns
  }
}

data "template_file" "worker_user_data" {
  for_each = local.workers
  template = file("${path.module}/cloud-init/cloud-init.tmpl")
  vars = {
    hostname = each.value.hostname
    vm_name  = each.value.vm_name
  }
}

data "template_file" "worker_net_cfg" {
  for_each = local.workers
  template = file("${path.module}/network-config/network-config.tmpl")
  vars = {
    ip_address = each.value.ip_address
    gateway    = each.value.gateway
    dns        = each.value.dns
  }
}