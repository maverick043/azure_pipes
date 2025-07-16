output "vm_names" {
  value = [for vm in proxmox_vm_qemu.maas_vm : vm.name]
}
