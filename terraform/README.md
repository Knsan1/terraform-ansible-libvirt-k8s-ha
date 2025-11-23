- To destroy the infrastructure without removing the iso
```bash
terraform destroy \
  -target=libvirt_domain.vm_master \
  -target=libvirt_domain.vm_worker \
  -target=libvirt_cloudinit_disk.cloudinit_master \
  -target=libvirt_cloudinit_disk.cloudinit_worker \
  -target=libvirt_volume.ubuntu_disk_master \
  -target=libvirt_volume.ubuntu_disk_worker \
  -target=libvirt_network.bridged_network \
  --auto-approve
```