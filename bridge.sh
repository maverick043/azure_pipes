#!/bin/bash

# Usage: ./create_proxmox_bridges.sh topology.yaml

TOPOLOGY_FILE="$1"
INTERFACES_FILE="/etc/network/interfaces"

if [[ -z "$TOPOLOGY_FILE" ]]; then
  echo "Usage: $0 <topology_file.yaml>"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "Please run as root"
   exit 1
fi

# Check for yq
if ! command -v yq >/dev/null 2>&1; then
  echo "Please install 'yq' to run this script."
  exit 1
fi

echo "[*] Parsing topology..."
NETWORKS=($(yq e '.networks | keys | .[]' "$TOPOLOGY_FILE"))

for NET in "${NETWORKS[@]}"; do
  BRIDGE=$(yq e ".networks.${NET}.bridge" "$TOPOLOGY_FILE")
  CIDR=$(yq e ".networks.${NET}.cidr" "$TOPOLOGY_FILE")
  GATEWAY=$(yq e ".networks.${NET}.gateway" "$TOPOLOGY_FILE")

  # Extract IP address from CIDR (e.g., 192.168.0.0/24 → 192.168.0.1)
  IFACE_IP="${GATEWAY:-$(echo $CIDR | cut -d'/' -f1 | sed 's/0$/1/')}"

  echo "[*] Checking if $BRIDGE exists..."

  if grep -q "iface $BRIDGE" "$INTERFACES_FILE"; then
    echo "    ↳ Bridge $BRIDGE already defined. Skipping."
    continue
  fi

  echo "[+] Creating bridge $BRIDGE with IP $IFACE_IP"

  cat <<EOF >> "$INTERFACES_FILE"

auto $BRIDGE
iface $BRIDGE inet static
    address $IFACE_IP
    netmask $(ipcalc -m "$CIDR" | cut -d'=' -f2)
    bridge_ports none
    bridge_stp off
    bridge_fd 0
EOF

done

echo "[✓] Bridge definitions added to $INTERFACES_FILE"
echo "[*] Restart networking or reboot to apply."
