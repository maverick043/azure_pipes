#!/bin/bash

# Usage: sudo ./create_proxmox_bridges.sh topology.yaml

TOPOLOGY_FILE="$1"
INTERFACES_FILE="/etc/network/interfaces"

if [[ -z "$TOPOLOGY_FILE" ]]; then
  echo "Usage: $0 <topology_file.yaml>"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root (sudo)."
  exit 1
fi

if ! command -v yq &>/dev/null; then
  echo "Please install 'yq' to parse YAML files."
  exit 1
fi

if ! command -v ipcalc &>/dev/null; then
  echo "Please install 'ipcalc' for CIDR parsing: apt install ipcalc"
  exit 1
fi

TOTAL=$(yq e '.networks | length' "$TOPOLOGY_FILE")

echo "[*] Found $TOTAL networks in topology."

for ((i = 0; i < TOTAL; i++)); do
  NAME=$(yq e ".networks[$i].network.name" "$TOPOLOGY_FILE" | tr -d "'\"")
  CIDR=$(yq e ".networks[$i].network.cidr" "$TOPOLOGY_FILE" | tr -d "'\"")

  BRIDGE="vmbr-${NAME}"

  echo "[*] Processing network $NAME ($CIDR) → $BRIDGE"

  if grep -q "iface $BRIDGE" "$INTERFACES_FILE"; then
    echo "    ↳ Bridge $BRIDGE already exists. Skipping."
    continue
  fi

  if [[ -z "$CIDR" || "$CIDR" == "null" ]]; then
    echo "    ⚠️  CIDR missing. Defaulting to no IP config."
    cat <<EOF >> "$INTERFACES_FILE"

auto $BRIDGE
iface $BRIDGE inet manual
    bridge_ports none
    bridge_stp off
    bridge_fd 0
EOF
  else
    # Extract IP and netmask
    GATEWAY=$(echo "$CIDR" | sed 's|0/|1/|')  # e.g., 192.168.1.0/24 → 192.168.1.1/24
    NETMASK=$(ipcalc -m "$CIDR" | cut -d'=' -f2)
    echo "    ↳ Setting gateway IP: $GATEWAY, netmask: $NETMASK"

    cat <<EOF >> "$INTERFACES_FILE"

auto $BRIDGE
iface $BRIDGE inet static
    address ${GATEWAY%/*}
    netmask $NETMASK
    bridge_ports none
    bridge_stp off
    bridge_fd 0
EOF
  fi
done

echo "[✓] Bridge definitions updated in $INTERFACES_FILE"
echo "[*] Apply changes with: ifreload -a  or systemctl restart networking"
