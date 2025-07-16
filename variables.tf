variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "pm_user" {
  description = "Proxmox username"
  type        = string
}

variable "pm_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "pm_target_node" {
  description = "Proxmox node where the VM will run"
  type        = string
}

variable "vm_name_prefix" {
  description = "Prefix for the VM names"
  type        = string
}

variable "vm_template_name" {
  description = "Name of the template to clone"
  type        = string
}

variable "vm_network_bridge" {
  description = "Bridge to attach VM NIC to"
  type        = string
}

variable "vm_disk_size" {
  description = "Disk size for the VM (e.g., 20G)"
  type        = string
}

variable "vm_disk_storage" {
  description = "Proxmox storage name (e.g., local-lvm)"
  type        = string
}

variable "vm_memory" {
  description = "Memory size in MB"
  type        = number
}

variable "vm_cores" {
  description = "Number of vCPU cores"
  type        = number
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
}
