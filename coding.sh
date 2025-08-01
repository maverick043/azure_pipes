#!/bin/bash

set -e

VM_ID=101
DISK_PATH="/var/lib/vz/images/${VM_ID}/vm-${VM_ID}-disk-0.raw"
FILE_TO_COPY="./router_config.conf"
TARGET_PATH_IN_VM="/etc/network/router_config.conf"

echo "[*] Stopping VM ${VM_ID}..."
qm stop ${VM_ID}

echo "[*] Loading nbd kernel module..."
modprobe nbd max_part=8

echo "[*] Connecting VM disk to /dev/nbd0..."
qemu-nbd --connect=/dev/nbd0 "$DISK_PATH"

# Wait for partitions to be detected
sleep 2
PART=$(ls /dev/nbd0p* | head -n 1)

echo "[*] Mounting partition $PART..."
mkdir -p /mnt/vmroot
mount "$PART" /mnt/vmroot

echo "[*] Copying file into VM at $TARGET_PATH_IN_VM..."
cp "$FILE_TO_COPY" "/mnt/vmroot$TARGET_PATH_IN_VM"

echo "[*] Syncing and unmounting..."
sync
umount /mnt/vmroot
qemu-nbd --disconnect /dev/nbd0
rmdir /mnt/vmroot

echo "[*] Restarting VM ${VM_ID}..."
qm start ${VM_ID}

echo "[✓] Done."
