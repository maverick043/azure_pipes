#!/bin/bash

# Usage: ./create_vms_from_topology.sh topology.yaml 100

TOPOLOGY_FILE="$1"
START_VMID="$2"

if [[ -z "$TOPOLOGY_FILE" || -z "$START_VMID" ]]; then
  echo "Usage: $0 <topology_file.yaml> <starting_vmid>"
  exit 1
fi

# Check dependencies
for cmd in yq qm; do
  if ! command -v $cmd &>/dev/null; then
    echo "Missing command: $cmd. Please install it."
    exit 1
  fi
done

# Loop through each network
NETWORKS=($(yq e '.networks | keys | .[]' "$TOPOLOGY_FILE"))
VMID=$START_VMID
INDEX=1

for NET in "${NETWORKS[@]}"; do
  BRIDGE=$(yq e ".networks.${NET}.bridge" "$TOPOLOGY_FILE")
  CIDR=$(yq e ".networks.${NET}.cidr" "$TOPOLOGY_FILE")
  GATEWAY=$(yq e ".networks.${NET}.gateway" "$TOPOLOGY_FILE")

  PLATOON="platoon${INDEX}"
  echo "[*] Creating VM $VMID for $PLATOON (bridge: $BRIDGE)"

  # Create empty VM
  qm create $VMID --name "$PLATOON" --memory 512 --net0 virtio,bridge="$BRIDGE"

  # Optionally add a disk or boot image (customize as needed)
  # qm importdisk $VMID my_image.raw local-lvm
  # qm set $VMID --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$VMID-disk-0

  echo "[+] VM $VMID created and attached to $BRIDGE"
  ((VMID++))
  ((INDEX++))
done

echo "[✓] All VMs created from topology."
