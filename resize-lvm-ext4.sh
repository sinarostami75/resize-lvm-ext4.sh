#!/bin/bash

DISK="/dev/sda"
PARTITION="/dev/sda3"
VG_NAME="ubuntu-vg"
LV_NAME="ubuntu-lv"

# Check if the disk exists
if [ ! -b "$DISK" ]; then
  echo "Error: Disk $DISK not found."
  exit 1
fi

# Check if the partition exists
if [ ! -b "$PARTITION" ]; then
  echo "Error: Partition $PARTITION not found."
  exit 1
fi

# Resize partition
echo "Resizing partition $PARTITION..."
parted $DISK resizepart 3 100% || { echo "Failed to resize partition."; exit 1; }

# Resize physical volume
echo "Resizing physical volume $PARTITION..."
pvresize $PARTITION || { echo "Failed to resize physical volume."; exit 1; }

# Extend logical volume
echo "Extending logical volume $LV_NAME..."
lvextend -l +100%FREE /dev/$VG_NAME/$LV_NAME || { echo "Failed to extend logical volume."; exit 1; }

# Resize filesystem
echo "Resizing filesystem on logical volume $LV_NAME..."
resize2fs /dev/$VG_NAME/$LV_NAME || { echo "Failed to resize filesystem."; exit 1; }

echo "Resize operation completed successfully."
