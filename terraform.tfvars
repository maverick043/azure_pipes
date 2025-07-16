pm_api_url       = "https://proxmox.yourdomain.local:8006/api2/json"
pm_user          = "root@pam"
pm_password      = "your-secret-password"
pm_target_node   = "pve01"

vm_name_prefix   = "maas-node"
vm_template_name = "pxe-template"     # a cloud-init or PXE bootable VM template
vm_network_bridge = "vmbr0"
vm_disk_size     = "20G"
vm_disk_storage  = "local-lvm"
vm_memory        = 2048
vm_cores         = 2
vm_count         = 3
