#!/bin/bash

TOPOLOGY_FILE="topology.yaml"

COMPANY_COUNT=$(yq e '.companies | length' "$TOPOLOGY_FILE")
echo "Found $COMPANY_COUNT companies"

for ((i = 0; i < COMPANY_COUNT; i++)); do
  COMPANY_NAME=$(yq e ".companies[$i].company.name" "$TOPOLOGY_FILE")
  echo "→ Company: $COMPANY_NAME"

  PLATOON_COUNT=$(yq e ".companies[$i].company.platoons | length" "$TOPOLOGY_FILE")
  echo "  ↳ $PLATOON_COUNT platoons"

  for ((j = 0; j < PLATOON_COUNT; j++)); do
    PLATOON_NAME=$(yq e ".companies[$i].company.platoons[$j].platoon.name" "$TOPOLOGY_FILE")
    echo "    ↳ Platoon: $PLATOON_NAME"

    NODE_COUNT=$(yq e ".companies[$i].company.platoons[$j].platoon.nodes | length" "$TOPOLOGY_FILE")
    echo "      ↳ $NODE_COUNT nodes"

    for ((k = 0; k < NODE_COUNT; k++)); do
      NODE_NAME=$(yq e ".companies[$i].company.platoons[$j].platoon.nodes[$k].node.name" "$TOPOLOGY_FILE")
      echo "        ↳ Node: $NODE_NAME"

      INTERFACE_COUNT=$(yq e ".companies[$i].company.platoons[$j].platoon.nodes[$k].node.network_interfaces | length" "$TOPOLOGY_FILE")
      echo "          ↳ $INTERFACE_COUNT interfaces"

      for ((m = 0; m < INTERFACE_COUNT; m++)); do
        IF_NAME=$(yq e ".companies[$i].company.platoons[$j].platoon.nodes[$k].node.network_interfaces[$m].network_interface.name" "$TOPOLOGY_FILE")
        IF_NETWORK=$(yq e ".companies[$i].company.platoons[$j].platoon.nodes[$k].node.network_interfaces[$m].network_interface.network" "$TOPOLOGY_FILE")
        IF_IP=$(yq e ".companies[$i].company.platoons[$j].platoon.nodes[$k].node.network_interfaces[$m].network_interface.ip_address" "$TOPOLOGY_FILE")

        echo "            ↳ $IF_NAME → $IF_NETWORK [$IF_IP]"
      done
    done
  done
done
