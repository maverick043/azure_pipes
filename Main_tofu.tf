terraform {
  required_providers {
    maas = {
      source = "maas/maas"
      version = ">= 0.9.0"
    }
  }
}

provider "maas" {
  api_url = "http://YOUR_MAAS_SERVER/MAAS"
  api_key = "YOUR_API_KEY"
}

# Find the space and subnet
data "maas_spaces" "target_space" {
  name = "YOUR_SPACE_NAME"
}

data "maas_subnets" "target_subnet" {
  space = data.maas_spaces.target_space.name
}

# Create a VM on a KVM Pod
resource "maas_machine" "vm" {
  count      = 1

  pod        = "YOUR_KVM_POD_NAME"
  cores      = 2
  memory     = 4096 # MB
  storage    = 20   # GB

  interfaces {
    subnet = data.maas_subnets.target_subnet.subnets[0].id
    mode   = "STATIC"
    ip_address = null
  }

  hostname  = "my-vm-01"
  domain    = "yourdomain.local"
  architecture = "amd64/generic"
  zone         = "default" # optional
}

# Deploy Ubuntu 22.04 onto the VM
resource "maas_machine_deployment" "vm_deploy" {
  machine_id = maas_machine.vm[0].id

  osystem = "ubuntu"
  distro_series = "jammy" # Ubuntu 22.04 = 'jammy'
  hwe_kernel = "ga-22.04"
  user_data = <<EOF
#cloud-config
users:
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - YOUR_SSH_PUBLIC_KEY_HERE
EOF
}
