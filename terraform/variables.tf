variable "vm_name" {
  description = "VM hostname"
  type        = string
  default     = "ubuntu-vm"
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "worker_memory" {
  description = "Memory in MB"
  type        = number
  default     = 1538
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 16
}

variable "volume_name" {
  default = "noble-24.04-base.qcow2"
  type    = string
}

