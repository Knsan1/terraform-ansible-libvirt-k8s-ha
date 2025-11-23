# volumes.tf
resource "libvirt_volume" "ubuntu_base" {
  name = var.volume_name
  pool = "default"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [source]
  }
}
