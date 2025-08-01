#!/bin/bash

# Usage: ./create_vms_from_company_topology.sh topology.yaml 100

TOPOLOGY_FILE="$1"
START_VMID="$2"

if [[ -z "$TOPOLOGY_FILE" || -z "$START_VMID" ]]; then
  echo "Usage: $0 <topology_file.yaml> <starting_vm_id>"
  exit 1
fi

if ! command -v yq >/dev/null; then
  echo "Missing 'yq'. Install with: sudo apt install yq"
  exit 1
fi

VMID="$START_VMID"
COMPANY_COUNT=$(yq e '.companies | length' "$TOPOLOGY_FILE")

for ((i = 0; i < COMPANY_COUNT; i++)); do
  COMPANY_NAME=$(yq e ".companies[$i].company.name" "$TOPOLOGY_FILE")
  PLATOON_COUNT=$(yq e ".companies[$i].company.platoons | length" "$TOPOLOGY_FILE")

  for ((j = 0; j < PLATOON_COUNT; j++)); do
    PLATOON_NAME=$(yq e ".companies[$i].company.platoons[$j].platoon.name" "$TOPOLOGY_FILE")
    NODE_COUNT=$(yq e ".companies[$i].company.platoons[$j].platoon.nodes | length" "$TOPOLOGY_FILE")

    for ((k = 0; k < NODE_COUNT; k++)); do
      NODE_NAME=$(yq e ".companies[$i].company.platoons[$j].platoon.nodes[$k].node.name" "$TOPOLOGY_FILE")
      INTERFACE_COUNT=$(yq e ".companies[$i].company.platoons[$j].platoon.nodes[$k].node.network_interfaces | length" "$TOPOLOGY_FILE")

      echo "[*] Creating VM $VMID: $COMPANY_NAME-$PLATOON_NAME-$NODE_NAME"

      qm create "$VMID" --name "${COMPANY_NAME}-${PLATOON_NAME}-${NODE_NAME}" --memory 512

      for ((m = 0; m < INTERFACE_COUNT; m++)); do
        NET_NAME=$(yq e ".companies[$i].company.platoons[$j].platoon.nodes[$k].node.network_interfaces[$m].network_interface.network" "$TOPOLOGY_FILE")
        IF_NAME=$(yq e ".companies[$i].company.platoons[$j].platoon.nodes[$k].node.network_interfaces[$m].network_interface.name" "$TOPOLOGY_FILE")
        IP_ADDR=$(yq e ".companies[$i].company.platoons[$j].platoon.nodes[$k].node.network_interfaces[$m].network_interface.ip_address" "$TOPOLOGY_FILE")

        echo "    ↳ Attaching $IF_NAME to $NET_NAME with IP $IP_ADDR"
        qm set "$VMID" --net${m} virtio,bridge="vmbr-${NET_NAME}"
      done

      ((VMID++))
    done
  done
done
