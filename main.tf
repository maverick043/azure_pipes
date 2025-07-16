provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "maas_vm" {
  count       = var.vm_count
  name        = "${var.vm_name_prefix}-${count.index + 1}"
  target_node = var.pm_target_node
  cores       = var.vm_cores
  sockets     = 1
  memory      = var.vm_memory
  onboot      = true
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"

  network {
    model  = "virtio"
    bridge = var.vm_network_bridge
  }

  disk {
    size    = var.vm_disk_size
    type    = "scsi"
    storage = var.vm_disk_storage
  }

  clone = var.vm_template_name
}
