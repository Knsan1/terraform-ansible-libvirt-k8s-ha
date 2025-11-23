# Network Resource
resource "libvirt_network" "bridged_network" {
  name   = "k8s-bridge"
  mode   = "bridge"
  bridge = "virbr1"
}

# Master Resources
resource "libvirt_volume" "ubuntu_disk_master" {
  for_each       = local.masters
  name           = "${each.key}.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_base.id
  format         = "qcow2"
  size           = 10 * 1024 * 1024 * 1024 # 10 GiB
}

resource "libvirt_cloudinit_disk" "cloudinit_master" {
  for_each       = local.masters
  name           = "cloudinit-${each.key}.iso"
  pool           = "default"
  user_data      = data.template_file.master_user_data[each.key].rendered
  network_config = data.template_file.master_net_cfg[each.key].rendered
}

resource "libvirt_domain" "vm_master" {
  for_each = local.masters
  name     = each.key
  memory   = var.memory
  vcpu     = var.vcpu

  disk {
    volume_id = libvirt_volume.ubuntu_disk_master[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit_master[each.key].id

  network_interface {
    network_id = libvirt_network.bridged_network.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

# Worker Resources

resource "libvirt_volume" "ubuntu_disk_worker" {
  for_each       = local.workers
  name           = "${each.key}.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_base.id
  format         = "qcow2"
  size           = 10 * 1024 * 1024 * 1024
}

resource "libvirt_cloudinit_disk" "cloudinit_worker" {
  for_each       = local.workers
  name           = "cloudinit-${each.key}.iso"
  pool           = "default"
  user_data      = data.template_file.worker_user_data[each.key].rendered
  network_config = data.template_file.worker_net_cfg[each.key].rendered
}

resource "libvirt_domain" "vm_worker" {
  for_each = local.workers
  name     = each.key
  memory   = var.worker_memory
  vcpu     = var.vcpu

  disk {
    volume_id = libvirt_volume.ubuntu_disk_worker[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit_worker[each.key].id

  network_interface {
    network_id = libvirt_network.bridged_network.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}