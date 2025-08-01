#!/bin/bash

# Usage: ./create_vms_from_company_topology.sh topology.yaml 200

TOPOLOGY_FILE="$1"
START_VMID="$2"

if [[ -z "$TOPOLOGY_FILE" || -z "$START_VMID" ]]; then
  echo "Usage: $0 <topology_file.yaml> <starting_vm_id>"
  exit 1
fi

# Check dependencies
for cmd in yq qm; do
  if ! command -v $cmd &>/dev/null; then
    echo "Missing command: $cmd"
    exit 1
  fi
done

VMID=$START_VMID

COMPANIES=$(yq e '.companies | keys | .[]' "$TOPOLOGY_FILE")

for COMPANY in $COMPANIES; do
  PLATOONS=$(yq e ".companies.${COMPANY}.platoons | keys | .[]" "$TOPOLOGY_FILE")
  for PLATOON in $PLATOONS; do
    NODES=$(yq e ".companies.${COMPANY}.platoons.${PLATOON}.nodes | keys | .[]" "$TOPOLOGY_FILE")
    for NODE in $NODES; do
      INTERFACES_COUNT=$(yq e ".companies.${COMPANY}.platoons.${PLATOON}.nodes.${NODE}.interfaces | length" "$TOPOLOGY_FILE")

      VM_NAME="${COMPANY}-${PLATOON}-${NODE}"

      echo "[*] Creating VM $VMID: $VM_NAME with $INTERFACES_COUNT interface(s)"

      # Create the base VM
      qm create $VMID --name "$VM_NAME" --memory 512

      for ((i = 0; i < INTERFACES_COUNT; i++)); do
        NET_NAME=$(yq e ".companies.${COMPANY}.platoons.${PLATOON}.nodes.${NODE}.interfaces[$i].network" "$TOPOLOGY_FILE")
        IP_ADDR=$(yq e ".companies.${COMPANY}.platoons.${PLATOON}.nodes.${NODE}.interfaces[$i].ip" "$TOPOLOGY_FILE")
        IF_NAME=$(yq e ".companies.${COMPANY}.platoons.${PLATOON}.nodes.${NODE}.interfaces[$i].name" "$TOPOLOGY_FILE")

        echo "    ↳ Attaching net${i} ($IF_NAME) to bridge $NET_NAME with IP $IP_ADDR"

        qm set $VMID --net${i} virtio,bridge=$NET_NAME
      done

      ((VMID++))
    done
  done
done

echo "[✓] All VMs created successfully."
