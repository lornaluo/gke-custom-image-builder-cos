#!/bin/bash
set -ex

echo "Copying driver files from /var/lib/nvidia to /home/kubernetes/bin/nvidia..."

# Ensure the target directory exists
sudo mkdir -p /home/kubernetes/bin/nvidia

# Copy all contents, including hidden files, preserving attributes.
if [ -d "/var/lib/nvidia" ]; then
  sudo cp -a /var/lib/nvidia/. /home/kubernetes/bin/nvidia/
  echo "Driver files copied to /home/kubernetes/bin/nvidia."
else
  echo "Error: /var/lib/nvidia source directory not found."
  exit 1
fi

# Optional: Clean up the temporary workspace
echo "Cleaning up /var/lib/nvidia..."
sudo rm -rf /var/lib/nvidia
echo "Temporary workspace cleaned."
